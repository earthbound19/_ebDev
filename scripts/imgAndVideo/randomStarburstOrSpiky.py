#!/usr/bin/env python3
"""
DESCRIPTION
Generates plain SVG images of starburst or spiky polygons constrained to
an elliptical donut (annulus), with optional random vertex translation,
to make regular or irregular stars or flares and "spikies." The polygon’s
vertices are connected in angular order, guaranteeing a simple
(non‑self‑intersecting) shape. Three generation modes are available:
    perfect    – a perfectly symmetric alternating star.
    starburst  – an irregular star with angular and radial jitter of vertex
                 locations.
    random     – a "spiky," with vertices placed randomly inside the annulus.
Output is a plain SVG file with transparent background, black fill, and no
stroke.

USAGE
Run with these parameters (all are switch arguments):
    --mode {perfect,starburst,random}  (required)
    optional switches: -N, -W, -H, -r, -o, --fill, --stroke, --stroke-width, --seed
    mode-specific switches for 'starburst': -j, -J, --alternate-start
    mode-specific switches for 'perfect': --alternate-start

Examples:
    python randomStarburstOrSpiky.py --mode perfect -N 7
    python randomStarburstOrSpiky.py --mode random -N 20 -W 640 -H 480 -r 0.3 --seed 99 -o random.svg
    python randomStarburstOrSpiky.py --mode starburst -N 15 -j 25 -J 0.4 --seed 42

Detailed switch reference:
    --mode, -m        Generation mode. Required. One of:
                      perfect   – perfectly symmetric alternating star. A perfect star
                                will result from an even number for -N. An odd number
                                for -N here will result in a stubbed flare connected
                                by a straight line if vertex alternation starts on the outer
                                radius, or a truncated flare if vertex alternation starts
                                on the inner radius (--alternate-start inner)
                      starburst – irregular star with jitter (see -j, -J).
                      random    – completely random vertices in the donut.
    -N, --num-vertices   Integer, default 12. Number of polygon vertices (≥3).
    -W, --width          Integer, default 800. Canvas width in pixels.
    -H, --height         Integer, default same as --width. Canvas height.
                         If different from width, the donut becomes elliptical.
    -r, --inner-radius   Float, default 0.4. Scale factor for the inner ellipse
                         relative to the outer. Must be strictly between 0 and 1.
                         Example: 0.42 makes inner ellipse 42% the size of the outer.
                         The outer ellipse goes to the edge of the canvas and there
                         is not any switch to change that.
    -o, --output         File path, default auto‑generated. Output SVG file.
                         If omitted, a timestamped name is created of the form
                         YYYY_MM_DD_HH_MM_SS_<mode>_r<seed>.svg
    --fill               SVG color string, default 'black'. Polygon fill colour.
    --stroke             SVG color string, default 'none'. Polygon stroke colour.
                         When 'none', no stroke is drawn. Otherwise a valid SVG
                         colour name or #RRGGBB value.
    --stroke-width       Float, default 0. Stroke width (ignored if --stroke is 'none').
    --seed               Integer, default random. Random seed for reproducibility.
                         If not supplied, a random seed is generated and printed
                         to stderr, and also embedded in the SVG metadata.

    Mode‑specific switches:
    (only for 'starburst')
    -j, --jitter-angle   Float, default 0.0, range 0–360 (degrees).
                         Total allowed angular jitter. Each vertex’s base angle
                         is shifted by a random amount between ±(value/2) degrees.
                         So for example -j 18 leads to random angular jitter plus
                         or minus that range, or 18/2 = 8; the vertex will randomly
                         jitter +- 9 degrees. Values above roughly 180/N may cause
                         vertices to swap angular order (a warning is shown).
    -J, --jitter-radius  Float, default 0.0, range 0.0–1.0.
                         Only used in starburst mode. Fraction of the local radial
                         gap that a vertex may move toward the opposite boundary.
                         0 = no radial jitter, vertices stay on their assigned
                         inner/outer ellipse. 1 = max jitter (can touch the opposite
                         boundary). For example a vertex originating on the inner
                         radius (starburst mode only) with -J 0.8 will randomly
                         jitter up to 80 percent toward the outer radius. Likewise
                         a vertex orignating on the outer radius would randomly
                         jitter up to 80% toward the inner radius. Or with -J 0.4
                         a vertex originated on the outer radius will randomly jitter
                         up to 40% toward toward the inner radius, etc.

    (for 'perfect' and 'starburst')
    --alternate-start    String, default 'outer'. Which ellipse boundary the
                         first vertex (lowest angle) is placed on:
                         'outer' → first vertex on outer edge (then alternates).
                         'inner' → first vertex on inner edge.
                         Ignored in 'random' mode.
"""
# CODE

import argparse
import math
import random
import sys
import datetime

MARGIN = 2   # pixels subtracted from each side to keep the polygon inside the viewBox


def ellipse_radius(a: float, b: float, theta: float) -> float:
    """
    Distance from the centre to the boundary of an ellipse with semi-axes a, b
    at angle theta (radians).
    Formula: r = a*b / sqrt((b*cosθ)^2 + (a*sinθ)^2)
    """
    if a == b:
        return a
    cos_t = math.cos(theta)
    sin_t = math.sin(theta)
    return (a * b) / math.sqrt((b * cos_t) ** 2 + (a * sin_t) ** 2)


def to_cartesian(cx: float, cy: float, rho: float, theta: float):
    """Convert polar (ρ, θ) to Cartesian (x, y) with SVG y-down convention."""
    x = cx + rho * math.cos(theta)
    y = cy + rho * math.sin(theta)  # positive sin => down in SVG
    return x, y


def generate_perfect(args):
    """Generate vertices for a perfect alternating starburst."""
    N = args.num_vertices
    a = args.outer_a
    b = args.outer_b
    r_factor = args.inner_radius
    start_offset = 0 if args.alternate_start == 'outer' else 1
    vertices = []
    for i in range(N):
        theta = 2 * math.pi * i / N
        R_outer = ellipse_radius(a, b, theta)
        target_is_outer = (i + start_offset) % 2 == 0
        rho = R_outer if target_is_outer else R_outer * r_factor
        vertices.append((theta, rho))
    return vertices


def randomStarburstOrSpiky(args):
    """Generate vertices for an irregular starburst with jitter."""
    N = args.num_vertices
    a = args.outer_a
    b = args.outer_b
    r_factor = args.inner_radius
    jitter_deg = args.jitter_angle
    jitter_frac = args.jitter_radius
    start_offset = 0 if args.alternate_start == 'outer' else 1

    # Warn if angular jitter > 180/N degrees (threshold for potential reordering)
    if N > 0 and jitter_deg > 180.0 / N:
        print(
            f"Warning: angular jitter ({jitter_deg}°) exceeds 180/N ≈ {180.0/N:.1f}°. "
            "Vertices may swap angular order, making the shape irregular.",
            file=sys.stderr,
        )

    vertices = []
    for i in range(N):
        base_theta = 2 * math.pi * i / N
        # Angular jitter (degrees -> radians)
        angle_shift_deg = random.uniform(-jitter_deg / 2, jitter_deg / 2)
        theta = base_theta + math.radians(angle_shift_deg)

        R_outer = ellipse_radius(a, b, theta)
        R_inner = R_outer * r_factor
        gap = R_outer - R_inner

        target_is_outer = (i + start_offset) % 2 == 0

        if target_is_outer:
            # Starting on outer edge, move inward by a fraction of gap
            shift = random.uniform(0.0, jitter_frac) * gap
            rho = R_outer - shift
        else:
            # Starting on inner edge, move outward
            shift = random.uniform(0.0, jitter_frac) * gap
            rho = R_inner + shift

        vertices.append((theta, rho))
    return vertices


def generate_random(args):
    """Generate vertices placed uniformly at random inside the annulus."""
    N = args.num_vertices
    a = args.outer_a
    b = args.outer_b
    r_factor = args.inner_radius
    vertices = []
    for _ in range(N):
        theta = random.uniform(0, 2 * math.pi)
        R_outer = ellipse_radius(a, b, theta)
        R_inner = R_outer * r_factor
        rho = R_inner + random.uniform(0, 1) * (R_outer - R_inner)
        vertices.append((theta, rho))
    return vertices


def write_svg(args, vertices):
    """Create and output the SVG file (or stdout)."""
    W, H = args.width, args.height
    cx, cy = W / 2.0, H / 2.0

    # Sort vertices by polar angle
    vertices.sort(key=lambda v: v[0])

    # Ensure no duplicate angles (extremely unlikely, but cheap to fix)
    eps = 1e-12
    for i in range(len(vertices)):
        if i > 0 and abs(vertices[i][0] - vertices[i - 1][0]) < eps:
            vertices[i] = (vertices[i][0] + eps, vertices[i][1])

    # Build polygon points string
    points = []
    for theta, rho in vertices:
        x, y = to_cartesian(cx, cy, rho, theta)
        points.append(f"{x:.3f},{y:.3f}")
    points_str = " ".join(points)

    # Build switches string for metadata
    switch_parts = [f"--mode {args.mode}",
                    f"-N {args.num_vertices}",
                    f"-W {args.width}"]
    if args.height != args.width:
        switch_parts.append(f"-H {args.height}")
    if args.inner_radius != 0.4:
        switch_parts.append(f"-r {args.inner_radius}")
    if args.mode in ('perfect', 'starburst'):
        if args.alternate_start != 'outer':
            switch_parts.append(f"--alternate-start {args.alternate_start}")
    if args.mode == 'starburst':
        if args.jitter_angle != 0.0:
            switch_parts.append(f"-j {args.jitter_angle}")
        if args.jitter_radius != 0.0:
            switch_parts.append(f"-J {args.jitter_radius}")
    if args.fill != 'black':
        switch_parts.append(f"--fill {args.fill}")
    if args.stroke != 'none':
        switch_parts.append(f"--stroke {args.stroke}")
        if args.stroke_width != 0:
            switch_parts.append(f"--stroke-width {args.stroke_width}")
    if args.output:
        switch_parts.append(f"-o {args.output}")
    switch_parts.append(f"--seed {args.seed}")

    switches_str = " ".join(switch_parts)

    # Build SVG content
    svg_lines = [
        f'<svg viewBox="0 0 {W} {H}" xmlns="http://www.w3.org/2000/svg">',
        f'  <!-- Created with randomStarburstOrSpiky.py. Switches: {switches_str} -->',
        f'  <polygon points="{points_str}"',
        f'            fill="{args.fill}"',
    ]
    if args.stroke == 'none':
        svg_lines.append('            stroke="none"')
    else:
        svg_lines.append(f'            stroke="{args.stroke}"')
        if args.stroke_width:
            svg_lines.append(f'            stroke-width="{args.stroke_width}"')
    svg_lines.extend(["  />", "</svg>"])

    svg_text = "\n".join(svg_lines)

    # Output
    if args.output:
        with open(args.output, 'w', encoding='utf-8') as f:
            f.write(svg_text)
        print(f"SVG saved to {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(svg_text)


def auto_filename(mode: str, seed: int) -> str:
    """Generate timestamped filename: YYYY_MM_DD_HH_MM_SS_<mode>_r<seed>.svg"""
    now = datetime.datetime.now()
    timestamp = now.strftime("%Y_%m_%d_%H_%M_%S")
    return f"{timestamp}_{mode}_r{seed}.svg"


def main():
    parser = argparse.ArgumentParser(
        description="Generate SVG starburst / spiky polygon images.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    # Required mode switch
    parser.add_argument('--mode', '-m', required=True,
                        choices=['perfect', 'starburst', 'random'],
                        help="Generation mode (required)")

    # Common switches
    parser.add_argument('-N', '--num-vertices', type=int, default=12,
                        help="Number of vertices (>=3). Default: 12")
    parser.add_argument('-W', '--width', type=int, default=800,
                        help="Canvas width in pixels. Default: 800")
    parser.add_argument('-H', '--height', type=int, default=None,
                        help="Canvas height, same as width if omitted.")
    parser.add_argument('-r', '--inner-radius', type=float, default=0.4,
                        help="Scale factor for inner ellipse (0 < r < 1). Default: 0.4")
    parser.add_argument('-o', '--output', type=str, default=None,
                        help="Output SVG file. If omitted a timestamped name is used.")
    parser.add_argument('--fill', type=str, default='black',
                        help="Polygon fill colour. Default: black")
    parser.add_argument('--stroke', type=str, default='none',
                        help="Stroke colour. 'none' for no stroke. Default: none")
    parser.add_argument('--stroke-width', type=float, default=0,
                        help="Stroke width; ignored if stroke is 'none'. Default: 0")
    parser.add_argument('--seed', type=int, default=None,
                        help="Random seed for reproducibility. Random if omitted.")

    # Mode-specific switches (available always, but validated later)
    parser.add_argument('-j', '--jitter-angle', type=float, default=0.0,
                        help="Max angular jitter in degrees (0-360). Only for 'starburst'. Default: 0")
    parser.add_argument('-J', '--jitter-radius', type=float, default=0.0,
                        help="Max radial jitter as fraction of local gap (0-1). Only for 'starburst'. Default: 0")
    parser.add_argument('--alternate-start', choices=['outer', 'inner'], default='outer',
                        help="Which edge the first vertex sits on. For 'perfect' and 'starburst'. Default: outer")

    args = parser.parse_args()

    # Height default to width if not set
    if args.height is None:
        args.height = args.width

    # Basic parameter validation
    if args.num_vertices < 3:
        parser.error("Number of vertices must be at least 3.")
    if not (0 < args.inner_radius < 1):
        parser.error("Inner radius factor must be between 0 and 1 (exclusive).")
    if args.width < 2 * MARGIN + 1:
        parser.error(f"Width must be at least {2 * MARGIN + 1}px.")
    if args.height < 2 * MARGIN + 1:
        parser.error(f"Height must be at least {2 * MARGIN + 1}px.")

    # Validate mode-specific constraints
    if args.mode != 'starburst':
        if args.jitter_angle != 0.0 or args.jitter_radius != 0.0:
            parser.error("--jitter-angle and --jitter-radius are only allowed with --mode starburst.")
    else:
        if not (0 <= args.jitter_angle <= 360):
            parser.error("--jitter-angle must be between 0 and 360 degrees.")
        if not (0 <= args.jitter_radius <= 1):
            parser.error("--jitter-radius must be between 0 and 1.")

    if args.mode not in ('perfect', 'starburst') and args.alternate_start != 'outer':
        parser.error("--alternate-start is only valid for 'perfect' and 'starburst' modes.")

    # Seed handling
    if args.seed is None:
        args.seed = random.randint(0, 2**31 - 1)
    random.seed(args.seed)
    print(f"Using seed: {args.seed}", file=sys.stderr)

    # Compute semi-axes (outer ellipse)
    args.outer_a = args.width / 2.0 - MARGIN
    args.outer_b = args.height / 2.0 - MARGIN
    if args.outer_a <= 0 or args.outer_b <= 0:
        parser.error("Canvas too small; outer ellipse has non-positive semi-axes.")

    # Generate vertices
    if args.mode == 'perfect':
        vertices = generate_perfect(args)
    elif args.mode == 'starburst':
        vertices = randomStarburstOrSpiky(args)
    else:  # random
        vertices = generate_random(args)

    # Auto-filename if needed
    if args.output is None:
        args.output = auto_filename(args.mode, args.seed)

    # Write SVG
    write_svg(args, vertices)


if __name__ == "__main__":
    main()