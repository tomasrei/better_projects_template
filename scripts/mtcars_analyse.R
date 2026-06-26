library(here)
library(dplyr)
library(ggplot2)
library(tinytable)

source(here("scripts/functions.R"))

f_register_script(
  data_source = "data/clean/mtcars.rds",
  description = "Plots MPG vs weight, summarises stats by cylinder, counts high-efficiency cars"
)

dat <- readRDS(here("data/clean/mtcars.rds"))

# ── Plot ──────────────────────────────────────────────────────────────────────

ggplot(dat, aes(x = wt, y = mpg, colour = efficiency_class)) +
  geom_point(size = 2.5) +
  geom_smooth(method = "lm", se = TRUE) +
  scale_colour_manual(values = c("High" = "#2166ac", "Low" = "#d6604d")) +
  labs(
    x      = "Weight (1000 lbs)",
    y      = "Miles per gallon",
    colour = "Efficiency"
  ) +
  theme_minimal(base_size = 11)

ggsave(
  filename = f_record_output_file(here("typst/plots/mtcars_mpg_weight.png")),
  width = 14, height = 9, units = "cm", dpi = 300, bg = "white"
)

# ── Table ─────────────────────────────────────────────────────────────────────

tab <- dat |>
  group_by(cyl) |>
  summarise(
    `Mean MPG`    = round(mean(mpg), 1),
    `Mean HP`     = round(mean(hp), 0),
    `Mean weight` = round(mean(wt), 2),
    N             = n()
  ) |>
  rename(Cylinders = cyl)

tt(tab) |> print()

tt(tab) |>
  save_tt(
    output    = f_record_output_file(here("typst/tables/mtcars_by_cyl.typ")),
    overwrite = TRUE
  )

# ── Inline stats ──────────────────────────────────────────────────────────────

n_total           <- nrow(dat)
n_high_efficiency <- dat |> filter(efficiency_class == "High") |> nrow()

f_write_stats(
  stats = list(
    n_total           = n_total,
    n_high_efficiency = n_high_efficiency
  ),
  namespace = "mtcars"
)
