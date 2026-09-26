### General UI & Theme (`customtkinter`)
- **Window & Layout:**
    - Auto-restores and persists window geometry (`width x height + X offset + Y offset`) to/from YAML configurations.
    - Tracks and updates window coordinates dynamically via `<Configure>` bindings.
- **Header Controls:**
    - **Theme Toggle Button:** Switches between Light and Dark modes (`"Dark Mode"` / `"Light Mode"`).
    - **Config Buttons:** `"Load YAML Config"` and `"Save YAML Config"`.
- **Constraints Label:**
    `"Constraints: No double quotes in strings. Apostrophes/single quotes allowed. Trailing commas & empty tokens ignored. 2 spaces per Cartesian dimension level."`
- **Input Area:**
    - Multi-line text area with no element or line count max.
    - **Horizontal Scrollbar:** Text wrapping disabled (`wrap="none"`) with an attached horizontal scrollbar.
- **Action Buttons:**
    - `"Display Array Space!"`
    - `"Explore Random Coordinate!"`
### 2. Pre-Processing & Hierarchy Engine
Triggered on pressing `"Display Array Space!"`, `"Explore Random Coordinate!"`, or loading a YAML configuration:
1. **Tab Expansion & Whitespace Normalization:**
    - Converts all tab characters (`\t`) to 2 spaces (`"  "`).
    - Calculates indentation depth where every 2 leading spaces count as +1 Cartesian dimension level.
    - Re-formats and trims all leading, trailing, and internal item-level whitespace cleanly.
2. **Line Cleaning & Tokenization:**
    - Processes all non-empty lines in the text area.
    - Cleans tokens by stripping spaces and dropping empty elements (e.g., `a,,b,` $\rightarrow$ `['a', 'b']`).
    - Empty tokens may be expressed as a comma (,) and are parsed to empty strings "", to allow for a random chance to omit elements on a line. More commas / empty strings means higher chance of nothing from that array.
3. **Type Promotion (Per Line):**
    - Evaluates tokens as `int` $\rightarrow$ `float` $\rightarrow$ `string` if possible:
    - If any token is `string`, the entire line is promoted to `string`.
    - Else if any token is `float`, the line is promoted to `float`.
    - Otherwise, tokens remain `int`.
4. **Group & Cartesian Hierarchy:**
    - The first line defines base level 0.
    - Any line with **greater indentation depth** than its predecessor adds a Cartesian product dimension to the active group.
    - Any line with **equal or lesser indentation depth** resets the hierarchy and starts a new independent top-level Array Group.
    - Dimension depth is uncapped; as many lines as the user enters for new dimensions in a group are created.
### 3. Inspection & Prompt Synthesis Engine
- **Live Combinatorial Indicator:** Displays total combination counts per group (e.g., `Group 1: 3 × 3 × 2 = 18 combinations`).
- **Array Space Inspector (Preview & Controls):**
    - **Element Preview:** Displays up to the first 3 values of each array/dimension (e.g., `Preview: ['a', 'b', 'c']...`) in a non-selectable info label right above the spinbox control, for reference in identifying the data to modify more easily.
    - **Spinbox Controls:** Auto-bounded numerical index entry with `-` and `+` step buttons.
    - Silently clamps typed inputs outside valid index ranges (`< 0` becomes `0`; `> max` becomes `max`).
    - **"No Comma" Checkbox:** Positioned to the far right of every dimension row in the inspector. When ticked, the value produced by that line is followed by a single space instead of a comma and space (`,` ) in the synthesized prompt string.
- **Prompt Synthesis & Clipboard:**
	- **Output Entry:** Single continuous string combining active selected values from **every array group** (including possibility of dispalying nothing for an empty ("" / ,) element, formatted dynamically based on each line's "No comma" toggle setting.
	- **"Copy to Clipboard" Button:** Positioned directly to the right of the synthesized output box to immediately copy the string.
- **"Explore Random Coordinate!" Action:**
    - Generates a valid random coordinate for every spinbox across all groups.
    - Updates all spinboxes visually, updates preview fields, and updates the output string.

### 4. Updated YAML Configuration Schema
YAML
```
version: "1.0"
settings:
  appearance_mode: "Dark"
  window_geometry: "900x850+120+80"
data:
  raw_text: |
    a, b, c
      1, 2, 3
    x, y, z
  groups:
    - group_index: 0
      dimensions:
        - depth: 0
          type: "string"
          values: ["a", "b", "c"]
        - depth: 1
          type: "int"
          no_comma: true
          values: [1, 2, 3]
    - group_index: 1
      dimensions:
        - depth: 0
          type: "string"
          no_comma: false
          values: ["x", "y", "z"]
```