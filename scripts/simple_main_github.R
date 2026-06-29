if ("tinytrail" %in% loadedNamespaces()) pkgload::unload("tinytrail")
remove.packages("tinytrail")
pak::cache_delete("tinytrail")
pak::pak("tinytrail-r/tinytrail")

library(tinytrail)
library(tinytable)
library(here)
library(ggplot2)

tinytrail(
  description = "Smoke test: GitHub install, auto hooks, extra_hooks, and explicit tinytrail_write()",
  data_source = "mtcars (built-in R dataset)",
  extra_hooks = data.frame(fn = "tinytable::save_tt", arg = "output")
)

# ── Prepare data ───────────────────────────────────────────────────────────────

dat <- within(mtcars, {
  model            <- rownames(mtcars)
  efficiency_class <- ifelse(mpg > 20, "High", "Low")
})

# ── Plot (auto-hooked via ggsave) ──────────────────────────────────────────────

ggplot(dat, aes(x = wt, y = mpg, colour = efficiency_class)) +
  geom_point(size = 2.5) +
  scale_colour_manual(values = c("High" = "#2166ac", "Low" = "#d6604d")) +
  labs(x = "Weight (1000 lbs)", y = "Miles per gallon", colour = "Efficiency") +
  theme_minimal(base_size = 11)

ggsave(
  filename = here("typst/plots/simple_mtcars.png"),
  width = 14, height = 9, units = "cm", dpi = 300, bg = "white"
)

# ── Table (auto-hooked via extra_hooks) ────────────────────────────────────────

tab <- aggregate(cbind(mpg, hp) ~ efficiency_class, data = dat, FUN = mean)

tt(tab) |>
  save_tt(
    output    = here("typst/tables/simple_mtcars.typ"),
    overwrite = TRUE
  )

# ── Save clean data (explicit tinytrail_write) ─────────────────────────────────

saveRDS(dat, file = tinytrail_write(here("data/clean/mtcars_simple.rds")))

# ── Data dictionary (last, after all transforms are done) ─────────────────────

dat |> tinytrail_dict()
