"""Hydrofracturing Estimation window (port of HFsim.fig / HFsim.m)."""
from __future__ import annotations

import numpy as np
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QButtonGroup, QCheckBox, QComboBox, QFormLayout, QGridLayout,
    QGroupBox, QHBoxLayout, QLabel, QLineEdit, QMessageBox, QPushButton,
    QRadioButton, QTableWidget, QTableWidgetItem, QTabWidget, QVBoxLayout, QWidget,
)

from geomech.core import hydrofrac as hf
from geomech.core import units as U
from geomech.gui.mplcanvas import MplWidget


class _Input(QWidget):
    """Number entry with a unit combo box (one row of the MATLAB baseData table)."""

    def __init__(self, kind: str, default_unit: str, value: str = ""):
        super().__init__()
        self.kind = kind
        self.edit = QLineEdit(value)
        self.edit.setAlignment(Qt.AlignmentFlag.AlignRight)
        self.unit = QComboBox()
        self.unit.addItems(U.choices(kind))
        self.unit.setCurrentText(default_unit)
        lay = QHBoxLayout(self)
        lay.setContentsMargins(0, 0, 0, 0)
        lay.addWidget(self.edit, 3)
        lay.addWidget(self.unit, 2)

    def si(self) -> float:
        txt = self.edit.text().strip()
        if not txt:
            raise ValueError("empty input")
        return U.to_si(float(txt), self.kind, self.unit.currentText())

    def unit_name(self) -> str:
        return self.unit.currentText()


class HydrofracPanel(QWidget):
    RESULT_ROWS = [
        ("Fracture length", "length"), ("Fracture height", "length"),
        ("Maximum aperture", "aperture"), ("Average aperture", "aperture"),
        ("Net pressure", "pressure"), ("Total injection time", "time"),
        ("Total injected volume", "volume"),
    ]

    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Hydraulic Fracturing Simulator")
        self.result: hf.FracResult | None = None
        self.params: hf.FracParams | None = None
        self._build()

    # ------------------------------------------------------------------ UI
    def _build(self):
        root = QHBoxLayout(self)
        left = QVBoxLayout()
        root.addLayout(left, 0)

        # --- base data ---------------------------------------------------
        g = QGroupBox("Base data")
        f = QFormLayout(g)
        self.in_E = _Input("modulus", U.DEFAULT["modulus"], "20")
        self.in_nu = QLineEdit("0.25")
        self.in_Q = _Input("rate", U.DEFAULT["rate"], "3")
        self.in_mu = _Input("viscosity", U.DEFAULT["viscosity"], "100")
        self.in_C = _Input("leakoff", U.DEFAULT["leakoff"], "0.0005")
        self.in_Sp = _Input("aperture", "mm", "1")
        self.in_Rw = _Input("length", "m", "0.1")
        f.addRow("Young's modulus", self.in_E)
        f.addRow("Poisson's ratio", self.in_nu)
        f.addRow("Injection rate (borehole)", self.in_Q)
        f.addRow("Fluid viscosity", self.in_mu)
        f.addRow("Leak-off coefficient, C", self.in_C)
        f.addRow("Spurt loss, Sp", self.in_Sp)
        f.addRow("Borehole radius", self.in_Rw)
        left.addWidget(g)

        # --- model -------------------------------------------------------
        g = QGroupBox("Fracture model")
        grid = QGridLayout(g)
        self.rb_pkn = QRadioButton("PKN fracture, height:")
        self.rb_kgd = QRadioButton("KGD fracture, height:")
        self.rb_rad = QRadioButton("Radial fracture")
        self.rb_pkn.setChecked(True)
        self.in_hPKN = _Input("length", "m", "30")
        self.in_hKGD = _Input("length", "m", "30")
        self.model_group = QButtonGroup(self)
        for i, rb in enumerate((self.rb_pkn, self.rb_kgd, self.rb_rad)):
            self.model_group.addButton(rb, i)
        grid.addWidget(self.rb_pkn, 0, 0); grid.addWidget(self.in_hPKN, 0, 1)
        grid.addWidget(self.rb_kgd, 1, 0); grid.addWidget(self.in_hKGD, 1, 1)
        grid.addWidget(self.rb_rad, 2, 0)
        self.model_group.idToggled.connect(self._model_changed)
        left.addWidget(g)

        # --- injection --------------------------------------------------
        g = QGroupBox("Injection")
        grid = QGridLayout(g)
        self.rb_time = QRadioButton("Total injection time,")
        self.rb_vol = QRadioButton("Total injected volume,")
        self.rb_time.setChecked(True)
        self.in_T = _Input("time", U.DEFAULT["time"], "60")
        self.in_V = _Input("volume", U.DEFAULT["volume"], "180")
        self.inj_group = QButtonGroup(self)
        self.inj_group.addButton(self.rb_time, 0)
        self.inj_group.addButton(self.rb_vol, 1)
        grid.addWidget(self.rb_time, 0, 0); grid.addWidget(self.in_T, 0, 1)
        grid.addWidget(self.rb_vol, 1, 0); grid.addWidget(self.in_V, 1, 1)
        self.inj_group.idToggled.connect(self._inj_changed)
        left.addWidget(g)

        self.btn_run = QPushButton("Run")
        self.btn_run.setStyleSheet("font-weight: bold; padding: 6px;")
        self.btn_run.clicked.connect(self.run)
        left.addWidget(self.btn_run)

        # --- results ----------------------------------------------------
        g = QGroupBox("Results (at end of injection)")
        v = QVBoxLayout(g)
        self.table = QTableWidget(len(self.RESULT_ROWS), 2)
        self.table.setHorizontalHeaderLabels(["Value", "Unit"])
        self.table.setVerticalHeaderLabels([r[0] for r in self.RESULT_ROWS])
        self.table.horizontalHeader().setStretchLastSection(True)
        self.table.setColumnWidth(0, 90)
        self.table.verticalHeader().setDefaultSectionSize(22)
        self.table.setMinimumHeight(22 * (len(self.RESULT_ROWS) + 1) + 8)
        self.table.setEditTriggers(QTableWidget.NoEditTriggers)
        v.addWidget(self.table)
        left.addWidget(g)
        left.addStretch(1)

        # --- right: plots --------------------------------------------------
        right = QVBoxLayout()
        root.addLayout(right, 1)

        g = QGroupBox("History plot")
        h = QHBoxLayout(g)
        self.cb_L = QCheckBox("Fracture length"); self.cb_L.setChecked(True)
        self.cb_Wmax = QCheckBox("Maximum aperture")
        self.cb_Wavg = QCheckBox("Average aperture")
        self.cb_P = QCheckBox("Net pressure")
        for cb in (self.cb_L, self.cb_Wmax, self.cb_Wavg, self.cb_P):
            h.addWidget(cb)
        h.addWidget(QLabel("vs"))
        self.rb_vs_t = QRadioButton("Injection time"); self.rb_vs_t.setChecked(True)
        self.rb_vs_V = QRadioButton("Injected volume")
        h.addWidget(self.rb_vs_t); h.addWidget(self.rb_vs_V)
        self.btn_plot = QPushButton("Plot")
        self.btn_plot.clicked.connect(self.plot_history)
        h.addWidget(self.btn_plot)
        right.addWidget(g)

        g = QGroupBox("Geometry at a given time / volume")
        h = QHBoxLayout(g)
        self.lbl_at = QLabel("At time t =")
        self.in_at = QLineEdit("60")
        self.in_at.setMaximumWidth(90)
        self.lbl_at_unit = QLabel(U.DEFAULT["time"])
        h.addWidget(self.lbl_at); h.addWidget(self.in_at); h.addWidget(self.lbl_at_unit)
        h.addSpacing(16)
        h.addWidget(QLabel("Aperture scale factor in 3D:"))
        self.in_sf = QLineEdit("5000")
        self.in_sf.setMaximumWidth(80)
        h.addWidget(self.in_sf)
        self.btn_2d = QPushButton("Plot 2D aperture profile")
        self.btn_3d = QPushButton("Plot 3D fracture shape")
        self.btn_2d.clicked.connect(self.plot_profile)
        self.btn_3d.clicked.connect(self.plot_3d)
        h.addWidget(self.btn_2d); h.addWidget(self.btn_3d)
        h.addStretch(1)
        right.addWidget(g)

        self.tabs = QTabWidget()
        self.plot_hist = MplWidget()
        self.plot_prof = MplWidget()
        self.plot_geom = MplWidget(projection="3d")
        self.tabs.addTab(self.plot_hist, "History")
        self.tabs.addTab(self.plot_prof, "2D aperture profile")
        self.tabs.addTab(self.plot_geom, "3D fracture shape")
        right.addWidget(self.tabs, 1)

        self._model_changed(0, True)
        self._inj_changed(0, True)
        self._set_outputs_enabled(False)

    def _model_changed(self, _id, _checked):
        self.in_hPKN.setEnabled(self.rb_pkn.isChecked())
        self.in_hKGD.setEnabled(self.rb_kgd.isChecked())

    def _inj_changed(self, _id, _checked):
        by_time = self.rb_time.isChecked()
        self.in_T.setEnabled(by_time)
        self.in_V.setEnabled(not by_time)
        self.lbl_at.setText("At time t =" if by_time else "At volume V =")
        self.lbl_at_unit.setText(self.in_T.unit_name() if by_time else self.in_V.unit_name())

    def _set_outputs_enabled(self, on: bool):
        for w in (self.table, self.btn_plot, self.btn_2d, self.btn_3d, self.in_at, self.in_sf,
                  self.cb_L, self.cb_Wmax, self.cb_Wavg, self.cb_P, self.rb_vs_t, self.rb_vs_V):
            w.setEnabled(on)

    # ---------------------------------------------------------------- logic
    def model(self) -> str:
        return {0: "PKN", 1: "KGD", 2: "radial"}[self.model_group.checkedId()]

    def _read_params(self) -> tuple[hf.FracParams, float]:
        m = self.model()
        h = None
        if m == "PKN":
            h = self.in_hPKN.si()
        elif m == "KGD":
            h = self.in_hKGD.si()
        p = hf.FracParams(E=self.in_E.si(), nu=float(self.in_nu.text()), Q=self.in_Q.si(),
                          mu=self.in_mu.si(), C=self.in_C.si(), Sp=self.in_Sp.si(),
                          h=h, Rw=self.in_Rw.si())
        t_final = self.in_T.si() if self.rb_time.isChecked() else self.in_V.si() / p.Q
        return p, t_final

    def _at_time(self) -> float:
        """Time [s] for the 2D/3D plots, from the 'At time / At volume' field."""
        val = float(self.in_at.text())
        if self.rb_time.isChecked():
            return U.to_si(val, "time", self.in_T.unit_name())
        return U.to_si(val, "volume", self.in_V.unit_name()) / self.params.Q

    def run(self):
        try:
            p, t_final = self._read_params()
            res = hf.simulate(self.model(), p, t_final)
        except Exception as e:  # noqa: BLE001 - show any input/solver error to the user
            QMessageBox.critical(self, "Hydrofracturing", f"Run failed:\n{e}")
            return
        self.params, self.result = p, res
        self._fill_table()
        self._set_outputs_enabled(True)
        self.in_at.setText(self.in_T.edit.text() if self.rb_time.isChecked() else self.in_V.edit.text())
        self.plot_history()

    def _display_units(self) -> dict[str, str]:
        return {"length": self.in_hPKN.unit_name(), "aperture": self.in_Sp.unit_name(),
                "pressure": U.DEFAULT["pressure"], "time": self.in_T.unit_name(),
                "volume": self.in_V.unit_name()}

    def _fill_table(self):
        r, du = self.result, self._display_units()
        height = r.height if r.height is not None else float("nan")
        vals = [r.length[-1], height, r.w_max[-1], r.w_avg[-1], r.p_net[-1], r.t[-1], r.volume[-1]]
        for i, ((_, kind), v) in enumerate(zip(self.RESULT_ROWS, vals)):
            unit = du[kind]
            txt = "-" if np.isnan(v) else f"{U.from_si(v, kind, unit):.6g}"
            self.table.setItem(i, 0, QTableWidgetItem(txt))
            self.table.setItem(i, 1, QTableWidgetItem(unit))

    # ---------------------------------------------------------------- plots
    def plot_history(self):
        if self.result is None:
            return
        r, du = self.result, self._display_units()
        vs_t = self.rb_vs_t.isChecked()
        x = U.from_si(r.t, "time", du["time"]) if vs_t else U.from_si(r.volume, "volume", du["volume"])
        xlabel = f"Injection time ({du['time']})" if vs_t else f"Injected volume ({du['volume']})"
        series = []
        if self.cb_L.isChecked():
            series.append(("Fracture length", U.from_si(r.length, "length", du["length"]), du["length"]))
        if self.cb_Wmax.isChecked():
            series.append(("Maximum fracture aperture", U.from_si(r.w_max, "aperture", du["aperture"]), du["aperture"]))
        if self.cb_Wavg.isChecked():
            series.append(("Average fracture aperture", U.from_si(r.w_avg, "aperture", du["aperture"]), du["aperture"]))
        if self.cb_P.isChecked():
            series.append(("Net fluid pressure", U.from_si(r.p_net, "pressure", du["pressure"]), du["pressure"]))
        fig = self.plot_hist.figure
        fig.clear()
        n = max(len(series), 1)
        for i, (name, y, unit) in enumerate(series):
            ax = fig.add_subplot(n, 1, i + 1)
            ax.plot(x, y)
            ax.set_ylabel(f"{name} ({unit})")
            ax.grid(True)
            if i == n - 1:
                ax.set_xlabel(xlabel)
        fig.suptitle(f"{r.model} model")
        self.plot_hist.draw()
        self.tabs.setCurrentWidget(self.plot_hist)

    def plot_profile(self):
        if self.result is None:
            return
        try:
            t = self._at_time()
            single = hf.evaluate(self.model(), self.params, t)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Hydrofracturing", f"Evaluation failed:\n{e}")
            return
        du = self._display_units()
        x, w = hf.aperture_profile(self.model(), single.length, single.w_max)
        ax = self.plot_prof.clear()
        ax.plot(U.from_si(x, "length", du["length"]), U.from_si(w, "aperture", du["aperture"]))
        ax.set_xlabel(f"Distance from borehole wall, x ({du['length']})")
        ax.set_ylabel(f"Maximum fracture aperture at x ({du['aperture']})")
        ax.grid(True)
        ax.set_title(f"{self.model()} aperture profile at t = {U.from_si(t, 'time', du['time']):.4g} {du['time']}")
        self.plot_prof.draw()
        self.tabs.setCurrentWidget(self.plot_prof)

    def plot_3d(self):
        if self.result is None:
            return
        try:
            t = self._at_time()
            sf = float(self.in_sf.text())
            single = hf.evaluate(self.model(), self.params, t)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Hydrofracturing", f"Evaluation failed:\n{e}")
            return
        du = self._display_units()
        lu = du["length"]
        L = U.from_si(single.length, "length", lu)
        W0 = U.from_si(single.w_max, "length", lu)
        Rw = U.from_si(self.params.Rw, "length", lu)
        m = self.model()
        if m == "PKN":
            mesh = hf.pkn_mesh(U.from_si(self.params.h, "length", lu), L, Rw, W0, sf)
        elif m == "KGD":
            mesh = hf.kgd_mesh(U.from_si(self.params.h, "length", lu), L, Rw, W0, sf)
        else:
            mesh = hf.radial_mesh(L, Rw, W0, sf)

        ax = self.plot_geom.clear()
        cmap = "viridis"
        vmax = mesh.cmax
        surf = None
        for sx, sy, sz in mesh.mirror:
            surf = ax.plot_surface(sx * mesh.X, sy * mesh.Y, sz * mesh.Z,
                                   facecolors=_colors(mesh.color, vmax, cmap),
                                   rstride=1, cstride=1, linewidth=0, antialiased=False,
                                   alpha=0.7, shade=True)
        # borehole cylinder (grey)
        rb, hb = mesh.borehole
        th = np.linspace(0, 2 * np.pi, 37)
        zc = np.array([-hb, hb])
        TH, ZC = np.meshgrid(th, zc)
        ax.plot_surface(rb * np.cos(TH), rb * np.sin(TH), ZC, color="0.7", alpha=0.9, linewidth=0)
        import matplotlib.cm as cm
        from matplotlib.colors import Normalize
        mappable = cm.ScalarMappable(norm=Normalize(0, vmax), cmap=cmap)
        cb = self.plot_geom.figure.colorbar(mappable, ax=ax, shrink=0.6)
        cb.set_label(f"Fracture aperture ({1 / sf:g}*{lu})")
        ax.set_xlabel(f"Distance ({lu})")
        ax.set_zlabel(f"Height ({lu})" if m != "radial" else f"Aperture ({1 / sf:g}*{lu})")
        ax.set_title(mesh.title)
        ax.view_init(elev=25, azim=135)
        try:
            ax.set_box_aspect((np.ptp(ax.get_xlim()), np.ptp(ax.get_ylim()), np.ptp(ax.get_zlim())))
        except Exception:  # noqa: BLE001 - older matplotlib
            pass
        self.plot_geom.draw()
        self.tabs.setCurrentWidget(self.plot_geom)


def _colors(values, vmax, cmap):
    import matplotlib
    from matplotlib.colors import Normalize
    return matplotlib.colormaps[cmap](Normalize(0, vmax)(values))
