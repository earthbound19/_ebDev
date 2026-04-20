#!/usr/bin/env python3
"""
SCRIPT: report_render_statistics.py
VERSION: 1.0.0

DESCRIPTION:
    Render Statistics Reporter for ComfyUI Batch Runner
    Reads the state pickle file from comfyUIbatchRunner.py and generates
    human-readable reports about render progress, completion statistics,
    and identifies combinations that need attention.

DEPENDENCIES:
    Python 3.6 or higher
    No external libraries required (uses only standard library)

USAGE:
    # Basic report (requires only state file)
    python report_render_statistics.py --state-file state.pkl
    
    # Full report with human-readable prompt text
    python report_render_statistics.py --state-file state.pkl \\
        --superprompts superprompts.txt --metaprompts metaprompts.txt
    
    # Save to file
    python report_render_statistics.py --state-file state.pkl --output report.txt
    
    # CSV export for spreadsheet analysis
    python report_render_statistics.py --state-file state.pkl --format csv --output data.csv
    
    # Show combinations with no completed renders
    python report_render_statistics.py --state-file state.pkl --combinations-with-no-renders
    
    # Show combinations where all renders are complete
    python report_render_statistics.py --state-file state.pkl --combinations-with-all-renders
    
    # Show combinations below 50% completion rate
    python report_render_statistics.py --state-file state.pkl --completion-below 0.5
    
    # Group by superprompt only (roll up all metaprompts)
    python report_render_statistics.py --state-file state.pkl --group-by superprompt

REQUIRED ARGUMENTS:
    --state-file FILE         Path to state pickle file from comfyUIbatchRunner.py

OPTIONAL ARGUMENTS - INPUT FILES:
    --superprompts FILE       Superprompts file for human-readable output
                              (default: superprompts.txt)
    --metaprompts FILE        Metaprompts file for human-readable output
                              (default: metaprompts.txt)

OPTIONAL ARGUMENTS - OUTPUT CONTROL:
    --format FORMAT           Output format: 'table' (default) or 'csv'
    --output FILE             Write output to file instead of stdout
    --no-color                Disable ANSI color codes in table output

OPTIONAL ARGUMENTS - FILTERING:
    --combinations-with-no-renders     Show only combinations with 0 completed renders
    --combinations-with-all-renders    Show only fully completed combinations
    --completion-below N               Show combinations with completion rate < N (0.0-1.0)
    --superprompt-idx RANGE            Filter by superprompt index (e.g., '0,3,5-10')
    --metaprompt-idx RANGE             Filter by metaprompt index (e.g., '0,3,5-10')

OPTIONAL ARGUMENTS - GROUPING:
    --group-by TYPE           Group results: 'superprompt', 'metaprompt', or
                              'superduperprompt' (default)

NOTES:
    COLOR CODING (table format only):
        - Green: Completion rate >= 80%
        - Yellow: Completion rate 20-80%
        - Red: Completion rate < 20%
        - Bright Red + Bold: 0% complete
        - Dim Green: 100% complete

    INDEX RANGE SYNTAX:
        Examples: '0'        (single index)
                  '0,3,5'    (multiple indices)
                  '0-10'     (range inclusive)
                  '0-5,10,15-20' (mixed)

EXAMPLES:
    # Quick overview of all combinations
    python report_render_statistics.py --state-file state.pkl
    
    # See what hasn't been rendered at all
    python report_render_statistics.py --state-file state.pkl --combinations-with-no-renders
    
    # Export problem areas (below 30% complete) to CSV
    python report_render_statistics.py --state-file state.pkl \\
        --completion-below 0.3 --format csv --output problem_combos.csv
    
    # Check progress for specific superprompts
    python report_render_statistics.py --state-file state.pkl \\
        --superprompt-idx 0-5 --group-by superprompt
    
    # Full report with prompt text
    python report_render_statistics.py --state-file state.pkl \\
        --superprompts superprompts.txt --metaprompts metaprompts.txt --output full_report.txt
"""

import argparse
import pickle
import sys
import re
from pathlib import Path
from collections import defaultdict
from datetime import datetime
from typing import List, Dict, Tuple, Optional, Set

# ANSI color codes (disabled if --no-color or output is not a terminal)
COLORS = {
    'green': '\033[92m',
    'dim_green': '\033[2;92m',
    'yellow': '\033[93m',
    'red': '\033[91m',
    'bright_red': '\033[91;1m',
    'cyan': '\033[96m',
    'bold': '\033[1m',
    'reset': '\033[0m'
}

def parse_index_range(range_str: str) -> Set[int]:
    """Parse index range string like '0,3,5-10' into a set of integers"""
    indices = set()
    parts = range_str.split(',')
    
    for part in parts:
        part = part.strip()
        if '-' in part:
            start, end = part.split('-')
            start = int(start.strip())
            end = int(end.strip())
            indices.update(range(start, end + 1))
        else:
            indices.add(int(part))
    
    return indices

def load_state_file(state_path: Path) -> List[Dict]:
    """Load and validate state pickle file"""
    if not state_path.exists():
        print(f"Error: State file not found: {state_path}")
        sys.exit(1)
    
    try:
        with open(state_path, 'rb') as f:
            state = pickle.load(f)
        
        if not isinstance(state, list):
            print(f"Error: {state_path} does not contain a valid state list")
            sys.exit(1)
        
        if len(state) == 0:
            print(f"Error: {state_path} is empty")
            sys.exit(1)
        
        return state
    except Exception as e:
        print(f"Error loading state file: {e}")
        sys.exit(1)

def load_prompt_file(file_path: Path) -> List[str]:
    """Load prompts from text file (one per line)"""
    if not file_path.exists():
        return []
    
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            return [line.strip() for line in f if line.strip()]
    except Exception as e:
        print(f"Warning: Could not load {file_path}: {e}")
        return []

class ComboAggregate:
    """Aggregated statistics for a superduperprompt (sp_idx, mp_idx pair)"""
    def __init__(self, superprompt_idx: int, metaprompt_idx: int):
        self.superprompt_idx = superprompt_idx
        self.metaprompt_idx = metaprompt_idx
        self.completed_reps: List[int] = []
        self.pending_reps: List[int] = []
        self.rendering_reps: List[int] = []
        self.failed_reps: List[int] = []
        self.seeds: Dict[int, int] = {}  # rep -> seed
    
    def add_render(self, rep: int, status: str, seed: Optional[int] = None):
        """Add a render repetition to the aggregate"""
        if status == 'completed':
            self.completed_reps.append(rep)
            if seed is not None:
                self.seeds[rep] = seed
        elif status == 'pending':
            self.pending_reps.append(rep)
        elif status == 'rendering':
            self.rendering_reps.append(rep)
        elif status == 'failed':
            self.failed_reps.append(rep)
    
    @property
    def completed(self) -> int:
        return len(self.completed_reps)
    
    @property
    def total(self) -> int:
        return (len(self.completed_reps) + len(self.pending_reps) + 
                len(self.rendering_reps) + len(self.failed_reps))
    
    @property
    def pending(self) -> int:
        return len(self.pending_reps)
    
    @property
    def completion_rate(self) -> float:
        return self.completed / self.total if self.total > 0 else 0.0
    
    @property
    def is_complete(self) -> bool:
        return self.completed == self.total and self.total > 0
    
    @property
    def is_unrendered(self) -> bool:
        return self.completed == 0 and self.total > 0

def aggregate_by_superduperprompt(state: List[Dict]) -> Dict[Tuple[int, int], ComboAggregate]:
    """Group by (sp_idx, mp_idx) pair"""
    aggregates = {}
    
    for combo in state:
        key = (combo['superprompt_idx'], combo.get('metaprompt_idx', -1))
        
        if key not in aggregates:
            aggregates[key] = ComboAggregate(key[0], key[1])
        
        # Determine repetition number
        s_rep = combo.get('superprompt_repetition', 0)
        m_rep = combo.get('metaprompt_repetition', 0)
        # For reporting, we just need which repetition number (m_rep varies fastest)
        rep = m_rep
        
        status = combo.get('status', 'pending')
        seed = combo.get('seed')
        
        aggregates[key].add_render(rep, status, seed)
    
    return aggregates

def aggregate_by_superprompt(aggregates: Dict[Tuple[int, int], ComboAggregate]) -> Dict[int, Dict]:
    """Roll up metaprompts per superprompt"""
    result = {}
    
    for (sp_idx, mp_idx), agg in aggregates.items():
        if sp_idx not in result:
            result[sp_idx] = {
                'completed': 0,
                'total': 0,
                'combos': []
            }
        
        result[sp_idx]['completed'] += agg.completed
        result[sp_idx]['total'] += agg.total
        result[sp_idx]['combos'].append(agg)
    
    return result

def aggregate_by_metaprompt(aggregates: Dict[Tuple[int, int], ComboAggregate]) -> Dict[int, Dict]:
    """Roll up superprompts per metaprompt"""
    result = {}
    
    for (sp_idx, mp_idx), agg in aggregates.items():
        if mp_idx not in result:
            result[mp_idx] = {
                'completed': 0,
                'total': 0,
                'combos': []
            }
        
        result[mp_idx]['completed'] += agg.completed
        result[mp_idx]['total'] += agg.total
        result[mp_idx]['combos'].append(agg)
    
    return result

def apply_filters(aggregates: List[Tuple[Tuple[int, int], ComboAggregate]], 
                  args) -> List[Tuple[Tuple[int, int], ComboAggregate]]:
    """Apply filtering options to the aggregates list"""
    filtered = []
    
    for key, agg in aggregates:
        # Filter by combinations-with-no-renders
        if args.combinations_with_no_renders and not agg.is_unrendered:
            continue
        
        # Filter by combinations-with-all-renders
        if args.combinations_with_all_renders and not agg.is_complete:
            continue
        
        # Filter by completion-below threshold
        if args.completion_below is not None and agg.completion_rate >= args.completion_below:
            continue
        
        # Filter by superprompt index
        if args.superprompt_idx:
            if key[0] not in args.superprompt_idx:
                continue
        
        # Filter by metaprompt index
        if args.metaprompt_idx:
            if key[1] not in args.metaprompt_idx:
                continue
        
        filtered.append((key, agg))
    
    # Sort by original index order (sp_idx then mp_idx)
    filtered.sort(key=lambda x: (x[0][0], x[0][1]))
    
    return filtered

def get_completion_color(rate: float, is_complete: bool, use_color: bool) -> str:
    """Get ANSI color code for completion rate"""
    if not use_color:
        return ""
    
    if is_complete:
        return COLORS['dim_green']
    elif rate == 0.0:
        return COLORS['bright_red']
    elif rate < 0.2:
        return COLORS['red']
    elif rate < 0.8:
        return COLORS['yellow']
    else:
        return COLORS['green']

def format_progress_bar(rate: float, width: int = 10) -> str:
    """Create a simple progress bar string"""
    filled = int(rate * width)
    empty = width - filled
    return '■' * filled + '░' * empty

def format_table(aggregates: List[Tuple[Tuple[int, int], ComboAggregate]],
                 summary: Dict,
                 superprompts: List[str],
                 metaprompts: List[str],
                 group_by: str,
                 use_color: bool) -> str:
    """Format output as human-readable table"""
    lines = []
    
    # Header
    lines.append("=" * 70)
    lines.append(f"RENDER STATISTICS REPORT")
    lines.append(f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    lines.append(f"State file: {summary['state_file']}")
    lines.append("=" * 70)
    lines.append("")
    
    # Summary
    lines.append("SUMMARY")
    lines.append(f"  Total combinations:     {summary['total_combinations']:,}")
    
    completed = summary['completed']
    total = summary['total_combinations']
    rate = completed / total if total > 0 else 0
    color = get_completion_color(rate, completed == total, use_color)
    lines.append(f"  Completed:              {color}{completed:,} ({rate:.1%}){COLORS['reset'] if use_color else ''}")
    
    pending = summary['pending']
    lines.append(f"  Pending:                {pending:,}")
    
    rendering = summary.get('rendering', 0)
    if rendering > 0:
        lines.append(f"  In progress:            {rendering:,}")
    
    lines.append("")
    lines.append(f"  Superprompts:           {summary['superprompt_count']}")
    lines.append(f"  Metaprompts:            {summary['metaprompt_count']}")
    lines.append(f"  Repetitions per combo:  {summary['repetitions_per_combo']}")
    lines.append("")
    
    if group_by == 'superduperprompt':
        lines.append("=" * 70)
        if summary.get('filter_active'):
            lines.append(f"SUPERDUPERPROMPTS (filtered - {len(aggregates)} of {summary['total_combos_count']} combos)")
        else:
            lines.append(f"SUPERDUPERPROMPTS ({len(aggregates)} total)")
        lines.append("=" * 70)
        lines.append("")
        
        for (sp_idx, mp_idx), agg in aggregates:
            # Get prompt text if available
            sp_text = superprompts[sp_idx] if sp_idx < len(superprompts) else f"sp{sp_idx}"
            if mp_idx >= 0 and mp_idx < len(metaprompts):
                mp_text = metaprompts[mp_idx]
                display_text = f"{sp_text} + {mp_text}"
            elif mp_idx == -1 or not metaprompts:
                display_text = sp_text
            else:
                display_text = f"{sp_text} + mp{mp_idx}"
            
            # Don't truncate - let terminal handle wrapping
            rate = agg.completion_rate
            color = get_completion_color(rate, agg.is_complete, use_color)
            bar = format_progress_bar(rate)
            
            if agg.is_complete:
                status_marker = " ✓"
            else:
                status_marker = ""
            
            lines.append(f"  [{sp_idx},{mp_idx}] {display_text}")
            lines.append(f"      {color}{bar}{COLORS['reset'] if use_color else ''} {agg.completed}/{agg.total} complete ({rate:.1%}){status_marker}")
            
            # Show completed repetitions only if any exist and combo is not complete
            if agg.completed_reps and not agg.is_complete:
                completed_str = ', '.join(str(r) for r in sorted(agg.completed_reps))
                lines.append(f"      Completed repetitions: {completed_str}")
            elif agg.completed_reps == 0:
                lines.append(f"      (no completed repetitions)")
            
            lines.append("")
    
    elif group_by == 'superprompt':
        lines.append("=" * 70)
        lines.append(f"PROGRESS BY SUPROMPT ({len(aggregates)} superprompts)")
        lines.append("=" * 70)
        lines.append("")
        
        by_sp = aggregate_by_superprompt(dict(aggregates))
        
        for sp_idx in sorted(by_sp.keys()):
            sp_data = by_sp[sp_idx]
            sp_text = superprompts[sp_idx] if sp_idx < len(superprompts) else f"sp{sp_idx}"
            
            # Don't truncate - let terminal handle wrapping
            
            rate = sp_data['completed'] / sp_data['total'] if sp_data['total'] > 0 else 0
            color = get_completion_color(rate, sp_data['completed'] == sp_data['total'], use_color)
            bar = format_progress_bar(rate)
            
            lines.append(f"  sp{sp_idx:03d} [{sp_text}]")
            lines.append(f"      {color}{bar}{COLORS['reset'] if use_color else ''} {sp_data['completed']:,}/{sp_data['total']:,} complete ({rate:.1%})")
            lines.append("")
    
    elif group_by == 'metaprompt':
        lines.append("=" * 70)
        lines.append(f"PROGRESS BY METAPROMPT ({len(aggregates)} metaprompts)")
        lines.append("=" * 70)
        lines.append("")
        
        by_mp = aggregate_by_metaprompt(dict(aggregates))
        
        for mp_idx in sorted(by_mp.keys()):
            mp_data = by_mp[mp_idx]
            if mp_idx >= 0 and mp_idx < len(metaprompts):
                mp_text = metaprompts[mp_idx]
                display = f"mp{mp_idx:03d} [{mp_text}]"
            else:
                display = f"mp{mp_idx} [no metaprompt]"
            
            rate = mp_data['completed'] / mp_data['total'] if mp_data['total'] > 0 else 0
            color = get_completion_color(rate, mp_data['completed'] == mp_data['total'], use_color)
            bar = format_progress_bar(rate)
            
            lines.append(f"  {display}")
            lines.append(f"      {color}{bar}{COLORS['reset'] if use_color else ''} {mp_data['completed']:,}/{mp_data['total']:,} complete ({rate:.1%})")
            lines.append("")
    
    lines.append("=" * 70)
    
    return '\n'.join(lines)

def format_csv(aggregates: List[Tuple[Tuple[int, int], ComboAggregate]],
               summary: Dict,
               superprompts: List[str],
               metaprompts: List[str]) -> str:
    """Format output as CSV"""
    lines = []
    
    # Header
    lines.append('"superprompt_idx","metaprompt_idx","superprompt_text","metaprompt_text","superduperprompt","completed","total","pending","completion_rate","is_complete","has_no_renders"')
    
    for (sp_idx, mp_idx), agg in aggregates:
        sp_text = superprompts[sp_idx] if sp_idx < len(superprompts) else ""
        
        if mp_idx >= 0 and mp_idx < len(metaprompts):
            mp_text = metaprompts[mp_idx]
            superduperprompt = sp_text.replace('{}', mp_text) if '{}' in sp_text else sp_text
        else:
            mp_text = ""
            superduperprompt = sp_text
        
        # Escape quotes in CSV fields
        sp_text = sp_text.replace('"', '""')
        mp_text = mp_text.replace('"', '""')
        superduperprompt = superduperprompt.replace('"', '""')
        
        lines.append(f'"{sp_idx}","{mp_idx}","{sp_text}","{mp_text}","{superduperprompt}",{agg.completed},{agg.total},{agg.pending},{agg.completion_rate:.4f},{agg.is_complete},{agg.is_unrendered}')
    
    return '\n'.join(lines)

def main():
    parser = argparse.ArgumentParser(
        description='Render Statistics Reporter for ComfyUI Batch Runner',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__
    )
    
    parser.add_argument('--state-file', required=True,
                       help='Path to state pickle file')
    parser.add_argument('--superprompts', default='superprompts.txt',
                       help='Superprompts file (default: superprompts.txt)')
    parser.add_argument('--metaprompts', default='metaprompts.txt',
                       help='Metaprompts file (default: metaprompts.txt)')
    parser.add_argument('--format', choices=['table', 'csv'], default='table',
                       help='Output format (default: table)')
    parser.add_argument('--output', help='Write output to file instead of stdout')
    parser.add_argument('--no-color', action='store_true',
                       help='Disable ANSI color codes in table output')
    parser.add_argument('--combinations-with-no-renders', action='store_true',
                       help='Show only combinations with 0 completed renders')
    parser.add_argument('--combinations-with-all-renders', action='store_true',
                       help='Show only fully completed combinations')
    parser.add_argument('--completion-below', type=float,
                       help='Show combinations with completion rate < N (0.0-1.0)')
    parser.add_argument('--superprompt-idx', type=str,
                       help='Filter by superprompt index (e.g., "0,3,5-10")')
    parser.add_argument('--metaprompt-idx', type=str,
                       help='Filter by metaprompt index (e.g., "0,3,5-10")')
    parser.add_argument('--group-by', choices=['superprompt', 'metaprompt', 'superduperprompt'],
                       default='superduperprompt',
                       help='Group results (default: superduperprompt)')
    
    args = parser.parse_args()
    
    # Validate completion-below
    if args.completion_below is not None and (args.completion_below < 0 or args.completion_below > 1):
        print("Error: --completion-below must be between 0 and 1")
        sys.exit(1)
    
    # Parse index filters
    if args.superprompt_idx:
        args.superprompt_idx = parse_index_range(args.superprompt_idx)
    if args.metaprompt_idx:
        args.metaprompt_idx = parse_index_range(args.metaprompt_idx)
    
    # Load state file
    state_path = Path(args.state_file)
    state = load_state_file(state_path)
    
    # Load prompt files
    superprompts = load_prompt_file(Path(args.superprompts))
    metaprompts = load_prompt_file(Path(args.metaprompts))
    
    # Calculate summary statistics
    total_combinations = len(state)
    completed = sum(1 for c in state if c.get('status') == 'completed')
    pending = sum(1 for c in state if c.get('status') == 'pending')
    rendering = sum(1 for c in state if c.get('status') == 'rendering')
    
    # Determine repetitions per combo (from first combo)
    repetitions_per_combo = 0
    if state:
        # Find max repetition values
        max_s_rep = max((c.get('superprompt_repetition', 0) for c in state), default=0)
        max_m_rep = max((c.get('metaprompt_repetition', 0) for c in state), default=0)
        repetitions_per_combo = (max_s_rep + 1) * (max_m_rep + 1)
    
    # Aggregate by superduperprompt
    aggregates = aggregate_by_superduperprompt(state)
    
    # Apply filters
    filtered_aggregates = apply_filters(list(aggregates.items()), args)
    
    summary = {
        'state_file': args.state_file,
        'total_combinations': total_combinations,
        'completed': completed,
        'pending': pending,
        'rendering': rendering,
        'superprompt_count': len(superprompts) if superprompts else len(set(c['superprompt_idx'] for c in state)),
        'metaprompt_count': len(metaprompts) if metaprompts else len(set(c.get('metaprompt_idx', -1) for c in state if c.get('metaprompt_idx', -1) >= 0)),
        'repetitions_per_combo': repetitions_per_combo,
        'total_combos_count': len(aggregates),
        'filter_active': (args.combinations_with_no_renders or args.combinations_with_all_renders or 
                         args.completion_below is not None or args.superprompt_idx or args.metaprompt_idx)
    }
    
    # Determine if color should be used
    use_color = (not args.no_color and args.format == 'table' and 
                 sys.stdout.isatty() and args.output is None)
    
    # Generate output
    if args.format == 'csv':
        output = format_csv(filtered_aggregates, summary, superprompts, metaprompts)
    else:  # table
        output = format_table(filtered_aggregates, summary, superprompts, metaprompts, 
                              args.group_by, use_color)
    
    # Write output
    if args.output:
        try:
            with open(args.output, 'w', encoding='utf-8') as f:
                f.write(output)
            print(f"Report saved to: {args.output}")
        except Exception as e:
            print(f"Error writing to {args.output}: {e}")
            sys.exit(1)
    else:
        print(output)

if __name__ == "__main__":
    main()