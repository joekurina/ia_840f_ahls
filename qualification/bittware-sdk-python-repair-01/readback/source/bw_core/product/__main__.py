# Library:
#    bw_core.products
#
# Desc:
#    __main__.py
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
# Copyright © 2024, BittWare, a Molex Company.
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
""" Provides command line product info interrogation"""

import argparse
import re
import sys
import types
from enum import Enum
from bw_core.utils.common_argparse import add_common_arguments
from bw_core.product import BaseProduct as Product

Product._load_product_entry_points()  # pylint: disable=protected-access
lazy_index: dict[str, Product] = {}

ALLOWED_ATTRS = [
    # Product attributes that can be queried directly. The ones that make no sense
    # are commented out.
    # 'all_products',
    'alt_mfg_info',
    'bmc_class',
    'bmc_handler',
    'bmc_type',
    # 'bmc_type_from_dev_ids',
    # 'by_name',
    'card_desc_path',
    'clock_files',
    'data_directory',
    'dump',
    'family',
    'fpga_desc_path',
    # 'get_card_desc',
    # 'look_up',
    'name',
    'prom',
    'str_family',
    'str_name',
    'test_plans',
    'vendor_info',
]

ALLOWED_ATTRS_LIST = "\n".join(ALLOWED_ATTRS)


def lazy(name: str) -> str:
    """normalizes potential product name strings"""
    return re.sub(r"[_-]", "", name.upper())


_index = Product.all_products
for pname, _prod in _index.items():  # pylint: disable=no-member
    lazy_name = lazy(pname)
    lazy_index[lazy_name] = _prod


def resolve_product_name(name) -> Product:
    """Look for a close match of a product name string in the known product classes

    The target name is uppercase'd and striped of '_' and '-'. The result is compared
    to known product names looking for 'startswith' the first match is returned.

    Example: searching for ia440 will match IA-440I

    Arguments:
        name: str, the target product name.

    Raises:
        KeyError if no match is found.

    """
    lname = lazy(name)
    for lindex, prod in lazy_index.items():
        if lindex.startswith(lname):
            return prod

    raise KeyError(f"no matching product found for {name}")


def command_descriptions():
    """
    query and display information about installed products
    """
    return """
    Tool for finding info for installed products.

Typical use:
    $ python -m bw_core.product -d
        < Dump long form product info for all products >

    $ python -m bw_core.product -l ia440
    IA-440I          /home/dbelser/SDK3/REPOS/Product_Families/agilex/bw_agilex/data/IA-440I

    $ python -m bw_core.product ia440 alt_mfg_info
    alt_mfg_info:{'Model': 'IA-440I'}

"""


def setup_parser():
    """Create arg parser, including common command line options"""
    parser = argparse.ArgumentParser(
        description="Product Utility\n",
        formatter_class=argparse.RawTextHelpFormatter,
        epilog=command_descriptions(),
    )

    parser.add_argument(
        "product_name",
        help="A string that selects the target product. This string is lazy\n"
        "matched (case ignored) to known product names. The default value is 'ALL'\n"
        "which lists all known products.\n\n"
        "The product name may be followed by one or more attribute names, in\n"
        "which case the specified product attributes are listed."
        "Valid attribute names are:\n\n"
        + ALLOWED_ATTRS_LIST,
        nargs="*",
        type=str,
        default=["ALL"],
    )

    parser.add_argument(
        "-l",
        "--list",
        default=False,
        action="store_true",
        help="List product(S), short form\n\n",
    )

    parser.add_argument(
        "-d",
        "--dump",
        default=False,
        action="store_true",
        help="List product(s) long form (dump)\n\n",
    )

    add_common_arguments(parser)
    return parser


def cmd_list(args):
    """Utility function for listing products"""

    def display(prod):
        data = prod.dump()
        if args.dump:
            print()
            for attr, value in data.items():
                print(f"    {attr:>16} : {value}")
        else:
            print(f"{data['name']:16} {data['data_directory']}")

    if args.product_name[0] == "ALL":
        index = Product.all_products
        for prod in index.values():  # pylint: disable=no-member
            display(prod)
    else:
        prod = Product.by_name(args.product_name[0])
        display(prod)


def cmd_attributes(args):
    """Display various attributes for selected product"""
    if args.product_name[0] == "ALL":
        print("No product name was specified")
        sys.exit(-1)

    prod = Product.by_name(args.product_name[0])

    for attr_name in args.product_name[1:]:
        if attr_name not in ALLOWED_ATTRS:
            print(f"{attr_name}: <unknown attribute>")
            sys.exit(-1)

        if (attr := getattr(prod, attr_name, None)):
            if isinstance(attr, Enum):
                print(f"{attr_name}:{attr.value}")
            elif type(attr) is types.MethodType:  # pylint: disable=unidiomatic-typecheck
                print(f"{attr_name}:{attr()}")
            else:
                print(f"{attr_name}:{attr}")


def main():
    """Utility main"""
    parser = setup_parser()
    args = parser.parse_args()

    try:
        if args.product_name[0] != "ALL":
            if prod := resolve_product_name(args.product_name[0]):
                args.product_name[0] = prod.name.value
            else:
                print(f"No product match for product name {args.product_name}")

        show_attrs = len(args.product_name) > 1

        if args.list or args.dump or not show_attrs:
            cmd_list(args)
        elif show_attrs:
            cmd_attributes(args)
        else:
            parser.print_help()
    except KeyError as exc:
        print(exc)
        sys.exit(-1)


if __name__ == "__main__":
    main()
