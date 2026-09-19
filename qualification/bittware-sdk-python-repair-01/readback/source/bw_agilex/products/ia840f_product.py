# Library:
#    bw_core.products.families.Agilex.IA840FProduct
#
# Desc:
#    IA840F_product.py
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
IA 840 F Product
"""
import os
from typing import Dict
from random import randrange
from bw_core.enums import BMCType
from bw_core.data_types import VendorDeviceInfo
from bw_core.card_ids import BITTWARE_PCIE_VID, BT_IA_840F, FAKE_SDK_SSDID, ProductNames
from ..agilex_product import AgilexProduct


class IA840FProduct(AgilexProduct):
    """
    IA 840F Product class

    Attributes:
        name: name of the card
        vendor_info: contains vendor_id and device_id
        fpga_desc_path: path to the fpga description file
        card_desc_path: path to the card description file
        bmc_type: type of BMC on the card
    """

    name = ProductNames.IA_840F
    vendor_info = VendorDeviceInfo(vendor_id=BITTWARE_PCIE_VID, device_id=BT_IA_840F)
    data_directory = os.path.join(AgilexProduct.data_directory, "IA-840F")
    fpga_desc_path = os.path.join(data_directory, "ia-840f_cardtest.json")
    card_desc_path = os.path.join(data_directory, "IA-840F.yml")
    clock_files = os.path.join(data_directory, "clocks")
    bmc_type = BMCType.PLDM


class IA840FFakeProduct(IA840FProduct):
    """
    IA 840F Product class when subsystem device ID is faked (test and simulated)

    Attributes:
        vendor_info: contains vendor_id and device_id
        bmc_type: type of BMC on the card
    """

    name = ProductNames.IA_840F_QEMU
    vendor_info = VendorDeviceInfo(
        vendor_id=BITTWARE_PCIE_VID, device_id=BT_IA_840F, ss_vendor_id=BITTWARE_PCIE_VID, ss_device_id=FAKE_SDK_SSDID
    )
    bmc_type: BMCType = BMCType.NONE

    @classmethod
    def alt_mfg_info(cls, dev_ids: VendorDeviceInfo = VendorDeviceInfo(0, 0, None, None)) -> Dict[str, str]:
        """
        Return MFG info with random serial number

        Note:
            This method should only be called for mocking out alt info

        Arguments:
            dev_ids: A stubbed out vendor device id to mock

        Returns:
            A mocked out dictionary of manufacturing info
        """
        _vid, _did, _ss_vid, _ss_did = dev_ids
        return {
            "Model": "IA-840F",
            "PartNumber": "IA-840F-S-B272E2V-44R4R4-S0-X322-220E-9",
            "SerialNumber": f"{randrange(1, 999999):#06d}",  # nosec
            "Version": "0.0.0.0.0",
        }
