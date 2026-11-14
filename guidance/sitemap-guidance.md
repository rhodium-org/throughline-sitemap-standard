# Writing a sitemap graph

This is for the person or agent writing a graph that follows the sitemap standard:
one website, described so that its sitemap, a wireframe of every page and a
storyboard of every journey can be drawn from the graph alone.

`tl check` already enforces the declared shape: the registers, the required
attributes, which attributes go with which kind of element, and how many of each
link an item holds. This page covers what it cannot check. A design checker reads
the same graph and tests most of what is listed here, so meet it before you push.

Run `tl context` first: it lists every kind of item, its attributes and its links,
generated from the version of the standard the graph names. Make every change with
`tl` (`tl new`, `tl link`, `tl amend`), never by editing the YAML. An agent
proposes; a person ratifies.

## The order to write a graph in

1. **The site** (`SITE`, exactly one): its `name`, and its `url` if it has one.
2. **Roles** (`ROLE`): each kind of person the site serves. Write none if everyone
   sees the same site.
3. **Pages** (`PAGE`): a place a person can be. Write the home page first and link
   the site to it with `starts_at`. Give every page a `purpose`, and a `route`
   unless it cannot be linked to. A section of a single-page tool is a page with
   no route. A page is `part_of` its parent page; one with no parent sits under
   home. A page only some roles may reach is `open_to` those roles.
4. **Components** (`CMP`): a part of the site with one job, such as a bar, a
   panel or a dialog. Write a component once, however many pages show it. A
   component inside another `composes` it and takes an `order`.
5. **Appearances** (`APP`): one component shown on one page. Each is `part_of`
   its page, `shows` its component, and holds the `placement` (header, nav, main,
   aside, footer, overlay) and the `order` within it.
6. **Elements** (`ELM`): one thing a person reads or acts on, or a group of them.
   Each `composes` its component or its group and takes a `kind` and an `order`.
7. **Journeys** (`JRN`) and their **steps** (`STEP`): one path one role takes,
   from arriving to done. Another path is another journey. Write these last: a
   step is `on` a page and `acts_on` an element, so both must exist.

## Rules the check cannot enforce

### Pages

- **Every page can be reached from home** by following `navigates_to`, and has a
  way back to its parent or to home.
- **Titles and routes are unique.** No two pages share either.
- **`part_of` agrees with the routes.** A page at `/projects/{id}` is `part_of`
  the page at `/projects`, and no page is its own ancestor.
- **A link leads only where its reader may go.** If a page is `open_to` fewer
  roles than the page that links to it, make the link `open_to` those roles too.
- **The `nav` components appear on every page**, in the same order.

### Components and appearances

- **Every component is shown exactly one way:** by an appearance, or inside a
  component that is shown, never both.
- **An overlay is opened by something.** A component placed `overlay` is the
  target of some element's `opens`, and a component of kind `dialog` is always
  placed `overlay`.
- **A template is `like`d, not copied.** Where several components hold the same
  elements, write them once on one component and link the others to it with
  `like`; each then adds only what differs.

### Elements

- **Orders are unique among siblings**, and labels are unique within a component.
- **One level-1 heading a page**, and heading levels never skip.
- **At most one `emphasis: primary` action a page.**
- **Something that goes to another page is a link**, not a button whose `effect`
  is `navigates`.
- **A destructive action asks first.** Outside an overlay, it `opens` one that
  confirms.
- **`label` is the words on the control**, as the person reads them. Where the
  words differ for each copy of a repeated element, write the part that differs
  as `{part}`.
- **`shown_if` is words for the drawing**, read by nothing else. Use `shown_when`
  (ready, empty, loading, failed) for a state a tool should act on.
- **A list says what it holds when empty and holds its place while it loads:**
  give it a sibling with `shown_when: empty` and one with `shown_when: loading`.
  A list with a large `expected_count` has a field beside it to find an entry.
- **A choice has at least two `choices`.** A menu holds no more than seven
  options.

### Fields and the buttons that need them

- **`mandatory` means always answered.** A field answered only for some actions
  is `needed_by` each button that needs it, and not `mandatory`. Each target is a
  button whose `effect` is `submits`, in the same component as the field.
- **A button never waits unpressable.** Prefer `while_unanswered: explains` to
  `disabled`.
- **In a form, the fields only the person can answer come before the `prefilled`
  ones.**

### Journeys

- **Steps are numbered 1 to n** by `order`, with no gap.
- **Each step's element is on its page**, and each next page is the same page or
  the one the step's element leads to.
- **The journey's role may reach every page its steps are on.**

## The graph's own requirements

The standard cannot name a register it does not hold. To link pages and elements
to your requirements, declare a requirements register and the links to it as items
of your own, with `scope: this-graph`, as the standard's `conformance/full-site`
example does, and link with `relates`.

## What you never write

There are no coordinates, sizes, colours or breakpoints. Every position is an
`order` among siblings and an `arrangement` (column or row), so a drawing can
reflow at any width. If you find yourself wanting to say how something looks, it
does not belong in this graph.
