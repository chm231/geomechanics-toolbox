"""The rock-mass generator is checked against the original script of the DFN project,
vendored unchanged as tests/oracle/generate_dfn_v1.py (same seeds -> identical arrays)."""
import importlib.util
import json
from pathlib import Path

import numpy as np
import pytest

from geomech.core import dfn_rockmass as rm

ORACLE = Path(__file__).parent / "oracle" / "generate_dfn_v1.py"


def _oracle():
    if not ORACLE.exists():
        pytest.skip("original generate_dfn.py not vendored")
    pytest.importorskip("h5py")
    spec = importlib.util.spec_from_file_location("generate_dfn_v1", ORACLE)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


SIZE_DISTS = [
    {"type": "powerlaw", "kr": 2.88, "r0": 0.28, "rmin": 0.5, "rmax": 250.0},
    {"type": "powerlaw", "kr": 1.0, "r0": 0.28, "rmin": 0.5, "rmax": 250.0},   # alpha == 2
    {"type": "exponential", "r0": 4.0, "rmin": 0.5, "rmax": 250.0},
    {"type": "lognormal", "mu": 0.5, "sigma": 0.6, "rmin": 0.5, "rmax": 50.0},
    {"type": "uniform", "rmin": 0.5, "rmax": 20.0},
]


@pytest.mark.parametrize("d", SIZE_DISTS, ids=lambda d: d["type"] + str(d.get("kr", "")))
def test_size_sampling_and_pdf_match_original(d):
    o = _oracle()
    r_o = o.sample_radius(d, 5000, seed=11)
    r_p = rm.sample_radius(d, 5000, seed=11)
    np.testing.assert_array_equal(r_p, r_o)
    grid = np.linspace(0.1, d["rmax"] * 1.1, 400)
    np.testing.assert_allclose(rm.size_pdf_truncated(grid, d), o.size_pdf_truncated(grid, d), rtol=1e-12)
    assert rm.num_fractures_from_P32(1.2, d, 100.0**3) == o.compute_num_fractures_from_P32(1.2, d, 100.0**3)


@pytest.mark.parametrize("trend,plunge,kappa", [(87.2, 1.7, 21.66), (342.9, 80.3, 8.18), (0.0, 90.0, 5.0), (0.0, -90.0, 5.0), (10.0, 0.0, 0.0)])
def test_fisher_normals_and_basis_match_original(trend, plunge, kappa):
    o = _oracle()
    m_o = o.mean_pole_vector_from_trend_plunge(trend, plunge)
    m_p = rm.mean_pole_vector(trend, plunge)
    np.testing.assert_allclose(m_p, m_o, atol=1e-15)
    n_o = o.sample_fisher_normals(m_o, kappa, 3000, seed=5)
    n_p = rm.sample_fisher_normals(m_p, kappa, 3000, seed=5)
    np.testing.assert_allclose(n_p, n_o, atol=1e-14)
    su_o, du_o = o.normal_to_strike_dip_basis_vectorized(n_o)
    su_p, du_p = rm.strike_dip_basis(n_p)
    np.testing.assert_allclose(su_p, su_o, atol=1e-14)
    np.testing.assert_allclose(du_p, du_o, atol=1e-14)
    box = {"dx": 100, "dy": 100, "dz": 100, "x0": -50, "y0": -50, "z0": -50}
    r = rm.sample_radius(SIZE_DISTS[0], 3000, seed=1)
    for mode in ("area_uniform", "report"):
        np.testing.assert_allclose(rm.sample_centers(box, r, su_p, du_p, mode, seed=9),
                                   o.sample_centers_from_surface_points(box, r, su_o, du_o, mode, seed=9), atol=1e-12)


@pytest.mark.parametrize("site", ["forsmark", "laxemar"])
def test_whole_realisation_matches_original_pipeline(site):
    """Re-run the original per-set loop (its main() is CLI-only) with the same seeds on a
    small box and compare every fracture."""
    o = _oracle()
    size, rmin, rmax, seed = 40.0, 0.5, 250.0, 42
    sets = rm.preset_sets(site, rmin, rmax)
    dfn = rm.generate(sets, size=size, seed=seed)
    box = {"dx": size, "dy": size, "dz": size, "x0": -size / 2, "y0": -size / 2, "z0": -size / 2}
    V = size**3
    C, N, R = [], [], []
    for i, s in enumerate(sets):
        d = s.size_dist()
        if d["type"] == "powerlaw":
            p = 2.0 - s.kr
            i0 = (s.rmax**p - s.r0**p) / p; imin = (s.rmax**p - s.rmin**p) / p
            target = s.P32 * imin / i0
        elif d["type"] == "exponential":
            lbl = 1.0 / s.r0
            F = lambda r: -np.exp(-lbl * r) * (r**2 + 2 * r / lbl + 2 / lbl**2)  # noqa: E731
            target = s.P32 * (F(s.rmax) - F(s.rmin)) / (F(s.rmax) - F(0.0))
        else:
            target = s.P32
        assert dfn.scaled_p32[i] == pytest.approx(target, rel=1e-12)
        n = o.compute_num_fractures_from_P32(target, d, V)
        assert dfn.targets[i] == n
        base = seed + i * 1000
        r = o.sample_radius(d, n, seed=base)
        nrm = o.sample_fisher_normals(o.mean_pole_vector_from_trend_plunge(s.trend, s.plunge), s.kappa, n, seed=base + 1)
        su, du = o.normal_to_strike_dip_basis_vectorized(nrm)
        c = o.sample_centers_from_surface_points(box, r, su, du, "area_uniform", seed=base + 2)
        C.append(c); N.append(nrm); R.append(r)
    np.testing.assert_allclose(dfn.centers, np.vstack(C).astype(np.float32), rtol=0, atol=0)
    np.testing.assert_allclose(dfn.normals, np.vstack(N).astype(np.float32), rtol=0, atol=0)
    np.testing.assert_allclose(dfn.radii, np.concatenate(R).astype(np.float32), rtol=0, atol=0)
    assert dfn.n == sum(dfn.targets) and dfn.n > 100


def test_clipping_and_trace_maps_match_original():
    o = _oracle()
    dfn = rm.generate(rm.preset_sets("forsmark", 1.0, 250.0), size=40.0, seed=3)
    cb = rm.crop_box_dict(10.0)
    n_checked = 0
    for i in range(min(dfn.n, 300)):
        c, nrm, r = dfn.centers[i].astype(float), dfn.normals[i].astype(float), float(dfn.radii[i])
        a, b = rm.clip_disc(c, nrm, r, cb), o.clip_disc_with_cropbox(c, nrm, r, cb)
        assert (a is None) == (b is None)
        if a is not None:
            np.testing.assert_allclose(a, b, atol=1e-12)
            for dim in range(3):
                sa, sb = rm.intersect_poly_plane(a, dim, 0.0), o._intersect_poly_plane(b, dim, 0.0)
                assert (sa is None) == (sb is None)
                if sa is not None:
                    np.testing.assert_allclose(sa, sb, atol=1e-12)
            n_checked += 1
    assert n_checked > 5
    clipped = rm.clip_to_crop_box(dfn, cb)
    assert clipped.p32 > 0 and len(clipped.polygons) == len(clipped.set_id)
    tm = rm.trace_map(dfn, cb, "x", 0.0)
    assert tm.p21 > 0 and all(s.shape == (2, 3) for s in tm.segments)


def test_config_and_presets_and_export(tmp_path):
    cfg = {"dataset_name": "t", "sets": {"1": {"p32_base": 0.6, "dist_type": "powerlaw", "r0": 0.28, "trend": 182.8, "plunge": -1.7, "kappa": 22.1, "kr": 2.9},
                                       "4": {"p32_base": 1.0, "dist_type": "exponential", "r0": 3.0, "trend": 3.3, "plunge": 62.1, "kappa": 10.0}}}
    p = tmp_path / "cfg.json"; p.write_text(json.dumps(cfg))
    sets = rm.load_config(p, rmin=0.5, rmax=100.0)
    assert [s.name for s in sets] == ["Set_1", "Set_4"] and sets[0].rmin == 0.5 and sets[1].dist_type == "exponential"
    assert len(rm.preset_sets("laxemar")) == 5 and rm.preset_sets("forsmark")[0].rmin == 0.5
    dfn = rm.generate(sets, size=20.0, seed=1)
    rm.export_csv(dfn, tmp_path / "dfn.csv")
    assert np.loadtxt(tmp_path / "dfn.csv", skiprows=1).shape == (dfn.n, 8)
    h5py = pytest.importorskip("h5py")
    rm.export_hdf5(dfn, tmp_path / "dfn.h5", 0.5, 100.0, "custom")
    with h5py.File(tmp_path / "dfn.h5") as f:
        assert f["/fractures/centers"].shape == (dfn.n, 3) and f["/meta/site"][()] == b"custom"
    GX, GY, dens = rm.pole_density_equal_angle(dfn.normals)
    assert dens.shape == (80, 80) and np.isnan(dens[0, 0])
