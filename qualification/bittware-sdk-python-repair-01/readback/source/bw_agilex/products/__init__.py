# Library:
#    bw_core.products.family.Agilex
#
# Desc:
#    __init__.py
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
Sub package for all product / family related code
"""
from .ia220u2_product import IA220U2Product
from .ia420f_product import IA420FProduct
from .ia440i_product import IA440IProduct
from .ia441i_product import IA441IProduct  # noqa: F401
from .ia720i_product import IA720IProduct
from .ia780i_product import IA780IProduct
from .ia840f_product import IA840FProduct, IA840FFakeProduct
from .ia860m_product import IA860MProduct
from .agidevkit_product import AGIDEVKITProduct

__all__ = [
    "IA220U2Product",
    "IA420FProduct",
    "IA440IProduct",
    "IA441IProduct",
    "IA720IProduct",
    "IA780IProduct",
    "IA840FProduct",
    "IA840FFakeProduct",
    "IA860MProduct",
    "AGIDEVKITProduct",
]
