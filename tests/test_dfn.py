"""Regression tests for the 3-D DFN generator vs. the original MATLAB loop
(tests/reference/dfn_matlab.json from tools/gen_reference_dfn.m). MATLAB rng(seed,
'twister') and numpy RandomState(seed) produce the same uniform stream, so whole
realisations are compared."""
import json
from pathlib import Path

import numpy as np
import pytest

from geomech.core import dfn
from geomech.core import hydroshear as hs

REF = Path(__file__).parent / "reference" / "dfn_matlab.json"
_REF = json.loads(REF.read_text()) if REF.exists() else {}
_CASES = _REF.get("cases", [])
needs_ref = pytest.mark.skipif(not _CASES, reason="MATLAB reference missing; run tools/gen_reference_dfn.m")


def _params(inputs, shape="Circle"):
    seed, n, x0, y0, z0, domx, domy, domz, dip, dipd, K, l, fsize_ne, fracd, trim, curt, apmean = inputs
    return int(seed), dfn.DFNParams(n=int(n), x0=x0, y0=y0, z0=z0, domx=domx, domy=domy, domz=domz, shape=shape,
                                    dip=dip, dipdir=dipd, K=K, mean_len=l,
                                    size_model="Negative exponential" if fsize_ne else "Power law",
                                    fracd=fracd, trim=trim, curt=curt, aperture_model="Negative exponential",
                                    ap_mean=apmean)


def _nan(v):
    return np.array([[np.nan if x is None else x for x in row] if isinstance(row, list) else (np.nan if row is None else row) for row in v], float)


@needs_ref
@pytest.mark.parametrize("case", _CASES, ids=lambda c: f"seed{c['inputs'][0]:g}-n{c['inputs'][1]:g}")
def test_realisation_matches_matlab(case):
    seed, p = _params(case["inputs"])
    d = dfn.generate(p, seed=seed)
    np.testing.assert_allclose(d.centers[:, 0], case["x1"], rtol=1e-12)
    np.testing.assert_allclose(d.centers[:, 1], case["y1"], rtol=1e-12)
    np.testing.assert_allclose(d.centers[:, 2], case["z1"], rtol=1e-12)
    np.testing.assert_allclose(d.length, case["l1"], rtol=1e-12)
    np.testing.assert_allclose(d.aperture, case["ap"], rtol=1e-12)
    np.testing.assert_allclose(d.rfk, case["rfk"], rtol=1e-12)
    np.testing.assert_allclose(d.normals, case["Pf"], atol=1e-12)
    np.testing.assert_allclose(d.dip2, case["dip2"], atol=1e-12)
    np.testing.assert_allclose(d.dipd2, case["dipd2"], atol=1e-12)
    assert d.K2 == pytest.approx(case["K2"], rel=1e-12)
    np.testing.assert_allclose(d.polygons[0], case["CC1"], atol=1e-10)
    np.testing.assert_allclose(d.polygons[-1], case["CCend"], atol=1e-10)


@needs_ref
@pytest.mark.parametrize("case", _CASES, ids=lambda c: f"seed{c['inputs'][0]:g}-n{c['inputs'][1]:g}")
def test_window_and_drill_match_matlab(case):
    seed, p = _params(case["inputs"])
    d = dfn.generate(p, seed=seed)
    w = dfn.window_traces(d, 60, 30, 0.5)
    ok = np.array([s is not None for s in w.segments3d])
    np.testing.assert_array_equal(ok, np.array(case["sw_ok"]).astype(bool))
    SW = _nan(case["SW"])
    for z in np.flatnonzero(ok):
        np.testing.assert_allclose(w.segments3d[z].ravel(), SW[z], atol=1e-9)
    r = dfn.drill_classify(d, p.domx + 0.5, p.domy - 0.3, 0.0, 10.0, 0.25)
    np.testing.assert_array_equal(r.intersects, np.array(case["inter"]).astype(bool))


def test_square_fractures_are_squares_of_side_l():
    """The MATLAB 'Square' branch cannot run (3x3 * 1x3 error); squares are built on the
    disc plane instead: four vertices, side = l, centred on the fracture centre."""
    p = dfn.DFNParams(n=30, shape="Square", size_model="Power law", dip=45, dipdir=90, K=15,
                      fracd=2.5, trim=0.5, curt=10, ap_mean=100)
    d = dfn.generate(p, seed=5)
    for verts, c, L, nrm in zip(d.polygons, d.centers, d.length, d.normals):
        assert verts.shape == (4, 3)
        np.testing.assert_allclose(verts.mean(axis=0), c, atol=1e-9)
        sides = np.linalg.norm(np.roll(verts, -1, axis=0) - verts, axis=1)
        np.testing.assert_allclose(sides, L, rtol=1e-9)
        # all vertices lie on the plane through c with normal +-nrm
        assert np.abs((verts - c) @ nrm).max() < 1e-9 * max(L, 1.0)
    assert 0.5 <= d.length.min() and d.length.max() <= 10


def test_uniform_stream_matches_matlab_twister():
    """rng(1,'twister'); rand(1,5) in MATLAB gives these values."""
    np.testing.assert_allclose(np.random.RandomState(1).rand(5),
                               [0.417022004702574, 0.7203244934421581, 0.00011437481734488664,
                                0.30233257263183977, 0.14675589081711304], rtol=1e-15)


def test_verification_and_export_roundtrip(tmp_path):
    d = dfn.generate(dfn.DFNParams(n=200, K=30), seed=2)
    v = dfn.verify(d)
    assert all(50 < r <= 100 for r in v.reliability)
    assert 20 < d.K2 < 45
    r = dfn.drill_classify(d, 0.0, 0.0, 0.0, 10.0, 0.3)
    f = tmp_path / "dfn.txt"
    dfn.save_classified(f, d, r)
    both, first = hs.load_dfn(f), hs.load_dfn(f, intersecting_only=True)
    assert len(first) == r.intersects.sum() and len(both) == d.n


def test_power_law_count():
    p = dfn.DFNParams(x0=10, y0=10, z0=10, fracd=2.5, trim=0.5, curt=10)
    assert p.power_law_count() == round(1000 * (0.5 ** -2.5 - 10 ** -2.5))
