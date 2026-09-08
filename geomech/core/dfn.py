"""3-D discrete fracture network generation - port of threeddfngui.m.

Fractures are circular (200-vertex polygons) or square discs with

* centres uniformly distributed in a box of size (x0, y0, z0) around
  (domx, domy, -domz);
* normals following a Fisher distribution (concentration K) around the mean
  (dip, dip direction);
* diameters from a negative-exponential (mean l) or a truncated power law
  (exponent fracd between trim and curt);
* apertures from a negative-exponential, normal, log-normal or uniform law.

Random numbers are drawn from numpy's legacy Mersenne Twister in exactly the
order the MATLAB loop consumes rand(), so ``generate(..., seed=s)`` reproduces
the MATLAB realisation obtained after ``rng(s, 'twister')`` for the uniform-based
choices (MATLAB's normrnd needs the Statistics toolbox and differs anyway).

Also ported: sampling-window traces (swplot / swslider), drillhole intersection
classification and export (drillclassify / drillsave), and the distribution
verification statistics (verification).
"""
from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path

import numpy as np

SIZE_MODELS = ("Negative exponential", "Power law")
APERTURE_MODELS = ("Negative exponential", "Normal", "Log normal", "Uniform")
SHAPES = ("Circle", "Square")


@dataclass(frozen=True)
class DFNParams:
    n: int = 100
    x0: float = 10.0          # domain size [m]
    y0: float = 10.0
    z0: float = 10.0
    domx: float = 0.0         # domain centre (z is measured downward: centre at -domz)
    domy: float = 0.0
    domz: float = 5.0
    shape: str = "Circle"
    dip: float = 45.0         # mean orientation [deg]
    dipdir: float = 90.0
    K: float = 20.0           # Fisher concentration
    size_model: str = "Negative exponential"
    mean_len: float = 2.0     # negative-exponential mean diameter [m]
    fracd: float = 2.5        # power-law exponent
    trim: float = 0.5         # power-law lower bound [m]
    curt: float = 10.0        # power-law upper bound [m]
    aperture_model: str = "Negative exponential"
    ap_mean: float = 100.0    # [um]
    ap_std: float = 20.0

    def power_law_count(self) -> int:
        """checkfnum_Callback: n = round(x0 y0 z0 (trim^-D - curt^-D))."""
        return int(round(self.x0 * self.y0 * self.z0 * (self.trim ** -self.fracd - self.curt ** -self.fracd)))


def _rotx(a: float) -> np.ndarray:
    return np.array([[1, 0, 0], [0, np.cos(a), -np.sin(a)], [0, np.sin(a), np.cos(a)]])


def _rotz(a: float) -> np.ndarray:
    return np.array([[np.cos(a), -np.sin(a), 0], [np.sin(a), np.cos(a), 0], [0, 0, 1]])


@dataclass
class DFN:
    params: DFNParams
    centers: np.ndarray        # (n, 3)
    length: np.ndarray         # diameter / side [m]
    aperture: np.ndarray       # [um]
    rfk: np.ndarray            # Fisher deviation angle [rad]
    normals: np.ndarray        # (n, 3) unit normals Pf (before the sign flip)
    dip2: np.ndarray           # circle discs only [rad]
    dipd2: np.ndarray
    polygons: list[np.ndarray] # (200, 3) circles or (4, 3) squares, world coordinates
    K2: float                  # Fisher K estimated from the realisation
    rotations: list[tuple] = field(default_factory=list)   # (rotx2, rotz2, rotx3, rotz3, P2) per disc

    @property
    def n(self) -> int:
        return len(self.length)

    def table(self) -> np.ndarray:
        """(n, 5): X Y Z Dip Dip-direction [deg] as written by drillsave."""
        return np.column_stack([self.centers, np.rad2deg(self.dip2), np.rad2deg(self.dipd2)])


def generate(p: DFNParams, seed: int | None = None, rng: np.random.RandomState | None = None) -> DFN:
    rs = rng if rng is not None else np.random.RandomState(seed)
    rand = rs.rand
    dip, dipd = np.deg2rad(p.dip), np.deg2rad(p.dipdir)
    rotx, rotz = _rotx(-dip), _rotz(-dipd)
    n = p.n
    centers = np.zeros((n, 3)); length = np.zeros(n); ap = np.zeros(n); rfk = np.zeros(n)
    Pf = np.zeros((n, 3)); dip2 = np.zeros(n); dipd2 = np.zeros(n)
    polys: list[np.ndarray] = []; rots = []
    for z in range(n):
        centers[z] = [p.domx + p.x0 * rand() - p.x0 / 2, p.domy + p.y0 * rand() - p.y0 / 2,
                      -p.domz + p.z0 * rand() - p.z0 / 2]
        if p.size_model == "Negative exponential":
            length[z] = -np.log(1 - rand()) * p.mean_len
        else:
            length[z] = (p.trim ** -p.fracd - (p.trim ** -p.fracd - p.curt ** -p.fracd) * rand()) ** (-1 / p.fracd)
        if p.aperture_model == "Negative exponential":
            ap[z] = -np.log(1 - rand()) * p.ap_mean
        elif p.aperture_model == "Normal":
            ap[z] = p.ap_mean + p.ap_std * rs.randn()
        elif p.aperture_model == "Log normal":
            # MATLAB: lognrnd(log(l^2/sqrt(s+m^2)), sqrt(log(s/m^2+1))) with l = mean LENGTH (a slip);
            # the verification plot uses m^2, which is what is generated here.
            mu = np.log(p.ap_mean**2 / np.sqrt(p.ap_std + p.ap_mean**2))
            sg = np.sqrt(np.log(p.ap_std / p.ap_mean**2 + 1))
            ap[z] = np.exp(mu + sg * rs.randn())
        elif p.aperture_model == "Uniform":
            ap[z] = p.ap_mean * 2 * rand()
        else:
            raise ValueError(p.aperture_model)

        rfk[z] = np.arccos(np.log(1 - rand()) / p.K + 1)
        # The MATLAB 'Square' branch is broken (it multiplies a 3x3 matrix by a 1x3 row and its
        # vertex z-offsets ignore the fracture size), so squares are built here like the discs:
        # same orientation draw, four vertices at 45/135/225/315 deg on the disc plane.
        if True:
            rtheta = rand() * 2 * np.pi
            _q = rand()
            Pi = np.array([np.sin(rfk[z]) * np.cos(rtheta), np.sin(rfk[z]) * np.sin(rtheta), np.cos(rfk[z])])
            pf = rotz @ (rotx @ Pi)
            d2 = np.arccos(np.clip(pf[2], -1, 1))
            if pf[2] < 0:
                # MATLAB flips x, y of Pf in place (z keeps its sign); K2 is computed from these
                pf = pf.copy(); pf[0], pf[1] = -pf[0], -pf[1]
                d2 = -d2
            Pf[z] = pf
            if pf[0] >= 0 and pf[1] >= 0:
                dd2 = np.arctan(pf[0] / pf[1]) if pf[1] != 0 else np.pi / 2
            elif pf[0] >= 0 and pf[1] < 0:
                dd2 = np.arctan(-pf[1] / pf[0]) + np.pi / 2 if pf[0] != 0 else np.pi
            elif pf[0] < 0 and pf[1] >= 0:
                dd2 = np.arctan(-pf[1] / pf[0]) + 3 * np.pi / 2
            else:
                dd2 = np.arctan(pf[0] / pf[1]) + np.pi
            if d2 <= -np.pi / 2:
                d2 = np.pi + d2
                dd2 = abs(2 * np.pi - dd2)
            dip2[z], dipd2[z] = d2, dd2
            rotx2, rotz2 = _rotx(-d2), _rotz(-dd2)
            rotx3, rotz3 = _rotx(d2), _rotz(dd2)
            P1 = centers[z]
            P2 = rotx3 @ (rotz3 @ P1)
            if p.shape == "Square":
                ang = np.deg2rad([45, 135, 225, 315])
                rad = length[z] / np.sqrt(2)          # half-diagonal of a square of side l
            else:
                ang = 2 * np.pi / 200 * np.arange(1, 201)
                rad = length[z] / 2
            NP = np.column_stack([P2[0] + rad * np.cos(ang), P2[1] + rad * np.sin(ang), np.full(len(ang), P2[2])])
            CC = (rotz2 @ (rotx2 @ NP.T)).T
            polys.append(CC)
            rots.append((rotx2, rotz2, rotx3, rotz3, P2))
    rn = np.linalg.norm(Pf.sum(axis=0))
    K2 = (n - 1) / (n - rn)
    return DFN(p, centers, length, ap, rfk, Pf, dip2, dipd2, polys, float(K2), rots)


# --------------------------------------------------------------------------
# Verification of the generated distributions (verification_Callback)
# --------------------------------------------------------------------------
@dataclass
class Verification:
    hist_x: list[np.ndarray]     # bin centres for orientation, size, aperture
    hist_y: list[np.ndarray]     # normalised histogram heights
    pdf_x: list[np.ndarray]
    pdf_y: list[np.ndarray]
    reliability: tuple[float, float, float]   # percent, as displayed


def _hist(v: np.ndarray, n: int, nbins: int = 25):
    m = v.max()
    edges = np.arange(m / (2 * nbins), m - m / (2 * nbins) + 1e-12, m / nbins)
    # MATLAB histc(v, edges): counts v in [edges(k), edges(k+1)), last bin = v == edges(end)
    counts = np.zeros(len(edges))
    for k in range(len(edges) - 1):
        counts[k] = np.sum((v >= edges[k]) & (v < edges[k + 1]))
    counts[-1] = np.sum(v == edges[-1])
    return edges, counts / n * nbins / m


def verify(dfn: DFN) -> Verification:
    p, n = dfn.params, dfn.n
    nb = 25
    xs, ys, px, py, rel = [], [], [], [], []
    # orientation
    e1, c1 = _hist(dfn.rfk, n, nb)
    m = dfn.rfk.max(); vx1 = np.arange(0, m + 1e-12, m / (20 * nb))
    vy1 = p.K * np.sin(vx1) * np.exp(p.K * np.cos(vx1)) / (np.exp(p.K) - np.exp(-p.K))
    # size
    e2, c2 = _hist(dfn.length, n, nb)
    m = dfn.length.max(); vx2 = np.arange(0, m + 1e-12, m / (20 * nb))
    if p.size_model == "Negative exponential":
        vy2 = 1 / p.mean_len * np.exp(-vx2 / p.mean_len)
    else:
        # truncated power law: the density lives on [trim, curt] only. MATLAB evaluates the
        # formula from x = 0 (Inf at 0, huge values below trim), which squashes the chart and
        # makes sum(vy2) infinite so the size reliability always reads 100 %.
        with np.errstate(divide="ignore"):
            vy2 = p.fracd * vx2 ** (-(p.fracd + 1)) / (p.trim ** -p.fracd - p.curt ** -p.fracd)
        vy2 = np.where((vx2 >= p.trim) & (vx2 <= p.curt), vy2, 0.0)
    # aperture
    e3, c3 = _hist(dfn.aperture, n, nb)
    m = dfn.aperture.max(); vx3 = np.arange(0, m + 1e-12, m / (20 * nb))
    if p.aperture_model == "Negative exponential":
        vy3 = 1 / p.ap_mean * np.exp(-vx3 / p.ap_mean)
    elif p.aperture_model == "Normal":
        vy3 = np.exp(-0.5 * ((vx3 - p.ap_mean) / p.ap_std) ** 2) / (p.ap_std * np.sqrt(2 * np.pi))
    elif p.aperture_model == "Log normal":
        mu = np.log(p.ap_mean**2 / np.sqrt(p.ap_std + p.ap_mean**2)); sg = np.sqrt(np.log(p.ap_std / p.ap_mean**2 + 1))
        with np.errstate(divide="ignore", invalid="ignore"):
            vy3 = np.where(vx3 > 0, np.exp(-0.5 * ((np.log(vx3) - mu) / sg) ** 2) / (vx3 * sg * np.sqrt(2 * np.pi)), 0.0)
    else:
        vy3 = np.full_like(vx3, 1 / m)
    for c, vy in ((c1, vy1), (c2, vy2), (c3, vy3)):
        idx = 20 * np.arange(1, nb + 1)
        idx = idx[idx < len(vy)]
        verif = np.abs(c[:len(idx)] - vy[idx])
        s = np.nansum(vy[np.isfinite(vy)])
        rel.append(round(1000 - verif.sum() / s * 1000) / 10 if s > 0 else float("nan"))
    return Verification([e1, e2, e3], [c1, c2, c3], [vx1, vx2, vx3], [vy1, vy2, vy3], tuple(rel))


# --------------------------------------------------------------------------
# Sampling window traces (swplot_Callback / swslider_Callback)
# --------------------------------------------------------------------------
@dataclass
class WindowTraces:
    normal: np.ndarray                   # SWV
    swd: float
    segments3d: list[np.ndarray | None]  # (2, 3) chord end points per disc, None if no intersection
    segments2d: list[np.ndarray | None]  # (2, 2) trace in the window plane (width, height)


def window_position(p: DFNParams, swdip_deg: float, swdipd_deg: float, t: float) -> float:
    """Plane offset swd for slider value t (swslider_Callback)."""
    swdip, swdipd = np.deg2rad(swdip_deg), np.deg2rad(swdipd_deg)
    v = np.array([np.sin(swdip) * np.sin(swdipd), np.sin(swdip) * np.cos(swdipd), np.cos(swdip)])
    return float(-t * (v[0] * p.x0 + v[1] * p.y0 - v[2] * p.z0) + v[0] * p.domx + v[1] * p.domy - v[2] * p.domz)


def window_traces(dfn: DFN, swdip_deg: float, swdipd_deg: float, swd: float) -> WindowTraces:
    if dfn.params.shape != "Circle":
        raise ValueError("sampling-window traces are only available for circular fractures")
    swdip, swdipd = np.deg2rad(swdip_deg), np.deg2rad(swdipd_deg)
    SWV = np.array([np.sin(swdip) * np.sin(swdipd), np.sin(swdip) * np.cos(swdipd), np.cos(swdip)])
    rotx4, rotz4 = _rotx(swdip - np.pi / 2), _rotz(swdipd)
    seg3, seg2 = [], []
    for z in range(dfn.n):
        rotx2, rotz2, rotx3, rotz3, P2 = dfn.rotations[z]
        T = rotx3 @ (rotz3 @ SWV)
        temp3 = rotx3 @ (rotz3 @ np.array([0, 0, swd / SWV[2]]))
        a, b, c = T
        swd2 = a * temp3[0] + b * temp3[1] + c * temp3[2]
        eqa = 1 + (a / b) ** 2
        eqb = -2 * P2[0] + 2 * a * c * P2[2] / b**2 - 2 * a * swd2 / b**2 + 2 * a * P2[1] / b
        eqc = (P2[0] ** 2 + (c * P2[2] / b) ** 2 + (swd2 / b) ** 2 + P2[1] ** 2 - 2 * c * swd2 * P2[2] / b**2
               + 2 * c * P2[1] * P2[2] / b - 2 * swd2 * P2[1] / b - dfn.length[z] ** 2 / 4)
        disc = eqb**2 - 4 * eqa * eqc
        if disc < 0 or not np.isfinite(disc):
            seg3.append(None); seg2.append(None)
            continue
        x1 = (-eqb - np.sqrt(disc)) / (2 * eqa); y1 = (-a * x1 + swd2 - c * P2[2]) / b
        x2 = (-eqb + np.sqrt(disc)) / (2 * eqa); y2 = (-a * x2 + swd2 - c * P2[2]) / b
        t1, t2 = np.array([x1, y1, P2[2]]), np.array([x2, y2, P2[2]])
        SW = np.vstack([rotz2 @ (rotx2 @ t1), rotz2 @ (rotx2 @ t2)])
        SW2 = rotx4 @ (rotz4 @ SW.T)          # (3, 2): rows x (width), y, z (height)
        seg3.append(SW)
        seg2.append(np.column_stack([SW2[0], SW2[2]]))
    return WindowTraces(SWV, swd, seg3, seg2)


def window_plane(p: DFNParams, SWV: np.ndarray, swd: float):
    x = np.arange(p.domx - p.x0, p.domx + p.x0 + 1e-9, 0.1)
    y = np.arange(p.domy - p.y0, p.domy + p.y0 + 1e-9, 0.1)
    X, Y = np.meshgrid(x, y)
    Z = (-SWV[0] * X - SWV[1] * Y + swd) / SWV[2]
    return X, Y, Z


# --------------------------------------------------------------------------
# Drillhole intersection (drillclassify_Callback / drillsave_Callback)
# --------------------------------------------------------------------------
@dataclass
class DrillResult:
    x: float; y: float; z_top: float; depth: float; radius: float
    intersects: np.ndarray       # bool per fracture

    def cylinder(self, n: int = 100):
        t = np.linspace(0, 2 * np.pi, n + 1)
        X = np.vstack([self.radius * np.cos(t)] * 2) + self.x
        Y = np.vstack([self.radius * np.sin(t)] * 2) + self.y
        Z = np.vstack([np.full(n + 1, self.z_top - self.depth), np.full(n + 1, self.z_top)])
        return X, Y, Z


def drill_classify(dfn: DFN, x: float, y: float, z_top: float, depth: float, radius: float) -> DrillResult:
    """A fracture intersects the hole if one of its 200 polygon vertices lies inside
    the hole radius in plan view, or the disc-centre distance test of the MATLAB
    code passes. Like the original, the vertical extent of the hole is not checked."""
    if dfn.params.shape != "Circle":
        raise ValueError("drillhole classification is only available for circular fractures")
    inter = np.zeros(dfn.n, bool)
    for z in range(dfn.n):
        CC = dfn.polygons[z]
        nn = np.any((CC[:, 0] - x) ** 2 + (CC[:, 1] - y) ** 2 < radius**2)
        P1 = dfn.centers[z]
        d2, dd2 = dfn.dip2[z], dfn.dipd2[z]
        nx, ny, nz = np.sin(d2) * np.sin(dd2), np.sin(d2) * np.cos(dd2), np.cos(d2)
        dz = (nx * P1[0] + ny * P1[1] + nz * P1[2] - nx * x - ny * y) / nz
        horiz = np.sqrt((x - P1[0]) ** 2 + (y - P1[1]) ** 2)
        theta = np.arctan(abs(dz - P1[2]) / horiz) if horiz > 0 else np.pi / 2
        mm = horiz / np.cos(theta) < dfn.length[z] / 2 - radius / np.cos(theta)
        inter[z] = bool(nn or mm)
    return DrillResult(x, y, z_top, depth, radius, inter)


def save_classified(path: str | Path, dfn: DFN, res: DrillResult) -> None:
    """drillsave_Callback text format (read back by hydroshear.load_dfn / stereonet)."""
    tab = dfn.table()
    lines = ["Intersecting Fractures", "X\tY\tZ\tDip\tDip direction"]
    lines += ["\t".join(f"{v:f}" for v in row) for row in tab[res.intersects]]
    lines += ["", "Non-intersecting Fractures", "X\tY\tZ\tDip\tDip direction"]
    lines += ["\t".join(f"{v:f}" for v in row) for row in tab[~res.intersects]]
    with open(path, "w", encoding="utf-8", newline="\r\n") as fh:
        fh.write("\n".join(lines) + "\n")
