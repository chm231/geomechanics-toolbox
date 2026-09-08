"""3D DFN Generation window (port of threeddfngui.fig / threeddfngui.m)."""
from __future__ import annotations

import numpy as np
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QCheckBox, QComboBox, QFileDialog, QFormLayout, QGridLayout, QGroupBox, QHBoxLayout, QLabel,
    QLineEdit, QMessageBox, QPushButton, QRadioButton, QScrollArea, QSlider, QTabWidget, QVBoxLayout, QWidget,
)

from geomech.core import dfn
from geomech.gui.mplcanvas import MplWidget
from geomech.gui.util import fit_scroll_width


def _edit(text: str, width: int = 70) -> QLineEdit:
    e = QLineEdit(text)
    e.setAlignment(Qt.AlignmentFlag.AlignRight)
    e.setMaximumWidth(width)
    return e


class DFNPanel(QTabWidget):
    """Two generators behind one window: the toolbox generator (threeddfngui.m) and the
    rock-mass generator of the DFN project (multi-set, P32-based)."""

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("3D Discrete Fracture Network")
        from geomech.gui.dfn_rockmass_panel import DFNRockMassPanel
        self.toolbox = DFNToolboxPanel()
        self.rockmass = DFNRockMassPanel()
        self.addTab(self.toolbox, "Toolbox mode (single set, MATLAB)")
        self.addTab(self.rockmass, "Rock-mass mode (multi-set, P32)")
        self.setDocumentMode(True)


class DFNToolboxPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.dfn: dfn.DFN | None = None
        self.drill: dfn.DrillResult | None = None
        self._build()

    def _build(self):
        root = QHBoxLayout(self)
        left_w = QWidget(); left = QVBoxLayout(left_w)
        scroll = QScrollArea(); scroll.setWidgetResizable(True); scroll.setWidget(left_w); scroll.setMinimumWidth(400)
        root.addWidget(scroll, 0)

        g = QGroupBox("Domain")
        grid = QGridLayout(g)
        self.in_x0, self.in_y0, self.in_z0 = _edit("10"), _edit("10"), _edit("10")
        self.in_domx, self.in_domy, self.in_domz = _edit("0"), _edit("0"), _edit("5")
        grid.addWidget(QLabel("Size X / Y / Z (m)"), 0, 0)
        for c, e in enumerate((self.in_x0, self.in_y0, self.in_z0)):
            grid.addWidget(e, 0, c + 1)
        grid.addWidget(QLabel("Centre X / Y / depth Z (m)"), 1, 0)
        for c, e in enumerate((self.in_domx, self.in_domy, self.in_domz)):
            grid.addWidget(e, 1, c + 1)
        left.addWidget(g)

        g = QGroupBox("Fracture orientation (Fisher)")
        grid = QGridLayout(g)
        self.in_dip, self.in_dipd, self.in_K = _edit("45"), _edit("90"), _edit("20")
        grid.addWidget(QLabel("Dip (°)"), 0, 0); grid.addWidget(self.in_dip, 0, 1)
        grid.addWidget(QLabel("Dip direction (°)"), 0, 2); grid.addWidget(self.in_dipd, 0, 3)
        grid.addWidget(QLabel("Fisher K"), 1, 0); grid.addWidget(self.in_K, 1, 1)
        grid.addWidget(QLabel("Shape"), 1, 2)
        self.cb_shape = QComboBox(); self.cb_shape.addItems(dfn.SHAPES); grid.addWidget(self.cb_shape, 1, 3)
        left.addWidget(g)

        g = QGroupBox("Fracture size")
        grid = QGridLayout(g)
        self.rb_ne, self.rb_pl = QRadioButton("Negative exponential"), QRadioButton("Power law")
        self.rb_ne.setChecked(True)
        self.rb_ne.toggled.connect(lambda *_: self._size_changed())
        self.in_n, self.in_len = _edit("100"), _edit("2")
        self.in_fracd, self.in_trim, self.in_curt = _edit("2.5"), _edit("0.5"), _edit("10")
        grid.addWidget(self.rb_ne, 0, 0, 1, 2); grid.addWidget(QLabel("Number"), 1, 0); grid.addWidget(self.in_n, 1, 1)
        grid.addWidget(QLabel("Mean length (m)"), 2, 0); grid.addWidget(self.in_len, 2, 1)
        grid.addWidget(self.rb_pl, 0, 2, 1, 2); grid.addWidget(QLabel("Exponent D"), 1, 2); grid.addWidget(self.in_fracd, 1, 3)
        grid.addWidget(QLabel("Min / max (m)"), 2, 2); row = QHBoxLayout(); row.addWidget(self.in_trim); row.addWidget(self.in_curt); grid.addLayout(row, 2, 3)
        self.btn_count = QPushButton("Number from density"); self.btn_count.clicked.connect(self.count_from_density)
        grid.addWidget(self.btn_count, 3, 2, 1, 2)
        left.addWidget(g)

        g = QGroupBox("Aperture (µm)")
        grid = QGridLayout(g)
        self.cb_ap = QComboBox(); self.cb_ap.addItems(dfn.APERTURE_MODELS)
        self.in_apm, self.in_aps = _edit("100"), _edit("20")
        grid.addWidget(self.cb_ap, 0, 0, 1, 2)
        grid.addWidget(QLabel("Mean"), 1, 0); grid.addWidget(self.in_apm, 1, 1)
        grid.addWidget(QLabel("Std. dev."), 1, 2); grid.addWidget(self.in_aps, 1, 3)
        left.addWidget(g)

        row = QHBoxLayout()
        row.addWidget(QLabel("Seed")); self.in_seed = _edit("1", 60); row.addWidget(self.in_seed)
        self.btn_gen = QPushButton("Generate"); self.btn_gen.setStyleSheet("font-weight: bold;"); self.btn_gen.clicked.connect(self.generate)
        self.btn_ver = QPushButton("Verification"); self.btn_ver.clicked.connect(self.verification)
        row.addWidget(self.btn_gen); row.addWidget(self.btn_ver)
        left.addLayout(row)
        self.lbl_info = QLabel(""); self.lbl_info.setWordWrap(True); left.addWidget(self.lbl_info)

        g = QGroupBox("Sampling window (plane)")
        grid = QGridLayout(g)
        self.in_swdip, self.in_swdipd, self.in_swd = _edit("60"), _edit("30"), _edit("0.5")
        grid.addWidget(QLabel("Dip (°)"), 0, 0); grid.addWidget(self.in_swdip, 0, 1)
        grid.addWidget(QLabel("Dip dir. (°)"), 0, 2); grid.addWidget(self.in_swdipd, 0, 3)
        grid.addWidget(QLabel("Distance d"), 1, 0); grid.addWidget(self.in_swd, 1, 1)
        self.btn_sw = QPushButton("Plot traces"); self.btn_sw.clicked.connect(self.window_plot)
        grid.addWidget(self.btn_sw, 1, 2, 1, 2)
        self.sl_sw = QSlider(Qt.Orientation.Horizontal); self.sl_sw.setRange(-50, 50); self.sl_sw.setValue(0)
        self.sl_sw.valueChanged.connect(self.window_slider)
        grid.addWidget(QLabel("Move plane"), 2, 0); grid.addWidget(self.sl_sw, 2, 1, 1, 3)
        left.addWidget(g)

        g = QGroupBox("Drillhole")
        grid = QGridLayout(g)
        self.in_dx, self.in_dy, self.in_dz = _edit("0"), _edit("0"), _edit("0")
        self.in_dd, self.in_dr = _edit("10"), _edit("0.25")
        grid.addWidget(QLabel("Collar X / Y / Z"), 0, 0)
        for c, e in enumerate((self.in_dx, self.in_dy, self.in_dz)):
            grid.addWidget(e, 0, c + 1)
        grid.addWidget(QLabel("Depth"), 1, 0); grid.addWidget(self.in_dd, 1, 1)
        grid.addWidget(QLabel("Radius"), 1, 2); grid.addWidget(self.in_dr, 1, 3)
        self.cb_inter, self.cb_non = QCheckBox("Show intersecting"), QCheckBox("Show non-intersecting")
        self.cb_inter.setChecked(True); self.cb_non.setChecked(True)
        grid.addWidget(self.cb_inter, 2, 0, 1, 2); grid.addWidget(self.cb_non, 2, 2, 1, 2)
        self.btn_drill = QPushButton("Classify"); self.btn_drill.clicked.connect(self.drill_classify)
        self.btn_save = QPushButton("Save data…"); self.btn_save.clicked.connect(self.save_data)
        grid.addWidget(self.btn_drill, 3, 0, 1, 2); grid.addWidget(self.btn_save, 3, 2, 1, 2)
        left.addWidget(g)
        left.addStretch(1)

        self.tabs = QTabWidget()
        self.plot3d = MplWidget(projection="3d")
        self.plot_ver = MplWidget()
        self.plot_sw = MplWidget()
        self.plot_drill = MplWidget(projection="3d")
        for w, t in ((self.plot3d, "3D DFN"), (self.plot_ver, "Verification"), (self.plot_sw, "Sampling window"), (self.plot_drill, "Drillhole")):
            self.tabs.addTab(w, t)
        root.addWidget(self.tabs, 1)
        self._size_changed()
        fit_scroll_width(scroll)          # never cut the inputs off horizontally

    # ------------------------------------------------------------ helpers

    def _size_changed(self):
        ne = self.rb_ne.isChecked()
        for e in (self.in_len,):
            e.setEnabled(ne)
        for e in (self.in_fracd, self.in_trim, self.in_curt, self.btn_count):
            e.setEnabled(not ne)

    def params(self) -> dfn.DFNParams:
        return dfn.DFNParams(
            n=int(float(self.in_n.text())), x0=float(self.in_x0.text()), y0=float(self.in_y0.text()), z0=float(self.in_z0.text()),
            domx=float(self.in_domx.text()), domy=float(self.in_domy.text()), domz=float(self.in_domz.text()),
            shape=self.cb_shape.currentText(), dip=float(self.in_dip.text()), dipdir=float(self.in_dipd.text()), K=float(self.in_K.text()),
            size_model="Negative exponential" if self.rb_ne.isChecked() else "Power law",
            mean_len=float(self.in_len.text()), fracd=float(self.in_fracd.text()), trim=float(self.in_trim.text()), curt=float(self.in_curt.text()),
            aperture_model=self.cb_ap.currentText(), ap_mean=float(self.in_apm.text()), ap_std=float(self.in_aps.text()),
        )

    def count_from_density(self):
        try:
            self.in_n.setText(str(self.params().power_law_count()))
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "3D DFN", f"Invalid input:\n{e}")

    def _add_polys(self, ax, polys, color, alpha=0.7):
        ax.add_collection3d(Poly3DCollection(polys, facecolors=color, edgecolors="k", linewidths=0.3, alpha=alpha))

    def _limits(self, ax, p: dfn.DFNParams):
        ax.set_xlim(p.domx - p.x0, p.domx + p.x0); ax.set_ylim(p.domy - p.y0, p.domy + p.y0)
        ax.set_zlim(-p.domz - p.z0, -p.domz + p.z0)
        ax.set_box_aspect((2 * p.x0, 2 * p.y0, 2 * p.z0))
        ax.set_xlabel("X"); ax.set_ylabel("Y"); ax.set_zlabel("Z")

    # ------------------------------------------------------------ actions
    def generate(self):
        try:
            p = self.params()
            seed = int(float(self.in_seed.text())) if self.in_seed.text().strip() else None
            self.dfn = dfn.generate(p, seed=seed)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "3D DFN", f"Generation failed:\n{e}")
            return
        d = self.dfn
        ax = self.plot3d.clear()
        self._add_polys(ax, d.polygons, (0.8, 0.8, 1.0) if p.shape == "Square" else "red")
        self._limits(ax, p)
        ax.set_title("3D Discrete Fracture Network", fontweight="bold")
        self.plot3d.draw()
        self.lbl_info.setText(f"{d.n} fractures generated. Fisher K estimated from the realisation: K' = {d.K2:.3f}")
        self.tabs.setCurrentWidget(self.plot3d)

    def verification(self):
        if self.dfn is None:
            return
        v = dfn.verify(self.dfn)
        fig = self.plot_ver.figure; fig.clear()
        titles = (("Fracture orientation", "Angle (rad)"), ("Fracture size", "Length (m)"), ("Aperture size", "aperture (um)"))
        for i in range(3):
            ax = fig.add_subplot(2, 2, i + 1)
            w = v.hist_x[i][1] - v.hist_x[i][0] if len(v.hist_x[i]) > 1 else 1
            ax.bar(v.hist_x[i], v.hist_y[i], width=w * 0.9)
            ax.plot(v.pdf_x[i], v.pdf_y[i], "r")
            if i == 1 and self.dfn.params.size_model == "Power law":
                ax.set_xlim(self.dfn.params.trim, self.dfn.params.curt)
            ax.set_title(titles[i][0]); ax.set_xlabel(titles[i][1]); ax.set_ylabel("PDF")
        ax = fig.add_subplot(2, 2, 4); ax.axis("off")
        ax.text(0.05, 0.7, f"Reliability (100 - Σ|hist - pdf| / Σpdf):\n\n"
                           f"orientation  {v.reliability[0]:.1f} %\nsize  {v.reliability[1]:.1f} %\naperture  {v.reliability[2]:.1f} %",
                fontsize=11, va="top")
        self.plot_ver.draw()
        self.tabs.setCurrentWidget(self.plot_ver)

    def _draw_window(self, swd: float):
        d = self.dfn
        p = d.params
        w = dfn.window_traces(d, float(self.in_swdip.text()), float(self.in_swdipd.text()), swd)
        fig = self.plot_sw.figure; fig.clear()
        ax1 = fig.add_subplot(1, 2, 1, projection="3d")
        self._add_polys(ax1, d.polygons, "red", 0.5)
        apmax = d.aperture.max() if d.aperture.max() > 0 else 1.0
        for z, s in enumerate(w.segments3d):
            if s is not None:
                ax1.plot(s[:, 0], s[:, 1], s[:, 2], linewidth=2 * (1 + d.aperture[z] / apmax))
        X, Y, Z = dfn.window_plane(p, w.normal, swd)
        ax1.plot_wireframe(X, Y, Z, rstride=10, cstride=10, color="0.4", linewidth=0.4)
        self._limits(ax1, p)
        ax1.set_title("3D Discrete Fracture Network", fontweight="bold")
        ax2 = fig.add_subplot(1, 2, 2)
        for z, s in enumerate(w.segments2d):
            if s is not None:
                ax2.plot(s[:, 0], s[:, 1], linewidth=1 + d.aperture[z] / apmax)
        ax2.set_aspect("equal"); ax2.set_title("Sampling Window"); ax2.set_xlabel("Width"); ax2.set_ylabel("Height")
        ax2.set_xlim(p.domx - p.x0, p.domx + p.x0); ax2.set_ylim(p.domy - p.y0, p.domy + p.y0)
        ax2.grid(True, alpha=0.3)
        self.plot_sw.draw()
        self.tabs.setCurrentWidget(self.plot_sw)

    def window_plot(self):
        if self.dfn is None:
            return
        try:
            self._draw_window(float(self.in_swd.text()))
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "3D DFN", f"Sampling window failed:\n{e}")

    def window_slider(self, value: int):
        if self.dfn is None:
            return
        try:
            swd = dfn.window_position(self.dfn.params, float(self.in_swdip.text()), float(self.in_swdipd.text()), value / 100)
            self.in_swd.setText(f"{swd:.4g}")
            self._draw_window(swd)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "3D DFN", f"Sampling window failed:\n{e}")

    def drill_classify(self):
        if self.dfn is None:
            return
        try:
            self.drill = dfn.drill_classify(self.dfn, float(self.in_dx.text()), float(self.in_dy.text()), float(self.in_dz.text()),
                                            float(self.in_dd.text()), float(self.in_dr.text()))
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "3D DFN", f"Classification failed:\n{e}")
            return
        d, r = self.dfn, self.drill
        ax = self.plot_drill.clear()
        X, Y, Z = r.cylinder()
        ax.plot_surface(X, Y, Z, color="0.5", alpha=0.8)
        inter = [poly for poly, f in zip(d.polygons, r.intersects) if f]
        non = [poly for poly, f in zip(d.polygons, r.intersects) if not f]
        if self.cb_inter.isChecked() and inter:
            self._add_polys(ax, inter, "blue", 0.5)
        if self.cb_non.isChecked() and non:
            self._add_polys(ax, non, "red", 0.5)
        self._limits(ax, d.params)
        ax.set_title(f"Intersected Fractures with Drillhole ({r.intersects.sum()} of {d.n})", fontweight="bold")
        self.plot_drill.draw()
        self.tabs.setCurrentWidget(self.plot_drill)

    def save_data(self):
        if self.dfn is None or self.drill is None:
            QMessageBox.information(self, "3D DFN", "Run 'Classify' first.")
            return
        path, _ = QFileDialog.getSaveFileName(self, "Save data As", "", "Text files (*.txt)")
        if path:
            dfn.save_classified(path, self.dfn, self.drill)
