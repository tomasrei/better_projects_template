library(S7)
library(openxlsx)
library(here)
library(jsonlite)

# ── Project-specific functions ────────────────────────────────────────────────

# plot_   ggplot2 figures
# tab_    tables (gt, flextable, etc.)
# calc_   derived statistics or transforms
# clean_  data cleaning helpers
# read_   custom data loaders

# ── Script registry ───────────────────────────────────────────────────────────

ScriptMeta <- new_class("ScriptMeta",
  properties = list(
    name        = class_character,
    data_source = class_character,
    description = class_character,
    updated     = class_character
  )
)

f_register_script <- function(name, data_source, description) {
  entry <- ScriptMeta(
    name        = name,
    data_source = data_source,
    description = description,
    updated     = format(Sys.time(), "%Y-%m-%d %H:%M")
  )

  registry_path <- here("_registry.xlsx")

  if (file.exists(registry_path)) {
    wb       <- loadWorkbook(registry_path)
    registry <- readWorkbook(wb, sheet = "registry")
  } else {
    wb       <- createWorkbook()
    registry <- data.frame(
      name        = character(),
      data_source = character(),
      description = character(),
      updated     = character()
    )
  }

  registry <- registry[registry$name != entry@name, ]
  registry <- rbind(registry, data.frame(
    name        = entry@name,
    data_source = entry@data_source,
    description = entry@description,
    updated     = entry@updated
  ))
  registry <- registry[order(registry$name), ]

  if ("registry" %in% names(wb)) removeWorksheet(wb, "registry")
  addWorksheet(wb, "registry")
  writeData(wb, "registry", registry)
  saveWorkbook(wb, registry_path, overwrite = TRUE)
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
