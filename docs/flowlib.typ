// ============================================================
// flowlib.typ — shared visual style for /flowchart howto documents.
//
// Copied verbatim into each project by the /flowchart skill, so the
// project compiles on its own. Don't hand-edit the copy in a project;
// change the master in the flowchart skill (assets/flowlib.typ) and re-copy.
//
// Contents:
//   1. Colours + language strings
//   2. Icons (hand-drawn from basic shapes, no image files)
//   3. Diagram parts (fletcher nodes/edges in the house style)
//   4. Text parts (step grid, legend, note box, annotated folder tree)
//   5. Page setup (pure-Typst mode only)
// ============================================================

#import "@preview/fletcher:0.5.8" as fletcher: diagram, node, edge

#let flowlib-version = "1"

// ------------------------------------------------------------
// 1. Colours + language strings
// ------------------------------------------------------------

#let brand  = rgb("#1a3a5c")   // main colour: hand-edited sources, arrows, headings
#let stripe = rgb("#f2f5f8")   // light fill: process boxes, note boxes
#let border = rgb("#c7d2dd")   // thin rules, group outlines
#let accent = rgb("#b5540a")   // the thing you run / attention
#let muted  = rgb("#7a8a9c")   // generated intermediates (don't edit)
#let good   = rgb("#2e6b4f")   // final outputs

// Node/file kinds, used consistently in diagrams and the folder tree.
//   src = hand-edited source   run = script/command you run
//   gen = generated, don't edit   out = final output
//   ext = external system/person   old = archive, not part of the flow
//   dir = plain folder (tree only)
#let fc-kind-color = (
  src: brand, run: accent, gen: muted, out: good, ext: brand, old: border, dir: brand,
)

#let fc-lang = state("fc-lang", "en")
#let fc-strings = (
  en: (manual: "manual", src: "edit", run: "run", gen: "generated", out: "output",
       ext: "external", old: "archive", reads: "reads", legend: "Legend"),
  sv: (manual: "manuellt", src: "redigera", run: "kör", gen: "genereras", out: "resultat",
       ext: "extern", old: "arkiv", reads: "läser", legend: "Teckenförklaring"),
)
// Look up a UI string in the current language (falls back to English).
#let fc-t(key) = context {
  let l = fc-lang.get()
  fc-strings.at(l, default: fc-strings.en).at(key, default: fc-strings.en.at(key))
}
// Set the language for flowlib strings. Pure Typst: fc-doc does this.
// Quarto: call `#fc-set-lang("sv")` in a {=typst} block at the top.
#let fc-set-lang(l) = fc-lang.update(l)

// ------------------------------------------------------------
// 2. Icons — all return a box of fixed size
// ------------------------------------------------------------

#let fc-icon-sheet(w: 2.1cm, h: 1.55cm, color: brand) = box(width: w, height: h)[
  #place(top+left, rect(width: w, height: h, radius: 2pt, fill: white, stroke: 1.1pt + color))
  #place(top+left, rect(width: w, height: h / 3, radius: (top-left: 2pt, top-right: 2pt), fill: color))
  #for i in (1, 2) {
    place(top+left, dx: i * w / 3, line(start: (0pt, 0pt), end: (0pt, h), stroke: 0.5pt + color))
    place(top+left, dy: i * h / 3, line(start: (0pt, 0pt), end: (w, 0pt), stroke: 0.5pt + color))
  }
]

// Document page with text lines and a coloured format tag ("PDF", "R", "YAML"...).
#let fc-icon-doc(w: 1.6cm, h: 2.05cm, color: brand, tag: none) = box(width: w, height: h)[
  #place(top+left, rect(width: w, height: h, radius: 3pt, fill: white, stroke: 1.1pt + color))
  #for i in range(3) {
    place(top+left, dx: w * 0.18, dy: h * 0.20 + i * h * 0.13,
      line(start: (0pt, 0pt), end: (w * 0.64, 0pt), stroke: 0.6pt + color))
  }
  #if tag != none {
    place(bottom+left, dy: -h * 0.14, dx: w * 0.14,
      box(fill: color, radius: 2pt, inset: (x: 4pt, y: 2pt))[
        #text(fill: white, size: 6.5pt, weight: "bold")[#tag]
      ])
  }
]

// Stack of pages: "many files of this kind" (e.g. plots/, tables/).
#let fc-icon-docs(w: 1.6cm, h: 2.05cm, color: brand, tag: none) = box(width: w + 6pt, height: h + 6pt)[
  #place(top+left, dx: 6pt, rect(width: w, height: h, radius: 3pt, fill: white, stroke: 0.8pt + color))
  #place(top+left, dx: 3pt, dy: 3pt, rect(width: w, height: h, radius: 3pt, fill: white, stroke: 0.8pt + color))
  #place(top+left, dy: 6pt, fc-icon-doc(w: w, h: h, color: color, tag: tag))
]

#let fc-icon-folder(w: 2.1cm, h: 1.6cm, color: brand, tag: none) = box(width: w, height: h)[
  #place(top+left, rect(width: w * 0.42, height: h * 0.3, radius: (top-left: 3pt, top-right: 3pt), fill: color))
  #place(top+left, dy: h * 0.18, rect(width: w, height: h * 0.82, radius: 3pt, fill: white, stroke: 1.1pt + color))
  #place(top+left, dy: h * 0.18, rect(width: w, height: h * 0.14, radius: (top-left: 3pt, top-right: 3pt), fill: color))
  #if tag != none {
    place(bottom+left, dy: -h * 0.12, dx: w * 0.1,
      box(fill: color, radius: 2pt, inset: (x: 4pt, y: 2pt))[
        #text(fill: white, size: 6.5pt, weight: "bold")[#tag]
      ])
  }
]

// Database cylinder.
#let fc-icon-db(w: 1.6cm, h: 1.8cm, color: brand) = box(width: w, height: h)[
  #let e = h * 0.22
  #let st = 1.1pt + color
  #place(top+left, dy: h - e, ellipse(width: w, height: e, fill: white, stroke: st))
  #place(top+left, dy: e / 2, rect(width: w, height: h - e, fill: white, stroke: none))
  #place(top+left, dy: e / 2, line(start: (0pt, 0pt), end: (0pt, h - e), stroke: st))
  #place(top+left, dx: w, dy: e / 2, line(start: (0pt, 0pt), end: (0pt, h - e), stroke: st))
  #for i in (1, 2) {
    let y = e / 2 + i * (h - e) / 3
    place(top+left, curve(stroke: 0.6pt + color,
      curve.move((0pt, y)), curve.quad((w / 2, y + e), (w, y))))
  }
  #place(top+left, ellipse(width: w, height: e, fill: color, stroke: st))
]

#let fc-icon-person(size: 1.8cm, color: brand) = box(width: size, height: size)[
  #place(top+center, dy: size * 0.04, circle(radius: size * 0.2, fill: color))
  #place(bottom+center, rect(width: size * 0.8, height: size * 0.42,
    radius: (top-left: size * 0.4, top-right: size * 0.4), fill: color))
]

// Bot / AI assistant / external service.
#let fc-icon-bot(size: 1.8cm, color: brand) = box(width: size, height: size)[
  #let hw = size * 0.82
  #let hh = size * 0.62
  #place(top+center, line(start: (0pt, 0pt), end: (0pt, size * 0.2), stroke: 1.1pt + color))
  #place(top+center, dy: -size * 0.04, circle(radius: size * 0.06, fill: color))
  #place(bottom+center, dy: -size * 0.04, rect(width: hw, height: hh, radius: size * 0.14, fill: white, stroke: 1.3pt + color))
  #place(bottom+center, dy: -size * 0.04 - hh * 0.5, dx: -hw * 0.2, circle(radius: size * 0.075, fill: color))
  #place(bottom+center, dy: -size * 0.04 - hh * 0.5, dx: hw * 0.2, circle(radius: size * 0.075, fill: color))
  #place(bottom+center, dy: -size * 0.04 - hh * 0.18,
    line(start: (-hw * 0.18, 0pt), end: (hw * 0.18, 0pt), stroke: 1.1pt + color))
]

// Any image file as an icon (e.g. a logo). Path is relative to the file
// that *calls* this (in Quarto: relative to the .qmd).
#let fc-icon-image(path, size: 1.8cm) = box(width: size, height: size)[
  #image(path, width: size, height: size, fit: "contain")
]

// ------------------------------------------------------------
// 3. Diagram parts (fletcher)
// ------------------------------------------------------------

// Diagram wrapper with house defaults. Pass nodes/edges as positional args.
// Coordinates are grid cells: (column, row). Fractions like (1.5, 0) are fine.
#let fc-diagram(..args, spacing: (1.3cm, 0.9cm)) = diagram(
  spacing: spacing,
  edge-stroke: 1.2pt + brand,
  mark-scale: 90%,
  node-corner-radius: 3pt,
  ..args,
)

#let fc-label(label, sub: none, color: brand) = {
  set align(center)
  text(size: 8.5pt, weight: "bold", fill: color)[#label]
  if sub != none {
    linebreak()
    text(size: 7pt, fill: color)[#sub]
  }
}

// A file/thing node: icon with a bold label under it.
//   kind:  src | run | gen | out | ext — sets the colour (see fc-kind-color)
//   icon:  a function taking `color:` (e.g. fc-icon-doc.with(tag: "R")),
//          or ready-made content
// The node's width is the icon's width (a long label may stick out
// sideways), so horizontal arrows touch the icon. Its height includes the
// label, so arrows leaving downwards start below the label. Arrows hit the
// side slightly below the icon's middle — that's expected.
#let fc-file(pos, label, icon: fc-icon-doc, kind: "src", sub: none, name: none,
             label-width: 3.2cm, ..node-args) = {
  let color = fc-kind-color.at(kind)
  let ic = if type(icon) == function { icon(color: color) } else { icon }
  let lab = box(width: label-width, fc-label(label, sub: sub, color: color))
  let body = context {
    let iw = measure(ic).width
    let lh = measure(lab).height
    stack(dir: ttb, spacing: 4pt,
      ic,
      box(width: iw, height: lh, place(top + center, lab)))
  }
  node(pos, body, name: name, shape: rect, stroke: none, inset: 0pt, outset: 4pt, ..node-args)
}

// A process/step node (e.g. "quarto render", "R/main.R"): rounded box.
#let fc-process(pos, label, sub: none, kind: "run", name: none, width: auto, height: auto, ..node-args) = {
  let color = fc-kind-color.at(kind)
  node(pos, fc-label(label, sub: sub, color: color), name: name,
    shape: rect, fill: stripe, stroke: 1.1pt + color, corner-radius: 3pt,
    inset: 8pt, width: width, height: height, ..node-args)
}

// A free-floating small note in the diagram (no box).
#let fc-note(pos, body, name: none, width: 3.5cm) = node(pos,
  box(width: width, align(center, text(size: 7.5pt, style: "italic", fill: brand)[#body])),
  name: name, shape: rect, stroke: none)

// A labelled frame around several nodes, e.g. a folder: enclose: (<a>, <b>).
#let fc-group(enclose, label, color: border) = node(
  enclose: enclose, stroke: (paint: color, thickness: 0.8pt, dash: "dashed"),
  fill: none, corner-radius: 5pt, inset: 10pt, snap: false,
  align(top + left, move(dy: -1.2em, box(fill: white, inset: (x: 3pt))[
    #text(size: 7.5pt, weight: "bold", fill: muted, raw(label))])),
)

// Normal flow arrow. Pass vertices/labels exactly as to fletcher's edge():
//   fc-flow(<a>, <b>)   fc-flow(<a>, (1,2), <b>, [label])   fc-flow(<a>, <b>, corner: right)
#let fc-flow(..args, color: brand) = edge(..args, marks: "-|>", stroke: 1.2pt + color,
  label-size: 7.5pt, label-fill: white)

// Manual step (someone does it by hand): dashed, labelled "manual"/"manuellt".
#let fc-manual(..args, label: auto, color: brand) = edge(..args, marks: "-|>",
  stroke: (paint: color, thickness: 1.2pt, dash: "dashed"),
  label: text(size: 7.5pt, style: "italic", fill: color)[#if label == auto { fc-t("manual") } else { label }],
  label-fill: white)

// "Reads but doesn't change" (e.g. a lookup table): thin dotted.
#let fc-reads(..args, color: muted) = edge(..args, marks: "-|>",
  stroke: (paint: color, thickness: 0.9pt, dash: "dotted"), label-size: 7.5pt, label-fill: white)

// ------------------------------------------------------------
// 4. Text parts
// ------------------------------------------------------------

// Numbered "do this" steps side by side. steps: array of (title, body).
#let fc-steps(..steps) = {
  let s = steps.pos()
  grid(
    columns: (1fr,) * s.len(),
    gutter: 0.8cm,
    ..s.enumerate().map(((i, st)) => [
      #text(fill: brand, weight: "bold")[#(i + 1). #st.at(0)]
      #v(0.15cm)
      #st.at(1)
    ]),
  )
}

// Small grey caption under a diagram mapping short labels to real files.
// entries: array of (term, explanation).
#let fc-legend(..entries) = align(center, block(width: 92%,
  text(size: 7.5pt, fill: gray.darken(25%))[
    #entries.pos().map(((k, v)) => [*#k* = #v]).join([ · ])
  ]))

// Badge for a kind, e.g. fc-badge("gen") -> [generated].
#let fc-badge(kind) = box(fill: fc-kind-color.at(kind), radius: 2pt,
  inset: (x: 3pt, y: 1.5pt), baseline: 1.5pt,
  text(fill: if kind == "old" { brand } else { white }, size: 6.5pt, weight: "bold", fc-t(kind)))

// Line-style key for the arrow types and kind colours actually used.
//   fc-key(kinds: ("src", "gen", "out"), manual: true, reads: false)
#let fc-key(kinds: ("src", "run", "gen", "out"), manual: true, reads: false) = {
  let sample(st) = box(width: 1cm, height: 0.6em, align(horizon, line(length: 100%, stroke: st)))
  let items = kinds.map(k => fc-badge(k))
  if manual { items.push([#sample((paint: brand, thickness: 1.2pt, dash: "dashed")) #text(size: 7.5pt, fc-t("manual"))]) }
  if reads { items.push([#sample((paint: muted, thickness: 0.9pt, dash: "dotted")) #text(size: 7.5pt, fc-t("reads"))]) }
  align(center, items.join(h(0.6cm)))
}

// Boxed explanation with a coloured left rule.
#let fc-box(label, body, color: brand, bg: stripe) = block(
  width: 100%, fill: bg, inset: (x: 10pt, y: 8pt), radius: 2pt,
  stroke: (left: 2.5pt + color), breakable: true,
)[
  #text(size: 8pt, weight: "bold", fill: color)[#label]
  #v(2pt, weak: true)
  #text(size: 9pt)[#body]
]

// Annotated folder tree. entries: array of dictionaries
//   (name: "data/raw/", depth: 1, kind: "src", note: [Original data, never modified])
// depth 0 = directly under the project root; kind and note are optional.
#let fc-tree(root, entries, name-width: auto) = {
  let n = entries.len()
  let d(i) = entries.at(i).at("depth", default: 0)
  let is-last(i) = {
    let res = true
    for j in range(i + 1, n) {
      if d(j) < d(i) { break }
      if d(j) == d(i) { res = false; break }
    }
    res
  }
  let open = ()
  let rows = ()
  for i in range(n) {
    let e = entries.at(i)
    let dep = d(i)
    let last = is-last(i)
    let prefix = range(dep).map(k => if open.at(k, default: false) { "│  " } else { "   " }).join("")
    if prefix == none { prefix = "" }
    prefix += if last { "└─ " } else { "├─ " }
    while open.len() <= dep { open.push(false) }
    open.at(dep) = not last
    let kind = e.at("kind", default: none)
    let ncol = if kind == none { brand } else if kind == "old" { muted } else { fc-kind-color.at(kind) }
    rows.push(text(size: 8.5pt, raw(prefix) + text(fill: ncol, weight: "bold", raw(e.name))))
    rows.push(if kind != none and kind != "dir" { fc-badge(kind) } else { [] })
    rows.push(text(size: 8.5pt, e.at("note", default: [])))
  }
  block(breakable: true, grid(
    columns: (name-width, auto, 1fr),
    column-gutter: 0.5cm,
    row-gutter: 0.42em,
    align: (left + horizon, left + horizon, left + horizon),
    grid.cell(colspan: 3, text(size: 9pt, weight: "bold", fill: brand, raw(root))),
    ..rows,
  ))
}

// ------------------------------------------------------------
// 5. Page setup — pure-Typst mode only (Quarto has its own template)
//    #show: fc-doc.with(title: [...], subtitle: [...], lang: "sv")
// ------------------------------------------------------------

#let fc-doc(title: none, subtitle: none, lang: "en", body) = {
  set document(title: title)
  set page(paper: "a4", margin: (x: 2.5cm, y: 2.5cm),
    numbering: "1", number-align: center)
  set text(font: "Libertinus Serif", size: 10pt, lang: lang)
  set par(justify: false)
  show heading: set text(fill: brand)
  show heading.where(level: 1): it => { v(0.4cm); it; v(0.2cm) }
  show raw.where(block: false): set text(size: 0.95em)
  set table(stroke: 0.5pt + border, inset: 6pt)
  show table.cell.where(y: 0): set text(weight: "bold", fill: brand)
  fc-lang.update(lang)
  if title != none {
    align(center)[
      #text(size: 20pt, weight: "bold", fill: brand)[#title]
      #if subtitle != none { v(0.1cm); text(size: 12pt, fill: muted)[#subtitle] }
    ]
    v(0.8cm)
  }
  body
}
