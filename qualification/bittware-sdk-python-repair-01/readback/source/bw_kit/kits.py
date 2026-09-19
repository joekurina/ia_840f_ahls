# Library:
#    bw_kit.kits.py
#
# Desc:
#    kits.py
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
This class holds the data shared by all kits and helps break
cyclic dependencies. Kits and Devices entries import from this
class not each other.

This class only imports Kit and Device entry for type hints.
"""
import logging
import re
import os
from typing import TYPE_CHECKING, Union, Tuple, Sequence, overload, Literal, Optional, Any
from bw_core.exceptions.base import KitException
from bw_core.legacy import BraceMessage as _B
from bw_core.utils.entry_points import get_entry_points
from bw_kit.enums import Interfaces, TagAliases

if TYPE_CHECKING:
    from bw_kit.kit import Kit
    from bw_kit.device_entry import DeviceEntry


log = logging.getLogger(__name__)


def _active_kits_from_env() -> Tuple[str, ...]:
    env_kits = os.environ.get("BW_ACTIVE_KITS")
    return tuple(re.split(r"[,\s]+", env_kits)) if env_kits else tuple()


BW_ACTIVE_KITS: Tuple[str, ...] = _active_kits_from_env()
""" Determines which kits will be used. The default behavior is use all installed python kits (determined
by registered 'bittware_kits' entry points). An environment variable can be used to explicitly select what
kits will be used:

(shell)$ export BW_ACTIVE_KITS='KitVFIO KitUSB KitUART KitSYSFS'
"""

BW_PCI_TAG_ALIAS: Interfaces = Interfaces.VFIO
""" Determines which interface type is to be considered the "PCI" interfaces for device selection.
The defaults is "VFIO", device tags that begin with PCI: are aliased to VFIO (PCI:1 == VFIO:1).
Can be controlled by setting an environment variable of the same name:

(shell)$ export BW_PCI_TAG_ALIAS='BWPCI'

Will map all PCI:x devices to the Bittware PCI driver and kit
"""

try:
    if "BW_PCI_TAG_ALIAS" in os.environ:
        BW_PCI_TAG_ALIAS = Interfaces(os.environ.get("BW_PCI_TAG_ALIAS"))
except (ValueError, AttributeError):
    log.warning(
        _B(
            "Invalid value Environment variable BW_PCI_TAG_ALIAS. {iface} is not a valid interface name."
            " Using 'VFIO' instead.",
            iface=os.environ.get("BW_PCI_TAG_ALIAS"),
        )
    )


class Kits:
    """
    Holds the data used by Kits and DeviceEntries

    Attributes:
        KitClasses: Dictionary of actively used Kit classes. kits.use() determines the active kits
        KitEntryPoints: Dictionary of all available kit classes
        KitInterfaces: Dictionary of all interface types provided by active kits. Kits.use_kits() must
            be called (either implicitly or explicitly) prior to using this dictionary otherwise
            it will be empty.
        devices: List all devices found from scanning available kits
        ActiveKits: The list of kits that will be used to find devices. Can be set by Kits.use_kits
    """

    PCI_INTERFACE_ALIAS: Interfaces = BW_PCI_TAG_ALIAS
    KitClasses: dict[str, "Kit"] = {}
    KitEntryPoints: dict[str, "Kit"] = {}
    KitInterfaces: dict[str, "Kit"] = {}
    devices: Optional[list["DeviceEntry"]] = None
    ActiveKits: Tuple[str, ...] = BW_ACTIVE_KITS
    _last_scan_passive: Optional[bool] = None

    @overload
    @classmethod
    def interface_names(
        cls, all_interfaces: bool = ..., enums: Literal[False] = False, include_aliases: bool = False
    ) -> list[str]: ...

    @overload
    @classmethod
    def interface_names(
        cls, all_interfaces: bool = ..., enums: Literal[True] = ..., include_aliases: bool = False
    ) -> list[Interfaces]: ...

    @classmethod
    def interface_names(
        cls, all_interfaces: bool = False, enums: bool = False, include_aliases: bool = False
    ) -> Union[list[str], list[Interfaces]]:
        """
        By default returns a list of interface names supported by loaded kits, if
        all_interfaces is set True, additional interface names will be returned
        even if no currently loaded kit supports them.

        Args:
            all_interfaces: If True, return all interface names, not just those
                supported by the loaded kits.
            enums: If True, return a list of Interface enums, otherwise return a list of strings.

        Returns:
            A list of interface names as strings.
        """
        intf_enums: list[Interfaces] = []

        if all_interfaces:
            intf_enums = list(Interfaces)  # all interface enums
        else:
            if not cls.KitEntryPoints:
                cls._init_kit_classes()  # Load entry points and "use kits" if not already done.
            intf_enums = list(cls.KitInterfaces)  # type:ignore

        if include_aliases:
            if cls.PCI_INTERFACE_ALIAS in intf_enums and Interfaces.PCI not in intf_enums:
                intf_enums.append(Interfaces.PCI)

        if enums:
            return intf_enums

        return [enum.value for enum in intf_enums]

    @classmethod
    def init_lists(cls, card_list: list["DeviceEntry"]):
        """
        Provided primarily for unit tests but may be useful
        Sets the currently cached device lists to whatever is passed in.
        The default parameters clear the device lists

        Args:
            card_list: A list of DeviceEntry objects
        """
        Kits.devices = card_list

    @classmethod
    def _intf_list(
        cls, interfaces: Optional[Union[list[Union[Interfaces, str]], Interfaces, str]] = None
    ) -> list[Interfaces]:
        """Helper function that excepts one or more Interface enums or strings and
        always returns a list of Interface enums or an empty list.

        This method also ensures that the PCI alias interface is in the list if the
        list contains 'PCI'

        Raises:
            ValueError: if a string representation of an interface cannot be converted to an Interface enum.
        """
        if interfaces is None:
            interfaces = []
        elif not isinstance(interfaces, list):
            interfaces = [interfaces]

        iflist = {Interfaces[intf] for intf in interfaces}
        if Interfaces.PCI in iflist and cls.PCI_INTERFACE_ALIAS not in iflist:
            iflist.add(cls.PCI_INTERFACE_ALIAS)

        return list(iflist)

    @classmethod
    def _init_kit_classes(cls):
        """Load Kit entry points, clears any previously loaded entry points"""
        cls.KitEntryPoints.clear()
        loaded = []
        for entry_point in get_entry_points(group="bittware_kits"):
            # When a package is installed editable, you often get duplicated entry points.
            # use attr to check and don't load twice
            if entry_point.attr in loaded:
                continue
            try:
                entry_point.load()
                loaded.append(entry_point.attr)
            except ImportError as err:
                log.critical(err)
        cls._select_kits(cls.ActiveKits)

    @classmethod
    def _select_kits(cls, kits: Sequence[str]):
        """
        Internal, selects kit classes from kit entry points based on names in kits

        Args:
            kits: A list of kit names to load and use.
        """
        cls.KitClasses.clear()
        cls.KitInterfaces.clear()
        found = []

        # if kit list is empty, use all of them
        if not kits:
            kits = tuple(cls.KitEntryPoints.keys())

        for want in kits:
            if want and want not in cls.KitEntryPoints:
                log.error(
                    "Kit %s was not found, you may need to install the package that contains it",
                    want,
                )
                raise KitException(f"No entry point for kit {want}")

            kit_class = cls.KitEntryPoints[want]
            cls.KitClasses[want] = kit_class
            found.append(want)

            for interface in kit_class.interfaces:
                if interface in cls.KitInterfaces:
                    log.warning(
                        "Kit %s is attempting to redefine interface %s, defined by kit %s",
                        kit_class.__qualname__,  # type: ignore
                        interface,
                        cls.KitInterfaces[interface].__qualname__,  # type: ignore
                    )
                else:
                    cls.KitInterfaces[interface] = kit_class

        cls.ActiveKits = tuple(found)

    @classmethod
    def use_kits(cls, *kits: str) -> dict[str, "Kit"]:
        """
        Declare which kits an application or tool intends to use.
        Each requested kit must have a corresponding python class entrypoint.

        Args:
            *kits: var args (list) of kit names to load and use. If
                no kit names are specified, all available kit entry points
                will be loaded.

        Returns:
            A dictionary of kit classes that were loaded and are now active.
        """

        if not cls.KitEntryPoints:
            cls._init_kit_classes()  # Load entry points and "use kits" if not already done.
            if not cls.KitEntryPoints:
                log.warning(
                    "No kit entry points found while loading kits. "
                    "Possibly because of an incomplete installation. "
                    "One or more installed kit(s) are required to do anything useful."
                )
                return cls.KitClasses

        if not kits:
            kits = [
                epoint.__name__  # type: ignore
                for epoint in cls.KitEntryPoints.values()
                if epoint.CODE_STATUS == "released"
            ]

        cls._select_kits(kits)
        return cls.KitClasses

    @classmethod
    def scan_devices(
        cls,
        interfaces: Optional[Union[list[Union[Interfaces, str]], Interfaces, str]] = None,
        rescan: bool = False,
        passive: bool = False,
        **kwargs: Any,
    ) -> list["DeviceEntry"]:
        """Each kit entry point is asked to scan for card entries. The scan can be limited
        to interfaces requested or all available if None.

        In almost all cases an application will call this function once during early
        initialization. This initial card scan can occur after the application has
        determined what interfaces it is interested in working with. Generally, it is
        best to just scan for all available card devices found by the installed kits.

        In some cases it may be desireable or necessary to rescan, for instance after
        a BMC upgrade or FPGA load.

        Args:
            interfaces: bw_kit.enums.Interface - one or more specific interfaces to scan for.
                        Can be None (find all cards), a single (scaler bwk.Interface)
                        or a list [bwk.Interface]. Strings may be used instead of
                        bwk.Interface enums as long as the string value converts to a
                        valid Interface enum.

            rescan:     bool, If True the current card list (if any) is discarded and
                        a new scan will be performed by each kit. The default is False
                        causing successive calls to scan_devices to return the cached
                        card list.

            passive:    bool, defaults to False. If True, no actions that require
                        opening the card devices will be preformed.

        Returns:
            A list of DeviceEntry objects, one for each card found.
        """
        if not cls.KitEntryPoints:
            cls._init_kit_classes()  # Load entry points and "use kits" if not already done.

        # if we already scanned, check if need to force active (re)scan
        if cls.devices is not None and cls._last_scan_passive and not passive:
            rescan = True

        # make sure interfaces is a (possibly empty) list
        # also adds PCI_INTERFACE_ALIAS if list contains PCI
        scan_for = cls._intf_list(interfaces)  # type:ignore

        if cls.devices is None or rescan:
            cls.init_lists([])

            for kit_class in cls.KitClasses.values():
                kit_class.card_scan(interfaces=scan_for, passive=passive, **kwargs)

            cls._last_scan_passive = passive

        devices = [
            ent for ent in list(cls.devices) if ent.interface in scan_for  # type:ignore
        ]
        return devices

    @classmethod
    def device_list(
        cls,
        interfaces: Optional[Union[list[Union[Interfaces, str]], Interfaces, str]] = None,
        rescan: bool = False,
        passive: bool = False,
    ) -> list["DeviceEntry"]:
        """
        This method is simply an alias Kits.scan_devices
        It may be removed in the future.
        """
        return cls.scan_devices(interfaces=interfaces, rescan=rescan, passive=passive)

    @classmethod
    def get_card_entry(cls, **kwargs) -> Optional[Union[list["DeviceEntry"], "DeviceEntry"]]:
        """
        Exactly equivalent to find_entries(find_one=True, **kwargs)
        See find_entries.
        """
        return cls.find_device_entries(find_one=True, **kwargs)

    @classmethod
    def find_device_entries(  # pylint: disable=too-many-positional-arguments
        cls,
        find_first: bool = False,
        find_one: bool = False,
        interface: Optional[str] = None,
        dev_index: Optional[str] = None,
        serial_number: Optional[str] = None,
        tag: Optional[str] = None,
        kit: Optional[Union[type, str]] = None,
        device_id: Optional[str] = None,
    ) -> Optional[Union[list["DeviceEntry"], "DeviceEntry"]]:
        """
        Find all card entries that match keyword args

        Args:
            find_one:
                If True, raise an error if exactly one entry is not found.
                Default is False.
            find_first:
                If True, return the first matching entry, default is False,
                return a list of all matching entries
            interface:
                Match card list entry interface type one of Interface.
            dev_index:
                The device index as indicated by the particular Kit, typically
                just the numeric index of scanned devices on a particular
                interface.
            serial_number:
                The card's serial number (not always known by the Kit)
            tag:
                A tag (as generated by the Kit) guaranteed unique for an
                interface type and typically just the interface and device
                number as in 'PCI:3'
            kit:
                Match the Kit class that found this device can be class or
                string.
            device_id:
                The card's device_id
        Returns:
            A list of DeviceEntry objects that match the keyword args.
                - If find_one is True, exactly one entry is returned or an error is raised.
                - If find_first is True, the first matching entry is returned or None if no match.
                - If no matches are found, an empty list is returned.
        """
        # pylint: disable=too-many-arguments,too-many-branches
        # kit is a classname (string) but we accept a class or object
        if isinstance(kit, type):
            kit = kit.__name__

        # validate interface arg and force it to be an enum
        if interface:
            interface = Interfaces(interface)

        found = []
        if cls.devices:
            for entry in cls.devices:  # pylint: disable=not-an-iterable
                if interface is not None and entry.interface != interface:
                    continue
                if dev_index is not None:
                    if entry.interface is Interfaces.UART:
                        # NOTE: this is defined as an int, not a string.
                        if not entry.device.endswith(str(dev_index)):  # type: ignore
                            continue
                    elif entry.device != int(dev_index):
                        continue
                if device_id is not None and entry.dev_ids.device_id != device_id:
                    continue
                if serial_number and entry.serial_number != serial_number:
                    continue
                if tag and entry.device_tag != tag:
                    continue
                if kit and entry.kit_name != kit:
                    continue
                if find_first:
                    return entry
                found.append(entry)

        if find_one:
            if len(found) != 1:
                raise KitException(
                    f"Found {len(found)} device entries, but expected exactly one."
                )
            return found[0]

        if find_first and not found:
            return None

        return found

    @classmethod
    def device_map(
        cls,
        interfaces: Optional[Union[list[Union[Interfaces, str]], Interfaces, str]] = None,
        aliases: Optional[list[TagAliases]] = None,
        rescan: bool = False,
    ) -> dict[str, "DeviceEntry"]:
        """
        Uses all active kits to scan for devices on one or more specific interfaces.
        Can also add device tag aliases to the map, current alias support includes
        location and serial number.

        If all alias tags are requested a single card will typically produce two
        device entries (USB & PCI) and the map will contain keys for following:

            'USB:0', 'USB:8070238', 'USB:1-7.1'     All to the same USB device entry
            'PCI:0', 'PCI:8070238', 'PCI:65:00.0'   All to the same PCI device entry

        Note that if interface PCI and aliases SERIAL_NUMBER are requested, then the
        scan will be "active", in other words, it will attempt to access the BMC via
        PCI in order to retrieve the card serial number. If BMC via PCI is not supported
        either due to the bitstream or FPGA configuration state, no serial number
        based tag will be added and any errors attempting to read the serial number
        via PCI will be silently ignored.

        Args:
            interfaces: An Interface enum or list of Interface enums. Only device
                on the specified interfaces will be returned. The default is None
                in which case all interfaces supported by the loaded kits will be
                scanned.
            aliases: A list of one or more TagAliases to be added to the device map.
                Current tag aliases are:

                - `NATIVE` (the default tag from a kit)
                - `SERIAL_NUMBER`
                - `LOCATION`

                The default is None, in which case only the NATIVE kit tags are used
                (no aliases). If alias tags are specified, you must explicitly request
                NATIVE tags if you want them. This allows for requesting just LOCATION
                or SERIAL_NUMBER tags (and not using PCI:1 native tags for instance)

                The list 'all_tags' is provided by this module for convenience.

                ???+ example
                    ```py
                    bwk.device_map(aliases=all_tags)
                    ```

                is typically all that's needed.
            rescan: Boolean, default is False. Can be used in the rare case that
                a second scan is required because devices may have changed.

        Returns:
            A dictionary of device tags to DeviceEntry objects
        """
        if not aliases:
            aliases = [TagAliases.NATIVE]

        # check for PCI and serial number tags
        # Have to actively access PCI for serial number
        passive = True

        # make a set of the interfaces we will scan
        intf_list = cls._intf_list(interfaces)
        intf_set = (
            set(intf_list)
            if intf_list
            else set(
                cls.interface_names(all_interfaces=True, enums=True)
            )  # type:ignore
        )

        # if we want serial number tags, check for interfaces that require active scans
        if TagAliases.SERIAL_NUMBER in aliases and set(
            [Interfaces.PCI, Interfaces.BWPCI, Interfaces.VFIO, Interfaces.SYSFS]
        ).intersection(intf_set):
            passive = False

        dev_map: dict[str, "DeviceEntry"] = {
            dev.device_tag: dev
            for dev in cls.scan_devices(
                interfaces=intf_list, rescan=rescan, passive=passive  # type:ignore
            )
            if dev.device_tag
        }

        alias_map = {}

        def add_alias(tag: str, device: "DeviceEntry"):
            # if the kit puts shell meta characters in the tag they are converted to '.'
            tag = re.sub(r"[\|&;\(\)<>]", ".", tag)
            if tag not in alias_map:
                alias_map[tag] = device
                if device.interface == cls.PCI_INTERFACE_ALIAS:
                    tag = device.interface.value + ":" + tag.split(":", 1)[1]
                    alias_map[tag] = device
                return
            log.warning(
                "Failed to add device tag alias '%s' to device map, tag already exists",
                tag,
            )

        for tag, device in dev_map.items():
            if TagAliases.NATIVE in aliases:
                add_alias(tag, device)

            if TagAliases.SERIAL_NUMBER in aliases and device.serial_number:
                tag = (
                    f"{device.interface.value}:{str(device.serial_number).upper()}"  # type: ignore
                )
                add_alias(tag, device)

            if (
                TagAliases.LOCATION in aliases
                and device.extra_props.get("location") is not None
            ):
                if device.interface in [Interfaces.VFIO, Interfaces.PCI, Interfaces.SYSFS]:
                    location = str(device.extra_props["location"].split(":", 1)[1])
                else:
                    location = str(device.extra_props["location"])
                tag = (
                    str(device.interface.value)  # type:ignore
                    + ":"
                    + location
                )
                add_alias(tag, device)

        return alias_map
