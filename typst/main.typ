// ── Paths & data ─────────────────────────────────────────────────────────────
// Run scripts/mtcars_clean.R then scripts/mtcars_analyse.R before compiling.

#let plots  = "plots/"
#let tables = "tables/"
#let data   = json("data.json")

// ── Document ──────────────────────────────────────────────────────────────────

#set document(title: "Example: Motor Trend Cars", author: "Tomas Reivinger")
#set page(paper: "a4", margin: (x: 2.5cm, y: 3cm))
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)

= Motor Trend Cars

== Fuel efficiency

The dataset contains #data.mtcars.n_total cars. Of these,
#data.mtcars.n_high_efficiency were classified as high efficiency, defined as achieving more than 20 miles per gallon.

@fig-mpg-weight shows the relationship between vehicle weight and fuel
efficiency. Heavier cars consistently achieve lower mileage, with high-efficiency
cars concentrated at the lower end of the weight range.

#figure(
  image(plots + "mtcars_mpg_weight.png", width: 90%),
  caption: [Miles per gallon by vehicle weight and efficiency class.]
) <fig-mpg-weight>

== Summary by cylinder count

@tbl-cyl-summary presents mean fuel efficiency, horsepower, and weight
broken down by number of cylinders.

#figure(
  include(tables + "mtcars_by_cyl.typ"),
  caption: [Mean statistics by cylinder count.]
) <tbl-cyl-summary>
