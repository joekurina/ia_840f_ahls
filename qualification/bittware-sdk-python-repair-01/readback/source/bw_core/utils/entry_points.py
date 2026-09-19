"""utils for managing bittware entry points"""

import sys
from functools import lru_cache
from typing import Literal, Optional, Union, overload
import importlib.metadata
from importlib.metadata import EntryPoint

BittwareEntryPoints = Literal[
    "bittware_products",
    "bittware_flash",
    "bittware_sdk",
    "bittware_tests",
    "bittware_cmdk_components",
    "bittware_components",
    "bittware_bmc",
    "bittware_kits",
]


@overload
def get_entry_points(group: BittwareEntryPoints, name: Literal[None] = None) -> list[EntryPoint]:
    ...


@overload
def get_entry_points(
    group: BittwareEntryPoints, name: str
) -> Optional[EntryPoint]: ...


@lru_cache(maxsize=10)
def get_entry_points(
    group: BittwareEntryPoints, name: Optional[str] = None
) -> Union[list[EntryPoint], Optional[EntryPoint]]:
    """
    Get the entry points for a given group.

    Args:
        group: The entry point group to search for.
        name: The name of the entry point to search for (optional).

    Returns:
        A list of entry points for the specified group, or a single entry point if a name is provided.
        If no entry points are found, returns an empty list for group queries, or None for name queries.

    Raises:
        TypeError: If group is not a string or not a valid BittwareEntryPoints value.
    """
    # Explicit runtime type checking for group parameter
    if not isinstance(group, str):
        raise TypeError(f"Expected group to be a string, got {type(group).__name__}")

    if sys.version_info >= (3, 10):
        # Python 3.10+ implementation
        if name:
            if eps := importlib.metadata.entry_points(group=group, name=name):
                return list(eps)
            return None

        return list(importlib.metadata.entry_points(group=group))

    # Python <3.10 implementation
    eps = importlib.metadata.entry_points()
    entry_points = eps[group]

    if name:
        for entry_point in entry_points:
            if entry_point.name == name:
                return entry_point
        return None

    return entry_points
