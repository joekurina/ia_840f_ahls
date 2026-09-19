# Library:
#    bw-agilex
#
# Desc:
#    bmc_agilex_handler.py
#
#  Provided by
#  -----------
#      BittWare, a Molex Company.
#      45 South Main St. Suite L100
#      Concord, NH 03301
#      Ph:     (603) 226 0404
#      WWW:    https://www.bittware.com
#      Email:  support@bittware.com
#
# Copyright © 2021, BittWare, a Molex Company.
#
# License:
#  This source code is provided to you (the Licensee) under
#  license by BittWare, a Molex Company.  To view or use this
#  source code, the Licensee must accept a Software License
#  Agreement (viewable at developer.bittware.com), which is
#  commonly provided as a click-through license agreement.  The
#  terms of the Software License Agreement govern all use and
#  distribution of this file unless an alternative superseding
#  license has been executed with BittWare.  This source code
#  and its derivatives may not be distributed to third parties
#  in source code form.  Software including or derived from this
#  source code, including derivative works thereof created by
#  Licensee, may be distributed to third parties with BITTWARE
#  hardware only and in executable form only.
#
#  The click-thorough license is available here:
#  https://developer.bittware.com/software_license.txt

"""
Bmc Agilex handler class

******
This class is really a bmc handler that uses BRAM, BMC and ARBITER
components and any KIT that provides a valid RW handle for said components.
For the moment this is strictly Agilex but doesn't necessarily have to be.
******
"""
import time
from typing import TYPE_CHECKING
from bw_core.exceptions import ComponentException, BmcError
from bw_kit.kit_bmc_handler import KitBmcHandler

if TYPE_CHECKING:
    from bw_kit import DeviceEntry


class BmcHandler(KitBmcHandler):
    """BMC Agilex Handler class
    This handler class is for communicating with the BMC using the
    BittWare Agilex FPGA library to communicate with the BMC via the FPGA interface
    Keyword Args:
        device (DeviceEntry): Get a BMC handler for this card.
    """

    _BMC_BRAM_REQUEST_COUNT_ADDRESS = 0
    _BMC_BRAM_REQUEST_ADDRESS = 4
    _BMC_BRAM_RESPONSE_COUNT_ADDRESS = 0x800
    _BMC_BRAM_RESPONSE_ADDRESS = 0x804
    _BMC_SPI_MAX_PACKET = 0x7FC

    def __init__(self, device: "DeviceEntry"):
        super().__init__(device, use_sem=True)

        comp_index = self._card_entry.component_index()
        if comp_index.empty:
            raise BmcError(
                "Failed to create BMC handler, no component index for"
                f" {self._card_entry.device_tag}: '{comp_index.empty}'"
            )

        mem_spaces = self._card_entry.kit.memory_spaces
        self.bmc_bram = comp_index.get_component(("BMC_BRAM", ""), mem_space=mem_spaces)
        self.bmc_irq = comp_index.get_component(("BMC_IRQ", ""), mem_space=mem_spaces)
        self.bmc_arbiter = comp_index.get_component(("ARBITER", ""), mem_space=mem_spaces)
        if not (self.bmc_bram and self.bmc_irq and self.bmc_arbiter):
            raise BmcError("Failed to get one or more components for the BMC handler")

        self.rw_bram = device.DevRW()
        self.rw_irq = device.DevRW()
        self.rw_arb = device.DevRW()

        self.bmc_bram.rw_handler(self.rw_bram)
        self.bmc_irq.rw_handler(self.rw_irq)
        self.bmc_arbiter.rw_handler(self.rw_arb)

        self.bmc_irq.mask_enable()

    def claim_access_to_bmc(self):
        """claim access to bmc"""
        access_claimed = False
        claim_attempts_remaining = 20

        while not access_claimed:
            try:
                self.bmc_arbiter.claim()
                access_claimed = True
                return True

            except ComponentException:
                time.sleep(0.01)
                claim_attempts_remaining -= 1

                if claim_attempts_remaining <= 0:
                    self.bmc_arbiter.release()
                    return False
        return False

    def write_function(self, write_bytes):
        """write message to bmc"""
        self._sem_lock()
        if self.display_writes:
            print("WRITE:", end=" ")

            for byte_to_print in write_bytes:
                print(hex(byte_to_print), end=" ")

            print(f"({write_bytes} bytes)")

        request_length_bytes = len(write_bytes)

        # Zero pad bytes to make it to a multiple of 4 as we'll be writing
        # a dword at a time.
        while (len(write_bytes) % 4) != 0:
            write_bytes.append(0)

        # Validate the length of the write we've been asked to do.
        if len(write_bytes) > self._BMC_SPI_MAX_PACKET:
            raise BmcError(
                f"Trying to write too many bytes for an SPI packet ({len(write_bytes)} > {self._BMC_SPI_MAX_PACKET})"
            )

        if len(write_bytes) > ((self.bmc_bram.size / 2) - 4):
            raise BmcError(f"Can't write more bytes ({len(write_bytes)}) than size of shared memory space.")

        # Our input looks good, so now get exclusive access to the shared memory
        # with the BMC.
        if not self.claim_access_to_bmc():
            raise BmcError("Couldn't claim access to shared memory with BMC when trying to write.")

        # Copy the bytes into the shared memory, a dword at a time.
        try:
            for index in range(0, len(write_bytes), 4):
                value = write_bytes[index]
                value += write_bytes[index + 1] << 8
                value += write_bytes[index + 2] << 16
                value += write_bytes[index + 3] << 24

                self.rw_bram.write32(self._BMC_BRAM_REQUEST_ADDRESS + index, value)  # type: ignore

            # We've written the data, it's now safe to write the request count.
            # We write data, then length so the BMC doesn't try to read a half
            # written buffer.
            self.rw_bram.write32(self._BMC_BRAM_REQUEST_COUNT_ADDRESS, request_length_bytes)  # type: ignore

        except ComponentException as err:
            self.bmc_arbiter.release()
            print(f"Error while writing to shared memory with BMC ({str(err)})")
            raise BmcError(err) from err

        # Trigger an interrupt to the let the BMC know we've sent it a request.
        # We enable IRQ because it costs nothing to make sure it's enabled.the
        self.bmc_irq.mask_enable()
        self.bmc_irq.generate()

        self.bmc_arbiter.release()

    def read_function(self, _max_bytes):
        """Read a BMC response"""
        # Make sure the IRQ isn't masked off.
        self.bmc_irq.mask_enable()

        # Watch for an IRQ from the BMC.
        try:
            self.bmc_irq.poll_irq()
        except ComponentException:
            self._sem_unlock()
            return []

        # We've observed an IRQ from the BMC, get exclusive access to the memory
        # shared with the BMC.
        if not self.claim_access_to_bmc():
            raise BmcError("Couldn't claim access to shared memory with BMC when trying to read (saw the IRQ).")

        # Read the response length then validate it.
        response_byte_count = self.rw_bram.read32(self._BMC_BRAM_RESPONSE_COUNT_ADDRESS)  # type: ignore

        if response_byte_count > self._BMC_SPI_MAX_PACKET:
            raise BmcError(
                f"Trying to read too many bytes for an SPI packet ({response_byte_count} > {self._BMC_SPI_MAX_PACKET})"
            )

        if response_byte_count > ((self.bmc_bram.size / 2) - 4):
            raise BmcError(f"Nonsense response length ({response_byte_count} is greater than shared memory space)")

        bytes_read = []
        bytes_to_read = response_byte_count

        # Round up the PCIe bytes to read to dwords.
        if (bytes_to_read % 4) != 0:
            bytes_to_read += 4 - (bytes_to_read % 4)

        # Read the response bytes from the BMC, a dword at a time.
        for byte_offset in range(0, bytes_to_read, 4):
            value = self.rw_bram.read32(self._BMC_BRAM_RESPONSE_ADDRESS + byte_offset)  # type: ignore
            bytes_read.append(value & 0xFF)
            bytes_read.append((value >> 8) & 0xFF)
            bytes_read.append((value >> 16) & 0xFF)
            bytes_read.append((value >> 24) & 0xFF)

        # Trim off any padding bytes from reading a dword at a time.
        if len(bytes_read) > response_byte_count:
            bytes_read = bytes_read[:response_byte_count]

        # Zero the response count, to let the BMC know we handled the buffer.
        self.rw_bram.write32(self._BMC_BRAM_RESPONSE_COUNT_ADDRESS, 0)  # type: ignore

        # Clear the IRQ, now that we've consumed the response from the BMC.
        self.bmc_irq.clear()

        self.bmc_arbiter.release()

        if self.display_reads:
            print("READ:", end=" ")
            for byte_to_print in bytes_read:
                print(hex(byte_to_print), end=" ")

            print(f"({len(bytes_read)} bytes)")

        self._sem_unlock()
        return bytes_read
