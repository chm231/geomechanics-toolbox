"""Regression tests for the stereonet module vs. the original MATLAB helpers
(tests/reference/stereonet_matlab.json from tools/gen_reference_stereonet.m)."""
import json
from pathlib import Path

import numpy as np
import pytest

from geomech.core import stereonet as st

REF = Path(__file__).parent / "reference" / "stereonet_matlab.json"
_REF = json.loads(REF.read_text()) if REF.exists() else {}
needs_ref = pytest.mark.skipif(not _REF, reason="MATLAB reference missing; run tools/gen_reference_stereonet.m")


def _data():
    return np.array(_REF["data"], dtype=float)


@needs_ref
@pytest.mark.parametrize("k", range(4), ids=["lower-area", "lower-angle", "upper-area", "upper-angle"])
def test_projection_and_density(k):
    c = _REF["proj"][k]
    d = _data()
    tre, plu = st.poles(d[:, 0], d[:, 1])
    x, y = st.project(tre, plu, bool(c["upper"]), bool(c["equalAngle"]))
    np.testing.assert_allclose(x, c["x"], atol=1e-12)
    np.testing.assert_allclose(y, c["y"], atol=1e-12)
    cx, cy, res = st.pole_density(d[:, 0], d[:, 1], bool(c["upper"]), bool(c["equalAngle"]))
    np.testing.assert_allclose(cx, c["cx"], atol=1e-12)
    np.testing.assert_allclose(cy, c["cy"], atol=1e-12)
    np.testing.assert_allclose(res, c["density"], atol=1e-9)


@needs_ref
def test_vector_to_trend_plunge():
    d = _data()
    v = st.pole_vectors(d[:, 0], d[:, 1])
    np.testing.assert_allclose(v, _REF["vec"], atol=1e-12)
    t, p = st.vec_to_trend_plunge(v[:, 0], v[:, 1], v[:, 2])
    np.testing.assert_allclose(t, _REF["vec_tre"], atol=1e-12)
    np.testing.assert_allclose(p, _REF["vec_plu"], atol=1e-12)


@needs_ref
def test_great_circles():
    for row in _REF["gc"]:
        for c in row:
            x, y = st.great_circle(np.deg2rad(c["dip"]), np.deg2rad(c["did"]), bool(c["upper"]), equal_angle=True)
            np.testing.assert_allclose(x, c["x"], atol=1e-12)
            np.testing.assert_allclose(y, c["y"], atol=1e-12)


@needs_ref
@pytest.mark.parametrize("i", range(4))
def test_designated_set_mean(i):
    c = _REF["sets"][i]
    d = _data()
    w = [np.deg2rad(v) for v in c["window"]]
    r = st.designate_set(d[:, 0], d[:, 1], *w, upper=False, equal_angle=False)
    assert r.n_members == c["n"]
    if c["dip"] is None or (isinstance(c["dip"], float) and np.isnan(c["dip"])):
        assert r.mean_vec is None
    else:
        np.testing.assert_allclose(r.mean_vec, c["avg"], atol=1e-12)
        assert r.mean_dip_deg == pytest.approx(c["dip"], abs=1e-9)
        assert r.mean_dipdir_deg == pytest.approx(c["did"], abs=1e-9)


@needs_ref
def test_fcm_from_fixed_partition():
    c = _REF["fcm"]
    v = np.array(_REF["vec"])
    center, U, obj = st.fcm(v, 3, U0=np.array(c["U0"]))
    np.testing.assert_allclose(obj, c["obj"], rtol=1e-9)
    np.testing.assert_allclose(center, c["center"], atol=1e-9)
    np.testing.assert_allclose(U, c["U"], atol=1e-9)


@needs_ref
def test_rose_counts():
    d = _data()
    theta = st.strike_angles(d[:, 1])
    np.testing.assert_allclose(theta, _REF["rose_theta"], atol=1e-12)
    counts, _ = st.rose_histogram(d[:, 1])
    np.testing.assert_array_equal(counts, np.array(_REF["rose_counts"]).round())


def test_unproject_roundtrip():
    for upper in (False, True):
        for ea in (False, True):
            for dip, dd in ((30, 45), (60, 120), (85, 200), (10, 300), (45, 0)):
                tre, plu = st.poles(dip, dd)
                x, y = st.project(tre, plu, upper, ea)
                di, did = st.unproject(float(x), float(y), upper, ea)
                assert np.rad2deg(di) == pytest.approx(dip, abs=1e-6)
                ddiff = (np.rad2deg(did) - dd + 180) % 360 - 180
                assert abs(ddiff) < 1e-6


def test_clustering_recovers_three_sets():
    rng = np.random.default_rng(0)
    sets = [(60, 30), (70, 150), (20, 270)]
    dip, dd = [], []
    for s_dip, s_dd in sets:
        dip += list(np.clip(s_dip + rng.normal(0, 4, 40), 1, 89)); dd += list((s_dd + rng.normal(0, 6, 40)) % 360)
    cl = st.cluster_poles(dip, dd, 3, seed=3)
    assert len(cl) == 3
    found = sorted((round(c.dip_deg), round(c.dipdir_deg)) for c in cl)
    for s in sets:
        assert any(abs(f[0] - s[0]) < 8 and (abs(f[1] - s[1]) < 15 or abs(f[1] - s[1]) > 345) for f in found), (s, found)
