"""Publication ("scientific") look for the toolbox figures.

Modelled on the paper-figure conventions of the production-analysis scripts: serif text
(Times New Roman, STIX maths), tick marks pointing inwards on all four sides, black
1.2 pt axes frame, scientific offset written as x10^n in math text, framed legend with a
black edge, and high-resolution export with tight bounding box.

    plotstyle.set_enabled(True)          # every MplWidget restyles its figure on draw()
    plotstyle.style_figure(fig)          # style one figure in place (screen font sizes)
    plotstyle.export_figure(fig, "fig.png", dpi=600)   # paper font sizes, tight bbox

The style is applied after the panels have drawn, so the panels themselves stay untouched;
3-D and polar axes get the fonts only (no spines / formatters), colour bars keep their ticks.
"""
from __future__ import annotations

from dataclasses import dataclass, replace

import matplotlib
from matplotlib.ticker import ScalarFormatter

SERIF = ["Times New Roman", "STIXGeneral", "DejaVu Serif"]     # first one available wins


@dataclass(frozen=True)
class Sizes:
    """Font sizes [pt] and frame line width."""
    title: float
    label: float
    tick: float
    legend: float
    offset: float
    line: float = 1.2

    def scaled(self, k: float) -> "Sizes":
        return replace(self, title=self.title * k, label=self.label * k, tick=self.tick * k,
                       legend=self.legend * k, offset=self.offset * k)


SCREEN = Sizes(title=13, label=12, tick=11, legend=10, offset=11)      # embedded canvases
PAPER = Sizes(title=24, label=22, tick=20, legend=18, offset=20)       # the reference scripts' sizes

# rcParams applied while the style is on (affects artists created afterwards)
_RC = {
    "font.family": "serif", "font.serif": SERIF, "mathtext.fontset": "stix",
    "axes.formatter.use_mathtext": True, "axes.formatter.limits": (-2, 3),
    "xtick.direction": "in", "ytick.direction": "in", "xtick.top": True, "ytick.right": True,
    "axes.linewidth": 1.2, "axes.edgecolor": "black",
    "legend.frameon": True, "legend.framealpha": 1.0, "legend.edgecolor": "black", "legend.fancybox": False,
}
_saved: dict = {}
_enabled = False


class ScientificFormatter(ScalarFormatter):
    """ScalarFormatter that writes the exponent as x10^n in math text once the values leave
    10^-2..10^3, optionally with a fixed number of decimals on the tick labels."""

    def __init__(self, decimals: int | None = None):
        super().__init__(useMathText=True)
        self.set_scientific(True)
        self.set_powerlimits((-2, 3))
        self._decimals = decimals

    def _set_format(self):
        super()._set_format()
        if self._decimals is not None:
            fmt = f"%.{self._decimals}f"
            self.format = r"$\mathdefault{%s}$" % fmt if self._useMathText else fmt


def enabled() -> bool:
    return _enabled


def set_enabled(flag: bool) -> None:
    """Switch the style on or off for the whole application."""
    global _enabled
    if flag and not _saved:
        _saved.update({k: matplotlib.rcParams[k] for k in _RC})
        matplotlib.rcParams.update(_RC)
    elif not flag and _saved:
        matplotlib.rcParams.update(_saved)
        _saved.clear()
    _enabled = bool(flag)


def _is_3d(ax) -> bool:
    return hasattr(ax, "zaxis")


def _is_polar(ax) -> bool:
    return getattr(ax, "name", "") == "polar"


def _is_colorbar(ax) -> bool:
    return getattr(ax, "_colorbar", None) is not None


def style_axes(ax, sizes: Sizes = SCREEN, decimals: int | None = None) -> None:
    """Apply the look to one Axes in place (idempotent)."""
    ax.title.set_fontfamily(SERIF); ax.title.set_fontsize(sizes.title); ax.title.set_fontweight("bold")
    axes_ = [ax.xaxis, ax.yaxis] + ([ax.zaxis] if _is_3d(ax) else [])
    for axis in axes_:
        axis.label.set_fontfamily(SERIF); axis.label.set_fontsize(sizes.label)
        off = axis.get_offset_text(); off.set_fontfamily(SERIF); off.set_fontsize(sizes.offset)
        for t in axis.get_ticklabels(which="both"):
            t.set_fontfamily(SERIF)
    for t in ax.texts:
        t.set_fontfamily(SERIF)
    leg = ax.get_legend()
    if leg is not None:
        for t in leg.get_texts():
            t.set_fontfamily(SERIF); t.set_fontsize(sizes.legend)
        leg.get_title().set_fontfamily(SERIF)
        frame = leg.get_frame(); frame.set_edgecolor("black"); frame.set_alpha(1.0); frame.set_linewidth(1.0)
    if _is_3d(ax):
        ax.tick_params(axis="both", labelsize=sizes.tick)
        return
    if _is_polar(ax):
        ax.tick_params(axis="both", labelsize=sizes.tick)
        return
    if _is_colorbar(ax):
        ax.tick_params(axis="both", which="both", labelsize=sizes.tick, direction="in")
    else:
        ax.tick_params(axis="both", which="both", labelsize=sizes.tick, direction="in", top=True, right=True)
        for axis, scale in ((ax.xaxis, ax.get_xscale()), (ax.yaxis, ax.get_yscale())):
            if scale == "linear" and isinstance(axis.get_major_formatter(), ScalarFormatter):
                axis.set_major_formatter(ScientificFormatter(decimals))
    for key in ("left", "bottom", "right", "top"):
        if key in ax.spines:
            ax.spines[key].set_color("black"); ax.spines[key].set_linewidth(sizes.line)


def _paper_sizes(fig, sizes: Sizes) -> Sizes:
    """Shrink the paper fonts when a figure holds several plots, so labels do not collide."""
    n = sum(1 for ax in fig.axes if not _is_colorbar(ax))
    return sizes if n <= 1 else sizes.scaled(max(0.5, 1.0 / n**0.5))


def style_figure(fig, sizes: Sizes = SCREEN, decimals: int | None = None) -> None:
    for ax in fig.axes:
        style_axes(ax, sizes, decimals)
    st = getattr(fig, "_suptitle", None)
    if st is not None:
        st.set_fontfamily(SERIF); st.set_fontsize(sizes.title); st.set_fontweight("bold")


def export_figure(fig, path, dpi: int = 600, sizes: Sizes = PAPER, decimals: int | None = None) -> None:
    """Save `fig` for a paper: scientific look with the paper font sizes, tight bounding box,
    white background. Vector formats (pdf/svg) ignore dpi. The figure is left in the
    screen-size scientific look afterwards; the panel restores its own look on the next plot."""
    with matplotlib.rc_context(_RC):
        style_figure(fig, _paper_sizes(fig, sizes), decimals)
        fig.savefig(path, dpi=dpi, bbox_inches="tight", facecolor="white")
    style_figure(fig, SCREEN, decimals)
    fig.canvas.draw_idle()
