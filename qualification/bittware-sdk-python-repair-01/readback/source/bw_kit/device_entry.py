# Library:
#    bw_kit.device_entry.py
#
# Desc:
#    kit.py
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
# Copyright © 2020, BittWare, a Molex Company.
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
Base device entry class, all kits return devices and work on
devices derived from this class. Kits may extend this class
for additional kit specific device functionality.

Kits should ONLY derive from this class if absolutely necessary.
"""
import logging
from typing import TYPE_CHECKING, NamedTuple, Any, Optional
from bw_core import BMCType
from bw_core.data_types.card_desc_model import CardConfigurationModel
from bw_core.exceptions.base import BmcError  # only needed for CPLD version
from bw_core.register_rw import PCIDevRW
from bw_core.data_types import VendorDeviceInfo, DeviceComponentIndex
from bw_bmc_abs import BaseBmc
from bw_kit.enums import Interfaces
from bw_kit.component_resolver import ComponentResolver
from bw_kit.kits import Kits

if TYPE_CHECKING:
    from bw_kit.kit import Kit
    from bw_core.product import BaseProduct as Product

log = logging.getLogger(__name__)


class DeviceEntry(NamedTuple):
    """
    A generic / agnostic device entry that should work for any Kit class.
    Provides immutable generic device entries. Used by all bw_kits for
    card enumeration. A kit is only required to provide the fields "interface"
    and "device".

    The rest are populated if available and extra_props is a catch-all that
    sub classes can use to cache any additional information needed.

    Attributes:
        product: The product object for this device entry
        interface: The interface for this device entry
        device: The device number for this device entry
        serial_number: The serial number for this device entry
        configuration: The configuration for this device entry
        revision: The revision for this device entry
        dev_ids: The vendor and device IDs for this device entry
        kit_name: The name of the kit that produced this device entry
        extra_props: A catch-all for any additional information needed
    """

    product: Optional["Product"] = None
    interface: Optional[Interfaces] = None
    device: Optional[int] = None
    serial_number: str = ""
    configuration: str = ""
    revision: str = ""
    dev_ids: VendorDeviceInfo = VendorDeviceInfo(0, 0)
    kit_name: str = ""
    extra_props: dict[str, Any] = {}

    def __repr__(self) -> str:
        interface_value = self.interface.value if self.interface else ""
        if self.product:
            return (
                f"{self.kit_name}.Entry(interface='{interface_value}', "
                f"product='{self.product.name}', serial_number'{self.serial_number}')"
            )
        return (
            f"{self.kit_name}.Entry(interface='{interface_value}', "
            f"product='{self.product}', serial_number'{self.serial_number}')"
        )

    # @MaskingProperty  # DOES NOT WORK for NamedTuple
    @property
    def kit(self) -> "Kit":
        """
        Returns the Kit class that produced this entry

        Raises: KeyError if entry was created with an invalid kit name
        """
        if self.kit_name not in Kits.KitClasses:
            log.debug("kit_name not found in Kits.KitClasses")
        kit = Kits.KitClasses[self.kit_name]
        log.debug("kit returned by Kits.KitClasses is: %s", kit)
        return kit

    @property
    def handle(self) -> Any:
        """Shorthand - calls Kit.handle(this entry) on the proper Kit class"""
        log.debug("Accessing handle property for device entry: %s", self)
        handle = self.kit.get_handle(self)
        log.debug("Handle returned by get_handle is: %s", handle)
        return handle

    @property
    def bmc(self) -> Optional[BaseBmc]:
        """Shorthand - calls Kit.bmc(this entry) on the proper Kit class"""
        return self.kit.get_bmc(self)

    @property
    def bmc_type(self) -> "BMCType":
        """The BMC type for this device entry"""
        if not self.product:
            return BMCType.NONE

        return self.product.bmc_type_from_dev_ids(self.dev_ids)

    @property
    def device_tag(self) -> str:
        """Shorthand calls Kit.device_tag(this entry) on the proper Kit class"""
        return self.kit.device_tag(self)

    @property
    def location(self) -> Any:
        """entry location as a property if set, otherwise None"""
        return self.extra_props.get("location")

    def bmc_version(self, rescan: bool = False) -> Optional[str]:
        """Get and cache the BMC version"""
        if not self.bmc:
            return None

        if "bmc_version" not in self.extra_props or rescan:
            self.extra_props["bmc_version"] = self.bmc.version()

        return self.extra_props["bmc_version"]

    def DevRW(self, **kwargs: Any) -> PCIDevRW:  # pylint: disable=invalid-name
        """
        Create and return a DevRW object for this device (self)
        Use the kit associated with this device and this devices
        device handle to construct and appropriate RegRW object.
        Derived classes will want use any additional info carried
        with the device entry as appropriate. For instance, edge_id
        for a UART Edge device.
        Any additional kwargs will be passed on to the DevRW object
        constructor, such as 'base' (address) or 'space' memory space.

        Args:
            **kwargs: Additional arguments to pass to the DevRW constructor

        Returns:
            A DevRW object for this device entry
        """
        return self.kit.DevRW(self.handle, device_tag=self.device_tag, **kwargs)

    # handle this once with get bmc info, remove dependency here.
    def cpld_version(self, rescan: bool = False) -> Optional[str]:
        """
        Get and cache the CPLD version

        Args:
            rescan: Force a rescan of the of BMC

        Returns:
            The cached CPLD version or None
        """
        if self.bmc_type == BMCType.LITE or not self.bmc:
            return None

        if "cpld_version" not in self.extra_props or rescan:
            try:
                self.bmc.discover()
                cpld_version = self.bmc.card().cpld_version()
            except BmcError:
                cpld_version = "<Not Available>"
            self.extra_props["cpld_version"] = cpld_version

        return self.extra_props["cpld_version"]

    def card_description(self) -> Optional[CardConfigurationModel]:
        """
        load the card description for this device entry

        !!! note
            If the device entry was found by passive scanning, the card
            revision will be None and this function will always return None.

        Returns:
            the card description object for this device entry or None
        """
        if not self.product:
            return None

        revision = self.revision if self.revision else ""
        return self.product.get_card_desc(revision)

    def component_index(self) -> DeviceComponentIndex:
        """
        Create the component Index for this device entry if available

        Returns:
            The component Index or None
        """
        if "component_index" in self.extra_props:
            return self.extra_props["component_index"]

        # if this device doesn't support memory space read/write, return an empty component index
        try:
            rw_handler = self.DevRW()
        except NotImplementedError:
            index = DeviceComponentIndex(dev_ids=VendorDeviceInfo(0, 0), dev_rw=PCIDevRW())
            index.empty = f"Device {self.device_tag} does not support memory space read/write"
            return index

        kwargs = {}
        if "external_json" in self.extra_props:
            kwargs["external_json"] = self.extra_props["external_json"]
        index = ComponentResolver.get_component_index(
            self.dev_ids, rw_handler, spaces=self.kit.memory_spaces, **kwargs
        )
        self.extra_props["component_index"] = index
        return index

    def i2c_bus_cache(self) -> dict[str, Any]:
        """
        Get the cached I2C busses
        Once get_i2c_components() is called, this function will return a dict of
        bus names to FpgaI2cBus objects

        Returns:
            The cached I2C busses
        """
        if "i2c_busses" not in self.extra_props:
            self.extra_props["i2c_busses"] = {}
        return self.extra_props["i2c_busses"]
