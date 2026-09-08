"""Borehole stability analysis (port of BSA210831_v2.m, calUCS.m, calOBB.m).

Two analyses:

* Single orientation - stress field around an inclined borehole in a generally
  anisotropic elastic rock. Analytic solution after Lekhnitskii / Ong (1994) with
  complex stress potentials, optionally with thermal stresses and mud pressure;
  or a 2-D plane-strain finite element solution (4-node quads, 3x3 Gauss).
* All orientations (isotropic rock only) - required UCS to avoid breakout and the
  breakout orientation for every borehole trend/plunge, plotted on an equal-area
  lower-hemisphere stereonet (calUCS.m / calOBB.m).

Conventions follow the MATLAB code: user inputs in MPa, GPa and degrees; the
analytic solution works internally in Pa with the compliance matrix scaled by
1e-6 exactly as the original does (amatte = Gmat / 1e6). Results carry the same
scaling as the MATLAB arrays (Pa), and the GUI divides by 1e6 for display.

Known quirks of the original that are reproduced on purpose (see README):
* the far-field shear stresses are fed to the transformation as (xz, yz, xy)
  where the matrix expects (yz, xz, xy);
* the displacement potentials use (Tyz - i*Sz) where the stress potentials use
  (Tyz - i*Txz);
* the three roots mu are multiplied by 1.0001, 1.0002, 1.0003 to separate
  repeated roots (isotropic case).
"""
from __future__ import annotations

from dataclasses import dataclass, field

import numpy as np
import scipy.sparse as sp
import scipy.sparse.linalg as spla

MPA = 1.0e6


# --------------------------------------------------------------------------
# Elastic constants (Voigt compliance, 1/GPa as in the GUI table)
# --------------------------------------------------------------------------
def compliance_isotropic(E: float, v: float) -> np.ndarray:
    S = np.zeros((6, 6))
    S[:3, :3] = -v / E
    np.fill_diagonal(S[:3, :3], 1 / E)
    S[3, 3] = S[4, 4] = S[5, 5] = 2 * (1 + v) / E
    return S


def compliance_transverse(E: float, E_: float, v: float, v_: float, G_: float) -> np.ndarray:
    """Transversely isotropic (isotropy plane = x-y), GUI 'Apply' button formula."""
    S = np.array([
        [1 / E, -v / E, -v_ / E_, 0, 0, 0],
        [-v / E, 1 / E, -v_ / E_, 0, 0, 0],
        [-v_ / E_, -v_ / E_, 1 / E_, 0, 0, 0],
        [0, 0, 0, 1 / G_, 0, 0],
        [0, 0, 0, 0, 1 / G_, 0],
        [0, 0, 0, 0, 0, 2 * (1 + v) / E],
    ])
    return S


@dataclass(frozen=True)
class BoreholeParams:
    compliance: np.ndarray        # 6x6 Voigt compliance [1/GPa]
    Sx: float                     # far-field stresses [MPa], total
    Sy: float
    Sz: float
    Sxy: float = 0.0
    Syz: float = 0.0
    Sxz: float = 0.0
    Pp: float = 0.0               # pore pressure [MPa]
    Pmud: float | None = None     # mud / injection pressure [MPa] (None = no fluid injection)
    dT: float = 0.0               # temperature change [K]
    alpha: float = 0.0            # thermal expansion coefficient [1/K]
    radius: float = 0.1           # borehole radius [m]
    polar: float = 0.0            # borehole polar angle (inclination) [deg]
    azimuth: float = 0.0          # borehole azimuth [deg]

    @property
    def Gfp(self) -> float:
        """(Pmud - Pp) in MPa, 0 without injection."""
        return 0.0 if self.Pmud is None else self.Pmud - self.Pp


# --------------------------------------------------------------------------
# Tensor transformation helpers
# --------------------------------------------------------------------------
def _voigt_T(L1, L2, L3, M1, M2, M3, N1, N2, N3) -> np.ndarray:
    """Voigt transformation matrix; scalars give (6, 6), arrays broadcast to (..., 6, 6)."""
    L1, L2, L3, M1, M2, M3, N1, N2, N3 = np.broadcast_arrays(
        *[np.asarray(a, float) for a in (L1, L2, L3, M1, M2, M3, N1, N2, N3)])
    rows = [
        [L1**2, M1**2, N1**2, 2 * M1 * N1, 2 * N1 * L1, 2 * L1 * M1],
        [L2**2, M2**2, N2**2, 2 * M2 * N2, 2 * N2 * L2, 2 * L2 * M2],
        [L3**2, M3**2, N3**2, 2 * M3 * N3, 2 * N3 * L3, 2 * L3 * M3],
        [L2 * L3, M2 * M3, N2 * N3, M2 * N3 + M3 * N2, N2 * L3 + N3 * L2, L2 * M3 + L3 * M2],
        [L3 * L1, M3 * M1, N3 * N1, M1 * N3 + M3 * N1, N1 * L3 + N3 * L1, L1 * M3 + L3 * M1],
        [L1 * L2, M1 * M2, N1 * N2, M1 * N2 + M2 * N1, N1 * L2 + N2 * L1, L1 * M2 + L2 * M1],
    ]
    return np.stack([np.stack(r, -1) for r in rows], -2)


def borehole_transform(Gpol, Gazi) -> np.ndarray:
    """Ong (1994) transformation from global to borehole axes (Tsig); arrays broadcast."""
    L1 = np.cos(Gpol) * np.cos(Gazi); L2 = -np.sin(Gazi); L3 = np.sin(Gpol) * np.cos(Gazi)
    M1 = np.cos(Gpol) * np.sin(Gazi); M2 = np.cos(Gazi); M3 = np.sin(Gazi) * np.sin(Gpol)
    N1 = -np.sin(Gpol); N2 = 0.0; N3 = np.cos(Gpol)
    return _voigt_T(L1, L2, L3, M1, M2, M3, N1, N2, N3)


def _eptrans(theta) -> np.ndarray:
    """In-plane rotation by theta; an array of angles gives (n, 6, 6)."""
    c, s = np.cos(theta), np.sin(theta)
    return _voigt_T(c, -s, 0.0, s, c, 0.0, 0.0, 0.0, 1.0)


def _thermal_voigt(amat: np.ndarray, theta, Gtc: float, Gec: float) -> np.ndarray:
    """Thermal stress (Voigt, x-y-z frame) at every theta - the MATLAB per-angle solve,
    batched over the angles (and over leading axes of amat: (..., 6, 6) -> (..., n, 6))."""
    amat = np.asarray(amat, float)
    theta = np.atleast_1d(np.asarray(theta, float))
    out_shape = amat.shape[:-2] + (len(theta), 6)
    if Gtc * Gec == 0.0:
        return np.zeros(out_shape)
    T = _eptrans(theta)                                        # (n, 6, 6)
    ep = np.swapaxes(T, -1, -2) @ amat[..., None, :, :] @ T    # T' amat T for every (..., n)
    rhs = np.full(out_shape[:-1] + (2, 1), Gtc * Gec)
    s = np.linalg.solve(ep[..., 1:3, 1:3], rhs)[..., 0]
    v = np.zeros(out_shape)
    v[..., 1] = s[..., 0]; v[..., 2] = s[..., 1]
    return (np.linalg.inv(T) @ v[..., None])[..., 0]           # T^-1 v, T inverted once per angle


def _rotate_to_polar(Sxx, Syy, Szz, Txy, Txz, Tyz, theta):
    """Cartesian (borehole frame) -> cylindrical components on an (nr, nth) grid."""
    c, s = np.cos(theta)[None, :], np.sin(theta)[None, :]
    Sr = c * c * Sxx + 2 * c * s * Txy + s * s * Syy
    St = s * s * Sxx - 2 * c * s * Txy + c * c * Syy
    Trt = -c * s * Sxx + (c * c - s * s) * Txy + c * s * Syy
    Trz = c * Txz + s * Tyz
    Ttz = -s * Txz + c * Tyz
    return Sr, St, Szz, Trt, Trz, Ttz


def _principal(Sr, St, Sz, Trt, Trz, Ttz):
    A = np.empty(Sr.shape + (3, 3))
    A[..., 0, 0] = Sr; A[..., 1, 1] = St; A[..., 2, 2] = Sz
    A[..., 0, 1] = A[..., 1, 0] = Trt
    A[..., 0, 2] = A[..., 2, 0] = Trz
    A[..., 1, 2] = A[..., 2, 1] = Ttz
    w = np.linalg.eigvalsh(A)  # ascending
    return w[..., 2], w[..., 1], w[..., 0]


# --------------------------------------------------------------------------
# Result container
# --------------------------------------------------------------------------
@dataclass
class StressField:
    """Stress field on an (nr, nth) polar grid in the borehole frame. Units: Pa
    (the MATLAB scaling); divide by 1e6 for MPa."""

    r: np.ndarray            # (nr, nth) radius [m]
    theta: np.ndarray        # (nr, nth) angle [rad]
    radius: float            # borehole radius [m]
    Sr: np.ndarray
    St: np.ndarray
    Sz: np.ndarray
    Trt: np.ndarray
    Trz: np.ndarray
    Ttz: np.ndarray
    Sxx: np.ndarray
    Syy: np.ndarray
    Szz: np.ndarray
    Txy: np.ndarray
    Txz: np.ndarray
    Tyz: np.ndarray
    Sp1: np.ndarray
    Sp2: np.ndarray
    Sp3: np.ndarray
    dispxx: np.ndarray | None = None
    dispyy: np.ndarray | None = None
    method: str = "analytic"
    extra: dict = field(default_factory=dict)

    def quantity(self, kind: str) -> np.ndarray:
        """Plot quantities of the MATLAB 'Plotting Option' popup, in Pa."""
        if kind == "tangential":
            return self.St
        if kind == "radial":
            return self.Sr
        if kind == "axial":
            return self.Sz
        if kind == "sp1":
            return self.Sp1
        if kind == "sp3":
            return self.Sp3
        if kind == "tresca":
            return self.Sp1 - self.Sp3
        if kind == "vonmises":
            return np.sqrt(((self.Sp1 - self.Sp2) ** 2 + (self.Sp2 - self.Sp3) ** 2
                            + (self.Sp3 - self.Sp1) ** 2) / 2)
        raise ValueError(kind)


QUANTITIES = {
    "tangential": "Tangential stress (MPa)", "radial": "Radial stress (MPa)",
    "axial": "Axial stress (MPa)", "sp1": "Maximum principal stress (MPa)",
    "sp3": "Minimum principal stress (MPa)", "tresca": "Tresca stress (MPa)",
    "vonmises": "Von-Mises stress (MPa)",
}


# --------------------------------------------------------------------------
# Analytic solution (Ong 1994) - port of the 'Analytic Solution' branch of CallRun
# --------------------------------------------------------------------------
def _prepare(p: BoreholeParams):
    amatte = p.compliance / MPA
    Gpol, Gazi = np.deg2rad(p.polar), np.deg2rad(p.azimuth)
    Tsig = borehole_transform(Gpol, Gazi)
    Gsxi, Gsyi, Gszi = (p.Sx - p.Pp) * MPA, (p.Sy - p.Pp) * MPA, (p.Sz - p.Pp) * MPA
    Gsxyi, Gsyzi, Gsxzi = p.Sxy * MPA, p.Syz * MPA, p.Sxz * MPA
    # MATLAB order quirk: [xz, yz, xy] into the (yz, xz, xy) slots
    devst = Tsig @ np.array([Gsxi, Gsyi, Gszi, Gsxzi, Gsyzi, Gsxyi])
    Gsx, Gsy, Gsz, Gtyz, Gtxz, Gtxy = devst
    amat = Tsig.T @ amatte @ Tsig
    return amat, (Gsx, Gsy, Gsz, Gtyz, Gtxz, Gtxy), p.Gfp * MPA, p.dT, p.alpha


def analytic_solution(p: BoreholeParams, r_factors: np.ndarray | None = None,
                      n_theta: int = 1441) -> StressField:
    """Stress field on r = (1:0.05:10)*radius (181 radii) x theta = 0:pi/720:2pi (1441 angles)."""
    amat, (Gsx, Gsy, Gsz, Gtyz, Gtxz, Gtxy), Gfp, Gtc, Gec = _prepare(p)
    b = amat - np.outer(amat[:, 2], amat[:, 2]) / amat[2, 2]      # reduced compliance (Lekhnitskii)
    b11, b12, b14, b15, b16 = b[0, 0], b[0, 1], b[0, 3], b[0, 4], b[0, 5]
    b22, b24, b25, b26 = b[1, 1], b[1, 3], b[1, 4], b[1, 5]
    b44, b45, b46, b55, b56, b66 = b[3, 3], b[3, 4], b[3, 5], b[4, 4], b[4, 5], b[5, 5]
    poly = [   # Ong (1994) eq. 3.3.4-3.3.5, sextic in mu
        b11 * b55 - b15**2,
        2 * b15 * (b14 + b56) - 2 * b11 * b45 - 2 * b16 * b55,
        b11 * b44 + 4 * b16 * b45 + b55 * (2 * b12 + b66) - 2 * b15 * (b25 + b46) - (b14 + b56) ** 2,
        2 * b15 * b24 + 2 * (b14 + b56) * (b25 + b46) - 2 * b16 * b44 - 2 * b45 * (2 * b12 + b66) - 2 * b26 * b55,
        b44 * (2 * b12 + b66) + 4 * b26 * b45 + b22 * b55 - 2 * b24 * (b14 + b56) - (b25 + b46) ** 2,
        2 * b24 * (b25 + b46) - 2 * b26 * b44 - 2 * b22 * b45,
        b22 * b44 - b24**2,
    ]
    roots = np.roots(poly)   # same companion-matrix eigenvalue approach as MATLAB roots()
    tempmu = [z for z in roots if z.imag > 0]
    if len(tempmu) < 3:
        raise ValueError("could not find three roots with positive imaginary part")
    mu = np.array([1.0001 * tempmu[0], 1.0002 * tempmu[1], 1.0003 * tempmu[2]])

    def l3_num(m):
        return b15 * m**3 - (b14 + b56) * m**2 + (b25 + b46) * m - b24

    def l2_den(m):
        return b55 * m**2 - 2 * b45 * m + b44

    def l4_den(m):
        return b11 * m**4 - 2 * b16 * m**3 + (2 * b12 + b66) * m**2 - 2 * b26 * m + b22

    lbd = np.array([-l3_num(mu[0]) / l2_den(mu[0]), -l3_num(mu[1]) / l2_den(mu[1]),
                    -l3_num(mu[2]) / l4_den(mu[2])])

    Gr = p.radius
    r = (np.arange(1.0, 10.0 + 1e-9, 0.05) if r_factors is None else np.asarray(r_factors)) * Gr
    theta = np.linspace(0.0, 2 * np.pi, n_theta)
    R = Gr
    Del = mu[1] - mu[0] + lbd[2] * lbd[1] * (mu[0] - mu[2]) + lbd[0] * lbd[2] * (mu[2] - mu[1])
    p1 = b11 * mu[0]**2 + b12 - b16 * mu[0] + lbd[0] * (b15 * mu[0] - b14)
    p2 = b11 * mu[1]**2 + b12 - b16 * mu[1] + lbd[1] * (b15 * mu[1] - b14)
    p3 = lbd[2] * (b11 * mu[2]**2 + b12 - b16 * mu[2]) + b15 * mu[2] - b14
    q1 = b12 * mu[0] + b22 / mu[0] - b26 + lbd[0] * (b25 - b24 / mu[0])
    q2 = b12 * mu[1] + b22 / mu[1] - b26 + lbd[1] * (b25 - b24 / mu[1])
    q3 = lbd[2] * (b12 * mu[2] + b22 / mu[2] - b26) + b25 - b24 / mu[2]

    nr, nth = len(r), len(theta)
    # branch tracking of the square root, sequential in theta (MATLAB stsign/detsign):
    # stsign becomes -1 once Im > 0 and returns to +1 once Im < 0 (zeros keep the state);
    # every return flips detsign. Vectorised with a forward-filled state instead of the loop.
    detert = np.zeros((3, nr, nth), dtype=complex)
    zeta = np.zeros((3, nr, nth), dtype=complex)
    jj = np.arange(nth)[None, :]
    for k in range(3):
        z = r[:, None] * (np.cos(theta)[None, :] + mu[k] * np.sin(theta)[None, :])
        deter = (z / R) ** 2 - 1 - mu[k] ** 2
        im = deter.imag
        sgn = np.where(im > 0, -1, np.where(im < 0, 1, 0))
        last = np.maximum.accumulate(np.where(sgn != 0, jj, -1), axis=1)
        state = np.where(last >= 0, np.take_along_axis(sgn, np.maximum(last, 0), axis=1), 1)
        prev = np.concatenate([np.ones((nr, 1), int), state[:, :-1]], axis=1)
        back = (prev == -1) & (im < 0)
        detsign = np.cumprod(np.where(back, -1.0, 1.0), axis=1)
        detert[k] = detsign * np.sqrt(deter)
        zeta[k] = (z / R + detert[k]) / (1 - 1j * mu[k])

    A = 1j * Gtxy - Gsy + Gfp
    B = Gtxy - 1j * Gsx + 1j * Gfp
    C = Gtyz - 1j * Gtxz
    Cd = Gtyz - 1j * Gsz                        # MATLAB quirk in the displacement potentials
    l1, l2, l3 = lbd
    m1, m2, m3 = mu
    Phi1 = -(1 / (2 * Del * zeta[0] * detert[0])) * (A * (m2 - l2 * l3 * m3) + B * (l2 * l3 - 1) + C * l3 * (m3 - m2))
    Phi2 = -(1 / (2 * Del * zeta[1] * detert[1])) * (A * (l1 * l3 * m3 - m1) + B * (1 - l1 * l3) + C * l3 * (m1 - m3))
    Phi3 = -(1 / (2 * Del * zeta[2] * detert[2])) * (A * (m1 * l2 - m2 * l1) + B * (l1 - l2) + C * (m2 - m1))
    Sxx = Gsx + 2 * np.real(m1**2 * Phi1 + m2**2 * Phi2 + (l3 * m3**2) * Phi3)
    Syy = Gsy + 2 * np.real(Phi1 + Phi2 + l3 * Phi3)
    Txy = Gtxy - 2 * np.real(m1 * Phi1 + m2 * Phi2 + l3 * m3 * Phi3)
    Txz = Gtxz + 2 * np.real(m1 * l1 * Phi1 + m2 * l2 * Phi2 + m3 * Phi3)
    Tyz = Gtyz - 2 * np.real(l1 * Phi1 + l2 * Phi2 + Phi3)
    Szz = Gsz - (1 / amat[2, 2]) * (amat[2, 0] * (Sxx - Gsx) + amat[2, 1] * (Syy - Gsy) + amat[2, 3] * (Tyz - Gtyz)
                                    + amat[2, 4] * (Txz - Gtxz) + amat[2, 5] * (Txy - Gtxy))
    pphi1 = R / (2 * Del * zeta[0]) * (A * (m2 - l2 * l3 * m3) + B * (l2 * l3 - 1) + Cd * l3 * (m3 - m2))
    pphi2 = R / (2 * Del * zeta[1]) * (A * (l1 * l3 * m3 - m1) + B * (1 - l1 * l3) + Cd * l3 * (m1 - m3))
    pphi3 = R / (2 * Del * zeta[2]) * (A * (m1 * l2 - m2 * l1) + B * (l1 - l2) + Cd * (m2 - m1))
    dispxx = 2 * np.real(p1 * pphi1 + p2 * pphi2 + p3 * pphi3)
    dispyy = 2 * np.real(q1 * pphi1 + q2 * pphi2 + q3 * pphi3)

    th = _thermal_voigt(amat, theta, Gtc, Gec)   # (nth, 6): x, y, z, yz, xz, xy
    Sxx = Sxx + th[None, :, 0]; Syy = Syy + th[None, :, 1]; Szz = Szz + th[None, :, 2]
    Tyz = Tyz + th[None, :, 3]; Txz = Txz + th[None, :, 4]; Txy = Txy + th[None, :, 5]

    Sr, St, Sz, Trt, Trz, Ttz = _rotate_to_polar(Sxx, Syy, Szz, Txy, Txz, Tyz, theta)
    Sp1, Sp2, Sp3 = _principal(Sr, St, Sz, Trt, Trz, Ttz)
    gridtheta, gridr = np.meshgrid(theta, r)
    return StressField(gridr, gridtheta, Gr, Sr, St, Sz, Trt, Trz, Ttz, Sxx, Syy, Szz, Txy, Txz, Tyz,
                       Sp1, Sp2, Sp3, dispxx, dispyy, "analytic", {"mu": mu, "lbd": lbd})


# --------------------------------------------------------------------------
# Finite element solution - port of the 'FEM' branch of CallRun
# --------------------------------------------------------------------------
def fem_mesh(Gr: float, rmesh: int, thmesh: int):
    """Structured quad mesh around the hole out to a square of half-width 8*Gr."""
    if thmesh % 8:
        raise ValueError("thmesh must be a multiple of 8")
    rend = 8 * Gr
    rghpo = int(np.floor(2 * rmesh / 3))
    rghco = 10
    nodep = np.zeros(((rmesh + 1) * thmesh, 2))
    q = thmesh // 4
    for thc in range(thmesh):
        r0x, r0y = Gr * np.cos(thc * 2 * np.pi / thmesh + np.pi / 4), Gr * np.sin(thc * 2 * np.pi / thmesh + np.pi / 4)
        if thc < q:
            rex, rey = rend - thc * rend / (thmesh / 8), rend
        elif thc < 2 * q:
            rex, rey = -rend, rend - (thc - q) * rend / (thmesh / 8)
        elif thc < 3 * q:
            rex, rey = -rend + (thc - 2 * q) * rend / (thmesh / 8), -rend
        else:
            rex, rey = rend, -rend + (thc - 3 * q) * rend / (thmesh / 8)
        base = (1 + rmesh) * thc
        for rc in range(rghpo + 1):
            nodep[base + rc] = [r0x + (rex - r0x) * rc / rghco / rmesh, r0y + (rey - r0y) * rc / rghco / rmesh]
        rghlox = r0x + (rex - r0x) * rghpo / rghco / rmesh
        rghloy = r0y + (rey - r0y) * rghpo / rghco / rmesh
        for rc in range(rghpo + 1, rmesh + 1):
            nodep[base + rc] = [rghlox + (rex - rghlox) * (rc - rghpo) / (rmesh - rghpo),
                                rghloy + (rey - rghloy) * (rc - rghpo) / (rmesh - rghpo)]
    nodet = np.zeros((rmesh * thmesh, 4), dtype=int)
    for thc in range(thmesh):
        nxt = (thc + 1) % thmesh
        for rc in range(1, rmesh + 1):
            nodet[rc - 1 + thc * rmesh] = [rc + thc * (rmesh + 1), rc + thc * (rmesh + 1) + 1,
                                           rc + nxt * (rmesh + 1) + 1, rc + nxt * (rmesh + 1)]
    return nodep, nodet - 1   # 0-based connectivity


def _bmat(x, y, zeta, eta):
    """Strain-displacement matrix of 4-node quads at (zeta, eta).
    x, y: (4,) for one element or (ne, 4) for all; returns B (..., 3, 8) and |J| (...)."""
    x = np.asarray(x, float); y = np.asarray(y, float)
    x1, x2, x3, x4 = (x[..., k] for k in range(4))
    y1, y2, y3, y4 = (y[..., k] for k in range(4))
    j11 = 0.25 * ((x2 - x1) * (1 - eta) + (x3 - x4) * (1 + eta))
    j12 = 0.25 * ((y2 - y1) * (1 - eta) + (y3 - y4) * (1 + eta))
    j21 = 0.25 * ((x4 - x1) * (1 - zeta) + (x3 - x2) * (1 + zeta))
    j22 = 0.25 * ((y4 - y1) * (1 - zeta) + (y3 - y2) * (1 + zeta))
    dJ = np.abs(j11 * j22 - j12 * j21)
    a = [-(1 - eta) * j22 + (1 - zeta) * j12, (1 - eta) * j22 + (1 + zeta) * j12,
         (1 + eta) * j22 - (1 + zeta) * j12, -(1 + eta) * j22 - (1 - zeta) * j12]
    b = [(1 - eta) * j21 - (1 - zeta) * j11, -(1 - eta) * j21 - (1 + zeta) * j11,
         -(1 + eta) * j21 + (1 + zeta) * j11, (1 + eta) * j21 + (1 - zeta) * j11]
    B = np.zeros(np.shape(dJ) + (3, 8))
    for k in range(4):
        B[..., 0, 2 * k] = a[k]
        B[..., 1, 2 * k + 1] = b[k]
        B[..., 2, 2 * k] = b[k]
        B[..., 2, 2 * k + 1] = a[k]
    return B / (4 * np.asarray(dJ))[..., None, None], dJ


def fem_solution(p: BoreholeParams, rmesh: int = 60, thmesh: int = 60, interp_n: int = 400) -> StressField:
    """2-D plane-strain FEM (x-y borehole plane). Returns element-centre stresses
    interpolated onto a polar grid like the MATLAB code (which used a 5000x5000 grid)."""
    from scipy.interpolate import LinearNDInterpolator
    from scipy.spatial import Delaunay, cKDTree

    amat, (Gsx, Gsy, Gsz, Gtyz, Gtxz, Gtxy), Gfp, Gtc, Gec = _prepare(p)
    Gr = p.radius
    nodep, nodet = fem_mesh(Gr, rmesh, thmesh)
    invC = np.array([[amat[0, 0], amat[1, 0], amat[5, 0]], [amat[1, 0], amat[1, 1], amat[1, 5]],
                     [amat[5, 0], amat[5, 1], amat[5, 5]]])
    C = np.linalg.inv(invC)
    gp = [-np.sqrt(3 / 5), 0.0, np.sqrt(3 / 5)]
    gw = np.array([[25, 40, 25], [40, 64, 40], [25, 40, 25]]) / 81
    ndof = 2 * len(nodep)
    ne = len(nodet)
    # element stiffness for all elements at once: Ke = sum_g w_g B' C B |J|
    X, Y = nodep[nodet, 0], nodep[nodet, 1]                    # (ne, 4)
    Ke = np.zeros((ne, 8, 8))
    for i, gz in enumerate(gp):
        for j, ge in enumerate(gp):
            B, dJ = _bmat(X, Y, gz, ge)                        # (ne, 3, 8), (ne,)
            Ke += gw[i, j] * dJ[:, None, None] * np.einsum("eki,kl,elj->eij", B, C, B)
    dofs = np.stack([2 * nodet, 2 * nodet + 1], -1).reshape(ne, 8)
    rows = np.repeat(dofs, 8, axis=1).ravel(); cols = np.tile(dofs, (1, 8)).ravel()
    K = sp.csr_matrix((Ke.ravel(), (rows, cols)), shape=(ndof, ndof))

    # boundary tractions on the outer square (MATLAB node bookkeeping, 1-based kcount)
    F = np.zeros(ndof)
    n = len(nodep)
    step = rmesh + 1
    w = 2 * (8 * Gr) / (thmesh / 4)          # rend*2/(thmesh/4); corner nodes get w/2
    def add(k1, fy, fx):  # k1 is the MATLAB 1-based node number
        F[2 * k1 - 1] += fy
        F[2 * k1 - 2] += fx
    add(step, w / 2 * (Gsy + Gtxy), 0.0)
    F[2 * step - 2] = F[2 * step - 1] + w / 2 * (Gsx + Gtxy)   # MATLAB: Ftot(2k-1) = Ftot(2k) + ...
    for k1 in range(2 * rmesh + 2, n // 4 + 1, step):
        add(k1, w * Gsy, w * Gtxy)
    k1 = n // 4 + step
    add(k1, w / 2 * (Gsy + Gtxy), -w / 2 * (Gsx + Gtxy))
    for k1 in range(n // 4 + 2 * rmesh + 2, n // 2 + 1, step):
        add(k1, -w * Gtxy, -w * Gsx)
    k1 = n // 2 + step
    add(k1, -w / 2 * (Gsy + Gtxy), -w / 2 * (Gsx + Gtxy))
    for k1 in range(n // 2 + 2 * rmesh + 2, 3 * n // 4 + 1, step):
        add(k1, -w * Gsy, -w * Gtxy)
    k1 = 3 * n // 4 + step
    add(k1, -w / 2 * (Gsy + Gtxy), w / 2 * (Gsx + Gtxy))
    for k1 in range(3 * n // 4 + 2 * rmesh + 2, n + 1, step):
        add(k1, w * Gtxy, w * Gsx)
    for k1 in range(1, n + 1, step):   # fluid pressure on the hole wall
        F[2 * k1 - 2] -= Gfp * nodep[k1 - 1, 0] * 2 * np.pi / thmesh
        F[2 * k1 - 1] -= Gfp * nodep[k1 - 1, 1] * 2 * np.pi / thmesh

    # minimum-norm least-squares solution (MATLAB: pinv(Ktot)*Ftot) via rigid-body constraints
    Nsp = np.zeros((ndof, 3))
    Nsp[0::2, 0] = 1; Nsp[1::2, 1] = 1
    Nsp[0::2, 2] = -nodep[:, 1]; Nsp[1::2, 2] = nodep[:, 0]
    Q, _ = np.linalg.qr(Nsp)
    Fp = F - Q @ (Q.T @ F)                      # project out the null-space component
    Kaug = sp.bmat([[K, sp.csr_matrix(Q)], [sp.csr_matrix(Q.T), None]]).tocsc()
    sol = spla.spsolve(Kaug, np.concatenate([Fp, np.zeros(3)]))
    atot = sol[:ndof]

    # element-centre stresses, all elements at once
    B0, _ = _bmat(X, Y, 0.0, 0.0)                              # (ne, 3, 8)
    stress = np.einsum("kl,elj,ej->ek", C, B0, atot[dofs])     # C @ B @ a per element
    xe, ye = X.mean(1), Y.mean(1)
    th_e = np.arctan2(ye, xe)
    c, s = np.cos(th_e), np.sin(th_e)
    srr = stress[:, 0] * c**2 + 2 * stress[:, 2] * s * c + stress[:, 1] * s**2
    stt = stress[:, 0] * s**2 - 2 * stress[:, 2] * s * c + stress[:, 1] * c**2
    srt = (stress[:, 1] - stress[:, 0]) * s * c + stress[:, 2] * (c**2 - s**2)
    thermal = np.zeros(ne); sxx = np.zeros(ne); syy = np.zeros(ne); sxy = np.zeros(ne)
    if Gtc * Gec != 0.0:
        tv = _thermal_voigt(amat, th_e, Gtc, Gec)
        # thermalstele = tangential thermal stress (stthertemp(1)); recompute it directly
        T = _eptrans(th_e)
        ep = np.einsum("nji,jk,nkl->nil", T, amat, T)[:, 1:3, 1:3]
        thermal = np.linalg.solve(ep, np.full((ne, 2, 1), Gtc * Gec))[:, 0, 0]
        sxx, syy, sxy = tv[:, 0], tv[:, 1], tv[:, 5]
    stt = stt + thermal
    sxx = sxx + stress[:, 0]; syy = syy + stress[:, 1]; sxy = sxy + stress[:, 2]

    r_e = np.hypot(xe, ye)
    RF, TH = np.meshgrid(np.linspace(r_e.min(), r_e.max(), interp_n), np.linspace(0, 2 * np.pi, interp_n))
    XF, YF = RF * np.cos(TH), RF * np.sin(TH)
    pts = np.column_stack([xe, ye])
    tri = Delaunay(pts)                                        # one triangulation for all fields
    grid = np.column_stack([XF.ravel(), YF.ravel()])
    tree = None

    def interp(v):
        nonlocal tree
        lin = LinearNDInterpolator(tri, v)(grid)
        bad = np.isnan(lin)
        if bad.any():
            if tree is None:
                tree = cKDTree(pts)
            lin[bad] = v[tree.query(grid[bad])[1]]
        return lin.reshape(XF.shape).T

    Sr, St, Trt, Sxx, Syy, Txy, thermalst = (interp(v) for v in (srr, stt, srt, sxx, syy, sxy, thermal))
    zero = np.zeros_like(Sr)
    w = np.linalg.eigvalsh(np.stack([np.stack([Sr, Trt], -1), np.stack([Trt, St], -1)], -2))
    Sp1, Sp2, Sp3 = w[..., 1], w[..., 1], w[..., 0]
    return StressField(RF.T, TH.T, Gr, Sr, St, zero, Trt, zero, zero, Sxx, Syy, zero, Txy, zero, zero,
                       Sp1, Sp2, Sp3, None, None, "fem",
                       {"nodep": nodep, "nodet": nodet, "disp": atot.reshape(-1, 2),
                        "elem_xy": pts, "elem_srr": srr, "elem_stt": stt, "elem_srt": srt,
                        "thermalst": thermalst})


# --------------------------------------------------------------------------
# Failure criteria, breakout geometry, local Mohr circle
# --------------------------------------------------------------------------
@dataclass(frozen=True)
class Strength:
    ucs: float          # [MPa]
    friction: float     # [deg]
    tensile: float      # [MPa]


def failure_indicators(f: StressField, s: Strength):
    """(Mohr-Coulomb, tensile) indicator fields; failure where value >= 0 (MATLAB sign, sign2)."""
    phi = np.deg2rad(s.friction)
    mc = -(s.ucs * MPA + f.Sp3 * (1 + np.sin(phi)) / (1 - np.sin(phi)) - f.Sp1)
    tens = -(f.Sp3 + s.tensile * MPA)
    return mc, tens


def breakout_geometry(f: StressField, s: Strength) -> tuple[float, float]:
    """Breakout depth Rbbo [m] and angular width theta_bbo [deg] from the Mohr-Coulomb
    criterion (port of Callmnsaveok). Theta indices wrap around instead of erroring."""
    Gucs = s.ucs * MPA
    phi = np.deg2rad(s.friction)
    k = (1 + np.sin(phi)) / (1 - np.sin(phi))
    Smc_all = Gucs + f.Sp3 * k - f.Sp1            # (nr, nth): failed where <= 0
    Smc = Smc_all[0]
    nth = Smc.size
    i_min = int(np.argmin(Smc))
    rbbo, thetabbo = 0.0, 0.0
    if Smc[i_min] <= 0:
        if Smc.max() <= 0:
            thetabbo = np.pi
            cols = [(i_min + d) % nth for d in range(-359, 360)]
        else:
            i1 = i_min
            while Smc[i1 % nth] <= 0:
                i1 -= 1
            i2 = i_min
            while Smc[i2 % nth] <= 0:
                i2 += 1
            i1, i2 = i1 + 1, i2 - 1
            thetabbo = f.theta[0, i2 % nth] - f.theta[0, i1 % nth]
            if thetabbo < 0:
                thetabbo += 2 * np.pi
            cols = [c % nth for c in range(i1, i2 + 1)]
        for c in cols:
            col = Smc_all[:, c]
            i_r = 0
            while i_r < col.size and col[i_r] <= 0:
                i_r += 1
            if i_r > 0 and f.r[i_r - 1, 0] > rbbo:
                rbbo = f.r[i_r - 1, 0]
    return float(rbbo), float(np.rad2deg(thetabbo))


@dataclass
class LocalMohr:
    r: float
    theta_deg: float
    Sr: float; St: float; Sz: float
    Sp1: float; Sp2: float; Sp3: float
    t: np.ndarray                # normal stress axis [Pa]
    circles: np.ndarray          # (3, len(t)) shear stress of the three circles [Pa]
    C0: float | None = None      # cohesion from UCS [Pa]
    reqC0: float | None = None   # required cohesion [Pa]
    mc_line: np.ndarray | None = None
    req_line: np.ndarray | None = None


def local_mohr(f: StressField, r: float, theta_deg: float, s: Strength | None = None) -> LocalMohr:
    xx, yy = f.r * np.cos(f.theta), f.r * np.sin(f.theta)
    xg, yg = r * np.cos(np.deg2rad(theta_deg)), r * np.sin(np.deg2rad(theta_deg))
    i, j = np.unravel_index(np.argmin((xx - xg) ** 2 + (yy - yg) ** 2), xx.shape)
    Sp1, Sp2, Sp3 = f.Sp1[i, j], f.Sp2[i, j], f.Sp3[i, j]
    t = np.arange(Sp3, Sp1, 10000.0) if Sp1 > Sp3 else np.array([Sp3])
    y1 = np.real(np.sqrt(((Sp2 - Sp3) / 2) ** 2 - (t - (Sp2 + Sp3) / 2) ** 2 + 0j))
    y2 = np.real(np.sqrt(((Sp3 - Sp1) / 2) ** 2 - (t - (Sp3 + Sp1) / 2) ** 2 + 0j))
    y3 = np.real(np.sqrt(((Sp1 - Sp2) / 2) ** 2 - (t - (Sp1 + Sp2) / 2) ** 2 + 0j))
    out = LocalMohr(float(f.r[i, j]), float(np.rad2deg(f.theta[i, j])), float(f.Sr[i, j]), float(f.St[i, j]),
                    float(f.Sz[i, j]), float(Sp1), float(Sp2), float(Sp3), t, np.vstack([y1, y2, y3]))
    if s is not None:
        phi = np.deg2rad(s.friction)
        C0 = s.ucs * MPA / 2 * (1 - np.sin(phi)) / np.cos(phi)
        reqC0 = np.sqrt(1 + np.tan(phi) ** 2) * abs((Sp3 - Sp1) / 2) - np.tan(phi) * (Sp1 + Sp3) / 2
        out.C0, out.reqC0 = float(C0), float(reqC0)
        out.mc_line = np.tan(phi) * t + C0
        out.req_line = np.tan(phi) * t + reqC0
    return out


# --------------------------------------------------------------------------
# All orientations (isotropic): required UCS and breakout orientation stereonets
# --------------------------------------------------------------------------
def _wall_stresses(delta, phi, Pp, Pmud, v, S_g, amatte, Gtc, Gec):
    """Port of the shared body of calUCS.m / calOBB.m: sig_tmax over theta.
    delta, phi may be arrays (broadcast together); returns broadcast shape + (n_theta,)."""
    delta, phi = np.broadcast_arrays(np.asarray(delta, float), np.asarray(phi, float))
    Gpol, Gazi = phi, np.pi / 2 - delta
    S_gg = np.array([S_g[1, 1], S_g[0, 0], S_g[2, 2], S_g[1, 2], S_g[0, 2], S_g[0, 1]])
    Tsig = borehole_transform(Gpol, Gazi)                      # (..., 6, 6)
    Tfs = Tsig.copy()
    Tfs[..., 4, :] *= -1; Tfs[..., 5, :] *= -1
    d = Tfs @ S_gg                                             # (..., 6)
    s00, s11, s22, s12, s02, s01 = (d[..., k, None] for k in range(6))
    amat = np.einsum("...ji,jk,...kl->...il", Tsig, amatte, Tsig)
    theta = np.arange(0.0, 2 * np.pi + 1e-12, 0.01 * np.pi)
    th = _thermal_voigt(amat, theta, Gtc, Gec) * 1e-6          # (..., n_theta, 6)
    c, s = np.cos(theta), np.sin(theta)
    # rotated thermal tensor components needed: temp(3,3), temp(2,2), temp(2,3), temp(1,1)
    t33 = th[..., 2]
    t22 = s * s * th[..., 0] - 2 * c * s * th[..., 5] + c * c * th[..., 1]
    t23 = -s * th[..., 4] + c * th[..., 3]
    sig_zz = s22 - 2 * v * (s00 - s11) * np.cos(2 * theta) - 4 * v * s01 * np.sin(2 * theta) + t33
    sig_tt = (s00 + s11 - 2 * (s00 - s11) * np.cos(2 * theta)
              - 4 * s01 * np.sin(2 * theta) - (Pmud - Pp) + t22)
    tau_tz = 2 * (s12 * c - s02 * s) + t23
    return 0.5 * (sig_zz + sig_tt + np.sqrt((sig_zz - sig_tt) ** 2 + 4 * tau_tz**2))


def required_ucs(delta, phi, Pp, Pmud, v, S_g, amatte, Gtc=0.0, Gec=0.0) -> float:
    """calUCS.m: maximum tangential-plane principal stress around the wall [MPa]."""
    return float(np.max(_wall_stresses(delta, phi, Pp, Pmud, v, S_g, amatte, Gtc, Gec)))


def breakout_orientation(delta, phi, Pp, Pmud, v, S_g, amatte, Gtc=0.0, Gec=0.0) -> float:
    """calOBB.m: angle [rad] of the first maximum (1-based index * 0.01*pi, as MATLAB)."""
    smax = _wall_stresses(delta, phi, Pp, Pmud, v, S_g, amatte, Gtc, Gec)
    idx = int(np.flatnonzero(np.round(smax, 5) == np.round(smax.max(), 5))[0])
    return (idx + 1) * 0.01 * np.pi


def _first_max_angle(smax: np.ndarray) -> np.ndarray:
    """breakout_orientation over the last axis of a batch of sig_tmax curves."""
    hit = np.round(smax, 5) == np.round(smax.max(-1, keepdims=True), 5)
    return (np.argmax(hit, axis=-1) + 1) * 0.01 * np.pi


def stress_tensor_geographic(SHmax: float, Shmin: float, Sv: float) -> np.ndarray:
    """S_g of the all-orientation branch: SHmax along East(y), Shmin along North(x), Sv down."""
    X, Y, Z = np.array([0, 1, 0.]), np.array([1, 0, 0.]), np.array([0, 0, -1.])
    v_SHmax = np.array([1.0, 0.0, 0.0])
    v_Shmin = np.array([np.cos(np.pi / 2), np.sin(np.pi / 2), 0.0])
    S = sorted([SHmax, Shmin, Sv], reverse=True)
    S_s = np.diag(S)
    if Sv == S[0]:
        d1, d2, d3 = Z, v_SHmax, v_Shmin
    elif Sv == S[1]:
        d1, d2, d3 = v_SHmax, Z, v_Shmin
    else:
        d1, d2, d3 = v_SHmax, v_Shmin, Z
    R_s = np.array([[d @ X, d @ Y, d @ Z] for d in (d1, d2, d3)])
    return R_s.T @ S_s @ R_s


@dataclass
class OrientationResult:
    delta: np.ndarray; phi: np.ndarray
    X: np.ndarray; Y: np.ndarray; UCS: np.ndarray            # (41, 11) equal-area stereonet
    delta_obb: np.ndarray; phi_obb: np.ndarray
    X_obb: np.ndarray; Y_obb: np.ndarray; OBB: np.ndarray     # (25, 7)
    R: float = 1.0

    def breakout_segments(self):
        """(x, y, angle_red, angle_black) for the breakout-orientation plot (MATLAB fig4).
        MATLAB uses atan(y/x), so the centre point (0/0) is NaN and drawn as nothing."""
        xre, yre, obb = self.X_obb.ravel(), self.Y_obb.ravel(), self.OBB.ravel()
        with np.errstate(divide="ignore", invalid="ignore"):
            thetare = np.arctan(yre / xre)
        return xre, yre, thetare - obb, thetare


def all_orientations(E: float, v: float, Sx: float, Sy: float, Sz: float, Pp: float,
                     Pmud: float | None, dT: float = 0.0, alpha: float = 0.0) -> OrientationResult:
    """'All Orientation' run (isotropic, analytic). Sx = SHmax, Sy = Shmin, Sz = Sv [MPa]."""
    amatte = compliance_isotropic(E, v) / MPA
    SHmax, Shmin, Sv = Sx - Pp, Sy - Pp, Sz - Pp
    Gfp = 0.0 if Pmud is None else Pmud - Pp
    S_g = stress_tensor_geographic(SHmax, Shmin, Sv)
    Pmud_eff = Pp + Gfp
    R = 1.0
    delta = np.arange(0, 2 * np.pi + 1e-12, np.pi / 20)
    phi = np.arange(0, np.pi / 2 + 1e-12, np.pi / 20)
    X = np.sqrt(2) * R * np.cos(np.pi / 2 - phi[None, :] / 2) * np.sin(delta[:, None])
    Y = np.sqrt(2) * R * np.cos(np.pi / 2 - phi[None, :] / 2) * np.cos(delta[:, None])
    UCS = _wall_stresses(delta[:, None], phi[None, :], Pp, Pmud_eff, v, S_g, amatte, dT, alpha).max(-1)
    d2 = np.arange(0, 2 * np.pi + 1e-12, np.pi / 12)
    f2 = np.arange(0, np.pi / 2 + 1e-12, np.pi / 12)
    X2 = np.sqrt(2) * R * np.cos(np.pi / 2 - f2[None, :] / 2) * np.sin(d2[:, None])
    Y2 = np.sqrt(2) * R * np.cos(np.pi / 2 - f2[None, :] / 2) * np.cos(d2[:, None])
    OBB = _first_max_angle(_wall_stresses(d2[:, None], f2[None, :], Pp, Pmud_eff, v, S_g, amatte, dT, alpha))
    return OrientationResult(delta, phi, X, Y, UCS, d2, f2, X2, Y2, OBB, R)
