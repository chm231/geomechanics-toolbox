"""Hydraulic shearing (hydroshearing) estimation - port of HSsim.m and its helpers
strSort.m, Pcm_cal.m, Pco_cal.m, Pc_cal2.m, dPcdz_cal.m, optJD.m, polygonGroup.m,
stereonetGroup.m.

Given the in-situ stress state (Sv, SHmax, Shmin and the SHmax azimuth) and a joint
friction angle phi, the module evaluates

* Pcm  - minimum critical injection pressure for shearing the optimally oriented joint
* Pco  - cut-off pressure Pcm + alpha (S3 - Pcm) for "high shearing tendency"
* Pc   - critical pressure for shearing a joint of given dip / dip direction
* dPc/dz - vertical gradient of Pc; compared with the hydrostatic gradient it tells
  whether shearing initiates at the casing shoe (upward growth) or the well toe
* stress-polygon maps (Pcm, Pco, shearing probability, downward-growth probability
  as functions of the normalised horizontal stresses) and equal-area stereonets of
  Pc and dPc/dz over all joint orientations with the cumulative shearing probability.

Units: stresses in Pa internally (GUI inputs in MPa), angles in radians internally
(GUI inputs in degrees), densities in kg/m^3.
"""
from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

import numpy as np

G = 9.80665
MPA = 1.0e6


# --------------------------------------------------------------------------
# Principal stress ordering (strSort.m)
# --------------------------------------------------------------------------
def sort_stresses(Sv: float, SHmax: float, SHmax_azi: float, Shmin: float) -> np.ndarray:
    """S123: rows [magnitude, direction vector (x=East?, y, z)] sorted descending
    (sortrows(..., 'descend'): magnitude first, then the direction components)."""
    rows = np.array([
        [Sv, 0.0, 0.0, 1.0],
        [SHmax, np.sin(SHmax_azi), np.cos(SHmax_azi), 0.0],
        [Shmin, np.sin(SHmax_azi + np.pi / 2), np.cos(SHmax_azi + np.pi / 2), 0.0],
    ])
    order = np.lexsort([-rows[:, 3], -rows[:, 2], -rows[:, 1], -rows[:, 0]])
    return rows[order]


def pcm(S1: float, S3: float, phi: float) -> float:
    """Pcm_cal.m: critical pressure for the optimally oriented joint."""
    c1 = S1 / S3
    c2 = (1 + np.sin(phi)) / (1 - np.sin(phi))
    return (c2 - c1) / (c2 - 1) * S3


def pco(Pcm: float, alpha: float, S3: float) -> float:
    """Pco_cal.m: cut-off pressure for shearing with high tendency."""
    return Pcm + alpha * (S3 - Pcm)


def joint_normal(dip: float, dip_dir: float) -> np.ndarray:
    return np.array([np.sin(dip) * np.sin(dip_dir), np.sin(dip) * np.cos(dip_dir), np.cos(dip)])


def resolved_stresses(dip, dip_dir, S123: np.ndarray):
    """(sigma_n, tau) on joints of given dip / dip direction (arrays broadcast)."""
    dip, dip_dir = np.broadcast_arrays(np.asarray(dip, float), np.asarray(dip_dir, float))
    n = np.stack([np.sin(dip) * np.sin(dip_dir), np.sin(dip) * np.cos(dip_dir), np.cos(dip)], axis=-1)
    S1, S2, S3 = S123[:, 0]
    l, m, nn = n @ S123[0, 1:], n @ S123[1, 1:], n @ S123[2, 1:]
    sigma = l**2 * S1 + m**2 * S2 + nn**2 * S3
    tau = np.sqrt(((S1 - S2) * l * m) ** 2 + ((S2 - S3) * m * nn) ** 2 + ((S3 - S1) * nn * l) ** 2)
    return sigma, tau


def pc(dip, dip_dir, S123: np.ndarray, phi: float):
    """Pc_cal2.m: critical pressure for shearing a specific joint."""
    sigma, tau = resolved_stresses(dip, dip_dir, S123)
    return sigma - tau / np.tan(phi)


def dpcdz(rho_r: float, dip, dip_dir, S123: np.ndarray, Sv: float, phi: float):
    """dPcdz_cal.m: vertical gradient of Pc [Pa/m]."""
    return pc(dip, dip_dir, S123, phi) / Sv * rho_r * G


def optimal_joints(S123: np.ndarray, phi: float) -> tuple[tuple[float, float], tuple[float, float]]:
    """optJD.m: the two optimally oriented joint planes as (dip, dip direction) in degrees."""
    S1_d, S3_d = S123[0, 1:], S123[2, 1:]
    out = []
    for sign in (+1, -1):
        n = S1_d * np.cos(np.pi / 4 + phi / 2) + sign * S3_d * np.sin(np.pi / 4 + phi / 2)
        az = np.arctan2(n[1], n[0])
        elev = np.arctan2(n[2], np.hypot(n[0], n[1]))
        dip, dd = np.rad2deg(np.pi / 2 - elev), np.rad2deg(np.pi / 2 - az)
        if dip < 0:
            if -180 < dd <= 180:
                dd += 180
            elif 180 < dd <= 360:
                dd -= 180
            dip = -dip
        elif dd < 0:
            dd += 360
        out.append((round(float(dip), 2), round(float(dd), 2)))
    return out[0], out[1]


# --------------------------------------------------------------------------
# Quick run (HSsim quickRun_Callback)
# --------------------------------------------------------------------------
@dataclass(frozen=True)
class ShearParams:
    Sv: float          # [MPa]
    SHmax: float       # [MPa]
    Shmin: float       # [MPa]
    SHmax_azi: float   # [deg]
    phi: float         # friction angle [deg]
    rho_r: float       # rock density [kg/m^3]
    rho_f: float       # fluid density [kg/m^3]
    alpha: float       # coefficient for Pco

    @property
    def S123(self) -> np.ndarray:
        return sort_stresses(self.Sv * MPA, self.SHmax * MPA, np.deg2rad(self.SHmax_azi), self.Shmin * MPA)

    @property
    def phi_rad(self) -> float:
        return np.deg2rad(self.phi)


@dataclass
class QuickResult:
    Pcm: float                        # [MPa]
    Pco: float                        # [MPa]
    optimal: tuple[tuple[float, float], tuple[float, float]]
    joints: np.ndarray                # (n, 4): dip, dip dir [deg], Pc [MPa], initiation flag (0 up / 1 down)


def quick_run(p: ShearParams, joints: np.ndarray | None = None) -> QuickResult:
    S123, phi = p.S123, p.phi_rad
    Pcm = pcm(S123[0, 0], S123[2, 0], phi)
    Pco = pco(Pcm, p.alpha, S123[2, 0])
    rows = np.zeros((0, 4))
    if joints is not None and len(joints):
        j = np.asarray(joints, float)[:, :2]
        dip, dd = np.deg2rad(j[:, 0]), np.deg2rad(j[:, 1])
        Pc = pc(dip, dd, S123, phi)
        grad = dpcdz(p.rho_r, dip, dd, S123, p.Sv * MPA, phi)
        init = np.where(grad > p.rho_f * G, 0, 1)
        rows = np.column_stack([j[:, 0], j[:, 1], Pc / MPA, init])
    return QuickResult(Pcm / MPA, Pco / MPA, optimal_joints(S123, phi), rows)


# --------------------------------------------------------------------------
# DFN joint file (X Y Z Dip Dip-direction, optional 'Intersecting Fractures' block)
# --------------------------------------------------------------------------
def load_dfn(path: str | Path, intersecting_only: bool = False) -> np.ndarray:
    """Returns (n, 2) array of dip, dip direction [deg]. With intersecting_only the
    first block only (the MATLAB 'Borehole-intersecting DFN only' button); otherwise
    both blocks are concatenated ('Load overall DFN data')."""
    text = Path(path).read_text(encoding="utf-8", errors="replace").splitlines()
    blocks, cur, in_block = [], [], False
    for line in text:
        if not line.strip():
            continue
        cells = line.strip().split("\t")
        if cells and cells[0] == "X":
            if cur:
                blocks.append(cur)
            cur, in_block = [], True
            continue
        if in_block:
            try:
                vals = [float(c) for c in cells[:5]]
            except ValueError:
                in_block = False
                continue
            if len(vals) == 5:
                cur.append(vals[3:5])
    if cur:
        blocks.append(cur)
    if not blocks:
        raise ValueError("no 'X\\tY\\tZ\\tDip\\tDip direction' block found")
    use = blocks[:1] if intersecting_only else blocks
    return np.array([r for b in use for r in b], dtype=float)


# --------------------------------------------------------------------------
# Stress polygon group (polygonGroup.m, computation part)
# --------------------------------------------------------------------------
@dataclass
class PolygonResult:
    x: np.ndarray        # normalised Shmin (50x50)
    y: np.ndarray        # normalised SHmax
    kcm: np.ndarray      # normalised Pcm
    kco: np.ndarray | None
    pro_pco: np.ndarray | None
    pro_down: np.ndarray | None
    mup: float
    mum: float
    k0: float            # rho_f / rho_r

    def frame_lines(self):
        """Solid polygon edges and dashed hydrostatic-limit lines (normalised)."""
        mup, mum, k0 = self.mup, self.mum, self.k0
        solid = [([mum / mup, 1.0], [1.0, 1.0]), ([1.0, 1.0], [1.0, mup / mum])]
        a = k0 + mum / mup * (1 - k0)
        b = k0 + mup / mum * (1 - k0)
        dashed = [([a, a], [a, 1.0]), ([a, 1.0], [1.0, b]), ([1.0, b], [b, b])]
        return solid, dashed


def polygon_group(phi: float, Sv: float, rho_r: float, rho_f: float, alpha: float,
                  with_pco: bool = True, n: int = 50) -> PolygonResult:
    """phi [rad], Sv [Pa]. Grid over the Anderson stress polygon, 50 x 50 as MATLAB."""
    k0 = rho_f / rho_r
    mu = np.tan(phi)
    mup, mum = np.sqrt(mu**2 + 1) + mu, np.sqrt(mu**2 + 1) - mu
    i = np.arange(n)[:, None]
    j = np.arange(n)[None, :]
    fac = 1 + i / (n - 1) * (mup / mum - 1)
    with np.errstate(divide="ignore", invalid="ignore"):
        t = np.tan(np.pi / 2 * j / (n - 1))
        x = (mum / mup * t + mup / mum) / (fac + t)
    x = np.broadcast_to(x, (n, n)).copy()
    x[:, n - 1] = mum / mup
    y = x * fac
    sig = np.sort(np.stack([y, x, np.ones_like(x)], -1), axis=-1)[..., ::-1]
    kcm = pcm(sig[..., 0] * Sv / MPA, sig[..., 2] * Sv / MPA, phi) / Sv * MPA
    if not with_pco:
        return PolygonResult(x, y, kcm, None, None, None, mup, mum, k0)
    kco = kcm + alpha * (sig[..., 2] - kcm)
    # joint normals over dip direction (90 values, 4 deg step) x dip (91 values, 1 deg step)
    did = 4 * np.arange(90) / 180 * np.pi
    di = np.arange(91) / 180 * np.pi
    nx = -np.sin(di)[None, :] * np.cos(did)[:, None]
    ny = -np.sin(di)[None, :] * np.sin(did)[:, None]
    nz = np.broadcast_to(np.cos(di)[None, :], (90, 91))
    # MATLAB counts dip = 0 once (k == 1) and dip = 90 for the first 45 dip directions
    mask = np.ones((90, 91), bool)
    mask[1:, 0] = False
    mask[45:, 90] = False
    total = 90 * 89 + 45 + 1
    pro_pco = np.zeros((n, n)); pro_down = np.zeros((n, n))
    for a in range(n):
        yy, xx = y[a][:, None, None], x[a][:, None, None]      # (n,1,1)
        nor = yy * nx**2 + xx * ny**2 + nz**2
        trtr = yy**2 * nx**2 + xx**2 * ny**2 + nz**2
        she = np.sqrt(np.maximum(trtr - nor * nor, 0.0))
        pp = nor - she / mu
        pro_pco[a] = ((pp - kco[a][:, None, None] < 0) & mask).sum(axis=(1, 2)) / total
        down = ((pp - k0 < 0) & mask).sum(axis=(1, 2))
        down[kcm[a] - k0 >= 0] = 0
        pro_down[a] = down / total
    return PolygonResult(x, y, kcm, kco, pro_pco, pro_down, mup, mum, k0)


# --------------------------------------------------------------------------
# Stereonet group (stereonetGroup.m, computation part)
# --------------------------------------------------------------------------
@dataclass
class StereonetResult:
    x: np.ndarray        # (361, 91) equal-area lower-hemisphere coordinates
    y: np.ndarray
    kc: np.ndarray       # normalised Pc
    pp_gr: np.ndarray    # Pc gradient [MPa/100 m... MATLAB: kc * rho_r/100*0.980665]
    p: np.ndarray        # normalised pressure axis (91)
    prob: np.ndarray     # cumulative shearing probability (91)
    nor_sig3: float
    nor_sig1: float
    nor_Pco: float
    nor_Pcm: float
    gr_sv: float
    gr_f: float


def stereonet_group(S123: np.ndarray, Sv: float, phi: float, rho_r: float, rho_f: float,
                    alpha: float, with_prob: bool = True) -> StereonetResult:
    S1, S3 = S123[0, 0], S123[2, 0]
    Pcm = pcm(S1, S3, phi)
    Pco = pco(Pcm, alpha, S3)
    nor_sig3, nor_sig1, nor_Pco, nor_Pcm = S3 / Sv, S1 / Sv, Pco / Sv, Pcm / Sv
    gr_sv, gr_f = rho_r / 100 * 0.980665, rho_f / 100 * 0.980665
    no = 91
    did = (np.arange(360) / 180 * np.pi)[:, None]
    di = (np.arange(91) / 180 * np.pi)[None, :]
    tre, plu = did + np.pi, 0.5 * np.pi - di
    sigma, tau = resolved_stresses(np.broadcast_to(di, (360, 91)), np.broadcast_to(did, (360, 91)), S123)
    kc = (sigma - tau / np.tan(phi)) / Sv
    pp_gr = kc * gr_sv
    x = np.sqrt(2) * np.cos(tre) * np.cos(0.5 * (0.5 * np.pi + plu))
    y = np.sqrt(2) * np.sin(tre) * np.cos(0.5 * (0.5 * np.pi + plu))
    x, y = np.broadcast_to(x, (360, 91)), np.broadcast_to(y, (360, 91))
    close = lambda a: np.vstack([a, a[:1]])  # noqa: E731 - row 361 repeats row 1
    kc, pp_gr, x, y = close(kc), close(pp_gr), close(x), close(y)
    p = np.zeros(no); prob = np.zeros(no)
    if with_prob:
        dp = (nor_sig1 - nor_Pcm) / (no - 1)
        p = nor_Pcm + np.arange(no) * dp
        mask = np.ones((360, 91), bool)
        mask[1:, 0] = False          # dip 0 counted once
        mask[180:, 90] = False       # dip 90 counted for 180 dip directions
        vals = kc[:360][mask]
        num_fra = np.zeros(no)
        for k in range(no - 1):
            inbin = (vals >= p[k]) & (vals < p[k + 1])
            if k == no - 2:
                inbin |= vals == p[k + 1]
            num_fra[k] = inbin.sum()
        prob[1] = num_fra[0]
        for i in range(2, no):
            prob[i] = prob[i - 1] + num_fra[i - 1]
        prob = prob / (360 * 89 + 180 + 1)
    return StereonetResult(x, y, kc, pp_gr, p, prob, nor_sig3, nor_sig1, nor_Pco, nor_Pcm, gr_sv, gr_f)
