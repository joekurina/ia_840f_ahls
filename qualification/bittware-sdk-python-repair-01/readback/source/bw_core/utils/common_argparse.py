#  Provided by
#  -----------
#      BittWare, a Molex Company.
#      45 South Main St. Suite L100
#      Concord, NH 03301
#      Ph:     (603) 226 0404
#      WWW:    https://www.bittware.com
#      Email:  support@bittware.com
#
# Copyright (C) 2022, BittWare, a Molex Company.
#
# License:
#  This source code is provided to you (the Licensee) under
#  license by BittWare, a Molex Company. To view or use this
#  source code, the Licensee must accept a Software License
#  Agreement (viewable at developer.bittware.com), which is
#  commonly provided as a click-through license agreement. The
#  terms of the Software License Agreement govern all use and
#  distribution of this file unless an alternative superseding
#  license has been executed with BittWare. This source code
#  and its derivatives may not be distributed to third parties
#  in source code form. Software including or derived from this
#  source code, including derivative works thereof created by
#  Licensee, may be distributed to third parties with BITTWARE
#  hardware only and in executable form only.
#
#  The click-thorough license is available here:
#  https://developer.bittware.com/software_license.txt
"""
common argparse

!!! warning
    This module will be deprecated in the future.
"""
# pylint: disable=duplicate-code
import sys
import logging
from argparse import ArgumentParser, Action, SUPPRESS
from typing import Sequence, Optional
import bw_kit as bwk
from . import bwsdk_version


class _VersionAction(Action):
    """Print the SDK version, respecting --json / -j for output format.

    argparse's built-in version action exits inside parse_args() before the
    utility's post-parse code runs — so a bare `--version --json` ignores
    the JSON request. This action scans sys.argv for --json/-j (the argparse
    namespace isn't reliable here: actions fire in argv order, so
    `--version --json` would see namespace.json still False) and emits either
    a UtilityJSONData envelope or the plain banner before exit(0).
    """

    def __init__(self, option_strings, dest, **kwargs):
        super().__init__(
            option_strings=option_strings,
            dest=SUPPRESS,
            default=SUPPRESS,
            nargs=0,
            **kwargs,
        )

    def __call__(self, parser, namespace, values, option_string=None):
        version = bwsdk_version()
        wants_json = any(tok in ("--json", "-j") for tok in sys.argv[1:])
        if wants_json:
            # Local import avoids a circular import at module load
            from .utils_json import UtilityJSONData  # pylint: disable=import-outside-toplevel
            UtilityJSONData.from_data(parser.prog, {"bwsdk_version": version}).print()
        else:
            parser._print_message(  # pylint: disable=protected-access
                f"BittWare SDK Version {version}\n", sys.stdout
            )
        parser.exit(0)


class BwArgParser(ArgumentParser):
    """ Modified ArgumentParser that prints help on any invalid argument """
    def error(self, message):
        sys.stderr.write(f'{self.prog} error: %s\n' % message)
        self.print_help()
        sys.exit(2)


def add_common_arguments(argument_parser: ArgumentParser, exclude: Optional[list[str]] = None):
    """add common arguments to argparse

    > --version    prints bwsdk version
    > --loglevel   sets logging level

    Optional argument exclude is a list of option names that should not be added. Note
    that this is rarely needed.

    Args:
        argument_parser: argparse.ArgumentParser
        exclude: list of option names to exclude
    """
    if not exclude:
        exclude = []

    if 'version' not in exclude:
        argument_parser.add_argument("--version", action=_VersionAction)

    class SetLogLevel(Action):  # pylint: disable=too-few-public-methods
        """Configures the basic logging to specified log level"""

        def __call__(self, parser, namespace, values, option_string=None):
            if values:
                logging.basicConfig(
                    level=values,  # type: ignore
                    format="%(asctime)s.%(msecs)03d000 %(levelname)-9s %(message)s",
                    datefmt="%Y-%m-%dT%H:%M:%S",  # ISO8601
                )

    if 'loglevel' not in exclude:
        argument_parser.add_argument(
            "-L",
            "--loglevel",
            choices=["INFO", "DEBUG"],
            help="Log level to log (INFO, DEBUG) defaults to None",
            default=None,
            action=SetLogLevel
        )


def add_device_tag_select(
    parser: ArgumentParser, default_interface: str = "PCI", allowed_interfaces: Optional[Sequence[str]] = None
) -> list[str]:
    """
    common options for selecting a device

    Args:
        parser: argpase parser
        default_interface: default interface
        allowed_interfaces: list of allowed interfaces

    Returns:
        list of allowed interfaces
    """
    avail_intf = bwk.Kits.interface_names()

    # PCI is now an alias, if we have the kit it aliases to, add PCI
    if bwk.Kits.PCI_INTERFACE_ALIAS.value in avail_intf:
        avail_intf.append("PCI")  # type:ignore

    if not allowed_interfaces:
        allowed_interfaces = ["PCI", "USB", "UART", "VFIO", "SYSFS"]

    interfaces = [intf for intf in allowed_interfaces if intf in avail_intf]
    interface_str = ", ".join(interfaces)

    class UpdateDevice(Action):  # pylint: disable=too-few-public-methods
        """arg parse namespace update action that allows --interface and --card to work
        with shared --device"""
        def __call__(self, parser, namespace, values, option_string=None):
            if self.dest == 'interface':
                namespace.device.interface = values

            if self.dest == 'card':
                namespace.device.index = values

    class CheckInterface(Action):  # pylint: disable=too-few-public-methods
        """Additionally checks the interface of the device tag"""
        def __call__(self, parser, namespace, values, option_string=None):
            if values.interface not in allowed_interfaces:  # type: ignore
                parser.error(f"Device tag interface {values} not valid, choose from {','.join(allowed_interfaces)}")
            else:
                namespace.device = values

    parser.add_argument(
        "-i",
        "--interface",
        choices=interfaces,
        type=str.upper,
        dest="interface",
        default=default_interface,
        help=f"Interface choice: {interface_str} depending on card and available interfaces",
        action=UpdateDevice
    )

    # put device tag and card (index) in an exclusive group it display an error if the user tries to use both.
    tag_or_idx = parser.add_mutually_exclusive_group()

    tag_or_idx.add_argument(
        "-c",
        "--card",
        help="Number of the card (default: %(default)d). Note that this does not work for UART devices",
        type=int,
        default=0,
        action=UpdateDevice
    )

    # Display device_tags examples based on allowed interfaces
    dev_tag_options = ["PCI:0", "PCI:01:00.0", "PCI:1234567", "USB:0", "USB:1-6.4", "UART:USB3"]
    valid_dev_tags = [tag for tag in dev_tag_options if tag.split(":", maxsplit=1)[0] in allowed_interfaces]
    tag_or_idx.add_argument(
        "-d",
        "--device",
        dest="device",
        default=bwk.DeviceTag(default_interface, "0"),
        help=f"Device (device_tag), examples: {', '.join(valid_dev_tags)}",
        type=bwk.DeviceTag,
        action=CheckInterface
    )

    return interfaces
