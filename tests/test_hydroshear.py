"""Regression tests for the hydroshearing module vs. the original MATLAB functions
(tests/reference/hydroshear_matlab.json from tools/gen_reference_hydroshear.m)."""
import json
from pathlib import Path

import numpy as np
import pytest

from geomech.core import hydroshear as hs

REF = Path(__file__).parent / "reference" / "hydroshear_matlab.json"
_REF = json.loads(REF.read_text()) if REF.exists() else {}
_CASES = _REF.get("cases", [])
needs_ref = pytest.mark.skipif(not _CASES, reason="MATLAB reference missing; run tools/gen_reference_hydroshear.m")
_IDS = ["-".join(f"{v:g}" for v in c["inputs"][:5]) for c in _CASES]


def _params(case) -> hs.ShearParams:
    Sv, SH, Sh, azi, phi, rr, rf, alpha = case["inputs"]
    return hs.ShearParams(Sv, SH, Sh, azi, phi, rr, rf, alpha)


@needs_ref
@pytest.mark.parametrize("case", _CASES, ids=_IDS)
def test_quick_run_matches_matlab(case):
    p = _params(case)
    np.testing.assert_allclose(p.S123, case["S123"], atol=1e-12)
    q = hs.quick_run(p, np.array(case["joints"]))
    assert q.Pcm == pytest.approx(case["Pcm"] / 1e6, rel=1e-12)
    assert q.Pco == pytest.approx(case["Pco"] / 1e6, rel=1e-12)
    assert f"({q.optimal[0][0]:.2f}, {q.optimal[0][1]:.2f})," == case["opt1"]
    assert f"({q.optimal[1][0]:.2f}, {q.optimal[1][1]:.2f})" == case["opt2"]
    np.testing.assert_allclose(q.joints[:, 2], np.array(case["Pc"]) / 1e6, rtol=1e-10)
    grad = hs.dpcdz(p.rho_r, np.deg2rad(q.joints[:, 0]), np.deg2rad(q.joints[:, 1]), p.S123, p.Sv * 1e6, p.phi_rad)
    np.testing.assert_allclose(grad, case["grad"], rtol=1e-10)
    np.testing.assert_array_equal(q.joints[:, 3], np.where(np.array(case["grad"]) > p.rho_f * hs.G, 0, 1))


@needs_ref
@pytest.mark.parametrize("case", _CASES, ids=_IDS)
def test_polygon_group_matches_matlab(case):
    p = _params(case)
    r = hs.polygon_group(p.phi_rad, p.Sv * 1e6, p.rho_r, p.rho_f, p.alpha)
    np.testing.assert_allclose(r.x, case["poly_x"], rtol=1e-12)
    np.testing.assert_allclose(r.y, case["poly_y"], rtol=1e-12)
    np.testing.assert_allclose(r.kcm, case["kcm"], rtol=1e-10)
    np.testing.assert_allclose(r.kco, case["kco"], rtol=1e-10)
    np.testing.assert_allclose(r.pro_pco, case["pro_pco"], atol=1e-12)
    # counts of joints with (pp - k0) < 0: one joint can sit exactly on the threshold and be
    # counted differently by the two roundings of the shear stress -> allow one count (1/8056)
    np.testing.assert_allclose(r.pro_down, case["pro_down"], atol=1.5 / (90 * 89 + 45 + 1))


@needs_ref
@pytest.mark.parametrize("case", _CASES, ids=_IDS)
def test_stereonet_group_matches_matlab(case):
    p = _params(case)
    r = hs.stereonet_group(p.S123, p.Sv * 1e6, p.phi_rad, p.rho_r, p.rho_f, p.alpha)
    si, sj = np.array(case["si"]), np.array(case["sj"])
    sub = np.ix_(si, sj)
    np.testing.assert_allclose(r.x[sub], case["sx"], atol=1e-12)
    np.testing.assert_allclose(r.y[sub], case["sy"], atol=1e-12)
    np.testing.assert_allclose(r.kc[sub], case["kc"], rtol=1e-10, atol=1e-12)
    np.testing.assert_allclose(r.pp_gr[sub], case["pp_gr"], rtol=1e-10, atol=1e-12)
    # MATLAB allocates p, num_fra, prob with zeros(no) -> 91x91 matrices of which only the first
    # column (linear indices 1..91) is used; the JSON holds the flattened matrix.
    np.testing.assert_allclose(r.p, np.array(case["p"])[:91], rtol=1e-12)
    # cumulative histogram of kc over 90 bins: a joint whose kc falls exactly on a bin edge can be
    # binned differently by the two roundings of kc -> allow one count (1/32221) per bin
    np.testing.assert_allclose(r.prob, np.array(case["prob"])[:91], atol=1.5 / (360 * 89 + 180 + 1))
    assert not np.any(np.array(case["prob"])[91:])


def test_load_dfn_sample():
    src = Path(__file__).resolve().parents[1] / "src" / "DFNs" / "demo.txt"
    if not src.exists():
        pytest.skip("src/DFNs/demo.txt not present")
    both = hs.load_dfn(src)
    first = hs.load_dfn(src, intersecting_only=True)
    assert both.shape[1] == 2 and len(both) >= len(first) > 0
    assert (both[:, 0] >= 0).all() and (both[:, 0] <= 90).all()


def test_pcm_zero_for_optimal_when_S1_equals_limit():
    """Pcm = 0 when S1/S3 equals the frictional limit (1+sin phi)/(1-sin phi)."""
    phi = np.deg2rad(30)
    S3 = 10e6
    S1 = S3 * (1 + np.sin(phi)) / (1 - np.sin(phi))
    assert hs.pcm(S1, S3, phi) == pytest.approx(0.0, abs=1e-6)
