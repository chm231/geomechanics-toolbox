"""Main launcher window (port of Simulator_int.mlapp)."""
from __future__ import annotations

import sys

from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QApplication, QGridLayout, QLabel, QMainWindow, QPushButton, QVBoxLayout, QWidget,
)

from geomech import __version__
from geomech.gui.hydrofrac_panel import HydrofracPanel
from geomech.gui.thermal_panel import ThermalPanel

# (label, factory or None while not yet ported) - order follows Simulator_int.mlapp
MODULES = [
    ("Borehole Stability", None),
    ("Hydrofracturing Estimation", HydrofracPanel),
    ("Hydroshearing Estimation", None),
    ("Temperature Prediction", ThermalPanel),
    ("Stereographic Projection", None),
    ("3D DFN Generation", None),
    ("3D Mohr Circle", None),
    ("Strength Anisotropy", None),
]


class Launcher(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle(f"Geomechanics Toolbox {__version__}")
        self._windows: list[QWidget] = []
        central = QWidget()
        self.setCentralWidget(central)
        v = QVBoxLayout(central)
        title = QLabel("Geomechanics Toolbox")
        title.setAlignment(Qt.AlignmentFlag.AlignCenter)
        title.setStyleSheet("font-size: 22px; font-weight: bold; margin: 12px;")
        v.addWidget(title)
        grid = QGridLayout()
        v.addLayout(grid)
        for i, (name, factory) in enumerate(MODULES):
            btn = QPushButton(name)
            btn.setMinimumSize(220, 48)
            if factory is None:
                btn.setEnabled(False)
                btn.setToolTip("Not yet ported from MATLAB")
            else:
                btn.clicked.connect(lambda _=False, f=factory: self.open_module(f))
            grid.addWidget(btn, i // 2, i % 2)
        v.addStretch(1)

    def open_module(self, factory):
        w = factory()
        w.setAttribute(Qt.WidgetAttribute.WA_DeleteOnClose)
        w.resize(1200, 720)
        w.show()
        self._windows.append(w)


def main(argv: list[str] | None = None) -> int:
    app = QApplication.instance() or QApplication(argv or sys.argv)
    win = Launcher()
    win.show()
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
