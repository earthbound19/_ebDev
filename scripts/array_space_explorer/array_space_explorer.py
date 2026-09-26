# DESCRIPTION
# Array Space Explorer & Prompt Generator
# A CustomTkinter GUI tool for parsing line-separated, comma-delimited multidimensional arrays
# with indentation-based Cartesian hierarchy. Features interactive coordinate exploration,
# per-line "No comma" formatting controls, random coordinate generation, live prompt synthesis
# with direct clipboard copy support, window geometry tracking, and YAML config load/save capabilities.

# DEPENDENCIES
# - python >= 3.8
# - customtkinter
# - pyyaml

# USAGE
# 1. Install dependencies:
#    pip install customtkinter pyyaml
# 2. Run the application:
#    python array_space_explorer.py
# 3. Enter arrays line by line in the textarea. Use 2 spaces per indentation level to create
#    child dimensions (Cartesian products). Click "Display Array Space!" or "Explore Random Coordinate!".

# CODE
import math
import random
import tkinter as tk
from tkinter import filedialog
import customtkinter as ctk
import yaml

# Initialize CustomTkinter appearance defaults
ctk.set_appearance_mode("Dark")
ctk.set_default_color_theme("blue")


class ArraySpaceExplorer(ctk.CTk):

    def __init__(self):
        super().__init__()

        self.title("Array Space Explorer & Prompt Generator")
        self.geometry("950x850")

        self.parsed_groups = []  # Holds structured parsed array data
        self.spinboxes = []  # Holds CTk Entry/Spinbox & Checkbox widgets for indices

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
                "Constraints: No double quotes in strings. Apostrophes/single"
                " quotes allowed.\nBlank tokens between commas allowed (for optional/skipped elements). 2"
                " spaces per Cartesian dimension level."
            ),
            font=("Arial", 12, "italic"),
            text_color="gray",
        )
        self.constraint_label.pack(anchor="w", padx=20, pady=(5, 5))

        # Textarea Input with Horizontal Scrollbar
        self.text_frame = ctk.CTkFrame(self)
        self.text_frame.pack(fill="x", padx=15, pady=5)

        self.text_area = ctk.CTkTextbox(
            self.text_frame, height=180, font=("Consolas", 14), wrap="none"
        )
        self.text_area.pack(fill="x", expand=True, padx=5, pady=(5, 0))

        self.h_scrollbar = ctk.CTkScrollbar(
            self.text_frame,
            orientation="horizontal",
            command=self.text_area.xview,
        )
        self.h_scrollbar.pack(fill="x", padx=5, pady=(2, 5))
        self.text_area.configure(xscrollcommand=self.h_scrollbar.set)

        # Default starter content (including empty entries)
        self.text_area.insert(
            "1.0", "a, b, c, \n  1, , 2, 3\n    10.5, 20.0\nx, y, z"
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
        )
        self.info_label.pack(anchor="w", padx=20, pady=5)

        # Inspection Area (Scrollable Frame)
        self.inspector_frame = ctk.CTkScrollableFrame(
            self, height=220, label_text="Array Space Inspector"
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

        self.copy_btn = ctk.CTkButton(
            self.output_control_row,
            text="Copy to Clipboard",
            width=140,
            command=self.copy_to_clipboard,
        )
        self.copy_btn.pack(side="right")

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

    def _parse_token(self, token):
        token = token.strip()
        if not token:
            return ""

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
        raw_lines = raw_text.splitlines()

        normalized_lines = []
        prev_depth = 0  # Track previous line's depth

        for line in raw_lines:
            # Convert tabs to 2 spaces
            expanded = line.replace("\t", "  ")
            stripped = expanded.lstrip(" ")

            if not stripped:
                continue

            # Calculate indentation depth
            indent_count = len(expanded) - len(stripped)
            raw_depth = indent_count // 2

            # Clamp to the maximum depth allowed relative to the prior line
            max_depth = prev_depth + 1
            depth = min(raw_depth, max_depth)
            prev_depth = depth

            # Parse tokens including empty strings
            tokens = [self._parse_token(tok) for tok in stripped.split(",")]

            if tokens:
                normalized_lines.append(
                    {"depth": depth, "raw_tokens": tokens, "stripped": stripped}
                )

        # Re-format textarea content with standardized spaces
        reformatted_text_lines = []
        for item in normalized_lines:
            indent_str = "  " * item["depth"]
            tokens_str = ", ".join(
                '""' if t == "" else str(t) for t in item["raw_tokens"]
            )
            reformatted_text_lines.append(f"{indent_str}{tokens_str}")

        self.text_area.delete("1.0", "end")
        self.text_area.insert("1.0", "\n".join(reformatted_text_lines))

        # Build Hierarchy & Type Promotion
        groups = []
        current_group = []

        for item in normalized_lines:
            raw_tokens = item["raw_tokens"]
            depth = item["depth"]

            has_str = any(isinstance(t, str) and t != "" for t in raw_tokens)
            has_float = any(isinstance(t, float) for t in raw_tokens)

            if has_str:
                typed_tokens = [str(t) for t in raw_tokens]
                line_type = "string"
            elif has_float:
                typed_tokens = [
                    float(t) if t != "" else "" for t in raw_tokens
                ]
                line_type = "float"
            else:
                typed_tokens = [
                    int(t) if t != "" else "" for t in raw_tokens
                ]
                line_type = "int"

            dim_info = {
                "depth": depth,
                "type": line_type,
                "values": typed_tokens,
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

    def process_and_display(self):
        self.parse_input_text()
        self._rebuild_inspector_ui()
        self.update_synthesized_output()

    def _rebuild_inspector_ui(self, saved_no_comma_states=None):
        for widget in self.inspector_frame.winfo_children():
            widget.destroy()

        self.spinboxes = []
        total_space_sizes = []

        if not self.parsed_groups:
            self.info_label.configure(
                text="Array Space Size: 0 (No valid data)"
            )
            return

        for g_idx, group in enumerate(self.parsed_groups):
            group_size = math.prod(len(dim["values"]) for dim in group)
            total_space_sizes.append(
                f"Group {g_idx + 1}: {group_size} combinations"
            )

            group_container = ctk.CTkFrame(self.inspector_frame)
            group_container.pack(fill="x", padx=5, pady=5)

            lbl_title = ctk.CTkLabel(
                group_container,
                text=f"Group {g_idx + 1} (Size: {group_size})",
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

                first_three = dim["values"][:3]
                preview_str = ", ".join(
                    '""' if v == "" else str(v) for v in first_three
                )
                if len(dim["values"]) > 3:
                    preview_str += ", ..."

                lbl_dim = ctk.CTkLabel(
                    row_frame,
                    text=(
                        f"{indent_prefix}Dim [{d_idx}] (0 .."
                        f" {len(dim['values']) - 1}) -> Preview: [{preview_str}]"
                    ),
                    anchor="w",
                )
                lbl_dim.pack(side="left", fill="x", expand=True)

                # Spinbox (Up/Down Buttons + Entry)
                btn_down = ctk.CTkButton(
                    row_frame,
                    text="-",
                    width=30,
                    command=lambda g=g_idx, d=d_idx: self._adjust_index(
                        g, d, -1
                    ),
                )
                btn_down.pack(side="left", padx=2)

                entry_var = tk.StringVar(value="0")
                entry_var.trace_add(
                    "write", lambda *args: self._on_index_change()
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
                    command=lambda g=g_idx, d=d_idx: self._adjust_index(
                        g, d, 1
                    ),
                )
                btn_up.pack(side="left", padx=2)

                # "Display no comma" checkbox to the right of every line
                no_comma_var = tk.BooleanVar(value=False)
                if (
                    saved_no_comma_states
                    and g_idx < len(saved_no_comma_states)
                    and d_idx < len(saved_no_comma_states[g_idx])
                ):
                    no_comma_var.set(saved_no_comma_states[g_idx][d_idx])

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
                        "no_comma_var": no_comma_var,
                        "max": len(dim["values"]) - 1,
                    }
                )

            self.spinboxes.append(group_spinboxes)

        self.info_label.configure(text=" | ".join(total_space_sizes))

    def _adjust_index(self, group_idx, dim_idx, delta):
        sb = self.spinboxes[group_idx][dim_idx]
        try:
            curr = int(sb["var"].get())
        except ValueError:
            curr = 0

        new_val = max(0, min(curr + delta, sb["max"]))
        sb["var"].set(str(new_val))

    def _on_index_change(self):
        self.update_synthesized_output()

    def update_synthesized_output(self):
        output_tokens = []

        for g_idx, group in enumerate(self.parsed_groups):
            for d_idx, dim in enumerate(group):
                sb = self.spinboxes[g_idx][d_idx]
                try:
                    val = int(sb["var"].get())
                except ValueError:
                    val = 0

                clamped_idx = max(0, min(val, sb["max"]))
                val_str = str(dim["values"][clamped_idx])
                no_comma = sb["no_comma_var"].get()

                output_tokens.append({"val": val_str, "no_comma": no_comma})

        # Assemble string dynamically, ignoring blank elements
        rendered_elements = []
        for idx, item in enumerate(output_tokens):
            if item["val"] == "":
                continue

            rendered_elements.append(item)

        synthesized_parts = []
        for idx, item in enumerate(rendered_elements):
            synthesized_parts.append(item["val"])

            # Determine separator following this element (if not the last active element)
            if idx < len(rendered_elements) - 1:
                if item["no_comma"]:
                    synthesized_parts.append(" ")
                else:
                    synthesized_parts.append(", ")

        output_str = "".join(synthesized_parts)
        self.output_entry.configure(state="normal")
        self.output_entry.delete(0, "end")
        self.output_entry.insert(0, output_str)
        self.output_entry.configure(state="readonly")

    def roll_random_coordinate(self):
        if not self.parsed_groups:
            self.process_and_display()

        for g_idx, group in enumerate(self.parsed_groups):
            for d_idx, dim in enumerate(group):
                sb = self.spinboxes[g_idx][d_idx]
                rand_idx = random.randint(0, sb["max"])
                sb["var"].set(str(rand_idx))

        self.update_synthesized_output()

    def save_yaml(self):
        filepath = filedialog.asksaveasfilename(
            defaultextension=".yaml", filetypes=[("YAML Files", "*.yaml *.yml")]
        )
        if not filepath:
            return

        self.parse_input_text()
        raw_text = self.text_area.get("1.0", "end-1c")

        groups_export = []
        for g_idx, group in enumerate(self.parsed_groups):
            dims_export = []
            for d_idx, dim in enumerate(group):
                sb = self.spinboxes[g_idx][d_idx]
                dim_copy = dict(dim)
                dim_copy["no_comma"] = sb["no_comma_var"].get()
                dims_export.append(dim_copy)

            groups_export.append(
                {"group_index": g_idx, "dimensions": dims_export}
            )

        yaml_data = {
            "version": "1.0",
            "settings": {
                "appearance_mode": ctk.get_appearance_mode(),
                "window_geometry": self.geometry(),
            },
            "data": {
                "raw_text": raw_text,
                "groups": groups_export,
            },
        }

        with open(filepath, "w", encoding="utf-8") as f:
            yaml.dump(yaml_data, f, default_flow_style=False)

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

        saved_no_comma_states = []
        if "data" in yaml_data:
            if "raw_text" in yaml_data["data"]:
                self.text_area.delete("1.0", "end")
                self.text_area.insert("1.0", yaml_data["data"]["raw_text"])

            if "groups" in yaml_data["data"]:
                for group in yaml_data["data"]["groups"]:
                    group_states = []
                    for dim in group.get("dimensions", []):
                        group_states.append(dim.get("no_comma", False))
                    saved_no_comma_states.append(group_states)

        self.parse_input_text()
        self._rebuild_inspector_ui(saved_no_comma_states=saved_no_comma_states)
        self.update_synthesized_output()


if __name__ == "__main__":
    app = ArraySpaceExplorer()
    app.mainloop()