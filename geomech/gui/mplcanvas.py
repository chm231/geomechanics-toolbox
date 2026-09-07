"""Matplotlib canvas embedded in Qt."""
from __future__ import annotations

from matplotlib.backends.backend_qtagg import FigureCanvasQTAgg, NavigationToolbar2QT
from matplotlib.figure import Figure
from PySide6.QtWidgets import QVBoxLayout, QWidget


class MplWidget(QWidget):
    """A Figure with a navigation toolbar, usable as an ordinary QWidget."""

    def __init__(self, parent: QWidget | None = None, projection: str | None = None):
        super().__init__(parent)
        self.figure = Figure(figsize=(6, 4), tight_layout=True)
        self.canvas = FigureCanvasQTAgg(self.figure)
        self.toolbar = NavigationToolbar2QT(self.canvas, self)
        self._projection = projection
        self.ax = self.figure.add_subplot(111, projection=projection)
        lay = QVBoxLayout(self)
        lay.setContentsMargins(0, 0, 0, 0)
        lay.addWidget(self.toolbar)
        lay.addWidget(self.canvas)

    def clear(self):
        self.figure.clear()
        self.ax = self.figure.add_subplot(111, projection=self._projection)
        return self.ax

    def draw(self):
        self.canvas.draw_idle()
