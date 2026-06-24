library(here)
library(dplyr)

source(here("scripts/functions.R"))

f_register_script(
  name        = "mtcars_clean.R",
  data_source = "mtcars (built-in R dataset)",
  description = "Adds efficiency_class variable to mtcars and saves clean data"
)

# ── Clean ─────────────────────────────────────────────────────────────────────

mtcars_clean <- mtcars |>
  mutate(
    model           = rownames(mtcars),
    efficiency_class = if_else(mpg > 20, "High", "Low")
  ) |>
  relocate(model)

saveRDS(mtcars_clean, here("data/clean/mtcars.rds"))
