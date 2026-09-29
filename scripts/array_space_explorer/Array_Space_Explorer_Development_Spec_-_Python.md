### 1. General UI & Theme (`customtkinter`)
- **Window & Layout:**
    - Auto-restores and persists window geometry (`width x height + X offset + Y offset`) to/from YAML configurations.
    - Tracks and updates window coordinates dynamically via `<Configure>` bindings.
- **Header Controls:**
    - **Theme Toggle Button:** Switches between Light and Dark modes (`"Dark Mode"` / `"Light Mode"`).
    - **Config Buttons:** `"Load YAML Config"` and `"Save YAML Config"`.
- **Constraints Label:**
    `"Constraints: No double quotes in strings. Apostrophes/single quotes allowed. Empty tokens between commas are stripped. 2 spaces per Cartesian dimension level. Roles textarea: one role per line, line N applies to values line N; blank role lines are allowed and yield role-less dimensions. Skip chance 0.0-1.0, Max picks 1..N, and Lock are per-dimension."`
- **Input Areas (side-by-side):**
    - **Values textarea (left, wide):** Multi-line, no element or line count max, text wrapping disabled (`wrap="none"`) with an attached horizontal scrollbar.
    - **Roles textarea (right, ~220px wide):** Multi-line, one role per line, label above it ("Roles (optional, 1 per line)"). Role lines are optional. A blank role line at index N applies `null` to the values line at index N. Roles are freeform strings; there is no vocabulary, canonical list, default, or inference from them.
    - Both textareas maintain their own content and scroll independently.
- **Action Buttons:**
    - `"Display Array Space!"`
    - `"Explore Random Coordinate!"`
- **Output Row:**
    - Read-only output entry (synthesized string).
    - `"Copy to Clipboard"` button.
    - `"Re-roll skips & picks"` button — resamples every dimension's skip roll and every unlocked dimension's multi-pick subset, without changing manual spinbox indices.

### 2. Pre-Processing & Hierarchy Engine
Triggered on pressing `"Display Array Space!"`, `"Explore Random Coordinate!"`, or loading a YAML configuration:
1. **Tab Expansion & Whitespace Normalization:**
    - Converts all tab characters (`\t`) to 2 spaces (`"  "`).
    - Calculates indentation depth where every 2 leading spaces count as +1 Cartesian dimension level.
    - Re-formats and trims all leading, trailing, and internal item-level whitespace cleanly.
2. **Line Cleaning & Tokenization:**
    - Processes all non-empty lines in the Values textarea. Blank lines are skipped entirely and their corresponding role lines are also skipped (strict line-index alignment is preserved by skipping both).
    - Tokens are split on commas, whitespace-stripped, and empty tokens between commas are silently dropped (e.g., `a,,b,` → `['a', 'b']`). Empty tokens are no longer a skip mechanism.
    - No token may contain a double-quote character. Single quotes and apostrophes are allowed and are stripped when they wrap a token.
3. **Role Assignment:**
    - The Roles textarea is a shadow of the Values textarea. Values line at index N pairs with Roles line at index N.
    - A non-blank role line sets the dimension's `role` to that string (trimmed).
    - A blank role line, or a Roles textarea shorter than the Values textarea, leaves that dimension's `role` as `null`.
    - Roles have no semantic effect on ordering, separators, type promotion, or YAML structure. They are inert metadata.
    - Roles are freeform strings. The tool does not validate, canonicalize or infer them.
4. **Type Promotion (Per Line):**
    - Evaluates tokens as `int` → `float` → `string` if possible:
    - If any token is `string`, the entire line is promoted to `string`.
    - Else if any token is `float`, the line is promoted to `float`.
    - Otherwise, tokens remain `int`.
5. **Group & Cartesian Hierarchy:**
    - The first line defines base level 0.
    - Any line with **greater indentation depth** than its predecessor adds a Cartesian product dimension to the active group.
    - Any line with **equal or lesser indentation depth** resets the hierarchy and starts a new independent top-level Array Group.
    - Dimension depth is uncapped; as many lines as the user enters for new dimensions in a group are created.

### 3. Inspection & Prompt Synthesis Engine
- **Live Combinatorial Indicator:** Per group, displays two numbers:
    - `Raw: <prod(len(values))>`
    - `Expected non-skipped: ~<prod(len(values)) x prod(1 - skip_chance)>`
    - Updated live as `skip_chance` values change.
- **Array Space Inspector (Preview & Controls):**
    - **Element Preview:** Displays up to the first 3 values of each array/dimension (e.g., `Preview: ['a', 'b', 'c']...`) in a non-selectable info label right above the spinbox control, for reference in identifying the data to modify more easily.
    - **Role Display:** The dimension's label is `[<role or (none)>] Dim [n] (0 .. max) -> Preview: [...]`. No color coding.
    - **Spinbox Controls:** Auto-bounded numerical index entry with `-` and `+` step buttons.
    - Silently clamps typed inputs outside valid index ranges (`< 0` becomes `0`; `> max` becomes `max`).
    - **Skip Chance Entry:** Per-dimension `Skip:` entry, float in `[0.0, 1.0]`, clamped on focus-out. On each synthesis pass, a dimension with `skip_chance > 0` is omitted from the output with that probability. Skips are cached per synthesis pass and are resampled only by `"Explore Random Coordinate!"` and `"Re-roll skips & picks"`.
    - **Max Picks Slider:** Per-dimension `Max picks:` slider, integer in `[1, len(values)]`, default `1`. When `max_picks > 1`, the dimension contributes a random subset of size `k` in `[1, max_picks]`, ordered as the values appear in the axis. When `max_picks > 1`, the index spinbox and its `-`/`+` buttons are disabled (the manual index is ignored; the random subset is authoritative).
    - **Selection Lock Checkbox:** Per-dimension `Lock` tickbox, positioned between the Max picks slider and the Display no comma checkbox.
        - When ticked, the dimension's currently selected value (when `max_picks == 1`) or cached multi-pick subset (when `max_picks > 1`) is not changed by `"Explore Random Coordinate!"` or `"Re-roll skips & picks"`.
        - The skip roll is still resampled when locked; only the pick is frozen. To always include a locked layer, set its `skip_chance` to `0.0`.
        - Manual spinbox edits remain allowed while locked when `max_picks == 1`. When `max_picks > 1` the spinbox is disabled by the existing max-picks behavior regardless of lock.
        - `selection_lock` does not affect `no_comma`, `skip_chance`, `max_picks`, or `role`.
        - The tool never injects values into any dimension. A locked dimension simply preserves whatever was already in its `values` list and its current index/subset. If a value exists in a locked dimension's `values` list that "should not be randomly selectable", it is present in the config but unreachable by `"Explore Random Coordinate!"`; it can still be selected manually by typing its index.
    - **"No Comma" Checkbox:** Positioned to the right of the Lock checkbox in every dimension row. When ticked, values produced by that line are separated from the next active element by a single space instead of `", "`.
- **Prompt Synthesis & Clipboard:**
    - **Output Entry:** Single continuous string combining active selected values from **every array group**, formatted dynamically based on each line's "No comma" toggle setting. Dimensions whose skip roll fired are omitted entirely (no separator contributed).
    - **"Copy to Clipboard" Button:** Positioned directly to the right of the synthesized output box to immediately copy the string.
    - **"Re-roll skips & picks" Button:** Resamples all skip rolls and all multi-pick subsets across all unlocked dimensions. Does not change manual indices. Locked dimensions keep their pick subset (but their skip roll is resampled).
- **"Explore Random Coordinate!" Action:**
    - Generates a valid random index for every unlocked spinbox across all groups.
    - Resamples all skip rolls and all unlocked multi-pick subsets.
    - Updates all spinboxes visually, updates preview fields, and updates the output string.

### 4. Updated YAML Configuration Schema
YAML
```
version: "2.0"
settings:
  appearance_mode: "Dark"
  window_geometry: "1200x900+120+80"
data:
  raw_text: |
    Geometric Abstraction, Organic Constructivism
      Impasto Paletting, Drybrush Layering
        Guilloché Spirals, Voronoi Tessellations
  raw_roles: |
    movement
    technique

  groups:
    - group_index: 0
      dimensions:
        - role: "movement"
          depth: 0
          type: "string"
          no_comma: false
          selection_lock: false
          skip_chance: 0.0
          max_picks: 1
          values: ["Geometric Abstraction", "Organic Constructivism"]
        - role: "technique"
          depth: 1
          type: "string"
          no_comma: false
          selection_lock: false
          skip_chance: 0.25
          max_picks: 2
          values: ["Impasto Paletting", "Drybrush Layering"]
        - role: null
          depth: 2
          type: "string"
          no_comma: true
          selection_lock: false
          skip_chance: 0.0
          max_picks: 1
          values: ["Guilloché Spirals", "Voronoi Tessellations"]
```
**Schema Notes:**
- `role` is explicitly `null` when the user left that line's role blank.
- `raw_roles` mirrors `raw_text` line-for-line, including blank lines, so round-trip preserves alignment.
- `selection_lock` is written to YAML per dimension. On load, a missing `selection_lock` key defaults to `false`, so YAML files that do not define it load cleanly.
- `skip_chance` is a float in `[0.0, 1.0]`.
- `max_picks` is an integer in `[1, len(values)]`.
- No `constraints`, `sampling`, `weight`, or `notes` keys exist. The tool emits exactly the keys shown and reads exactly the keys shown.
- No backward compatibility. The tool does not read v1 files and does not migrate.