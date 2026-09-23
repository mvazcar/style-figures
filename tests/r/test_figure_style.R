source(file.path("R", "figure_style.R"))

s <- figure_style()
stopifnot(
  identical(s$blue, "#0072BD"),
  identical(s$orange, "#D95319"),
  identical(s$red, "#A2142F"),
  identical(length(s$matlab), 7L),
  identical(scale_colour_style_figures()$palette(2), s$matlab),
  s$font_name %in% c("Helvetica", "Arial")
)

m <- figure_style(palette = "set1")
stopifnot(
  identical(m$blue, "#377eb8"),
  identical(m$red, "#e41a1c"),
  identical(length(m$set1), 9L),
  identical(scale_colour_style_figures(palette = "set1")$palette(2),
            m$set1)
)

d <- expand.grid(x = 1:3, panel = c("A", "B"))
d$y <- d$x + as.integer(d$panel == "B")
p <- ggplot2::ggplot(d, ggplot2::aes(x, y)) +
  ggplot2::geom_line(colour = s$blue, linewidth = s$width_mm) +
  facet_wrap_style_figures(~panel, nrow = 1) +
  theme_style_figures()

stopifnot(
  isTRUE(p$facet$params$draw_axes$x),
  isTRUE(p$facet$params$draw_axes$y),
  isTRUE(p$facet$params$axis_labels$x),
  isTRUE(p$facet$params$axis_labels$y),
  identical(p$theme$text$family, s$font_name)
)

path <- tempfile(fileext = ".png")
figure_print(p, path, width = 8.5, height = 3.1875)
stopifnot(file.exists(path), file.info(path)$size > 1000)
unlink(path)

bad <- try(figure_style(font_size = 0), silent = TRUE)
stopifnot(inherits(bad, "try-error"))
