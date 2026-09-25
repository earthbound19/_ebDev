# DESCRIPTION
# Oklch Space Dominant Color Extractor (using Coloraide)
# Quantizes images in Oklch color space to extract dominant colors with
# configurable perceptual weighting and adaptive extreme detection.
# Loads an image, converts it from sRGB to Oklch color space, performs
# clustering on the Oklch values to find representative colors,
# and outputs cluster centers in both sRGB hex codes and Oklch value format.
#
# Why Oklch for quantization?
# - Lightness (0-1): Perceptual lightness from Oklab
# - Chroma (0-1, gamut-normalized per pixel): Perceptual colorfulness from Oklab
# - Hue (0-360): Perceptual hue from Oklab (circular, no purple-shift artifact)
#
# Oklch provides perceptually uniform results derived from Oklab, with
# improved hue linearity compared to CAM16-based spaces. This implementation
# uses the proper Oklch color space from Coloraide.
#
# GAMUT-NORMALIZED CHROMA
# Raw Oklch chroma is not directly comparable across lightness/hue because
# the sRGB gamut boundary varies. A chroma of 0.15 at L=0.9 is near the
# maximum possible; at L=0.5 the same 0.15 is moderate. This script uses
# a precomputed LUT of max in-gamut chroma per (L, H) cell to normalize
# each pixel's chroma, so "chroma=1.0" means "at the gamut edge" for that
# pixel's lightness and hue. This makes chroma comparison perceptually
# consistent across the image.
#
# [rest of top-of-file DESCRIPTION identical to previous Oklch version,
#  with the note that "tone" and "lightness" are aliases in CLI]

# CODE
# Script version
SCRIPT_VERSION = "4.3.1"

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

# Create a Color class with all color spaces pre-registered
OKLCHColor = ColorAll

# =============================================================================
# GAMUT LUT: max in-gamut chroma per (L, H) cell
# =============================================================================

# LUT dimensions. 128 L values and 180 H values gives 10-degree hue resolution,
# which is finer than typical perceptual hue discrimination (~2-4 degrees) but
# a reasonable tradeoff for build time and cache size.
GAMUT_LUT_N_L = 128
GAMUT_LUT_N_H = 180

def get_gamut_lut_path():
    """Return path to the gamut LUT cache file."""
    cache_dir = get_cache_dir()
    return os.path.join(cache_dir, "oklch_srgb_gamut_lut.npz")

def build_gamut_lut():
    """
    Build a LUT of max in-gamut chroma for each (L, H) cell in sRGB.

    For each grid cell, binary search for the largest chroma whose Oklch
    color converts to a point inside the sRGB gamut.

    Returns: (lut, L_values, H_values)
    """
    print(f"  Building sRGB gamut LUT ({GAMUT_LUT_N_L} x {GAMUT_LUT_N_H})...")
    start = time.time()

    L_values = np.linspace(0.01, 0.99, GAMUT_LUT_N_L)
    H_values = np.linspace(0, 360, GAMUT_LUT_N_H, endpoint=False)
    lut = np.zeros((GAMUT_LUT_N_L, GAMUT_LUT_N_H), dtype=np.float32)

    for i, L in enumerate(L_values):
        for j, H in enumerate(H_values):
            # Binary search for max chroma that stays in sRGB
            lo, hi = 0.0, 0.5
            for _ in range(20):  # ~1e-6 chroma precision
                mid = (lo + hi) / 2.0
                c = OKLCHColor('oklch', [float(L), float(mid), float(H)])
                rgb = c.convert('srgb')
                r, g, b = rgb.coords()
                # Coloraide clamps to sRGB by default, so we need to check
                # the pre-clamp values. Use in_gamut on the Oklab clip check.
                # Simpler heuristic: convert back and forth and check if
                # the round-trip preserves the color (within tolerance).
                # For a cleaner check, test if the color is "in gamut" by
                # seeing whether the sRGB coords are all within [0, 1].
                if 0.0 <= r <= 1.0 and 0.0 <= g <= 1.0 and 0.0 <= b <= 1.0:
                    lo = mid
                else:
                    hi = mid
            lut[i, j] = lo

    elapsed = time.time() - start
    print(f"  Gamut LUT built in {elapsed:.1f} seconds")
    return lut, L_values, H_values

def load_or_build_gamut_lut():
    """
    Load the gamut LUT from cache, or build and cache it if not present.
    Returns: (lut, L_values, H_values)
    """
    lut_path = get_gamut_lut_path()
    if os.path.exists(lut_path):
        try:
            data = np.load(lut_path)
            lut = data['lut']
            L_values = data['L_values']
            H_values = data['H_values']
            print(f"  Loaded gamut LUT from: {lut_path}")
            return lut, L_values, H_values
        except Exception as e:
            print(f"  Warning: Failed to load gamut LUT ({e}), rebuilding...")

    lut, L_values, H_values = build_gamut_lut()

    try:
        np.savez_compressed(lut_path, lut=lut, L_values=L_values, H_values=H_values)
        print(f"  Saved gamut LUT to: {lut_path}")
    except Exception as e:
        print(f"  Warning: Failed to save gamut LUT ({e})")

    return lut, L_values, H_values

# Module-level cache for the LUT (loaded once per process)
_GAMUT_LUT = None
_GAMUT_L_VALUES = None
_GAMUT_H_VALUES = None

def ensure_gamut_lut_loaded():
    """Ensure the module-level LUT is loaded."""
    global _GAMUT_LUT, _GAMUT_L_VALUES, _GAMUT_H_VALUES
    if _GAMUT_LUT is None:
        _GAMUT_LUT, _GAMUT_L_VALUES, _GAMUT_H_VALUES = load_or_build_gamut_lut()

def lookup_max_chroma(L, H):
    """
    Bilinear lookup of max in-gamut chroma for given (L, H) arrays.
    L in [0, 1], H in [0, 360).
    Returns array of max chroma values.
    """
    ensure_gamut_lut_loaded()

    lut = _GAMUT_LUT
    L_values = _GAMUT_L_VALUES
    H_values = _GAMUT_H_VALUES
    n_L = len(L_values)
    n_H = len(H_values)

    # Map L to continuous index space
    L_idx = (L - L_values[0]) / (L_values[-1] - L_values[0]) * (n_L - 1)
    L_idx = np.clip(L_idx, 0, n_L - 1)

    # Map H to continuous index space, wrapping around
    H_idx = H / 360.0 * n_H  # H in [0, 360) -> [0, n_H)
    H_idx = H_idx % n_H

    # Bilinear interpolation
    L_lo = np.floor(L_idx).astype(int)
    L_hi = np.minimum(L_lo + 1, n_L - 1)
    L_frac = L_idx - L_lo

    H_lo = np.floor(H_idx).astype(int) % n_H
    H_hi = (H_lo + 1) % n_H
    H_frac = H_idx - np.floor(H_idx)

    v00 = lut[L_lo, H_lo]
    v01 = lut[L_lo, H_hi]
    v10 = lut[L_hi, H_lo]
    v11 = lut[L_hi, H_hi]

    v0 = v00 * (1 - H_frac) + v01 * H_frac
    v1 = v10 * (1 - H_frac) + v11 * H_frac
    return v0 * (1 - L_frac) + v1 * L_frac

# =============================================================================

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

def process_chunk_rgb_to_oklch(args):
    """Process a chunk of RGB pixels and return Oklch values (L, C, H order)."""
    chunk_data = args
    
    chunk_float = chunk_data.astype(np.float32) / 255.0
    pixels = chunk_float.reshape(-1, 3)
    
    oklch_values = []
    for pixel in pixels:
        try:
            color = OKLCHColor('srgb', pixel.tolist())
            color_oklch = color.convert('oklch')
            l, c, h = color_oklch.coords()
            oklch_values.append([l, c, h])
        except Exception:
            oklch_values.append([0.0, 0.0, 0.0])
    
    return np.array(oklch_values, dtype=np.float32)

def calculate_core_count(percent):
    """Calculate number of cores to use based on percentage."""
    total_cores = cpu_count()
    
    if percent <= 0:
        return 1
    elif percent >= 1:
        return total_cores
    
    core_count = max(1, int(round(total_cores * percent)))
    return core_count

def calculate_feature_weights(lightness_weight=1.0, chroma_weight=1.0, hue_weight=1.0):
    """
    Convert user-friendly perceptual weights to actual feature weights.
    
    The transformation ensures that when all weights are 1.0, each perceptual
    dimension (lightness, chroma, hue) has EQUAL total influence on clustering.
    
    How it works:
    - Hue is represented by 2 features (sin, cos)
    - To make total hue influence = 1.0, each hue feature gets weight = hue_weight/2
    - Lightness and chroma are each 1 feature, so they get full weight
    """
    hue_feature_weight = hue_weight / 2.0
    
    return np.array([
        lightness_weight,    # lightness
        chroma_weight,       # chroma
        hue_feature_weight,  # hue_sin
        hue_feature_weight,  # hue_cos
    ])

def create_features(pixels_oklch):
    """
    Convert Oklch pixels to feature space for clustering.
    Expects pixels_oklch with columns [L, C, H].
    Includes validation and gamut-normalized chroma.
    """
    # First, check for any invalid input
    if np.any(~np.isfinite(pixels_oklch)):
        invalid_count = np.sum(~np.isfinite(pixels_oklch))
        print(f"  Warning: Found {invalid_count} invalid Oklch values, filtering...")
        valid_mask = np.all(np.isfinite(pixels_oklch), axis=1)
        pixels_oklch = pixels_oklch[valid_mask]
        if len(pixels_oklch) == 0:
            raise ValueError("No valid pixels after filtering - all Oklch values were invalid")
        print(f"  Filtered to {len(pixels_oklch):,} valid pixels")
    
    lightness = pixels_oklch[:, 0]
    chroma = pixels_oklch[:, 1]
    hue = pixels_oklch[:, 2]
    
    # Gamut-normalize chroma: divide by max chroma achievable at (L, H)
    max_chroma = lookup_max_chroma(lightness, hue)
    # Floor at a small value to avoid division blowup near L=0 or L=1
    # where max chroma approaches zero
    max_chroma = np.maximum(max_chroma, 1e-3)
    normalized_chroma = chroma / max_chroma
    # Clamp to [0, 1] — some pixels may slightly exceed LUT due to bilinear
    # interpolation near the gamut boundary
    normalized_chroma = np.clip(normalized_chroma, 0.0, 1.0)
    
    hue_rad = np.radians(hue)
    
    features = np.column_stack([
        lightness,            # Already 0-1
        normalized_chroma,    # 0-1 after gamut normalization
        np.sin(hue_rad),
        np.cos(hue_rad),
    ])
    
    if np.any(~np.isfinite(features)):
        nan_count = np.sum(~np.isfinite(features))
        print(f"  Warning: Features contain {nan_count} non-finite values after conversion")
        valid_mask = np.all(np.isfinite(features), axis=1)
        features = features[valid_mask]
        if len(features) == 0:
            raise ValueError("No valid features after filtering - cannot proceed")
        print(f"  Filtered to {len(features):,} valid feature rows")
    
    return features

def reconstruct_oklch(centers_features):
    """
    Convert feature space centers back to Oklch coordinates.
    Returns array with columns [L, C, H].
    Note: Chroma is denormalized using the LUT at the center's (L, H).
    This is approximate because the normalization was per-pixel, but for
    cluster centers it recovers the right chroma scale.
    """
    L = np.clip(centers_features[:, 0], 0, 1)
    C_norm = np.clip(centers_features[:, 1], 0, 1)
    sin_h = centers_features[:, 2]
    cos_h = centers_features[:, 3]
    H = np.degrees(np.arctan2(sin_h, cos_h)) % 360
    
    # Denormalize chroma using LUT at the center's (L, H)
    max_chroma = lookup_max_chroma(L, H)
    max_chroma = np.maximum(max_chroma, 1e-3)
    C = C_norm * max_chroma
    C = np.clip(C, 0, 0.5)
    
    return np.column_stack([L, C, H])

def measure_group_diversity(group_pixels):
    """Measure internal diversity of a group in Oklch space."""
    if len(group_pixels) < 2:
        return 0.0
    
    features = create_features(group_pixels)
    centroid = np.mean(features, axis=0)
    distances = np.linalg.norm(features - centroid, axis=1)
    return np.mean(distances)

def hybrid_sample(pixels_oklch, total_pixels, target_samples, random_ratio=0.81):
    """Hybrid sampling combining random and grid sampling."""
    n_random = int(target_samples * random_ratio)
    n_grid = target_samples - n_random
    
    step = total_pixels // n_grid
    grid_indices = np.arange(0, total_pixels, step)[:n_grid]
    
    remaining_mask = np.ones(total_pixels, dtype=bool)
    remaining_mask[grid_indices] = False
    remaining_indices = np.arange(total_pixels)[remaining_mask]
    random_indices = np.random.choice(remaining_indices, n_random, replace=False)
    
    indices = np.sort(np.concatenate([grid_indices, random_indices]))
    return pixels_oklch[indices]

def get_cache_filename(input_path, max_samples, random_ratio):
    """Generate a descriptive cache filename in the global cache directory."""
    cache_dir = get_cache_dir()
    
    base = os.path.splitext(os.path.basename(input_path))[0]
    base = re.sub(r'[^\w\s.-]', '', base)
    base = base.replace(' ', '_')
    
    r_percent = int(round(random_ratio * 100))
    param_str = f"a{max_samples}_r{r_percent}"
    
    filename = f"{base}_{param_str}_dendrogram.pkl"
    return os.path.join(cache_dir, filename)

def get_oklch_cache_path(input_path):
    """Generate cache path for Oklch values in the global cache directory."""
    cache_dir = get_cache_dir()
    
    base = os.path.splitext(os.path.basename(input_path))[0]
    base = re.sub(r'[^\w\s.-]', '', base)
    base = base.replace(' ', '_')
    
    filename = f"{base}_oklch_cache.pkl"
    return os.path.join(cache_dir, filename)

def debug_cache_paths(input_path, auto_samples, random_ratio):
    """Print detailed cache file paths for debugging."""
    cache_dir = get_cache_dir()
    oklch_cache = get_oklch_cache_path(input_path)
    dendrogram_cache = os.path.join(cache_dir, get_cache_filename(input_path, auto_samples, random_ratio))
    lut_path = get_gamut_lut_path()
    
    print(f"\n  DEBUG: Cache directory: {cache_dir}")
    print(f"  DEBUG: Expected Oklch cache: {oklch_cache}")
    print(f"  DEBUG: Oklch cache exists: {os.path.exists(oklch_cache)}")
    print(f"  DEBUG: Expected dendrogram cache: {dendrogram_cache}")
    print(f"  DEBUG: Dendrogram cache exists: {os.path.exists(dendrogram_cache)}")
    print(f"  DEBUG: Gamut LUT: {lut_path}")
    print(f"  DEBUG: Gamut LUT exists: {os.path.exists(lut_path)}")
    
    if os.path.exists(cache_dir):
        print(f"  DEBUG: All cache files in directory:")
        for f in os.listdir(cache_dir):
            if f.endswith('.pkl') or f.endswith('.npz'):
                print(f"    - {f}")

def check_caches_exist(input_path, auto_samples, random_ratio):
    """Check if both Oklch and dendrogram caches exist for an image."""
    oklch_cache = get_oklch_cache_path(input_path)
    dendrogram_cache = os.path.join(get_cache_dir(), get_cache_filename(input_path, auto_samples, random_ratio))
    
    oklch_exists = os.path.exists(oklch_cache)
    dendro_exists = os.path.exists(dendrogram_cache)
    
    if oklch_exists:
        try:
            with open(oklch_cache, 'rb') as f:
                oklch_data = pickle.load(f)
            if np.any(~np.isfinite(oklch_data)):
                print(f"  Warning: Oklch cache contains invalid values, deleting...")
                os.remove(oklch_cache)
                oklch_exists = False
        except Exception as e:
            print(f"  Warning: Oklch cache corrupted ({e}), deleting...")
            os.remove(oklch_cache)
            oklch_exists = False
    
    return oklch_exists, dendro_exists

def load_oklch_from_cache(input_path):
    """Load Oklch values directly from cache with validation."""
    cache_file = get_oklch_cache_path(input_path)
    with open(cache_file, 'rb') as f:
        pixels_oklch = pickle.load(f)
    
    if np.any(~np.isfinite(pixels_oklch)):
        invalid_count = np.sum(~np.isfinite(pixels_oklch))
        raise ValueError(f"Oklch cache contains {invalid_count} invalid values. Delete the cache file and re-run with source image.")
    
    return pixels_oklch

def load_or_convert_oklch(pixels_rgb, input_path, cores_to_use, chunk_size, auto_samples=54000, random_ratio=0.81):
    """Load cached Oklch values or convert and cache."""
    cache_file = get_oklch_cache_path(input_path)
    dendrogram_cache = os.path.join(get_cache_dir(), get_cache_filename(input_path, auto_samples, random_ratio))
    
    if os.path.exists(cache_file):
        print(f"  Loading cached Oklch values from: {cache_file}")
        try:
            with open(cache_file, 'rb') as f:
                pixels_oklch = pickle.load(f)
            
            if np.any(~np.isfinite(pixels_oklch)):
                invalid_count = np.sum(~np.isfinite(pixels_oklch))
                print(f"  Warning: Cache contains {invalid_count} invalid values.")
                print(f"  Deleting both Oklch and dendrogram caches to force clean regeneration...")
                os.remove(cache_file)
                if os.path.exists(dendrogram_cache):
                    os.remove(dendrogram_cache)
            else:
                print(f"  Loaded {len(pixels_oklch):,} valid Oklch values from cache")
                return pixels_oklch
        except Exception as e:
            print(f"  Warning: Failed to load Oklch cache ({e}), recomputing...")
    
    print(f"  Converting {len(pixels_rgb):,} pixels to Oklch space...")
    
    chunks = []
    for i in range(0, len(pixels_rgb), chunk_size):
        chunk = pixels_rgb[i:i+chunk_size]
        chunks.append(chunk)
    
    all_oklch = []
    with Pool(processes=cores_to_use) as pool:
        for i, result in enumerate(pool.imap(process_chunk_rgb_to_oklch, chunks)):
            all_oklch.append(result)
            if (i + 1) % max(1, len(chunks) // 10) == 0:
                pct = (i + 1) / len(chunks) * 100
                print(f"    Conversion: {pct:.0f}% complete", end='\r')
    
    print()
    pixels_oklch = np.vstack(all_oklch)
    
    valid_mask = np.all(np.isfinite(pixels_oklch), axis=1)
    invalid_count = np.sum(~valid_mask)
    if invalid_count > 0:
        print(f"  Filtering out {invalid_count} invalid pixels before saving to cache")
        pixels_oklch_clean = pixels_oklch[valid_mask]
    else:
        pixels_oklch_clean = pixels_oklch
    
    try:
        os.makedirs(os.path.dirname(cache_file), exist_ok=True)
        with open(cache_file, 'wb') as f:
            pickle.dump(pixels_oklch_clean, f)
        print(f"  Saved {len(pixels_oklch_clean):,} valid Oklch values to cache: {cache_file}")
    except Exception as e:
        print(f"  Warning: Failed to save Oklch cache ({e})")
    
    if os.path.exists(dendrogram_cache):
        print(f"  Deleting outdated dendrogram cache: {dendrogram_cache}")
        os.remove(dendrogram_cache)
    
    return pixels_oklch_clean

def discover_natural_groups_cached(pixels_oklch, input_path, max_samples=54000, random_ratio=0.81, use_cache=True):
    """Hierarchical clustering to find natural perceptual groups, with caching."""
    total_pixels = len(pixels_oklch)
    
    cache_dir = get_cache_dir()
    cache_file = os.path.join(cache_dir, get_cache_filename(input_path, max_samples, random_ratio))
    
    if use_cache and os.path.exists(cache_file):
        print(f"  Loading cached dendrogram from: {cache_file}")
        try:
            with open(cache_file, 'rb') as f:
                cache_data = pickle.load(f)
                all_labels = cache_data['all_labels']
                natural_groups = cache_data['natural_groups']
                cached_total_pixels = cache_data.get('total_pixels', 0)
            
            if cached_total_pixels != total_pixels:
                print(f"  Warning: Cached dendrogram expects {cached_total_pixels} pixels but current has {total_pixels}")
                print(f"  Deleting outdated dendrogram cache and recomputing...")
                os.remove(cache_file)
            else:
                print(f"  Loaded {natural_groups} groups from cache")
                return all_labels, natural_groups
        except Exception as e:
            print(f"  Warning: Failed to load cache ({e}), recomputing...")
    
    print(f"  Computing dendrogram (this may take a moment)...")
    
    if total_pixels > max_samples:
        n_random = int(max_samples * random_ratio)
        n_grid = max_samples - n_random
        
        step = total_pixels // n_grid
        grid_indices = np.arange(0, total_pixels, step)[:n_grid]
        
        remaining_mask = np.ones(total_pixels, dtype=bool)
        remaining_mask[grid_indices] = False
        remaining_indices = np.arange(total_pixels)[remaining_mask]
        random_indices = np.random.choice(remaining_indices, n_random, replace=False)
        
        sample_indices = np.sort(np.concatenate([grid_indices, random_indices]))
        sample = pixels_oklch[sample_indices]
        sampled = True
        original_sample_size = len(sample)
        n_random_actual = len(random_indices)
        n_grid_actual = len(grid_indices)
        
        valid_mask = np.all(np.isfinite(sample), axis=1)
        invalid_count = np.sum(~valid_mask)
        if invalid_count > 0:
            print(f"  Warning: Found {invalid_count} invalid Oklch values in sample, filtering...")
            sample = sample[valid_mask]
            valid_sample_indices = sample_indices[valid_mask]
        else:
            valid_sample_indices = sample_indices
        sample_size = len(sample)
    else:
        sample = pixels_oklch
        sampled = False
        sample_size = total_pixels
        n_random_actual = 0
        n_grid_actual = 0
        invalid_count = 0
        valid_sample_indices = np.arange(total_pixels)
    
    print(f"  Converting {sample_size:,} pixels to features...")
    features = create_features(sample)
    
    final_sample_size = len(features)
    if final_sample_size < sample_size:
        print(f"  Warning: Further filtered by create_features, using {final_sample_size} pixels")
        valid_feature_indices = valid_sample_indices[:final_sample_size]
    else:
        valid_feature_indices = valid_sample_indices
    
    if final_sample_size < 2:
        raise ValueError(f"Only {final_sample_size} valid pixels found - cannot perform clustering")
    
    print(f"  Computing pairwise distances...")
    distance_matrix = pdist(features, metric='euclidean')
    
    print(f"  Building dendrogram with Ward linkage...")
    linkage_matrix = linkage(distance_matrix, method='ward')
    
    merge_distances = linkage_matrix[:, 2]
    gap_sizes = np.diff(merge_distances)
    
    if len(gap_sizes) == 0:
        natural_groups = 1
    else:
        mean_gap = np.mean(gap_sizes)
        std_gap = np.std(gap_sizes)
        threshold = mean_gap + std_gap
        natural_groups = np.sum(gap_sizes > threshold) + 1
    
    natural_groups = max(1, min(natural_groups, final_sample_size))
    
    if natural_groups == 1:
        cluster_labels = np.ones(final_sample_size, dtype=int)
    else:
        cut_distance = merge_distances[-(natural_groups - 1)]
        cluster_labels = fcluster(linkage_matrix, cut_distance, criterion='distance')
    
    if sampled:
        all_labels = np.zeros(total_pixels, dtype=int)
        for idx, label in zip(valid_feature_indices, cluster_labels):
            all_labels[idx] = label
        print(f"  (Used hybrid sampling: {n_random_actual} random + {n_grid_actual} grid = {original_sample_size} pixels, {invalid_count} invalid filtered)")
    else:
        all_labels = cluster_labels
    
    if use_cache:
        try:
            os.makedirs(cache_dir, exist_ok=True)
            cache_data = {
                'all_labels': all_labels,
                'natural_groups': natural_groups,
                'max_samples': max_samples,
                'random_ratio': random_ratio,
                'total_pixels': total_pixels
            }
            with open(cache_file, 'wb') as f:
                pickle.dump(cache_data, f)
            print(f"  Saved dendrogram to cache: {cache_file}")
        except Exception as e:
            print(f"  Warning: Failed to save cache ({e})")
    
    return all_labels, natural_groups

def allocate_colors_from_groups(group_labels, pixels_oklch, n_colors):
    """Allocate colors proportionally across natural groups."""
    unique_groups = np.unique(group_labels)
    group_sizes = [np.sum(group_labels == g) for g in unique_groups]
    total_pixels = len(pixels_oklch)
    
    group_diversities = []
    for g in unique_groups:
        group_pixels = pixels_oklch[group_labels == g]
        group_diversities.append(measure_group_diversity(group_pixels))
    
    allocations = []
    for size in group_sizes:
        n = max(1, int(n_colors * size / total_pixels))
        allocations.append(n)
    
    allocated = sum(allocations)
    
    if allocated < n_colors:
        shortage = n_colors - allocated
        diversity_indices = sorted(range(len(unique_groups)), 
                                   key=lambda i: group_diversities[i], reverse=True)
        for _ in range(shortage):
            idx = diversity_indices[_ % len(diversity_indices)]
            allocations[idx] += 1
    elif allocated > n_colors:
        surplus = allocated - n_colors
        candidates = [(i, a, group_diversities[i], group_sizes[i]) 
                      for i, a in enumerate(allocations) if a > 1]
        candidates.sort(key=lambda x: (x[2], x[3]))
        for _ in range(min(surplus, len(candidates))):
            idx = candidates[_][0]
            allocations[idx] -= 1
    
    result = []
    for i, g in enumerate(unique_groups):
        group_pixels = pixels_oklch[group_labels == g]
        result.append({
            'group_id': int(g),
            'size': group_sizes[i],
            'size_pct': group_sizes[i] / total_pixels * 100,
            'diversity': group_diversities[i],
            'allocated': allocations[i],
            'pixels': group_pixels
        })
    
    return result

def extract_colors_from_groups(group_assignments, feature_weights):
    """For each group, run weighted k-means to extract allocated number of colors."""
    all_centers = []
    all_group_ids = []
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
            original_n = n
            n = len(group_pixels)
            print(f"      Not enough pixels: requested {original_n}, using {n}")
        
        if n == 0:
            continue
        
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
            random_state=42
        )
        kmeans.fit(features)
        centers = reconstruct_oklch(kmeans.cluster_centers_original)
        
        if n > 20:
            elapsed = time.time() - start_time
            print(f"      Completed in {elapsed:.1f} seconds")
        
        for _ in range(len(centers)):
            all_centers.append(centers[_])
            all_group_ids.append(group_id)
    
    if not all_centers:
        return np.array([]), []
    
    print(f"  Total colors extracted: {len(all_centers)}")
    return np.vstack(all_centers), all_group_ids

def check_allocation_warnings(group_assignments, n_colors):
    """Generate warnings for potential allocation issues."""
    warnings_list = []
    
    zero_allocation = [g for g in group_assignments if g['allocated'] == 0]
    if zero_allocation:
        for g in zero_allocation:
            warnings_list.append(
                f"Group {g['group_id']} ({g['size_pct']:.1f}% of image) will not appear in palette"
            )
    
    for g in group_assignments:
        if g['allocated'] == 1 and g['diversity'] > 0.08:
            warnings_list.append(
                f"Group {g['group_id']} has high diversity ({g['diversity']:.3f}) but only gets 1 color"
            )
    
    min_possible = len(group_assignments)
    if n_colors < min_possible:
        warnings_list.append(
            f"Requested {n_colors} colors but {min_possible} natural groups exist. "
            f"Consider increasing to at least {min_possible}."
        )
    
    return warnings_list

def extract_colors_with_adaptive_extremes(pixels_oklch, n_colors, preset_weights, feature_weights, extreme_ratio=0.3):
    """Extract colors using preset-aware adaptive extreme detection."""
    lightness_w = preset_weights['lightness']
    chroma_w = preset_weights['chroma']
    hue_w = preset_weights['hue']
    
    base_percentile = 10
    
    if chroma_w > 1.1:
        chroma_threshold = base_percentile / chroma_w
    elif chroma_w < 0.9:
        chroma_threshold = base_percentile * (1.0 + (0.9 - chroma_w))
    else:
        chroma_threshold = base_percentile
    
    if lightness_w > 1.1:
        lightness_threshold = base_percentile / lightness_w
    elif lightness_w < 0.9:
        lightness_threshold = base_percentile * (1.0 + (0.9 - lightness_w))
    else:
        lightness_threshold = base_percentile
    
    avg_emphasis = (chroma_w + lightness_w) / 2
    adaptive_extreme_ratio = extreme_ratio * avg_emphasis
    adaptive_extreme_ratio = min(0.5, max(0.1, adaptive_extreme_ratio))
    
    n_extreme = max(1, int(n_colors * adaptive_extreme_ratio))
    n_dominant = n_colors - n_extreme
    
    print(f"  Adaptive extreme detection:")
    print(f"    Chroma threshold: top/bottom {chroma_threshold:.1f}%")
    print(f"    Lightness threshold: top/bottom {lightness_threshold:.1f}%")
    print(f"    Extreme colors: {n_extreme} ({adaptive_extreme_ratio*100:.0f}% of palette)")
    
    chroma_high = np.percentile(pixels_oklch[:, 1], 100 - chroma_threshold)
    chroma_low = np.percentile(pixels_oklch[:, 1], chroma_threshold)
    lightness_high = np.percentile(pixels_oklch[:, 0], 100 - lightness_threshold)
    lightness_low = np.percentile(pixels_oklch[:, 0], lightness_threshold)
    
    extreme_mask = (
        (pixels_oklch[:, 1] >= chroma_high) |
        (pixels_oklch[:, 1] <= chroma_low) |
        (pixels_oklch[:, 0] >= lightness_high) |
        (pixels_oklch[:, 0] <= lightness_low)
    )
    
    hue_threshold_percentile = base_percentile
    hue_hist, hue_bins = np.histogram(pixels_oklch[:, 2], bins=36)
    threshold_count = len(pixels_oklch) * (hue_threshold_percentile / 100)
    rare_hue_bins = np.where(hue_hist < threshold_count)[0]
    
    if len(rare_hue_bins) > 0:
        rare_hue_mask = np.zeros(len(pixels_oklch), dtype=bool)
        for bin_idx in rare_hue_bins:
            bin_min = hue_bins[bin_idx]
            bin_max = hue_bins[bin_idx + 1]
            rare_hue_mask |= (pixels_oklch[:, 2] >= bin_min) & (pixels_oklch[:, 2] < bin_max)
        extreme_mask |= rare_hue_mask
        print(f"    Also capturing rare hues (bins with <{hue_threshold_percentile:.0f}% of pixels)")
    
    extreme_pixels = pixels_oklch[extreme_mask]
    normal_pixels = pixels_oklch[~extreme_mask]
    
    extreme_percent = len(extreme_pixels) / len(pixels_oklch) * 100
    print(f"    Found {len(extreme_pixels):,} extreme pixels ({extreme_percent:.1f}% of total)")
    
    if len(extreme_pixels) >= n_extreme and n_extreme > 0:
        extreme_features = create_features(extreme_pixels)
        extreme_kmeans = WeightedKMeans(
            feature_weights=feature_weights,
            n_clusters=n_extreme,
            init='k-means++',
            n_init=10,
            max_iter=300,
            random_state=42
        )
        extreme_kmeans.fit(extreme_features)
        extreme_centers = reconstruct_oklch(extreme_kmeans.cluster_centers_original)
    else:
        extreme_centers = np.array([])
        n_dominant = n_colors
        print(f"    Not enough extreme pixels, using all for dominant clustering")
    
    if len(normal_pixels) >= n_dominant and n_dominant > 0:
        normal_features = create_features(normal_pixels)
        normal_kmeans = WeightedKMeans(
            feature_weights=feature_weights,
            n_clusters=n_dominant,
            init='k-means++',
            n_init=10,
            max_iter=300,
            random_state=42
        )
        normal_kmeans.fit(normal_features)
        normal_centers = reconstruct_oklch(normal_kmeans.cluster_centers_original)
    else:
        print(f"    Falling back to standard clustering on all pixels")
        all_features = create_features(pixels_oklch)
        all_kmeans = WeightedKMeans(
            feature_weights=feature_weights,
            n_clusters=n_colors,
            init='k-means++',
            n_init=10,
            max_iter=300,
            random_state=42
        )
        all_kmeans.fit(all_features)
        return reconstruct_oklch(all_kmeans.cluster_centers_original)
    
    if len(extreme_centers) > 0:
        return np.vstack([normal_centers, extreme_centers])
    else:
        return normal_centers

def generate_output_filename(input_path, preset, lightness_w, chroma_w, hue_w, n_colors, capture_extremes):
    """
    Generate a descriptive output filename.
    Weights passed as (lightness, chroma, hue) to match Oklch natural order.
    """
    base = os.path.splitext(os.path.basename(input_path))[0]
    base = re.sub(r'[^\w\s.-]', '', base)
    base = base.replace(' ', '_')
    
    name_parts = [base]
    
    if preset:
        name_parts.append(preset)
    
    name_parts.append(f"n{n_colors:02d}")
    
    l_str = f"l{int(round(lightness_w * 10)):02d}"
    c_str = f"c{int(round(chroma_w * 10)):02d}"
    h_str = f"h{int(round(hue_w * 10)):02d}"
    name_parts.append(f"{l_str}{c_str}{h_str}")
    
    if capture_extremes:
        name_parts.append("extremes")
    
    filename = "_".join(name_parts) + ".hexplt"
    return filename

# Define presets. Internal key 'lightness' corresponds to Oklch L.
PRESETS = {
    'hue-focused': {'hue': 1.5, 'chroma': 0.5, 'lightness': 1.2, 
                    'desc': 'Emphasizes hue differences over chroma variation; may prioritize color variety over saturation'},
    
    'chroma-focused': {'hue': 0.7, 'chroma': 2.0, 'lightness': 0.8, 
                       'desc': 'Emphasizes chroma/saturation differences; may capture a wider range of both saturated and desaturated colors'},
    
    'tone-focused': {'hue': 0.7, 'chroma': 1.2, 'lightness': 2.0, 
                     'desc': 'Emphasizes lightness differences; may produce higher contrast between lights and darks'},
    
    'color-focused': {'hue': 1.5, 'chroma': 1.8, 'lightness': 0.7, 
                      'desc': 'Emphasizes both hue variety and saturation over lightness; may produce rich, colorful palettes'},
    
    'pastel-bias': {'hue': 1.2, 'chroma': 0.6, 'lightness': 1.5, 
                    'desc': 'Emphasizes lightness and hue while de-emphasizing chroma; may favor light colors with recognizable hues'},
    
    'high-impact': {'hue': 0.8, 'chroma': 1.8, 'lightness': 1.8, 
                    'desc': 'Emphasizes both chroma and lightness differences; may capture both saturated and high-contrast colors'},

    'higher-impact': {'hue': 0.64, 'chroma': 2.56, 'lightness': 1.6, 
                    'desc': 'Emphasizes both chroma and lightness differences more; chroma yet more; may capture both saturated and high-contrast colors'},

    'balanced': {'hue': 1.0, 'chroma': 1.0, 'lightness': 1.0, 
                 'desc': 'Equal weight to all perceptual dimensions'},
    
    'auto': {'desc': 'Automatically discovers natural perceptual groups using hierarchical clustering'},
}

# Alias map for user-facing preset names: allow "lightness-focused" as synonym
# for "tone-focused" for Oklch purists.
PRESET_ALIASES = {
    'lightness-focused': 'tone-focused',
}

def resolve_preset_name(name):
    """Resolve a user-facing preset name through the alias map."""
    if name is None:
        return None
    return PRESET_ALIASES.get(name, name)

if __name__ == '__main__':
    # Build the preset choices list including aliases
    preset_choices = list(PRESETS.keys()) + list(PRESET_ALIASES.keys())

    parser = argparse.ArgumentParser(
        description='Extract dominant colors from images using Oklch space quantization with perceptual weighting and adaptive extreme detection',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Oklch Color Space Benefits for Quantization (via Coloraide):
  Lightness: 0-1 (perceptual lightness from Oklab)
  Chroma:    0-~0.4 (perceptual colorfulness from Oklab, gamut-normalized)
  Hue:       0-360 (circular, from Oklab)

GAMUT-NORMALIZED CHROMA:
  Chroma is normalized per-pixel by the maximum in-gamut chroma for that
  pixel's lightness and hue, using a precomputed LUT. "Chroma=1.0" means
  "at the sRGB gamut edge" for that pixel's L and H, making chroma
  comparison perceptually consistent across the image.

PERCEPTUAL WEIGHTING EXPLAINED:
  When all weights = 1.0, each perceptual dimension has EQUAL influence.
  Weights can be set via --hue-weight, --chroma-weight, and either
  --tone-weight (HCT-compatible name) or --lightness-weight (Oklch-natural name).
  Both spellings are aliases for the same argument.

PRESET MODES (use --preset):
  hue-focused       : Emphasizes hue differences over chroma variation
  chroma-focused    : Emphasizes chroma/saturation differences
  tone-focused      : Emphasizes lightness differences (alias: lightness-focused)
  color-focused     : Emphasizes both hue variety and saturation
  pastel-bias       : Emphasizes lightness and hue, de-emphasizes chroma
  high-impact       : Emphasizes both chroma and lightness differences
  balanced          : Equal weight to all perceptual dimensions
  auto              : Data-driven natural group discovery via hierarchical clustering

The Oklch space provides perceptually uniform color differences,
resulting in more meaningful dominant color extraction than RGB clustering.
This implementation uses the proper Oklch color space from Coloraide.
        """
    )

    parser.add_argument('-i', '--input', required=True,
                       help='Source image file path')
    parser.add_argument('-n', '--numbercolors', type=int, default=36,
                       help='Number of dominant colors to extract (default: 36)')
    parser.add_argument('-f', '--output-format', choices=['hex', 'oklch'], default='hex',
                       help='Console output format: hex (#RRGGBB) or oklch (L,C,H) (default: hex). File output always includes both.')
    parser.add_argument('--cores', type=float, default=0.75,
                       help='Percentage of CPU cores to use for conversion (0.0-1.0, default: 0.75)')
    parser.add_argument('--capture-extremes', action='store_true',
                       help='Enable adaptive extreme detection to include outlier colors in the palette (ignored with --preset auto)')
    parser.add_argument('-s', '--sample-pixels', action='store_true',
                       help='Sample up to 1.33M pixels instead of processing all (faster for large images, default: off)')
    
    parser.add_argument('--auto-samples', type=int, default=54000,
                       help='Number of samples for auto preset group discovery (default: 54000)')
    parser.add_argument('-r', '--randomsamplepercent', type=float, default=0.81,
                       help='Percentage of samples to take randomly in auto preset (0.0-1.0, default: 0.81). Remaining are grid samples.')
    
    output_group = parser.add_mutually_exclusive_group()
    output_group.add_argument('-o', '--output', 
                            help='Explicit output file path (must end in .hexplt). When used, auto-output is disabled.')
    output_group.add_argument('-a', '--auto-output', action='store_true', default=True,
                            help='Auto-generate output filename from input, preset, weights, color count (default: enabled)')
    
    parser.add_argument('--preset', choices=preset_choices,
                       help='Preset weighting mode. "auto" uses hierarchical clustering to discover natural perceptual groups.')
    parser.add_argument('--weight-preset', choices=preset_choices,
                       help='When using --preset auto, apply this preset for within-group clustering')
    
    # Hue and chroma weights have single names
    parser.add_argument('--hue-weight', type=float, default=1.0,
                       help='Perceptual weight for hue (0.0-3.0, default: 1.0)')
    parser.add_argument('--chroma-weight', type=float, default=1.0,
                       help='Perceptual weight for chroma (0.0-3.0, default: 1.0)')
    
    # Lightness weight: two aliases, both write to args.lightness_weight
    parser.add_argument('--lightness-weight', '--tone-weight',
                       dest='lightness_weight',
                       type=float, default=1.0,
                       help='Perceptual weight for lightness (0.0-3.0, default: 1.0). '
                            'Aliases: --lightness-weight, --tone-weight (HCT-compatible name).')
    
    parser.add_argument('--no-cache', action='store_true',
                       help='Disable caching for auto preset group discovery')

    parser.add_argument('--force-write', action='store_true',
                       help='Overwrite existing output file if it exists (if not provided, default behavior is skip and warn)')

    args = parser.parse_args()

    # Resolve preset aliases
    args.preset = resolve_preset_name(args.preset)
    args.weight_preset = resolve_preset_name(args.weight_preset)

    # VALIDATION CHECKS
    if args.randomsamplepercent < 0 or args.randomsamplepercent > 1:
        print("\nError: --randomsamplepercent must be between 0.0 and 1.0\n", file=sys.stderr)
        sys.exit(1)
    
    if args.randomsamplepercent == 1.0:
        print("\nWarning: --randomsamplepercent=1.0 means all samples are random (no grid sampling). This may reduce spatial coverage.\n", file=sys.stderr)
    
    if args.auto_samples < 100:
        print("\nWarning: --auto-samples very low (<100). Group discovery may be unreliable.\n", file=sys.stderr)
    
    if args.weight_preset and args.preset != 'auto':
        print("\nError: --weight-preset can only be used with --preset auto\n", file=sys.stderr)
        sys.exit(2)
    
    if args.weight_preset and (args.hue_weight != 1.0 or args.chroma_weight != 1.0 or args.lightness_weight != 1.0):
        print("\nError: Cannot use --weight-preset with individual weight options\n", file=sys.stderr)
        sys.exit(3)
    
    if args.preset is not None and args.preset != 'auto':
        if (args.hue_weight != 1.0 or args.chroma_weight != 1.0 or args.lightness_weight != 1.0):
            print("\nError: Cannot use --preset with individual weight options!\n", file=sys.stderr)
            sys.exit(4)

    if args.cores < 0 or args.cores > 1:
        print("\nError: --cores must be between 0.0 and 1.0\n", file=sys.stderr)
        sys.exit(5)

    if args.numbercolors < 1:
        print("\nError: Number of colors must be at least 1!\n", file=sys.stderr)
        sys.exit(6)

    input_exists = os.path.exists(args.input)
    oklch_exists, dendro_exists = check_caches_exist(args.input, args.auto_samples, args.randomsamplepercent)
    
    if not input_exists:
        if oklch_exists and dendro_exists:
            print(f"\nWarning: Source image '{args.input}' not found, but both Oklch and dendrogram caches exist and are valid.")
            print("Proceeding with cached data.\n")
        elif oklch_exists:
            print(f"\nWarning: Source image '{args.input}' not found. Oklch cache exists but dendrogram cache missing.")
            sys.exit(7)
        elif dendro_exists:
            print(f"\nWarning: Source image '{args.input}' not found. Dendrogram cache exists but Oklch cache missing or was invalid (deleted).")
            sys.exit(8)
        else:
            print(f"\nError: Input file '{args.input}' not found and no caches available!\n", file=sys.stderr)
            sys.exit(9)

    if args.output and not args.output.lower().endswith('.hexplt'):
        print(f"\nError: Output file must end in .hexplt (got: {args.output})\n", file=sys.stderr)
        sys.exit(10)

    is_auto_preset = (args.preset == 'auto')
    
    if args.preset is not None and args.preset != 'auto':
        preset_weights = PRESETS[args.preset]
        hue_w = preset_weights['hue']
        chroma_w = preset_weights['chroma']
        lightness_w = preset_weights['lightness']
        weight_source = f"preset '{args.preset}'"
        used_preset = args.preset
        group_feature_weights = None
    elif is_auto_preset:
        if args.weight_preset:
            preset_weights = PRESETS[args.weight_preset]
            weight_hue = preset_weights['hue']
            weight_chroma = preset_weights['chroma']
            weight_lightness = preset_weights['lightness']
            group_feature_weights = calculate_feature_weights(weight_lightness, weight_chroma, weight_hue)
            weight_source = f"auto preset with within-group preset '{args.weight_preset}'"
            used_preset = f"auto-{args.weight_preset}"
            hue_w = weight_hue
            chroma_w = weight_chroma
            lightness_w = weight_lightness
        elif (args.hue_weight != 1.0 or args.chroma_weight != 1.0 or args.lightness_weight != 1.0):
            group_feature_weights = calculate_feature_weights(args.lightness_weight, args.chroma_weight, args.hue_weight)
            weight_source = f"auto preset with custom weights (H:{args.hue_weight:.2f}, C:{args.chroma_weight:.2f}, L:{args.lightness_weight:.2f})"
            
            matched_preset = None
            for preset_name, preset_vals in PRESETS.items():
                if preset_name == 'auto':
                    continue
                if (abs(preset_vals['hue'] - args.hue_weight) < 0.01 and
                    abs(preset_vals['chroma'] - args.chroma_weight) < 0.01 and
                    abs(preset_vals['lightness'] - args.lightness_weight) < 0.01):
                    matched_preset = preset_name
                    break
            
            used_preset = f"auto-{matched_preset}" if matched_preset else "auto-custom"
            hue_w = args.hue_weight
            chroma_w = args.chroma_weight
            lightness_w = args.lightness_weight
        else:
            group_feature_weights = calculate_feature_weights(1.0, 1.0, 1.0)
            weight_source = "auto preset (balanced weights for within-group clustering)"
            used_preset = 'auto'
            hue_w = 1.0
            chroma_w = 1.0
            lightness_w = 1.0
    else:
        hue_w = args.hue_weight
        chroma_w = args.chroma_weight
        lightness_w = args.lightness_weight
        weight_source = "manual"
        used_preset = None
        group_feature_weights = None

    for name, val in [('hue', hue_w), ('chroma', chroma_w), ('lightness', lightness_w)]:
        if val < 0 or val > 3:
            print(f"\nWarning: {name} weight {val} is outside typical range 0.0-3.0", file=sys.stderr)

    if not is_auto_preset:
        feature_weights = calculate_feature_weights(lightness_w, chroma_w, hue_w)
    else:
        feature_weights = group_feature_weights

    print(f"\nLoading image: {args.input}")
    print(f"Using Oklch color space from Coloraide (Oklab polar)")
    print(f"Weighting mode: {weight_source}")
    if not is_auto_preset:
        print(f"  Perceptual weights: Lightness={lightness_w:.2f}, Chroma={chroma_w:.2f}, Hue={hue_w:.2f}")
        print(f"  Feature weights (after balancing):")
        print(f"    Lightness:  {feature_weights[0]:.3f}")
        print(f"    Chroma:     {feature_weights[1]:.3f}")
        print(f"    Hue sin/cos: {feature_weights[2]:.3f} each (total hue influence: {feature_weights[2]+feature_weights[3]:.3f})")
    if args.capture_extremes and not is_auto_preset:
        print(f"  Adaptive extreme detection: ENABLED")
    elif args.capture_extremes and is_auto_preset:
        print(f"  Note: --capture-extremes is ignored with --preset auto")

    output_path = None
    if args.auto_output:
        output_path = generate_output_filename(
            args.input, used_preset, lightness_w, chroma_w, hue_w, args.numbercolors,
            args.capture_extremes and not is_auto_preset
        )
        print(f"\nAuto-generating output filename: {output_path}")
    elif args.output:
        output_path = args.output
    
    if output_path and os.path.exists(output_path) and not args.force_write:
        print(f"\nWarning: Output file already exists: {output_path}")
        print("Skipping processing. Use --force-write to overwrite.")
        sys.exit(0)

    # Ensure gamut LUT is loaded before any feature creation.
    # This triggers a one-time build on first run (~30-60 seconds),
    # then instant loads from cache on subsequent runs.
    ensure_gamut_lut_loaded()

    try:
        if input_exists:
            img = Image.open(args.input).convert('RGB')
            
            width, height = img.size
            total_pixels = width * height
            print(f"Image size: {width}x{height} pixels")
            
            img_array = np.array(img)
            img_array = np.clip(img_array, 0, 255)
            
            max_pixels = 1333333
            if args.sample_pixels and total_pixels > max_pixels:
                pixels_flat = img_array.reshape(-1, 3)
                sample_indices = np.random.choice(total_pixels, max_pixels, replace=False)
                pixels_rgb = pixels_flat[sample_indices]
                print(f"Sampling {max_pixels:,} of {total_pixels:,} pixels for processing (--sample-pixels enabled)")
            else:
                pixels_rgb = img_array.reshape(-1, 3)
                if total_pixels > max_pixels:
                    print(f"Processing all {total_pixels:,} pixels (use -s to sample for faster performance)")
                else:
                    print(f"Processing all {len(pixels_rgb):,} pixels")
            
            print(f"Converting {len(pixels_rgb):,} pixels to Oklch space using {args.cores*100:.0f}% of CPU cores...")
            start_time = time.time()
            cores_to_use = calculate_core_count(args.cores)
            chunk_size = max(1000, len(pixels_rgb) // (cores_to_use * 4))
            pixels_oklch = load_or_convert_oklch(pixels_rgb, args.input, cores_to_use, chunk_size, args.auto_samples, args.randomsamplepercent)
            conversion_time = time.time() - start_time
            print(f"Conversion completed in {conversion_time:.2f} seconds")
        else:
            print(f"Source image '{args.input}' not found, loading cached Oklch values...")
            pixels_oklch = load_oklch_from_cache(args.input)
            total_pixels = len(pixels_oklch)
            print(f"Image size: (cached) {total_pixels} pixels")
            print(f"Console output format: {args.output_format.upper()}")
        
        print(f"\nPerforming clustering to find {args.numbercolors} dominant colors...")
        
        cluster_start = time.time()
        
        if is_auto_preset:
            print(f"\nUsing auto preset - discovering natural perceptual groups...")
            print(f"  Sampling: {args.auto_samples} pixels ({args.randomsamplepercent*100:.0f}% random, {(1-args.randomsamplepercent)*100:.0f}% grid)")
            
            use_cache = not args.no_cache
            group_labels, n_groups = discover_natural_groups_cached(
                pixels_oklch, 
                args.input, 
                max_samples=args.auto_samples, 
                random_ratio=args.randomsamplepercent,
                use_cache=use_cache
            )
            print(f"  Natural groups discovered: {n_groups}")
            
            group_assignments = allocate_colors_from_groups(group_labels, pixels_oklch, args.numbercolors)
            
            print(f"\n  Group allocation for {args.numbercolors} colors:")
            for g in group_assignments:
                print(f"    Group {g['group_id']}: {g['size_pct']:.1f}% of image, diversity {g['diversity']:.3f}, gets {g['allocated']} color(s)")
            
            warnings_list = check_allocation_warnings(group_assignments, args.numbercolors)
            if warnings_list:
                print(f"\n  Warnings:")
                for w in warnings_list:
                    print(f"    {w}")
            
            if n_groups > args.numbercolors:
                print(f"\n  Note: Requested {args.numbercolors} colors, but {n_groups} natural groups were discovered.")
                print(f"  Auto mode preserves all natural groups (1 color per group minimum).")
                print(f"  Result will contain {n_groups} colors. Use --preset balanced for exact color counts.")
            
            centers_oklch, group_ids = extract_colors_from_groups(group_assignments, group_feature_weights)
            
        elif args.capture_extremes:
            preset_dict = {'hue': hue_w, 'chroma': chroma_w, 'lightness': lightness_w}
            centers_oklch = extract_colors_with_adaptive_extremes(
                pixels_oklch, 
                args.numbercolors,
                preset_dict,
                feature_weights
            )
            group_ids = None
        else:
            features = create_features(pixels_oklch)
            
            kmeans = WeightedKMeans(
                feature_weights=feature_weights,
                n_clusters=args.numbercolors,
                init='k-means++',
                n_init=10,
                max_iter=300,
                random_state=42,
                verbose=0
            )
            
            kmeans.fit(features)
            centers_features = kmeans.cluster_centers_original
            centers_oklch = reconstruct_oklch(centers_features)
            group_ids = None
        
        cluster_time = time.time() - cluster_start
        print(f"Clustering completed in {cluster_time:.2f} seconds")
        
        hex_colors = []
        for oklch_center in centers_oklch:
            l, c, h = oklch_center
            color_oklch = OKLCHColor('oklch', [l, c, h])
            color_rgb = color_oklch.convert('srgb')
            r, g, b = color_rgb.coords()
            
            r_8bit = int(np.clip(r * 255, 0, 255))
            g_8bit = int(np.clip(g * 255, 0, 255))
            b_8bit = int(np.clip(b * 255, 0, 255))
            hex_colors.append(f"#{r_8bit:02x}{g_8bit:02x}{b_8bit:02x}")
        
        if args.output_format == 'hex':
            display_lines = hex_colors
            print(f"\nDominant color(s) in HEX format:\n")
            if group_ids is not None:
                for i, (hex_color, oklch, gid) in enumerate(zip(hex_colors, centers_oklch, group_ids)):
                    print(f"  {i+1}. {hex_color}  (L:{oklch[0]:.3f}, C:{oklch[1]:.3f}, H:{oklch[2]:.1f}) [group {gid}]")
            else:
                for i, (hex_color, oklch) in enumerate(zip(hex_colors, centers_oklch)):
                    print(f"  {i+1}. {hex_color}  (L:{oklch[0]:.3f}, C:{oklch[1]:.3f}, H:{oklch[2]:.1f})")
        else:
            oklch_lines = [f"{oklch[0]:.3f},{oklch[1]:.3f},{oklch[2]:.1f}" for oklch in centers_oklch]
            display_lines = oklch_lines
            print(f"\nDominant color(s) in OKLCH format (LIGHTNESS,CHROMA,HUE):\n")
            if group_ids is not None:
                for i, (oklch_line, hex_color, gid) in enumerate(zip(oklch_lines, hex_colors, group_ids)):
                    print(f"  {i+1}. {oklch_line}  ({hex_color}) [group {gid}]")
            else:
                for i, (oklch_line, hex_color) in enumerate(zip(oklch_lines, hex_colors)):
                    print(f"  {i+1}. {oklch_line}  ({hex_color})")
        
        if group_ids is not None:
            file_lines = [f"{hex_color}  (L:{oklch[0]:.3f}, C:{oklch[1]:.3f}, H:{oklch[2]:.1f}) [group {gid}]" 
                         for hex_color, oklch, gid in zip(hex_colors, centers_oklch, group_ids)]
        else:
            file_lines = [f"{hex_color}  (L:{oklch[0]:.3f}, C:{oklch[1]:.3f}, H:{oklch[2]:.1f})" 
                         for hex_color, oklch in zip(hex_colors, centers_oklch)]
       
        if output_path:
            try:
                with open(output_path, 'w') as f:
                    f.write(f"Generated by OKLCH_quantize_get_dominant_colors.py (version {SCRIPT_VERSION})\n")
                    f.write(f"Source image: {os.path.basename(args.input)}\n")
                    if used_preset:
                        f.write(f"Preset: {used_preset}\n")
                    f.write(f"Weights: Hue={hue_w:.2f}, Chroma={chroma_w:.2f}, Lightness={lightness_w:.2f}\n")
                    f.write(f"Colors: {args.numbercolors}\n")
                    f.write(f"Format: sRGB hex and corresponding Oklch values (L: lightness, C: chroma, H: hue)\n\n")
                    
                    for line in file_lines:
                        f.write(f"{line}\n")
                
                print(f"\nResults saved to: {output_path}")
            except Exception as e:
                print(f"\nError saving to file: {e}", file=sys.stderr)
        
        print(f"\n{'HEX' if args.output_format == 'hex' else 'OKLCH'} output:")
        for line in display_lines:
            print(line)
        
        total_time = time.time() - start_time
        print(f"\nTotal processing time: {total_time:.2f} seconds")
        print("Done!\n")
        
    except Exception as e:
        print(f"\nError processing image: {e}\n", file=sys.stderr)
        sys.exit(12)