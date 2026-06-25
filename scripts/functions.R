library(here)
library(jsonlite)
library(yaml)

# ── Project-specific functions ────────────────────────────────────────────────

# plot_   ggplot2 figures
# tab_    tables (gt, flextable, etc.)
# calc_   derived statistics or transforms
# clean_  data cleaning helpers
# read_   custom data loaders

# ── Script registry ───────────────────────────────────────────────────────────

f_register_script <- function(name, data_source, description) {
  registry_path <- here("_registry.yaml")

  if (file.exists(registry_path)) {
    registry <- yaml::read_yaml(registry_path)
  } else {
    registry <- list(
      `$version`    = "0.1.0",
      `$learn_more` = "https://data-dict.tidyverse.org",
      scripts       = list()
    )
  }

  existing_outputs <- registry$scripts[[name]]$outputs
  registry$scripts[[name]] <- list(
    data_source = data_source,
    description = description,
    updated     = format(Sys.time(), "%Y-%m-%d %H:%M"),
    outputs     = existing_outputs %||% list()
  )

  registry$scripts <- registry$scripts[order(names(registry$scripts))]
  yaml::write_yaml(registry, registry_path)

  options(.current_script_name = name)
}

f_register_output <- function(file) {
  registry_path <- here("_registry.yaml")
  script_name   <- getOption(".current_script_name")
  if (is.null(script_name) || !file.exists(registry_path)) return(invisible(NULL))

  root     <- here()
  rel_file <- if (startsWith(file, root)) substring(file, nchar(root) + 2) else file

  registry <- yaml::read_yaml(registry_path)
  existing <- as.character(unlist(registry$scripts[[script_name]]$outputs %||% list()))
  registry$scripts[[script_name]]$outputs <- sort(unique(c(existing, rel_file)))
  yaml::write_yaml(registry, registry_path)
  invisible(file)
}

f_record_output_file <- function(file) {
  f_register_output(file)
  file
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
