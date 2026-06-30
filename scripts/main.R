if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")
pak::pak("tinytrail-r/tinytrail")

library(tinytrail)
library(ggplot2)
library(tinytable)
library(here)

tinytrail(
  description = "Template: mtcars cleaning, plot, and table",
  data_source = "mtcars (built-in R dataset)",
  extra_hooks = list(fn = "tinytable::save_tt", arg = "output")
)

# ── Prepare data ───────────────────────────────────────────────────────────────

dat <- within(mtcars, {
  model            <- rownames(mtcars)
  efficiency_class <- ifelse(mpg > 20, "High", "Low")
})

# ── Plot (auto-tracked via ggsave hook) ───────────────────────────────────────

ggplot(dat, aes(x = wt, y = mpg, colour = efficiency_class)) +
  geom_point(size = 2.5) +
  scale_colour_manual(values = c("High" = "#2166ac", "Low" = "#d6604d")) +
  labs(x = "Weight (1000 lbs)", y = "Miles per gallon", colour = "Efficiency") +
  theme_minimal(base_size = 11)

ggsave(
  filename = here("typst/plots/simple_mtcars.png"),
  width = 14, height = 9, units = "cm", dpi = 300, bg = "white"
)

# ── Table (auto-tracked via extra_hooks) ──────────────────────────────────────

tab <- aggregate(cbind(mpg, hp) ~ efficiency_class, data = dat, FUN = mean)

tt(tab) |>
  save_tt(
    output    = here("typst/tables/simple_mtcars.typ"),
    overwrite = TRUE
  )

# ── Save clean data ────────────────────────────────────────────────────────────

saveRDS(dat, here("data/clean/mtcars_simple.rds"))

# ── Data dictionary (last, after all transforms are done) ─────────────────────

dat |> tinytrail_dict()
