library(here)
library(dplyr)

source(here("scripts/functions.R"))



tinytrail(
  description = "Adds efficiency_class variable to mtcars and saves clean data",
  data_source = "mtcars (built-in R dataset)"
)

# ── Clean ─────────────────────────────────────────────────────────────────────

mtcars_clean <- mtcars |>
  tinytrail_dict("mtcars_raw") |>
  mutate(
    model            = rownames(mtcars),
    efficiency_class = if_else(mpg > 20, "High", "Low")
  ) |>
  relocate(model)

saveRDS(mtcars_clean, file = tinytrail_write(here("data/clean/mtcars.rds")))
