"""Stereographic projection of joint orientations - port of stereoProjection.m and its
helpers convert_TPCoor.m, convert_VecTP.m, wulffCircle.m, wulffNet.m, schmidtNet.m,
roseDiagram.m, fcm_new.m / stepfcm_new.m / distfcm_new.m / initfcm.m, dist3.m.

Conventions (as in the MATLAB code):
* a plane is given by dip and dip direction (degrees); its pole has trend = dip
  direction + 180 deg and plunge = 90 deg - dip;
* projection coordinates: x to the East, y to the North; a pole with trend `tre`
  and plunge `plu` maps to (cos(pi/2 - tre), sin(pi/2 - tre)) * r(plu) on the
  lower hemisphere (mirrored for the upper hemisphere), with
  r = tan(pi/4 - plu/2) (equal angle, Wulff) or sqrt(2) cos(pi/4 + plu/2)
  (equal area, Schmidt);
* the unit vector of a pole is (cos(plu) cos(tre), cos(plu) sin(tre), sin(plu)).

All angles inside this module are radians unless the name ends in _deg.
"""
from __future__ import annotations

from dataclasses import dataclass

import numpy as np

SQRT2 = 1.41421356   # the MATLAB code uses this 8-digit constant


# --------------------------------------------------------------------------
# Coordinate conversions
# --------------------------------------------------------------------------
def poles(dip_deg, dipdir_deg):
    """Plane (dip, dip direction) [deg] -> pole (trend, plunge) [rad] (polePlot_Callback)."""
    dip, dd = np.asarray(dip_deg, float), np.asarray(dipdir_deg, float)
    return np.deg2rad(dd) + np.pi, 0.5 * np.pi - np.deg2rad(dip)


def project(tre, plu, upper: bool, equal_angle: bool):
    """convert_TPCoor.m"""
    tre, plu = np.asarray(tre, float), np.asarray(plu, float)
    if equal_angle:
        r = np.tan(0.25 * np.pi - 0.5 * plu)
    else:
        r = SQRT2 * np.cos(0.25 * np.pi + 0.5 * plu)
    x = np.cos(0.5 * np.pi - tre) * r
    y = np.sin(0.5 * np.pi - tre) * r
    return (-x, -y) if upper else (x, y)


def unproject(x: float, y: float, upper: bool, equal_angle: bool) -> tuple[float, float]:
    """Projection point -> plane (dip, dip direction) [rad] (showCircle_Callback inverse).

    The MATLAB callback ignores the hemisphere here although project() mirrors the
    point for the upper hemisphere, so clicked poles on upper-hemisphere plots were
    labelled with the dip direction off by 180 degrees; the mirror is applied here."""
    if upper:
        x, y = -x, -y
    rr = np.sqrt(x**2 + y**2)
    if equal_angle:
        plu = np.pi / 2 - 2 * np.arctan(rr)
    else:
        plu = -np.pi / 2 + 2 * np.arccos(min(np.sqrt(rr**2 / 2), 1.0))
    if plu == np.pi / 2:
        tre = -np.pi
    elif x == 0:
        tre = 0.0 if y > 0 else np.pi
    elif y == 0:
        tre = np.pi / 2 if x > 0 else 3 * np.pi / 2
    else:
        tre = np.pi / 2 - np.arctan(y / x) if x > 0 else -np.pi / 2 - np.arctan(y / x)
    di = np.pi / 2 - plu
    did = tre - np.pi
    if did < 0:
        did += 2 * np.pi
    return float(di), float(did)


def vec_to_trend_plunge(x, y, z):
    """convert_VecTP.m (vectorised)."""
    x, y, z = (np.atleast_1d(np.asarray(v, float)) for v in (x, y, z))
    tre = np.where(x == 0, np.where(y > 0, 0.0, np.pi),
                   np.where(y == 0, np.where(x > 0, np.pi / 2, 3 * np.pi / 2),
                            np.where(x < 0, np.arctan(np.divide(y, x, out=np.zeros_like(y), where=x != 0)) + np.pi,
                                     np.arctan(np.divide(y, x, out=np.zeros_like(y), where=x != 0)))))
    plu = np.arcsin(np.clip(z, -1, 1))
    neg = plu < 0
    tre = np.where(neg, np.where(tre >= np.pi, tre - np.pi, tre + np.pi), tre)
    plu = np.where(neg, -plu, plu)
    return tre, plu


def pole_vectors(dip_deg, dipdir_deg) -> np.ndarray:
    """Unit pole vectors as used by the contour / clustering / mean-direction code
    (trend wrapped to [0, 360), plunge wrapped by +360 when negative)."""
    dip, dd = np.atleast_1d(np.asarray(dip_deg, float)), np.atleast_1d(np.asarray(dipdir_deg, float))
    tre = np.where(dd + 180 >= 360, dd + 180 - 360, dd + 180)
    plu = np.where(90 - dip < 0, 90 - dip + 360, 90 - dip)
    t, p = np.deg2rad(tre), np.deg2rad(plu)
    return np.column_stack([np.cos(p) * np.cos(t), np.cos(p) * np.sin(t), np.sin(p)])


# --------------------------------------------------------------------------
# Great circles and nets
# --------------------------------------------------------------------------
def great_circle(dip: float, dipdir: float, upper: bool, equal_angle: bool = True, N: int = 50):
    """wulffCircle.m. The MATLAB function always uses the equal-angle radius even on
    equal-area plots; pass equal_angle=False for the correct Schmidt-net circle."""
    psi = np.linspace(0, np.pi, N + 1)
    adi = np.arctan(np.tan(dip) * np.sin(psi))
    r = np.tan((np.pi / 2 - adi) / 2) if equal_angle else np.sqrt(2) * np.sin((np.pi / 2 - adi) / 2)
    x = r * (np.sin(psi) * np.sin(dipdir) + np.cos(psi) * (-np.cos(dipdir)))
    y = r * (np.sin(psi) * np.cos(dipdir) + np.cos(psi) * np.sin(dipdir))
    return (-x, -y) if upper else (x, y)


def net_lines(did: float, equal_angle: bool, N: int = 50) -> list[tuple[np.ndarray, np.ndarray]]:
    """Polylines of the Wulff (equal_angle) or Schmidt net rotated to dip direction did."""
    out = []
    out.append((np.array([-1, 1]) * np.sin(did), np.array([-1, 1]) * np.cos(did)))
    out.append((np.array([-1, 1]) * np.cos(-did), np.array([-1, 1]) * np.sin(-did)))
    t = np.linspace(0, 2 * np.pi, 2 * N + 1)
    out.append((np.cos(t), np.sin(t)))
    psi = np.linspace(0, np.pi, N + 1)
    for i in range(1, 9):
        di = i * np.pi / 18
        adi = np.arctan(np.tan(di) * np.sin(psi))
        r = np.tan((np.pi / 2 - adi) / 2) if equal_angle else np.sqrt(2) * np.sin((np.pi / 2 - adi) / 2)
        x1 = r * (np.sin(psi) * np.sin(did) + np.cos(psi) * (-np.cos(did)))
        y1 = r * (np.sin(psi) * np.cos(did) + np.cos(psi) * np.sin(did))
        out.append((x1, y1)); out.append((-x1, -y1))
    for i in range(1, 9):
        alpha = i * np.pi / 18
        xl = np.sin(alpha)
        if equal_angle:
            x = np.arange(-xl, xl + xl / 50, xl / 25)
            d = 1 / np.cos(alpha)
            rd = d * np.sin(alpha)
            y0 = np.sqrt(np.maximum(rd * rd - x * x, 0.0))
            y1 = d - y0
            X = x * np.sin(did) + y1 * (-np.cos(did))
            Y = x * np.cos(did) + y1 * np.sin(did)
        else:
            yl = np.cos(alpha)
            x = np.arange(-xl, xl + xl / 100, xl / 50)
            psi2 = np.arctan(x / yl)
            r = np.sqrt(1 - np.abs(np.sqrt(np.maximum(1 - yl**2 - x * x, 0.0))))
            X = r * np.sin(psi2) * np.sin(did) + r * np.cos(psi2) * (-np.cos(did))
            Y = r * np.sin(psi2) * np.cos(did) + r * np.cos(psi2) * np.sin(did)
        out.append((X, Y)); out.append((-X, -Y))
    return out


# --------------------------------------------------------------------------
# Rose diagram of strikes (roseDiagram.m)
# --------------------------------------------------------------------------
def strike_angles(dipdir_deg) -> np.ndarray:
    """Both strike directions of every plane, as angles in the MATLAB 'rose' convention
    theta = (90 - strike) [rad] (counter-clockwise from East)."""
    dd = np.array(dipdir_deg, dtype=float)
    on_grid = np.mod(dd, 10) == 0
    dd = np.where(on_grid, np.where(dd == 360, dd - 359.999, dd + 0.001), dd)
    s1 = np.where((dd >= 270) & (dd < 360), dd - 90, np.where((dd >= 0) & (dd < 90), dd + 90, dd + 90))
    s2 = np.where((dd >= 270) & (dd < 360), dd - 270, np.where((dd >= 0) & (dd < 90), dd + 270, dd - 90))
    strike = np.empty(2 * dd.size)
    strike[0::2], strike[1::2] = s1, s2
    return np.deg2rad(90 - strike)


def rose_histogram(dipdir_deg, nbins: int = 36):
    """Bin counts and bin edges [rad] of the strike rose (MATLAB rose(theta, 36))."""
    theta = np.mod(strike_angles(dipdir_deg), 2 * np.pi)
    edges = np.arange(nbins + 1) * 2 * np.pi / nbins
    counts, _ = np.histogram(theta, bins=edges)
    return counts, edges


# --------------------------------------------------------------------------
# Pole density contour (contour_Callback)
# --------------------------------------------------------------------------
def pole_density(dip_deg, dipdir_deg, upper: bool, equal_angle: bool, r1: int = 50, r2: int = 100):
    """Percentage of poles within a 1 %-area counting circle on an (r2 x r1) grid of
    (trend, plunge); returns projected x, y and the density (r2, r1)."""
    v = pole_vectors(dip_deg, dipdir_deg)
    vec = np.vstack([v, -v])
    n = len(v)
    theta = np.arccos(99 / 100)
    i = np.arange(r1)[None, :]; j = np.arange(r2)[:, None]
    plu = i * np.pi / 2 / (r1 - 1); tre = j * 2 * np.pi / (r2 - 1)
    g = np.stack([np.cos(plu) * np.cos(tre), np.cos(plu) * np.sin(tre), np.broadcast_to(np.sin(plu), (r2, r1))], -1)
    # |g - v| <= 2 sin(theta/2)  <=>  g . v >= cos(theta) for unit vectors: one matrix product
    # instead of the (r2, r1, 2n, 3) distance array of the literal port
    result = (g.reshape(-1, 3) @ vec.T >= np.cos(theta)).sum(-1).reshape(r2, r1) / n * 100
    x, y = project(np.broadcast_to(tre, (r2, r1)), np.broadcast_to(plu, (r2, r1)), upper, equal_angle)
    return x, y, result


# --------------------------------------------------------------------------
# Designated set: mean direction inside a trend/plunge window (meanDButton_Callback)
# --------------------------------------------------------------------------
@dataclass
class SetWindow:
    outline: list[tuple[np.ndarray, np.ndarray]]   # polylines in projection coordinates
    mean_vec: np.ndarray | None                    # unit vector or None ('No data')
    mean_dip_deg: float | None
    mean_dipdir_deg: float | None
    n_members: int


def designate_set(dip_deg, dipdir_deg, tre_from: float, tre_to: float, plu_from: float, plu_to: float,
                  upper: bool, equal_angle: bool) -> SetWindow:
    """Window bounds in radians. A window crossing the horizon is given with plu_from < 0
    (its 'negative plunge' part is taken on the opposite side of the net)."""
    dip, dd = np.atleast_1d(np.asarray(dip_deg, float)), np.atleast_1d(np.asarray(dipdir_deg, float))
    theta = np.arange(tre_from, tre_to + 1e-12, 1 / 1000) if tre_from < tre_to else np.arange(tre_from - 2 * np.pi, tre_to + 1e-12, 1 / 1000)
    outline = []
    pr = lambda t, p: project(t, p, upper, equal_angle)  # noqa: E731
    tre = np.deg2rad(dd) + np.pi
    plu = np.pi / 2 - np.deg2rad(dip)
    plu = np.where(plu < 0, plu + 2 * np.pi, plu)
    tmp = []
    if plu_from < 0:
        for t in (tre_from, tre_to):
            outline.append(pr(np.array([t - np.pi, t - np.pi]), np.array([-plu_from, 0.0])))
            outline.append(pr(np.array([t, t]), np.array([plu_to, 0.0])))
        outline.append(pr(theta - np.pi, np.full_like(theta, -plu_from)))
        outline.append(pr(theta - np.pi, np.zeros_like(theta)))
        outline.append(pr(theta, np.full_like(theta, plu_to)))
        outline.append(pr(theta, np.zeros_like(theta)))
        tre_w = np.where(tre >= 2 * np.pi, tre - 2 * np.pi, tre)
        tre_sym = np.where(tre_w >= np.pi, tre_w - np.pi, tre_w + np.pi)
        for t, ts, p in zip(tre_w, tre_sym, plu):
            in_t = (tre_from <= t <= tre_to) if tre_from < tre_to else (tre_from <= t or t <= tre_to)
            in_s = (tre_from <= ts <= tre_to) if tre_from < tre_to else (tre_from <= ts or ts <= tre_to)
            v = np.array([np.cos(p) * np.cos(t), np.cos(p) * np.sin(t), np.sin(p)])
            if in_t and p <= plu_to:
                tmp.append(v)
            elif in_s and p <= -plu_from:
                tmp.append(-v)
        avg = np.mean(tmp, axis=0) if tmp else np.full(3, np.nan)
        if tmp:
            avg = avg / np.linalg.norm(avg)
    else:
        for t in (tre_from, tre_to):
            outline.append(pr(np.array([t, t]), np.array([plu_from, plu_to])))
        outline.append(pr(theta, np.full_like(theta, plu_from)))
        outline.append(pr(theta, np.full_like(theta, plu_to)))
        tre_w = np.where(tre > 2 * np.pi, tre - 2 * np.pi, tre)
        for t, p in zip(tre_w, plu):
            in_t = (tre_from <= t <= tre_to) if tre_from < tre_to else (tre_from <= t or t <= tre_to)
            if in_t and plu_from <= p <= plu_to:
                tmp.append(np.array([np.cos(p) * np.cos(t), np.cos(p) * np.sin(t), np.sin(p)]))
        if len(tmp) == 1:
            avg = tmp[0]
        elif tmp:
            avg = np.mean(tmp, axis=0); avg = avg / np.linalg.norm(avg)
        else:
            avg = np.full(3, np.nan)
    if np.isnan(avg).any():
        return SetWindow(outline, None, None, None, 0)
    t_avg, p_avg = vec_to_trend_plunge(*avg)
    di = np.pi / 2 - p_avg[0]
    did = t_avg[0] - np.pi
    if did < 0:
        did += 2 * np.pi
    return SetWindow(outline, avg, float(np.rad2deg(di)), float(np.rad2deg(did)), len(tmp))


# --------------------------------------------------------------------------
# Fuzzy c-means with antipodal symmetry (fcm_new / stepfcm_new / distfcm_new)
# --------------------------------------------------------------------------
def _distfcm(center: np.ndarray, data: np.ndarray) -> np.ndarray:
    d1 = np.sqrt(((data[None, :, :] - center[:, None, :]) ** 2).sum(-1))
    d2 = np.sqrt(((-data[None, :, :] - center[:, None, :]) ** 2).sum(-1))
    return np.minimum(d1, d2)


def stepfcm(data: np.ndarray, U: np.ndarray, expo: float = 2.0):
    mf = U**expo
    center = (mf @ data) / mf.sum(axis=1, keepdims=True)
    dist = _distfcm(center, data)
    obj = float(((dist**2) * mf).sum())
    with np.errstate(divide="ignore"):
        tmp = dist ** (-2 / (expo - 1))
    U_new = tmp / tmp.sum(axis=0, keepdims=True)
    return U_new, center, obj


def fcm(data: np.ndarray, cluster_n: int, expo: float = 2.0, max_iter: int = 100, min_impro: float = 1e-5,
        U0: np.ndarray | None = None, rng: np.random.Generator | None = None):
    """Returns (center, U, obj_fcn). U0 replaces the random initial partition (initfcm)."""
    data = np.asarray(data, float)
    if U0 is None:
        rng = np.random.default_rng() if rng is None else rng
        U = rng.random((cluster_n, len(data)))
        U = U / U.sum(axis=0, keepdims=True)
    else:
        U = np.asarray(U0, float)
    obj = []
    center = None
    for i in range(max_iter):
        U, center, o = stepfcm(data, U, expo)
        obj.append(o)
        if i > 0 and abs(obj[i] - obj[i - 1]) < min_impro:
            break
    return center, U, np.array(obj)


@dataclass
class Cluster:
    members: np.ndarray          # indices into the input planes
    center_vec: np.ndarray
    dip_deg: float
    dipdir_deg: float


def cluster_poles(dip_deg, dipdir_deg, n: int, seed: int | None = None) -> list[Cluster]:
    """FCM_Callback: FCM into n sets, then each set's centre is the (antipode-aware)
    mean of its members (fcm with one cluster == plain mean)."""
    data = pole_vectors(dip_deg, dipdir_deg)
    rng = np.random.default_rng(seed)
    _, U, _ = fcm(data, n, rng=rng)
    maxU = U.max(axis=0)
    out = []
    for i in range(n):
        idx = np.flatnonzero(U[i] == maxU)
        if idx.size == 0:
            continue
        c, _, _ = fcm(data[idx], 1)
        t, p = vec_to_trend_plunge(*c[0])
        di, did = np.pi / 2 - p[0], t[0] - np.pi
        if did < 0:
            did += 2 * np.pi
        out.append(Cluster(idx, c[0], float(np.rad2deg(di)), float(np.rad2deg(did))))
    return out


# --------------------------------------------------------------------------
# Data files
# --------------------------------------------------------------------------
def load_dip_file(path) -> np.ndarray:
    """'Import dip/dipDirec': header line then 'dip<TAB>dip direction' rows."""
    rows = []
    with open(path, encoding="utf-8", errors="replace") as fh:
        next(fh)
        for line in fh:
            parts = line.split()
            if len(parts) >= 2:
                try:
                    rows.append([float(parts[0]), float(parts[1])])
                except ValueError:
                    continue
    return np.array(rows, float).reshape(-1, 2)
