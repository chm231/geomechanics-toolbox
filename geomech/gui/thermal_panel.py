"""Temperature Prediction window (port of TherCal.fig / TherCal.m)."""
from __future__ import annotations

import numpy as np
from matplotlib.colors import Normalize
from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QButtonGroup, QCheckBox, QFileDialog, QFormLayout, QGridLayout, QGroupBox, QHBoxLayout,
    QLabel, QLineEdit, QMessageBox, QPushButton, QRadioButton, QTabWidget, QVBoxLayout, QWidget,
)

from geomech.core import thermal as th
from geomech.core.thermal_project import load_project, save_project
from geomech.gui.mplcanvas import MplWidget

# label, attribute, unit, default (defaults = src/reservTemp_projects/saveTest.txt)
BASE_FIELDS = [
    ("Specific heat of rock", "c_r", "J/kg·°C", "800"),
    ("Specific heat of fluid", "c_w", "J/kg·°C", "4178"),
    ("Rock density", "rho_r", "kg/m³", "2628"),
    ("Thermal conductivity of rock, k", "K_r", "W/m·°C", "3.018"),
    ("Initial rock temperature", "T_ro", "°C", "180"),
    ("Injection fluid temperature", "T_wo", "°C", "60"),
]
VAR_FIELDS = [
    ("Width of fracture", "L", "m", "600"),
    ("Mass flow rate", "Q_m", "kg/s", "40"),
    ("Number of fractures", "N", "", "5"),
    ("Fracture spacing", "spacing", "m", "60"),
    ("Distance from injection well", "z", "m", "800"),
    ("Time", "t_year", "years", "30"),
]
OVERRIDES = [("Width of fracture", "L", "m"), ("Mass flow rate", "Q_m", "kg/s"),
             ("Number of fractures", "N", ""), ("Fracture spacing", "spacing", "m")]


def _num_edit(text: str) -> QLineEdit:
    e = QLineEdit(text)
    e.setAlignment(Qt.AlignmentFlag.AlignRight)
    e.setMaximumWidth(110)
    return e


class ThermalPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Reservoir Temperature Calculator")
        self.fields: dict[str, QLineEdit] = {}
        self.ov_box: dict[str, QCheckBox] = {}
        self.ov_edit: dict[str, QLineEdit] = {}
        self._curves: list[tuple[np.ndarray, np.ndarray, str]] = []
        self.field: th.TemperatureField | None = None
        self.outlet: float | None = None
        self._build()

    # ------------------------------------------------------------------ UI
    def _build(self):
        root = QHBoxLayout(self)
        left = QVBoxLayout()
        root.addLayout(left, 0)

        io = QHBoxLayout()
        b_open, b_save = QPushButton("Open project…"), QPushButton("Save project…")
        b_open.clicked.connect(self.open_project)
        b_save.clicked.connect(self.save_project)
        io.addWidget(b_open); io.addWidget(b_save)
        left.addLayout(io)

        for title, spec in (("Base data", BASE_FIELDS), ("Variables", VAR_FIELDS)):
            g = QGroupBox(title)
            f = QFormLayout(g)
            for label, attr, unit, default in spec:
                row = QHBoxLayout()
                e = _num_edit(default)
                self.fields[attr] = e
                row.addWidget(e); row.addWidget(QLabel(unit)); row.addStretch(1)
                f.addRow(label, row)
            left.addWidget(g)

        g = QGroupBox("Thermal model")
        v = QVBoxLayout(g)
        self.model_group = QButtonGroup(self)
        self.rb_model: dict[str, QRadioButton] = {}
        for i, m in enumerate(th.MODELS):
            rb = QRadioButton(th.MODEL_LABELS[m])
            self.rb_model[m] = rb
            self.model_group.addButton(rb, i)
            v.addWidget(rb)
        self.rb_model["bodvarsson"].setChecked(True)
        self.model_group.idToggled.connect(lambda *_: self._model_changed())
        left.addWidget(g)

        self.btn_calc = QPushButton("Calculate temperature distribution")
        self.btn_calc.setStyleSheet("font-weight: bold; padding: 6px;")
        self.btn_calc.clicked.connect(self.calculate)
        left.addWidget(self.btn_calc)
        row = QHBoxLayout()
        row.addWidget(QLabel("Outlet fluid temperature"))
        self.out_T = QLineEdit(); self.out_T.setReadOnly(True); self.out_T.setMaximumWidth(110)
        self.out_T.setAlignment(Qt.AlignmentFlag.AlignRight)
        row.addWidget(self.out_T); row.addWidget(QLabel("°C")); row.addStretch(1)
        left.addLayout(row)
        left.addStretch(1)

        # --- right ---------------------------------------------------------
        right = QVBoxLayout()
        root.addLayout(right, 1)
        g = QGroupBox("Fluid temperature profile")
        grid = QGridLayout(g)
        self.rb_dist = QRadioButton("Distance"); self.rb_time = QRadioButton("Time (year)")
        self.rb_dist.setChecked(True)
        self.axis_group = QButtonGroup(self)
        self.axis_group.addButton(self.rb_dist, 0); self.axis_group.addButton(self.rb_time, 1)
        self.axis_group.idToggled.connect(lambda *_: self._axis_changed())
        self.in_from, self.in_to = _num_edit("0"), _num_edit("1000")
        self.lbl_from_u, self.lbl_to_u = QLabel("m"), QLabel("m")
        grid.addWidget(self.rb_dist, 0, 0); grid.addWidget(self.rb_time, 1, 0)
        grid.addWidget(QLabel("From"), 0, 1); grid.addWidget(self.in_from, 0, 2); grid.addWidget(self.lbl_from_u, 0, 3)
        grid.addWidget(QLabel("To"), 1, 1); grid.addWidget(self.in_to, 1, 2); grid.addWidget(self.lbl_to_u, 1, 3)
        for r, (label, attr, unit) in enumerate(OVERRIDES):
            cb = QCheckBox(label)
            e = _num_edit("")
            e.setEnabled(False)
            cb.toggled.connect(e.setEnabled)
            self.ov_box[attr], self.ov_edit[attr] = cb, e
            grid.addWidget(cb, r, 5); grid.addWidget(e, r, 6); grid.addWidget(QLabel(unit), r, 7)
        grid.setColumnMinimumWidth(4, 24)
        self.btn_plot = QPushButton("Plot"); self.btn_plot.clicked.connect(self.plot_profile)
        self.btn_clear = QPushButton("Clear"); self.btn_clear.clicked.connect(self.clear_profiles)
        grid.addWidget(self.btn_plot, 2, 1, 1, 2); grid.addWidget(self.btn_clear, 3, 1, 1, 2)
        right.addWidget(g)

        self.tabs = QTabWidget()
        self.plot_field = MplWidget()
        self.plot_prof = MplWidget()
        self.tabs.addTab(self.plot_field, "Rock temperature distribution")
        self.tabs.addTab(self.plot_prof, "Fluid temperature profile")
        right.addWidget(self.tabs, 1)

        self._model_changed()
        self._set_profile_enabled(False)

    def model(self) -> str:
        return th.MODELS[self.model_group.checkedId()]

    def _model_changed(self):
        m = self.model()
        self.fields["spacing"].setEnabled(m != "bodvarsson")
        self.fields["L"].setEnabled(m != "radial")
        self.ov_box["spacing"].setEnabled(m != "bodvarsson")
        self.ov_box["L"].setEnabled(m != "radial")
        if m == "bodvarsson":
            self.ov_box["spacing"].setChecked(False)
        if m == "radial":
            self.ov_box["L"].setChecked(False)

    def _axis_changed(self):
        u = "m" if self.rb_dist.isChecked() else "years"
        self.lbl_from_u.setText(u); self.lbl_to_u.setText(u)
        if self.rb_dist.isChecked():
            self.in_from.setText("0"); self.in_to.setText("1000")
        else:
            self.in_from.setText("1"); self.in_to.setText("50")

    def _set_profile_enabled(self, on: bool):
        for w in (self.rb_dist, self.rb_time, self.in_from, self.in_to, self.btn_plot, self.btn_clear,
                  *self.ov_box.values()):
            w.setEnabled(on)
        if on:
            self._model_changed()

    # ---------------------------------------------------------------- logic
    def params(self) -> th.ThermalParams:
        vals = {}
        for _, attr, _, _ in BASE_FIELDS + VAR_FIELDS:
            txt = self.fields[attr].text().strip()
            if not txt:
                raise ValueError(f"'{attr}' is empty")
            vals[attr] = int(float(txt)) if attr == "N" else float(txt)
        return th.ThermalParams(**vals)

    def set_params(self, p: th.ThermalParams):
        for _, attr, _, _ in BASE_FIELDS + VAR_FIELDS:
            self.fields[attr].setText(f"{getattr(p, attr):g}")

    def calculate(self):
        try:
            p = self.params()
            m = self.model()
            self.outlet = th.outlet_temperature(m, p)
            self.field = th.temperature_field(m, p)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Temperature Prediction", f"Calculation failed:\n{e}")
            return
        self.out_T.setText(f"{self.outlet:.2f}")
        self._draw_field()
        self._set_profile_enabled(True)
        self.tabs.setCurrentWidget(self.plot_field)

    def _draw_field(self):
        f = self.field
        ax = self.plot_field.clear()
        norm = Normalize(f.T_wo, f.T_ro)
        levels = np.linspace(f.T_wo, f.T_ro, 257)
        cs = None
        for offset, sign in f.tiles():
            cs = ax.contourf(f.along, sign * f.normal + offset, np.clip(f.T, f.T_wo, f.T_ro),
                             levels=levels, cmap="jet", norm=norm, antialiased=False)
            ax.plot([0, f.along.max()], [offset, offset], "k--", linewidth=0.5)
        cb = self.plot_field.figure.colorbar(cs, ax=ax)
        cb.set_ticks(np.round(np.linspace(f.T_wo, f.T_ro, 8), 2))
        cb.set_label("Outlet fluid temperature (°C)")
        ax.set_aspect("equal")
        ax.set_xlabel("Distance along fracture (m)")
        ax.set_ylabel("Normal distance from fracture (m)")
        ax.set_title(th.MODEL_LABELS[f.model])
        self.plot_field.draw()

    def plot_profile(self):
        try:
            p = self.params()
            start, end = float(self.in_from.text()), float(self.in_to.text())
            overrides = {}
            for attr, cb in self.ov_box.items():
                if cb.isChecked() and cb.isEnabled():
                    v = float(self.ov_edit[attr].text())
                    overrides[attr] = int(v) if attr == "N" else v
            axis = "distance" if self.rb_dist.isChecked() else "time"
            x, T = th.profile(self.model(), p, axis, start, end, **overrides)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Temperature Prediction", f"Plot failed:\n{e}")
            return
        self._curves.append((x, T, th.legend_label(**overrides)))
        self._draw_profiles(axis, start, end, p.T_ro)
        self.tabs.setCurrentWidget(self.plot_prof)

    def _draw_profiles(self, axis: str, start: float, end: float, T_ro: float):
        ax = self.plot_prof.clear()
        for x, T, label in self._curves:
            ax.plot(x, T, linewidth=2, label=label)
        ax.set_xlabel("Distance (m)" if axis == "distance" else "Time (year)")
        ax.set_ylabel("Fluid temperature (°C)")
        ax.set_xlim(start, end); ax.set_ylim(0, T_ro)
        ax.grid(True, which="both")
        ax.minorticks_on()
        if self._curves:
            ax.legend(loc="lower right" if axis == "distance" else "lower left")
        self.plot_prof.draw()

    def clear_profiles(self):
        self._curves.clear()
        self.plot_prof.clear()
        self.plot_prof.draw()

    # ---------------------------------------------------------------- files
    def open_project(self):
        path, _ = QFileDialog.getOpenFileName(self, "File open", "", "Text files (*.txt)")
        if not path:
            return
        try:
            model, p, outlet = load_project(path)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Temperature Prediction", f"Could not read project:\n{e}")
            return
        self.rb_model[model].setChecked(True)
        self.set_params(p)
        self.out_T.setText("" if outlet is None else f"{outlet:.2f}")

    def save_project(self):
        path, _ = QFileDialog.getSaveFileName(self, "Save as", "", "Text files (*.txt)")
        if not path:
            return
        try:
            save_project(path, self.model(), self.params(), self.outlet, self.field)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Temperature Prediction", f"Could not save project:\n{e}")
