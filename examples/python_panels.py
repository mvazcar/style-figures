"""Render a reproducible shared-axis example: python examples/python_panels.py."""

from pathlib import Path

import numpy as np
from matplotlib import pyplot as plt

from style_figures import figure_print, figure_style, subplots


def main():
    figure_style()
    x = np.linspace(0, 10, 101)
    fig, axes = subplots(2, 2, sharex=True, sharey=True)
    for i, ax in enumerate(axes.flat):
        for phase, label, line in [(0, "Series A", "-"), (0.4, "Series B", "--")]:
            ax.plot(x, 1 + 0.2 * np.sin(x + i / 2 + phase), label=label, linestyle=line)
        ax.set(
            title=f"Panel {i + 1}",
            xlabel="Time",
            ylabel="Value",
            xticks=[0, 2, 4, 6, 8, 10],
            yticks=[0.8, 1, 1.2],
            ylim=(0.75, 1.3),
        )
        ax.legend(loc="upper right", ncols=2)
    output = Path(__file__).resolve().parents[1] / "figures" / "python_panels.png"
    figure_print(output, fig)
    plt.close(fig)
    print(output)


if __name__ == "__main__":
    main()
