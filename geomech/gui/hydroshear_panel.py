"""Hydroshearing Estimation window (port of HSsim.fig / HSsim.m)."""
from __future__ import annotations

import numpy as np
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QCheckBox, QFileDialog, QFormLayout, QGridLayout, QGroupBox, QHBoxLayout, QLabel, QLineEdit,
    QMessageBox, QPushButton, QTableWidget, QTableWidgetItem, QTabWidget, QVBoxLayout, QWidget,
)

from geomech.core import hydroshear as hs
from geomech.gui.mplcanvas import MplWidget

MPA = 1e6


def _edit(text: str, width: int = 80) -> QLineEdit:
    e = QLineEdit(text)
    e.setAlignment(Qt.AlignmentFlag.AlignRight)
    e.setMaximumWidth(width)
    return e


class HydroshearPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Hydraulic Shearing Simulator")
        self._build()

    def _build(self):
        root = QHBoxLayout(self)
        left = QVBoxLayout()
        root.addLayout(left, 0)

        g = QGroupBox("In-situ stress")
        grid = QGridLayout(g)
        grid.addWidget(QLabel("Magnitude"), 0, 1); grid.addWidget(QLabel("Azimuth"), 0, 3)
        self.in_Sv, self.in_SH, self.in_Sh, self.in_azi = _edit("30"), _edit("40"), _edit("25"), _edit("0")
        grid.addWidget(QLabel("Sv"), 1, 0); grid.addWidget(self.in_Sv, 1, 1); grid.addWidget(QLabel("MPa"), 1, 2)
        grid.addWidget(QLabel("SHmax"), 2, 0); grid.addWidget(self.in_SH, 2, 1); grid.addWidget(QLabel("MPa"), 2, 2)
        grid.addWidget(self.in_azi, 2, 3); grid.addWidget(QLabel("deg."), 2, 4)
        grid.addWidget(QLabel("Shmin"), 3, 0); grid.addWidget(self.in_Sh, 3, 1); grid.addWidget(QLabel("MPa"), 3, 2)
        left.addWidget(g)

        g = QGroupBox("Rock / fluid")
        f = QFormLayout(g)
        self.in_phi, self.in_rr, self.in_rf, self.in_alpha = _edit("30"), _edit("2600"), _edit("1000"), _edit("0.5")
        for lbl, e, u in (("Friction angle", self.in_phi, "deg."), ("Rock density", self.in_rr, "kg/m³"),
                          ("Fluid density", self.in_rf, "kg/m³"), ("Coefficient α for Pco", self.in_alpha, "")):
            row = QHBoxLayout(); row.addWidget(e); row.addWidget(QLabel(u)); row.addStretch(1)
            f.addRow(lbl, row)
        left.addWidget(g)

        g = QGroupBox("Joints")
        v = QVBoxLayout(g)
        row = QHBoxLayout()
        self.in_dip, self.in_dd = _edit("60", 60), _edit("120", 60)
        row.addWidget(QLabel("Dip:")); row.addWidget(self.in_dip); row.addWidget(QLabel("deg."))
        row.addWidget(QLabel("Dip direction:")); row.addWidget(self.in_dd); row.addWidget(QLabel("deg."))
        self.btn_add = QPushButton("Add"); self.btn_add.clicked.connect(self.add_joint)
        row.addWidget(self.btn_add)
        v.addLayout(row)
        row = QHBoxLayout()
        b1 = QPushButton("Load overall DFN data…"); b1.clicked.connect(lambda: self.load_dfn(False))
        b2 = QPushButton("Borehole-intersecting DFN only…"); b2.clicked.connect(lambda: self.load_dfn(True))
        b3 = QPushButton("Clear"); b3.clicked.connect(self.clear_joints)
        row.addWidget(b1); row.addWidget(b2); row.addWidget(b3)
        v.addLayout(row)
        self.table = QTableWidget(0, 4)
        self.table.setHorizontalHeaderLabels(["Dip (deg.)", "Dip direction (deg.)", "Pc (MPa)", "Initiation & propagation*"])
        self.table.horizontalHeader().setStretchLastSection(True)
        self.table.setMinimumHeight(160)
        v.addWidget(self.table)
        v.addWidget(QLabel("* 0: initiation at casing shoe & upward migration\n  1: initiation at well toe & downward migration"))
        left.addWidget(g)

        self.btn_run = QPushButton("Run")
        self.btn_run.setStyleSheet("font-weight: bold; padding: 6px;")
        self.btn_run.clicked.connect(self.quick_run)
        left.addWidget(self.btn_run)
        g = QGroupBox("Results")
        f = QFormLayout(g)
        self.out_pcm, self.out_pco, self.out_opt = QLabel("(...)"), QLabel("(...)"), QLabel("(...)")
        f.addRow("Pcm (MPa):", self.out_pcm); f.addRow("Pco (MPa):", self.out_pco)
        f.addRow("Optimal joints (dip, dip dir.):", self.out_opt)
        left.addWidget(g)

        g = QGroupBox("Advanced analysis")
        v = QVBoxLayout(g)
        self.cb_pcm = QCheckBox("Pcm distribution under various stress conditions")
        self.cb_pc = QCheckBox("Pc, Pco && shearing probability for various joint orientations")
        self.cb_pco = QCheckBox("Pco && shearing probability under various stress conditions")
        self.cb_grad = QCheckBox("dPc/dz distribution (shearing initiation location && growth direction)")
        self.cb_down = QCheckBox("Probability of downward growth under various stress conditions")
        self.cb_norm = QCheckBox("Normalize to Sv")
        for cb in (self.cb_pcm, self.cb_pc, self.cb_pco, self.cb_grad, self.cb_down):
            cb.setChecked(True); v.addWidget(cb)
        v.addWidget(self.cb_norm)
        self.btn_adv = QPushButton("Run && Plot"); self.btn_adv.clicked.connect(self.advanced_run)
        v.addWidget(self.btn_adv)
        left.addWidget(g)
        left.addStretch(1)

        self.tabs = QTabWidget()
        root.addWidget(self.tabs, 1)
        self.plots: dict[str, MplWidget] = {}
        for key, title in (("pcm", "Pcm polygon"), ("pc", "Pc stereonet & probability"), ("pco", "Pco polygon & probability"),
                           ("grad", "dPc/dz stereonet"), ("down", "Downward-growth probability")):
            w = MplWidget(); self.plots[key] = w; self.tabs.addTab(w, title)

    # ------------------------------------------------------------ joints
    def joints(self) -> np.ndarray:
        rows = []
        for i in range(self.table.rowCount()):
            a, b = self.table.item(i, 0), self.table.item(i, 1)
            if a is None or b is None or not a.text().strip():
                continue
            rows.append([float(a.text()), float(b.text())])
        return np.array(rows, dtype=float).reshape(-1, 2)

    def _set_joints(self, arr: np.ndarray):
        self.table.setRowCount(len(arr))
        for i, row in enumerate(arr):
            for j, v in enumerate(row):
                self.table.setItem(i, j, QTableWidgetItem(f"{v:g}"))
            self.table.setItem(i, 2, QTableWidgetItem("")); self.table.setItem(i, 3, QTableWidgetItem(""))

    def add_joint(self):
        try:
            j = np.vstack([self.joints(), [float(self.in_dip.text()), float(self.in_dd.text())]])
        except ValueError as e:
            QMessageBox.critical(self, "Hydroshearing", f"Invalid joint:\n{e}")
            return
        self._set_joints(j)

    def clear_joints(self):
        self.table.setRowCount(0)

    def load_dfn(self, intersecting_only: bool):
        path, _ = QFileDialog.getOpenFileName(self, "File open", "", "Text files (*.txt)")
        if not path:
            return
        try:
            self._set_joints(hs.load_dfn(path, intersecting_only))
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Hydroshearing", f"Could not read DFN file:\n{e}")

    # ------------------------------------------------------------ runs
    def params(self) -> hs.ShearParams:
        return hs.ShearParams(float(self.in_Sv.text()), float(self.in_SH.text()), float(self.in_Sh.text()),
                              float(self.in_azi.text()), float(self.in_phi.text()), float(self.in_rr.text()),
                              float(self.in_rf.text()), float(self.in_alpha.text()))

    def quick_run(self):
        try:
            q = hs.quick_run(self.params(), self.joints())
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Hydroshearing", f"Run failed:\n{e}")
            return
        self.out_pcm.setText(f"{q.Pcm:.4g}"); self.out_pco.setText(f"{q.Pco:.4g}")
        self.out_opt.setText(f"({q.optimal[0][0]:.2f}, {q.optimal[0][1]:.2f}),  ({q.optimal[1][0]:.2f}, {q.optimal[1][1]:.2f})")
        for i, row in enumerate(q.joints):
            self.table.setItem(i, 2, QTableWidgetItem(f"{row[2]:.4f}"))
            self.table.setItem(i, 3, QTableWidgetItem(f"{int(row[3])}"))

    def advanced_run(self):
        try:
            p = self.params()
            norm = self.cb_norm.isChecked()
            if self.cb_pcm.isChecked() or self.cb_pco.isChecked() or self.cb_down.isChecked():
                r = hs.polygon_group(p.phi_rad, p.Sv * MPA, p.rho_r, p.rho_f, p.alpha,
                                     with_pco=self.cb_pco.isChecked() or self.cb_down.isChecked())
                if self.cb_pcm.isChecked():
                    self._polygon(self.plots["pcm"], r, p, r.kcm, "Minimum critical pressure", "k_cm" if norm else "P_cm (MPa)", norm, scale=True)
                if self.cb_pco.isChecked():
                    self._polygon(self.plots["pco"], r, p, r.kco, "Cut-off pressure" + (", kco" if norm else ", Pco"),
                                  "k_co" if norm else "P_co (MPa)", norm, scale=True,
                                  second=(r.pro_pco, "Probability of shearing with high tendency (by " + ("kco" if norm else "Pco") + ")"))
                if self.cb_down.isChecked():
                    self._polygon(self.plots["down"], r, p, r.pro_down, "Probability of downward shearing", "", norm, scale=False)
            if self.cb_pc.isChecked() or self.cb_grad.isChecked():
                s = hs.stereonet_group(p.S123, p.Sv * MPA, p.phi_rad, p.rho_r, p.rho_f, p.alpha, with_prob=self.cb_pc.isChecked())
                if self.cb_pc.isChecked():
                    self._stereonet_pc(s, p, norm)
                if self.cb_grad.isChecked():
                    self._stereonet_grad(s)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Hydroshearing", f"Advanced analysis failed:\n{e}")
            return
        for key, cb in (("pcm", self.cb_pcm), ("pc", self.cb_pc), ("pco", self.cb_pco), ("grad", self.cb_grad), ("down", self.cb_down)):
            if cb.isChecked():
                self.tabs.setCurrentWidget(self.plots[key])
                break

    # ------------------------------------------------------------ plots
    def _polygon(self, w: MplWidget, r: hs.PolygonResult, p: hs.ShearParams, z, title, cbar, norm, scale, second=None):
        fig = w.figure; fig.clear()
        f = 1.0 if norm else p.Sv
        axes = [fig.add_subplot(1, 2 if second else 1, 1)]
        panels = [(z * (f if scale else 1.0), title, cbar)]
        if second is not None:
            axes.append(fig.add_subplot(1, 2, 2)); panels.append((second[0], second[1], ""))
        for ax, (val, ttl, cb_label) in zip(axes, panels):
            cs = ax.contourf(r.x * f, r.y * f, val, 80, cmap="jet")
            cb = fig.colorbar(cs, ax=ax); cb.set_label(cb_label)
            solid, dashed = r.frame_lines()
            for xs, ys in solid:
                ax.plot(np.array(xs) * f, np.array(ys) * f, "k", linewidth=1)
            for xs, ys in dashed:
                ax.plot(np.array(xs) * f, np.array(ys) * f, "--k")
            ax.set_xlim(0, 1.1 * r.mup / r.mum * f); ax.set_ylim(0, 1.1 * r.mup / r.mum * f)
            ax.set_aspect("equal")
            ax.set_xlabel("Normalized min. horizontal stress, k_h" if norm else "Min. horizontal stress, Shmin (MPa)", fontweight="bold")
            ax.set_ylabel("Normalized max. horizontal stress, k_H" if norm else "Max. horizontal stress, SHmax (MPa)", fontweight="bold")
            ax.set_title(ttl, fontweight="bold")
        w.draw()

    def _stereonet_pc(self, s: hs.StereonetResult, p: hs.ShearParams, norm: bool):
        w = self.plots["pc"]; fig = w.figure; fig.clear()
        f = 1.0 if norm else p.Sv
        ax1 = fig.add_subplot(1, 2, 1)
        cs = ax1.contourf(s.y, s.x, s.kc * f, 80, cmap="jet")
        cb = fig.colorbar(cs, ax=ax1, shrink=0.55); cb.set_label("k_c" if norm else "P_c (MPa)")
        c = ax1.contour(s.y, s.x, s.kc * f, levels=sorted([s.nor_Pco * f, s.nor_sig3 * f]), colors="k", linewidths=2)
        ax1.clabel(c, fontsize=10, colors="yellow")
        ax1.set_aspect("equal"); ax1.set_axis_off()
        ax1.set_title("Normalized critical pressure for shearing" if norm else "Critical pressure for shearing", fontweight="bold")
        ax2 = fig.add_subplot(1, 2, 2)
        ax2.plot(s.p * f, s.prob * 100, "k", linewidth=1.5)
        ax2.grid(True)
        ax2.set_xlabel("Normalized injection pressure, k_PP" if norm else "Injection pressure, P_w (MPa)")
        ax2.set_ylabel("Probability of shearing (%)")
        ax2.set_xlim(s.p.min() * f, s.p.max() * f); ax2.set_ylim(0, 100)
        dp = s.p[1] - s.p[0]
        for xv, label in ((s.nor_sig3, "k_w = k_3" if norm else "P_w = S_3"), (s.nor_Pco, "k_w = k_co" if norm else "P_w = P_co")):
            i = int(round((xv - s.nor_Pcm) / dp))
            if 0 <= i < len(s.prob):
                ax2.plot(xv * f, 100 * s.prob[i], "ks")
                ax2.text(xv * f + 0.02, 100 * s.prob[i] - 2, " " + label)
        w.draw()

    def _stereonet_grad(self, s: hs.StereonetResult):
        w = self.plots["grad"]; ax = w.clear()
        cs = ax.contourf(s.y, s.x, s.pp_gr, 80, cmap="jet")
        cb = w.figure.colorbar(cs, ax=ax); cb.set_label("P'_c (MPa/km)")
        c = ax.contour(s.y, s.x, s.pp_gr, levels=[s.gr_f], colors="k", linewidths=2)
        ax.clabel(c, fontsize=10, colors="yellow")
        ax.set_aspect("equal"); ax.set_axis_off()
        ax.set_title("Gradient of critical pressure", fontweight="bold")
        w.draw()
