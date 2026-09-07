"""Strength anisotropy of rock with a single plane of weakness
(port of anisotropy.mlapp, method aniso).

beta (degrees) is the angle between the major principal stress sigma_1 and the
NORMAL to the plane of weakness (equivalently between the plane and sigma_3).
With beta_J = 90 - beta being Jaeger's plane-to-sigma_1 angle, the peak strength
sigma_1 is the smaller of

* sliding on the plane (Jaeger's criterion written in beta):
  sigma_1 = (c_j cos(phi_j) + sigma_3 sin(beta + phi_j) cos(beta)) / (cos(beta + phi_j) sin(beta))
  == sigma_3 + 2 (c_j + sigma_3 tan(phi_j)) / ((1 - tan(phi_j) cot(beta_J)) sin(2 beta_J))
* intact rock (Mohr-Coulomb):
  UCS = 2 c_r cos(phi_r) / (1 - sin(phi_r)) + sigma_3 tan^2(45 + phi_r / 2)

and sliding is impossible for beta > 90 - phi_j (beta_J < phi_j), where the intact
strength applies. Stresses in MPa, angles in degrees. beta runs 0.1 ... 89.9 in 0.1
steps (899 points), as in the MATLAB app.
"""
from __future__ import annotations

import numpy as np


def rock_strength(c_r: float, phi_r: float, sigma_3: float) -> float:
    """Mohr-Coulomb triaxial strength of the intact rock [MPa]."""
    pr = np.deg2rad(phi_r)
    return 2 * c_r * np.cos(pr) / (1 - np.sin(pr)) + sigma_3 * np.tan(np.deg2rad(45 + phi_r / 2)) ** 2


def beta_grid() -> np.ndarray:
    """MATLAB: arad = i/10 for i = 1..899."""
    return np.arange(1, 900) / 10.0


def strength_anisotropy(c_j: float, phi_j: float, c_r: float, phi_r: float, sigma_3: float):
    """Returns (beta_deg, sigma_1) with the MATLAB capping rules applied."""
    beta = beta_grid()
    ucs = rock_strength(c_r, phi_r, sigma_3)
    b, pj = np.deg2rad(beta), np.deg2rad(phi_j)
    with np.errstate(divide="ignore", invalid="ignore"):
        y = (c_j * np.cos(pj) + sigma_3 * np.sin(b + pj) * np.cos(b)) / (np.cos(b + pj) * np.sin(b))
    y = np.where((y > ucs) | (beta > 90 - phi_j) | ~np.isfinite(y), ucs, y)
    return beta, y
