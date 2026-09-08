"""Regression tests for the borehole stability module vs. the original MATLAB code
(tests/reference/borehole_matlab.json, produced by tools/gen_reference_borehole.m which
wraps the verbatim computational blocks of BSA210831_v2.m plus calUCS.m / calOBB.m)."""
import json
from pathlib import Path

import numpy as np
import pytest

from geomech.core import borehole as bh

REF = Path(__file__).parent / "reference" / "borehole_matlab.json"
_REF = json.loads(REF.read_text()) if REF.exists() else {}
needs_ref = pytest.mark.skipif(not _REF, reason="MATLAB reference missing; run tools/gen_reference_borehole.m")


def _params(case):
    Sx, Sy, Sz, Sxy, Syz, Sxz, Pp, Pmud, dT, alpha, Gr, pol, azi = case["inputs"]
    return bh.BoreholeParams(np.array(case["Gmat"], dtype=float), Sx, Sy, Sz, Sxy, Syz, Sxz, Pp,
                             None if Pmud is None else Pmud, dT, alpha, Gr, pol, azi)


def _ids(c):
    i = c["inputs"]
    return f"pol{i[11]:g}-azi{i[12]:g}-dT{i[8]:g}-{'iso' if abs(c['Gmat'][0][0] - 0.01) < 1e-12 else 'trans'}"


@needs_ref
@pytest.mark.parametrize("case", _REF.get("analytic", []), ids=_ids)
def test_analytic_field_matches_matlab(case):
    f = bh.analytic_solution(_params(case))
    ri, ti = np.array(case["ri"]), np.array(case["ti"])
    sub = np.ix_(ri, ti)
    np.testing.assert_allclose(f.r[sub], case["r"], rtol=1e-12)
    np.testing.assert_allclose(f.theta[sub], case["theta"], rtol=1e-12, atol=1e-12)
    mu_ref = np.array(case["mu_re"]) + 1j * np.array(case["mu_im"])
    # Isotropic rock makes the sextic have a triple root (+-i); companion-matrix eigenvalues of a
    # repeated root are only accurate to ~eps^(1/3) ~ 1e-5, and MATLAB and LAPACK-via-numpy land on
    # slightly different values. Distinct roots (anisotropic cases) agree to 1e-9.
    iso = "iso" in _ids(case)
    np.testing.assert_allclose(f.extra["mu"], mu_ref, rtol=1e-4 if iso else 1e-9)
    rtol = 1e-4 if iso else 1e-7
    scale = 30e6  # tolerance relative to the stress level (Pa)
    for name in ("Sr", "St", "Sz", "Trt", "Trz", "Ttz", "Sp1", "Sp2", "Sp3"):
        np.testing.assert_allclose(getattr(f, name)[sub], case[name], rtol=rtol, atol=rtol * scale, err_msg=name)
    for name in ("dispxx", "dispyy"):
        ref = np.array(case[name])
        np.testing.assert_allclose(getattr(f, name)[sub], ref, rtol=rtol, atol=rtol * np.abs(ref).max(), err_msg=name)
    np.testing.assert_allclose(f.St[0], case["St_wall"], rtol=rtol, atol=rtol * scale)


@needs_ref
@pytest.mark.parametrize("case", _REF.get("analytic", []), ids=_ids)
def test_breakout_geometry_matches_matlab(case):
    f = bh.analytic_solution(_params(case))
    rbbo, thetabbo = bh.breakout_geometry(f, bh.Strength(40, 30, 0))
    assert rbbo == pytest.approx(case["rbbo"], abs=1e-9)
    assert thetabbo == pytest.approx(np.rad2deg(case["thetabbo"]), abs=1e-9)


def test_isotropic_wall_matches_kirsch():
    """Vertical hole, isotropic rock, no mud: tangential wall stress = Kirsch solution."""
    p = bh.BoreholeParams(bh.compliance_isotropic(100, 0.25), 30, 20, 25, Pp=10, radius=0.1)
    f = bh.analytic_solution(p)
    sx, sy = (30 - 10) * 1e6, (20 - 10) * 1e6
    kirsch = sx + sy - 2 * (sx - sy) * np.cos(2 * f.theta[0])
    np.testing.assert_allclose(f.St[0], kirsch, rtol=5e-4)   # mu perturbation (1.0001..1.0003) limits agreement
    assert np.abs(f.Sr[0]).max() < 1e-4 * sx
    assert np.abs(f.Sr[-1] - (sx * np.cos(f.theta[-1]) ** 2 + sy * np.sin(f.theta[-1]) ** 2)).max() < 0.03 * sx


@needs_ref
def test_fem_element_stresses_match_matlab():
    c = _REF["fem"]
    Sx, Sy, Sz, Sxy, Syz, Sxz, Pp, Pmud, dT, alpha, Gr, pol, azi = c["inputs"]
    p = bh.BoreholeParams(bh.compliance_isotropic(100, 0.25), Sx, Sy, Sz, Sxy, Syz, Sxz, Pp, Pmud, dT, alpha, Gr, pol, azi)
    f = bh.fem_solution(p, c["rmesh"], c["thmesh"], interp_n=50)
    np.testing.assert_allclose(f.extra["elem_xy"][:, 0], c["xe"], rtol=1e-12, atol=1e-12)
    np.testing.assert_allclose(f.extra["elem_xy"][:, 1], c["ye"], rtol=1e-12, atol=1e-12)
    scale = 30e6
    for name in ("srr", "stt", "srt"):
        np.testing.assert_allclose(f.extra["elem_" + name], c[name], rtol=1e-6, atol=1e-6 * scale, err_msg=name)


@needs_ref
@pytest.mark.parametrize("case", _REF.get("allori", []), ids=lambda c: "-".join(f"{v:g}" for v in c["inputs"]))
def test_all_orientations_match_matlab(case):
    Sx, Sy, Sz, Pp, Pmud, dT, alpha = case["inputs"]
    o = bh.all_orientations(100, 0.25, Sx, Sy, Sz, Pp, Pmud, dT, alpha)
    np.testing.assert_allclose(bh.stress_tensor_geographic(Sx - Pp, Sy - Pp, Sz - Pp), case["S_g"], atol=1e-12)
    np.testing.assert_allclose(o.UCS, case["UCS"], rtol=1e-9)
    np.testing.assert_allclose(o.OBB, case["OBB"], rtol=1e-12)


def test_local_mohr_and_failure_indicators():
    p = bh.BoreholeParams(bh.compliance_isotropic(100, 0.25), 30, 20, 25, Pp=10, radius=0.1)
    f = bh.analytic_solution(p)
    s = bh.Strength(40, 30, 5)
    mc, tens = bh.failure_indicators(f, s)
    assert mc.shape == f.St.shape and tens.shape == f.St.shape
    lm = bh.local_mohr(f, 0.1, 90, s)
    assert lm.theta_deg == pytest.approx(90, abs=0.3)
    assert lm.Sp1 >= lm.Sp2 >= lm.Sp3
    assert lm.mc_line is not None and lm.C0 > 0


def test_batched_wall_stresses_and_thermal_voigt_match_scalar_calls():
    """all_orientations evaluates every (delta, phi) at once; the batch must equal the scalar
    calUCS/calOBB port point by point, thermal terms included."""
    amatte = bh.compliance_isotropic(100, 0.25) / bh.MPA
    S_g = bh.stress_tensor_geographic(20, 10, 15)
    delta = np.deg2rad([0.0, 37.0, 200.0]); phi = np.deg2rad([0.0, 45.0, 90.0])
    batch = bh._wall_stresses(delta[:, None], phi[None, :], 10.0, 15.0, 0.25, S_g, amatte, 5.0, 1e-5)
    assert batch.shape == (3, 3, 201)
    for i, d in enumerate(delta):
        for j, f in enumerate(phi):
            one = bh._wall_stresses(d, f, 10.0, 15.0, 0.25, S_g, amatte, 5.0, 1e-5)
            np.testing.assert_allclose(batch[i, j], one, rtol=1e-12)
            assert bh._first_max_angle(batch[i, j]) == pytest.approx(bh.breakout_orientation(d, f, 10.0, 15.0, 0.25, S_g, amatte, 5.0, 1e-5))
    # per-angle 6x6 solves (the MATLAB loop) against the batched version
    theta = np.linspace(0, 2 * np.pi, 37)
    amat = bh.compliance_transverse(100, 60, 0.25, 0.2, 30) / bh.MPA
    loop = np.array([np.linalg.solve(T, np.r_[0.0, np.linalg.solve((T.T @ amat @ T)[1:3, 1:3], [5e-5, 5e-5]), 0.0, 0.0, 0.0])
                     for T in (bh._eptrans(t) for t in theta)])
    np.testing.assert_allclose(bh._thermal_voigt(amat, theta, 5.0, 1e-5), loop, rtol=1e-9, atol=1e-12)
    assert bh._eptrans(theta).shape == (37, 6, 6)
    np.testing.assert_allclose(bh._eptrans(theta)[5], bh._eptrans(theta[5]))
