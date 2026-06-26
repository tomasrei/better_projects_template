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

f_order_registry_entry <- function(entry) {
  key_order <- c("data_source", "description", "updated", "script_runtime", "n_plots", "n_tables", "outputs")
  entry[c(intersect(key_order, names(entry)), setdiff(names(entry), key_order))]
}

get_current_script_name <- function() {
  idx <- which(vapply(sys.calls(), \(x) deparse(x[[1]]) == "source", logical(1)))
  if (length(idx) == 0) return(NULL)
  basename(sys.frame(idx[length(idx)])$ofile)
}

f_register_script <- function(name = get_current_script_name(), data_source, description) {
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

  registry$scripts[[name]] <- list(
    data_source = data_source,
    description = description,
    updated     = format(Sys.time(), "%Y-%m-%d %H:%M"),
    outputs     = "none"
  )

  all_names        <- names(registry$scripts)
  pipeline         <- all_names[all_names == "main.R — full pipeline"]
  rest             <- sort(all_names[all_names != "main.R — full pipeline"])
  registry$scripts <- lapply(registry$scripts[c(pipeline, rest)], f_order_registry_entry)
  yaml::write_yaml(registry, registry_path)

  options(.current_script_name = name)
}

f_register_output <- function(file) {
  registry_path <- here("_registry.yaml")
  script_name   <- getOption(".current_script_name")
  if (is.null(script_name) || !file.exists(registry_path)) return(invisible(NULL))

  root     <- here()
  rel_file <- if (startsWith(file, root)) substring(file, nchar(root) + 2) else file

  registry     <- yaml::read_yaml(registry_path)
  existing_raw <- registry$scripts[[script_name]]$outputs %||% list()
  existing <- if (identical(existing_raw, "none") || length(existing_raw) == 0) {
    character(0)
  } else {
    as.character(unlist(existing_raw))
  }
  all_out <- unique(c(existing, rel_file))
  outputs <- all_out[order(dirname(all_out),
                           startsWith(basename(all_out), "sensitivity_"),
                           basename(all_out))]
  registry$scripts[[script_name]]$outputs  <- outputs
  registry$scripts[[script_name]]$n_plots  <- sum(grepl("\\.png$", outputs))
  registry$scripts[[script_name]]$n_tables <- sum(grepl("\\.tex$", outputs))
  registry$scripts <- lapply(registry$scripts, f_order_registry_entry)
  yaml::write_yaml(registry, registry_path)
  invisible(file)
}

# Wrap the filename/file argument of any save call to auto-register the output.
# Usage:
#   ggsave(filename = f_record_output_file("plot.png"), path = here("plots"), ...)
#   save_kable(kbl, file = f_record_output_file(here("tables", "table.tex")))
f_record_output_file <- function(file) {
  f_register_output(file)
  file
}

# ── Timing ────────────────────────────────────────────────────────────────────

toc_min <- function(...) {
  result <- toc(func.toc = function(tic, toc, msg) {
    mins <- (toc - tic) / 60
    paste0(msg, ": ", round(mins, 1), " min elapsed")
  }, ...)

  registry_path <- here("_registry.yaml")
  if (file.exists(registry_path) && !is.null(result$msg)) {
    registry <- yaml::read_yaml(registry_path)
    if (!is.null(registry$scripts[[result$msg]])) {
      elapsed_mins <- round((result$toc - result$tic) / 60, 1)
      registry$scripts[[result$msg]]$script_runtime <- paste0(elapsed_mins, " min")
      registry$scripts <- lapply(registry$scripts, f_order_registry_entry)
      yaml::write_yaml(registry, registry_path)
    }
  }

  invisible(result)
}

f_aggregate_main_stats <- function() {
  registry_path <- here("_registry.yaml")
  if (!file.exists(registry_path)) return(invisible(NULL))

  registry      <- yaml::read_yaml(registry_path)
  child_scripts <- registry$scripts[names(registry$scripts) != "main.R — full pipeline"]

  registry$scripts[["main.R — full pipeline"]]$n_plots  <-
    sum(sapply(child_scripts, function(s) s$n_plots  %||% 0))
  registry$scripts[["main.R — full pipeline"]]$n_tables <-
    sum(sapply(child_scripts, function(s) s$n_tables %||% 0))

  registry$scripts <- lapply(registry$scripts, f_order_registry_entry)
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
