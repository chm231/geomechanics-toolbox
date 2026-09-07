"""3D Mohr's Circle window (port of Mohr_Circle.mlapp + Mohr_Sub.mlapp)."""
from __future__ import annotations

import numpy as np
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QFormLayout, QGroupBox, QHBoxLayout, QLabel, QLineEdit, QMessageBox, QPushButton,
    QTabWidget, QVBoxLayout, QWidget,
)

from geomech.core import mohr
from geomech.gui.mplcanvas import MplWidget


def _edit(text: str, width: int = 90) -> QLineEdit:
    e = QLineEdit(text)
    e.setAlignment(Qt.AlignmentFlag.AlignRight)
    e.setMaximumWidth(width)
    return e


class MohrPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("3D Mohr's Circle")
        self.result: mohr.MohrResult | None = None
        self._n_plots = 0
        self._build()

    def _build(self):
        root = QHBoxLayout(self)
        left = QVBoxLayout()
        root.addLayout(left, 0)

        g = QGroupBox("Principal stresses")
        f = QFormLayout(g)
        self.in_sx, self.in_sy, self.in_sz = _edit("100"), _edit("60"), _edit("30")
        f.addRow("σx (MPa)", self.in_sx)
        f.addRow("σy (MPa)", self.in_sy)
        f.addRow("σz (MPa)", self.in_sz)
        left.addWidget(g)

        g = QGroupBox("Normal vector of the plane")
        h = QHBoxLayout(g)
        self.in_nx, self.in_ny, self.in_nz = _edit("1", 50), _edit("1", 50), _edit("1", 50)
        for lbl, e in (("nx", self.in_nx), ("ny", self.in_ny), ("nz", self.in_nz)):
            h.addWidget(QLabel(lbl)); h.addWidget(e)
        left.addWidget(g)

        row = QHBoxLayout()
        self.btn_add = QPushButton("Add plot"); self.btn_add.clicked.connect(self.add_plot)
        self.btn_clear = QPushButton("Clear"); self.btn_clear.clicked.connect(self.clear)
        row.addWidget(self.btn_add); row.addWidget(self.btn_clear)
        left.addLayout(row)

        g = QGroupBox("Stress on the plane")
        f = QFormLayout(g)
        self.out_sn, self.out_tn = _edit("", 110), _edit("", 110)
        self.out_sn.setReadOnly(True); self.out_tn.setReadOnly(True)
        f.addRow("σn (MPa)", self.out_sn)
        f.addRow("τn (MPa)", self.out_tn)
        left.addWidget(g)

        self.btn_3d = QPushButton("View in 3D")
        self.btn_3d.setStyleSheet("padding: 8px; font-size: 13px;")
        self.btn_3d.clicked.connect(self.view_3d)
        self.btn_3d.setEnabled(False)
        left.addWidget(self.btn_3d)

        g = QGroupBox("Stress components on the plane (MPa)")
        f = QFormLayout(g)
        self.out_vec_sn, self.out_vec_tn, self.out_vec_Tn = _edit("", 160), _edit("", 160), _edit("", 160)
        for e in (self.out_vec_sn, self.out_vec_tn, self.out_vec_Tn):
            e.setReadOnly(True); e.setAlignment(Qt.AlignmentFlag.AlignLeft)
        f.addRow("σn", self.out_vec_sn)
        f.addRow("τn", self.out_vec_tn)
        f.addRow("Tn", self.out_vec_Tn)
        left.addWidget(g)
        left.addStretch(1)

        self.tabs = QTabWidget()
        self.plot2d = MplWidget()
        self.plot3d = MplWidget(projection="3d")
        self.tabs.addTab(self.plot2d, "Mohr's circles")
        self.tabs.addTab(self.plot3d, "3D view")
        root.addWidget(self.tabs, 1)
        self._init_axes()

    def _init_axes(self):
        ax = self.plot2d.ax
        ax.set_xlabel("Normal Stress (MPa)")
        ax.set_ylabel("Shear Stress (MPa)")
        ax.set_title("3D Mohr's Circle", fontweight="bold")
        ax.set_aspect("equal", adjustable="box")
        ax.grid(True, alpha=0.3)
        self.plot2d.draw()

    def _inputs(self):
        return (float(self.in_sx.text()), float(self.in_sy.text()), float(self.in_sz.text()),
                float(self.in_nx.text()), float(self.in_ny.text()), float(self.in_nz.text()))

    # ---------------------------------------------------------------- 2D
    def add_plot(self):
        try:
            inputs = self._inputs()
            r = mohr.mohr_3d(*inputs)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "3D Mohr's Circle", f"Error:\n{e}")
            return
        self.result, self._inputs_used = r, inputs
        self._n_plots += 1
        ax = self.plot2d.ax
        for c in r.circles:
            ax.plot(*c.points(), "k", linewidth=2)
        ax.plot(*r.p_phi, "o", markersize=5, markerfacecolor="blue", markeredgecolor="blue")
        ax.plot(*r.p_theta, "o", markersize=5, markerfacecolor="blue", markeredgecolor="blue")
        ax.axvline(0, color="k", linewidth=1)
        ax.axhline(0, color="k", linewidth=1)
        ax.plot(*r.aux_theta.points(), "k--", linewidth=1)
        ax.plot(*r.aux_phi.points(), "k--", linewidth=1)
        ax.plot([r.sigma_n], [r.tau_n], "o", markersize=10, markerfacecolor="red", markeredgecolor="red")
        all_x = np.concatenate([c.points()[0] for c in (*r.circles, r.aux_theta, r.aux_phi)])
        all_y = np.concatenate([c.points()[1] for c in (*r.circles, r.aux_theta, r.aux_phi)])
        ax.plot([r.sigma_n, r.sigma_n], [r.tau_n, 0], "k--", linewidth=1)
        ax.plot([r.sigma_n, 0], [r.tau_n, r.tau_n], "k--", linewidth=1)
        ax.text(r.sigma_n, 0, f"  {r.sigma_n:.4g}", va="bottom", ha="right")
        ax.text(all_x.min(), r.tau_n, f"  {r.tau_n:.4g}", va="top", ha="left")
        for s, name in zip(r.sigma, ("σ₁", "σ₂", "σ₃")):
            ax.text(s + 0.5, 0, name, va="top", ha="left", fontsize=14)
        lo, hi = ax.get_xlim() if self._n_plots > 1 else (all_x.min(), all_x.max())
        ax.set_xlim(min(lo, all_x.min()), max(hi, all_x.max()))
        ax.set_ylim(0, max(ax.get_ylim()[1] if self._n_plots > 1 else 0, all_y.max() * 1.05))
        self.plot2d.draw()
        self.tabs.setCurrentWidget(self.plot2d)
        self.out_sn.setText(f"{r.sigma_n:.4f}")
        self.out_tn.setText(f"{r.tau_n:.4f}")
        self.btn_3d.setEnabled(True)

    def clear(self):
        self.plot2d.clear()
        self._init_axes()
        self._n_plots = 0

    # ---------------------------------------------------------------- 3D
    def view_3d(self):
        if self.result is None:
            return
        sx, sy, sz, nx, ny, nz = self._inputs_used
        v = mohr.plane_view(sx, sy, sz, nx, ny, nz, self.result.sigma_n)
        cube, c = v.cube_size, v.center
        ax = self.plot3d.clear()
        # cube edges + translucent faces
        V = np.array([[0, 0, 0], [cube, 0, 0], [cube, cube, 0], [0, cube, 0],
                      [0, 0, cube], [cube, 0, cube], [cube, cube, cube], [0, cube, cube]], dtype=float)
        faces = [[0, 1, 2, 3], [4, 5, 6, 7], [0, 1, 5, 4], [1, 2, 6, 5], [2, 3, 7, 6], [3, 0, 4, 7]]
        ax.add_collection3d(Poly3DCollection([V[f] for f in faces], facecolors=(0, 0, 1, 0.12),
                                             edgecolors="black", linewidths=1.5))
        for vec in np.eye(3) * cube:
            ax.quiver(0, 0, 0, *vec, color="k", linewidth=2, arrow_length_ratio=0.05)
        px, py, pz = v.plane
        ax.plot_surface(px, py, pz, color="red", alpha=0.5, linewidth=0)
        for vec, label in ((v.normal_stress_vec, "σn"), (v.traction_vec, "Tn"), (v.shear_vec, "τn")):
            d = 0.5 * vec
            ax.quiver(*c, *d, color="k", linewidth=2, arrow_length_ratio=0.15)
            ax.text(*(c + d), label, fontsize=10, color="k")
        # boundary stress arrows (red) - MATLAB draws 10-unit arrows into (+) or out of (-) each face
        for i, s in enumerate((sx, sy, sz)):
            if s == 0:
                continue
            e = np.zeros(3); e[i] = 1.0
            if s > 0:
                start = c.copy(); start[i] = -10.0
                ax.quiver(*start, *(10 * e), color="red", linewidth=2, arrow_length_ratio=0.3)
                ax.text(*start, ("σx", "σy", "σz")[i], fontsize=10, color="red")
            else:
                start = c.copy(); start[i] = 0.0
                ax.quiver(*start, *(-10 * e), color="red", linewidth=2, arrow_length_ratio=0.3)
                ax.text(*(start - 10 * e), ("σx", "σy", "σz")[i], fontsize=10, color="red")
        ax.set_xlim(-10, cube + 10); ax.set_ylim(-10, cube + 10); ax.set_zlim(-10, cube + 10)
        ax.set_box_aspect((1, 1, 1))
        ax.set_xlabel("σx (MPa)"); ax.set_ylabel("σy (MPa)"); ax.set_zlabel("σz (MPa)")
        ax.set_title("Plane and stress vectors")
        self.plot3d.draw()
        self.tabs.setCurrentWidget(self.plot3d)
        fmt = lambda a: "( " + ", ".join(f"{x:.1f}" for x in a) + " )"  # noqa: E731
        self.out_vec_Tn.setText(fmt(v.traction_vec))
        self.out_vec_tn.setText(fmt(v.shear_vec))
        self.out_vec_sn.setText(fmt(v.normal_stress_vec))
