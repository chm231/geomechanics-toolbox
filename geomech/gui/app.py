"""Main launcher window (port of Simulator_int.mlapp)."""
from __future__ import annotations

import sys
from pathlib import Path

from PySide6.QtCore import Qt
from PySide6.QtWidgets import (
    QApplication, QGridLayout, QLabel, QMainWindow, QPushButton, QVBoxLayout, QWidget,
)

from geomech import __version__
from geomech.gui.anisotropy_panel import AnisotropyPanel
from geomech.gui.borehole_panel import BoreholePanel
from geomech.gui.dfn_panel import DFNPanel
from geomech.gui.hydrofrac_panel import HydrofracPanel
from geomech.gui.hydroshear_panel import HydroshearPanel
from geomech.gui.mohr_panel import MohrPanel
from geomech.gui.stereonet_panel import StereonetPanel
from geomech.gui.thermal_panel import ThermalPanel

# (label, factory or None while not yet ported) - order follows Simulator_int.mlapp
MODULES = [
    ("Borehole Stability", BoreholePanel),
    ("Hydrofracturing Estimation", HydrofracPanel),
    ("Hydroshearing Estimation", HydroshearPanel),
    ("Temperature Prediction", ThermalPanel),
    ("Stereographic Projection", StereonetPanel),
    ("3D DFN Generation", DFNPanel),
    ("3D Mohr Circle", MohrPanel),
    ("Strength Anisotropy", AnisotropyPanel),
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
    argv = list(sys.argv if argv is None else argv)
    if "--smoke-test" in argv:
        # open every module, run its default case and exit (used to check a build / the exe)
        from geomech.gui import smoke
        return smoke.run(log=Path("geomech_smoke.log"))
    app = QApplication.instance() or QApplication(argv)
    win = Launcher()
    win.show()
    return app.exec()


if __name__ == "__main__":
    raise SystemExit(main())
