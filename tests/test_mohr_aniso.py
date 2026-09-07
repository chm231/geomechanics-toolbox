"""Regression tests for the Mohr circle and strength anisotropy modules vs. MATLAB
(tests/reference/mohr_aniso_matlab.json from tools/gen_reference_mohr_aniso.m)."""
import json
from pathlib import Path

import numpy as np
import pytest

from geomech.core import anisotropy as an
from geomech.core import mohr

REF = Path(__file__).parent / "reference" / "mohr_aniso_matlab.json"
_REF = json.loads(REF.read_text()) if REF.exists() else {}
needs_ref = pytest.mark.skipif(not _REF, reason="MATLAB reference missing; run tools/gen_reference_mohr_aniso.m")


@needs_ref
@pytest.mark.parametrize("case", _REF.get("mohr", []), ids=lambda c: "-".join(f"{v:g}" for v in c["inputs"]))
def test_mohr_matches_matlab(case):
    r = mohr.mohr_3d(*case["inputs"])
    assert r.sigma_n == pytest.approx(case["sigma_n"], rel=1e-10)
    assert r.tau_n == pytest.approx(case["tau_n"], rel=1e-10)
    np.testing.assert_allclose(r.p_theta, case["p_theta"], rtol=1e-10)
    np.testing.assert_allclose(r.p_phi, case["p_phi"], rtol=1e-10)
    v = mohr.plane_view(*case["inputs"], r.sigma_n)
    np.testing.assert_allclose(v.traction_vec, case["traction"], rtol=1e-10)
    np.testing.assert_allclose(v.normal_stress_vec, case["normal_vec"], rtol=1e-10)
    np.testing.assert_allclose(v.shear_vec, case["shear_vec"], rtol=1e-10)


@pytest.mark.parametrize("inputs", [
    (90, 51.5, 88.2, 1, 1, 1), (100, 60, 30, 1, 0, 0.5), (30, 100, 60, 0.3, 0.7, 0.2),
    (80, 40, 10, 0, 1, 1), (100, 60, 30, 2, 3, 4),
])
def test_graphical_construction_equals_direction_cosines(inputs):
    r = mohr.mohr_3d(*inputs)
    sn, tn = mohr.plane_stress_analytic(*inputs)
    assert r.sigma_n == pytest.approx(sn, rel=1e-9)
    assert r.tau_n == pytest.approx(tn, rel=1e-9, abs=1e-9)


def test_mohr_rejects_zero_normal():
    with pytest.raises(ValueError):
        mohr.mohr_3d(100, 60, 30, 0, 0, 0)


@needs_ref
@pytest.mark.parametrize("case", _REF.get("aniso", []), ids=lambda c: "-".join(f"{v:g}" for v in c["inputs"]))
def test_anisotropy_matches_matlab(case):
    beta, s1 = an.strength_anisotropy(*case["inputs"])
    ref = np.array([np.nan if v is None else v for v in case["sigma_1"]], dtype=float)
    np.testing.assert_allclose(beta, case["beta"], rtol=1e-12)
    # MATLAB's cosd(90) is exactly 0, so c_j = 0 and sigma_3 = 0 give 0/0 = NaN at beta = 90 - phi_j;
    # Python evaluates the limit (0). Only finite reference values are compared.
    ok = np.isfinite(ref)
    assert ok.sum() >= len(ref) - 1
    np.testing.assert_allclose(s1[ok], ref[ok], rtol=1e-10)
    assert np.isfinite(s1).all()


def test_anisotropy_equals_jaeger_criterion():
    """The app's beta is measured from the plane NORMAL; Jaeger's beta_J = 90 - beta."""
    c_j, phi_j, c_r, phi_r, s3 = 2.0, 30.0, 50.0, 40.0, 10.0
    beta, s1 = an.strength_anisotropy(c_j, phi_j, c_r, phi_r, s3)
    bj = np.deg2rad(90 - beta)
    tp = np.tan(np.deg2rad(phi_j))
    with np.errstate(divide="ignore", invalid="ignore"):
        jaeger = s3 + 2 * (c_j + s3 * tp) / ((1 - tp / np.tan(bj)) * np.sin(2 * bj))
    ucs = an.rock_strength(c_r, phi_r, s3)
    ok = beta < 90 - phi_j - 0.05          # sliding regime (beta_J > phi_j)
    np.testing.assert_allclose(s1[ok], np.minimum(jaeger[ok], ucs), rtol=1e-9)
    assert np.all(s1[~ok] == ucs)
    assert np.all(s1 <= ucs + 1e-9)
    # minimum strength at beta_J = 45 + phi_j/2, i.e. beta = 45 - phi_j/2
    assert beta[np.argmin(s1)] == pytest.approx(45 - phi_j / 2, abs=0.1)
