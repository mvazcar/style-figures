import matplotlib

matplotlib.use("Agg")

import matplotlib.pyplot as plt
import numpy as np
import pytest
from matplotlib import font_manager
from matplotlib.ticker import FuncFormatter
from PIL import Image

from style_figures import figure_print, figure_style, figure_ticks, subplots


@pytest.fixture(autouse=True)
def isolate_style():
    with matplotlib.rc_context():
        yield
    plt.close("all")


def assert_ticks_visible(fig, axes):
    fig.canvas.draw()
    for ax in np.asarray(axes, dtype=object).flat:
        for axis in (ax.xaxis, ax.yaxis):
            ticks = axis.get_major_ticks()
            assert ticks
            assert any(tick.label1.get_text() for tick in ticks)
            assert all(tick.tick1line.get_visible() and tick.label1.get_visible() for tick in ticks)


def test_shared_panels_have_both_axes_and_keep_sharing():
    figure_style()
    fig, axes = subplots(2, 2, sharex=True, sharey=True)
    for ax in axes.flat:
        ax.plot([0, 1, 2], [2, 3, 4])
    assert_ticks_visible(fig, axes)
    axes[0, 0].set_xlim(-1, 5)
    axes[1, 1].set_ylim(0, 9)
    assert all(ax.get_xlim() == (-1, 5) and ax.get_ylim() == (0, 9) for ax in axes.flat)
    np.testing.assert_allclose(fig.get_size_inches(), [17, 12.75])


def test_existing_shared_axes_are_repaired_at_export(tmp_path):
    fig, axes = plt.subplots(2, 2, sharex=True, sharey=True, figsize=(4, 3))
    for ax in axes.flat:
        ax.plot([0, 1], [0, 1])
        ax.label_outer()
    fig.canvas.draw()
    assert not axes[0, 1].get_xticklabels()
    assert not axes[0, 1].get_yticklabels()
    output = figure_print(tmp_path / "panels", fig, dpi=80)
    assert_ticks_visible(fig, axes)
    with Image.open(output) as image:
        assert image.size == (320, 240)
        assert image.format == "PNG"


def test_custom_ticks_formatters_and_data_survive():
    fig, axes = plt.subplots(1, 2, sharey=True)
    for ax in axes:
        ax.plot([1, 2, 3], [0, 0.5, 1])
        ax.set_xticks([1, 3], ["Start", "End"])
        ax.set_yticks([0, 0.5, 1])
        ax.yaxis.set_major_formatter(FuncFormatter(lambda x, _: f"{x:.0%}"))
    figure_ticks(fig)
    assert_ticks_visible(fig, axes)
    for ax in axes:
        assert [label.get_text() for label in ax.get_xticklabels()] == ["Start", "End"]
        assert [label.get_text() for label in ax.get_yticklabels()] == ["0%", "50%", "100%"]
        np.testing.assert_array_equal(ax.lines[0].get_ydata(), [0, 0.5, 1])


def test_hidden_panels_and_colourbars_stay_unchanged():
    fig, axes = plt.subplots(1, 2)
    plot = axes[0].imshow([[1, 2], [3, 4]])
    colourbar = fig.colorbar(plot, ax=axes[0])
    axes[1].axis("off")
    before = colourbar.ax.yaxis.get_ticks_position()
    figure_ticks(fig)
    assert not axes[1].axison
    assert colourbar.ax.yaxis.get_ticks_position() == before


def test_style_colours_and_export_defaults(tmp_path):
    style = figure_style()
    fig, ax = subplots(figsize=(4, 3))
    (first,) = ax.plot([0, 1], [1, 2])
    (second,) = ax.plot([0, 1], [2, 3])
    assert first.get_color() == style.blue == "#377eb8"
    assert second.get_color() == style.red == "#e41a1c"
    assert first.get_linewidth() == 3
    assert ax.get_xticklabels()[0].get_fontsize() == 24
    assert style.font_name in ("Helvetica", "Arial")
    assert font_manager.FontProperties(
        fname=font_manager.findfont(
            ax.get_xticklabels()[0].get_fontproperties(), fallback_to_default=False
        )
    ).get_name() in ("Helvetica", "Arial")
    assert not ax.spines["top"].get_visible()
    assert not ax.spines["right"].get_visible()
    assert all(line.get_visible() for line in ax.get_ygridlines())
    assert not any(line.get_visible() for line in ax.get_xgridlines())
    output = figure_print(tmp_path / "default", fig)
    with Image.open(output) as image:
        assert image.size == (1200, 900)
        assert image.info["dpi"][0] == pytest.approx(300, abs=0.1)


@pytest.mark.parametrize("value", [0, -1, float("nan"), float("inf")])
def test_reject_invalid_sizes(value, tmp_path):
    with pytest.raises(ValueError):
        figure_style(font_size=value)
    with pytest.raises(ValueError):
        figure_style(line_width=value)
    with pytest.raises(ValueError):
        figure_print(tmp_path / "invalid", dpi=value)
    assert not (tmp_path / "invalid.png").exists()


def test_missing_required_fonts_raise_instead_of_silent_fallback(monkeypatch):
    monkeypatch.setattr(font_manager.fontManager, "ttflist", [])
    with pytest.raises(RuntimeError, match="Helvetica or Arial"):
        figure_style()


def test_png_300_defaults_override_inherited_export_settings(tmp_path):
    matplotlib.rcParams.update({"savefig.format": "pdf", "savefig.dpi": 72})
    figure_style()
    fig, ax = subplots(figsize=(4, 3))
    ax.plot([0, 1], [0, 1])
    fig.savefig(tmp_path / "ordinary")
    figure_print(tmp_path / "helper", fig)
    assert sorted(path.name for path in tmp_path.iterdir()) == ["helper.png", "ordinary.png"]
    for path in tmp_path.iterdir():
        with Image.open(path) as image:
            assert image.format == "PNG"
            assert image.size == (1200, 900)
            assert image.info["dpi"][0] == pytest.approx(300, abs=0.1)


def test_complete_colour_cycle_and_named_colours():
    style = figure_style()
    expected = [
        "#377eb8",
        "#e41a1c",
        "#4daf4a",
        "#984ea3",
        "#ff7f00",
        "#ffff33",
        "#a65628",
        "#f781bf",
        "#999999",
    ]
    names = ["blue", "red", "green", "purple", "orange", "yellow", "brown", "pink", "gray"]
    fig, ax = subplots()
    lines = [ax.plot([0, 1], [i, i + 1])[0] for i in range(10)]
    assert [line.get_color() for line in lines] == expected + expected[:1]
    assert [getattr(style, name) for name in names] == expected


def test_classic_matlab_colour_order():
    style = figure_style(palette="matlab")
    expected = [
        "#0072BD", "#D95319", "#EDB120", "#7E2F8E",
        "#77AC30", "#4DBEEE", "#A2142F",
    ]
    fig, ax = subplots()
    lines = [ax.plot([0, 1], [i, i + 1])[0] for i in range(8)]
    assert [line.get_color() for line in lines] == expected + expected[:1]
    assert style.blue == expected[0]
    assert style.orange == expected[1]
    assert style.red == expected[6]
    assert style.matlab == tuple(expected)


def test_reject_unknown_palette():
    with pytest.raises(ValueError, match="palette"):
        figure_style(palette="unknown")
