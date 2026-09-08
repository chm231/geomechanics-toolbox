"""Main launcher window (port of Simulator_int.mlapp)."""
from __future__ import annotations

import os
import sys
from pathlib import Path

from PySide6.QtCore import QSettings, Qt
from PySide6.QtWidgets import (
    QApplication, QCheckBox, QGridLayout, QHBoxLayout, QLabel, QMainWindow, QPushButton, QSpinBox, QVBoxLayout, QWidget,
)

from geomech import __version__
from geomech.gui.anisotropy_panel import AnisotropyPanel
from geomech.gui.borehole_panel import BoreholePanel
from geomech.gui.dfn_panel import DFNPanel
from geomech.gui.hydrofrac_panel import HydrofracPanel
from geomech.gui.hydroshear_panel import HydroshearPanel
from geomech.gui import plotstyle
from geomech.gui.mplcanvas import MplWidget
from geomech.gui.mohr_panel import MohrPanel
from geomech.gui.stereonet_panel import StereonetPanel
from geomech.gui.thermal_panel import ThermalPanel
from geomech.gui.util import default_window_size

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
        self.cb_style = QCheckBox("Scientific plot style (serif fonts, inward ticks, ×10ⁿ exponents)")
        self.cb_style.setToolTip("Applies to every figure; 'Publication figure…' on a plot saves it at 600 dpi in this style.")
        self.cb_style.setChecked(plotstyle.enabled())
        self.cb_style.toggled.connect(self.set_plot_style)
        v.addWidget(self.cb_style)
        row = QHBoxLayout()
        row.addWidget(QLabel("Font scale"))
        self.sp_font = QSpinBox(); self.sp_font.setRange(50, 200); self.sp_font.setSingleStep(10); self.sp_font.setSuffix(" %")
        self.sp_font.setValue(int(round(plotstyle.font_scale() * 100)))
        self.sp_font.setToolTip("Multiplies the (already size-adaptive) fonts of the scientific style and of publication exports.")
        self.sp_font.valueChanged.connect(self.set_font_scale)
        row.addWidget(self.sp_font); row.addStretch(1)
        v.addLayout(row)

    def set_plot_style(self, flag: bool):
        plotstyle.set_enabled(flag)
        settings().setValue("scientific_style", bool(flag))
        self._restyle_open_windows()

    def set_font_scale(self, percent: int):
        plotstyle.set_font_scale(percent / 100.0)
        settings().setValue("plot_font_scale", int(percent))
        self._restyle_open_windows()

    def _restyle_open_windows(self):
        for win in self._windows:                       # restyle what is already on screen
            for mw in win.findChildren(MplWidget):
                mw.draw()

    def open_module(self, factory):
        w = factory()
        w.setAttribute(Qt.WidgetAttribute.WA_DeleteOnClose)
        w.resize(*default_window_size(w))      # the panel's own size hint, clamped to the screen
        w.show()
        self._windows.append(w)


def settings() -> QSettings:
    return QSettings("Geomechanics Toolbox", "GeomechanicsToolbox")


def apply_saved_plot_style() -> None:
    """Plot style from the saved preference, or GEOMECH_SCIENTIFIC=1 for scripts and screenshots."""
    plotstyle.set_enabled(os.environ.get("GEOMECH_SCIENTIFIC") == "1"
                          or settings().value("scientific_style", False, type=bool))
    plotstyle.set_font_scale(settings().value("plot_font_scale", 100, type=int) / 100.0)


def main(argv: list[str] | None = None) -> int:
    argv = list(sys.argv if argv is None else argv)
    apply_saved_plot_style()
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
