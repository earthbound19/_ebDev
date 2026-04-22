#!/usr/bin/env python3
"""
SCRIPT: extract_prompts_from_pngs.py
VERSION: 1.0.2

DESCRIPTION:
    Extracts unique full prompts from all PNGs in a directory tree and saves to a text file,
    one prompt per line, deduplicated.
    
    Useful for:
        - Recovering orphans to see what prompts they contain
        - Building a superduperprompts file from existing images
        - Auditing what prompts are in a curated collection

USAGE:
    Run with the following switches:
    - REQUIRED --curated-dir the location of images
    - OPTIONAL --output filename_to_write_prompts_to.txt. If omitted,
      defautls to extracted_prompts.txt
    For example:
    python path_to/extract_prompts_from_pngs.py --curated-dir ./kept_images --output prompts.txt
"""

import argparse
import json
import sys
from pathlib import Path
from PIL import Image

def extract_prompt_from_png(png_path):
    """Extract positive prompt from PNG metadata."""
    try:
        with Image.open(png_path) as img:
            metadata = img.text
            if 'prompt' not in metadata:
                return None
            
            workflow = json.loads(metadata['prompt'])
            
            for node_id, node_data in workflow.items():
                if node_data.get('class_type') == 'CLIPTextEncode':
                    title = node_data.get('_meta', {}).get('title', '')
                    if 'Prompt Positive' in title:
                        return node_data.get('inputs', {}).get('text', '')
            
            # Fallback
            for node_id, node_data in workflow.items():
                if node_data.get('class_type') == 'CLIPTextEncode':
                    title = node_data.get('_meta', {}).get('title', '').lower()
                    if 'positive' in title:
                        return node_data.get('inputs', {}).get('text', '')
            
            return None
    except Exception as e:
        print(f"Warning: Could not read {png_path.name}: {e}")
        return None

def main():
    parser = argparse.ArgumentParser(description='Extract unique prompts from PNG files')
    parser.add_argument('--curated-dir', required=True, help='Directory containing PNGs')
    parser.add_argument('--output', default='extracted_prompts.txt', help='Output file (default: extracted_prompts.txt)')
    
    args = parser.parse_args()
    
    curated_path = Path(args.curated_dir)
    if not curated_path.exists():
        print(f"Error: Directory not found: {curated_path}")
        sys.exit(1)
    
    png_files = list(curated_path.rglob("*.png"))
    print(f"Found {len(png_files)} PNGs")
    
    prompts = set()
    failed = 0
    
    for png_path in png_files:
        prompt = extract_prompt_from_png(png_path)
        if prompt:
            prompts.add(prompt)
        else:
            failed += 1
    
    print(f"Extracted {len(prompts)} unique prompts ({failed} PNGs failed)")
    
    # Convert to sorted list for consistent output
    sorted_prompts = sorted(prompts)
    
    with open(args.output, 'w', encoding='utf-8') as f:
        for prompt in sorted_prompts:
            f.write(prompt + '\n')
    
    print(f"Saved to: {args.output}")

if __name__ == "__main__":
    main()