"""Minimal unit registry (subset of Units.m).

Every quantity kind maps display-unit name -> factor such that
``value_SI = value_display * factor``. The full Units.m unit-system dialog
(metric / oilfield presets) will be ported on top of this table.
"""
from __future__ import annotations

_PSI = 6894.757293168
_FT = 0.3048
_IN = 0.0254
_BBL = 0.158987294928  # US oil barrel [m^3]

UNITS: dict[str, dict[str, float]] = {
    "pressure": {"Pa": 1.0, "kPa": 1e3, "MPa": 1e6, "GPa": 1e9, "psi": _PSI, "bar": 1e5},
    "length": {"m": 1.0, "cm": 1e-2, "mm": 1e-3, "km": 1e3, "ft": _FT, "in": _IN},
    "aperture": {"m": 1.0, "cm": 1e-2, "mm": 1e-3, "um": 1e-6, "in": _IN},
    "rate": {"m3/s": 1.0, "m3/min": 1 / 60, "m3/h": 1 / 3600, "L/min": 1e-3 / 60,
             "L/s": 1e-3, "bbl/min": _BBL / 60},
    "viscosity": {"Pa.s": 1.0, "mPa.s": 1e-3, "cP": 1e-3},
    "leakoff": {"m/sqrt(s)": 1.0, "m/sqrt(min)": 1 / 60**0.5, "ft/sqrt(min)": _FT / 60**0.5},
    "time": {"s": 1.0, "min": 60.0, "h": 3600.0, "day": 86400.0},
    "volume": {"m3": 1.0, "L": 1e-3, "bbl": _BBL, "ft3": _FT**3},
    "fraction": {"fraction": 1.0},
}

# Default display units for the GUI (matching the toolbox "metric" preset)
DEFAULT = {
    "pressure": "MPa", "modulus": "GPa", "length": "m", "aperture": "mm",
    "rate": "m3/min", "viscosity": "cP", "leakoff": "m/sqrt(min)",
    "time": "min", "volume": "m3",
}


def factor(kind: str, unit: str) -> float:
    kind = "pressure" if kind == "modulus" else kind
    try:
        return UNITS[kind][unit]
    except KeyError as e:
        raise KeyError(f"unknown unit {unit!r} for {kind}") from e


def to_si(value: float, kind: str, unit: str) -> float:
    return value * factor(kind, unit)


def from_si(value, kind: str, unit: str):
    return value / factor(kind, unit)


def choices(kind: str) -> list[str]:
    kind = "pressure" if kind == "modulus" else kind
    return list(UNITS[kind])
