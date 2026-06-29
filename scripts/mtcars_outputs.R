library(here)
library(dplyr)
library(ggplot2)
library(tinytable)

source(here("scripts/functions.R"))



tinytrail(
  description = "Plots and tables from mtcars clean data",
  data_source = "mtcars clean data (mtcars_clean.R)"
)

Sys.sleep(12)

dat <- readRDS(here("data/clean/mtcars.rds")) |>
  tinytrail_dict("mtcars_clean")

tab <- dat |>
  group_by(cyl) |>
  summarise(
    `Mean MPG`    = round(mean(mpg), 1),
    `Mean HP`     = round(mean(hp), 0),
    `Mean weight` = round(mean(wt), 2),
    N             = n()
  ) |>
  rename(Cylinders = cyl)

# ── Plot ──────────────────────────────────────────────────────────────────────

ggplot(dat, aes(x = wt, y = mpg, colour = efficiency_class)) +
  geom_point(size = 2.5) +
  geom_smooth(method = "lm", se = TRUE) +
  scale_colour_manual(values = c("High" = "#2166ac", "Low" = "#d6604d")) +
  labs(x = "Weight (1000 lbs)", y = "Miles per gallon", colour = "Efficiency") +
  theme_minimal(base_size = 11)

ggsave(
  filename = tinytrail_write(here("typst/plots/mtcars_ggplot2.png")),
  width = 14, height = 9, units = "cm", dpi = 300, bg = "white"
)

# ── Multiple outputs: lapply and map ──────────────────────────────────────────
# Expected n_files after this block: 3 (one per cyl group)

cyl_levels <- unique(dat$cyl)

lapply(cyl_levels, function(cyl_val) {
  p <- ggplot(dat[dat$cyl == cyl_val, ], aes(x = wt, y = mpg)) +
    geom_point(size = 2.5) +
    labs(title = paste(cyl_val, "cylinders"), x = "Weight", y = "MPG") +
    theme_minimal(base_size = 11)
  ggsave(
    filename = tinytrail_write(here(paste0("typst/plots/mtcars_cyl", cyl_val, "_lapply.png"))),
    plot = p, width = 10, height = 7, units = "cm", dpi = 300, bg = "white"
  )
})

purrr::map(cyl_levels, function(cyl_val) {
  p <- ggplot(dat[dat$cyl == cyl_val, ], aes(x = wt, y = mpg)) +
    geom_point(size = 2.5) +
    labs(title = paste(cyl_val, "cylinders"), x = "Weight", y = "MPG") +
    theme_minimal(base_size = 11)
  ggsave(
    filename = tinytrail_write(here(paste0("typst/plots/mtcars_cyl", cyl_val, "_map.png"))),
    plot = p, width = 10, height = 7, units = "cm", dpi = 300, bg = "white"
  )
})

# ── Table ─────────────────────────────────────────────────────────────────────

tt(tab) |>
  save_tt(
    output    = tinytrail_write(here("typst/tables/mtcars_tinytable.typ")),
    overwrite = TRUE
  )

# ── Inline stats (not part of package (yet)!) ──────────────────────────────────────────────────────────────

n_total           <- nrow(dat)
n_high_efficiency <- dat |> filter(efficiency_class == "High") |> nrow()

f_write_stats(
  stats     = list(n_total = n_total, n_high_efficiency = n_high_efficiency),
  namespace = "mtcars"
)
