"""Reservoir temperature prediction (port of TherCal.m and its helpers:
bdv.m, grgtal.m, TWD.m, radtal.m, radTWD.m, talbot_inversion.m,
rockTemp_bdv.m, rockTemp_grg.m, rockTemp_rad.m).

Three heat-extraction models for cold water injected through fractures in hot rock:

* "bodvarsson" - single fracture, rectilinear flow (Bodvarsson, closed form with erfc)
* "gringarten" - N parallel fractures, rectilinear flow (Gringarten et al. 1975,
                 Laplace-domain solution inverted numerically with Talbot's method)
* "radial"     - N parallel fractures, radial flow (Laplace-domain solution, Talbot)

Units follow the MATLAB GUI: J/kg/K, kg/m^3, W/m/K, degC, kg/s, m, years.
Time inputs are in years; internally converted to seconds where needed.
"""
from __future__ import annotations

from dataclasses import dataclass, replace
from typing import Callable, Literal

import numpy as np
from scipy.special import erfc

Model = Literal["bodvarsson", "gringarten", "radial"]
MODELS: tuple[str, ...] = ("bodvarsson", "gringarten", "radial")
MODEL_LABELS = {
    "bodvarsson": "Single fracture, rectilinear flow model",
    "gringarten": "Multiple fracture, rectilinear flow model",
    "radial": "Multiple fracture, radial flow model",
}

_YEAR = 365 * 86400.0
_GRG_H = 6.0        # hard-coded characteristic height in grgtal.m
_RHO_W = 1000.0     # radtal.m: fluid density (no influence on results)
_B = 10.0           # radtal.m: aperture (no influence on results)


@dataclass(frozen=True)
class ThermalParams:
    """Base data + variables of the TherCal window."""

    c_r: float      # specific heat of rock [J/kg/K]
    c_w: float      # specific heat of fluid [J/kg/K]
    rho_r: float    # rock density [kg/m^3]
    K_r: float      # thermal conductivity of rock [W/m/K]
    T_ro: float     # initial rock temperature [degC]
    T_wo: float     # injection fluid temperature [degC]
    L: float        # width of fracture [m]
    Q_m: float      # total mass flow rate [kg/s]
    N: int          # number of fractures
    spacing: float  # fracture spacing [m] (MATLAB uses x_E = spacing / 2)
    z: float        # distance from injection well along the fracture [m]
    t_year: float   # time [years]

    @property
    def x_E(self) -> float:
        return self.spacing / 2.0


# --------------------------------------------------------------------------
# Numerical inverse Laplace transform (talbot_inversion.m, Abate & Whitt 2006)
# --------------------------------------------------------------------------
def talbot_inversion(f_s: Callable[[np.ndarray], np.ndarray], t, M: int = 64) -> np.ndarray:
    """Inverse Laplace transform of f_s evaluated at times t (1-D array).

    f_s receives a complex array of shape (len(t), M) and must evaluate
    element-wise; per-time parameters can be broadcast as (len(t), 1) columns.
    """
    t = np.atleast_1d(np.asarray(t, dtype=float)).reshape(-1)
    k = np.arange(1, M)
    cot = 1.0 / np.tan(np.pi / M * k)
    delta = np.empty(M, dtype=complex)
    delta[0] = 2 * M / 5
    delta[1:] = 2 * np.pi / 5 * k * (cot + 1j)
    gamma = np.empty(M, dtype=complex)
    gamma[0] = 0.5 * np.exp(delta[0])
    gamma[1:] = (1 + 1j * np.pi / M * k * (1 + cot**2) - 1j * cot) * np.exp(delta[1:])
    s = delta[None, :] / t[:, None]
    return 0.4 / t * np.sum(np.real(gamma[None, :] * f_s(s)), axis=1)


# --------------------------------------------------------------------------
# Point models. x = depth into the rock from the fracture face (0 = fluid temp)
# --------------------------------------------------------------------------
def _bcast(*arrs):
    arrs = np.broadcast_arrays(*[np.asarray(a, dtype=float) for a in arrs])
    return arrs[0].shape, [a.ravel() for a in arrs]


def bodvarsson(p: ThermalParams, x, z, t_year):
    """bdv.m - single fracture. z: distance along fracture [m], t_year: years."""
    q = p.Q_m / (p.N * p.L)
    alpha = 2 * p.K_r / (p.c_w * q)
    a = p.K_r / (p.rho_r * p.c_r)
    t = np.asarray(t_year, dtype=float) * _YEAR
    x = np.asarray(x, dtype=float)
    z = np.asarray(z, dtype=float)
    return p.T_ro + (p.T_wo - p.T_ro) * erfc((alpha * z + x) / (2 * np.sqrt(a * t)))


def gringarten(p: ThermalParams, x, z, t_year, x_E: float | None = None):
    """grgtal.m + TWD.m - N parallel fractures, half-spacing x_E (default p.x_E).

    x_E = inf reproduces the single-fracture limit used by rockTemp_grg.m for N == 1.
    """
    x_E = p.x_E if x_E is None else x_E
    Q = p.Q_m / (p.N * p.L)
    H = _GRG_H
    shape, (x, z, t) = _bcast(x, z, t_year)
    zd = z / H
    tdstar = t / (((p.K_r * p.rho_r * p.c_r) * H**2 * 4) / (p.c_w**2 * Q**2) / _YEAR)
    a = p.c_w * Q / (2 * p.K_r * H)

    if np.isinf(x_E):
        # Infinite spacing: tanh -> 1 and TWD reduces to exp(-sqrt(s)(zd + a x))/s, whose
        # inverse transform is erfc((zd + a x) / (2 sqrt(t))). MATLAB (rockTemp_grg.m, N == 1)
        # pushes x_E = inf through the Talbot inversion and gets NaN everywhere; the closed
        # form is exact and stable.
        T_WD = erfc((zd + a * x) / (2 * np.sqrt(tdstar)))
        return (p.T_ro + (p.T_wo - p.T_ro) * T_WD).reshape(shape)

    def f(s):
        rs = np.sqrt(s)
        with np.errstate(over="ignore", invalid="ignore"):
            th = np.tanh(rs * a * x_E)
            return (1 / s * np.exp(-zd[:, None] * rs * th)
                    * (np.cosh(rs * a * x[:, None]) - th * np.sinh(rs * a * x[:, None])))

    T_WD = talbot_inversion(f, tdstar)
    return (p.T_ro + (p.T_wo - p.T_ro) * T_WD).reshape(shape)


def radial(p: ThermalParams, x, r, t_year, x_E: float | None = None):
    """radtal.m + radTWD.m - N parallel fractures, radial flow.

    x: normal distance into rock [m]; r: radial distance from the well [m].
    x_E = inf gives the single-fracture closed form (rockTemp_rad.m used 1e10 for N == 1).
    """
    x_E = p.x_E if x_E is None else x_E
    shape, (x, r, t) = _bcast(x, r, t_year)
    if np.isinf(x_E):
        # Infinite spacing: theta -> 0, tanh -> 1 and the transform reduces to
        # exp(-sqrt(s)(ep + H))/s, i.e. T_WD = erfc((2 K pi r^2/(c_w Q) + x) / (2 sqrt(a t))),
        # the radial analogue of Bodvarsson. MATLAB (rockTemp_rad.m, N == 1) uses x_E = 1e10
        # in the Talbot inversion, which returns values like -5e6 degC deep in the rock.
        a = p.K_r / (p.rho_r * p.c_r)
        c = 2 * p.K_r * np.pi * r**2 / (p.c_w * (p.Q_m / p.N)) + x
        T_WD = erfc(c / (2 * np.sqrt(a * t * _YEAR)))
        return (p.T_ro + (p.T_wo - p.T_ro) * T_WD).reshape(shape)
    tdstar = p.K_r * t * _YEAR / (p.rho_r * p.c_r * x_E**2)
    theta = (_RHO_W * p.c_w) / (p.rho_r * p.c_r) * (2 * _B) / x_E
    ep = p.K_r * np.pi * r**2 * (2 + theta) / (p.c_w * (p.Q_m / p.N) * x_E)
    Hd = x / x_E

    def f(s):
        rs = np.sqrt(s)
        with np.errstate(over="ignore", invalid="ignore"):
            th = np.tanh(rs)
            return (1 / s * np.exp(-(2 * rs * th) * ep[:, None] / (2 + theta))
                    * (np.cosh(rs * Hd[:, None]) - np.sinh(rs * Hd[:, None]) * th))

    T_WD = talbot_inversion(f, tdstar)
    return (p.T_ro + (p.T_wo - p.T_ro) * T_WD).reshape(shape)


def fluid_temperature(model: Model, p: ThermalParams, z=None, t_year=None):
    """Fluid temperature at distance z (default p.z) and time t_year (default p.t_year)."""
    z = p.z if z is None else z
    t_year = p.t_year if t_year is None else t_year
    if model == "bodvarsson":
        return bodvarsson(p, 0.0, z, t_year)
    if model == "gringarten":
        return gringarten(p, 0.0, z, t_year)
    if model == "radial":
        return radial(p, 0.0, z, t_year)
    raise ValueError(f"unknown model {model!r}")


def outlet_temperature(model: Model, p: ThermalParams) -> float:
    """'Calculate temperature distribution' button: outlet fluid temperature [degC]."""
    return float(fluid_temperature(model, p))


# --------------------------------------------------------------------------
# Profile plots ('Plot' button)
# --------------------------------------------------------------------------
def profile(model: Model, p: ThermalParams, axis: Literal["distance", "time"],
            start: float, end: float, n: int = 501, **overrides):
    """Fluid temperature vs distance [m] or time [years], 501 points like MATLAB.

    overrides: L, Q_m, N, spacing (the 'Width of fracture / Mass flow rate /
    Number of fractures / Fracture spacing' checkboxes).
    """
    q = replace(p, **overrides) if overrides else p
    grid = np.linspace(start, end, n)
    if axis == "distance":
        return grid, fluid_temperature(model, q, z=grid)
    if axis == "time":
        return grid, fluid_temperature(model, q, t_year=grid)
    raise ValueError(axis)


def legend_label(**overrides) -> str:
    parts = []
    if "L" in overrides:
        parts.append(f" Width of fracture={overrides['L']:g}m")
    if "Q_m" in overrides:
        parts.append(f" Mass flow rate={overrides['Q_m']:g}kg/s")
    if "N" in overrides:
        parts.append(f" Number of fractures={overrides['N']:g}")
    if "spacing" in overrides:
        parts.append(f" Fracture spacing={overrides['spacing']:g}m")
    return "".join(parts) if parts else " Original condition"


# --------------------------------------------------------------------------
# Rock temperature field (rockTemp_bdv.m, rockTemp_grg.m, rockTemp_rad.m)
# --------------------------------------------------------------------------
@dataclass
class TemperatureField:
    """101x101 grid: along = distance along the fracture, normal = distance into rock."""

    model: str
    along: np.ndarray    # [m], shape (101, 101)
    normal: np.ndarray   # [m], shape (101, 101)
    T: np.ndarray        # [degC]
    N: int
    x_E: float           # half spacing used for tiling the plot
    T_wo: float
    T_ro: float

    def tiles(self) -> list[tuple[float, float]]:
        """(offset, sign) pairs to draw the field around every fracture as MATLAB does."""
        if self.model == "bodvarsson":
            return [(0.0, 1.0), (0.0, -1.0)]
        out = []
        if self.N % 2 == 1:
            for i in range(-(self.N - 1) // 2, (self.N - 1) // 2 + 1):
                out += [(2 * self.x_E * i, 1.0), (2 * self.x_E * i, -1.0)]
        else:
            for i in range(1, self.N // 2 + 1):
                c = self.x_E * (2 * i - 1)
                out += [(c, 1.0), (c, -1.0), (-c, 1.0), (-c, -1.0)]
        return out


def temperature_field(model: Model, p: ThermalParams, n: int = 101) -> TemperatureField:
    idx = np.arange(n)
    along = p.z / (n - 1) * idx                       # zz = z/100*(j-1)
    if model == "bodvarsson" or p.N == 1:
        normal = p.z / (4 * (n - 1)) * idx            # x = z/400*(i-1)
    else:
        normal = p.x_E / (n - 1) * idx                # x = x_E/100*(i-1)
    NRM, ALG = np.meshgrid(normal, along, indexing="ij")   # (i = normal, j = along)
    if model == "bodvarsson":
        T = bodvarsson(p, NRM, ALG, p.t_year)
    elif model == "gringarten":
        T = gringarten(p, NRM, ALG, p.t_year, x_E=np.inf if p.N == 1 else None)
    elif model == "radial":
        T = radial(p, NRM, ALG, p.t_year, x_E=np.inf if p.N == 1 else None)
    else:
        raise ValueError(model)
    return TemperatureField(model, ALG, NRM, T, p.N, p.x_E, p.T_wo, p.T_ro)
