"""Publication ("scientific") look for the toolbox figures.

Modelled on the paper-figure conventions of the production-analysis scripts: serif text
(Times New Roman, STIX maths), tick marks pointing inwards on all four sides, black
1.2 pt axes frame, scientific offset written as x10^n in math text, framed legend with a
black edge, and high-resolution export with tight bounding box.

    plotstyle.set_enabled(True)          # every MplWidget restyles its figure on draw()
    plotstyle.style_figure(fig)          # style one figure in place (screen font sizes)
    plotstyle.export_figure(fig, "fig.png", dpi=600)   # paper font sizes, tight bbox

Font sizes adapt to the figure: the size tables are written for an 8 x 6 inch figure and
are scaled by the figure's actual size, reduced for several plots in one figure and for
3-D axes (whose tick labels crowd), and multiplied by the user's font scale. The export
normalises the figure to fit 8 x 6 inches, so papers get the same fonts whatever the
window size on screen.

The style is applied after the panels have drawn, so the panels themselves stay untouched;
3-D and polar axes get the fonts only (no spines / formatters), colour bars keep their ticks.
"""
from __future__ import annotations

from dataclasses import dataclass, replace

import matplotlib
from matplotlib.layout_engine import TightLayoutEngine
from matplotlib.ticker import MaxNLocator, ScalarFormatter

SERIF = ["Times New Roman", "STIXGeneral", "DejaVu Serif"]     # first one available wins
REF_SIZE = (8.0, 6.0)          # inches the size tables below are written for
SCALE_LIMITS = (0.6, 1.3)      # adaptive factor range on screen
AXES3D_FACTOR = 0.8            # labels / ticks of 3-D axes
TOP_RECT_3D = 0.90             # share of the figure height left to the plots when a 3-D axes is present


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


SCREEN = Sizes(title=14, label=13, tick=12, legend=11, offset=12)      # embedded canvases (8 x 6 in reference)
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
_font_scale = 1.0


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
            self.format = r"$\mathdefault{%s}$" % fmt if self.get_useMathText() else fmt


# ---------------------------------------------------------------- switches
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


def font_scale() -> float:
    return _font_scale


def set_font_scale(k: float) -> None:
    """User multiplier on every font size (1.0 = the tables above), on screen and in exports."""
    global _font_scale
    _font_scale = max(0.25, float(k))


# ---------------------------------------------------------------- helpers
def _is_3d(ax) -> bool:
    return hasattr(ax, "zaxis")


def _is_polar(ax) -> bool:
    return getattr(ax, "name", "") == "polar"


def _is_colorbar(ax) -> bool:
    return getattr(ax, "_colorbar", None) is not None


def _n_plots(fig) -> int:
    return sum(1 for ax in fig.axes if not _is_colorbar(ax))


def adaptive_factor(fig, limits: tuple[float, float] | None = SCALE_LIMITS, user_scale: bool = True) -> float:
    """Font multiplier for `fig`: its size relative to the 8 x 6 in reference (clipped to
    `limits`), reduced by 1/sqrt(n) for n plots in one figure, times the user's font scale."""
    w, h = fig.get_size_inches()
    k = min(w / REF_SIZE[0], h / REF_SIZE[1])
    if limits is not None:
        k = min(max(k, limits[0]), limits[1])
    n = _n_plots(fig)
    if n > 1:
        k *= max(0.5, 1.0 / n**0.5)
    return k * (_font_scale if user_scale else 1.0)


def style_axes(ax, sizes: Sizes = SCREEN, decimals: int | None = None) -> None:
    """Apply the look to one Axes in place (idempotent). `sizes` are used as given."""
    three_d = _is_3d(ax)
    ax.title.set_fontfamily(SERIF); ax.title.set_fontsize(sizes.title); ax.title.set_fontweight("bold")
    label_size = sizes.label * (AXES3D_FACTOR if three_d else 1.0)
    tick_size = sizes.tick * (AXES3D_FACTOR if three_d else 1.0)
    axes_ = [ax.xaxis, ax.yaxis] + ([ax.zaxis] if three_d else [])
    for axis in axes_:
        axis.label.set_fontfamily(SERIF); axis.label.set_fontsize(label_size)
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
    if three_d:
        ax.tick_params(axis="both", labelsize=tick_size)
        for axis in axes_:                                 # fewer ticks: 3-D tick labels crowd easily
            if isinstance(axis.get_major_formatter(), ScalarFormatter):
                axis.set_major_locator(MaxNLocator(5))
        return
    if _is_polar(ax):
        ax.tick_params(axis="both", labelsize=tick_size)
        return
    if _is_colorbar(ax):
        ax.tick_params(axis="both", which="both", labelsize=tick_size, direction="in")
    else:
        ax.tick_params(axis="both", which="both", labelsize=tick_size, direction="in", top=True, right=True)
        for axis, scale in ((ax.xaxis, ax.get_xscale()), (ax.yaxis, ax.get_yscale())):
            if scale == "linear" and isinstance(axis.get_major_formatter(), ScalarFormatter):
                axis.set_major_formatter(ScientificFormatter(decimals))
    for key in ("left", "bottom", "right", "top"):
        if key in ax.spines:
            ax.spines[key].set_color("black"); ax.spines[key].set_linewidth(sizes.line)


def layout_for_3d(fig) -> bool:
    """Fixed margins for figures with 3-D axes; returns True when they were applied.

    Tight layout gives up on the first draw of a 3-D axes (its decorations are measured
    too large before the projection is set up), so the axes keeps its full-figure position
    and the title is pushed off the top edge. Fixed margins are deterministic: 10 % is
    kept for the title, more at the left / bottom when 2-D axes share the figure. Figures
    that lose their 3-D axes later get tight layout back."""
    has_3d = any(_is_3d(ax) for ax in fig.axes)
    if has_3d:
        mixed = any(not _is_3d(ax) and not _is_colorbar(ax) for ax in fig.axes)
        if isinstance(fig.get_layout_engine(), TightLayoutEngine):
            fig.set_layout_engine("none")
            fig._geomech_layout3d = True
        fig.subplots_adjust(left=0.07 if mixed else 0.0, right=0.97 if mixed else 0.98,
                            bottom=0.09 if mixed else 0.0, top=TOP_RECT_3D, wspace=0.25)
    elif getattr(fig, "_geomech_layout3d", False):
        fig.set_layout_engine("tight")
        fig._geomech_layout3d = False
    return has_3d


def style_figure(fig, sizes: Sizes = SCREEN, decimals: int | None = None, adaptive: bool = True) -> None:
    """Style every axes of `fig`; with `adaptive` the sizes are multiplied by adaptive_factor(fig)."""
    k = adaptive_factor(fig) if adaptive else 1.0
    s = sizes.scaled(k)
    for ax in fig.axes:
        style_axes(ax, s, decimals)
    st = getattr(fig, "_suptitle", None)
    if st is not None:
        st.set_fontfamily(SERIF); st.set_fontsize(s.title); st.set_fontweight("bold")
    layout_for_3d(fig)


def export_figure(fig, path, dpi: int = 600, sizes: Sizes = PAPER, decimals: int | None = None,
                  max_size: tuple[float, float] = REF_SIZE) -> None:
    """Save `fig` for a paper: the figure is scaled to fit `max_size` inches (aspect kept),
    fonts take the paper sizes (reduced for several plots, times the user's font scale),
    tight bounding box, white background. Vector formats (pdf/svg) ignore dpi. Size and the
    screen look are restored afterwards."""
    w, h = fig.get_size_inches()
    s = min(max_size[0] / w, max_size[1] / h)
    try:
        fig.set_size_inches(w * s, h * s, forward=False)
        with matplotlib.rc_context(_RC):
            style_figure(fig, sizes.scaled(_font_scale), decimals, adaptive=False)
            n = _n_plots(fig)
            if n > 1:
                style_figure(fig, sizes.scaled(_font_scale * max(0.5, 1.0 / n**0.5)), decimals, adaptive=False)
            fig.savefig(path, dpi=dpi, bbox_inches="tight", facecolor="white")
    finally:
        fig.set_size_inches(w, h, forward=False)
        style_figure(fig, SCREEN, decimals)
        fig.canvas.draw_idle()
