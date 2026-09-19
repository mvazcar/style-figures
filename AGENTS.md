# Figure template rules

This repository provides the same scientific plotting style in MATLAB and Matplotlib. Preserve the original MATLAB public calls when extending it.

Show bottom x and left y tick marks and tick labels on every visible Cartesian subplot, including shared-axis panels. Keep custom non-empty ticks and labels, data, limits and sharing intact. Leave intentionally hidden panels and colourbars alone. Use the provided subplot and export helpers rather than hiding inner labels.

Use Helvetica or Arial only. Prefer Helvetica when installed, otherwise Arial. Fail clearly when neither is available. Do not introduce a different font fallback.

Keep the Set1 palette, normal-weight titles, horizontal grid, outward short ticks, 24-point text, 3-point lines and PNG export at 300 dpi. Preserve the original MIT attribution.

For both MATLAB and Python, produce ONLY PNG at 300 dpi unless the user explicitly asks for another format or resolution. Do not automatically add PDF, SVG, JPEG or other companion exports. Apply this rule to new examples, plotting scripts and downstream projects that use this template. Existing historical files need not be deleted.

Validate Python with pytest and Ruff, and MATLAB with runtests('tests/matlab'). Render and inspect the example figures when layout or style changes. Test visible behaviour through the public helpers, not source-code strings. Document usage changes in README.md.
