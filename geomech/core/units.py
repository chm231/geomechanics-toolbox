"""Unit registry and unit sets - port of Units.m / Units.fig.

Every quantity kind maps unit name -> factor such that value_SI = value * factor
(the MATLAB '...IUFactor'); output factors are the reciprocals (the MATLAB
'...OUFactor' constants agree with 1/factor to their 9 significant digits).

The unit names and their ORDER are those of the MATLAB popup menus, because the
unit-set files (src/HFsim_units/*.txt) store 1-based indices into those menus.

Note: the toolbox's "bbl" is the US liquid barrel (31.5 US gal = 0.11924 m^3),
not the 42-gal oil barrel; it is kept as in the original.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

_FT, _IN, _YD = 0.3048, 0.0254, 0.9144
_UKGAL, _USGAL, _BBL, _FT3 = 4.54609188e-3, 3.78541178e-3, 0.11924071, 2.83168466e-2
_PSI = 6894.76
_PSF = 47.8802590   # Units.m uses 4.78802590 for the INPUT factor (10x too small); its output factor 2.0885e-2 is right

_LENGTH = {"cm": 0.01, "ft": _FT, "in.": _IN, "km": 1000.0, "m": 1.0, "yd": _YD}
_PRESSURE = {"10^6 psi": _PSI * 1e6, "1000 psi": _PSI * 1e3, "atm": 101325.0, "bar": 1e5, "kg/cm^2": 9.80665e4,
             "kPa": 1e3, "lbf/ft^2": _PSF, "MPa": 1e6, "Pa": 1.0, "psi": _PSI}

UNITS: dict[str, dict[str, float]] = {
    "volume": {"1000 U.K.gal": _UKGAL * 1e3, "1000 U.S.gal": _USGAL * 1e3, "bbl": _BBL, "ft^3": _FT3, "L": 1e-3,
               "m^3": 1.0, "U.K.gal": _UKGAL, "U.S.gal": _USGAL},
    "length": dict(_LENGTH),
    "aperture": {"cm": 0.01, "ft": _FT, "in.": _IN, "mm": 1e-3},
    "height": dict(_LENGTH),
    "rate": {"10 U.S.gpm": 10 * _USGAL / 60, "bbl/day": _BBL / 86400, "bpm": _BBL / 60, "ft^3/day": _FT3 / 86400,
             "ft^3/min": _FT3 / 60, "L/min": 1e-3 / 60, "m^3/day": 1 / 86400, "m^3/min": 1 / 60,
             "U.K.gpm": _UKGAL / 60, "U.S.gal/day": _USGAL / 86400, "U.S.gpm": _USGAL / 60, "L/sec": 1e-3},
    "leakoff": {"cm/min^1/2": 0.01 / 60**0.5, "cm/s^1/2": 0.01, "ft/min^1/2": _FT / 60**0.5, "ft/s^1/2": _FT,
                "m/min^1/2": 1 / 60**0.5, "m/s^1/2": 1.0, "mm/min^1/2": 1e-3 / 60**0.5, "mm/s^1/2": 1e-3},
    "pressure": dict(_PRESSURE),
    "spurt": dict(_LENGTH),
    "time": {"day": 86400.0, "hr": 3600.0, "min": 60.0, "s": 1.0, "yr": 3.1536e7},
    "modulus": {"10^6 psi": _PSI * 1e6, "1000 psi": _PSI * 1e3, "atm": 101325.0, "bar": 1e5, "GPa": 1e9,
                "kg/cm^2": 9.80665e4, "kPa": 1e3, "lbf/ft^2": _PSF, "MPa": 1e6, "Pa": 1.0, "psi": _PSI},
    "radius": {"cm": 0.01, "ft": _FT, "in.": _IN, "km": 1000.0, "m": 1.0, "mm": 1e-3, "yd": _YD},
    "viscosity": {"Pl": 1.0, "P": 0.1, "cP": 1e-3},
    "fraction": {"fraction": 1.0},
}

# (label in the unit-set file, kind) in MATLAB order (uSet rows 1..12)
QUANTITIES = [
    ("Fluid volume", "volume"), ("Fracture length", "length"), ("Fracture aperture", "aperture"),
    ("Fracture height", "height"), ("Injection rate", "rate"), ("Leakoff coefficient", "leakoff"),
    ("Pressure", "pressure"), ("Spurt loss", "spurt"), ("Time", "time"), ("Young's modulus", "modulus"),
    ("Borehole radius", "radius"), ("Fluid viscosity", "viscosity"),
]

# src/HFsim_units/demo.txt
DEFAULT = {
    "volume": "m^3", "length": "m", "aperture": "mm", "height": "m", "rate": "m^3/min",
    "leakoff": "cm/min^1/2", "pressure": "MPa", "spurt": "cm", "time": "min", "modulus": "GPa",
    "radius": "in.", "viscosity": "cP",
}


def factor(kind: str, unit: str) -> float:
    try:
        return UNITS[kind][unit]
    except KeyError as e:
        raise KeyError(f"unknown unit {unit!r} for {kind}") from e


def to_si(value, kind: str, unit: str):
    return value * factor(kind, unit)


def from_si(value, kind: str, unit: str):
    return value / factor(kind, unit)


def choices(kind: str) -> list[str]:
    return list(UNITS[kind])


@dataclass
class UnitSet:
    """Input / output unit per quantity (the MATLAB uSet matrix + description)."""

    description: str = "demo"
    input: dict[str, str] = field(default_factory=lambda: dict(DEFAULT))
    output: dict[str, str] = field(default_factory=lambda: dict(DEFAULT))

    def indices(self) -> list[tuple[int, int]]:
        """1-based popup indices as stored in the unit-set file."""
        return [(choices(k).index(self.input[k]) + 1, choices(k).index(self.output[k]) + 1) for _, k in QUANTITIES]

    @classmethod
    def from_indices(cls, description: str, idx: list[tuple[int, int]]) -> "UnitSet":
        inp, out = {}, {}
        for (label, k), (i, o) in zip(QUANTITIES, idx):
            c = choices(k)
            if not (1 <= i <= len(c) and 1 <= o <= len(c)):
                raise ValueError(f"{label}: unit index out of range ({i}, {o})")
            inp[k], out[k] = c[i - 1], c[o - 1]
        return cls(description, inp, out)

    def save(self, path: str | Path) -> None:
        lines = ["Description:", self.description, "", "Parameter\tInput unit\tOutput unit"]
        lines += [f"{label}\t{i}\t{o}" for (label, _), (i, o) in zip(QUANTITIES, self.indices())]
        with open(path, "w", encoding="utf-8", newline="\r\n") as fh:
            fh.write("\n".join(lines) + "\n")

    @classmethod
    def load(cls, path: str | Path) -> "UnitSet":
        raw = Path(path).read_bytes()
        try:
            text = raw.decode("utf-8")
        except UnicodeDecodeError:
            text = raw.decode("cp949", errors="replace")
        lines = text.splitlines()
        if not lines or not lines[0].startswith("Description"):
            raise ValueError("not a unit-set file (missing 'Description:' line)")
        desc = lines[1].strip() if len(lines) > 1 else ""
        idx = []
        for label, _ in QUANTITIES:
            row = next((l for l in lines if l.startswith(label + "\t")), None)
            if row is None:
                raise ValueError(f"unit-set file is missing '{label}'")
            cells = row.split("\t")
            idx.append((int(cells[1]), int(cells[2])))
        return cls.from_indices(desc, idx)
