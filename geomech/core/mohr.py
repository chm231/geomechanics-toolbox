"""3D Mohr's circle (port of Mohr_Circle.mlapp and Mohr_Sub.mlapp).

Given the three principal stresses applied along x, y, z and a plane normal
n = (n_x, n_y, n_z), the MATLAB app finds the normal and shear stress on the
plane graphically: the point lies on the intersection of two auxiliary circles
centred on the (sigma_1, sigma_2) and (sigma_2, sigma_3) circle centres. That
construction is reproduced here (so the numbers match the MATLAB app) and the
analytic direction-cosine result is available as a cross-check.

Stresses in MPa (or any consistent unit); compression positive.
"""
from __future__ import annotations

from dataclasses import dataclass

import numpy as np


@dataclass
class Circle:
    center: float
    radius: float

    def points(self, n: int = 100):
        t = np.linspace(0.0, np.pi, n)
        return self.center + self.radius * np.cos(t), self.radius * np.sin(t)


@dataclass
class MohrResult:
    sigma: tuple[float, float, float]      # sorted principal stresses (sigma_1 >= sigma_2 >= sigma_3)
    circles: tuple[Circle, Circle, Circle]  # (1-2), (2-3), (1-3)
    phi: float                              # angle between n and the sigma_1 axis [rad]
    theta: float                            # angle between n and the sigma_3 axis [rad]
    p_phi: tuple[float, float]              # construction point on the (1-2) circle
    p_theta: tuple[float, float]            # construction point on the (2-3) circle
    aux_theta: Circle                       # dashed circle through p_theta, centred on circle (1-2)
    aux_phi: Circle                         # dashed circle through p_phi, centred on circle (2-3)
    sigma_n: float                          # normal stress on the plane
    tau_n: float                            # shear stress on the plane (>= 0)


def _extreme_component(sig: tuple[float, float, float], n: tuple[float, float, float], largest: bool) -> float:
    """MATLAB picks n along the largest (smallest) sigma with >= (<=) comparisons, x first."""
    sx, sy, sz = sig
    if largest:
        if sx >= sy and sx >= sz:
            return n[0]
        if sy >= sx and sy >= sz:
            return n[1]
        return n[2]
    if sx <= sy and sx <= sz:
        return n[0]
    if sy <= sx and sy <= sz:
        return n[1]
    return n[2]


def mohr_3d(sigma_x: float, sigma_y: float, sigma_z: float,
            n_x: float, n_y: float, n_z: float) -> MohrResult:
    sig = (float(sigma_x), float(sigma_y), float(sigma_z))
    n = (float(n_x), float(n_y), float(n_z))
    s1, s2, s3 = sorted(sig, reverse=True)
    size_n = np.sqrt(n_x**2 + n_y**2 + n_z**2)
    if size_n == 0:
        raise ValueError("normal vector must be non-zero")
    n_max = _extreme_component(sig, n, largest=True)
    n_min = _extreme_component(sig, n, largest=False)
    phi = float(np.arccos(np.clip(n_max / size_n, -1, 1)))
    theta = float(np.arccos(np.clip(n_min / size_n, -1, 1)))

    c12 = Circle((s1 + s2) / 2, abs(s2 - s1) / 2)
    c23 = Circle((s2 + s3) / 2, abs(s3 - s2) / 2)
    c13 = Circle((s1 + s3) / 2, abs(s3 - s1) / 2)

    x_phi = c12.center + c12.radius * np.cos(2 * phi)
    y_phi = c12.radius * np.sin(2 * phi)
    x_theta = c23.center - c23.radius * np.cos(2 * theta)
    y_theta = c23.radius * np.sin(2 * theta)

    aux_theta = Circle(c12.center, float(np.hypot(x_theta - c12.center, y_theta)))
    aux_phi = Circle(c23.center, float(np.hypot(x_phi - c23.center, y_phi)))

    d = abs(c12.center - c23.center)
    r1, r2 = aux_theta.radius, aux_phi.radius
    if d > r1 + r2:
        raise ValueError("auxiliary circles do not intersect (too far apart)")
    if d < abs(r1 - r2):
        raise ValueError("auxiliary circles do not intersect (one inside the other)")
    if d == 0 and r1 == r2:
        raise ValueError("auxiliary circles coincide")
    a = (r1**2 - r2**2 + d**2) / (2 * d)
    h = float(np.sqrt(max(r1**2 - a**2, 0.0)))
    x2 = c12.center + a * (c23.center - c12.center) / d
    return MohrResult(
        sigma=(s1, s2, s3), circles=(c12, c23, c13), phi=phi, theta=theta,
        p_phi=(float(x_phi), float(y_phi)), p_theta=(float(x_theta), float(y_theta)),
        aux_theta=aux_theta, aux_phi=aux_phi, sigma_n=float(x2), tau_n=h,
    )


def plane_stress_analytic(sigma_x: float, sigma_y: float, sigma_z: float,
                          n_x: float, n_y: float, n_z: float) -> tuple[float, float]:
    """Direction-cosine result: sigma_n = sum l_i^2 s_i, tau_n = sqrt(sum l_i^2 s_i^2 - sigma_n^2)."""
    n = np.array([n_x, n_y, n_z], dtype=float)
    l2 = (n / np.linalg.norm(n)) ** 2
    s = np.array([sigma_x, sigma_y, sigma_z], dtype=float)
    sigma_n = float(l2 @ s)
    tau_n = float(np.sqrt(max(l2 @ s**2 - sigma_n**2, 0.0)))
    return sigma_n, tau_n


# --------------------------------------------------------------------------
# 3-D view (Mohr_Sub.mlapp)
# --------------------------------------------------------------------------
@dataclass
class PlaneView:
    cube_size: float
    center: np.ndarray               # cube centre
    unit_normal: np.ndarray
    plane: tuple[np.ndarray, np.ndarray, np.ndarray]  # px, py, pz (10x10), clipped to the cube
    normal_stress_vec: np.ndarray    # -sigma_n * n_hat (MATLAB sign convention)
    traction_vec: np.ndarray         # diag(-sigma) @ n_hat
    shear_vec: np.ndarray            # traction - normal_stress_vec


def plane_view(sigma_x: float, sigma_y: float, sigma_z: float,
               n_x: float, n_y: float, n_z: float, sigma_n: float) -> PlaneView:
    n = np.array([n_x, n_y, n_z], dtype=float)
    n_hat = n / np.linalg.norm(n)
    cube = float(max(sigma_x, sigma_y, sigma_z))
    center = np.full(3, cube / 2)
    half = cube * 0.5
    px, py = np.meshgrid(np.linspace(-half, half, 10), np.linspace(-half, half, 10))
    with np.errstate(divide="ignore", invalid="ignore"):
        pz = -(n_hat[0] * px + n_hat[1] * py) / n_hat[2]
    px = np.clip(px + center[0], 0, cube)
    py = np.clip(py + center[1], 0, cube)
    pz = np.clip(pz + center[2], 0, cube)
    normal_vec = -sigma_n * n_hat
    traction = np.diag([-sigma_x, -sigma_y, -sigma_z]) @ n_hat
    shear = traction - normal_vec
    return PlaneView(cube, center, n_hat, (px, py, pz), normal_vec, traction, shear)
