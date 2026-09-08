"""Hydraulic-fracture geometry estimation (port of HFsim.m, PKN_C.m, KGD_C.m,
radial_C.m, PKN3D.m, KGD3D.m, radial3D.m).

Three classic 2-D fracture models are supported:

* "PKN"    - Perkins-Kern-Nordgren (fixed height h, elliptical cross-section)
* "KGD"    - Khristianovic-Geertsma-de Klerk (fixed height h, plane strain)
* "radial" - penny-shaped fracture (no height parameter)

Without leak-off (C = 0 and Sp = 0) the PKN and KGD models use the closed-form
Nordgren / Geertsma-de Klerk solutions. With Carter leak-off (C > 0 or Sp > 0)
the "-C" formulations are solved with a root finder, exactly like the MATLAB
fzero(fun, [0 1e5]) call.

All inputs and outputs are SI: Pa, m, m^3/s, Pa*s, m/sqrt(s), s.
"""
from __future__ import annotations

from dataclasses import dataclass, field
from typing import Literal

import numpy as np
from scipy.optimize import brentq
from scipy.special import erfcx

Model = Literal["PKN", "KGD", "radial"]

# Root-finding bracket used by the MATLAB code: fzero(fun, [0 1.0e5])
# lower end > 0: at L = 0 the width is 0 and the Carter term becomes 0 * inf (NaN) when Sp = 0
_BRACKET = (1.0e-12, 1.0e5)


@dataclass(frozen=True)
class FracParams:
    """Reservoir / treatment parameters (SI)."""

    E: float          # Young's modulus [Pa]
    nu: float         # Poisson's ratio [-]
    Q: float          # injection rate [m^3/s]
    mu: float         # fluid viscosity [Pa*s]
    C: float = 0.0    # Carter leak-off coefficient [m/sqrt(s)]
    Sp: float = 0.0   # spurt loss [m]
    h: float | None = None   # fracture height [m] (PKN, KGD only)
    Rw: float | None = None  # borehole radius [m] (3-D geometry only)

    @property
    def leakoff(self) -> bool:
        return not (self.C == 0.0 and self.Sp == 0.0)


@dataclass
class FracResult:
    """Fracture state (SI). Scalars for a single time, arrays for a series."""

    model: str
    t: np.ndarray | float           # injection time [s]
    length: np.ndarray | float      # half-length L (PKN/KGD) or radius R (radial) [m]
    w_max: np.ndarray | float       # maximum aperture [m]
    w_avg: np.ndarray | float       # average aperture [m]
    p_net: np.ndarray | float       # net pressure [Pa]
    volume: np.ndarray | float      # injected volume Q*t [m^3]
    height: float | None = None     # fracture height [m] (None for radial)


# --------------------------------------------------------------------------
# Closed-form no-leak-off solutions (HFsim.m runButton_Callback)
# --------------------------------------------------------------------------
def pkn_no_leakoff(p: FracParams, t):
    t = np.asarray(t, dtype=float)
    E, nu, Q, mu, h = p.E, p.nu, p.Q, p.mu, p.h
    L = 0.39 * (E * Q**3 / ((1 - nu**2) * mu * h**4)) ** 0.2 * t**0.8
    Wmax = 2.18 * ((1 - nu**2) * mu * Q**2 / (E * h)) ** 0.2 * t**0.2
    Pnet = 1.09 * (E**4 * mu * Q**2 / ((1 - nu**2) ** 4 * h**6)) ** 0.2 * t**0.2
    return Wmax, L, Pnet


def kgd_no_leakoff(p: FracParams, t):
    t = np.asarray(t, dtype=float)
    E, nu, Q, mu, h = p.E, p.nu, p.Q, p.mu, p.h
    L = 0.38 * (E * Q**3 / ((1 - nu**2) * mu * h**3)) ** (1 / 6) * t ** (2 / 3)
    Wmax = 1.67 * ((1 - nu**2) * mu * Q**3 / (E * h**3)) ** (1 / 6) * t ** (1 / 3)
    Pnet = 1.09 * (mu * E**2 / (1 - nu**2) ** 2) ** (1 / 3) * t ** (-1 / 3)
    return Wmax, L, Pnet


# --------------------------------------------------------------------------
# Carter leak-off solutions (PKN_C.m, KGD_C.m, radial_C.m)
# --------------------------------------------------------------------------
def _carter(x: float) -> float:
    """exp(x^2)*erfc(x) + 2/sqrt(pi)*x - 1, evaluated overflow-free.

    MATLAB computes exp(x^2)*erfc(x) literally; erfcx(x) is the same quantity.
    """
    return erfcx(x) + 2.0 / np.sqrt(np.pi) * x - 1.0


def pkn_c(p: FracParams, t: float):
    E, nu, Q, mu, C, Sp, h = p.E, p.nu, p.Q, p.mu, p.C, p.Sp, p.h

    def fun(L):
        w = 2.75 * np.pi * ((1 - nu**2) * mu * Q * L / E) ** 0.25 + 10 * Sp
        x = 10 * C * np.sqrt(np.pi * t) / w
        return Q / (40 * C**2 * np.pi * h) * w * _carter(x) - L

    L = brentq(fun, *_BRACKET)
    Wmax = 2.75 * ((1 - nu**2) * mu * Q * L / E) ** 0.25
    Pnet = Wmax * E / (2 * (1 - nu**2) * h)
    return Wmax, L, Pnet


def kgd_c(p: FracParams, t: float):
    E, nu, Q, mu, C, Sp, h = p.E, p.nu, p.Q, p.mu, p.C, p.Sp, p.h

    def fun(L):
        w = 2.708 * np.pi * ((1 - nu**2) * mu * Q * L**2 / (h * E)) ** 0.25 + 8 * Sp
        x = 8 * C * np.sqrt(np.pi * t) / w
        return Q / (32 * C**2 * np.pi * h) * w * _carter(x) - L

    L = brentq(fun, *_BRACKET)
    Wmax = 2.708 * ((1 - nu**2) * mu * Q * L**2 / (h * E)) ** 0.25
    Pnet = Wmax * E / (4 * (1 - nu**2) * L)
    return Wmax, L, Pnet


def radial_c(p: FracParams, t: float):
    E, nu, Q, mu, C, Sp = p.E, p.nu, p.Q, p.mu, p.C, p.Sp
    if C == 0.0:
        # MATLAB divides by C^2 and fzero fails on NaN; make the failure explicit.
        raise ValueError("radial model requires a non-zero leak-off coefficient C")

    def fun(R):
        w = 14.128 * ((1 - nu**2) * mu * Q * R / E) ** 0.25 + 15 * Sp
        x = 15 * C * np.sqrt(np.pi * t) / w
        return np.sqrt(Q / (60 * C**2 * np.pi**2) * w * _carter(x)) - R

    R = brentq(fun, *_BRACKET)
    Wmax = 3.532 * ((1 - nu**2) * mu * Q * R / E) ** 0.25
    Pnet = Wmax * np.pi * E / (8 * (1 - nu**2) * R)
    return Wmax, R, Pnet


# --------------------------------------------------------------------------
# Public API
# --------------------------------------------------------------------------
_AVG_FACTOR = {"PKN": np.pi / 5, "KGD": np.pi / 4, "radial": 8 / 15}


def _check(model: str, p: FracParams) -> None:
    if model not in _AVG_FACTOR:
        raise ValueError(f"unknown model {model!r}; expected PKN, KGD or radial")
    if model != "radial" and p.h is None:
        raise ValueError(f"{model} model requires fracture height h")


def evaluate(model: Model, p: FracParams, t: float) -> FracResult:
    """Fracture state at a single injection time t [s]."""
    _check(model, p)
    if model == "PKN":
        Wmax, L, Pnet = pkn_c(p, t) if p.leakoff else pkn_no_leakoff(p, t)
    elif model == "KGD":
        Wmax, L, Pnet = kgd_c(p, t) if p.leakoff else kgd_no_leakoff(p, t)
    else:
        Wmax, L, Pnet = radial_c(p, t)
    Wmax, L, Pnet = float(Wmax), float(L), float(Pnet)
    return FracResult(
        model=model, t=float(t), length=L, w_max=Wmax,
        w_avg=Wmax * _AVG_FACTOR[model], p_net=Pnet, volume=p.Q * t,
        height=None if model == "radial" else p.h,
    )


def time_grid(t_final: float, n: int = 201) -> np.ndarray:
    """MATLAB: t = 1 : (t_f - 1)/200 : t_f  ->  201 points from 1 s to t_f."""
    return np.linspace(1.0, float(t_final), n)


def simulate(model: Model, p: FracParams, t_final: float, n: int = 201) -> FracResult:
    """Fracture growth history from 1 s to t_final (HFsim "Run" button).

    t_final may be derived from a total injected volume as V / Q.
    """
    _check(model, p)
    t = time_grid(t_final, n)
    if model == "PKN" and not p.leakoff:
        Wmax, L, Pnet = pkn_no_leakoff(p, t)
    elif model == "KGD" and not p.leakoff:
        Wmax, L, Pnet = kgd_no_leakoff(p, t)
    else:
        solver = {"PKN": pkn_c, "KGD": kgd_c, "radial": radial_c}[model]
        out = np.array([solver(p, ti) for ti in t])
        Wmax, L, Pnet = out[:, 0], out[:, 1], out[:, 2]
    return FracResult(
        model=model, t=t, length=L, w_max=Wmax,
        w_avg=Wmax * _AVG_FACTOR[model], p_net=Pnet, volume=p.Q * t,
        height=None if model == "radial" else p.h,
    )


def aperture_profile(model: Model, length: float, w_max: float, n: int = 201):
    """Maximum aperture along the fracture (HFsim "2D plot" button).

    Returns (x, w) with x from the borehole wall to the fracture tip.
    """
    frx = np.linspace(0.0, 1.0, n)
    if model == "PKN":
        w = w_max * (1 - frx) ** 0.25
    elif model == "KGD":
        w = w_max * (1 - frx**2) ** 0.5
    elif model == "radial":
        w = w_max * (1 - frx) ** 0.5
    else:
        raise ValueError(model)
    return frx * length, w


# --------------------------------------------------------------------------
# 3-D geometry meshes (PKN3D.m, KGD3D.m, radial3D.m) - data only, no plotting
# --------------------------------------------------------------------------
@dataclass
class FracMesh:
    """One symmetric part of the fracture surface as a structured grid.

    X, Y, Z are 2-D arrays; color is the local aperture used for the colour map
    (2*|Y| in MATLAB). mirror lists the sign flips the MATLAB code applies to
    draw the remaining symmetric parts: each entry is (sx, sy, sz).
    borehole is (radius, half-height) of the grey cylinder drawn at the origin.
    """

    X: np.ndarray
    Y: np.ndarray
    Z: np.ndarray
    color: np.ndarray
    mirror: list[tuple[int, int, int]]
    cmax: float
    title: str
    borehole: tuple[float, float] = field(default=(0.0, 0.0))


def pkn_mesh(H: float, L: float, R: float, W0: float, SF: float = 1.0) -> FracMesh:
    r = np.linspace(0.0, L, 51)
    h = np.linspace(-H / 2, H / 2, 51)
    Wr = SF * W0 * (1 - r / L) ** 0.25
    Wr[-1] = 0.0
    Wh = Wr[None, :] * np.sqrt(1 - (2 * h[:, None] / H) ** 2)
    X = np.broadcast_to(R + r[None, :], Wh.shape).copy()
    Y = Wh / 2
    Z = np.broadcast_to(h[:, None], Wh.shape).copy()
    return FracMesh(X, Y, Z, 2 * np.abs(Y),
                    mirror=[(1, 1, 1), (-1, 1, 1), (-1, -1, 1), (1, -1, 1)],
                    cmax=SF * W0, title="PKN fracture geometry",
                    borehole=(R, 2 * H))


def kgd_mesh(H: float, L: float, R: float, W0: float, SF: float = 1.0) -> FracMesh:
    ri = L * np.sqrt((4 * R**2 - W0**2) / (4 * L**2 - W0**2))
    r = np.linspace(ri, L, 51)
    Wr = np.real(SF * W0 / L * np.sqrt(np.maximum(L**2 - r**2, 0.0)))
    X = np.vstack([r, r])
    Y = np.vstack([Wr / 2, Wr / 2])
    Z = np.vstack([np.full(51, -H / 2), np.full(51, H / 2)])
    return FracMesh(X, Y, Z, 2 * np.abs(Y),
                    mirror=[(1, 1, 1), (-1, 1, 1), (-1, -1, 1), (1, -1, 1)],
                    cmax=SF * W0 / L * np.sqrt(L**2 - ri**2),
                    title="KGD fracture geometry", borehole=(R, 0.6 * H))


def radial_mesh(Rf: float, R: float, W0: float, SF: float = 1.0) -> FracMesh:
    theta = np.pi / 36 * np.arange(73)
    r = np.linspace(R, Rf, 51)
    X = np.outer(np.cos(theta), r)
    Y = np.outer(np.sin(theta), r)
    Z = np.broadcast_to(SF * W0 / 2 * np.sqrt(1 - r / Rf)[None, :], X.shape).copy()
    return FracMesh(X, Y, Z, 2 * np.abs(Z),
                    mirror=[(1, 1, 1), (1, 1, -1)],
                    cmax=SF * W0 * np.sqrt(1 - R / Rf),
                    title="Radial fracture model", borehole=(R, 0.5 * Rf))
