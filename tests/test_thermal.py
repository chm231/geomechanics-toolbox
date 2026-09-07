"""Regression tests: thermal module vs. original MATLAB output
(tests/reference/thermal_matlab.json from tools/gen_reference_thermal.m).

Tolerances: the Bodvarsson model is closed-form and matches to 1e-8. The Gringarten
and radial models go through Talbot's inverse Laplace transform with M = 64 terms of
magnitude ~exp(25) that cancel, so double-precision results from any two libraries
differ at the 1e-6 level (verified against a 60-digit evaluation of the same sum).
Those are compared with an absolute tolerance of 2e-3 degC (largest observed 1.2e-3),
far below the 0.01 degC the GUI displays.

MATLAB's single-fracture fields (N == 1) are broken: rockTemp_grg.m feeds x_E = inf
through the inversion and gets NaN everywhere; rockTemp_rad.m uses x_E = 1e10 and gets
values like -5e6 degC deep in the rock. The Python port uses the closed-form limits, so
for those two cases the test checks physical bounds instead of matching MATLAB.
"""
import json
from pathlib import Path

import numpy as np
import pytest

from geomech.core import thermal as th

REF = Path(__file__).parent / "reference" / "thermal_matlab.json"
_CASES = json.loads(REF.read_text()) if REF.exists() else []
_IDS = [f"{c['model']}-N{c['params']['N']}" for c in _CASES]
needs_ref = pytest.mark.skipif(not _CASES, reason="MATLAB reference missing; run tools/gen_reference_thermal.m")


def _params(case) -> th.ThermalParams:
    return th.ThermalParams(**case["params"])


def _arr(v):
    """JSON null (MATLAB NaN) -> nan."""
    return np.array([[np.nan if x is None else x for x in row] if isinstance(row, list)
                     else (np.nan if row is None else row) for row in v], dtype=float)


def _tol(model: str) -> dict:
    return {"rtol": 1e-8} if model == "bodvarsson" else {"rtol": 0, "atol": 2e-3}


def _assert_close(got, ref, model):
    ref = np.asarray(ref, dtype=float)
    ok = np.isfinite(ref)
    assert ok.any(), "reference is entirely NaN"
    np.testing.assert_allclose(np.atleast_1d(np.asarray(got, dtype=float))[ok], ref[ok], **_tol(model))


@needs_ref
@pytest.mark.parametrize("case", _CASES, ids=_IDS)
def test_outlet_temperature(case):
    _assert_close(th.outlet_temperature(case["model"], _params(case)), [case["outlet"]], case["model"])


@needs_ref
@pytest.mark.parametrize("case", _CASES, ids=_IDS)
def test_profiles(case):
    p = _params(case)
    x, T = th.profile(case["model"], p, "distance", 0, 1000)
    np.testing.assert_allclose(x, case["prof_z_x"], rtol=1e-12)
    _assert_close(T, _arr(case["prof_z"]), case["model"])
    x, T = th.profile(case["model"], p, "time", 1, 50)
    np.testing.assert_allclose(x, case["prof_t_x"], rtol=1e-12)
    _assert_close(T, _arr(case["prof_t"]), case["model"])


@needs_ref
@pytest.mark.parametrize("case", _CASES, ids=_IDS)
def test_temperature_field(case):
    p = _params(case)
    f = th.temperature_field(case["model"], p)
    idx = np.array(case["grid_idx"])
    np.testing.assert_allclose(f.normal[np.ix_(idx, idx)], _arr(case["grid_normal"]), rtol=1e-12)
    np.testing.assert_allclose(f.along[np.ix_(idx, idx)], _arr(case["grid_along"]), rtol=1e-12)
    ref = _arr(case["grid_T"])
    if case["model"] != "bodvarsson" and p.N == 1:
        # MATLAB output is NaN (gringarten) or wildly out of range (radial): check physics only.
        assert np.isnan(ref).all() or (np.nanmin(ref) < p.T_wo - 1) or (np.nanmax(ref) > p.T_ro + 1)
        T = f.T
        assert np.isfinite(T).all() and (T >= p.T_wo - 1e-9).all() and (T <= p.T_ro + 1e-9).all()
        assert T[0, 0] == pytest.approx(p.T_wo)          # fluid at the inlet
        assert np.all(np.diff(T, axis=0) >= -1e-9)        # warmer deeper into the rock
        return
    _assert_close(f.T[np.ix_(idx, idx)], ref, case["model"])


def test_saved_project_value():
    """reservTemp_projects/saveTest.txt records 161.67 degC for the Gringarten case."""
    p = th.ThermalParams(c_r=800, c_w=4178, rho_r=2628, K_r=3.018, T_ro=180, T_wo=60,
                         L=600, Q_m=40, N=5, spacing=60, z=800, t_year=30)
    assert th.outlet_temperature("gringarten", p) == pytest.approx(161.67, abs=0.005)


def test_talbot_inverts_exponential():
    # L{exp(-a t)} = 1/(s+a)
    t = np.array([0.5, 1.0, 2.0])
    got = th.talbot_inversion(lambda s: 1 / (s + 0.7), t)
    np.testing.assert_allclose(got, np.exp(-0.7 * t), rtol=1e-5)  # M=64 Talbot is coarse (MATLAB default)


def test_tiles_count():
    p = th.ThermalParams(c_r=800, c_w=4178, rho_r=2628, K_r=3.018, T_ro=180, T_wo=60,
                         L=600, Q_m=40, N=4, spacing=60, z=800, t_year=30)
    f = th.temperature_field("bodvarsson", p, n=5)
    assert len(f.tiles()) == 2
    f = th.temperature_field("gringarten", p, n=5)
    assert len(f.tiles()) == 8
