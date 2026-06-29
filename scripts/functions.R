if (!requireNamespace("pak", quietly = TRUE)) install.packages("pak")
if (!requireNamespace("tinytrail", quietly = TRUE)) pak::pak("local::/Users/tomas/Documents/R_Work/tinytrail")

library(here)
library(jsonlite)
library(tinytrail)

# ── Project-specific functions ────────────────────────────────────────────────

# plot_   ggplot2 figures
# tab_    tables (gt, flextable, etc.)
# calc_   derived statistics or transforms
# clean_  data cleaning helpers
# read_   custom data loaders

f_aggregate_main_stats <- function() {
  registry_path <- here("_tinytrail_proj.yaml")
  if (!file.exists(registry_path)) return(invisible(NULL))

  registry      <- yaml::read_yaml(registry_path)
  child_scripts <- registry$scripts[names(registry$scripts) != "main.R"]

  registry$scripts[["main.R"]]$n_files <-
    sum(sapply(child_scripts, function(s) if (is.null(s$n_files)) 0L else s$n_files))

  key_order <- c("data_source", "description", "first_run", "latest_run", "script_runtime", "n_files", "outputs")
  order_entry <- function(e) e[c(intersect(key_order, names(e)), setdiff(names(e), key_order))]
  registry$scripts <- lapply(registry$scripts, order_entry)
  yaml::write_yaml(registry, registry_path)
  invisible(NULL)
}

# ── Inline stats for Typst ────────────────────────────────────────────────────

f_write_stats <- function(stats, namespace = NULL) {
  json_path <- here("typst/data.json")
  existing  <- if (file.exists(json_path)) read_json(json_path) else list()

  new_data <- if (!is.null(namespace)) {
    setNames(list(stats), namespace)
  } else {
    stats
  }

  merged <- modifyList(existing, new_data)
  write_json(merged, json_path, auto_unbox = TRUE, pretty = TRUE)
}
