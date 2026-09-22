source(file.path("R", "figure_style.R"))

s <- figure_style(font_size = 18, line_width = 2)
x <- seq(0, 1, length.out = 50)
data <- expand.grid(x = x, panel = c("Founding age", "IPO age"),
                    series = c("First", "Second"))
data$y <- 1 + data$x +
  ifelse(data$panel == "IPO age", 0.5, 0) +
  ifelse(data$series == "Second", 0.35, 0)

p <- ggplot2::ggplot(data, ggplot2::aes(x, y, colour = series)) +
  ggplot2::geom_line(linewidth = s$width_mm) +
  facet_wrap_style_figures(~panel, nrow = 1) +
  scale_colour_style_figures() +
  ggplot2::labs(x = "Age", y = "Average markup", colour = NULL) +
  theme_style_figures(font_size = s$font, line_width = s$width)

figure_print(p, file.path("figures", "r_panels.png"), width = 17, height = 6.375)
