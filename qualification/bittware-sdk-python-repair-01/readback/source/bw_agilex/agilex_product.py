# Library:
#    bw_core.products.families.Agilex.IA440IProduct
#
# Desc:
#    IA440I_product.py
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
All Agilex Products
"""
import importlib.resources
from typing import Type, Union, Optional, TYPE_CHECKING
from typing_extensions import Self
from bw_core.product import BaseProduct
from bw_core.enums import BMCType, CardFamily
from bw_core.product.prom import PromDecoder, PromStyle
from .bmc_handlers import BmcHandler, Bmc30Handler

if TYPE_CHECKING:
    from bw_kit.kit_bmc_handler import KitBmcHandler


class AgilexProduct(BaseProduct):
    """
    Common product class for Agilex family

    Attributes:
        prom_decoder: PROM decoder
    """

    family = CardFamily.BW_AGILEX
    data_directory = str(importlib.resources.files("bw_agilex").joinpath("data"))
    prom = PromDecoder(PromStyle.REV1)

    @classmethod
    def bmc_handler(cls) -> Optional[Union[Type["KitBmcHandler"], Type[Self]]]:  # type: ignore
        """
        Return the correct BMC handler class depending on BMC type

        Returns:
            BMC handler class
        """
        if cls.bmc_type is BMCType.BMC30:
            return Bmc30Handler
        if cls.bmc_type is BMCType.PLDM:
            return BmcHandler
        if cls.bmc_type is BMCType.LITE:
            return cls  # This is wacky!! 220 uses "device" as the handler

        return None
