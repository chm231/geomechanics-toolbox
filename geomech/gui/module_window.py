"""Frame around a module panel: a menu bar with the plot options.

    Plot > Larger fonts (Ctrl +) / Smaller fonts (Ctrl -) / Reset font scale (Ctrl 0)
    Plot > Font scale [spin box, 50-200 %]
    Plot > Publication figure… (Ctrl E)   - saves the plot shown in the window

The scientific plot style is always on; the font scale is global (every open plot follows,
every module menu shows the same value) and is saved between runs.
"""
from __future__ import annotations

from PySide6.QtCore import QSettings, Qt
from PySide6.QtGui import QAction, QKeySequence
from PySide6.QtWidgets import (
    QApplication, QHBoxLayout, QLabel, QMainWindow, QMessageBox, QSpinBox, QWidget, QWidgetAction,
)

from geomech.gui import plotstyle
from geomech.gui.mplcanvas import MplWidget
from geomech.gui.util import default_window_size

FONT_SCALE_RANGE = (50, 200)
FONT_SCALE_STEP = 10


def settings() -> QSettings:
    return QSettings("Geomechanics Toolbox", "GeomechanicsToolbox")


def apply_plot_settings() -> None:
    """Scientific style always on; the font scale comes from the saved preference."""
    plotstyle.set_enabled(True)
    plotstyle.set_font_scale(settings().value("plot_font_scale", 100, type=int) / 100.0)


def font_scale_percent() -> int:
    return int(round(plotstyle.font_scale() * 100))


def set_font_scale_percent(percent: int) -> None:
    """Global font scale: applied to every open plot, saved, mirrored in every module menu."""
    lo, hi = FONT_SCALE_RANGE
    percent = int(min(max(percent, lo), hi))
    plotstyle.set_font_scale(percent / 100.0)
    settings().setValue("plot_font_scale", percent)
    for top in QApplication.topLevelWidgets():
        if isinstance(top, ModuleWindow):
            top.sync_font_scale(percent)
        for mw in top.findChildren(MplWidget):
            mw.draw()


class ModuleWindow(QMainWindow):
    def __init__(self, panel: QWidget, title: str = ""):
        super().__init__()
        self.panel = panel
        self.setWindowTitle(panel.windowTitle() or title)
        self.setCentralWidget(panel)
        self.setAttribute(Qt.WidgetAttribute.WA_DeleteOnClose)
        menu = self.menuBar().addMenu("&Plot")

        a = QAction("Larger fonts", self)
        a.setShortcuts([QKeySequence("Ctrl++"), QKeySequence("Ctrl+=")])
        a.triggered.connect(lambda: set_font_scale_percent(font_scale_percent() + FONT_SCALE_STEP))
        menu.addAction(a)
        a = QAction("Smaller fonts", self)
        a.setShortcut(QKeySequence("Ctrl+-"))
        a.triggered.connect(lambda: set_font_scale_percent(font_scale_percent() - FONT_SCALE_STEP))
        menu.addAction(a)
        a = QAction("Reset font scale", self)
        a.setShortcut(QKeySequence("Ctrl+0"))
        a.triggered.connect(lambda: set_font_scale_percent(100))
        menu.addAction(a)

        box = QWidget()
        lay = QHBoxLayout(box)
        lay.setContentsMargins(12, 2, 12, 2)
        lay.addWidget(QLabel("Font scale"))
        self.sp_font = QSpinBox()
        self.sp_font.setRange(*FONT_SCALE_RANGE)
        self.sp_font.setSingleStep(FONT_SCALE_STEP)
        self.sp_font.setSuffix(" %")
        self.sp_font.setValue(font_scale_percent())
        self.sp_font.setToolTip("Multiplies the size-adaptive fonts of every plot and of publication exports (saved).")
        self.sp_font.valueChanged.connect(self._spin_changed)
        lay.addWidget(self.sp_font)
        wa = QWidgetAction(menu)
        wa.setDefaultWidget(box)
        menu.addAction(wa)

        menu.addSeparator()
        a = QAction("Publication figure…", self)
        a.setShortcut(QKeySequence("Ctrl+E"))
        a.setToolTip("Save the plot shown in this window at 600 dpi in the scientific style")
        a.triggered.connect(self.export_visible_plot)
        menu.addAction(a)

        w, h = default_window_size(panel)
        self.resize(w, h + self.menuBar().sizeHint().height())

    # ---------------------------------------------------------------- font scale
    def _spin_changed(self, value: int):
        if value != font_scale_percent():
            set_font_scale_percent(value)

    def sync_font_scale(self, percent: int):
        self.sp_font.blockSignals(True)
        self.sp_font.setValue(percent)
        self.sp_font.blockSignals(False)

    # ---------------------------------------------------------------- export
    def visible_plot(self) -> MplWidget | None:
        """The plot the user is looking at (pages of hidden tabs are not visible)."""
        for mw in self.panel.findChildren(MplWidget):
            if mw.isVisible():
                return mw
        return None

    def export_visible_plot(self):
        mw = self.visible_plot()
        if mw is None:
            QMessageBox.information(self, "Publication figure", "No plot is shown in this window yet.")
            return
        mw.export_publication()
