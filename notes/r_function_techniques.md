# 7 Techniques for Writing Better R Functions

Source: YouTube — *7 Easy Techniques To Write Smooth R Functions*

---

## 1. Use Descriptive, Verb-Based Names

Name functions after what they *do*, not cryptic abbreviations.

```r
# Bad
cmp <- function(sx) mean(sx)

# Good
calculate_mean_prices <- function(prices) mean(prices)
```

Also name arguments descriptively (`prices` instead of `sx`).

**Bonus — prefix families of functions** so autocomplete helps you find them:
- `stringr` uses `str_*` for all string functions
- In a pipeline with OCR → LLM steps, use `ocr_*` and `llm_*` to group related functions

---

## 2. Make Functions Vectorized

R users expect functions to work on vectors of any length, not just scalars. A regular `if/else` block breaks when you pass a vector.

```r
# Breaks with vectors
categorize_price <- function(price) {
  if (price > 50) "expensive" else "normal"
}

# Works with vectors
categorize_price <- function(price, threshold = 50) {
  ifelse(price > threshold, "expensive", "normal")
}
```

`ifelse()` evaluates element-wise over a vector.

---

## 3. Avoid Magic Numbers

Hardcoded numbers are unreadable and inflexible. Expose them as arguments with sensible defaults.

```r
# Bad — what does 50 mean?
categorize_price <- function(price) ifelse(price > 50, "expensive", "normal")

# Good — flexible and self-documenting
categorize_price <- function(price, threshold = 50) {
  ifelse(price > threshold, "expensive", "normal")
}
```

---

## 4. Put the Data Frame First

When your function operates on a data frame, make it the **first argument**. This lets functions chain naturally with `|>` or `%>%`.

```r
append_price_category <- function(df, threshold = 50) {
  df |> mutate(price_category = categorize_price(price, threshold))
}

calculate_price_stats <- function(df, by) {
  df |> group_by({{ by }}) |> summarize(mean_price = mean(price))
}

# Composes cleanly in a pipe
data |>
  append_price_category() |>
  calculate_price_stats(by = price_category)
```

---

## 5. Curly-Curly `{{ }}` for Tidy Evaluation

When a function argument is meant to be an **unquoted column name** used inside tidyverse verbs (`mutate`, `group_by`, `summarize`, etc.), wrap it with `{{ }}`.

```r
# Reading a column
calculate_price_stats <- function(df, by) {
  df |> group_by({{ by }}) |> summarize(mean_price = mean(price))
}

# Writing / naming a new column — use := on the left side
append_group_column <- function(df, column) {
  df |> mutate({{ column }} := sample(c("A", "B"), n(), replace = TRUE))
}
```

- `{{ var }}` on the **right** side → reads the column named by `var`
- `{{ var }} :=` on the **left** side → creates a column named by `var`

---

## 6. `...` (Dot-Dot-Dot) for Pass-Through Arguments

Use `...` to forward flexible, variable arguments to an inner function without spelling them all out.

```r
calculate_price_stats <- function(df, by, ...) {
  df |>
    group_by({{ by }}) |>
    summarize(mean_price = mean(price), ...)
}

# Caller can add extra summary columns on the fly
data |>
  calculate_price_stats(
    by = price_category,
    max_price = max(price),
    min_price = min(price)
  )
```

**Caution:** `...` swallows any argument that doesn't match a named parameter. Mistyped argument names can silently pass through and produce confusing errors downstream.

---

## 7. S7 Classes to Bundle Function Arguments

When a function takes many arguments that evolve over time, bundle them into an **S7 class**. The function signature stays stable as you add or remove fields.

```r
library(S7)

Patient <- new_class("Patient", properties = list(
  name   = class_character,
  age    = class_integer,
  height = class_numeric,
  weight = class_numeric,
  bmi    = new_property(class_numeric, getter = function(self) {
    self@weight / (self@height / 100)^2
  })
))

analyze_patient <- function(patient) {
  glue::glue("Patient: {patient@name}, Age: {patient@age}, BMI: {round(patient@bmi, 1)}")
}
```

- Add or remove fields in the class definition without touching every call site.
- Access fields with `@` (e.g., `patient@name`).
- Computed properties (like `bmi` above) are defined inline via `getter`.
