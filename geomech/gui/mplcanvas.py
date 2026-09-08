"""Matplotlib canvas embedded in Qt."""
from __future__ import annotations

from pathlib import Path

from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg, NavigationToolbar2QT
from matplotlib.figure import Figure
from PySide6.QtWidgets import QFileDialog, QHBoxLayout, QMessageBox, QToolButton, QVBoxLayout, QWidget

from geomech.gui import plotstyle

EXPORT_FILTER = "PNG image, 600 dpi (*.png);;TIFF image, 600 dpi (*.tif);;PDF vector (*.pdf);;SVG vector (*.svg)"


class MplWidget(QWidget):
    """A Figure with a navigation toolbar, usable as an ordinary QWidget.

    draw() applies the scientific plot style when it is switched on (geomech.gui.plotstyle),
    and the 'Publication figure…' button saves the current figure with the paper look."""

    def __init__(self, parent: QWidget | None = None, projection: str | None = None):
        super().__init__(parent)
        self.figure = Figure(figsize=(6, 4), tight_layout=True)
        self.canvas = FigureCanvasQTAgg(self.figure)
        self.toolbar = NavigationToolbar2QT(self.canvas, self)
        self._projection = projection
        self.ax = self.figure.add_subplot(111, projection=projection)
        self.btn_export = QToolButton()
        self.btn_export.setText("Publication figure…")
        self.btn_export.setToolTip("Save the figure in the scientific style (serif fonts, inward ticks, x10^n) at high resolution")
        self.btn_export.clicked.connect(self.export_publication)
        top = QHBoxLayout()
        top.setContentsMargins(0, 0, 0, 0)
        top.addWidget(self.toolbar, 1)
        top.addWidget(self.btn_export, 0)
        lay = QVBoxLayout(self)
        lay.setContentsMargins(0, 0, 0, 0)
        lay.addLayout(top)
        lay.addWidget(self.canvas)
        self.canvas.mpl_connect("resize_event", self._on_resize)

    def _on_resize(self, _event):
        """The adaptive font sizes depend on the canvas size, which is stale while a tab is
        hidden: restyle when the canvas gets its real size (the redraw follows anyway)."""
        if plotstyle.enabled() and self.figure.axes:
            plotstyle.style_figure(self.figure)

    def clear(self):
        self.figure.clear()
        self.ax = self.figure.add_subplot(111, projection=self._projection)
        return self.ax

    def draw(self):
        plotstyle.layout_for_3d(self.figure)      # 3-D axes: fixed margins so the title is not pushed off the figure
        if plotstyle.enabled():
            plotstyle.style_figure(self.figure)
        self.canvas.draw_idle()

    def export_publication(self, path: str | None = None, dpi: int = 600):
        if not path:
            path, _ = QFileDialog.getSaveFileName(self, "Save publication figure", "figure.png", EXPORT_FILTER)
            if not path:
                return
        try:
            plotstyle.export_figure(self.figure, path, dpi=dpi)
        except Exception as e:  # noqa: BLE001
            QMessageBox.critical(self, "Publication figure", f"Could not save the figure:\n{e}")
            return
        self.canvas.draw_idle()
        return Path(path)
