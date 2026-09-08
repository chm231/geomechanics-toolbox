"""Scientific plot style: formatter, ticks, spines, fonts, export; no Qt needed."""
import matplotlib
matplotlib.use("Agg")

import re  # noqa: E402

import matplotlib.pyplot as plt  # noqa: E402
import numpy as np  # noqa: E402
import pytest  # noqa: E402

from geomech.gui import plotstyle  # noqa: E402


@pytest.fixture
def styled_fig():
    fig, ax = plt.subplots()
    x = np.arange(1, 25)
    ax.plot(x, 3.2e4 * np.exp(-x / 10), label="Observation")
    ax.plot(x, 2.8e4 * np.exp(-x / 8), "--", label="Decline curve")
    ax.set_xlabel("Time, month"); ax.set_ylabel("Oil production, bbl"); ax.set_title("EF-Well-06")
    ax.legend()
    plotstyle.style_axes(ax)
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
    assert ax.xaxis.label.get_fontsize() == plotstyle.SCREEN.label
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
    assert labels and all(re.fullmatch(r"\$\\mathdefault\{\d+\.\d\}\$", lbl) for lbl in labels), labels   # one decimal each
    assert ax.yaxis.get_offset_text().get_text() == ""
    plt.close(fig)


def test_3d_polar_log_and_colorbar_axes_do_not_break():
    fig = plt.figure()
    ax3 = fig.add_subplot(2, 2, 1, projection="3d"); ax3.plot([0, 1], [0, 1], [0, 1]); ax3.set_zlabel("z")
    axp = fig.add_subplot(2, 2, 2, projection="polar"); axp.bar([0, 1], [1, 2])
    axl = fig.add_subplot(2, 2, 3); axl.loglog([1, 10, 100], [1, 100, 10000])
    axc = fig.add_subplot(2, 2, 4); m = axc.pcolormesh(np.random.rand(4, 4)); fig.colorbar(m, ax=axc)
    plotstyle.style_figure(fig)
    fig.canvas.draw()
    assert not isinstance(axl.yaxis.get_major_formatter(), plotstyle.ScientificFormatter)   # log axes keep theirs
    assert ax3.zaxis.label.get_fontfamily() == plotstyle.SERIF
    assert isinstance(axc.yaxis.get_major_formatter(), plotstyle.ScientificFormatter)
    cbar_axes = [a for a in fig.axes if plotstyle._is_colorbar(a)]
    assert len(cbar_axes) == 1 and cbar_axes[0].yaxis.get_tick_params()["direction"] == "in"
    plt.close(fig)


def test_export_uses_paper_sizes_and_restores_screen_sizes(tmp_path, styled_fig):
    fig, ax = styled_fig
    out = tmp_path / "fig.png"
    plotstyle.export_figure(fig, out, dpi=150)
    assert out.exists() and out.stat().st_size > 1000
    assert ax.xaxis.label.get_fontsize() == plotstyle.SCREEN.label      # back to the screen look
    pdf = tmp_path / "fig.pdf"
    plotstyle.export_figure(fig, pdf)
    assert pdf.exists() and pdf.stat().st_size > 1000
    # several plots: fonts are scaled down so they fit
    fig2, axes = plt.subplots(2, 2)
    assert plotstyle._paper_sizes(fig2, plotstyle.PAPER).label == pytest.approx(plotstyle.PAPER.label * 0.5)
    plt.close(fig2)


def test_set_enabled_switches_rcparams_and_restores_them():
    before = {k: matplotlib.rcParams[k] for k in ("font.family", "xtick.direction", "axes.linewidth")}
    plotstyle.set_enabled(True)
    assert plotstyle.enabled() and matplotlib.rcParams["xtick.direction"] == "in"
    assert matplotlib.rcParams["font.family"] == ["serif"] and matplotlib.rcParams["mathtext.fontset"] == "stix"
    plotstyle.set_enabled(False)
    assert not plotstyle.enabled()
    assert {k: matplotlib.rcParams[k] for k in before} == before
