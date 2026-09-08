"""Scientific plot style: formatter, ticks, spines, fonts, adaptive sizes, export; no Qt needed."""
import matplotlib
matplotlib.use("Agg")

import re  # noqa: E402

import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
import pytest  # noqa: E402
from matplotlib.ticker import MaxNLocator  # noqa: E402

from geomech.gui import plotstyle  # noqa: E402

MATHDEFAULT_ONE_DECIMAL = re.compile(r"\$" + re.escape("\\mathdefault") + r"\{\d+\.\d\}\$")


@pytest.fixture(autouse=True)
def _unit_font_scale():
    plotstyle.set_font_scale(1.0)
    yield
    plotstyle.set_font_scale(1.0)


@pytest.fixture
def styled_fig():
    fig, ax = plt.subplots(figsize=(8, 6))
    x = np.arange(1, 25)
    ax.plot(x, 3.2e4 * np.exp(-x / 10), label="Observation")
    ax.plot(x, 2.8e4 * np.exp(-x / 8), "--", label="Decline curve")
    ax.set_xlabel("Time, month"); ax.set_ylabel("Oil production, bbl"); ax.set_title("EF-Well-06")
    ax.legend()
    plotstyle.style_figure(fig)
    fig.canvas.draw()
    yield fig, ax
    plt.close(fig)


def test_axes_get_the_scientific_look(styled_fig):
    fig, ax = styled_fig
    assert isinstance(ax.yaxis.get_major_formatter(), plotstyle.ScientificFormatter)
    assert "10^{4}" in ax.yaxis.get_offset_text().get_text()          # x10^4 as math text
    assert r"\times" in ax.yaxis.get_offset_text().get_text()
    params = ax.xaxis.get_tick_params(which="major")
    assert params["direction"] == "in" and params["top"] is True
    assert ax.yaxis.get_tick_params(which="major")["right"] is True
    for key in ("left", "bottom", "right", "top"):
        assert ax.spines[key].get_linewidth() == pytest.approx(1.2)
        assert ax.spines[key].get_edgecolor()[:3] == (0.0, 0.0, 0.0)
    assert ax.title.get_fontfamily() == plotstyle.SERIF and ax.title.get_fontweight() == "bold"
    assert ax.xaxis.label.get_fontsize() == plotstyle.SCREEN.label      # 8 x 6 in figure: factor 1
    assert ax.get_xticklabels()[0].get_fontfamily() == plotstyle.SERIF
    leg = ax.get_legend()
    assert leg.get_frame().get_edgecolor()[:3] == (0.0, 0.0, 0.0) and leg.get_frame().get_alpha() == 1.0
    assert leg.get_texts()[0].get_fontsize() == plotstyle.SCREEN.legend


def test_fixed_decimals_and_small_values():
    fig, ax = plt.subplots()
    ax.plot([0, 1, 2], [10, 20, 30])                     # exponent 1: no offset, plain labels
    plotstyle.style_axes(ax, decimals=1)
    fig.canvas.draw()
    labels = [t.get_text() for t in ax.get_yticklabels() if t.get_text()]
    assert labels and all(MATHDEFAULT_ONE_DECIMAL.fullmatch(lbl) for lbl in labels), labels
    assert ax.yaxis.get_offset_text().get_text() == ""
    plt.close(fig)


def test_adaptive_factor_follows_figure_size_plots_and_user_scale():
    fig, _ = plt.subplots(figsize=(8, 6)); assert plotstyle.adaptive_factor(fig) == pytest.approx(1.0); plt.close(fig)
    fig, _ = plt.subplots(figsize=(4, 3)); assert plotstyle.adaptive_factor(fig) == pytest.approx(0.6); plt.close(fig)   # clipped
    fig, _ = plt.subplots(figsize=(16, 12)); assert plotstyle.adaptive_factor(fig) == pytest.approx(1.3); plt.close(fig)
    fig, _ = plt.subplots(figsize=(12, 6)); assert plotstyle.adaptive_factor(fig) == pytest.approx(1.0); plt.close(fig)   # limited by height
    fig, _ = plt.subplots(2, 2, figsize=(8, 6)); assert plotstyle.adaptive_factor(fig) == pytest.approx(0.5); plt.close(fig)
    fig, ax = plt.subplots(figsize=(8, 6)); fig.colorbar(ax.pcolormesh(np.random.rand(3, 3)), ax=ax)
    assert plotstyle.adaptive_factor(fig) == pytest.approx(1.0)                 # colour bars do not count as plots
    plotstyle.set_font_scale(1.5)
    assert plotstyle.adaptive_factor(fig) == pytest.approx(1.5)
    plotstyle.style_figure(fig)
    assert ax.xaxis.label.get_fontsize() == pytest.approx(plotstyle.SCREEN.label * 1.5)
    plt.close(fig)


def test_3d_axes_get_smaller_fonts_fewer_ticks_and_room_for_the_title():
    fig = plt.figure(figsize=(8, 6), tight_layout=True)
    ax3 = fig.add_subplot(projection="3d"); ax3.plot([-10, 10], [-10, 10], [-15, 5]); ax3.set_zlabel("Z")
    ax3.set_title("3D Discrete Fracture Network")
    plotstyle.style_figure(fig)
    fig.canvas.draw()
    assert ax3.zaxis.label.get_fontsize() == pytest.approx(plotstyle.SCREEN.label * plotstyle.AXES3D_FACTOR)
    assert isinstance(ax3.xaxis.get_major_locator(), MaxNLocator) and len(ax3.get_xticks()) <= 8   # AutoLocator gave 13
    from matplotlib.layout_engine import TightLayoutEngine
    assert not isinstance(fig.get_layout_engine(), TightLayoutEngine)    # tight layout replaced by fixed margins
    assert fig.subplotpars.top == pytest.approx(plotstyle.TOP_RECT_3D)
    assert ax3.title.get_window_extent().y1 <= fig.bbox.y1 + 0.5         # title inside the figure after ONE draw
    fig.clear(); fig.add_subplot(); plotstyle.layout_for_3d(fig)
    assert isinstance(fig.get_layout_engine(), TightLayoutEngine)        # 2-D again: tight layout restored
    plt.close(fig)


def test_polar_log_and_colorbar_axes_do_not_break():
    fig = plt.figure()
    axp = fig.add_subplot(2, 2, 1, projection="polar"); axp.bar([0, 1], [1, 2])
    axl = fig.add_subplot(2, 2, 2); axl.loglog([1, 10, 100], [1, 100, 10000])
    axc = fig.add_subplot(2, 2, 3); m = axc.pcolormesh(np.random.rand(4, 4)); fig.colorbar(m, ax=axc)
    plotstyle.style_figure(fig)
    fig.canvas.draw()
    assert not isinstance(axl.yaxis.get_major_formatter(), plotstyle.ScientificFormatter)   # log axes keep theirs
    assert isinstance(axc.yaxis.get_major_formatter(), plotstyle.ScientificFormatter)
    cbar_axes = [a for a in fig.axes if plotstyle._is_colorbar(a)]
    assert len(cbar_axes) == 1 and cbar_axes[0].yaxis.get_tick_params()["direction"] == "in"
    plt.close(fig)


def test_export_normalises_size_uses_paper_fonts_and_restores(tmp_path, styled_fig):
    fig, ax = styled_fig
    fig.set_size_inches(12, 10)                                          # a big window on screen
    out = tmp_path / "fig.png"
    plotstyle.export_figure(fig, out, dpi=100)
    assert out.exists() and out.stat().st_size > 1000
    img = plt.imread(out)
    assert img.shape[1] <= 8 * 100 * 1.2 and img.shape[0] <= 6 * 100 * 1.2   # fitted into 8 x 6 in (+ tight bbox)
    assert tuple(fig.get_size_inches()) == (12, 10)                       # size restored
    assert ax.xaxis.label.get_fontsize() == pytest.approx(plotstyle.SCREEN.label * plotstyle.adaptive_factor(fig))
    pdf = tmp_path / "fig.pdf"
    plotstyle.export_figure(fig, pdf)
    assert pdf.exists() and pdf.stat().st_size > 1000


def test_set_enabled_switches_rcparams_and_restores_them():
    before = {k: matplotlib.rcParams[k] for k in ("font.family", "xtick.direction", "axes.linewidth")}
    plotstyle.set_enabled(True)
    assert plotstyle.enabled() and matplotlib.rcParams["xtick.direction"] == "in"
    assert matplotlib.rcParams["font.family"] == ["serif"] and matplotlib.rcParams["mathtext.fontset"] == "stix"
    plotstyle.set_enabled(False)
    assert not plotstyle.enabled()
    assert {k: matplotlib.rcParams[k] for k in before} == before
