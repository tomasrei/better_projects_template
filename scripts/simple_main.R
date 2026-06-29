library(here)
library(ggplot2)
library(tinytable)
if ("tinytrail" %in% loadedNamespaces()) pkgload::unload("tinytrail")
devtools::install("/Users/tomas/Documents/R_Work/tinytrail", quick = TRUE)
devtools::load_all("/Users/tomas/Documents/R_Work/tinytrail", quiet = TRUE)
options(.tinytrail_current_script = NULL, .tinytrail_registry_path = NULL, .tinytrail_warned = NULL)

tinytrail(
  description = "Smoke test: exercises all three tinytrail functions without source()",
  data_source = "mtcars (built-in R dataset)"
)

# ── Prepare data ───────────────────────────────────────────────────────────────

dat <- within(mtcars, {
  model            <- rownames(mtcars)
  efficiency_class <- ifelse(mpg > 20, "High", "Low")
})

# ── Plot ───────────────────────────────────────────────────────────────────────

ggplot(dat, aes(x = wt, y = mpg, colour = efficiency_class)) +
  geom_point(size = 2.5) +
  scale_colour_manual(values = c("High" = "#2166ac", "Low" = "#d6604d")) +
  labs(x = "Weight (1000 lbs)", y = "Miles per gallon", colour = "Efficiency") +
  theme_minimal(base_size = 11)

ggsave(
  filename = tinytrail_write(here("typst/plots/simple_mtcars.png")),
  width = 14, height = 9, units = "cm", dpi = 300, bg = "white"
)

# ── Table ──────────────────────────────────────────────────────────────────────

tab <- aggregate(cbind(mpg, hp) ~ efficiency_class, data = dat, FUN = mean)

tt(tab) |>
  save_tt(
    output    = tinytrail_write(here("typst/tables/simple_mtcars.typ")),
    overwrite = TRUE
  )

# ── Save clean data ────────────────────────────────────────────────────────────

saveRDS(dat, file = tinytrail_write(here("data/clean/mtcars_simple.rds")))

# ── Data dictionary (last, after all transforms are done) ─────────────────────

dat |> tinytrail_dict()
dat |> tinytrail_dict()