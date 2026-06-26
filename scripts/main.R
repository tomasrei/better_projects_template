library(here)
library(tictoc)

source(here("scripts/functions.R"))

f_register_script(
  name        = "main.R — full pipeline",
  data_source = "all",
  description = "Full pipeline: clean + analyse mtcars",
  pin_to_top  = TRUE
)
tic("main.R — full pipeline")

source(here("scripts/mtcars_clean.R"))
source(here("scripts/mtcars_analyse.R"))

toc_min()
f_aggregate_main_stats()
