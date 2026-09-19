# Library:
#    bw-agilex
#
# Desc:
#    bmc30_agilex_handler.py
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
import logging
from typing import TYPE_CHECKING
from bw_core.legacy import BraceMessage
from bw_core.exceptions.base import ComponentException
from bw_core.enums import MemorySpace
from bw_core.utils.semaphore.exception import BWSyncException
from bw_kit.kit_bmc_handler import KitBmcHandler

from bw_cmdk.nodes import Extended
from bw_cmdk_comps_v1.BMC.bmc3_0 import BMC3_0
from bw_cmdk_comps_v1.BMC.bmc3_0_host_if import BMC3_0_HOST_IF
from bw_cmdk_comps_v1.BMC.bmc3_capability_rom import BMC3CapabilityROM

if TYPE_CHECKING:
    from bw_kit import DeviceEntry


log = logging.getLogger(__name__)
_B = BraceMessage


class Bmc30Handler(KitBmcHandler):
    """BMC30 Agilex Handler class
    This handler class is for communicating with the BMC using the
    BittWare Agilex FPGA library to communicate with the BMC via the FPGA interface
    Keyword Args:
        device (DeviceEntry): Get a BMC handler for this card.
    """

    def __init__(self, device: "DeviceEntry"):
        super().__init__(device, use_sem=True)

        # updated in get_cmdk_node
        self.cmdk_ms = MemorySpace.BAR0

        host_node = self._get_host_node()
        bmc_3_0_comps = BMC3_0(host_node)

        dev_rw = device.DevRW(space=self.cmdk_ms)  # has to be the memory space of CMDK

        self.host_intf: BMC3_0_HOST_IF = bmc_3_0_comps.host_interface0
        self.host_intf.handler(dev_rw)

        self.i2c_intf: BMC3_0_HOST_IF = bmc_3_0_comps.host_interface1
        self.i2c_intf.handler(dev_rw)

        self.capabilities: BMC3CapabilityROM = bmc_3_0_comps.capabilities
        if dev_rw and self.capabilities.offset != 0:
            self.capabilities.read(dev_rw)

        # self.host_intf.display_reads = False
        # self.host_intf.display_writes = False

    def _get_host_node(self) -> Extended:
        """
        Returns the actual CMDK BMC3_IF node or a synthesized one from
        register map components. This allows us to use the same handler
        CMDK enabled vs. old school register map FPGA images.

        The CMDK host node is actually an extended node with 3 components
        in it. Two host interfaces and BMC capabilities.
        """

        comp_index = self._card_entry.component_index()
        if comp_index.empty:
            raise ComponentException(
                f"Component index for {self._card_entry.device_tag} is empty: '{comp_index.empty}'"
                )

        if comp_index.kind == "CMDK":
            self.cmdk_ms = comp_index.node_map.mem_space  # type: ignore
            return comp_index.get_cmdk_node("BMC3_IF")  # type: ignore
            # catch exceptions?
            # should be? return comp_index.get_component(("BMC3_IF", ""))

        # non CMDK host interface is always BAR0
        self.cmdk_ms = MemorySpace.BAR0

        host_comp = comp_index.get_component(("BMC_HOST0_IF", ""), want="base", mem_space=MemorySpace.BAR0)
        if not host_comp:
            raise ComponentException("Can't create BMC3 handler, 'BMC_HOST0_IF' not found.")
        host0_base = host_comp.base_addr

        host_comp = comp_index.get_component(("BMC_HOST1_IF", ""), want="base", mem_space=MemorySpace.BAR0)
        if not host_comp:
            raise ComponentException("Can't create BMC3 handler, 'BMC_HOST1_IF' not found.")
        host1_base = host_comp.base_addr

        host_caps = comp_index.get_component(("BMC_CAP_ROM_IF", ""), want="base", mem_space=MemorySpace.BAR0)
        comp_offset = host_caps.base_addr if host_caps else 0

        host_node = Extended(
            comp_class="BMC3_0_HOST_IF",
            version="0.0.0",
            name="BMC3_IF",
            comp_offset=comp_offset,
            next_rbo=0,
            reg_count=2,
            registers=["HOST0_IF_OFFSET", "HOST1_IF_OFFSET"],
            reg_values=[host0_base, host1_base],
        )
        return host_node

    def write_function(self, write_bytes):
        """
        SPI write function
        """
        if self._sem:
            try:
                self._sem_lock()
            except BWSyncException:
                # pylint: disable=protected-access
                log.warning("Failed to acquire semaphore (%s) lock", self._sem._name)
                return False
        data = self.host_intf.write_function(write_bytes, BMC3_0_HOST_IF.MESSAGE_TYPE_MCTP)
        return data

    def read_function(self, _max_bytes) -> list[int]:
        """
        SPI read function
        """
        message = self.host_intf.read_function(BMC3_0_HOST_IF.BMC_SPI_MAX_PACKET, BMC3_0_HOST_IF.MESSAGE_TYPE_MCTP)
        if self._sem:
            try:
                self._sem_unlock()
            except BWSyncException:
                # pylint: disable=protected-access
                log.warning("Failed to release semaphore (%s) lock", self._sem._name)
                return []
        return message

    def i2c_writeread_function(self, i2caddress, regaddr, data, numbytes):
        """
        I2C command / response
        """
        if self._sem:
            try:
                self._sem_lock()
            except BWSyncException:
                # pylint: disable=protected-access
                log.warning("Failed to acquire semaphore (%s) lock", self._sem._name)
                return []

        read_val = self.i2c_intf.i2c_writeread_function(i2caddress, regaddr, data, numbytes)

        if self._sem:
            try:
                self._sem_unlock()
            except BWSyncException:
                # pylint: disable=protected-access
                log.warning("Failed to release semaphore (%s) lock", self._sem._name)
                return []
        return read_val
