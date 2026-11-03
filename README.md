# Sitemap standard

A [throughline](https://github.com/rhodium-org/throughline) graph that states the
model a website is described in: its pages and the site's tree, the components on
each page and where they are placed, the elements a person reads or acts on, where
each leads, who may reach each page, and the journeys people take. It is a standard,
not a tool and not a site: it holds no website, and says nothing about how a drawing
looks.

A tool reading a graph that follows it can draw the sitemap, a wireframe of every page
and a storyboard of every journey, and a checker can test the design against its own
criteria, the same way every time.

## Following the standard

A site's graph names this repository as its schema source:

```toml
[[sources]]
namespace = "sitemap"
url = "https://github.com/rhodium-org/throughline-sitemap-standard"
ref = "v1.0.0"
schema = true
```

The graph is then checked against the declarations held here as items — registers,
types, value sets, attributes, links and link types — which follow the meta-standard
[rhodium-org/throughline-standard-standard](https://github.com/rhodium-org/throughline-standard-standard)
`v1.0.0` (namespace `meta`). Anything a site's graph holds that no declaration names is
an error. Needs throughline 4.6.2 or later.

## What a follower holds

| Register | Prefix | Holds | Attributes | Links (tl enforces the counts) |
|---|---|---|---|---|
| Site | SITE | exactly one: the website | `name`*, `url` (web address) | `starts_at` → exactly 1 PAGE (home) |
| Roles | ROLE | a kind of person the site serves | — | `derives_from` → the SITE |
| Pages | PAGE | a place a person can be | `route` (`/…`, `{param}` for any value; none = cannot be linked to), `purpose` | `derives_from` → the SITE; `part_of` → ≤ 1 parent PAGE (none = under home); `open_to` → the ROLEs that may reach it (none = anyone) |
| Components | CMP | a part of the site with one job: section, bar, strip, board, panel, dialog | `kind`*, `arrangement` (column, row), `label`, `order` (inside another component only) | `derives_from` → the SITE; `composes` → ≤ 1 parent CMP |
| Appearances | APP | one component shown on one page, and where | `placement`* (header, nav, main, aside, footer, overlay), `order`* | `part_of` → exactly 1 PAGE, every PAGE has ≥ 1; `shows` → exactly 1 CMP |
| Elements | ELM | one thing a person reads or acts on, or a group of them | `kind`* (21 values), `order`*, `label` (every control; `{part}` = what differs), `effect` (every button: navigates, opens, closes, submits, changes, copies, downloads, uploads), `url` (external links), `emphasis`, `level` (headings), `mandatory` (always answered), `arrangement` (groups), `repeats` | `composes` → exactly 1 CMP or ELM; `needed_by` → the buttons that need it answered (answerable controls only); `navigates_to` → ≤ 1 PAGE, required on a link and on a button that navigates; `opens` → ≤ 1 CMP, required on a button that opens |
| Journeys | JRN | one path one kind of person takes, arriving to done; another path is another journey | `goal`* | `derives_from` → the SITE; `taken_by` → exactly 1 ROLE |
| Steps | STEP | one thing done, on one page, in order | `order`*, `action`* (arrives, reads, presses, types, chooses, waits) | `part_of` → exactly 1 JRN, every JRN has ≥ 2; `on` → exactly 1 PAGE; `acts_on` → ≤ 1 ELM, exactly 1 when it presses, types or chooses |

`*` = required. All positions are relative — an order among siblings and an
arrangement — so a drawing reflows them at any width; there are no coordinates and no
breakpoints.

**A follower's own requirements.** The standard declares the link type `relates`
(LT-0010) but cannot name a register it does not hold. A follower declares its
requirements register and the links to it as its own items, `scope: this-graph`:
`conformance/full-site` does so (`registers/REG-0001` for REQ, `links/LINK-0001..0003`),
and `tl check` holds them like any other declaration.

## Consumer 1: the drawing tool (sitemap, wireframes, storyboards)

Every row is read from the graph alone; a follower that passes `tl check` is
guaranteed each one.

| It draws | It reads | Guaranteed by |
|---|---|---|
| The sitemap's tree | PAGE `part_of`, `route`; SITE `starts_at` as the root; parentless pages under it; `open_to` as a badge | LINK: one home, ≤ 1 parent |
| The flow arrows between pages | ELM `navigates_to` and `url`, up through `composes` to a component and its appearances | LINK: every link and navigating button leads somewhere; ATTR: every external link has an address |
| Each page's wireframe | APP `placement` as the region, `order` within it; CMP `kind` as the frame, `arrangement` as the direction, nested components by `composes` and `order` | LINK: every page has an appearance; every appearance shows one component |
| What sits in each part | ELM nesting, `order`, `arrangement`, `kind` as the widget, `label` as its words, `repeats` as three copies | ATTR: kind, order required; label on every control |
| Overlays | APP `placement: overlay`, reached by ELM `opens` | LINK: a button that opens opens one component |
| A journey's storyboard | STEP `order`, `on` as the frame, `acts_on` highlighted, `action` as the caption, JRN `taken_by` as the person | LINK: one page per step, one role per journey |

Output formats are the tool's business: SVG first, then Balsamiq (`.bmpr` is SQLite
holding JSON mockups) and Figma (through a small plugin; its REST API cannot write a
file).

## Consumer 2: the design checker

Checks that are shape are in the standard, so `tl check` makes them, each with a
conformance example. Checks that need a walk, a count or a threshold are the checker's.

| Check | Where | How |
|---|---|---|
| Every control has a label (WCAG 4.1.2, 3.3.2) | standard | ATTR-0011 — EX-0002 `no-label` |
| Every link leads to a page | standard | LINK-0006 — EX-0003 `link-nowhere` |
| Every external link has an address | standard | ATTR-0018 — EX-0004 `exit-nowhere` |
| One home | standard | LINK-0001 — EX-0005 `two-homes` |
| Every button says what it does | standard | ATTR-0023 — EX-0006 `no-effect` |
| A button that opens opens something | standard | LINK-0019 — EX-0007 `opens-nothing` |
| A button that navigates leads to a page | standard | LINK-0018 |
| Only an answerable control is needed by a button | standard | LINK-0023 — EX-0008 `needed-by-text` |
| A `needed_by` target is a button that submits, in the same component as the field | checker | target's kind, effect and parent |
| A required field is marked next to the buttons that need it | checker / drawing | `mandatory`, or `needed_by` |
| Every page reachable from home; no orphan pages | checker | walk over `navigates_to` |
| Click depth from home ≤ N | checker | shortest path |
| Every page has a way back to its parent or home | checker | walk |
| The `nav` components appear on every page (WCAG 3.2.3) | checker | compare appearances |
| A journey's role may reach every page its steps are on | checker | `taken_by` against each step's page's `open_to` |
| A page reachable by navigation from a page open to more roles than it is | checker | warn: a link a person cannot follow |
| A page with no route (cannot be linked to or bookmarked) | checker | PAGE without `route` |
| Page titles and routes unique (WCAG 2.4.2) | checker | count |
| One level-1 heading per page; levels never skip | checker | walk per page, by placement then order |
| At most one primary action per page | checker | count `emphasis: primary` |
| A destructive action outside an overlay opens one that asks first | checker | the parent's placement |
| A button whose effect is navigates should be a link | checker | `effect: navigates` |
| Every component is shown: by an appearance, or inside one that is; never both | checker | appearances against `composes` |
| Every overlay is opened by something; a `dialog` is placed `overlay` | checker | incoming `opens`; kind against placement |
| Orders unique among siblings; labels unique within a component | checker | count |
| A menu holds ≤ 7 options; a form ≤ N fields | checker | count |
| `part_of` has no cycle and agrees with route prefixes | checker | walk |
| Each journey's steps are 1..n; each step's element is on its page; each next page is this one or where this step's element leads | checker | walk |

## Conditionally mandatory fields (question 6)

`mandatory` says a field is always answered. A field answered only for some actions is
`needed_by` each button that needs it: table.iddn.uk's "Why not" is needed by Reject
and not by Ratify. tl refuses `needed_by` on anything but an answerable control
(LINK-0023, `conformance/needed-by-text`); the checker tests that each target is a
button that submits, in the same component. Rejected: leaving it to prose (nothing
could test it) and a form-level condition over other fields' values (neither tl nor a
deterministic drawing can evaluate one).

## What is here

| Folder | Items |
|---|---|
| `vision/` INT | 1 |
| `registers/` REG | 9: SITE, ROLE, PAGE, CMP, APP, ELM, JRN, STEP for followers; EX for this graph |
| `types/` TYPE | 7: Line, Text, Flag, Position, Heading level, Route, Web address |
| `enums/` ENUM | 7: Placement, Component kind, Element kind, Emphasis, Step action, Arrangement, Effect |
| `attributes/` ATTR | 23 |
| `link-types/` LT | 13: part_of, composes, verifies (ground); starts_at, navigates_to, opens, on, acts_on, shows, relates, open_to, taken_by, needed_by (do not) |
| `links/` LINK | 23 live |
| `examples/` EX | 8, one per conformance graph |
| `conformance/` | `full-site` (table.iddn.uk in part: 2 roles, 4 pages, 12 components, 18 appearances, 25 elements, 1 journey of 4 steps, 1 requirement) passes; `no-label`, `link-nowhere`, `exit-nowhere`, `two-homes`, `no-effect`, `opens-nothing`, `needed-by-text` each break one declaration and fail for that one reason. `./conformance/check.sh` runs them. |

Needs throughline 4.6.2 or later.
