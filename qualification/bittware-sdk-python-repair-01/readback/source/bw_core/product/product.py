# Library:
#    bw_core.products.product
#
# Desc:
#    product.py
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
"""
Base Product Class

Each supported product has a class derived from this class in the correct
family subdirectory. Product classes are "singleton" (but not enforced) only
the class is used instances are not intended to be created.

These classes auto-register when loaded into a directory held here.

Product classes will only contain STATIC ie. unchanging data that can
be different for each specific product.

Additional methods that works with the static data are provided in the base class.

Attributes:
    SDK3_ROOT: path to the SDK3 root directory
    log: logger for this module
"""

import os
import logging
from typing import Dict, Union, Optional
from typing_extensions import Type, Self
import yaml  # type: ignore
from bw_bmc_abs import BaseBmc, BmcBaseHandler
from ..decorators import classproperty
from .prom import PromDecoder
from ..enums import BMCType, CardFamily
from ..card_ids import BITTWARE_PCIE_VID, FAKE_SDK_SSDID, ProductNames
from ..data_types import VendorDeviceInfo
from ..data_types.card_desc_model import CardDescriptionModel, CardConfigurationModel
from ..utils.entry_points import get_entry_points

SDK3_ROOT: Optional[str] = os.environ.get("BWSDK_ROOT")
log: logging.Logger = logging.getLogger(__name__)


class BaseProduct:
    """
    Base class for all product classes.
    Product classes are intended to never be instantiated, all attributes and code apply
    in all cases to the specific product a derived product class is defined for.

    A specific derived product class is the final word / source for product information
    and details. I.E. what BMC does this product use?

    Attributes:
        _PRODUCTS_BY_NAME: dict of product classes by name
        _PRODUCTS_BY_VID_DID: dict of product classes by vendor and device IDs
        _PRODUCT_ENTRY_POINTS_LOADED: bool flag to indicate that product entry points have been loaded
        family: enum CardFamily
        name: enum ProductNames
        vendor_info: VendorDeviceInfo vendor and device IDs
        fpga_desc_path: str path to the FPGA description file
        card_desc_path: str path to the card description file
        data_directory: str path to data directory for the derived product class.

            Each product family typically has a family level class and each final product
            class sets the data directory by appending the ProductNames enum value to the
            family class data_directory:
            ```
            data_directory = os.path.join(
                agilexProduct.data_directory,
                "IA-440I"
            )
            ```
        bmc_type: BMCType type of BMC used by this product
        prom: PROM decoder/encoder
        _bmc_libs: dict of BMC classes by BMCType


    Raises:
        ValueError: when derived class definition attempts to assign an invalid family or name
    """

    _PRODUCTS_BY_NAME: Dict[str, Type[Self]] = {}
    _PRODUCTS_BY_VID_DID: Dict[VendorDeviceInfo, Type[Self]] = {}
    _PRODUCT_ENTRY_POINTS_LOADED: bool = False

    # !!!!! It would be desireable to make this go away and not use entry points for BMC classes
    # !!!!! We have exactly 2 BMC classes one for BMC and another for BMC Lite
    _bmc_libs: Dict[str, BaseBmc] = {}  # dictionary that maps BMCType to a BMC class

    name: ProductNames  # must be set in final derived classes
    family: CardFamily  # must be set in derived class from CardFamily.X.value
    vendor_info = VendorDeviceInfo(vendor_id=0, device_id=0)
    # For all "real" products, subsystem IDs will be None (can be Anything)
    # However we have a few cases where we use the SS ids for "Fake" products
    # when testing code with out an actual card or the 220 with BMC lite
    fpga_desc_path: str = ""  # these three must be set by derived classes
    card_desc_path: str = ""
    data_directory: str = ""
    clock_files: str = "<no clock files>"  # not required, so seed with "none"
    prom: PromDecoder

    # NOTE: we need Card class or Methods that work with a product class & device entry
    # to handle the odd case of ss_device_id == card_id.FAKE_SDK_SSID
    bmc_type: BMCType = BMCType.NONE

    @classmethod
    def by_name(cls, name: Union[str, ProductNames]) -> Optional[Type["BaseProduct"]]:
        """
        get a product by name

        ???+ example
            ```py
            product = BaseProduct.by_name("IA-220-U2")
            ```

        Args:
            name: str product name or ProductName enumeration

        Returns:
            A product class or None

        Raises:
            ValueError: if name(str) is not a valid ProductName enum
        """
        if not cls._PRODUCT_ENTRY_POINTS_LOADED:
            cls._load_product_entry_points()

        name = ProductNames(name)  # make sure name is a product enumeration
        return cls._PRODUCTS_BY_NAME.get(name)

    @classmethod
    def look_up(cls, ids: VendorDeviceInfo) -> Optional[Type["BaseProduct"]]:
        """
        Look for product using full IDs (including subsystem) first.
        Then try without subsystem (use None for IDs).
        Return None if neither match

        ???+ example
            ```py
            product = BaseProduct.lookup(VendorDeviceInfo(vendor_id, device_id))
            ```

        Args:
            ids: VendorDeviceInfo vendor and device IDs

        Returns:
            A product class or None
        """
        if not cls._PRODUCT_ENTRY_POINTS_LOADED:
            cls._load_product_entry_points()

        return cls._PRODUCTS_BY_VID_DID.get(
            ids,
            cls._PRODUCTS_BY_VID_DID.get(
                VendorDeviceInfo(vendor_id=ids.vendor_id, device_id=ids.device_id), None
            ),
        )

    def __init_subclass__(cls, **_kwargs):
        # register any final classes - only final classes will have a product name
        try:
            # only register class if both family and name attributes have been set
            # and are correct strings or enums
            cls.name = ProductNames(cls.name)
            cls.family = CardFamily(cls.family)
            cls._PRODUCTS_BY_NAME[cls.name] = cls
            cls._PRODUCTS_BY_VID_DID[cls.vendor_info] = cls
        except AttributeError:
            # class was a partial class (not final) do not register it
            pass

    @classproperty
    def str_name(self) -> str:
        """Product name as string"""
        try:
            return self.name.value
        except AttributeError:
            return ""

    @classproperty
    def str_family(self) -> str:
        """Product family as string"""
        try:
            return self.family.value
        except AttributeError:
            return ""

    @classproperty
    def all_products(self) -> Dict[str, Type[Self]]:
        """Provide public access to the private attribute _PRODUCTS_BY_NAME"""
        return self._PRODUCTS_BY_NAME

    @classmethod
    def _load_product_entry_points(cls, name: str = ""):
        """
        Loads all bittware_products entry points. Product classes
        auto register when loaded. This happens once on the first
        attempt to lookup a product.

        Args:
            group: The entry point to load (e.g. "agilex_products")
        """
        if cls._PRODUCT_ENTRY_POINTS_LOADED:
            return

        if name:
            entry_point = get_entry_points(name=name, group="bittware_products")
            entry_points = [entry_point] if entry_point else []
        else:
            entry_points = get_entry_points(group="bittware_products")

        for entry_point in entry_points:
            try:
                entry_point.load()
            except ImportError as err:
                log.critical(err)

        cls._PRODUCT_ENTRY_POINTS_LOADED = True

    @classmethod
    def alt_mfg_info(cls) -> Union[Dict[str, str], None]:
        """
        Returns MFG info for cards that do not have a BMC. For now this just the
        virtual cards and potentially another IA-220-U2 at some point. Ultimately
        there will be some sort of BMC-lite that stands in for BMC lib to be used
        with cards that don't have a full blown SDK BMC etc.

        Returns:
            a mocked dictionary of MFG info or None
        """
        return {"Model": cls.name.value}

    @classmethod
    def bmc_type_from_dev_ids(
        cls, dev_ids: Optional[VendorDeviceInfo] = None
    ) -> BMCType:
        """
        returns the BMC type after checking the subsystem vendor and device IDs.
        Any given product supports exactly on type of BMC. However we do occasionally
        for testing or development purposes FAKE_SDK_SSID to indicated that this is
        not an actual device. Hence this unfortunate method is needed.

        Args:
            dev_ids: VendorDeviceInfo vendor and device IDs or None

        Returns:
            BMCType type of BMC used by this product
        """

        if dev_ids is not None:
            _vid, _did, ss_vid, ss_did = dev_ids

            if (
                ss_vid is not None
                and ss_vid == BITTWARE_PCIE_VID
                and ss_did is not None
                and ss_did == FAKE_SDK_SSDID
            ):
                return BMCType.NONE

        return cls.bmc_type

    @classmethod
    def bmc_handler(cls) -> Type[BmcBaseHandler]:
        """
        Get the BMC handler class for this product.
        Typically the family level product class implements this.

        Returns:
            the BMC handler handler for a product
        """
        return BmcBaseHandler

    @classmethod
    def bmc_class(cls) -> Type[BaseBmc]:
        """
        Get the BMC class for this product. Really only determines BMC vs. BMC lite

        Returns:
            the BMC class for a product
        """
        if not cls._bmc_libs:
            for entry_point in get_entry_points(group="bittware_bmc"):
                try:
                    bmc_cls = entry_point.load()
                    cls._bmc_libs[bmc_cls.bmc_type()] = bmc_cls
                except ImportError as err:
                    logging.critical(err)

            # This is broke - confusion over type (BMC, BMC3, BMC lite) and transport (PLDM)
            if BMCType.PLDM in cls._bmc_libs:
                cls._bmc_libs[BMCType.BMC30] = cls._bmc_libs[BMCType.PLDM]

        return cls._bmc_libs.get(cls.bmc_type, None)  # type: ignore

    @classmethod
    def _load_card_desc(cls, path: str) -> CardDescriptionModel:
        """Read and parse the card description yam file

        Args:
            path: str path to an card description file (YAML)

        Returns:
            FPGADescriptionModel

        Raises:
            yaml.YAMLError: if the file is not valid YAML
            pydantic.ValidationError: if the YAML does not match the CardDescriptionModel
            pydantic.ParserError: if the YAML does not match the CardDescriptionModel
        """
        with open(path, "r", encoding="utf-8") as stream:
            card_desc = yaml.safe_load(stream)
        return CardDescriptionModel(**card_desc)

    @classmethod
    def get_card_desc(
        cls, revision: str = ""
    ) -> Optional[CardConfigurationModel]:
        """
        Most card description models will have at least one revision match that
        matches "any" and returns the latest? This may need future tweaking.

        !!! warning
            This method is deprecated! Use `CardDescriptionModel.configuration_for_card` instead.

        !!! note
            legacy use of:
            ```py
                CardConfigurationModel.get_card_desc(vendor_id, device_id, revision)
            ```

            is exactly equivalent to:
            ```py
                BaseProduct.lookup(
                    VendorDeviceInfo(vendor_id, device_id)
                    ).get_card_desc(revision)
            ```

        Args:
            revision: str card revision

        Returns:
            the card description info for a product or None
        """
        if not cls.card_desc_path or not os.path.exists(cls.card_desc_path):
            return None

        card_desc_data = cls._load_card_desc(cls.card_desc_path)
        return card_desc_data.configuration_for_card(revision)

    @classmethod
    def test_plans(cls) -> list[str]:
        """ Returns a list of path names for all test plans provided for the product """
        plan_dir = os.path.join(cls.data_directory, "test_plans")
        with os.scandir(plan_dir) as scan:
            return [entry.path for entry in scan]

    @classmethod
    def dump(cls, as_json: bool = False) -> dict[str, str]:
        """Returns most of the interesting attributes of the product as a dictionary of strings.
        Used exclusively for listing product object information, but might be useful elsewhere.

        Arguments:
            as_json: bool, default is False. in the future may optionally return json
        """
        _ = as_json  # future use maybe.
        data: dict[str, str] = {}
        data["name"] = cls.str_name
        data["family"] = cls.str_family
        data["vendor_info"] = cls.vendor_info  # type: ignore
        data["fpga_desc_path"] = cls.fpga_desc_path
        data["card_desc_path"] = cls.card_desc_path
        data["data_directory"] = cls.data_directory
        data["clock_files"] = cls.clock_files
        data["bmc_type"] = cls.bmc_type
        return data
