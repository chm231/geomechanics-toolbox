"""Rock-mass DFN generator - port of the DFN project's
``dfn generator v1/python/generate_dfn.py`` (Forsmark / Laxemar statistics).

Differences from the toolbox generator (geomech.core.dfn):

* several fracture SETS, each defined by an intensity P32 [m^2/m^3], a truncated
  RADIUS distribution (power law with survival exponent kr, exponential, log-normal
  or uniform between rmin and rmax), and a Fisher orientation given by the mean
  pole TREND / PLUNGE and concentration kappa;
* the number of fractures per set follows from P32 x box volume / mean disc area,
  with the tabulated P32 rescaled from its reference cutoff r0 to the generation
  cutoff rmin (power law and exponential);
* coordinates are x = East, y = North, z = Up; centres are sampled uniformly in
  the box and shifted by an area-uniform point on the disc so that the disc
  surface (not the centre) is uniform in space;
* discs can be clipped to a crop box, cut by axis-aligned planes into 2-D trace
  maps (P21) and exported to the HDF5 layout consumed by the DFN project.

Random numbers use numpy's default_rng with the same per-set / per-chunk seed
offsets as the original script, so generate(seed=s) reproduces its realisations.
"""
from __future__ import annotations

import json
import re
from dataclasses import dataclass, field
from pathlib import Path

import numpy as np
import scipy.integrate as integrate

DIST_TYPES = ("powerlaw", "exponential", "lognormal", "uniform")


# --------------------------------------------------------------------------
# Set definitions and presets
# --------------------------------------------------------------------------
@dataclass
class FractureSet:
    name: str
    P32: float                 # [m^2/m^3] tabulated intensity for radii >= r0
    dist_type: str = "powerlaw"
    kr: float = 3.0            # power-law survival exponent (pdf ~ r^-(kr+1))
    r0: float = 0.25           # reference radius of the tabulated P32 / exponential mean
    rmin: float = 0.5          # generation cutoffs [m]
    rmax: float = 250.0
    mu: float = 0.0            # log-normal parameters
    sigma: float = 1.0
    trend: float = 0.0         # mean pole trend [deg]
    plunge: float = 0.0        # mean pole plunge [deg], positive downward
    kappa: float = 10.0        # Fisher concentration

    def size_dist(self) -> dict:
        d = {"type": self.dist_type, "rmin": self.rmin, "rmax": self.rmax, "r0": self.r0,
             "kr": self.kr, "mu": self.mu, "sigma": self.sigma}
        return d


def _preset(rows, rmin, rmax):
    out = []
    for name, P32, dtype, kr, r0, trend, plunge, kappa in rows:
        lo = max(rmin, r0) if dtype == "powerlaw" else rmin
        out.append(FractureSet(name, P32, dtype, kr, r0, lo, rmax, 0.0, 1.0, trend, plunge, kappa))
    return out


def preset_sets(site: str, rmin: float = 0.5, rmax: float = 250.0) -> list[FractureSet]:
    """The Forsmark / Laxemar tables of the original script (powerlaw cutoffs rmin = max(rmin, r0))."""
    site = site.lower()
    if site == "forsmark":
        rows = [("Set_1", 0.602, "powerlaw", 2.88, 0.28, 87.2, 1.7, 21.66),
                ("Set_2", 2.069, "powerlaw", 3.02, 0.25, 135.2, 2.7, 21.54),
                ("Set_3", 0.448, "powerlaw", 2.81, 0.14, 40.6, 2.2, 23.90),
                ("Set_4", 0.226, "powerlaw", 2.95, 0.15, 190.4, 0.7, 30.63),
                ("Set_5", 0.605, "powerlaw", 2.92, 0.25, 342.9, 80.3, 8.18)]
    elif site == "laxemar":
        rows = [("Set_1", 1.310, "powerlaw", 2.85, 0.328, 338.1, 4.5, 13.06),
                ("Set_2", 1.026, "powerlaw", 3.04, 0.977, 100.4, 0.2, 19.62),
                ("Set_3", 0.975, "powerlaw", 3.01, 0.858, 212.9, 0.9, 10.46),
                ("Set_4", 2.320, "exponential", 0.0, 4.0, 3.3, 62.1, 10.13),
                ("Set_5", 1.400, "powerlaw", 3.60, 0.400, 243.0, 24.4, 23.52)]
    else:
        raise ValueError(f"unknown site {site!r}; use 'forsmark' or 'laxemar'")
    return _preset(rows, rmin, rmax)


def load_config(path: str | Path, rmin: float = 0.5, rmax: float = 250.0, default_kr: float = 3.0) -> list[FractureSet]:
    """DFN-project JSON config: {"sets": {"1": {"p32_base", "dist_type", "r0", "trend", "plunge",
    "kappa", ["kr"]}}}. kr is optional there (the estimator fills it); default_kr applies if absent."""
    cfg = json.loads(Path(path).read_text(encoding="utf-8"))
    out = []
    for key, s in cfg["sets"].items():
        dtype = s.get("dist_type", "powerlaw")
        r0 = float(s.get("r0", 0.25))
        lo = max(rmin, r0) if dtype == "powerlaw" else rmin
        out.append(FractureSet(f"Set_{key}", float(s["p32_base"]), dtype, float(s.get("kr", default_kr)), r0,
                               lo, rmax, float(s.get("mu", 0.0)), float(s.get("sigma", 1.0)),
                               float(s["trend"]), float(s["plunge"]), float(s["kappa"])))
    return out


# --------------------------------------------------------------------------
# Section 1 of the original: geometry and statistical sampling (verbatim logic)
# --------------------------------------------------------------------------
def mean_pole_vector(trend_deg: float, plunge_deg: float) -> np.ndarray:
    tr, pl = np.radians(trend_deg), np.radians(plunge_deg)
    n = np.array([np.cos(pl) * np.sin(tr), np.cos(pl) * np.cos(tr), -np.sin(pl)])
    return n / np.linalg.norm(n)


def _axis_angle_rotmat(axis, angle):
    x, y, z = axis
    c, s = np.cos(angle), np.sin(angle)
    C = 1.0 - c
    return np.array([[x * x * C + c, x * y * C - z * s, x * z * C + y * s],
                     [y * x * C + z * s, y * y * C + c, y * z * C - x * s],
                     [z * x * C - y * s, z * y * C + x * s, z * z * C + c]])


def sample_fisher_normals(mean_n, kappa, N, seed=None):
    mean_n = mean_n / np.linalg.norm(mean_n)
    rng = np.random.default_rng(seed)
    U = rng.uniform(0.0, 1.0, N)
    phi = 2.0 * np.pi * rng.uniform(0.0, 1.0, N)
    if kappa < 1e-10:
        cosT = 2.0 * U - 1.0
    else:
        cosT = np.clip((1.0 / kappa) * np.log(np.exp(-kappa) + U * (np.exp(kappa) - np.exp(-kappa))), -1.0, 1.0)
    sinT = np.sqrt(np.maximum(0.0, 1.0 - cosT**2))
    v0 = np.column_stack([sinT * np.cos(phi), sinT * np.sin(phi), cosT])
    ez = np.array([0.0, 0.0, 1.0])
    if np.linalg.norm(mean_n - ez) < 1e-12:
        R = np.eye(3)
    elif np.linalg.norm(mean_n + ez) < 1e-12:
        R = np.diag([1.0, -1.0, -1.0])
    else:
        axis = np.cross(ez, mean_n); axis /= np.linalg.norm(axis)
        R = _axis_angle_rotmat(axis, np.arccos(np.dot(ez, mean_n)))
    normals = (R @ v0.T).T
    return normals / np.linalg.norm(normals, axis=1, keepdims=True)


def strike_dip_basis(normals):
    normals = normals / np.linalg.norm(normals, axis=1, keepdims=True)
    ref = np.zeros_like(normals); ref[:, 2] = 1.0
    ref[np.abs(normals[:, 2]) > 0.95] = [1.0, 0.0, 0.0]
    strike_u = np.cross(ref, normals, axis=1); strike_u /= np.linalg.norm(strike_u, axis=1, keepdims=True)
    dip_u = np.cross(normals, strike_u, axis=1); dip_u /= np.linalg.norm(dip_u, axis=1, keepdims=True)
    return strike_u, dip_u


def size_pdf_truncated(r, d: dict):
    rmin, rmax = d["rmin"], d["rmax"]
    r = np.asarray(r, float)
    val = np.zeros_like(r)
    m = (r >= rmin) & (r <= rmax)
    t = d["type"].lower()
    if t == "powerlaw":
        alpha = d["kr"] + 1.0
        C = 1.0 / np.log(rmax / rmin) if abs(alpha - 1.0) < 1e-12 else (1.0 - alpha) / (rmax ** (1.0 - alpha) - rmin ** (1.0 - alpha))
        val[m] = C * r[m] ** (-alpha)
    elif t == "exponential":
        lbl = 1.0 / d["r0"]
        C = lbl / (np.exp(-lbl * rmin) - np.exp(-lbl * rmax))
        val[m] = C * np.exp(-lbl * r[m])
    elif t == "lognormal":
        mu, sig = d["mu"], d["sigma"]
        raw = lambda x: (1.0 / (x * sig * np.sqrt(2.0 * np.pi))) * np.exp(-(np.log(x) - mu) ** 2 / (2.0 * sig**2))  # noqa: E731
        Z, _ = integrate.quad(raw, rmin, rmax)
        val[m] = raw(r[m]) / Z
    elif t == "uniform":
        val[m] = 1.0 / (rmax - rmin)
    else:
        raise ValueError(f"unknown size distribution {d['type']!r}")
    return val


def sample_radius(d: dict, N, seed=None):
    rmin, rmax = d["rmin"], d["rmax"]
    rng = np.random.default_rng(seed)
    U = rng.uniform(0.0, 1.0, N)
    t = d["type"].lower()
    if t == "powerlaw":
        alpha = d["kr"] + 1.0
        if abs(alpha - 1.0) < 1e-12:
            return rmin * (rmax / rmin) ** U
        return (rmin ** (1.0 - alpha) + U * (rmax ** (1.0 - alpha) - rmin ** (1.0 - alpha))) ** (1.0 / (1.0 - alpha))
    if t == "exponential":
        lbl = 1.0 / d["r0"]
        A, B = np.exp(-lbl * rmin), np.exp(-lbl * rmax)
        return -(1.0 / lbl) * np.log(A - U * (A - B))
    if t == "lognormal":
        r = np.zeros(N); cnt = 0
        while cnt < N:
            batch = rng.lognormal(d["mu"], d["sigma"], N)
            valid = batch[(batch >= rmin) & (batch <= rmax)]
            take = min(len(valid), N - cnt)
            if take > 0:
                r[cnt:cnt + take] = valid[:take]; cnt += take
        return r
    if t == "uniform":
        return rmin + (rmax - rmin) * U
    raise ValueError(f"unknown size distribution {d['type']!r}")


def mean_disc_area(d: dict) -> float:
    f = lambda r: np.pi * r**2 * size_pdf_truncated(np.array([r]), d)[0]  # noqa: E731
    return integrate.quad(f, d["rmin"], d["rmax"])[0]


def num_fractures_from_P32(P32: float, d: dict, V: float) -> int:
    return max(0, int(round(V * P32 / mean_disc_area(d))))


def scaled_P32(s: FractureSet) -> float:
    """Rescale the tabulated P32 (radii >= r0) to the generation cutoff rmin."""
    d = s.size_dist()
    if s.dist_type == "powerlaw":
        p = 2.0 - s.kr
        if abs(p) < 1e-12:
            i0, imin = np.log(s.rmax) - np.log(s.r0), np.log(s.rmax) - np.log(s.rmin)
        else:
            i0, imin = (s.rmax**p - s.r0**p) / p, (s.rmax**p - s.rmin**p) / p
        return s.P32 * imin / i0
    if s.dist_type == "exponential":
        lbl = 1.0 / s.r0
        F = lambda r: -np.exp(-lbl * r) * (r**2 + 2 * r / lbl + 2 / lbl**2)  # noqa: E731
        return s.P32 * (F(s.rmax) - F(s.rmin)) / (F(s.rmax) - F(0.0))
    return s.P32


def sample_centers(box: dict, radius, strike_u, dip_u, center_mode="area_uniform", seed=None):
    N = len(radius)
    rng = np.random.default_rng(seed)
    x0, y0, z0 = box.get("x0", 0.0), box.get("y0", 0.0), box.get("z0", 0.0)
    c = np.zeros((N, 3))
    c[:, 0] = x0 + box["dx"] * rng.uniform(0.0, 1.0, N)
    c[:, 1] = y0 + box["dy"] * rng.uniform(0.0, 1.0, N)
    c[:, 2] = z0 + box["dz"] * rng.uniform(0.0, 1.0, N)
    omega = 2.0 * np.pi * rng.uniform(0.0, 1.0, N)
    mode = center_mode.lower()
    if mode == "report":
        rho = radius * rng.uniform(0.0, 1.0, N)
    elif mode == "area_uniform":
        rho = radius * np.sqrt(rng.uniform(0.0, 1.0, N))
    else:
        raise ValueError(f"unknown centerMode {center_mode!r}")
    for k in range(3):
        c[:, k] += rho * (strike_u[:, k] * np.cos(omega) + dip_u[:, k] * np.sin(omega))
    return c


# --------------------------------------------------------------------------
# Generation
# --------------------------------------------------------------------------
@dataclass
class RockMassDFN:
    box: dict
    sets: list[FractureSet]
    centers: np.ndarray       # (N, 3) float32, x East / y North / z Up
    normals: np.ndarray       # (N, 3)
    radii: np.ndarray         # (N,)
    set_id: np.ndarray        # (N,) 1-based
    targets: list[int] = field(default_factory=list)
    scaled_p32: list[float] = field(default_factory=list)
    realized_p32: list[float] = field(default_factory=list)

    @property
    def n(self) -> int:
        return len(self.radii)

    @property
    def volume(self) -> float:
        return self.box["dx"] * self.box["dy"] * self.box["dz"]

    def domain_box(self, margin: float = 5.0) -> np.ndarray:
        lo = self.centers.min(axis=0) - self.radii.max() - margin
        hi = self.centers.max(axis=0) + self.radii.max() + margin
        return np.array([lo[0], hi[0], lo[1], hi[1], lo[2], hi[2]], np.float32)


def generate(sets: list[FractureSet], size: float = 250.0, seed: int | None = None,
             chunk_size: int = 2_000_000, center_mode: str = "area_uniform",
             max_total: int | None = None) -> RockMassDFN:
    """Cube of edge `size` centred at the origin. Seeds follow the original script:
    base = seed + set_index*1000 + chunk*3 for radii, +1 normals, +2 centres."""
    box = {"dx": size, "dy": size, "dz": size, "x0": -size / 2, "y0": -size / 2, "z0": -size / 2}
    V = size**3
    C, Nn, R, S, targets, sp, rp = [], [], [], [], [], [], []
    for i, s in enumerate(sets):
        d = s.size_dist()
        p32 = scaled_P32(s)
        N = num_fractures_from_P32(p32, d, V)
        targets.append(N); sp.append(p32)
        if max_total is not None and sum(targets) > max_total:
            raise ValueError(f"target count {sum(targets):,} exceeds the limit {max_total:,}; "
                             f"reduce the box size or raise rmin")
        if N <= 0:
            rp.append(0.0)
            continue
        mean_n = mean_pole_vector(s.trend, s.plunge)
        cs, ns, rs = [], [], []
        for ch in range(int(np.ceil(N / chunk_size))):
            n_ch = min(chunk_size, N - ch * chunk_size)
            base = None if seed is None else seed + i * 1000 + ch * 3
            r_ch = sample_radius(d, n_ch, seed=base)
            n_ch_ = sample_fisher_normals(mean_n, s.kappa, n_ch, seed=None if base is None else base + 1)
            su, du = strike_dip_basis(n_ch_)
            c_ch = sample_centers(box, r_ch, su, du, center_mode, seed=None if base is None else base + 2)
            cs.append(c_ch); ns.append(n_ch_); rs.append(r_ch)
        c, nrm, r = np.vstack(cs), np.vstack(ns), np.concatenate(rs)
        rp.append(float(np.sum(np.pi * r**2) / V))
        C.append(c); Nn.append(nrm); R.append(r); S.append(np.full(len(r), i + 1, np.uint16))
    if not R:
        empty = np.zeros((0, 3), np.float32)
        return RockMassDFN(box, sets, empty, empty, np.zeros(0, np.float32), np.zeros(0, np.uint16), targets, sp, rp)
    return RockMassDFN(box, sets, np.vstack(C).astype(np.float32), np.vstack(Nn).astype(np.float32),
                       np.concatenate(R).astype(np.float32), np.concatenate(S), targets, sp, rp)


# --------------------------------------------------------------------------
# Clipping, trace maps, orientation density (Section 2.5 of the original)
# --------------------------------------------------------------------------
def disc_polygon(center, normal, radius, n_pts=36):
    normal = normal / np.linalg.norm(normal)
    ref = np.array([0., 0., 1.]) if abs(normal[2]) < 0.95 else np.array([1., 0., 0.])
    u = np.cross(ref, normal); u /= np.linalg.norm(u)
    v = np.cross(normal, u); v /= np.linalg.norm(v)
    a = np.linspace(0, 2 * np.pi, n_pts, endpoint=False)
    return center + radius * (np.outer(np.cos(a), u) + np.outer(np.sin(a), v))


def _clip_halfspace(poly, pt, nrm):
    if not poly:
        return poly
    out = []
    n = len(poly)
    for i in range(n):
        p1, p2 = poly[i], poly[(i + 1) % n]
        d1, d2 = np.dot(p1 - pt, nrm), np.dot(p2 - pt, nrm)
        if d1 >= 0:
            out.append(p1)
            if d2 < 0:
                out.append(p1 + d1 / (d1 - d2) * (p2 - p1))
        elif d2 >= 0:
            out.append(p1 + d1 / (d1 - d2) * (p2 - p1))
    return out


def crop_box_dict(half: float, center=(0.0, 0.0, 0.0)) -> dict:
    cx, cy, cz = center
    return {"xmin": cx - half, "xmax": cx + half, "ymin": cy - half, "ymax": cy + half, "zmin": cz - half, "zmax": cz + half}


def clip_disc(center, normal, radius, cb: dict):
    poly = list(disc_polygon(center, normal, radius))
    planes = [(np.array([cb["xmin"], 0., 0.]), np.array([1., 0., 0.])), (np.array([cb["xmax"], 0., 0.]), np.array([-1., 0., 0.])),
              (np.array([0., cb["ymin"], 0.]), np.array([0., 1., 0.])), (np.array([0., cb["ymax"], 0.]), np.array([0., -1., 0.])),
              (np.array([0., 0., cb["zmin"]]), np.array([0., 0., 1.])), (np.array([0., 0., cb["zmax"]]), np.array([0., 0., -1.]))]
    for pt, nrm in planes:
        poly = _clip_halfspace(poly, pt, nrm)
        if len(poly) < 3:
            return None
    return np.array(poly)


def intersect_poly_plane(poly, dim: int, val: float, tol=1e-8):
    pts = []
    n = len(poly)
    for i in range(n):
        p1, p2 = poly[i], poly[(i + 1) % n]
        v1, v2 = p1[dim], p2[dim]
        if abs(v1 - val) < tol:
            pts.append(p1.copy())
        if (v1 - val) * (v2 - val) < 0:
            pts.append(p1 + (val - v1) / (v2 - v1) * (p2 - p1))
        if abs(v1 - val) < tol and abs(v2 - val) < tol:
            pts.append(p2.copy())
    if len(pts) < 2:
        return None
    keep = [pts[0]]
    for p in pts[1:]:
        if all(np.linalg.norm(p - q) > 1e-7 for q in keep):
            keep.append(p)
    if len(keep) < 2:
        return None
    keep = np.array(keep)
    best, pair = -np.inf, None
    for i in range(len(keep)):
        for j in range(i + 1, len(keep)):
            dd = np.linalg.norm(keep[i] - keep[j])
            if dd > best:
                best, pair = dd, np.array([keep[i], keep[j]])
    return pair


# --------------------------------------------------------------------------
# Batched clipping (vectorised Sutherland-Hodgman on padded polygon arrays).
# clip_disc / _clip_halfspace above are the per-fracture reference kept for the
# oracle tests; the functions below give identical polygons, ~20x faster.
# --------------------------------------------------------------------------
_PLANES = (("xmin", 0, 1.0), ("xmax", 0, -1.0), ("ymin", 1, 1.0), ("ymax", 1, -1.0), ("zmin", 2, 1.0), ("zmax", 2, -1.0))


def disc_polygons(centers, normals, radii, n_pts=36):
    """Batched disc_polygon: (N, n_pts, 3), same vertices as the per-disc version."""
    C = np.asarray(centers, float).reshape(-1, 3)
    Nn = np.asarray(normals, float).reshape(-1, 3)
    R = np.asarray(radii, float).reshape(-1)
    Nn = Nn / np.linalg.norm(Nn, axis=1, keepdims=True)
    ref = np.where((np.abs(Nn[:, 2]) < 0.95)[:, None], np.array([0., 0., 1.]), np.array([1., 0., 0.]))
    u = np.cross(ref, Nn); u /= np.linalg.norm(u, axis=1, keepdims=True)
    v = np.cross(Nn, u); v /= np.linalg.norm(v, axis=1, keepdims=True)
    a = np.linspace(0, 2 * np.pi, n_pts, endpoint=False)
    return C[:, None, :] + R[:, None, None] * (np.cos(a)[None, :, None] * u[:, None, :] + np.sin(a)[None, :, None] * v[:, None, :])


def _clip_halfspace_batch(P, valid, dim, val, sign):
    """One Sutherland-Hodgman step on padded polygons P (N, n, 3); `valid` (N, n) marks the
    vertices, packed at the front of each row. Keeps the side sign * (x[dim] - val) >= 0."""
    N, n, _ = P.shape
    cnt = valid.sum(1)
    d = sign * (P[..., dim] - val)
    nxt = (np.arange(n)[None, :] + 1) % np.maximum(cnt, 1)[:, None]
    P2 = np.take_along_axis(P, nxt[..., None], 1)
    d2 = np.take_along_axis(d, nxt, 1)
    in1, in2 = d >= 0, d2 >= 0
    keep = valid & in1
    cross = valid & (in1 != in2)
    with np.errstate(invalid="ignore", divide="ignore"):
        t = d / (d - d2)
        I = P + t[..., None] * (P2 - P)
    out = np.empty((N, 2 * n, 3)); m = np.zeros((N, 2 * n), bool)
    out[:, 0::2] = P; out[:, 1::2] = np.where(cross[..., None], I, 0.0)
    m[:, 0::2] = keep; m[:, 1::2] = cross
    order = np.argsort(~m, axis=1, kind="stable")          # pack the surviving vertices to the front
    out = np.take_along_axis(out, order[..., None], 1); m = np.take_along_axis(m, order, 1)
    w = int(m.sum(1).max()) if N else 0
    return out[:, :w], m[:, :w]


def _clip_rows(P, cb):
    valid = np.ones(P.shape[:2], bool)
    idx = np.arange(len(P))
    for key, dim, sign in _PLANES:
        if not len(P):
            break
        P, valid = _clip_halfspace_batch(P, valid, dim, cb[key], sign)
        ok = valid.sum(1) >= 3
        P, valid, idx = P[ok], valid[ok], idx[ok]
    return P, valid, idx


def clip_discs(centers, normals, radii, cb: dict, n_pts=36):
    """Batched clip_disc. Returns padded polygons (M, w, 3), their vertex mask (M, w) and a
    boolean `kept` over the input discs (M = kept.sum()); discs entirely inside the box are
    passed through unclipped, exactly as the per-disc clipping would leave them."""
    P = disc_polygons(centers, normals, radii, n_pts)
    if not len(P):
        return np.zeros((0, n_pts, 3)), np.zeros((0, n_pts), bool), np.zeros(0, bool)
    lo, hi = P.min(1), P.max(1)
    inside = ((lo[:, 0] >= cb["xmin"]) & (hi[:, 0] <= cb["xmax"]) & (lo[:, 1] >= cb["ymin"]) & (hi[:, 1] <= cb["ymax"])
              & (lo[:, 2] >= cb["zmin"]) & (hi[:, 2] <= cb["zmax"]))
    Pc, vc, ic = _clip_rows(P[~inside], cb)
    ci = np.flatnonzero(~inside)[ic]
    w = max(n_pts, Pc.shape[1])
    out = np.zeros((len(P), w, 3)); valid = np.zeros((len(P), w), bool)
    out[inside, :n_pts] = P[inside]; valid[inside, :n_pts] = True
    out[ci, :Pc.shape[1]] = Pc; valid[ci, :vc.shape[1]] = vc
    kept = inside.copy(); kept[ci] = True
    return out[kept], valid[kept], kept


def polygon_areas(P, valid):
    """Area of each padded polygon (centroid fan, as the per-polygon sum)."""
    cnt = valid.sum(1)
    cen = np.where(valid[..., None], P, 0.0).sum(1) / np.maximum(cnt, 1)[:, None]
    nxt = (np.arange(P.shape[1])[None, :] + 1) % np.maximum(cnt, 1)[:, None]
    P2 = np.take_along_axis(P, nxt[..., None], 1)
    tri = 0.5 * np.linalg.norm(np.cross(P - cen[:, None], P2 - cen[:, None]), axis=2)
    return np.where(valid, tri, 0.0).sum(1)


def _candidates(dfn: RockMassDFN, cb: dict):
    c, r = dfn.centers, dfn.radii
    return ((c[:, 0] - r <= cb["xmax"]) & (c[:, 0] + r >= cb["xmin"]) & (c[:, 1] - r <= cb["ymax"]) & (c[:, 1] + r >= cb["ymin"])
            & (c[:, 2] - r <= cb["zmax"]) & (c[:, 2] + r >= cb["zmin"]))


@dataclass
class ClippedDFN:
    polygons: list[np.ndarray]
    set_id: np.ndarray
    total_area: float
    p32: float
    index: np.ndarray = field(default_factory=lambda: np.zeros(0, int))   # fracture index in the RockMassDFN
    areas: np.ndarray = field(default_factory=lambda: np.zeros(0))
    lower: np.ndarray = field(default_factory=lambda: np.zeros((0, 3)))   # per-polygon bounding boxes
    upper: np.ndarray = field(default_factory=lambda: np.zeros((0, 3)))
    volume: float = 0.0

    def subset(self, mask) -> "ClippedDFN":
        mask = np.asarray(mask, bool)
        area = float(self.areas[mask].sum())
        return ClippedDFN([p for p, m in zip(self.polygons, mask) if m], self.set_id[mask], area,
                          area / self.volume if self.volume > 0 else 0.0, self.index[mask], self.areas[mask],
                          self.lower[mask], self.upper[mask], self.volume)


def clip_to_crop_box(dfn: RockMassDFN, cb: dict, tunnel_poly_yz: np.ndarray | None = None,
                     chunk: int = 50_000) -> ClippedDFN:
    """Discs clipped to the crop box; optionally only those touching the tunnel polygon
    (given in the y-z plane, as the tunnel axis is x)."""
    idx = np.flatnonzero(_candidates(dfn, cb))
    polys, index, areas, lower, upper = [], [], [], [], []
    for s in range(0, len(idx), chunk):
        ii = idx[s:s + chunk]
        P, valid, kept = clip_discs(dfn.centers[ii], dfn.normals[ii], dfn.radii[ii], cb)
        cnt = valid.sum(1)
        polys.extend(P[k, :cnt[k]] for k in range(len(P)))
        index.append(ii[kept]); areas.append(polygon_areas(P, valid))
        lower.append(np.where(valid[..., None], P, np.inf).min(1)); upper.append(np.where(valid[..., None], P, -np.inf).max(1))
    V = (cb["xmax"] - cb["xmin"]) * (cb["ymax"] - cb["ymin"]) * (cb["zmax"] - cb["zmin"])
    index = np.concatenate(index) if index else np.zeros(0, int)
    areas = np.concatenate(areas) if areas else np.zeros(0)
    lower = np.concatenate(lower) if lower else np.zeros((0, 3))
    upper = np.concatenate(upper) if upper else np.zeros((0, 3))
    area = float(areas.sum())
    out = ClippedDFN(polys, dfn.set_id[index].astype(int), area, area / V if V > 0 else 0.0, index, areas, lower, upper, V)
    return out if tunnel_poly_yz is None else tunnel_subset(out, tunnel_poly_yz)


def tunnel_subset(clipped: ClippedDFN, tunnel_poly_yz: np.ndarray) -> ClippedDFN:
    """Clipped fractures with at least one vertex inside the tunnel polygon (y-z plane)."""
    if not clipped.polygons:
        return clipped
    from matplotlib.path import Path as MplPath
    counts = np.array([len(p) for p in clipped.polygons])
    flags = MplPath(tunnel_poly_yz).contains_points(np.concatenate(clipped.polygons)[:, 1:3])
    starts = np.concatenate([[0], np.cumsum(counts)[:-1]])
    return clipped.subset(np.logical_or.reduceat(flags, starts))


@dataclass
class TraceMap:
    axis: str
    value: float
    segments: list[np.ndarray]     # (2, 3) each
    set_id: np.ndarray
    total_length: float
    p21: float
    h_index: int                   # which coordinates to plot: horizontal / vertical
    v_index: int


def trace_map(src: RockMassDFN | ClippedDFN, cb: dict, axis: str = "x", value: float = 0.0) -> TraceMap:
    """Traces of the clipped fractures on the plane axis = value. `src` may be the clipped
    result of clip_to_crop_box(dfn, cb) (reused across the three trace maps) or the DFN itself."""
    clipped = src if isinstance(src, ClippedDFN) else clip_to_crop_box(src, cb)
    dim = "xyz".index(axis)
    h, v = {0: (1, 2), 1: (0, 2), 2: (0, 1)}[dim]
    cand = np.flatnonzero((clipped.lower[:, dim] - 1e-8 <= value) & (clipped.upper[:, dim] + 1e-8 >= value))
    segs, sids, L = [], [], 0.0
    for i in cand:
        seg = intersect_poly_plane(clipped.polygons[i], dim, value)
        if seg is not None:
            segs.append(seg); sids.append(int(clipped.set_id[i])); L += float(np.linalg.norm(seg[0] - seg[1]))
    lo = [cb["xmin"], cb["ymin"], cb["zmin"]]; hi = [cb["xmax"], cb["ymax"], cb["zmax"]]
    A = (hi[h] - lo[h]) * (hi[v] - lo[v])
    return TraceMap(axis, value, segs, np.array(sids, int), L, L / A if A > 0 else 0.0, h, v)


def pole_density_equal_angle(normals: np.ndarray, bins: int = 80, sigma: float = 2.0):
    """Lower-hemisphere equal-angle projection density of the fracture normals
    (validation stereonet of the original). Returns (X, Y, density with NaN outside)."""
    from scipy.ndimage import gaussian_filter
    n = np.asarray(normals, float).copy()
    n[n[:, 2] > 0] *= -1
    X = n[:, 0] / (1.0 - n[:, 2]); Y = n[:, 1] / (1.0 - n[:, 2])
    counts, xe, ye = np.histogram2d(X, Y, bins=bins, range=[[-1.0, 1.0], [-1.0, 1.0]])
    dens = gaussian_filter(counts, sigma=sigma)
    GX, GY = np.meshgrid(0.5 * (xe[:-1] + xe[1:]), 0.5 * (ye[:-1] + ye[1:]))
    dens = dens.T
    dens[~(GX**2 + GY**2 <= 1.0)] = np.nan
    return GX, GY, dens


def mean_pole_projection(s: FractureSet):
    n = mean_pole_vector(s.trend, s.plunge)
    if n[2] > 0:
        n = -n
    return n[0] / (1.0 - n[2]), n[1] / (1.0 - n[2])


def size_histogram_loglog(radii: np.ndarray, rmin: float = 1.0, rmax: float = 250.0, bins: int = 50):
    r = radii[(radii > rmin) & (radii < rmax)]
    if len(r) == 0:
        return np.array([]), np.array([])
    counts, edges = np.histogram(np.log10(r), bins=bins)
    c = 0.5 * (edges[:-1] + edges[1:])
    ok = counts > 0
    return c[ok], np.log10(counts[ok])


# --------------------------------------------------------------------------
# Tunnel polygon and export
# --------------------------------------------------------------------------
def read_tunnel_polygon(path: str | Path, z_shift: float = -4.0) -> np.ndarray:
    """'X= .. Y= ..' lines in mm -> closed (n+1, 2) polygon in metres, shifted like the original."""
    xs, ys = [], []
    for line in Path(path).read_text(encoding="utf-8", errors="replace").splitlines():
        line = line.strip()
        if line.startswith("X="):
            m = re.search(r"X=\s*([-\d.]+)\s*Y=\s*([-\d.]+)", line)
            if m:
                xs.append(float(m.group(1))); ys.append(float(m.group(2)))
    if not xs:
        raise ValueError(f"no coordinates parsed from {path}")
    poly = np.column_stack([xs, ys]) / 1000.0
    poly[:, 1] += z_shift
    return np.vstack([poly, poly[0]]).astype(np.float32)


def export_hdf5(dfn: RockMassDFN, path: str | Path, rmin: float, rmax: float, site: str = "custom",
                crop_half: float = 25.0, tunnel_poly_yz: np.ndarray | None = None, p32_label: str | None = None) -> None:
    """HDF5 layout of the DFN project (/fractures, /tunnel, /meta)."""
    import h5py
    label = p32_label or f"P32_r_ge_{str(rmin).replace('.', 'p')}m"
    crop = np.array([-crop_half, crop_half, -crop_half, crop_half, -crop_half, crop_half], np.float32)
    with h5py.File(path, "w") as f:
        f.create_dataset("/fractures/centers", data=dfn.centers, dtype=np.float32)
        f.create_dataset("/fractures/normals", data=dfn.normals, dtype=np.float32)
        f.create_dataset("/fractures/radii", data=dfn.radii.reshape(-1, 1), dtype=np.float32)
        f.create_dataset("/fractures/set_id", data=dfn.set_id.reshape(-1, 1), dtype=np.uint16)
        if tunnel_poly_yz is not None:
            f.create_dataset("/tunnel/poly_YZ", data=tunnel_poly_yz, dtype=np.float32)
            f.create_dataset("/tunnel/profile_Y", data=tunnel_poly_yz[:, 0], dtype=np.float32)
            f.create_dataset("/tunnel/profile_Z", data=tunnel_poly_yz[:, 1], dtype=np.float32)
        f.create_dataset("/meta/domain_box", data=dfn.domain_box().reshape(1, 6), dtype=np.float32)
        f.create_dataset("/meta/crop_box", data=crop.reshape(1, 6), dtype=np.float32)
        f.create_dataset("/meta/generation_rmin", data=np.array([rmin], np.float32))
        f.create_dataset("/meta/generation_rmax", data=np.array([rmax], np.float32))
        f.create_dataset("/meta/set_ids", data=np.arange(1, len(dfn.sets) + 1, dtype=np.int32))
        f.create_dataset("/meta/set_table_r0", data=np.array([s.r0 for s in dfn.sets], np.float32))
        f.create_dataset("/meta/set_generation_rmin", data=np.array([s.rmin for s in dfn.sets], np.float32))
        f.create_dataset("/meta/set_effective_rmin", data=np.array([s.rmin for s in dfn.sets], np.float32))
        f.create_dataset("/meta/p32_label", data=np.bytes_(label))
        f.create_dataset("/meta/site", data=np.bytes_(site))
        f.create_dataset("/meta/powerlaw_pdf_convention", data=np.bytes_("f_R(r) proportional to r^-(kr+1)"))
        f.create_dataset("/meta/powerlaw_survival_convention", data=np.bytes_("S_R(r) proportional to r^-kr"))
        f.create_dataset("/meta/kr_parameter_interpretation", data=np.bytes_("survival exponent"))
        f.attrs["created_by"] = "geomech.core.dfn_rockmass"
        f.attrs["num_fractures"] = dfn.n


def export_csv(dfn: RockMassDFN, path: str | Path) -> None:
    """x y z nx ny nz radius set_id, one fracture per line."""
    data = np.column_stack([dfn.centers, dfn.normals, dfn.radii, dfn.set_id])
    np.savetxt(path, data, fmt=["%.5f"] * 7 + ["%d"], delimiter="\t",
               header="x_east\ty_north\tz_up\tnx\tny\tnz\tradius\tset_id", comments="")
