# Library:
#    bw_kit.kit
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
Base class for all providers of kit functionality - A kit provides
listing and connections/handles for cards along with memory and register
R/W methods.

Other packages (such as bw_cardtest) work with "kits" relying on the
common interface.
"""
import logging
import abc
from typing import TYPE_CHECKING, Any, Optional
from bw_core import MemorySpace
from bw_core.register_rw import PCIDevRW
from bw_kit.enums import Interfaces
from bw_kit.kits import Kits

if TYPE_CHECKING:
    from bw_kit.device_entry import DeviceEntry
    from bw_bmc_abs import BaseBmc


log = logging.getLogger(__name__)


class Kit(abc.ABC):
    """
    Base class for Kit plug-ins.

    All Kits are "singletons" intended to only have the class used directly an
    are not instantiated to instances. However no effort is made to prevent
    creating instances - so don't do it.

    All data is kept in the class. Hence each Kit class contains the list of
    all discovered device supported by the specific class and provides access
    to the device.

    Derived classes implement class methods as needed and appropriate for the
    specific kit being used. Example device types PCI, USB, VFIO, SYSFS.

    Attributes:
        interfaces: List of interfaces supported by this class
        interface_names: List of interface names supported by this Kit
        memory_spaces: List of memory spaces supported by this Kit Class
        memory_space_names: List of memory space names supported by this Kit
    """

    # TODD: make all kits single interface kits?
    interfaces: list[Interfaces] = []
    interface_names: list[str] = []
    memory_spaces: list[MemorySpace] = []
    memory_space_names: list[str] = []

    CODE_STATUS = "released"

    _devices: list["DeviceEntry"] = []

    class DevRW(PCIDevRW):
        """
        All derived classes will implement this as a subclass of RegRWABC.
        Typically this is one of the standard ones already defined in bw_core,
        such as PCIDevRW.
        """

    def __init_subclass__(cls):
        """Used to capture all of the Kit classes provided as entry points"""
        Kits.KitEntryPoints[cls.__qualname__] = cls  # type: ignore

    @classmethod
    def init_lists(cls, device_list: Optional[list["DeviceEntry"]] = None):
        """
        Provided primarily for unit tests but may be useful
        Sets the currently cached device lists to whatever is passed in.
        The default parameters clear the device lists

        Args:
            device_list: A list of DeviceEntry objects
        """
        cls._devices = device_list if device_list else []

    @classmethod
    def device_tag(cls, entry: "DeviceEntry") -> str:
        """
        Create a unique string 'tag' for a DeviceEntry

        Args:
            entry: A DeviceEntry object

        Returns:
            A unique string tag for the DeviceEntry. The default returns
            a string containing the entries "interface:device" ie. 'USB:0'.
            If the entries interface matches the PCI interface alias, 'PCI'
            is used rather than the actual interface, for example: 'VFIO:3'
            becomes 'PCI:3'.
        """
        if entry.interface:
            if entry.interface == Kits.PCI_INTERFACE_ALIAS:
                return f"PCI:{entry.device}"
            return f"{entry.interface.value}:{entry.device}"
        return f"None:{entry.device}"

    @classmethod
    def get_handle(cls, _entry: "DeviceEntry") -> Any:
        """
        Return a device handle for a given DeviceEntry

        Args:
            _entry: A DeviceEntry object

        Returns:
            A device handle
        """
        raise NotImplementedError

    @classmethod
    def get_bmc(cls, _entry: "DeviceEntry") -> Optional["BaseBmc"]:
        """
        Return a BMC handle for a given DeviceEntry

        Args:
            _entry: A DeviceEntry object

        Returns:
            A BMC handle or None
        """
        raise NotImplementedError

    @classmethod
    @abc.abstractmethod
    def read32(cls, _handle: Any, _mem_space: MemorySpace, _addr: int) -> int:
        """Read a 32 bit value"""

    @classmethod
    @abc.abstractmethod
    def write32(cls, _handle: Any, _mem_space: MemorySpace, _addr: int, _val: int):
        """Write a 32 bit value"""

    @classmethod
    @abc.abstractmethod
    def card_scan(
        cls,
        interfaces: list[Interfaces],
        passive: bool = False,
        **kwargs: Any
    ):
        """
        The system is actively scanned for cards. The scan can be limited
        to a specific device type (Interface) by setting the interface arg
        to a list of desired device types. Note that only device types
        known by the Kit will scanned, regardless of interfaces. In other
        words, KitJTAG_AVMM will only find JTAG devices that it can handle.
        A new card list is generated and returned.

        Derived classes only need to scan and add cards that they can handle
        and let the super class trim the list by type:
            return super().device_list(interfaces)

        In general, you should just call device_list.

        Args:
            interfaces: A list of desired device types ( Interface ).
        """
