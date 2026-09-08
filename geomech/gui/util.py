"""Small Qt helpers shared by the panels."""
from __future__ import annotations

from PySide6.QtWidgets import QScrollArea, QWidget


def fit_scroll_width(scroll: QScrollArea, extra: int = 4) -> int:
    """Make a scroll area at least as wide as its content, so the input side of a panel is
    never cut off horizontally (the vertical scrollbar is still allowed). Call after the
    content widget is fully built; returns the width set."""
    inner = scroll.widget()
    width = inner.sizeHint().width() + scroll.verticalScrollBar().sizeHint().width() + 2 * scroll.frameWidth() + extra
    scroll.setMinimumWidth(width)
    return width


def default_window_size(w: QWidget, min_width: int = 1200, min_height: int = 720) -> tuple[int, int]:
    """Window size for a module: its own size hint, at least min_width x min_height, but
    never larger than the available screen area."""
    hint = w.sizeHint()
    width, height = max(min_width, hint.width()), max(min_height, hint.height())
    for scroll in w.findChildren(QScrollArea):       # show a scrolled input column in full when the screen allows
        inner = scroll.widget()
        if inner is not None:
            height = max(height, inner.sizeHint().height() + 80)
    screen = w.screen()
    if screen is not None:
        avail = screen.availableGeometry()
        width, height = min(width, avail.width() - 40), min(height, avail.height() - 80)
    return width, height
