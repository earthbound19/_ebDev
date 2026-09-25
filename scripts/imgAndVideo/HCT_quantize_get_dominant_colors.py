# DESCRIPTION
# HCT Space Dominant Color Extractor (using Coloraide)
# Quantizes images in HCT color space to extract dominant colors with
# configurable perceptual weighting and adaptive extreme detection.
# Loads an image, converts it from sRGB to HCT color space, performs
# clustering on the HCT values to find representative colors,
# and outputs cluster centers in both sRGB hex codes and HCT value format.
#
# Why HCT for quantization?
# - Hue (0-360): Perceptual hue from CAM16 (circular)
# - Chroma (0-145): Perceptual colorfulness/saturation from CAM16
# - Tone (0-100): Perceptual lightness from CIELAB D65
#
# HCT provides a more perceptually informed representation than RGB clustering,
# meaning the extracted colors will better represent what humans perceive
# as the "dominant" colors in an image. This implementation uses the proper
# HCT color space from Coloraide (CAM16 hue/chroma + CIELAB tone).
#
# PERCEPTUAL WEIGHTING SYSTEM
# The script includes a weighting system that lets users control
# which perceptual dimensions (hue, chroma, tone) influence the result.
# When all weights = 1.0, each perceptual dimension has EQUAL total influence:
# - Hue is represented by 2 features (sin, cos) and each gets weight 0.5
# - Chroma is 1 feature and gets weight 1.0
# - Tone is 1 feature and gets weight 1.0
# Total influence: Hue=1.0, Chroma=1.0, Tone=1.0
#
# Users can adjust weights via:
#   - Preset modes (hue-focused, chroma-focused, tone-focused, color-focused, pastel-bias, high-impact, balanced)
#   - Manual weight overrides for hue, chroma, and tone individually
#
# ADAPTIVE EXTREME DETECTION
# Standard k-means clustering averages colors within each cluster, which can dilute
# rare but perceptually important colors (like a small bright flower in a large dark scene).
# When enabled with --capture-extremes, the script uses a multi-stage approach:
#
#   1. Analyzes the distribution of chroma and tone values in the image
#   2. Dynamically calculates percentile thresholds based on perceptual weights
#      (emphasized dimensions use stricter thresholds, de-emphasized use looser)
#   3. Separates pixels into "extreme" (high/low chroma, high/low tone) and "normal" populations
#   4. Also identifies rare hues (hue bins with fewer than the threshold percentage of pixels)
#   5. Clusters extreme and normal populations separately
#   6. Combines results to create a palette that includes both statistical
#      dominant colors and perceptually extreme colors
#
# The extreme ratio (what percentage of the palette comes from extreme pixels)
# adapts automatically based on the perceptual weights - more emphasis on
# chroma or tone results in more extreme colors in the final palette.
#
# AUTO PRESET (HIERARCHICAL CLUSTERING)
# The --preset auto mode uses hierarchical clustering to discover natural
# perceptual groups in the image's HCT distribution. This data-driven approach:
#
#   1. Uses hybrid sampling (random + grid) for efficient O(n^3) complexity
#   2. Uses Ward's linkage to build a dendrogram of color distances in HCT space
#   3. Finds natural cut points where merge distances show significant gaps
#   4. Discovers the number of perceptual groups present in the image
#   5. Allocates at least 1 color per discovered group (--numbercolors sets minimum)
#   6. Warns when allocation may under-represent small but diverse groups
#   7. Notifies when actual output colors exceed requested count
#   8. Outputs group IDs with each color for meta-processing
#   9. Caches dendrograms to disk for faster subsequent runs
#
# When using --preset auto, you can also specify --weight-preset to apply any preset
# within the discovered groups (e.g., --preset auto --weight-preset high-impact).
# Alternatively, use individual weight flags (--hue-weight, etc.) for custom weights.
#
# This mode respects the inherent structure of the image's color distribution
# and may output more colors than requested. For exact color counts, use other presets
# such as balanced or chroma-focused.
#
# OUTPUT FORMATS
# Console output can be toggled between:
#   - hex: Shows hex codes with HCT values in parentheses
#   - hct: Shows HCT values with hex codes in parentheses
#
# File output (always .hexplt extension) contains both representations and group IDs:
#   #ff5733  (H:245.3, C:42.1, T:78.5) [group 1]
#   #4a90e2  (H:215.7, C:38.4, T:55.2) [group 2]
#
# This dual format maintains compatibility with any script that reads
# hex colors from .hexplt files while providing full HCT context and
# group information for meta-processing.
#
# AUTO-OUTPUT FILENAME GENERATION
# When using --auto-output (-a), filenames are generated with the pattern:
#   [basename]_[preset]_n[colors]_h[weight]c[weight]t[weight][_extremes].hexplt
# For --preset auto, the preset name appears as:
#   - "auto" for balanced weights
#   - "auto-presetname" when using --weight-preset or weights matching a preset
#   - "auto-custom" for non-matching custom weights
#
# Examples:
#   beach_sunset_chroma-focused_n05_h07_c20_t08.hexplt
#   beach_sunset_chroma-focused_n05_h07_c20_t08_extremes.hexplt
#   mountains_auto_n08_h10_c10_t10.hexplt
#   mountains_auto-high-impact_n08_h08_c18_t18.hexplt
#   portrait_auto-custom_n01_h15_c08_t12.hexplt
#
# Written nearly entirely by a Large Language Model, deepseek, with human
# guidance in features and fixes.
#
# DEPENDENCIES
# pip install Pillow numpy scikit-learn coloraide scipy
#
# Required versions:
# - Pillow>=9.0.0
# - numpy>=1.21.0
# - scikit-learn>=1.0.0
# - scipy>=1.7.0 (for hierarchical clustering)
# - coloraide>=2.2.0
#
# USAGE
# python HCT_quantize_get_dominant_colors.py --input IMAGE_FILE [--numbercolors N] 
#                                           [--output FILE | --auto-output]
#                                           [--output-format {hex,hct}]
#                                           [--cores PERCENT]
#                                           [--preset PRESET | --hue-weight FLOAT --chroma-weight FLOAT --tone-weight FLOAT]
#                                           [--capture-extremes]
#                                           [--auto-samples N] [--randomsamplepercent FLOAT]
#                                           [--weight-preset PRESET]
#                                           [--no-cache]
#
# Examples:
#   # Basic usage - balanced weights, 36 colors, auto-generated output file
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg
#
#   # Specify number of colors
#   python HCT_quantize_get_dominant_colors.py -i image.png -n 5
#
#   # Explicit output file path
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg -n 3 -o colors.hexplt
#
#   # Console output in HCT format instead of hex
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg -f hct
#
#   # Chroma-focused preset with auto-generated output
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg --preset chroma-focused -a
#
#   # High-impact preset combined with extreme detection
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg --preset high-impact --capture-extremes -a
#
#   # Auto preset - discovers natural groups, outputs at least 1 color per group
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg --preset auto -n 12
#
#   # Auto preset with high-impact weighting within each discovered group
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg --preset auto --weight-preset high-impact -a
#
#   # Auto preset with custom sample size for group discovery (default: 54000)
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg --preset auto --auto-samples 100000
#
#   # Auto preset with custom weights within groups
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg --preset auto --chroma-weight 2.0 -a
#
#   # Auto preset with caching disabled (force recompute)
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg --preset auto --no-cache
#
#   # Manual weights (no preset) - custom emphasis on hue and chroma
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg --hue-weight 2.0 --chroma-weight 0.5 -a
#
#   # Adaptive extreme detection (separates rare/vibrant colors into own clusters)
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg --capture-extremes
#
#   # Sample pixels for faster processing on very large images
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg -s
#
#   # Reproduce random sampling and clustering exactly
#   python HCT_quantize_get_dominant_colors.py -i photo.jpg --random-seed 1234
#
#   # Show this help message
#   python HCT_quantize_get_dominant_colors.py --help
#
# Short options:
#   -i : --input
#   -n : --numbercolors
#   -o : --output
#   -a : --auto-output
#   -f : --output-format
#   -s : --sample-pixels
#   -r : --randomsamplepercent
#
# NOTES
# - If --numbercolors is omitted, defaults to 36
# - Console output format can be hex or hct, but file output always includes both
# - File output always uses .hexplt extension for compatibility with existing tools
# - Preset modes and manual weights are mutually exclusive (auto preset is exception)
# - Auto preset (--preset auto) can be combined with --weight-preset or custom weights
# - Explicit output (-o) and auto-output (-a) are mutually exclusive
# - The script uses K-means++ initialization for better cluster quality
# - Hue is treated as a circular coordinate for accurate clustering via sin/cos encoding
# - Processing time increases with image size and number of colors requested
# - Use --cores to control CPU usage (0.0-1.0, default: 0.75)
# - By default, all pixels are processed for maximum accuracy. For very large images
#   (e.g., 4K+), use -s to sample up to 1.33M pixels for faster performance.
# - Adaptive extreme detection (--capture-extremes) adds processing time but may capture
#   outlier colors at perceptual extremes: most/least vibrant (chroma), most/least bright (tone),
#   or hue bins that are sparsely represented in the image (bottom 10% by bin population)
# - Auto preset (--preset auto) uses hierarchical clustering to discover natural perceptual groups
#   The number of output colors is determined by the natural groups (at least 1 per group).
#   The --numbercolors value is treated as a minimum; actual output may be larger.
#   For exact color counts, use standard presets like balanced or chroma-focused.
# - Auto preset uses hybrid sampling (random + grid) for group discovery.
#   Adjust sample size with --auto-samples (default: 54000) and random percentage with -r (default: 0.81).
# - Auto preset caches dendrograms in .color_quantize_cache/ directory next to the source image.
#   Use --no-cache to force recomputation.
# - Auto preset ignores --capture-extremes (grouping is data-driven)
# - --random-seed controls random pixel sampling and k-means initialization for reproducible runs
# - Palette output includes population percentage, within-cluster spread, and selection reason

# CODE
# Script version
# TO DO
# - Oklch variant: it may have less purple bias (HCT has that); maybe better hue linearity and uniformity. It may subtly cluster colors differently near the boundary of what sRGB (a typical monitor) can display. Although some sources argue HCT has better overal perceptual uniformity for predicting color differences; Oklch gives cleaner hue behavior (especially for blues/purples), while HCT might feel more "balanced" overall in how it perceives differences across all colors.
# - Oklab (Cartesian) variant: it may give a fundamentally different "feel" - more even-handed across all colors, potentially less vibrant palettes, but more "honest" about the distribution.

SCRIPT_VERSION = "4.3.0"

import argparse
import sys
import os
import numpy as np
from PIL import Image
from coloraide import Color
from coloraide.everything import ColorAll
from sklearn.cluster import KMeans
from multiprocessing import Pool, cpu_count
import warnings
import time
import re
import pickle
from pathlib import Path

# For hierarchical clustering in auto preset
from scipy.spatial.distance import pdist
from scipy.cluster.hierarchy import linkage, fcluster

# Suppress sklearn convergence warnings for large images
warnings.filterwarnings('ignore', category=UserWarning)

def get_cache_dir():
    """Get cache directory in user's Documents folder."""
    docs = Path.home() / "Documents"
    cache_dir = docs / ".color_quantize_cache"
    cache_dir.mkdir(parents=True, exist_ok=True)
    return cache_dir

# Create a Color class with HCT pre-registered
HCTColor = ColorAll

class WeightedKMeans(KMeans):
    """
    KMeans with per-feature weights for balanced or custom influence.
    Features are scaled before clustering to control their relative importance.
    """
    def __init__(self, feature_weights=None, **kwargs):
        super().__init__(**kwargs)
        self.feature_weights = feature_weights
    
    def fit(self, X, y=None, sample_weight=None):
        if self.feature_weights is not None:
            self.n_features_original_ = X.shape[1]
            self.X_scale_factor_ = self.feature_weights
            X = X * self.feature_weights
        return super().fit(X, y, sample_weight=sample_weight)
    
    def predict(self, X):
        if hasattr(self, 'X_scale_factor_'):
            X = X * self.X_scale_factor_
        return super().predict(X)
    
    @property
    def cluster_centers_original(self):
        """Return cluster centers in original (unweighted) feature space"""
        if hasattr(self, 'X_scale_factor_'):
            return self.cluster_centers_ / self.X_scale_factor_
        return self.cluster_centers_

def process_chunk_rgb_to_hct(args):
    """Process a chunk of RGB pixels and return HCT values."""
    chunk_data = args
    
    # Convert to float and normalize to 0-1
    chunk_float = chunk_data.astype(np.float32) / 255.0
    pixels = chunk_float.reshape(-1, 3)
    
    # Convert each pixel to HCT
    hct_values = []
    for pixel in pixels:
        try:
            color = HCTColor('srgb', pixel.tolist())
            color_hct = color.convert('hct')
            h, c, t = color_hct.coords()
            hct_values.append([h, c, t])
        except Exception:
            # Preserve conversion failures as invalid values so they can be tracked
            # and filtered without silently turning them into black pixels.
            hct_values.append([np.nan, np.nan, np.nan])
    
    return np.array(hct_values, dtype=np.float32)

def calculate_core_count(percent):
    """Calculate number of cores to use based on percentage."""
    total_cores = cpu_count()
    
    if percent <= 0:
        return 1
    elif percent >= 1:
        return total_cores
    
    core_count = max(1, int(round(total_cores * percent)))
    return core_count

def calculate_feature_weights(hue_weight=1.0, chroma_weight=1.0, tone_weight=1.0):
    """
    Convert user-friendly perceptual weights to actual feature weights.
    
    The transformation ensures that when all weights are 1.0, each perceptual
    dimension (hue, chroma, tone) has EQUAL total influence on clustering.
    
    How it works:
    - Hue is represented by 2 features (sin, cos)
    - To make total hue influence = 1.0, each hue feature gets weight = hue_weight/2
    - Chroma and tone are each 1 feature, so they get full weight
    """
    # Each hue feature gets half the user weight because there are two of them
    hue_feature_weight = hue_weight / 2.0
    
    return np.array([
        hue_feature_weight,  # hue_sin
        hue_feature_weight,  # hue_cos  
        chroma_weight,       # chroma
        tone_weight          # tone
    ])

def create_features(pixels_hct, return_valid_indices=False):
    """
    Convert HCT pixels to feature space for clustering.

    When return_valid_indices is True, also return the indices of the input
    rows represented by the returned features. This keeps feature rows aligned
    with source pixels when invalid values are filtered.
    """
    pixels_hct = np.asarray(pixels_hct)
    valid_mask = np.all(np.isfinite(pixels_hct), axis=1)
    valid_indices = np.flatnonzero(valid_mask)

    if len(valid_indices) != len(pixels_hct):
        invalid_count = len(pixels_hct) - len(valid_indices)
        print(f"  Warning: Found {invalid_count} invalid HCT pixels, filtering...")
        pixels_hct = pixels_hct[valid_mask]

    if len(pixels_hct) == 0:
        raise ValueError("No valid pixels after filtering - all HCT values were invalid")

    hue_rad = np.radians(pixels_hct[:, 0])

    features = np.column_stack([
        np.sin(hue_rad),
        np.cos(hue_rad),
        pixels_hct[:, 1] / 145.0,
        pixels_hct[:, 2] / 100.0
    ])

    feature_mask = np.all(np.isfinite(features), axis=1)
    if not np.all(feature_mask):
        invalid_count = np.sum(~feature_mask)
        print(f"  Warning: Found {invalid_count} invalid feature rows, filtering...")
        features = features[feature_mask]
        valid_indices = valid_indices[feature_mask]

    if len(features) == 0:
        raise ValueError("No valid features after filtering - cannot proceed")

    if return_valid_indices:
        return features, valid_indices
    return features

def reconstruct_hct(centers_features):
    """Convert feature space centers back to HCT coordinates."""
    centers_hct = np.zeros((len(centers_features), 3))
    centers_hct[:, 0] = np.degrees(np.arctan2(centers_features[:, 0], centers_features[:, 1])) % 360
    centers_hct[:, 1] = centers_features[:, 2] * 145.0
    centers_hct[:, 2] = centers_features[:, 3] * 100.0
    centers_hct[:, 1] = np.clip(centers_hct[:, 1], 0, 145)
    centers_hct[:, 2] = np.clip(centers_hct[:, 2], 0, 100)
    return centers_hct

def analyze_kmeans_clusters(pixels_hct, kmeans, features, centers_hct, total_population_pixels=None, population_hct=None):
    """Return population and diversity metadata for k-means palette centers."""
    labels = kmeans.labels_
    n_clusters = len(centers_hct)
    populations = np.bincount(labels, minlength=n_clusters)
    metadata = []
    source_pixels = pixels_hct
    denominator = len(source_pixels) if total_population_pixels is None else total_population_pixels

    for i in range(n_clusters):
        cluster_pixels = source_pixels[labels == i]
        metadata.append({
            "population": int(populations[i]),
            "population_denominator": int(denominator),
            "diversity": float(measure_group_diversity(cluster_pixels)),
            "reason": "cluster-representative"
        })
    return metadata

def measure_group_diversity(group_pixels):
    """
    Measure internal diversity of a group in HCT space.
    Returns average Euclidean distance to centroid in feature space.
    """
    if len(group_pixels) < 2:
        return 0.0
    
    features = create_features(group_pixels)
    centroid = np.mean(features, axis=0)
    distances = np.linalg.norm(features - centroid, axis=1)
    return np.mean(distances)

def hybrid_sample(pixels_hct, total_pixels, target_samples, random_ratio=0.81, rng=None):
    """
    Hybrid sampling combining random and grid sampling.
    Returns sampled pixels as array.
    """
    if rng is None:
        rng = np.random.default_rng()

    n_random = int(target_samples * random_ratio)
    n_grid = target_samples - n_random
    
    # Grid sampling: regular stride through flattened array
    step = total_pixels // n_grid
    grid_indices = np.arange(0, total_pixels, step)[:n_grid]
    
    # Random sampling from remaining pixels
    remaining_mask = np.ones(total_pixels, dtype=bool)
    remaining_mask[grid_indices] = False
    remaining_indices = np.arange(total_pixels)[remaining_mask]
    random_indices = rng.choice(remaining_indices, n_random, replace=False)
    
    indices = np.sort(np.concatenate([grid_indices, random_indices]))
    return pixels_hct[indices]

def get_cache_filename(input_path, max_samples, random_ratio, random_seed=42):
    """Generate a descriptive cache filename in the global cache directory."""
    cache_dir = get_cache_dir()
    
    base = os.path.splitext(os.path.basename(input_path))[0]
    base = re.sub(r'[^\w\s.-]', '', base)
    base = base.replace(' ', '_')
    
    r_percent = int(round(random_ratio * 100))
    param_str = f"a{max_samples}_r{r_percent}_s{random_seed}"
    
    filename = f"{base}_{param_str}_dendrogram.pkl"
    return os.path.join(cache_dir, filename)

def get_hct_cache_path(input_path):
    """Generate cache path for HCT values in the global cache directory."""
    cache_dir = get_cache_dir()
    
    base = os.path.splitext(os.path.basename(input_path))[0]
    base = re.sub(r'[^\w\s.-]', '', base)
    base = base.replace(' ', '_')
    
    filename = f"{base}_hct_cache.pkl"
    return os.path.join(cache_dir, filename)

def debug_cache_paths(input_path, auto_samples, random_ratio, random_seed=42):
    """Print detailed cache file paths for debugging."""
    cache_dir = get_cache_dir()
    hct_cache = get_hct_cache_path(input_path)
    dendrogram_cache = os.path.join(cache_dir, get_cache_filename(input_path, auto_samples, random_ratio, random_seed))
    
    print(f"\n  DEBUG: Cache directory: {cache_dir}")
    print(f"  DEBUG: Expected HCT cache: {hct_cache}")
    print(f"  DEBUG: HCT cache exists: {os.path.exists(hct_cache)}")
    print(f"  DEBUG: Expected dendrogram cache: {dendrogram_cache}")
    print(f"  DEBUG: Dendrogram cache exists: {os.path.exists(dendrogram_cache)}")
    
    # List all cache files for comparison
    if os.path.exists(cache_dir):
        print(f"  DEBUG: All cache files in directory:")
        for f in os.listdir(cache_dir):
            if f.endswith('.pkl'):
                print(f"    - {f}")

def check_caches_exist(input_path, auto_samples, random_ratio, random_seed=42):
    """Check if both HCT and dendrogram caches exist for an image.
    Automatically deletes corrupted HCT caches."""
    hct_cache = get_hct_cache_path(input_path)
    dendrogram_cache = os.path.join(get_cache_dir(), get_cache_filename(input_path, auto_samples, random_ratio, random_seed))
    
    hct_exists = os.path.exists(hct_cache)
    dendro_exists = os.path.exists(dendrogram_cache)
    
    # Validate and clean HCT cache if corrupted
    if hct_exists:
        try:
            with open(hct_cache, 'rb') as f:
                hct_data = pickle.load(f)
            if not isinstance(hct_data, np.ndarray) or hct_data.ndim != 2 or hct_data.shape[1] != 3:
                print(f"  Warning: HCT cache has an invalid shape, deleting...")
                os.remove(hct_cache)
                hct_exists = False
        except Exception as e:
            print(f"  Warning: HCT cache corrupted ({e}), deleting...")
            os.remove(hct_cache)
            hct_exists = False
    
    return hct_exists, dendro_exists

def load_hct_from_cache(input_path):
    """Load HCT values directly from cache with validation."""
    cache_file = get_hct_cache_path(input_path)
    with open(cache_file, 'rb') as f:
        pixels_hct = pickle.load(f)
    
    # Preserve invalid rows so their positions remain aligned with the source image.
    # Feature creation will filter them when clustering.
    invalid_count = np.sum(~np.all(np.isfinite(pixels_hct), axis=1))
    if invalid_count:
        print(f"  Warning: HCT cache contains {invalid_count:,} invalid rows; they will be excluded from clustering")
    return pixels_hct

def load_or_convert_hct(pixels_rgb, input_path, cores_to_use, chunk_size, auto_samples=54000, random_ratio=0.81, random_seed=42):
    """
    Load cached HCT values or convert and cache.
    Returns pixels_hct array.
    """
    cache_file = get_hct_cache_path(input_path)
    dendrogram_cache = os.path.join(get_cache_dir(), get_cache_filename(input_path, auto_samples, random_ratio, random_seed))
    
    # Check for valid cache
    if os.path.exists(cache_file):
        print(f"  Loading cached HCT values from: {cache_file}")
        try:
            with open(cache_file, 'rb') as f:
                pixels_hct = pickle.load(f)
            
            if len(pixels_hct) != len(pixels_rgb):
                print(f"  Warning: HCT cache contains {len(pixels_hct):,} pixels but current image requires {len(pixels_rgb):,}; recomputing...")
                if os.path.exists(dendrogram_cache):
                    os.remove(dendrogram_cache)
                pixels_hct = None
            else:
                invalid_count = np.sum(~np.all(np.isfinite(pixels_hct), axis=1))
                if invalid_count:
                    print(f"  Loaded {len(pixels_hct):,} HCT values from cache ({invalid_count:,} invalid rows will be filtered during analysis)")
                else:
                    print(f"  Loaded {len(pixels_hct):,} valid HCT values from cache")
                return pixels_hct
        except Exception as e:
            print(f"  Warning: Failed to load HCT cache ({e}), recomputing...")
    
    # Cache invalid or missing - recompute
    print(f"  Converting {len(pixels_rgb):,} pixels to HCT space...")
    
    # Split pixels into chunks for parallel conversion
    chunks = []
    for i in range(0, len(pixels_rgb), chunk_size):
        chunk = pixels_rgb[i:i+chunk_size]
        chunks.append(chunk)
    
    all_hct = []
    with Pool(processes=cores_to_use) as pool:
        for i, result in enumerate(pool.imap(process_chunk_rgb_to_hct, chunks)):
            all_hct.append(result)
            if (i + 1) % max(1, len(chunks) // 10) == 0:
                pct = (i + 1) / len(chunks) * 100
                print(f"    Conversion: {pct:.0f}% complete", end='\r')
    
    print()  # New line after progress
    pixels_hct = np.vstack(all_hct)
    
    # Preserve row-for-pixel alignment in the cache. Invalid conversion rows
    # remain invalid and are filtered only when a feature array is created.
    invalid_count = np.sum(~np.all(np.isfinite(pixels_hct), axis=1))
    if invalid_count > 0:
        print(f"  Retaining {invalid_count:,} invalid conversion rows in cache so pixel indices remain aligned")
    pixels_hct_clean = pixels_hct
    
    # Cache the full image results
    try:
        os.makedirs(os.path.dirname(cache_file), exist_ok=True)
        with open(cache_file, 'wb') as f:
            pickle.dump(pixels_hct_clean, f)
        print(f"  Saved {len(pixels_hct_clean):,} HCT values to cache: {cache_file}")
    except Exception as e:
        print(f"  Warning: Failed to save HCT cache ({e})")
    
    # Also delete any existing dendrogram cache since pixel indices have changed
    dendrogram_cache = os.path.join(get_cache_dir(), get_cache_filename(input_path, auto_samples, random_ratio, random_seed))
    if os.path.exists(dendrogram_cache):
        print(f"  Deleting outdated dendrogram cache: {dendrogram_cache}")
        os.remove(dendrogram_cache)
    
    return pixels_hct_clean

def discover_natural_groups_cached(pixels_hct, input_path, max_samples=54000, random_ratio=0.81, use_cache=True, random_seed=42):
    """
    Estimate natural perceptual groups using hierarchical clustering.
    Sampled pixels are clustered, then every pixel is assigned to the nearest
    discovered group centroid so group populations represent the whole image.
    """
    total_pixels = len(pixels_hct)
    cache_dir = get_cache_dir()
    cache_file = os.path.join(cache_dir, get_cache_filename(input_path, max_samples, random_ratio, random_seed))

    if use_cache and os.path.exists(cache_file):
        print(f"  Loading cached dendrogram/group assignments from: {cache_file}")
        try:
            with open(cache_file, 'rb') as f:
                cache_data = pickle.load(f)
            all_labels = cache_data['all_labels']
            natural_groups = cache_data['natural_groups']
            cached_total_pixels = cache_data.get('total_pixels', 0)
            if cached_total_pixels != total_pixels or len(all_labels) != total_pixels:
                print(f"  Warning: Cached group assignments do not match current pixel count; recomputing...")
                os.remove(cache_file)
            else:
                print(f"  Loaded {natural_groups} groups from cache")
                return all_labels, natural_groups
        except Exception as e:
            print(f"  Warning: Failed to load cache ({e}), recomputing...")

    print(f"  Computing dendrogram (this may take a moment)...")
    rng = np.random.default_rng(random_seed)

    if total_pixels > max_samples:
        n_random = int(max_samples * random_ratio)
        n_grid = max_samples - n_random
        step = max(1, total_pixels // n_grid)
        grid_indices = np.arange(0, total_pixels, step)[:n_grid]
        remaining_mask = np.ones(total_pixels, dtype=bool)
        remaining_mask[grid_indices] = False
        remaining_indices = np.flatnonzero(remaining_mask)
        if n_random > len(remaining_indices):
            n_random = len(remaining_indices)
        random_indices = rng.choice(remaining_indices, n_random, replace=False)
        sample_indices = np.sort(np.concatenate([grid_indices, random_indices]))
        sampled = True
        original_sample_size = len(sample_indices)
        n_random_actual = len(random_indices)
        n_grid_actual = len(grid_indices)
    else:
        sample_indices = np.arange(total_pixels)
        sampled = False
        original_sample_size = total_pixels
        n_random_actual = 0
        n_grid_actual = 0

    sample = pixels_hct[sample_indices]
    features, valid_local_indices = create_features(sample, return_valid_indices=True)
    valid_sample_indices = sample_indices[valid_local_indices]
    final_sample_size = len(features)

    if final_sample_size < 2:
        raise ValueError(f"Only {final_sample_size} valid pixels found - cannot perform clustering")

    print(f"  Computing pairwise distances for {final_sample_size:,} sampled pixels...")
    distance_matrix = pdist(features, metric='euclidean')
    print(f"  Building dendrogram with Ward linkage...")
    linkage_matrix = linkage(distance_matrix, method='ward')

    merge_distances = linkage_matrix[:, 2]
    gap_sizes = np.diff(merge_distances)

    if len(gap_sizes) == 0:
        natural_groups = 1
        threshold = 0.0
        largest_gaps = []
    else:
        mean_gap = np.mean(gap_sizes)
        std_gap = np.std(gap_sizes)
        threshold = mean_gap + std_gap
        natural_groups = np.sum(gap_sizes > threshold) + 1
        largest_gap_indices = np.argsort(gap_sizes)[-min(5, len(gap_sizes)):][::-1]
        largest_gaps = [(int(i + 1), float(gap_sizes[i])) for i in largest_gap_indices]

    natural_groups = max(1, min(natural_groups, final_sample_size))

    if natural_groups == 1:
        cluster_labels = np.ones(final_sample_size, dtype=int)
    else:
        cut_distance = merge_distances[-(natural_groups - 1)]
        cluster_labels = fcluster(linkage_matrix, cut_distance, criterion='distance')

    # Compute a centroid for each discovered group, then assign every pixel
    # in the image to its nearest group. This turns the sampled dendrogram
    # into full-image group populations rather than leaving most pixels at 0.
    group_centers = []
    for group_id in range(1, natural_groups + 1):
        members = features[cluster_labels == group_id]
        if len(members) == 0:
            group_centers.append(np.zeros(features.shape[1], dtype=np.float32))
        else:
            group_centers.append(np.mean(members, axis=0))
    group_centers = np.vstack(group_centers)

    all_features = create_features(pixels_hct)
    # The cache requires a label for every valid pixel. Pixels that were invalid
    # in the HCT array are left at label 0.
    valid_all_indices = np.flatnonzero(np.all(np.isfinite(pixels_hct), axis=1))
    distances = np.sum((all_features[:, None, :] - group_centers[None, :, :]) ** 2, axis=2)
    nearest = np.argmin(distances, axis=1) + 1
    all_labels = np.zeros(total_pixels, dtype=int)
    all_labels[valid_all_indices] = nearest

    print(f"  Group-structure estimate: {natural_groups} groups; gap threshold {threshold:.6g}")
    if largest_gaps:
        print("  Largest dendrogram gap(s): " + ", ".join(f"merge {i}: {gap:.6g}" for i, gap in largest_gaps))
    if sampled:
        print(f"  (Used hybrid sampling: {n_random_actual} random + {n_grid_actual} grid = {original_sample_size} pixels)")

    if use_cache:
        try:
            os.makedirs(cache_dir, exist_ok=True)
            cache_data = {
                'all_labels': all_labels,
                'natural_groups': natural_groups,
                'max_samples': max_samples,
                'random_ratio': random_ratio,
                'random_seed': random_seed,
                'total_pixels': total_pixels
            }
            with open(cache_file, 'wb') as f:
                pickle.dump(cache_data, f)
            print(f"  Saved group assignments to cache: {cache_file}")
        except Exception as e:
            print(f"  Warning: Failed to save cache ({e})")

    return all_labels, natural_groups

def allocate_colors_from_groups(group_labels, pixels_hct, n_colors):
    """
    Allocate colors proportionally across natural groups.
    Returns list of (group_id, n_colors, group_pixels) for each group.
    """
    unique_groups = np.unique(group_labels)
    unique_groups = unique_groups[unique_groups > 0]
    group_sizes = [np.sum(group_labels == g) for g in unique_groups]
    total_pixels = np.sum(group_labels > 0)
    
    # Calculate group diversities for informative output
    group_diversities = []
    for g in unique_groups:
        group_pixels = pixels_hct[group_labels == g]
        group_diversities.append(measure_group_diversity(group_pixels))
    
    # Proportional allocation (minimum 1 color per group)
    allocations = []
    for size in group_sizes:
        n = max(1, int(n_colors * size / total_pixels))
        allocations.append(n)
    
    allocated = sum(allocations)
    
    # Adjust to match exact n_colors
    if allocated < n_colors:
        # Add extra colors to groups with highest diversity first
        shortage = n_colors - allocated
        diversity_indices = sorted(range(len(unique_groups)), 
                                   key=lambda i: group_diversities[i], reverse=True)
        for _ in range(shortage):
            idx = diversity_indices[_ % len(diversity_indices)]
            allocations[idx] += 1
    elif allocated > n_colors:
        # Remove from groups with lowest diversity that have > 1 allocation
        surplus = allocated - n_colors
        # Sort by diversity (lowest first) then size
        candidates = [(i, a, group_diversities[i], group_sizes[i]) 
                      for i, a in enumerate(allocations) if a > 1]
        candidates.sort(key=lambda x: (x[2], x[3]))
        for _ in range(min(surplus, len(candidates))):
            idx = candidates[_][0]
            allocations[idx] -= 1
    
    # Build result list
    result = []
    for i, g in enumerate(unique_groups):
        group_pixels = pixels_hct[group_labels == g]
        result.append({
            'group_id': int(g),
            'size': group_sizes[i],
            'size_pct': group_sizes[i] / total_pixels * 100,
            'diversity': group_diversities[i],
            'allocated': allocations[i],
            'pixels': group_pixels
        })
    
    return result

def extract_colors_from_groups(group_assignments, feature_weights, random_seed=42):
    """
    For each group, run weighted k-means to extract allocated number of colors.
    Returns array of HCT centers and list of corresponding group IDs.
    """
    all_centers = []
    all_group_ids = []
    all_metadata = []
    total_groups = len(group_assignments)
    
    print(f"  Extracting colors from {total_groups} groups...")
    
    for idx, group in enumerate(group_assignments):
        n = group['allocated']
        group_pixels = group['pixels']
        group_id = group['group_id']
        group_pct = group['size_pct']
        
        print(f"    Group {group_id}: {group_pct:.1f}% of image, extracting {n} color(s) ({idx+1}/{total_groups})")
        
        if len(group_pixels) == 0:
            print(f"      Skipping (no pixels)")
            continue
        
        if len(group_pixels) < n:
            # Not enough pixels - take what we can
            original_n = n
            n = len(group_pixels)
            print(f"      Not enough pixels: requested {original_n}, using {n}")
        
        if n == 0:
            continue
        
        # Show progress for large extractions
        if n > 20:
            print(f"      Running k-means with {n} clusters...")
            start_time = time.time()
        
        features = create_features(group_pixels)
        kmeans = WeightedKMeans(
            feature_weights=feature_weights,
            n_clusters=n,
            init='k-means++',
            n_init=10,
            max_iter=300,
            random_state=random_seed
        )
        kmeans.fit(features)
        centers = reconstruct_hct(kmeans.cluster_centers_original)
        populations = np.bincount(kmeans.labels_, minlength=n)
        diversities = [measure_group_diversity(group_pixels[kmeans.labels_ == i]) for i in range(n)]
        
        if n > 20:
            elapsed = time.time() - start_time
            print(f"      Completed in {elapsed:.1f} seconds")
        
        # Append each center with its group ID
        for _ in range(len(centers)):
            all_centers.append(centers[_])
            all_group_ids.append(group_id)
            all_metadata.append({
                "population": int(populations[_]),
                "population_denominator": len(pixels_hct),
                "diversity": float(diversities[_]),
                "reason": "group-representative",
                "group_population_pct": float(group_pct)
            })
    
    if not all_centers:
        return np.array([]), [], []
    
    print(f"  Total colors extracted: {len(all_centers)}")
    return np.vstack(all_centers), all_group_ids, all_metadata

def check_allocation_warnings(group_assignments, n_colors):
    """
    Generate warnings for potential allocation issues.
    Returns list of warning strings.
    """
    warnings_list = []
    
    # Check for groups with 0 allocation
    zero_allocation = [g for g in group_assignments if g['allocated'] == 0]
    if zero_allocation:
        for g in zero_allocation:
            warnings_list.append(
                f"Group {g['group_id']} ({g['size_pct']:.1f}% of image) will not appear in palette"
            )
    
    # Check for groups with high diversity but low allocation
    for g in group_assignments:
        if g['allocated'] == 1 and g['diversity'] > 0.08:
            warnings_list.append(
                f"Group {g['group_id']} has high diversity ({g['diversity']:.3f}) but only gets 1 color"
            )
    
    # Suggest better n_colors
    min_possible = len(group_assignments)
    if n_colors < min_possible:
        warnings_list.append(
            f"Requested {n_colors} colors but {min_possible} natural groups exist. "
            f"Consider increasing to at least {min_possible}."
        )
    
    return warnings_list

def extract_colors_with_adaptive_extremes(pixels_hct, n_colors, preset_weights, feature_weights, extreme_ratio=0.3, return_metadata=False, random_seed=42):
    """
    Extract colors using preset-aware adaptive extreme detection.
    
    This multi-stage approach first identifies extreme pixels based on
    adaptive thresholds, then clusters extreme and normal populations separately
    to ensure the final palette includes both statistical dominant colors
    and perceptually extreme colors.
    
    Args:
        pixels_hct: array of HCT values
        n_colors: total number of colors desired
        preset_weights: dict with 'hue', 'chroma', 'tone' perceptual weights
        feature_weights: array of actual feature weights for clustering
        extreme_ratio: base ratio of extreme to dominant colors (0.0-1.0)
    
    Returns:
        combined_colors: array of HCT values for final palette
    """
    hue_w = preset_weights['hue']
    chroma_w = preset_weights['chroma']
    tone_w = preset_weights['tone']
    
    # STEP 1: Calculate adaptive thresholds based on weights
    # For emphasized dimensions, use stricter thresholds (smaller percentile)
    # For de-emphasized dimensions, use looser thresholds (larger percentile)
    base_percentile = 10  # Start with 10th/90th percentile as baseline
    
    # Chroma threshold adapts to chroma weight
    if chroma_w > 1.1:
        # Emphasized chroma - want truly extreme chroma values
        chroma_threshold = base_percentile / chroma_w
    elif chroma_w < 0.9:
        # De-emphasized chroma - cast wider net
        chroma_threshold = base_percentile * (1.0 + (0.9 - chroma_w))
    else:
        chroma_threshold = base_percentile
    
    # Tone threshold adapts to tone weight
    if tone_w > 1.1:
        tone_threshold = base_percentile / tone_w
    elif tone_w < 0.9:
        tone_threshold = base_percentile * (1.0 + (0.9 - tone_w))
    else:
        tone_threshold = base_percentile
    
    # STEP 2: Calculate adaptive extreme ratio based on weights
    # More emphasis = higher proportion of extreme colors
    avg_emphasis = (chroma_w + tone_w) / 2
    adaptive_extreme_ratio = extreme_ratio * avg_emphasis
    adaptive_extreme_ratio = min(0.5, max(0.1, adaptive_extreme_ratio))  # Clamp between 10-50%
    
    n_extreme = max(1, int(n_colors * adaptive_extreme_ratio))
    n_dominant = n_colors - n_extreme
    
    print(f"  Adaptive extreme detection:")
    print(f"    Chroma threshold: top/bottom {chroma_threshold:.1f}%")
    print(f"    Tone threshold: top/bottom {tone_threshold:.1f}%")
    print(f"    Extreme colors: {n_extreme} ({adaptive_extreme_ratio*100:.0f}% of palette)")
    
    # STEP 3: Identify extreme pixels using adaptive thresholds
    chroma_high = np.percentile(pixels_hct[:, 1], 100 - chroma_threshold)
    chroma_low = np.percentile(pixels_hct[:, 1], chroma_threshold)
    tone_high = np.percentile(pixels_hct[:, 2], 100 - tone_threshold)
    tone_low = np.percentile(pixels_hct[:, 2], tone_threshold)
    
    extreme_mask = (
        (pixels_hct[:, 1] >= chroma_high) |  # High chroma extremes
        (pixels_hct[:, 1] <= chroma_low) |   # Low chroma extremes
        (pixels_hct[:, 2] >= tone_high) |    # High tone extremes
        (pixels_hct[:, 2] <= tone_low)       # Low tone extremes
    )
    
    # Also capture rare hues (bottom 10% of hue bins)
    # Use the same base_percentile threshold for consistency
    hue_threshold_percentile = base_percentile
    hue_hist, hue_bins = np.histogram(pixels_hct[:, 0], bins=36)  # 10 degree bins
    threshold_count = len(pixels_hct) * (hue_threshold_percentile / 100)
    rare_hue_bins = np.where(hue_hist < threshold_count)[0]
    
    if len(rare_hue_bins) > 0:
        rare_hue_mask = np.zeros(len(pixels_hct), dtype=bool)
        for bin_idx in rare_hue_bins:
            bin_min = hue_bins[bin_idx]
            bin_max = hue_bins[bin_idx + 1]
            rare_hue_mask |= (pixels_hct[:, 0] >= bin_min) & (pixels_hct[:, 0] < bin_max)
        extreme_mask |= rare_hue_mask
        print(f"    Also capturing rare hues (bins with <{hue_threshold_percentile:.0f}% of pixels)")
    
    # STEP 4: Separate extreme and non-extreme pixels
    extreme_pixels = pixels_hct[extreme_mask]
    normal_pixels = pixels_hct[~extreme_mask]
    
    extreme_percent = len(extreme_pixels) / len(pixels_hct) * 100
    print(f"    Found {len(extreme_pixels):,} extreme pixels ({extreme_percent:.1f}% of total)")
    
    # STEP 5: Cluster extremes and normals separately
    # Cluster extreme pixels
    if len(extreme_pixels) >= n_extreme and n_extreme > 0:
        extreme_features = create_features(extreme_pixels)
        extreme_kmeans = WeightedKMeans(
            feature_weights=feature_weights,
            n_clusters=n_extreme,
            init='k-means++',
            n_init=10,
            max_iter=300,
            random_state=random_seed
        )
        extreme_kmeans.fit(extreme_features)
        extreme_centers = reconstruct_hct(extreme_kmeans.cluster_centers_original)
        extreme_labels = extreme_kmeans.labels_
        extreme_populations = np.bincount(extreme_labels, minlength=n_extreme)
        extreme_diversities = [measure_group_diversity(extreme_pixels[extreme_labels == i]) for i in range(n_extreme)]
    else:
        # Fallback if not enough extreme pixels
        extreme_centers = np.array([])
        extreme_labels = np.array([], dtype=int)
        extreme_populations = np.array([], dtype=int)
        extreme_diversities = []
        n_dominant = n_colors
        print(f"    Not enough extreme pixels, using all for dominant clustering")
    
    # Cluster normal pixels (or all if not enough extremes)
    if len(normal_pixels) >= n_dominant and n_dominant > 0:
        normal_features = create_features(normal_pixels)
        normal_kmeans = WeightedKMeans(
            feature_weights=feature_weights,
            n_clusters=n_dominant,
            init='k-means++',
            n_init=10,
            max_iter=300,
            random_state=random_seed
        )
        normal_kmeans.fit(normal_features)
        normal_centers = reconstruct_hct(normal_kmeans.cluster_centers_original)
        normal_labels = normal_kmeans.labels_
        normal_populations = np.bincount(normal_labels, minlength=n_dominant)
        normal_diversities = [measure_group_diversity(normal_pixels[normal_labels == i]) for i in range(n_dominant)]
    else:
        # Fallback: cluster all pixels
        print(f"    Falling back to standard clustering on all pixels")
        all_features = create_features(pixels_hct)
        all_kmeans = WeightedKMeans(
            feature_weights=feature_weights,
            n_clusters=n_colors,
            init='k-means++',
            n_init=10,
            max_iter=300,
            random_state=random_seed
        )
        all_kmeans.fit(all_features)
        fallback_centers = reconstruct_hct(all_kmeans.cluster_centers_original)
        if return_metadata:
            populations = np.bincount(all_kmeans.labels_, minlength=n_colors)
            metadata = [{"population": int(populations[i]), "diversity": measure_group_diversity(pixels_hct[all_kmeans.labels_ == i]), "reason": "cluster-representative"} for i in range(n_colors)]
            return fallback_centers, metadata
        return fallback_centers
    
    # STEP 6: Combine and return
    if len(extreme_centers) > 0:
        combined = np.vstack([normal_centers, extreme_centers])
        if return_metadata:
            metadata = []
            for i in range(len(normal_centers)):
                metadata.append({
                    "population": int(normal_populations[i]),
                    "diversity": float(normal_diversities[i]),
                    "reason": "dominant-population"
                })
            for i in range(len(extreme_centers)):
                metadata.append({
                    "population": int(extreme_populations[i]),
                    "diversity": float(extreme_diversities[i]),
                    "reason": "perceptual-extreme"
                })
            return combined, metadata
        return combined
    else:
        if return_metadata:
            metadata = [{
                "population": int(normal_populations[i]),
                "diversity": float(normal_diversities[i]),
                "reason": "dominant-population"
            } for i in range(len(normal_centers))]
            return normal_centers, metadata
        return normal_centers

def generate_output_filename(input_path, preset, hue_w, chroma_w, tone_w, n_colors, capture_extremes):
    """
    Generate a descriptive output filename based on input, preset, weights, color count,
    and whether extreme capture is enabled.
    Format: [basename]_[preset]_n[colors]_h[weight]c[weight]t[weight][_extremes].hexplt
    Weights are multiplied by 10 and zero-padded to 2 digits.
    """
    # Get base filename without extension
    base = os.path.splitext(os.path.basename(input_path))[0]
    
    # Clean up filename (remove problematic characters)
    base = re.sub(r'[^\w\s.-]', '', base)
    base = base.replace(' ', '_')
    
    # Build filename parts
    name_parts = [base]
    
    # Add preset if used
    if preset:
        name_parts.append(preset)
    
    # Add number of colors (zero-padded to 2 digits)
    name_parts.append(f"n{n_colors:02d}")
    
    # Add weights (format: h05_c20_t08 for 0.5, 2.0, 0.8)
    h_str = f"h{int(round(hue_w * 10)):02d}"
    c_str = f"c{int(round(chroma_w * 10)):02d}"
    t_str = f"t{int(round(tone_w * 10)):02d}"
    name_parts.append(f"{h_str}{c_str}{t_str}")
    
    # Add extremes indicator if enabled
    if capture_extremes:
        name_parts.append("extremes")
    
    # Join with underscores and add extension
    filename = "_".join(name_parts) + ".hexplt"
    return filename

def format_palette_reason(reason):
    """Convert internal selection reasons to concise output labels."""
    return {
        "cluster-representative": "cluster-representative",
        "dominant-population": "dominant-population",
        "perceptual-extreme": "perceptual-extreme",
        "group-representative": "group-representative"
    }.get(reason, reason)

def sort_palette_entries(entries):
    """Sort palette entries by population, while keeping equal-population entries stable."""
    return sorted(entries, key=lambda e: e.get("population", 0), reverse=True)

# Define presets (user-facing perceptual weights) in logical combination order
PRESETS = {
    # Single-dimension emphasis
    'hue-focused': {'hue': 1.5, 'chroma': 0.5, 'tone': 1.2, 
                    'desc': 'Emphasizes hue differences over chroma variation; may prioritize color variety over saturation'},
    
    'chroma-focused': {'hue': 0.7, 'chroma': 2.0, 'tone': 0.8, 
                       'desc': 'Emphasizes chroma/saturation differences; may capture a wider range of both saturated and desaturated colors'},
    
    'tone-focused': {'hue': 0.7, 'chroma': 1.2, 'tone': 2.0, 
                     'desc': 'Emphasizes tone/lightness differences; may produce higher contrast between lights and darks'},
    
    # Two-dimension emphasis
    'color-focused': {'hue': 1.5, 'chroma': 1.8, 'tone': 0.7, 
                      'desc': 'Emphasizes both hue variety and saturation over lightness; may produce rich, colorful palettes'},
    
    'pastel-bias': {'hue': 1.2, 'chroma': 0.6, 'tone': 1.5, 
                    'desc': 'Emphasizes tone and hue while de-emphasizing chroma; may favor light colors with recognizable hues'},
    
    'high-impact': {'hue': 0.8, 'chroma': 1.8, 'tone': 1.8, 
                    'desc': 'Emphasizes both chroma and tone differences; may capture both saturated and high-contrast colors'},

    'higher-impact': {'hue': 0.64, 'chroma': 2.56, 'tone': 1.6, 
                    'desc': 'Emphasizes both chroma and tone differences more; chroma yet more; may capture both saturated and high-contrast colors'},

    # All-dimension equal
    'balanced': {'hue': 1.0, 'chroma': 1.0, 'tone': 1.0, 
                 'desc': 'Equal weight to all perceptual dimensions'},
    
    # Auto preset - data-driven hierarchical clustering
    'auto': {'desc': 'Automatically discovers natural perceptual groups using hierarchical clustering'},
}

if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Extract dominant colors from images using HCT space quantization with perceptual weighting and adaptive extreme detection',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
HCT Color Space Benefits for Quantization (via Coloraide):
  Hue:    0-360 (circular, from CAM16)
  Chroma: 0-145 (perceptual colorfulness, from CAM16)
  Tone:   0-100 (perceptual lightness, from CIELAB D65)

PERCEPTUAL WEIGHTING EXPLAINED:
  When all weights = 1.0, each perceptual dimension has EQUAL influence:
  - Hue: 2 features (sin/cos) each get weight 0.5, and total influence = 1.0
  - Chroma: 1 feature gets weight 1.0, and total influence = 1.0
  - Tone: 1 feature gets weight 1.0, and total influence = 1.0
  
  Increase weight (>1.0) to emphasize a dimension, decrease (<1.0) to de-emphasize.

PRESET MODES (use --preset):
  hue-focused    : Emphasizes hue differences over chroma variation; may prioritize color variety over saturation
  chroma-focused : Emphasizes chroma/saturation differences; may capture a wider range of both saturated and desaturated colors
  tone-focused   : Emphasizes tone/lightness differences; may produce higher contrast between lights and darks
  color-focused  : Emphasizes both hue variety and saturation over lightness; may produce rich, colorful palettes
  pastel-bias    : Emphasizes tone and hue while de-emphasizing chroma; may favor light colors with recognizable hues
  high-impact    : Emphasizes both chroma and tone differences; may capture both saturated and high-contrast colors
  balanced       : Equal weight to all perceptual dimensions
  auto           : Automatically discovers natural perceptual groups using hierarchical clustering.
                   Outputs at least 1 color per discovered group (actual count may exceed --numbercolors).
                   Can be combined with --weight-preset or custom weights (e.g., --preset auto --weight-preset high-impact).
                   Adjust sampling with --auto-samples and -r.
                   Caches dendrograms in .color_quantize_cache/ directory. Use --no-cache to force recompute.

ADAPTIVE EXTREME DETECTION (--capture-extremes):
  Standard k-means clustering averages colors within each cluster, which can dilute
  rare but perceptually important colors (like a small bright flower in a large dark scene).
  When enabled, this feature:

  1. Analyzes the distribution of chroma and tone values in the image
  2. Dynamically calculates percentile thresholds based on perceptual weights
     (emphasized dimensions use stricter thresholds, de-emphasized use looser)
  3. Separates pixels into "extreme" and "normal" populations
  4. Also identifies rare hues (hue bins with fewer than the threshold percentage of pixels)
  5. Clusters extreme and normal populations separately
  6. Combines results to include both statistical dominant and perceptually extreme colors

  The extreme ratio adapts automatically based on perceptual weights.
  Note: --capture-extremes is ignored when --preset auto is used.

OUTPUT FORMATS:
  Console output can be toggled between hex and hct using -f.
  File output (always .hexplt) contains both representations and group IDs (for auto preset):
    #ff5733  (H:245.3, C:42.1, T:78.5) [group 1]
    #4a90e2  (H:215.7, C:38.4, T:55.2) [group 2]
  
  Auto-generated filenames follow the pattern:
    [basename]_[preset]_n[colors]_h[weight]c[weight]t[weight][_extremes].hexplt
  For auto preset with custom weights:
    - "auto" for balanced
    - "auto-presetname" for weights matching a preset (via --weight-preset or manual)
    - "auto-custom" for non-matching custom weights

The HCT space provides a perceptually informed color representation,
resulting in more meaningful dominant color extraction than RGB clustering.
This implementation uses the proper HCT color space from Coloraide.
        """
    )

    parser.add_argument('-i', '--input', required=True,
                       help='Source image file path')
    parser.add_argument('-n', '--numbercolors', type=int, default=36,
                       help='Number of dominant colors to extract (default: 36)')
    parser.add_argument('-f', '--output-format', choices=['hex', 'hct'], default='hex',
                       help='Console output format: hex (#RRGGBB) or hct (HUE,CHROMA,TONE) (default: hex). File output always includes both.')
    parser.add_argument('--cores', type=float, default=0.75,
                       help='Percentage of CPU cores to use for conversion (0.0-1.0, default: 0.75)')
    parser.add_argument('--capture-extremes', action='store_true',
                       help='Enable adaptive extreme detection to include outlier colors in the palette (ignored with --preset auto)')
    parser.add_argument('-s', '--sample-pixels', action='store_true',
                       help='Sample up to 1.33M pixels instead of processing all (faster for large images, default: off)')
    
    # Auto preset sampling options
    parser.add_argument('--auto-samples', type=int, default=54000,
                       help='Number of samples for auto preset group discovery (default: 54000)')
    parser.add_argument('-r', '--randomsamplepercent', type=float, default=0.81,
                       help='Percentage of samples to take randomly in auto preset (0.0-1.0, default: 0.81). Remaining are grid samples.')
    parser.add_argument('--random-seed', type=int, default=42,
                       help='Random seed for pixel sampling and clustering (default: 42)')
    
    # Output file options - mutually exclusive
    output_group = parser.add_mutually_exclusive_group()
    output_group.add_argument('-o', '--output', 
                            help='Explicit output file path (must end in .hexplt). When used, auto-output is disabled.')
    output_group.add_argument('-a', '--auto-output', action='store_true', default=True,
                            help='Auto-generate output filename from input, preset, weights, color count, and adds "_extremes" if --capture-extremes enabled (default: enabled)')
    
    # Weighting controls
    parser.add_argument('--preset', choices=list(PRESETS.keys()),
                       help='Preset weighting mode. "auto" uses hierarchical clustering to discover natural perceptual groups.')
    parser.add_argument('--weight-preset', choices=list(PRESETS.keys()),
                       help='When using --preset auto, apply this preset for within-group clustering (overrides individual --*-weight flags)')
    parser.add_argument('--hue-weight', type=float, default=1.0,
                       help='Perceptual weight for hue (0.0-3.0, default: 1.0)')
    parser.add_argument('--chroma-weight', type=float, default=1.0,
                       help='Perceptual weight for chroma/saturation (0.0-3.0, default: 1.0)')
    parser.add_argument('--tone-weight', type=float, default=1.0,
                       help='Perceptual weight for tone/lightness (0.0-3.0, default: 1.0)')
    
    # Cache control
    parser.add_argument('--no-cache', action='store_true',
                       help='Disable caching for auto preset group discovery')

    # Force-overwrite target palette file if it exists
    parser.add_argument('--force-write', action='store_true',
                       help='Overwrite existing output file if it exists (if not provided, default behavior is skip and warn)')

    args = parser.parse_args()

    # VALIDATION CHECKS
    
    # Validate random sample percent
    if args.randomsamplepercent < 0 or args.randomsamplepercent > 1:
        print("\nError: --randomsamplepercent must be between 0.0 and 1.0\n", file=sys.stderr)
        sys.exit(1)
    
    if args.randomsamplepercent == 1.0:
        print("\nWarning: --randomsamplepercent=1.0 means all samples are random (no grid sampling). This may reduce spatial coverage.\n", file=sys.stderr)
    
    # Validate auto samples
    if args.auto_samples < 100:
        print("\nWarning: --auto-samples very low (<100). Group discovery may be unreliable.\n", file=sys.stderr)
    
    # Check that --weight-preset is only used with --preset auto
    if args.weight_preset and args.preset != 'auto':
        print("\nError: --weight-preset can only be used with --preset auto\n", file=sys.stderr)
        sys.exit(2)
    
    # Check that --weight-preset and individual weights are not both specified
    if args.weight_preset and (args.hue_weight != 1.0 or args.chroma_weight != 1.0 or args.tone_weight != 1.0):
        print("\nError: Cannot use --weight-preset with individual --hue-weight, --chroma-weight, or --tone-weight options\n", file=sys.stderr)
        print("  Either use --weight-preset for a preset combination, or set custom weights with --*-weight flags.\n", file=sys.stderr)
        sys.exit(3)
    
    # Check for conflict between preset and individual weights
    # Auto preset (--preset auto) can be combined with custom weights
    if args.preset is not None and args.preset != 'auto':
        if (args.hue_weight != 1.0 or args.chroma_weight != 1.0 or args.tone_weight != 1.0):
            print("\nError: Cannot use --preset with individual --hue-weight, --chroma-weight, or --tone-weight options!\n", file=sys.stderr)
            print("  Auto preset (--preset auto) can be combined with custom weights.", file=sys.stderr)
            print("  For other presets, use either the preset or manual weights, not both.\n", file=sys.stderr)
            sys.exit(4)

    # Validate cores parameter
    if args.cores < 0 or args.cores > 1:
        print("\nError: --cores must be between 0.0 and 1.0\n", file=sys.stderr)
        sys.exit(5)

    # Validate number of colors
    if args.numbercolors < 1:
        print("\nError: Number of colors must be at least 1!\n", file=sys.stderr)
        sys.exit(6)

    # Check if input file exists, or facsimiles from it that we can use, and handle such cases.
    input_exists = os.path.exists(args.input)
    
    # Check caches (this will delete corrupted HCT caches automatically)
    hct_exists, dendro_exists = check_caches_exist(args.input, args.auto_samples, args.randomsamplepercent, args.random_seed)
    
    if not input_exists:
        if hct_exists and dendro_exists:
            print(f"\nWarning: Source image '{args.input}' not found, but both HCT and dendrogram caches exist and are valid.")
            print("Proceeding with cached data. Results will use previously computed color groups.")
            print("To regenerate from source, restore the image file or use --no-cache.\n")
        elif hct_exists:
            print(f"\nWarning: Source image '{args.input}' not found. HCT cache exists but dendrogram cache missing.")
            print("Cannot proceed without dendrogram. Please restore the image or delete the HCT cache.\n")
            sys.exit(7)
        elif dendro_exists:
            print(f"\nWarning: Source image '{args.input}' not found. Dendrogram cache exists but HCT cache missing or was invalid (deleted).")
            print("Cannot proceed without HCT values. Please restore the image to regenerate caches.\n")
            sys.exit(8)
        else:
            print(f"\nError: Input file '{args.input}' not found and no caches available!\n", file=sys.stderr)
            sys.exit(9)

    if args.output and not args.output.lower().endswith('.hexplt'):
        print(f"\nError: Output file must end in .hexplt (got: {args.output})\n", file=sys.stderr)
        sys.exit(10)

    # Determine weights based on preset or individual values
    is_auto_preset = (args.preset == 'auto')
    
    if args.preset is not None and args.preset != 'auto':
        preset_weights = PRESETS[args.preset]
        hue_w = preset_weights['hue']
        chroma_w = preset_weights['chroma']
        tone_w = preset_weights['tone']
        weight_source = f"preset '{args.preset}'"
        used_preset = args.preset
        group_feature_weights = None  # Not used in non-auto mode
    elif is_auto_preset:
        # For auto preset, determine weights for within-group clustering
        if args.weight_preset:
            # Use specified preset for within-group clustering
            preset_weights = PRESETS[args.weight_preset]
            weight_hue = preset_weights['hue']
            weight_chroma = preset_weights['chroma']
            weight_tone = preset_weights['tone']
            group_feature_weights = calculate_feature_weights(weight_hue, weight_chroma, weight_tone)
            weight_source = f"auto preset with within-group preset '{args.weight_preset}'"
            used_preset = f"auto-{args.weight_preset}"
            hue_w = weight_hue
            chroma_w = weight_chroma
            tone_w = weight_tone
        elif (args.hue_weight != 1.0 or args.chroma_weight != 1.0 or args.tone_weight != 1.0):
            # Use custom weights
            group_feature_weights = calculate_feature_weights(args.hue_weight, args.chroma_weight, args.tone_weight)
            weight_source = f"auto preset with custom weights (H:{args.hue_weight:.2f}, C:{args.chroma_weight:.2f}, T:{args.tone_weight:.2f})"
            
            # Determine if custom weights match an existing preset
            matched_preset = None
            for preset_name, preset_vals in PRESETS.items():
                if preset_name == 'auto':
                    continue
                if (abs(preset_vals['hue'] - args.hue_weight) < 0.01 and
                    abs(preset_vals['chroma'] - args.chroma_weight) < 0.01 and
                    abs(preset_vals['tone'] - args.tone_weight) < 0.01):
                    matched_preset = preset_name
                    break
            
            if matched_preset:
                used_preset = f"auto-{matched_preset}"
            else:
                used_preset = "auto-custom"
            
            # For display only
            hue_w = args.hue_weight
            chroma_w = args.chroma_weight
            tone_w = args.tone_weight
        else:
            # Default balanced weights for within-group clustering
            group_feature_weights = calculate_feature_weights(1.0, 1.0, 1.0)
            weight_source = "auto preset (balanced weights for within-group clustering)"
            used_preset = 'auto'
            hue_w = 1.0
            chroma_w = 1.0
            tone_w = 1.0
    else:
        hue_w = args.hue_weight
        chroma_w = args.chroma_weight
        tone_w = args.tone_weight
        weight_source = "manual"
        used_preset = None
        group_feature_weights = None

    # Validate weight ranges
    for name, val in [('hue', hue_w), ('chroma', chroma_w), ('tone', tone_w)]:
        if val < 0 or val > 3:
            print(f"\nWarning: {name} weight {val} is outside typical range 0.0-3.0", file=sys.stderr)

    # Calculate the actual feature weights for clustering (used in non-auto modes)
    if not is_auto_preset:
        feature_weights = calculate_feature_weights(hue_w, chroma_w, tone_w)
    else:
        # For auto preset, we use group_feature_weights
        feature_weights = group_feature_weights

    print(f"\nLoading image: {args.input}")
    print(f"Using HCT color space from Coloraide (CAM16 + CIELAB)")
    print(f"Weighting mode: {weight_source}")
    if not is_auto_preset:
        print(f"  Perceptual weights: Hue={hue_w:.2f}, Chroma={chroma_w:.2f}, Tone={tone_w:.2f}")
        print(f"  Feature weights (after balancing):")
        print(f"    Hue sin/cos: {feature_weights[0]:.3f} each (total hue influence: {feature_weights[0]+feature_weights[1]:.3f})")
        print(f"    Chroma:      {feature_weights[2]:.3f}")
        print(f"    Tone:        {feature_weights[3]:.3f}")
    if args.capture_extremes and not is_auto_preset:
        print(f"  Adaptive extreme detection: ENABLED")
    elif args.capture_extremes and is_auto_preset:
        print(f"  Note: --capture-extremes is ignored with --preset auto")

    output_path = None
    if args.auto_output:
        output_path = generate_output_filename(
            args.input, used_preset, hue_w, chroma_w, tone_w, args.numbercolors, args.capture_extremes and not is_auto_preset
        )
        print(f"\nAuto-generating output filename: {output_path}")
    elif args.output:
        output_path = args.output
    
    # Check if output file already exists before any processing; if it does; warn and skip
    if output_path and os.path.exists(output_path) and not args.force_write:
        print(f"\nWarning: Output file already exists: {output_path}")
        print("Skipping processing. Use --force-write to overwrite.")
        sys.exit(0)

    try:
        # Prepare pixel data
        if input_exists:
            # Load image and convert to RGB array
            img = Image.open(args.input).convert('RGB')
            
            # Get image dimensions
            width, height = img.size
            total_pixels = width * height
            print(f"Image size: {width}x{height} pixels")
            
            # Convert to numpy array
            img_array = np.array(img)
            # Clamp to valid 0-255 range (fixes any out-of-range values in data)
            img_array = np.clip(img_array, 0, 255)
            
            # Always cache the full image HCT representation. If sampling is requested,
            # sample from the cached HCT data after conversion so the cache always means
            # "this image" rather than "one random sample of this image."
            pixels_flat = img_array.reshape(-1, 3)
            print(f"Processing all {total_pixels:,} pixels for HCT conversion")
            print(f"Converting {total_pixels:,} pixels to HCT space using {args.cores*100:.0f}% of CPU cores...")
            start_time = time.time()
            cores_to_use = calculate_core_count(args.cores)
            chunk_size = max(1000, total_pixels // (cores_to_use * 4))
            all_pixels_hct = load_or_convert_hct(pixels_flat, args.input, cores_to_use, chunk_size, args.auto_samples, args.randomsamplepercent, args.random_seed)
            conversion_time = time.time() - start_time
            print(f"Conversion completed in {conversion_time:.2f} seconds")

            max_pixels = 1333333
            if args.sample_pixels and total_pixels > max_pixels:
                rng = np.random.default_rng(args.random_seed)
                sample_indices = rng.choice(total_pixels, max_pixels, replace=False)
                pixels_hct = all_pixels_hct[sample_indices]
                print(f"Sampling {max_pixels:,} of {total_pixels:,} cached HCT pixels for clustering (--sample-pixels enabled)")
            else:
                pixels_hct = all_pixels_hct
                print(f"Using all {len(pixels_hct):,} HCT pixels for clustering")
        else:
            # Source missing - load HCT directly from cache
            print(f"Source image '{args.input}' not found, loading cached HCT values...")
            pixels_hct = load_hct_from_cache(args.input)
            all_pixels_hct = pixels_hct
            total_pixels = len(pixels_hct)
            print(f"Image size: (cached) {total_pixels} pixels")
            print(f"Console output format: {args.output_format.upper()}")
        
        # Perform clustering based on mode
        print(f"\nPerforming clustering to find {args.numbercolors} dominant colors...")
        palette_metadata = []
        
        cluster_start = time.time()
        
        if is_auto_preset:
            # AUTO PRESET: Hierarchical clustering to discover natural groups
            print(f"\nUsing auto preset - discovering natural perceptual groups...")
            print(f"  Sampling: {args.auto_samples} pixels ({args.randomsamplepercent*100:.0f}% random, {(1-args.randomsamplepercent)*100:.0f}% grid)")
            
            # Discover natural groups with caching
            use_cache = not args.no_cache
            group_labels, n_groups = discover_natural_groups_cached(
                pixels_hct, 
                args.input, 
                max_samples=args.auto_samples, 
                random_ratio=args.randomsamplepercent,
                use_cache=use_cache,
                random_seed=args.random_seed
            )
            print(f"  Natural groups discovered: {n_groups}")
            
            # Allocate colors across groups
            group_assignments = allocate_colors_from_groups(group_labels, pixels_hct, args.numbercolors)
            
            # Print group information
            print(f"\n  Group allocation for {args.numbercolors} colors:")
            for g in group_assignments:
                print(f"    Group {g['group_id']}: {g['size_pct']:.1f}% of image, diversity {g['diversity']:.3f}, gets {g['allocated']} color(s)")
            
            # Check and print warnings
            warnings_list = check_allocation_warnings(group_assignments, args.numbercolors)
            if warnings_list:
                print(f"\n  Warnings:")
                for w in warnings_list:
                    print(f"    {w}")
            
            # Check if number of natural groups exceeds requested colors
            if n_groups > args.numbercolors:
                print(f"\n  Note: Requested {args.numbercolors} colors, but {n_groups} natural groups were discovered.")
                print(f"  Auto mode preserves all natural groups (1 color per group minimum).")
                print(f"  Result will contain {n_groups} colors. Use --preset balanced for exact color counts.")
            
            # Extract colors from groups with group IDs
            centers_hct, group_ids, palette_metadata = extract_colors_from_groups(group_assignments, group_feature_weights, args.random_seed)
            
        elif args.capture_extremes:
            # Use adaptive extreme detection
            preset_dict = {'hue': hue_w, 'chroma': chroma_w, 'tone': tone_w}
            centers_hct, palette_metadata = extract_colors_with_adaptive_extremes(
                pixels_hct, 
                args.numbercolors,
                preset_dict,
                feature_weights,
                return_metadata=True,
                random_seed=args.random_seed
            )
            group_ids = None
        else:
            # Standard weighted k-means clustering
            features = create_features(pixels_hct)
            
            kmeans = WeightedKMeans(
                feature_weights=feature_weights,
                n_clusters=args.numbercolors,
                init='k-means++',
                n_init=10,
                max_iter=300,
                random_state=args.random_seed,
                verbose=0
            )
            
            kmeans.fit(features)
            centers_features = kmeans.cluster_centers_original
            centers_hct = reconstruct_hct(centers_features)
            group_ids = None

            # Analyze the clusters using the complete HCT population. This means
            # percentages remain representative of the whole image even when -s
            # was used to reduce the data used to fit k-means.
            full_features = create_features(all_pixels_hct)
            full_labels = kmeans.predict(full_features)
            valid_full = np.all(np.isfinite(all_pixels_hct), axis=1)
            full_valid_pixels = all_pixels_hct[valid_full]
            populations = np.bincount(full_labels, minlength=args.numbercolors)
            palette_metadata = []
            for i in range(args.numbercolors):
                cluster_pixels = full_valid_pixels[full_labels == i]
                palette_metadata.append({
                    "population": int(populations[i]),
                    "population_denominator": len(full_valid_pixels),
                    "diversity": float(measure_group_diversity(cluster_pixels)),
                    "reason": "cluster-representative"
                })
        
        cluster_time = time.time() - cluster_start
        print(f"Clustering completed in {cluster_time:.2f} seconds")
        
        # Convert HCT centers to hex
        hex_colors = []
        for hct_center in centers_hct:
            h, c, t = hct_center
            color_hct = HCTColor('hct', [h, c, t])
            color_rgb = color_hct.convert('srgb')
            r, g, b = color_rgb.coords()
            
            r_8bit = int(np.clip(r * 255, 0, 255))
            g_8bit = int(np.clip(g * 255, 0, 255))
            b_8bit = int(np.clip(b * 255, 0, 255))
            hex_colors.append(f"#{r_8bit:02x}{g_8bit:02x}{b_8bit:02x}")

        # Attach all palette metadata to the colors, then sort by population.
        # This makes output order meaningful without changing the selected palette.
        palette_entries = []
        for i, (hct, hex_color, metadata) in enumerate(zip(centers_hct, hex_colors, palette_metadata)):
            entry = dict(metadata)
            entry.update({"hct": hct, "hex": hex_color, "group_id": group_ids[i] if group_ids is not None else None})
            palette_entries.append(entry)
        palette_entries = sort_palette_entries(palette_entries)
        centers_hct = np.array([entry["hct"] for entry in palette_entries])
        hex_colors = [entry["hex"] for entry in palette_entries]
        palette_metadata = palette_entries
        if group_ids is not None:
            group_ids = [entry["group_id"] for entry in palette_entries]

        # Prepare display lines based on requested format
        if args.output_format == 'hex':
            display_lines = hex_colors
            print(f"\nDominant color(s) in HEX format:\n")
            if group_ids is not None:
                for i, (hex_color, hct, gid) in enumerate(zip(hex_colors, centers_hct, group_ids)):
                    meta = palette_metadata[i]
                    pct = meta["population"] / meta["population_denominator"] * 100 if meta["population_denominator"] else 0.0
                    print(f"  {i+1}. {hex_color}  (H:{hct[0]:.1f}, C:{hct[1]:.1f}, T:{hct[2]:.1f}) [{pct:.2f}% | spread:{meta['diversity']:.4f} | {format_palette_reason(meta['reason'])} | group {gid}]")
            else:
                for i, (hex_color, hct) in enumerate(zip(hex_colors, centers_hct)):
                    meta = palette_metadata[i]
                    pct = meta["population"] / meta["population_denominator"] * 100 if meta["population_denominator"] else 0.0
                    print(f"  {i+1}. {hex_color}  (H:{hct[0]:.1f}, C:{hct[1]:.1f}, T:{hct[2]:.1f}) [{pct:.2f}% | spread:{meta['diversity']:.4f} | {format_palette_reason(meta['reason'])}]")
        else:
            hct_lines = [f"{hct[0]:.1f},{hct[1]:.1f},{hct[2]:.1f}" for hct in centers_hct]
            display_lines = hct_lines
            print(f"\nDominant color(s) in HCT format (HUE,CHROMA,TONE):\n")
            if group_ids is not None:
                for i, (hct_line, hex_color, gid) in enumerate(zip(hct_lines, hex_colors, group_ids)):
                    meta = palette_metadata[i]
                    pct = meta["population"] / meta["population_denominator"] * 100 if meta["population_denominator"] else 0.0
                    print(f"  {i+1}. {hct_line}  ({hex_color}) [{pct:.2f}% | spread:{meta['diversity']:.4f} | {format_palette_reason(meta['reason'])} | group {gid}]")
            else:
                for i, (hct_line, hex_color) in enumerate(zip(hct_lines, hex_colors)):
                    meta = palette_metadata[i]
                    pct = meta["population"] / meta["population_denominator"] * 100 if meta["population_denominator"] else 0.0
                    print(f"  {i+1}. {hct_line}  ({hex_color}) [{pct:.2f}% | spread:{meta['diversity']:.4f} | {format_palette_reason(meta['reason'])}]")
        
        # Prepare file output lines (always both hex and HCT)
        file_lines = []
        for i, (hex_color, hct, meta) in enumerate(zip(hex_colors, centers_hct, palette_metadata)):
            pct = meta["population"] / meta["population_denominator"] * 100 if meta["population_denominator"] else 0.0
            line = (f"{hex_color}  (H:{hct[0]:.1f}, C:{hct[1]:.1f}, T:{hct[2]:.1f}) "
                    f"[{pct:.2f}% | spread:{meta['diversity']:.4f} | {format_palette_reason(meta['reason'])}")
            if group_ids is not None:
                line += f" | group {group_ids[i]}"
            line += "]"
            file_lines.append(line)
       
        # Write file if output path specified
        if output_path:
            try:
                with open(output_path, 'w') as f:
                    f.write(f"Generated by HCT_quantize_get_dominant_colors.py (version {SCRIPT_VERSION})\n")
                    f.write(f"Source image: {os.path.basename(args.input)}\n")
                    if used_preset:
                        f.write(f"Preset: {used_preset}\n")
                    f.write(f"Weights: Hue={hue_w:.2f}, Chroma={chroma_w:.2f}, Tone={tone_w:.2f}\n")
                    f.write(f"Colors requested: {args.numbercolors}\n")
                    f.write(f"Random seed: {args.random_seed}\n")
                    f.write(f"Format: sRGB hex and corresponding HCT values (H: hue, C: chroma, T: tone)\n")
                    f.write("Palette metadata: population percentage, within-cluster spread, and selection reason\n\n")
                    
                    for line in file_lines:
                        f.write(f"{line}\n")
                
                print(f"\nResults saved to: {output_path}")
            except Exception as e:
                print(f"\nError saving to file: {e}", file=sys.stderr)
        
        # Console output
        print(f"\n{'HEX' if args.output_format == 'hex' else 'HCT'} output:")
        for line in display_lines:
            print(line)
        
        total_time = time.time() - start_time
        print(f"\nTotal processing time: {total_time:.2f} seconds")
        print("Done!\n")
        
    except Exception as e:
        print(f"\nError processing image: {e}\n", file=sys.stderr)
        sys.exit(12)