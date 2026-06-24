// ── Paths ─────────────────────────────────────────────────────────────────────
#let plots  = "plots/"
#let tables = "tables/"
#let data   = json("data.json")

// ── Document ──────────────────────────────────────────────────────────────────

#set document(title: "Title", author: "Tomas Reivinger")
#set page(paper: "a4", margin: (x: 2.5cm, y: 3cm))
#set text(font: "New Computer Modern", size: 11pt)
#set par(justify: true)

= Title

// Example: insert a computed value inline
// In 2007, the number of car-accidents in Liverpool was #data.accidents.n_liverpool_2007.

// Example: insert a plot
// #image(plots + "figure_name.png")
