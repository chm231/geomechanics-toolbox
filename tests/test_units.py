"""Unit registry vs. the constants hard-coded in Units.m, and unit-set file round trip."""
from pathlib import Path

import numpy as np
import pytest

from geomech.core import units as U

SRC = Path(__file__).resolve().parents[1] / "src"

# (kind, unit, MATLAB IU factor)   - okButton_Callback 'switch' tables (value -> SI)
MATLAB_IU = [
    ("height", "cm", 1.0e-2), ("height", "ft", 0.3048), ("height", "in.", 0.0254), ("height", "km", 1.0e3), ("height", "yd", 0.9144),
    ("volume", "1000 U.K.gal", 4.54609188), ("volume", "1000 U.S.gal", 3.78541178), ("volume", "bbl", 0.11924071),
    ("volume", "ft^3", 2.83168466e-2), ("volume", "L", 0.001), ("volume", "U.K.gal", 4.54609188e-3), ("volume", "U.S.gal", 3.78541178e-3),
    ("time", "day", 8.64e4), ("time", "hr", 3600), ("time", "min", 60), ("time", "yr", 3.1536e7),
    ("modulus", "10^6 psi", 6.89476e9), ("modulus", "1000 psi", 6.89476e6), ("modulus", "atm", 101325), ("modulus", "bar", 100000),
    ("modulus", "GPa", 1.0e9), ("modulus", "kg/cm^2", 9.80665e4), ("modulus", "kPa", 1000),
    ("modulus", "MPa", 1.0e6), ("modulus", "psi", 6.89476e3),
    ("rate", "10 U.S.gpm", 6.30901963e-4), ("rate", "bbl/day", 1.38010081e-6), ("rate", "bpm", 1.98734517e-3), ("rate", "ft^3/day", 3.2774128e-7),
    ("rate", "ft^3/min", 4.71947443e-4), ("rate", "L/min", 1.66666667e-5), ("rate", "m^3/day", 1.15740741e-5), ("rate", "m^3/min", 1.66666667e-2),
    ("rate", "U.K.gpm", 7.5768198e-5), ("rate", "U.S.gal/day", 4.38126363e-8), ("rate", "U.S.gpm", 6.30901963e-5), ("rate", "L/sec", 0.001),
    ("viscosity", "Pl", 1), ("viscosity", "P", 0.1), ("viscosity", "cP", 0.001),
    ("leakoff", "cm/min^1/2", 1.29099445e-3), ("leakoff", "cm/s^1/2", 0.01), ("leakoff", "ft/min^1/2", 3.93495108e-2), ("leakoff", "ft/s^1/2", 0.3048),
    ("leakoff", "m/min^1/2", 1.29099445e-1), ("leakoff", "m/s^1/2", 1), ("leakoff", "mm/min^1/2", 1.29099445e-4), ("leakoff", "mm/s^1/2", 0.001),
    ("spurt", "cm", 0.01), ("spurt", "ft", 0.3048), ("spurt", "in.", 0.0254), ("spurt", "km", 1000), ("spurt", "m", 1), ("spurt", "yd", 0.9144),
    ("radius", "cm", 0.01), ("radius", "ft", 0.3048), ("radius", "in.", 0.0254), ("radius", "km", 1000), ("radius", "m", 1), ("radius", "mm", 0.001), ("radius", "yd", 0.9144),
]
# (kind, unit, MATLAB OU factor)   - SI -> display
MATLAB_OU = [
    ("time", "day", 1.15740741e-5), ("time", "hr", 2.77777778e-4), ("time", "min", 1.66666667e-2), ("time", "yr", 3.17097920e-8),
    ("length", "cm", 100), ("length", "ft", 3.2808399), ("length", "in.", 39.3700787), ("length", "km", 0.001), ("length", "yd", 1.0936133),
    ("aperture", "cm", 100), ("aperture", "ft", 3.2808399), ("aperture", "in.", 39.3700787), ("aperture", "mm", 1000),
    ("pressure", "10^6 psi", 1.45037681e-10), ("pressure", "1000 psi", 1.45037681e-7), ("pressure", "atm", 9.86923267e-6), ("pressure", "bar", 1.0e-5),
    ("pressure", "kg/cm^2", 1.01971621e-5), ("pressure", "kPa", 0.001), ("pressure", "lbf/ft^2", 2.08854342e-2), ("pressure", "MPa", 1.0e-6),
    ("pressure", "Pa", 1), ("pressure", "psi", 1.45037681e-4),
    ("volume", "1000 U.K.gal", 0.219969157), ("volume", "1000 U.S.gal", 0.264172053), ("volume", "bbl", 8.38639757), ("volume", "ft^3", 35.3146667),
    ("volume", "L", 1000), ("volume", "m^3", 1), ("volume", "U.K.gal", 219.969157), ("volume", "U.S.gal", 264.172053),
]


@pytest.mark.parametrize("kind,unit,f", MATLAB_IU, ids=lambda v: str(v))
def test_input_factors_match_units_m(kind, unit, f):
    assert U.factor(kind, unit) == pytest.approx(f, rel=2e-6)


@pytest.mark.parametrize("kind,unit,f", MATLAB_OU, ids=lambda v: str(v))
def test_output_factors_match_units_m(kind, unit, f):
    assert 1 / U.factor(kind, unit) == pytest.approx(f, rel=2e-6)


def test_lbf_per_ft2_input_factor_is_corrected():
    """Units.m: YoungsIUFactor for lbf/ft^2 = 4.78802590 (10x too small); 1 lbf/ft^2 = 47.88 Pa,
    consistent with the MATLAB output factor 2.08854342e-2 = 1/47.88."""
    assert U.factor("modulus", "lbf/ft^2") == pytest.approx(47.8802590, rel=1e-8)
    assert U.factor("pressure", "lbf/ft^2") == pytest.approx(1 / 2.08854342e-2, rel=1e-7)


def test_menu_order_matches_fig():
    """Indices in unit-set files refer to the MATLAB popup order."""
    assert U.choices("volume") == ["1000 U.K.gal", "1000 U.S.gal", "bbl", "ft^3", "L", "m^3", "U.K.gal", "U.S.gal"]
    assert U.choices("rate")[-1] == "L/sec" and len(U.choices("rate")) == 12
    assert U.choices("modulus")[4] == "GPa" and len(U.choices("pressure")) == 10
    assert U.choices("radius") == ["cm", "ft", "in.", "km", "m", "mm", "yd"]


def test_load_demo_unit_set_and_roundtrip(tmp_path):
    demo = SRC / "HFsim_units" / "demo.txt"
    if not demo.exists():
        pytest.skip("src/HFsim_units/demo.txt not present")
    s = U.UnitSet.load(demo)
    assert s.description == "demo"
    assert s.input == U.DEFAULT and s.output == U.DEFAULT
    assert s.indices() == [(6, 6), (5, 5), (4, 4), (5, 5), (8, 8), (1, 1), (8, 8), (1, 1), (3, 3), (5, 5), (3, 3), (3, 3)]
    f = tmp_path / "set.txt"
    s.save(f)
    assert U.UnitSet.load(f) == s
    oil = U.UnitSet.load(SRC / "HFsim_units" / "oilfield.txt")
    assert oil.input["volume"] == "1000 U.K.gal" and oil.output["pressure"] == "10^6 psi"


def test_conversion_roundtrip():
    for kind, units in U.UNITS.items():
        for u in units:
            assert U.from_si(U.to_si(3.5, kind, u), kind, u) == pytest.approx(3.5)
    assert U.to_si(1.0, "leakoff", "ft/min^1/2") == pytest.approx(0.3048 / np.sqrt(60))
