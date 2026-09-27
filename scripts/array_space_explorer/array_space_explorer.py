# DESCRIPTION
# Array Space Explorer & Prompt Generator  (scriptVersion 2.0)
# A CustomTkinter GUI tool for parsing line-separated, comma-delimited multidimensional
# arrays with indentation-based Cartesian hierarchy. Features interactive coordinate
# exploration, per-line "No comma" formatting controls, per-line role tagging via a
# parallel Roles textarea, per-line skip chance, per-line max-picks, random coordinate
# generation, live prompt synthesis with direct clipboard copy support, window geometry
# tracking, and YAML config load/save capabilities.

# DEPENDENCIES
# - python >= 3.8
# - customtkinter
# - pyyaml

# USAGE
# 1. Install dependencies:
#    pip install customtkinter pyyaml
# 2. Run the application:
#    python array_space_explorer.py
# 3. Enter arrays line by line in the Values textarea. Use 2 spaces per indentation
#    level to create child dimensions (Cartesian products). Optionally fill the parallel
#    Roles textarea (one role per line, blank lines = role-less). Click
#    "Display Array Space!" or "Explore Random Coordinate!". Optionally save the config
#    as YAML with the provided button. OR load a previously saved YAML config.

# CODE
import math
import random
import tkinter as tk
from tkinter import filedialog
import customtkinter as ctk
import yaml

scriptVersion = "2.0"

# Initialize CustomTkinter appearance defaults
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")


class ArraySpaceExplorer(ctk.CTk):

    def __init__(self):
        super().__init__()

        self.title(f"Array Space Explorer & Prompt Generator  (v{scriptVersion})")
        self.geometry("1200x900")

        self.parsed_groups = []  # Holds structured parsed array data
        self.spinboxes = []      # Holds CTk Entry/Spinbox & Checkbox widgets for indices

        # Bind window movement & resizing to track geometry for YAML saving
        self.bind("<Configure>", self._on_window_configure)

        self._build_ui()

    def _on_window_configure(self, event):
        if event.widget == self:
            self.current_geometry = self.geometry()

    def _build_ui(self):
        # Top Header & Controls
        self.top_frame = ctk.CTkFrame(self)
        self.top_frame.pack(fill="x", padx=15, pady=(15, 5))

        self.theme_btn = ctk.CTkButton(
            self.top_frame, text="Dark Mode", command=self.toggle_theme
        )
        self.theme_btn.pack(side="left", padx=10, pady=10)

        self.load_yaml_btn = ctk.CTkButton(
            self.top_frame, text="Load YAML Config", command=self.load_yaml
        )
        self.load_yaml_btn.pack(side="right", padx=(5, 10), pady=10)

        self.save_yaml_btn = ctk.CTkButton(
            self.top_frame, text="Save YAML Config", command=self.save_yaml
        )
        self.save_yaml_btn.pack(side="right", padx=5, pady=10)

        # Constraints Label
        self.constraint_label = ctk.CTkLabel(
            self,
            text=(
                "Constraints: No double quotes in strings. Apostrophes/single quotes allowed. "
                "Empty tokens between commas are stripped. 2 spaces per Cartesian dimension level. "
                "Roles textarea: one role per line, line N applies to values line N; blank role lines "
                "are allowed and yield role-less dimensions. Skip chance 0.0-1.0 and Max picks 1..N "
                "are per-dimension."
            ),
            font=("Arial", 12, "italic"),
            text_color="gray",
            justify="left",
        )
        self.constraint_label.pack(anchor="w", padx=20, pady=(5, 5))

        # Side-by-side Values + Roles text areas
        self.text_frame = ctk.CTkFrame(self)
        self.text_frame.pack(fill="x", padx=15, pady=5)

        # Inner container so we can put values on the left and roles on the right
        self.text_inner = ctk.CTkFrame(self.text_frame, fg_color="transparent")
        self.text_inner.pack(fill="x", expand=True, padx=5, pady=5)

        # ---- Values column ----
        self.values_col = ctk.CTkFrame(self.text_inner, fg_color="transparent")
        self.values_col.pack(side="left", fill="both", expand=True)

        self.values_label = ctk.CTkLabel(
            self.values_col,
            text="Values  (indent with 2 spaces per Cartesian dimension)",
            font=("Arial", 12, "bold"),
        )
        self.values_label.pack(anchor="w", padx=2, pady=(0, 2))

        self.text_area = ctk.CTkTextbox(
            self.values_col, height=180, font=("Consolas", 14), wrap="none"
        )
        self.text_area.pack(fill="x", expand=True, padx=0, pady=(0, 0))

        self.h_scrollbar = ctk.CTkScrollbar(
            self.values_col,
            orientation="horizontal",
            command=self.text_area.xview,
        )
        self.h_scrollbar.pack(fill="x", padx=0, pady=(2, 0))
        self.text_area.configure(xscrollcommand=self.h_scrollbar.set)

        # Default starter content
        self.text_area.insert(
            "1.0", "Geometric Abstraction, Organic Constructivism, Folk Decorative Art\n"
                   "  Impasto Paletting, Drybrush Layering, Sgraffito Carving\n"
                   "    Guilloché Spirals, Isometric Facets, Voronoi Tessellations"
        )

        # ---- Roles column (right, narrower) ----
        self.roles_col = ctk.CTkFrame(self.text_inner, fg_color="transparent", width=220)
        self.roles_col.pack(side="right", fill="y", expand=False, padx=(10, 0))
        self.roles_col.pack_propagate(False)

        self.roles_label = ctk.CTkLabel(
            self.roles_col,
            text="Roles  (optional, 1 per line)",
            font=("Arial", 12, "bold"),
        )
        self.roles_label.pack(anchor="w", padx=2, pady=(0, 2))

        self.role_text_area = ctk.CTkTextbox(
            self.roles_col, height=180, font=("Consolas", 14), wrap="none"
        )
        self.role_text_area.pack(fill="both", expand=True, padx=0, pady=(0, 0))

        self.role_text_area.insert(
            "1.0", "movement\n"
                   "technique\n"
                   "\n"
        )

        # Main Action Buttons
        self.btn_frame = ctk.CTkFrame(self)
        self.btn_frame.pack(fill="x", padx=15, pady=10)

        self.display_btn = ctk.CTkButton(
            self.btn_frame,
            text="Display Array Space!",
            font=("Arial", 14, "bold"),
            command=self.process_and_display,
        )
        self.display_btn.pack(
            side="left", expand=True, fill="x", padx=10, pady=10
        )

        self.random_btn = ctk.CTkButton(
            self.btn_frame,
            text="Explore Random Coordinate!",
            font=("Arial", 14, "bold"),
            fg_color="#2b8a3e",
            hover_color="#217031",
            command=self.roll_random_coordinate,
        )
        self.random_btn.pack(
            side="right", expand=True, fill="x", padx=10, pady=10
        )

        # Combinatorial Size Indicator
        self.info_label = ctk.CTkLabel(
            self,
            text="Array Space Size: Not Processed Yet",
            font=("Arial", 13, "bold"),
            justify="left",
        )
        self.info_label.pack(anchor="w", padx=20, pady=5)

        # Inspection Area (Scrollable Frame)
        self.inspector_frame = ctk.CTkScrollableFrame(
            self, height=260, label_text="Array Space Inspector"
        )
        self.inspector_frame.pack(fill="both", expand=True, padx=15, pady=10)

        # Output Prompt Synthesis Box & Clipboard Button
        self.output_frame = ctk.CTkFrame(self)
        self.output_frame.pack(fill="x", padx=15, pady=(5, 15))

        self.output_title = ctk.CTkLabel(
            self.output_frame,
            text="Synthesized Output String:",
            font=("Arial", 12, "bold"),
        )
        self.output_title.pack(anchor="w", padx=10, pady=(5, 0))

        self.output_control_row = ctk.CTkFrame(
            self.output_frame, fg_color="transparent"
        )
        self.output_control_row.pack(fill="x", padx=10, pady=(0, 10))

        self.output_entry = ctk.CTkEntry(
            self.output_control_row, font=("Consolas", 14), state="readonly"
        )
        self.output_entry.pack(
            side="left", fill="x", expand=True, padx=(0, 10)
        )

        self.reroll_btn = ctk.CTkButton(
            self.output_control_row,
            text="Re-roll skips & picks",
            width=170,
            fg_color="#8a5a2b",
            hover_color="#6e4720",
            command=self.resample_skips_and_picks,
        )
        self.reroll_btn.pack(side="right", padx=(5, 5))

        self.copy_btn = ctk.CTkButton(
            self.output_control_row,
            text="Copy to Clipboard",
            width=140,
            command=self.copy_to_clipboard,
        )
        self.copy_btn.pack(side="right", padx=(5, 0))

    def toggle_theme(self):
        if self.theme_btn.cget("text") == "Dark Mode":
            ctk.set_appearance_mode("Light")
            self.theme_btn.configure(text="Light Mode")
        else:
            ctk.set_appearance_mode("Dark")
            self.theme_btn.configure(text="Dark Mode")

    def copy_to_clipboard(self):
        text = self.output_entry.get()
        if text:
            self.clipboard_clear()
            self.clipboard_append(text)
            self.update()
            old_text = self.copy_btn.cget("text")
            self.copy_btn.configure(text="Copied!")
            self.after(1500, lambda: self.copy_btn.configure(text=old_text))

    # ------------------------------------------------------------------
    # Parsing
    # ------------------------------------------------------------------

    def _parse_token(self, token):
        token = token.strip()
        if not token:
            return None  # explicit skip marker; caller strips Nones

        # Try Integer
        try:
            return int(token)
        except ValueError:
            pass

        # Try Float
        try:
            return float(token)
        except ValueError:
            pass

        # String handling (strip surrounding quotes if present)
        if (token.startswith("'") and token.endswith("'")) or (
            token.startswith('"') and token.endswith('"')
        ):
            token = token[1:-1]
        return token

    def parse_input_text(self):
        raw_text = self.text_area.get("1.0", "end-1c")
        raw_roles_text = self.role_text_area.get("1.0", "end-1c")

        # --- Values side (existing pipeline, minus "" skip semantic) ---
        raw_lines = raw_text.splitlines()
        role_lines = raw_roles_text.splitlines()

        normalized_lines = []
        prev_depth = 0

        for idx, line in enumerate(raw_lines):
            expanded = line.replace("\t", "  ")
            stripped = expanded.lstrip(" ")

            if not stripped:
                # Blank line: skipped. Role line at same index is also skipped.
                continue

            indent_count = len(expanded) - len(stripped)
            raw_depth = indent_count // 2

            max_depth = prev_depth + 1
            depth = min(raw_depth, max_depth)
            prev_depth = depth

            # Parse tokens, dropping empty ones (no more "" skip)
            raw_tokens = [self._parse_token(tok) for tok in stripped.split(",")]
            raw_tokens = [t for t in raw_tokens if t is not None]

            # Role: strict line-index alignment. Blank role -> None.
            role = None
            if idx < len(role_lines):
                role_candidate = role_lines[idx].strip()
                if role_candidate:
                    role = role_candidate

            normalized_lines.append(
                {
                    "depth": depth,
                    "raw_tokens": raw_tokens,
                    "stripped": stripped,
                    "role": role,
                    "source_line_index": idx,
                }
            )

        # Re-format values textarea with standardized spacing
        reformatted_text_lines = []
        for item in normalized_lines:
            indent_str = "  " * item["depth"]
            tokens_str = ", ".join(str(t) for t in item["raw_tokens"])
            reformatted_text_lines.append(f"{indent_str}{tokens_str}")

        self.text_area.delete("1.0", "end")
        self.text_area.insert("1.0", "\n".join(reformatted_text_lines))

        # Build Hierarchy & Type Promotion
        groups = []
        current_group = []

        for item in normalized_lines:
            raw_tokens = item["raw_tokens"]
            depth = item["depth"]

            has_str = any(isinstance(t, str) for t in raw_tokens)
            has_float = any(isinstance(t, float) for t in raw_tokens)

            if has_str:
                typed_tokens = [str(t) for t in raw_tokens]
                line_type = "string"
            elif has_float:
                typed_tokens = [float(t) for t in raw_tokens]
                line_type = "float"
            else:
                typed_tokens = [int(t) for t in raw_tokens]
                line_type = "int"

            dim_info = {
                "depth": depth,
                "type": line_type,
                "values": typed_tokens,
                "role": item["role"],
            }

            if not current_group:
                current_group.append(dim_info)
            else:
                p_depth = current_group[-1]["depth"]
                if depth > p_depth:
                    current_group.append(dim_info)
                else:
                    groups.append(current_group)
                    current_group = [dim_info]

        if current_group:
            groups.append(current_group)

        self.parsed_groups = groups
        return groups

    # ------------------------------------------------------------------
    # Display
    # ------------------------------------------------------------------

    def process_and_display(self):
        self.parse_input_text()
        self._rebuild_inspector_ui()
        self._resample_all_skips_and_picks()
        self.update_synthesized_output()

    def _rebuild_inspector_ui(self, saved_state=None):
        """saved_state: optional list-of-lists of dicts with keys
        {index, no_comma, skip_chance, max_picks} matching parsed_groups."""
        for widget in self.inspector_frame.winfo_children():
            widget.destroy()

        self.spinboxes = []
        total_raw_sizes = []
        total_expected_sizes = []
        pending_state = []

        if not self.parsed_groups:
            self.info_label.configure(
                text="Array Space Size: 0 (No valid data)"
            )
            return

        for g_idx, group in enumerate(self.parsed_groups):
            raw_size = math.prod(len(dim["values"]) for dim in group)

            # Expected non-skipped size assumes skip_chance known yet; compute after
            # controls are built if saved_state not supplied. Placeholder here.
            group_container = ctk.CTkFrame(self.inspector_frame)
            group_container.pack(fill="x", padx=5, pady=5)

            lbl_title = ctk.CTkLabel(
                group_container,
                text=f"Group {g_idx + 1} (Raw size: {raw_size})",
                font=("Arial", 12, "bold"),
            )
            lbl_title.pack(anchor="w", padx=10, pady=(5, 2))

            group_spinboxes = []

            for d_idx, dim in enumerate(group):
                row_frame = ctk.CTkFrame(
                    group_container, fg_color="transparent"
                )
                row_frame.pack(fill="x", padx=10, pady=4)

                indent_prefix = "  " * dim["depth"]
                role_display = dim.get("role") if dim.get("role") else "(none)"

                first_three = dim["values"][:3]
                preview_str = ", ".join(str(v) for v in first_three)
                if len(dim["values"]) > 3:
                    preview_str += ", ..."

                lbl_dim = ctk.CTkLabel(
                    row_frame,
                    text=(
                        f"{indent_prefix}[{role_display}] Dim [{d_idx}] "
                        f"(0 .. {len(dim['values']) - 1}) -> Preview: [{preview_str}]"
                    ),
                    anchor="w",
                )
                lbl_dim.pack(side="left", fill="x", expand=True)

                # Spinbox
                btn_down = ctk.CTkButton(
                    row_frame,
                    text="-",
                    width=30,
                    command=lambda g=g_idx, d=d_idx: self._adjust_index(g, d, -1),
                )
                btn_down.pack(side="left", padx=2)

                entry_var = tk.StringVar(value="0")
                entry_var.trace_add(
                    "write", lambda *args: self.update_synthesized_output()
                )

                entry = ctk.CTkEntry(
                    row_frame,
                    textvariable=entry_var,
                    width=50,
                    justify="center",
                )
                entry.pack(side="left", padx=2)

                btn_up = ctk.CTkButton(
                    row_frame,
                    text="+",
                    width=30,
                    command=lambda g=g_idx, d=d_idx: self._adjust_index(g, d, 1),
                )
                btn_up.pack(side="left", padx=2)

                # Skip chance entry
                skip_var = tk.StringVar(value="0.00")
                skip_label = ctk.CTkLabel(row_frame, text="Skip:")
                skip_label.pack(side="left", padx=(10, 2))
                skip_entry = ctk.CTkEntry(
                    row_frame, textvariable=skip_var, width=52, justify="center"
                )
                skip_entry.pack(side="left", padx=2)
                skip_var.trace_add(
                    "write", lambda *args: self.update_synthesized_output()
                )
                skip_entry.bind(
                    "<FocusOut>",
                    lambda e, v=skip_var: self._clamp_skip(v),
                )

                # Max picks slider
                maxpicks_var = tk.IntVar(value=1)
                mp_label = ctk.CTkLabel(row_frame, text="Max picks:")
                mp_label.pack(side="left", padx=(10, 2))
                mp_value_lbl = ctk.CTkLabel(row_frame, text="1", width=28)
                mp_value_lbl.pack(side="left", padx=(0, 2))

                def _on_mp_change(value, var=maxpicks_var, lbl=mp_value_lbl,
                                  ent=entry, bd=btn_down, bu=btn_up,
                                  _d=d_idx, _g=g_idx):
                    v = int(round(value))
                    var.set(v)
                    lbl.configure(text=str(v))
                    # Disable spinbox controls when max_picks > 1
                    if v > 1:
                        ent.configure(state="disabled")
                        bd.configure(state="disabled")
                        bu.configure(state="disabled")
                    else:
                        ent.configure(state="normal")
                        bd.configure(state="normal")
                        bu.configure(state="normal")
                    self.update_synthesized_output()

                mp_slider = ctk.CTkSlider(
                    row_frame,
                    from_=1,
                    to=max(1, len(dim["values"])),
                    number_of_steps=max(1, len(dim["values"]) - 1),
                    command=_on_mp_change,
                    width=140,
                )
                mp_slider.set(1)
                mp_slider.pack(side="left", padx=2)

                # "Display no comma" checkbox
                no_comma_var = tk.BooleanVar(value=False)
                no_comma_chk = ctk.CTkCheckBox(
                    row_frame,
                    text="Display no comma",
                    variable=no_comma_var,
                    command=self.update_synthesized_output,
                )
                no_comma_chk.pack(side="left", padx=(10, 5))

                group_spinboxes.append(
                    {
                        "var": entry_var,
                        "entry": entry,
                        "btn_up": btn_up,
                        "btn_down": btn_down,
                        "no_comma_var": no_comma_var,
                        "skip_var": skip_var,
                        "maxpicks_var": maxpicks_var,
                        "maxpicks_slider": mp_slider,
                        "maxpicks_label": mp_value_lbl,
                        "max": len(dim["values"]) - 1,
                        # runtime sample cache (repopulated on resample)
                        "skip_roll": False,
                        "pick_indices": [0],
                    }
                )

                # Defer restoration until every group has been added to self.spinboxes.
                if saved_state and g_idx < len(saved_state) and d_idx < len(saved_state[g_idx]):
                    pending_state.append((g_idx, d_idx, saved_state[g_idx][d_idx]))

            self.spinboxes.append(group_spinboxes)

        # Restore saved control state only after self.spinboxes is complete.
        # The StringVar/slider callbacks call update_synthesized_output(), which
        # expects every parsed dimension to already have a corresponding spinbox.
        for g_idx, d_idx, s in pending_state:
            sb = self.spinboxes[g_idx][d_idx]
            if "index" in s and s["index"] is not None:
                sb["var"].set(str(s["index"]))
            if "no_comma" in s:
                sb["no_comma_var"].set(bool(s["no_comma"]))
            if "skip_chance" in s:
                sb["skip_var"].set(f"{float(s['skip_chance']):.2f}")
            if "max_picks" in s:
                v = int(s["max_picks"])
                sb["maxpicks_var"].set(v)
                sb["maxpicks_slider"].set(v)
                sb["maxpicks_label"].configure(text=str(v))
                state = "disabled" if v > 1 else "normal"
                sb["entry"].configure(state=state)
                sb["btn_down"].configure(state=state)
                sb["btn_up"].configure(state=state)

        self._update_info_label()

    def _clamp_skip(self, var):
        try:
            v = float(var.get())
        except ValueError:
            v = 0.0
        v = max(0.0, min(1.0, v))
        var.set(f"{v:.2f}")
        self.update_synthesized_output()

    def _update_info_label(self):
        parts = []
        for g_idx, group in enumerate(self.parsed_groups):
            raw_size = math.prod(len(dim["values"]) for dim in group)
            expected = 1.0
            for d_idx, dim in enumerate(group):
                sb = self.spinboxes[g_idx][d_idx]
                try:
                    sc = float(sb["skip_var"].get())
                except ValueError:
                    sc = 0.0
                sc = max(0.0, min(1.0, sc))
                expected *= len(dim["values"]) * (1.0 - sc)
            parts.append(
                f"Group {g_idx + 1}: Raw {raw_size} | Expected non-skipped ~{expected:.1f}"
            )
        self.info_label.configure(text=" | ".join(parts) if parts else "Array Space Size: 0")

    # ------------------------------------------------------------------
    # Index & skip management
    # ------------------------------------------------------------------

    def _adjust_index(self, group_idx, dim_idx, delta):
        sb = self.spinboxes[group_idx][dim_idx]
        try:
            curr = int(sb["var"].get())
        except ValueError:
            curr = 0
        new_val = max(0, min(curr + delta, sb["max"]))
        sb["var"].set(str(new_val))

    def _resample_all_skips_and_picks(self):
        for g_idx, group in enumerate(self.parsed_groups):
            for d_idx, dim in enumerate(group):
                sb = self.spinboxes[g_idx][d_idx]
                try:
                    sc = float(sb["skip_var"].get())
                except ValueError:
                    sc = 0.0
                sc = max(0.0, min(1.0, sc))
                sb["skip_roll"] = random.random() < sc

                mp = max(1, int(sb["maxpicks_var"].get()))
                n_vals = len(dim["values"])
                k = random.randint(1, min(mp, n_vals))
                picks = sorted(random.sample(range(n_vals), k))
                sb["pick_indices"] = picks

    def resample_skips_and_picks(self):
        self._resample_all_skips_and_picks()
        self.update_synthesized_output()

    def roll_random_coordinate(self):
        if not self.parsed_groups:
            self.process_and_display()

        for g_idx, group in enumerate(self.parsed_groups):
            for d_idx, dim in enumerate(group):
                sb = self.spinboxes[g_idx][d_idx]
                rand_idx = random.randint(0, sb["max"])
                sb["var"].set(str(rand_idx))

        self._resample_all_skips_and_picks()
        self.update_synthesized_output()

    # ------------------------------------------------------------------
    # Synthesis
    # ------------------------------------------------------------------

    def update_synthesized_output(self):
        if not self.parsed_groups:
            self.output_entry.configure(state="normal")
            self.output_entry.delete(0, "end")
            self.output_entry.configure(state="readonly")
            return

        rendered_elements = []  # list of {val, no_comma} in order

        for g_idx, group in enumerate(self.parsed_groups):
            for d_idx, dim in enumerate(group):
                sb = self.spinboxes[g_idx][d_idx]

                if sb.get("skip_roll", False):
                    continue

                # Determine which value(s) this dimension contributes
                mp = max(1, int(sb["maxpicks_var"].get()))
                if mp > 1:
                    # multi-pick: use cached random subset
                    picks = sb.get("pick_indices", [0])
                    if not picks:
                        picks = [0]
                else:
                    try:
                        val = int(sb["var"].get())
                    except ValueError:
                        val = 0
                    val = max(0, min(val, sb["max"]))
                    picks = [val]

                no_comma = sb["no_comma_var"].get()

                for p in picks:
                    p = max(0, min(p, sb["max"]))
                    val_str = str(dim["values"][p])
                    rendered_elements.append(
                        {"val": val_str, "no_comma": no_comma}
                    )

        synthesized_parts = []
        for idx, item in enumerate(rendered_elements):
            synthesized_parts.append(item["val"])
            if idx < len(rendered_elements) - 1:
                synthesized_parts.append(" " if item["no_comma"] else ", ")

        output_str = "".join(synthesized_parts)
        self.output_entry.configure(state="normal")
        self.output_entry.delete(0, "end")
        self.output_entry.insert(0, output_str)
        self.output_entry.configure(state="readonly")

        self._update_info_label()

    # ------------------------------------------------------------------
    # YAML Save / Load
    # ------------------------------------------------------------------

    def save_yaml(self):
        filepath = filedialog.asksaveasfilename(
            defaultextension=".yaml", filetypes=[("YAML Files", "*.yaml *.yml")]
        )
        if not filepath:
            return

        self.parse_input_text()
        raw_text = self.text_area.get("1.0", "end-1c")
        raw_roles = self.role_text_area.get("1.0", "end-1c")

        groups_export = []
        for g_idx, group in enumerate(self.parsed_groups):
            dims_export = []
            for d_idx, dim in enumerate(group):
                sb = self.spinboxes[g_idx][d_idx]
                try:
                    sc = float(sb["skip_var"].get())
                except ValueError:
                    sc = 0.0
                sc = max(0.0, min(1.0, sc))

                dim_copy = {
                    "role": dim.get("role"),
                    "depth": dim["depth"],
                    "type": dim["type"],
                    "no_comma": bool(sb["no_comma_var"].get()),
                    "skip_chance": round(sc, 4),
                    "max_picks": int(sb["maxpicks_var"].get()),
                    "values": dim["values"],
                }
                dims_export.append(dim_copy)

            groups_export.append(
                {"group_index": g_idx, "dimensions": dims_export}
            )

        yaml_data = {
            "version": scriptVersion,
            "settings": {
                "appearance_mode": ctk.get_appearance_mode(),
                "window_geometry": self.geometry(),
            },
            "data": {
                "raw_text": raw_text,
                "raw_roles": raw_roles,
                "groups": groups_export,
            },
        }

        with open(filepath, "w", encoding="utf-8") as f:
            yaml.dump(yaml_data, f, default_flow_style=False, allow_unicode=True)

    def load_yaml(self):
        filepath = filedialog.askopenfilename(
            filetypes=[("YAML Files", "*.yaml *.yml")]
        )
        if not filepath:
            return

        with open(filepath, "r", encoding="utf-8") as f:
            yaml_data = yaml.safe_load(f)

        if "settings" in yaml_data:
            settings = yaml_data["settings"]

            if "appearance_mode" in settings:
                mode = settings["appearance_mode"]
                ctk.set_appearance_mode(mode)
                self.theme_btn.configure(text=f"{mode} Mode")

            if "window_geometry" in settings:
                self.geometry(settings["window_geometry"])

        saved_state = []
        if "data" in yaml_data:
            data = yaml_data["data"]

            if "raw_text" in data:
                self.text_area.delete("1.0", "end")
                self.text_area.insert("1.0", data["raw_text"])

            if "raw_roles" in data:
                self.role_text_area.delete("1.0", "end")
                self.role_text_area.insert("1.0", data["raw_roles"])

            if "groups" in data:
                for group in data["groups"]:
                    group_states = []
                    for dim in group.get("dimensions", []):
                        group_states.append(
                            {
                                "index": 0,
                                "no_comma": dim.get("no_comma", False),
                                "skip_chance": dim.get("skip_chance", 0.0),
                                "max_picks": dim.get("max_picks", 1),
                            }
                        )
                    saved_state.append(group_states)

        self.parse_input_text()
        self._rebuild_inspector_ui(saved_state=saved_state if saved_state else None)
        self._resample_all_skips_and_picks()
        self.update_synthesized_output()


if __name__ == "__main__":
    app = ArraySpaceExplorer()
    app.mainloop()