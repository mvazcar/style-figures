"""The style-figures template for Matplotlib.

Call figure_style() before plotting, subplots() to create panels, and
figure_print() to export. Both subplots() and figure_print() show bottom x
and left y ticks and their labels on every visible Cartesian panel.
"""

import math
from pathlib import Path
from types import SimpleNamespace

import matplotlib as mpl
from cycler import cycler
from matplotlib import font_manager

__all__ = ["figure_print", "figure_style", "figure_ticks", "subplots"]

_SET1 = (
    "#377eb8",
    "#e41a1c",
    "#4daf4a",
    "#984ea3",
    "#ff7f00",
    "#ffff33",
    "#a65628",
    "#f781bf",
    "#999999",
)
_SET1_NAMES = ("blue", "red", "green", "purple", "orange", "yellow", "brown", "pink", "gray")
_MATLAB = (
    "#0072BD",
    "#D95319",
    "#EDB120",
    "#7E2F8E",
    "#77AC30",
    "#4DBEEE",
    "#A2142F",
)
_MATLAB_NAMES = ("blue", "orange", "yellow", "purple", "green", "cyan", "red")


def _positive(value, name):
    value = float(value)
    if not math.isfinite(value) or value <= 0:
        raise ValueError(f"{name} must be a finite positive number")
    return value


def figure_style(font_size=24, line_width=3, palette="set1"):
    """Set session defaults and return named colours, font and line width.

    Use Helvetica when installed, otherwise Arial; fail if neither is present.
    Existing artists retain their styling. Use matplotlib.rc_context() to
    limit the defaults to a block of code. Select ``palette="matlab"`` for
    MATLAB's seven-colour ColorOrder from R2014b-R2024b.
    """
    font_size = _positive(font_size, "font_size")
    line_width = _positive(line_width, "line_width")
    if palette not in ("set1", "matlab"):
        raise ValueError("palette must be 'set1' or 'matlab'")
    colours = _SET1 if palette == "set1" else _MATLAB
    available = {font.name for font in font_manager.fontManager.ttflist}
    font_name = next((name for name in ("Helvetica", "Arial") if name in available), None)
    if font_name is None:
        raise RuntimeError("style-figures requires Helvetica or Arial. Install either font first.")
    mpl.rcParams.update(
        {
            "font.family": [font_name],
            "font.sans-serif": [font_name],
            "mathtext.fontset": "custom",
            "mathtext.rm": font_name,
            "mathtext.it": f"{font_name}:italic",
            "mathtext.bf": f"{font_name}:bold",
            "mathtext.sf": font_name,
            "mathtext.tt": font_name,
            "mathtext.cal": font_name,
            "mathtext.fallback": None,
            "font.size": font_size,
            "font.weight": "normal",
            "text.usetex": False,
            "figure.figsize": [8.5, 6.375],
            "figure.facecolor": "white",
            "figure.titlesize": font_size,
            "figure.titleweight": "normal",
            "axes.facecolor": "white",
            "axes.edgecolor": "black",
            "axes.labelcolor": "black",
            "axes.labelsize": font_size,
            "axes.labelweight": "normal",
            "axes.titlesize": font_size,
            "axes.titleweight": "normal",
            "axes.linewidth": 1,
            "axes.spines.top": False,
            "axes.spines.right": False,
            "axes.spines.bottom": True,
            "axes.spines.left": True,
            "axes.grid": True,
            "axes.grid.axis": "y",
            "axes.grid.which": "major",
            "axes.axisbelow": True,
            "axes.prop_cycle": cycler(color=colours),
            "grid.color": "black",
            "grid.alpha": 0.15,
            "grid.linestyle": "-",
            "xtick.color": "black",
            "ytick.color": "black",
            "xtick.labelsize": font_size,
            "ytick.labelsize": font_size,
            "xtick.direction": "out",
            "ytick.direction": "out",
            "xtick.major.size": 3,
            "ytick.major.size": 3,
            "xtick.major.width": 1,
            "ytick.major.width": 1,
            "xtick.bottom": True,
            "xtick.top": False,
            "ytick.left": True,
            "ytick.right": False,
            "xtick.labelbottom": True,
            "xtick.labeltop": False,
            "ytick.labelleft": True,
            "ytick.labelright": False,
            "lines.linewidth": line_width,
            "legend.frameon": False,
            "legend.fontsize": font_size,
            "savefig.dpi": 300,
            "savefig.format": "png",
            "savefig.facecolor": "white",
            "savefig.transparent": False,
            "savefig.bbox": None,
            "pdf.fonttype": 42,
            "ps.fonttype": 42,
        }
    )
    named = dict(zip(_SET1_NAMES, _SET1))
    named["cyan"] = _MATLAB[5]
    if palette == "matlab":
        named.update(zip(_MATLAB_NAMES, _MATLAB))
    return SimpleNamespace(
        **named,
        black="#000000",
        set1=_SET1,
        matlab=_MATLAB,
        palette=palette,
        font=font_size,
        width=line_width,
        font_name=font_name,
    )


def figure_ticks(fig=None):
    """Show ticks and tick labels on each visible Cartesian axes in a figure.

    This reverses shared-axis label suppression without changing tick
    locations, formatters, limits, data or sharing. Intentionally empty tick
    locations and formatters stay as specified. Hidden panels, colourbars,
    polar axes and 3D axes are left alone.
    """
    if fig is None:
        from matplotlib import pyplot as plt

        fig = plt.gcf()
    for ax in fig.axes:
        if (
            ax.name != "rectilinear"
            or not ax.get_visible()
            or not ax.axison
            or ax.get_label() == "<colorbar>"
        ):
            continue
        ax.xaxis.set_visible(True)
        ax.yaxis.set_visible(True)
        ax.tick_params(axis="x", which="both", bottom=True, labelbottom=True)
        ax.tick_params(axis="y", which="both", left=True, labelleft=True)
    return fig


def subplots(nrows=1, ncols=1, **kwargs):
    """Create panels with labelled ticks, including sharex/sharey layouts.

    Accepts matplotlib.pyplot.subplots keyword arguments. The default sheet
    has 8.5 by 6.375 inches per panel and constrained layout reserves space
    for repeated tick labels. Call figure_style() first to apply the style.
    """
    from matplotlib import pyplot as plt

    kwargs.setdefault("figsize", (8.5 * ncols, 6.375 * nrows))
    if not any(key in kwargs for key in ("layout", "constrained_layout", "tight_layout")):
        kwargs["layout"] = "constrained"
    fig, axes = plt.subplots(nrows, ncols, **kwargs)
    figure_ticks(fig)
    return fig, axes


def figure_print(file, fig=None, dpi=300, **kwargs):
    """Save a figure after restoring subplot tick labels; default PNG, 300 dpi.

    Generate PNG at 300 dpi only, unless the user explicitly requests another
    format or resolution. Do not automatically generate companion PDFs.
    A path without a suffix receives .png. Other suffixes, such as .pdf,
    are passed to Matplotlib. Parent folders must already exist. The
    sheet uses the figure's size in inches; bbox_inches='tight' may be
    passed explicitly if a cropped size is desired.
    """
    dpi = _positive(dpi, "dpi")
    if fig is None:
        from matplotlib import pyplot as plt

        fig = plt.gcf()
    path = Path(file)
    if not path.suffix:
        path = path.with_suffix(".png")
    figure_ticks(fig)
    fig.savefig(path, dpi=dpi, **kwargs)
    return path
