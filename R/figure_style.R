# ggplot2 adaptation of the style-figures MATLAB and Matplotlib template.
# MATLAB's R2014b-R2024b seven-colour ColorOrder is the default.

.style_figures_set1 <- c(
  blue = "#377eb8", red = "#e41a1c", green = "#4daf4a",
  purple = "#984ea3", orange = "#ff7f00", yellow = "#ffff33",
  brown = "#a65628", pink = "#f781bf", gray = "#999999"
)

.style_figures_matlab <- c(
  blue = "#0072BD", orange = "#D95319", yellow = "#EDB120",
  purple = "#7E2F8E", green = "#77AC30", cyan = "#4DBEEE",
  red = "#A2142F"
)

.style_figures_colors <- function(palette) {
  palette <- match.arg(palette, c("set1", "matlab"))
  if (palette == "set1") .style_figures_set1 else .style_figures_matlab
}

.style_figures_positive <- function(value, name) {
  if (!is.numeric(value) || length(value) != 1L || !is.finite(value) || value <= 0) {
    stop(name, " must be a finite positive number.", call. = FALSE)
  }
  invisible(value)
}

.style_figures_font <- function() {
  if (!requireNamespace("systemfonts", quietly = TRUE)) {
    stop("Install the systemfonts package to check for Helvetica or Arial.", call. = FALSE)
  }
  available <- unique(systemfonts::system_fonts()$family)
  for (font in c("Helvetica", "Arial")) {
    if (font %in% available) {
      # grid/ggpubr may measure text before the ragg export device opens.
      if (.Platform$OS.type == "windows") {
        do.call(grDevices::windowsFonts,
                setNames(list(grDevices::windowsFont(font)), font))
      }
      return(font)
    }
  }
  stop("style-figures requires Helvetica or Arial. Install either font first.", call. = FALSE)
}

# Return the named palette and the settings used by the other implementations.
figure_style <- function(font_size = 24, line_width = 3, palette = "matlab") {
  .style_figures_positive(font_size, "font_size")
  .style_figures_positive(line_width, "line_width")
  palette <- match.arg(palette, c("set1", "matlab"))
  colors <- .style_figures_colors(palette)
  named <- as.list(.style_figures_set1)
  for (name in names(colors)) named[[name]] <- colors[[name]]
  c(
    named,
    list(
      black = "#000000", set1 = unname(.style_figures_set1),
      matlab = unname(.style_figures_matlab), palette = palette,
      font = font_size, width = line_width,
      width_mm = line_width * 25.4 / 72,
      font_name = .style_figures_font()
    )
  )
}

# White 4:3 scientific figures; each visible panel keeps bottom and left axes.
theme_style_figures <- function(font_size = 24, line_width = 3,
                                palette = "matlab") {
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    stop("Install the ggplot2 package to use theme_style_figures().", call. = FALSE)
  }
  s <- figure_style(font_size, line_width, palette)
  ggplot2::theme(
    text = ggplot2::element_text(family = s$font_name, size = s$font, colour = s$black),
    plot.background = ggplot2::element_rect(fill = "white", colour = NA),
    panel.background = ggplot2::element_rect(fill = "white", colour = NA),
    panel.border = ggplot2::element_blank(),
    panel.grid.major.x = ggplot2::element_blank(),
    panel.grid.minor = ggplot2::element_blank(),
    panel.grid.major.y = ggplot2::element_line(
      colour = grDevices::adjustcolor(s$black, alpha.f = 0.15), linewidth = 0.35
    ),
    axis.line.x = ggplot2::element_line(colour = s$black, linewidth = 0.35),
    axis.line.y = ggplot2::element_line(colour = s$black, linewidth = 0.35),
    axis.ticks = ggplot2::element_line(colour = s$black, linewidth = 0.35),
    axis.ticks.length = grid::unit(3, "pt"),
    axis.text = ggplot2::element_text(size = s$font, colour = s$black),
    axis.title = ggplot2::element_text(size = s$font, face = "plain"),
    plot.title = ggplot2::element_text(size = s$font, face = "plain"),
    legend.background = ggplot2::element_blank(),
    legend.key = ggplot2::element_blank(),
    legend.text = ggplot2::element_text(size = s$font),
    strip.background = ggplot2::element_blank(),
    strip.text = ggplot2::element_text(size = s$font, face = "plain")
  )
}

scale_colour_style_figures <- function(..., palette = "matlab") {
  ggplot2::scale_colour_manual(
    values = unname(.style_figures_colors(palette)), ...)
}

scale_fill_style_figures <- function(..., palette = "matlab") {
  ggplot2::scale_fill_manual(
    values = unname(.style_figures_colors(palette)), ...)
}

# ggplot2 suppresses inner facet labels by default. These wrappers show axes
# and tick labels on every panel, matching figure_ticks() in Python/MATLAB.
facet_wrap_style_figures <- function(...) {
  ggplot2::facet_wrap(..., axes = "all", axis.labels = "all")
}

facet_grid_style_figures <- function(...) {
  ggplot2::facet_grid(..., axes = "all", axis.labels = "all")
}

# Export one PNG at the template's physical size and resolution by default.
figure_print <- function(plot, file, width = 8.5, height = 6.375, dpi = 300) {
  .style_figures_positive(width, "width")
  .style_figures_positive(height, "height")
  .style_figures_positive(dpi, "dpi")
  if (!grepl("\\.png$", file, ignore.case = TRUE)) {
    stop("figure_print() requires a .png filename.", call. = FALSE)
  }
  if (!requireNamespace("ragg", quietly = TRUE)) {
    stop("Install the ragg package for font-correct PNG export.", call. = FALSE)
  }
  ggplot2::ggsave(
    filename = file, plot = plot, width = width, height = height,
    units = "in", dpi = dpi, bg = "white", device = ragg::agg_png
  )
  invisible(file)
}
