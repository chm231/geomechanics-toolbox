"""Borehole Stability Analyzer window (port of BSA210831_v2.m)."""
from __future__ import annotations

import numpy as np
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QButtonGroup, QCheckBox, QComboBox, QFileDialog, QFormLayout, QGridLayout, QGroupBox,
    QHBoxLayout, QLabel, QLineEdit, QMessageBox, QPushButton, QRadioButton, QScrollArea,
    QTableWidget, QTableWidgetItem, QTabWidget, QVBoxLayout, QWidget,
)

from geomech.core import borehole as bh
from geomech.gui.mplcanvas import MplWidget
from geomech.gui.worker import run_async


def _edit(text: str, width: int = 70) -> QLineEdit:
    e = QLineEdit(text)
    e.setAlignment(Qt.AlignmentFlag.AlignRight)
    e.setMaximumWidth(width)
    return e


class BoreholePanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Borehole Stability Analyzer")
        self.field: bh.StressField | None = None
        self.orient: bh.OrientationResult | None = None
        self._build()

    # ------------------------------------------------------------------ UI
    def _build(self):
        root = QHBoxLayout(self)
        left_w = QWidget()
        left = QVBoxLayout(left_w)
        scroll = QScrollArea()
        scroll.setWidgetResizable(True)
        scroll.setWidget(left_w)
        scroll.setMinimumWidth(420)
        root.addWidget(scroll, 0)

        # --- borehole information ----------------------------------------
        g = QGroupBox("Borehole Information")
        grid = QGridLayout(g)
        self.rb_one = QRadioButton("Single Orientation"); self.rb_all = QRadioButton("All Orientation")
        self.rb_one.setChecked(True)
        self.ori_group = QButtonGroup(self); self.ori_group.addButton(self.rb_one, 0); self.ori_group.addButton(self.rb_all, 1)
        self.ori_group.idToggled.connect(lambda *_: self._mode_changed())
        grid.addWidget(self.rb_one, 0, 0, 1, 2); grid.addWidget(self.rb_all, 0, 2, 1, 2)
        self.in_R, self.in_pol, self.in_azi = _edit("0.1"), _edit("0"), _edit("0")
        for r, (lbl, e, u) in enumerate((("Radius", self.in_R, "m"), ("Polar Angle", self.in_pol, "degree"),
                                         ("Azimuthal Angle", self.in_azi, "degree")), start=1):
            grid.addWidget(QLabel(lbl), r, 0); grid.addWidget(e, r, 1); grid.addWidget(QLabel(u), r, 2)
        left.addWidget(g)

        # --- elastic parameters ------------------------------------------
        g = QGroupBox("Elastic Parameters")
        v = QVBoxLayout(g)
        row = QHBoxLayout()
        self.rb_iso, self.rb_trans, self.rb_ortho = QRadioButton("Isotropic"), QRadioButton("Transversely Isotropic"), QRadioButton("Orthotropic")
        self.rb_iso.setChecked(True)
        self.el_group = QButtonGroup(self)
        for i, rb in enumerate((self.rb_iso, self.rb_trans, self.rb_ortho)):
            self.el_group.addButton(rb, i); row.addWidget(rb)
        self.el_group.idToggled.connect(lambda *_: self._elastic_changed())
        v.addLayout(row)
        grid = QGridLayout()
        self.in_v, self.in_v_, self.in_E, self.in_E_, self.in_G_ = _edit("0.25", 60), _edit("0.25", 60), _edit("100", 60), _edit("100", 60), _edit("100", 60)
        for c, (lbl, e, u) in enumerate((("ν", self.in_v, ""), ("ν'", self.in_v_, ""), ("E", self.in_E, "GPa"),
                                         ("E'", self.in_E_, "GPa"), ("G'", self.in_G_, "GPa"))):
            grid.addWidget(QLabel(lbl), 0, 2 * c); grid.addWidget(e, 1, 2 * c); grid.addWidget(QLabel(u), 1, 2 * c + 1)
        v.addLayout(grid)
        row = QHBoxLayout()
        self.cb_matrix = QComboBox()
        self.cb_matrix.addItems(["3D Elastic Modulus Matrix (Voigt)", "3D Compliance Matrix (Voigt)"])
        self.cb_matrix.setCurrentIndex(1)
        self.btn_apply = QPushButton("Apply"); self.btn_apply.clicked.connect(self.apply_elastic)
        row.addWidget(self.cb_matrix, 1); row.addWidget(self.btn_apply)
        v.addLayout(row)
        self.table = QTableWidget(6, 6)
        self.table.horizontalHeader().setVisible(False); self.table.verticalHeader().setVisible(False)
        for c in range(6):
            self.table.setColumnWidth(c, 62)
        self.table.verticalHeader().setDefaultSectionSize(22)
        self.table.setFixedHeight(6 * 22 + 4)
        v.addWidget(self.table)
        v.addWidget(QLabel("(Unit: GPa or 1/GPa)"))
        left.addWidget(g)
        self._set_table(bh.compliance_isotropic(100, 0.25))

        # --- boundary condition ------------------------------------------
        g = QGroupBox("Boundary Condition (total stresses)")
        grid = QGridLayout(g)
        self.in_S = {k: _edit("0") for k in ("Sx", "Sy", "Sz", "Sxy", "Syz", "Sxz")}
        self.in_S["Sx"].setText("30"); self.in_S["Sy"].setText("20"); self.in_S["Sz"].setText("25")
        for r, k in enumerate(("Sx", "Sy", "Sz")):
            grid.addWidget(QLabel(k), r, 0); grid.addWidget(self.in_S[k], r, 1); grid.addWidget(QLabel("MPa"), r, 2)
        for r, k in enumerate(("Sxy", "Syz", "Sxz")):
            grid.addWidget(QLabel(k), r, 3); grid.addWidget(self.in_S[k], r, 4); grid.addWidget(QLabel("MPa"), r, 5)
        self.in_Pp = _edit("10")
        grid.addWidget(QLabel("Pore Pressure"), 3, 0, 1, 1); grid.addWidget(self.in_Pp, 3, 1); grid.addWidget(QLabel("MPa"), 3, 2)
        self.cb_fluid = QCheckBox("Fluid Injection"); self.in_Pmud = _edit("0"); self.in_Pmud.setEnabled(False)
        self.cb_fluid.toggled.connect(self.in_Pmud.setEnabled)
        grid.addWidget(self.cb_fluid, 4, 0, 1, 2); grid.addWidget(QLabel("Injection Pressure"), 5, 0)
        grid.addWidget(self.in_Pmud, 5, 1); grid.addWidget(QLabel("MPa"), 5, 2)
        left.addWidget(g)

        # --- thermal -------------------------------------------------------
        g = QGroupBox("Thermal Properties")
        grid = QGridLayout(g)
        self.cb_thermal = QCheckBox("Thermal Effect"); self.in_dT, self.in_alpha = _edit("0"), _edit("0")
        self.in_dT.setEnabled(False); self.in_alpha.setEnabled(False)
        self.cb_thermal.toggled.connect(self.in_dT.setEnabled); self.cb_thermal.toggled.connect(self.in_alpha.setEnabled)
        grid.addWidget(self.cb_thermal, 0, 0, 1, 3)
        grid.addWidget(QLabel("Temperature Change"), 1, 0); grid.addWidget(self.in_dT, 1, 1); grid.addWidget(QLabel("K"), 1, 2)
        grid.addWidget(QLabel("Expansion Coef."), 2, 0); grid.addWidget(self.in_alpha, 2, 1); grid.addWidget(QLabel("1/K"), 2, 2)
        left.addWidget(g)

        # --- analysis ----------------------------------------------------
        g = QGroupBox("Select Analysis")
        grid = QGridLayout(g)
        self.rb_ana, self.rb_fem = QRadioButton("Analytic Solution"), QRadioButton("FEM")
        self.rb_ana.setChecked(True)
        self.an_group = QButtonGroup(self); self.an_group.addButton(self.rb_ana, 0); self.an_group.addButton(self.rb_fem, 1)
        grid.addWidget(self.rb_ana, 0, 0, 1, 2); grid.addWidget(self.rb_fem, 0, 2, 1, 2)
        self.in_rmesh, self.in_thmesh = _edit("60", 50), _edit("56", 50)
        grid.addWidget(QLabel("R mesh"), 1, 0); grid.addWidget(self.in_rmesh, 1, 1)
        grid.addWidget(QLabel("θ mesh (multiple of 8)"), 1, 2); grid.addWidget(self.in_thmesh, 1, 3)
        left.addWidget(g)

        self.btn_run = QPushButton("Run")
        self.btn_run.setStyleSheet("font-weight: bold; padding: 8px;")
        self.btn_run.clicked.connect(self.run)
        left.addWidget(self.btn_run)
        self.lbl_status = QLabel("")
        self.lbl_status.setWordWrap(True)
        left.addWidget(self.lbl_status)
        left.addStretch(1)

        # --- right side ----------------------------------------------------
        self.tabs = QTabWidget()
        root.addWidget(self.tabs, 1)
        self.tabs.addTab(self._build_stress_tab(), "Stress distribution")
        self.tabs.addTab(self._build_local_tab(), "Local failure analysis")
        self.plot_ucs = MplWidget(); self.plot_obb = MplWidget()
        self.tabs.addTab(self.plot_ucs, "Required UCS")
        self.tabs.addTab(self.plot_obb, "Breakout orientation")
        self._mode_changed()
        self._elastic_changed()

    def _build_stress_tab(self) -> QWidget:
        w = QWidget()
        v = QVBoxLayout(w)
        top = QHBoxLayout()
        g = QGroupBox("Plotting Option")
        grid = QGridLayout(g)
        self.cb_kind = QComboBox()
        for k, label in bh.QUANTITIES.items():
            self.cb_kind.addItem(label, k)
        grid.addWidget(self.cb_kind, 0, 0, 1, 4)
        self.rb_contour, self.rb_line = QRadioButton("Contour Graph"), QRadioButton("Line Graph")
        self.rb_contour.setChecked(True)
        self.pg = QButtonGroup(self); self.pg.addButton(self.rb_contour, 0); self.pg.addButton(self.rb_line, 1)
        self.rb_byR, self.rb_byTh = QRadioButton("by R ="), QRadioButton("by θ =")
        self.rb_byR.setChecked(True)
        self.lg = QButtonGroup(self); self.lg.addButton(self.rb_byR, 0); self.lg.addButton(self.rb_byTh, 1)
        self.in_lineR, self.in_lineTh = _edit("0.1", 60), _edit("90", 60)
        grid.addWidget(self.rb_contour, 1, 0, 1, 2); grid.addWidget(self.rb_line, 1, 2, 1, 2)
        grid.addWidget(self.rb_byR, 2, 0); grid.addWidget(self.in_lineR, 2, 1); grid.addWidget(QLabel("m"), 2, 2)
        grid.addWidget(self.rb_byTh, 3, 0); grid.addWidget(self.in_lineTh, 3, 1); grid.addWidget(QLabel("degree"), 3, 2)
        self.btn_plot = QPushButton("Plot"); self.btn_plot.clicked.connect(self.plot_stress)
        grid.addWidget(self.btn_plot, 4, 0, 1, 4)
        top.addWidget(g)

        g = QGroupBox("Failure Criteria")
        grid = QGridLayout(g)
        self.cb_fail = QCheckBox("Apply failure criteria")
        self.in_ucs, self.in_fric, self.in_ten = _edit("40", 60), _edit("30", 60), _edit("5", 60)
        grid.addWidget(self.cb_fail, 0, 0, 1, 3)
        for r, (lbl, e, u) in enumerate((("UCS", self.in_ucs, "MPa"), ("Friction Angle", self.in_fric, "degree"),
                                         ("Tensile Strength", self.in_ten, "MPa")), start=1):
            grid.addWidget(QLabel(lbl), r, 0); grid.addWidget(e, r, 1); grid.addWidget(QLabel(u), r, 2)
        self.btn_bbo = QPushButton("Breakout geometry"); self.btn_bbo.clicked.connect(self.show_breakout)
        self.btn_save = QPushButton("Save raw data…"); self.btn_save.clicked.connect(self.save_raw)
        grid.addWidget(self.btn_bbo, 4, 0, 1, 3); grid.addWidget(self.btn_save, 5, 0, 1, 3)
        top.addWidget(g)
        v.addLayout(top)
        self.lbl_bbo = QLabel("")
        v.addWidget(self.lbl_bbo)
        self.plot_stress_w = MplWidget()
        self.plot_stress_w.canvas.mpl_connect("button_press_event", self._on_click)
        v.addWidget(self.plot_stress_w, 1)
        v.addWidget(QLabel("Click on the contour plot to open the local failure analysis at that point."))
        return w

    def _build_local_tab(self) -> QWidget:
        w = QWidget()
        v = QVBoxLayout(w)
        row = QHBoxLayout()
        row.addWidget(QLabel("r ="))
        self.in_loc_r = _edit("0.1", 70); row.addWidget(self.in_loc_r); row.addWidget(QLabel("m"))
        row.addWidget(QLabel("θ ="))
        self.in_loc_th = _edit("90", 70); row.addWidget(self.in_loc_th); row.addWidget(QLabel("degree"))
        self.btn_local = QPushButton("Analyse point"); self.btn_local.clicked.connect(self.local_analysis)
        row.addWidget(self.btn_local); row.addStretch(1)
        v.addLayout(row)
        self.lbl_local = QLabel(""); self.lbl_local.setWordWrap(True)
        v.addWidget(self.lbl_local)
        self.plot_local = MplWidget()
        v.addWidget(self.plot_local, 1)
        return w

    # ------------------------------------------------------------ UI logic
    def _mode_changed(self):
        single = self.rb_one.isChecked()
        for w in (self.in_pol, self.in_azi, self.rb_trans, self.rb_ortho, self.rb_fem):
            w.setEnabled(single)
        if not single:
            self.rb_iso.setChecked(True); self.rb_ana.setChecked(True)
            self.in_pol.setText("0"); self.in_azi.setText("0")

    def _elastic_changed(self):
        iso, trans, ortho = self.rb_iso.isChecked(), self.rb_trans.isChecked(), self.rb_ortho.isChecked()
        self.in_v.setEnabled(iso or trans); self.in_E.setEnabled(iso or trans)
        for e in (self.in_v_, self.in_E_, self.in_G_):
            e.setEnabled(trans)
        self.table.setEditTriggers(QTableWidget.EditTrigger.AllEditTriggers if ortho else QTableWidget.EditTrigger.NoEditTriggers)
        self.btn_apply.setEnabled(not ortho)

    def _set_table(self, M: np.ndarray):
        for i in range(6):
            for j in range(6):
                self.table.setItem(i, j, QTableWidgetItem(f"{M[i, j]:.6g}"))

    def _get_table(self) -> np.ndarray:
        return np.array([[float(self.table.item(i, j).text()) for j in range(6)] for i in range(6)])

    def apply_elastic(self):
        try:
            if self.rb_iso.isChecked():
                S = bh.compliance_isotropic(float(self.in_E.text()), float(self.in_v.text()))
            else:
                S = bh.compliance_transverse(float(self.in_E.text()), float(self.in_E_.text()), float(self.in_v.text()),
                                             float(self.in_v_.text()), float(self.in_G_.text()))
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Borehole Stability", f"Invalid elastic parameters:\n{e}")
            return
        if self.cb_matrix.currentIndex() == 0:
            S = np.linalg.inv(S)
        self._set_table(S)

    def compliance(self) -> np.ndarray:
        M = self._get_table()
        return np.linalg.inv(M) if self.cb_matrix.currentIndex() == 0 else M

    def params(self) -> bh.BoreholeParams:
        s = {k: float(e.text()) for k, e in self.in_S.items()}
        return bh.BoreholeParams(
            self.compliance(), s["Sx"], s["Sy"], s["Sz"], s["Sxy"], s["Syz"], s["Sxz"],
            Pp=float(self.in_Pp.text()),
            Pmud=float(self.in_Pmud.text()) if self.cb_fluid.isChecked() else None,
            dT=float(self.in_dT.text()) if self.cb_thermal.isChecked() else 0.0,
            alpha=float(self.in_alpha.text()) if self.cb_thermal.isChecked() else 0.0,
            radius=float(self.in_R.text()), polar=float(self.in_pol.text()), azimuth=float(self.in_azi.text()),
        )

    def strength(self) -> bh.Strength | None:
        if not self.cb_fail.isChecked():
            return None
        return bh.Strength(float(self.in_ucs.text()), float(self.in_fric.text()), float(self.in_ten.text()))

    # ---------------------------------------------------------------- run
    def run(self):
        """Read the inputs on the GUI thread, solve in a worker thread, plot when done."""
        try:
            p = self.params()
            if self.rb_one.isChecked():
                if self.rb_fem.isChecked():
                    rmesh, thmesh = int(self.in_rmesh.text()), int(self.in_thmesh.text())
                    job, on_done = (lambda: bh.fem_solution(p, rmesh, thmesh)), self._on_field
                else:
                    job, on_done = (lambda: bh.analytic_solution(p)), self._on_field
            else:
                E, v = float(self.in_E.text()), float(self.in_v.text())
                job = lambda: bh.all_orientations(E, v, p.Sx, p.Sy, p.Sz, p.Pp, p.Pmud, p.dT, p.alpha)  # noqa: E731
                on_done = self._on_orientations
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Borehole Stability", f"Run failed:\n{e}")
            return
        run_async(self, job, on_done, title="Borehole Stability", busy=(self.btn_run,), status=self.lbl_status)

    def _on_field(self, field: bh.StressField):
        self.field = field
        self.lbl_status.setText(f"{field.method} solution computed on a {field.St.shape[0]}×{field.St.shape[1]} grid.")
        self.plot_stress()
        self.tabs.setCurrentIndex(0)

    def _on_orientations(self, o: bh.OrientationResult):
        self.orient = o
        self._plot_orientations()
        self.lbl_status.setText("All-orientation analysis computed (Sx = SHmax, Sy = Shmin, Sz = Sv).")
        self.tabs.setCurrentWidget(self.plot_ucs)

    # -------------------------------------------------------------- plots
    def plot_stress(self):
        f = self.field
        if f is None:
            return
        kind = self.cb_kind.currentData()
        val = f.quantity(kind) / bh.MPA
        title = self.cb_kind.currentText()
        ax = self.plot_stress_w.clear()
        if self.rb_contour.isChecked():
            x, y = f.r * np.cos(f.theta), f.r * np.sin(f.theta)
            pc = ax.pcolormesh(x, y, val, cmap="jet", shading="gouraud")
            self.plot_stress_w.figure.colorbar(pc, ax=ax)
            lim = f.radius * 3
            ax.set_xlim(-lim, lim); ax.set_ylim(-lim, lim)
            ax.set_aspect("equal")
            ax.set_title(title)
            s = self.strength()
            if s is not None:
                mc, tens = bh.failure_indicators(f, s)
                ax.contour(x, y, mc, levels=[0], colors="k", linewidths=1.5)
                ax.contour(x, y, tens, levels=[0], colors="r", linewidths=1.5)
        else:
            if self.rb_byR.isChecked():
                i = int(np.argmin((f.r[:, 0] - float(self.in_lineR.text())) ** 2))
                ax.plot(np.rad2deg(f.theta[i]), val[i])
                ax.set_xlabel("Angle (degree)"); ax.set_xlim(0, 360)
                ax.set_title(f"{title} at r = {f.r[i, 0]:.4g} m")
            else:
                j = int(np.argmin((f.theta[0] - np.deg2rad(float(self.in_lineTh.text()))) ** 2))
                ax.plot(f.r[:, j], val[:, j])
                ax.set_xlabel("Radius (m)")
                ax.set_title(f"{title} at θ = {np.rad2deg(f.theta[0, j]):.4g}°")
            ax.set_ylabel("Stress (MPa)")
            ax.grid(True)
        self.plot_stress_w.draw()

    def _on_click(self, event):
        if self.field is None or event.inaxes is None or not self.rb_contour.isChecked():
            return
        r, th = float(np.hypot(event.xdata, event.ydata)), float(np.rad2deg(np.arctan2(event.ydata, event.xdata)) % 360)
        if r < self.field.radius or r > self.field.radius * 3:
            return
        self.in_loc_r.setText(f"{r:.4g}"); self.in_loc_th.setText(f"{th:.4g}")
        self.local_analysis()

    def local_analysis(self):
        if self.field is None:
            return
        try:
            lm = bh.local_mohr(self.field, float(self.in_loc_r.text()), float(self.in_loc_th.text()), self.strength())
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Borehole Stability", f"Local analysis failed:\n{e}")
            return
        ax = self.plot_local.clear()
        t = lm.t / bh.MPA
        for y in lm.circles:
            ax.plot(t, y / bh.MPA, "-b")
        txt = (f"Stress at r = {lm.r:.4g} m, θ = {lm.theta_deg:.4g}°:   σrr = {lm.Sr / bh.MPA:.3f} MPa,   "
               f"σθθ = {lm.St / bh.MPA:.3f} MPa,   σz = {lm.Sz / bh.MPA:.3f} MPa   |   "
               f"σ1 = {lm.Sp1 / bh.MPA:.3f}, σ2 = {lm.Sp2 / bh.MPA:.3f}, σ3 = {lm.Sp3 / bh.MPA:.3f} MPa")
        if lm.mc_line is not None:
            ax.plot(t, lm.mc_line / bh.MPA, "-r", label="Mohr-Coulomb strength")
            ax.plot(t, lm.req_line / bh.MPA, "--r", label="Required strength")
            ax.legend(loc="upper left")
            txt += (f"\nStrength: C0 = {lm.C0 / bh.MPA:.3f} MPa,  tan φ = {np.tan(np.deg2rad(self.strength().friction)):.3f},  "
                    f"Required C0 = {lm.reqC0 / bh.MPA:.3f} MPa (MC failure criterion)")
        self.lbl_local.setText(txt)
        ax.set_xlabel("Normal Stress (MPa)"); ax.set_ylabel("Shear Stress (MPa)")
        ax.set_ylim(0, max(3 * (lm.Sp1 - lm.Sp3) / 4 / bh.MPA, 1e-6))
        ax.set_aspect("equal", adjustable="datalim")
        ax.grid(True, alpha=0.3)
        self.plot_local.draw()
        self.tabs.setCurrentIndex(1)

    def show_breakout(self):
        if self.field is None:
            return
        s = self.strength()
        if s is None:
            QMessageBox.information(self, "Borehole Stability", "Enable 'Apply failure criteria' first.")
            return
        rbbo, thbbo = bh.breakout_geometry(self.field, s)
        self.lbl_bbo.setText(f"Breakout (Mohr-Coulomb):  Rbbo = {rbbo:.5f} m,  θbbo = {thbbo:.3f}°")

    def save_raw(self):
        if self.field is None:
            return
        path, _ = QFileDialog.getSaveFileName(self, "Save as", "", "Text files (*.txt)")
        if not path:
            return
        f = self.field
        base = path[:-4] if path.lower().endswith(".txt") else path
        np.savetxt(base + "_r.txt", np.column_stack([f.theta[0], f.Sr[0] / bh.MPA]), fmt="%4f   %12.6f",
                   header="Angle (rad)  Radial stress (MPa)", comments="")
        np.savetxt(base + "_t.txt", np.column_stack([f.theta[0], f.St[0] / bh.MPA]), fmt="%4f   %12.6f",
                   header="Angle (rad)  Tangential stress (MPa)", comments="")
        s = self.strength()
        if s is not None:
            rbbo, thbbo = bh.breakout_geometry(f, s)
            with open(base + "_bbo.txt", "w", encoding="utf-8") as fh:
                fh.write(f"Rbbo = {rbbo:5f}\nθbbo = {thbbo:5f}\n")

    def _plot_orientations(self):
        o = self.orient
        ax = self.plot_ucs.clear()
        pc = ax.pcolormesh(o.X, o.Y, o.UCS, cmap="jet", shading="gouraud")
        cb = self.plot_ucs.figure.colorbar(pc, ax=ax, orientation="horizontal")
        cb.set_label("(MPa)")
        ang = np.linspace(0, 2 * np.pi, 361)
        ax.plot(o.R * np.cos(ang), o.R * np.sin(ang), "k", linewidth=0.8)
        for k in range(6):
            a = k * np.pi / 6
            ax.plot([o.R * np.cos(a), -o.R * np.cos(a)], [o.R * np.sin(a), -o.R * np.sin(a)], "k", linewidth=0.3)
        ax.annotate("SHmax", xy=(o.R * 0.98, 0), xytext=(o.R * 1.25, 0), arrowprops=dict(arrowstyle="->"), va="center")
        ax.annotate("Shmin", xy=(0, o.R * 0.98), xytext=(0, o.R * 1.25), arrowprops=dict(arrowstyle="->"), ha="center")
        ax.set_xlim(-1.4 * o.R, 1.4 * o.R); ax.set_ylim(-1.4 * o.R, 1.4 * o.R)
        ax.set_aspect("equal"); ax.set_xticks([]); ax.set_yticks([])
        ax.set_title("Required UCS (lower hemisphere, equal area)")
        self.plot_ucs.draw()

        ax = self.plot_obb.clear()
        xre, yre, red, black = o.breakout_segments()
        c = o.R / 20
        for x, y, a in zip(xre, yre, red):
            if np.isfinite(a):
                ax.plot([x + c * np.cos(a), x - c * np.cos(a)], [y + c * np.sin(a), y - c * np.sin(a)], "r", linewidth=2)
        for x, y, a in zip(xre, yre, black):
            if np.isfinite(a):
                ax.plot([x + c * np.cos(a), x - c * np.cos(a)], [y + c * np.sin(a), y - c * np.sin(a)], "k", linewidth=0.8)
        ax.plot(o.R * np.cos(ang), o.R * np.sin(ang), "k", linewidth=0.5)
        ax.set_xlim(-1.25 * o.R, 1.25 * o.R); ax.set_ylim(-1.25 * o.R, 1.25 * o.R)
        ax.set_aspect("equal"); ax.set_xticks([]); ax.set_yticks([])
        ax.set_title("Borehole Breakout Orientation")
        self.plot_obb.draw()
