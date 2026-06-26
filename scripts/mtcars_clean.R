library(here)
library(dplyr)
library(tictoc)

source(here("scripts/functions.R"))

f_register_script(
  data_source = "mtcars (built-in R dataset)",
  description = "Adds efficiency_class variable to mtcars and saves clean data"
)
tic(getOption(".current_script_name"))

# ── Clean ─────────────────────────────────────────────────────────────────────

mtcars_clean <- mtcars |>
  mutate(
    model            = rownames(mtcars),
    efficiency_class = if_else(mpg > 20, "High", "Low")
  ) |>
  relocate(model)

saveRDS(mtcars_clean, file = f_record_output_file(here("data/clean/mtcars.rds")))

toc_min()
