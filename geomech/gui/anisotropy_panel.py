"""Strength Anisotropy window (port of anisotropy.mlapp)."""
from __future__ import annotations

from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QFormLayout, QGroupBox, QHBoxLayout, QLineEdit, QMessageBox, QPushButton, QVBoxLayout, QWidget,
)

from geomech.core import anisotropy as an
from geomech.gui.mplcanvas import MplWidget

FIELDS = [  # label, attr, default
    ("Fracture cohesion (MPa)", "c_j", "1"),
    ("Fracture friction angle (deg)", "phi_j", "30"),
    ("Rock cohesion (MPa)", "c_r", "10"),
    ("Rock friction angle (deg)", "phi_r", "35"),
    ("σ₃ (MPa)", "sigma_3", "5"),
]


class AnisotropyPanel(QWidget):
    def __init__(self, parent=None):
        super().__init__(parent)
        self.setWindowTitle("Strength Anisotropy Analysis")
        self.fields: dict[str, QLineEdit] = {}
        self._build()

    def _build(self):
        root = QHBoxLayout(self)
        left = QVBoxLayout()
        root.addLayout(left, 0)
        g = QGroupBox("Input")
        f = QFormLayout(g)
        for label, attr, default in FIELDS:
            e = QLineEdit(default)
            e.setAlignment(Qt.AlignmentFlag.AlignRight)
            e.setMaximumWidth(100)
            self.fields[attr] = e
            f.addRow(label, e)
        left.addWidget(g)
        row = QHBoxLayout()
        self.btn_add = QPushButton("Add plot"); self.btn_add.clicked.connect(self.add_plot)
        self.btn_clear = QPushButton("Clear"); self.btn_clear.clicked.connect(self.clear)
        row.addWidget(self.btn_add); row.addWidget(self.btn_clear)
        left.addLayout(row)
        left.addStretch(1)

        self.plot = MplWidget()
        root.addWidget(self.plot, 1)
        self._init_axes()

    def _init_axes(self):
        ax = self.plot.ax
        ax.set_title("Strength Anisotropy", fontweight="bold")
        ax.set_xlabel("β = angle between σ₁ and the normal to the plane of weakness (deg)")
        ax.set_ylabel("Peak strength σ₁ (MPa)")
        ax.grid(True)
        self.plot.draw()

    def values(self) -> dict[str, float]:
        return {attr: float(self.fields[attr].text()) for _, attr, _ in FIELDS}

    def add_plot(self):
        try:
            v = self.values()
            beta, s1 = an.strength_anisotropy(v["c_j"], v["phi_j"], v["c_r"], v["phi_r"], v["sigma_3"])
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Strength Anisotropy", f"Error:\n{e}")
            return
        label = f"c_j={v['c_j']:g}, φ_j={v['phi_j']:g}°, c_r={v['c_r']:g}, φ_r={v['phi_r']:g}°, σ₃={v['sigma_3']:g}"
        ax = self.plot.ax
        ax.plot(beta, s1, linewidth=2, label=label)
        ax.set_xlim(0, 90)
        ax.legend(fontsize=8)
        self.plot.draw()

    def clear(self):
        self.plot.clear()
        self._init_axes()
