# DESCRIPTION
# Monitors a specific file for changes and automatically creates numbered or
# randomly-named copies whenever the file is saved/modified.
# SEE ALSO: CTRL+ALT+S keyboard shortcut in Krita for "Save Incremental Version," which
# accomplishes the same. But for other raster art programs or scenarios,
# this script is still handy.

# Designed for workflows where you want to automatically save versions of a file
# (like an image being edited) without manually exporting or saving copies each time.
# The use case that inspired this is rapidly creating a lot of paint brush stroke etc.
# images (for an image bomber), by rapidly painting, undoing, and repainting a template image.
# With this script properly configured and running, every time you re-save the image,
# it will make a new numbered paint brush stroke image, saving time of clicking menus
# or typing a new file name.

# Two naming schemes:
#   - Numbered: 6-digit padded numbers: 000001.png, 000002.png, etc.
#   - Random: 14-character random alphanumeric strings, like aB3xK9mP2qR5tN.png

# Performance-optimized: scans directory once at startup for the highest of any numbered
# file, and uses in-memory counter thereafter. Efficient even with thousands of files.

# Written nearly entirely by a Large Language Model, deepseek, with human guidance in
# features and fixes. The test plans and details were written by a human.

# PLATFORM COMPATIBILITY:
# - Windows: Fully tested
# - macOS/Linux: Should work but path formats may need adjustment; use forward slashes or
#   escaped backslashes in paths

# DEPENDENCIES
# Python 3.6+. Uses pathlib, shutil, etc. - all standard library, no external packages.

# USAGE
# Run from a Python interpreter with these parameters:
# NO ARGUMENTS (simplest usage):
#   python fileMonitorAndNumberedSaves.py
#   - If a default config file, fileMonitorAndNumberedSaves.ini, exists, it will be loaded,
# and monitoring will start.
#   - If no config file exists, a template will be created and you'll be prompted to edit it
#   and rerun the script.

# WITH OPTIONAL SWITCHES:
#   --config, -c [FILENAME] : Use specified config file. You can omit the filename from
#   this switch and it will default to fileMonitorAndNumberedSaves.ini
#   --source, -s            : Path to the source file to monitor, if not using config.
#   --target, -t            : Target directory to save copies, if not using config.
#   --random                : Use 14-character random names instead of 6-digit numbers
#   --interval, -i          : Check interval in seconds, defaults to 1.0 if omitted
#   --create-config         : Create a template configuration file and exit
#   --help, -h              : Show this help message

# CONFIG FILE MODE BEHAVIOR:
#   When using --config, the following rules apply:
#   - any --source and --target switches are IGNORED, with a warning, and the config
#   values are used.
#   - any --interval switch OVERRIDES the value in the config file
#   - a --random switch OVERRIDES a numbered naming_scheme in the config file
#   This allows you to use a config file for most settings while still being able to
#   adjust check frequency from the command line.

# EXAMPLES:
# Simplest workflow (creates config if needed, then runs):
#   python fileMonitorAndNumberedSaves.py
#   (first run creates template, second run starts monitoring)

# Use default config file if it exists:
#   python fileMonitorAndNumberedSaves.py --config

# Use default config file but override interval and naming scheme:
#   python fileMonitorAndNumberedSaves.py --interval 0.5 --random

# Use specific config file:
#   python fileMonitorAndNumberedSaves.py --config fileMonitor_project2.ini

# Command line mode; no config file, and source and target specified with switches:
#   python fileMonitorAndNumberedSaves.py --source "D:\Art\workfile.png" --target "D:\Art\versions"

# Use random names instead of numbers:
#   python fileMonitorAndNumberedSaves.py --source "doc.txt" --target "backups" --random

# Shorter check interval for faster response:
#   python fileMonitorAndNumberedSaves.py --source "image.psd" --target "versions" --interval 0.3

# Create a custom config template:
#   python fileMonitorAndNumberedSaves.py --create-config brush_strokes3.ini

# Run as background process on Windows; this runs without a visible terminal, and you'll need to
# manually terminate the process:
#   start /B python fileMonitorAndNumberedSaves.py

# CONFIGURATION FILE FORMAT (INI):
#   [Settings]
#   source_file = C:\full_path\to_your\file.ext
#   target_directory = C:\path_to\target_directory
#   naming_scheme = numbered    ; Must be exactly "numbered" or "random" (without quotes)

# BEHAVIOR NOTES:
# - Numbered files are padded with six digits: 000001.ext, 000002.ext, etc.
# - On startup with numbered scheme, script scans target directory once to find
#   the highest existing number and continues from there
# - Random names use 14 alphanumeric characters (a-z, A-Z, 0-9)
# - If a generated random filename already exists (extremely unlikely), the script
#   automatically generates another one.
# - Press Ctrl+C to stop monitoring gracefully
# - The target directory is created automatically if a path to is available and it
#   doesn't exist
# - The script handles temporary file locks gracefully by skipping affected checks
# - On first run, the script captures the source file's initial state and waits for
#   the first change after that to create a copy. This prevents an immediate unwanted
#   copy on startup.
# - INI comments must be on their own line starting with ';' and any other comment
#   setup will cause errors. So don't put comments on the same line as a setting value.

# TROUBLESHOOTING:
# - If no copies are being created, verify the source file path is correct,
#   and that the target path exists or could be auto-created by the script
# - Check that you have write permissions in the target directory
# - Some editors may use temporary files; the 0.1s delay after detection helps
# - For network drives, you may need to increase check_interval due to latency
# - If you see "Invalid naming_scheme value", check that your config file has
#   no comments on the same line as the naming_scheme setting. Comments must be
#   on their own line starting with ';'

# For a list of tests, see the first comments under the CODE comment.


# CODE
# ~
# LIST OF TESTS for QA / dev:
# TESTING LEGEND:
# * = to test
# / = testing
# - tested and passed
# x = tested and failed
# ? = tested and partial pass; accompany this with notes
#
# - If you run this script with no switches, does it create a defualt config
# if there is none, and print help text for next steps?
# - if a default config exists with errors, and you run the script with no
#   switches, does it load the config and warn of errors for:
#  - no valid source file?
#  - no possible target directory?
#  - both?
# - if a default valid config exists, does it load and work correctly as follows? :
#  - if the target directory does not exist but could, does it create it?
#  - if it does exist, does it use it?
#  - if numbered file names already exist in the target directory, does it scan
#    for the next highest unused number, and save to that on source file change?
# - if a default valid config exists and you provide source and/or target
# command switches, does it ignore them?
# - if a default valid config exists and you override with these switches,
# do they work? :
#  - override file modification check interval
#  - override numbering mode to random file name mode
#  - override both of those
# - config uses random file name mode?
# - helpful error and exit if specified (custom) config file doesn't exist?
# - helpful error and exit if specified config file that matches the default
#   config file name doesn't exist?
# - if you invoke the script from a directory other than the one it is in, does
#   it find the default config file in the same directory the script is in, and
#   load and use it correctly? A. No, it creates a config file in the directory
#   which you invoke the script from. BUT, on second thought, I think that's
#   better behavior, as it would allow easier use of config files from any
#   other directory easily, simply by calling the script.
# - if you invoke the script from a directory other than the one it is in, with
#   a config file of the default name in that other (non-script) directory, does
#   it load and use that? Or does it only look in the script directory? A. It
#   the default config file name, if it exists, from whatever directory the
#   the script is invoked in. Per previous comment this is desired.
# - does it load and correctly use a custom config file in another path;
#   - invoked from the script directory (using the --config switch and the path
#   to a config in another path as the value for it)?
#   - invoked from a directory outside the scripts' directory?


import os
import shutil
import time
import random
import string
import configparser
from pathlib import Path
import argparse
import sys

class FileMonitor:
    def __init__(self, config_file=None, source_path=None, target_dir=None, naming_scheme='numbered'):
        """
        Initialize the file monitor with config file or direct parameters.
        """
        if config_file and Path(config_file).exists():
            self.load_config(config_file)
        else:
            self.source_path = Path(source_path) if source_path else None
            self.target_dir = Path(target_dir) if target_dir else None
            self.naming_scheme = naming_scheme

        # Validate required paths
        if not self.source_path or not self.target_dir:
            raise ValueError("Source path and target directory must be specified")

        self.target_dir = Path(self.target_dir)
        self.source_path = Path(self.source_path)

        # Create target directory if it doesn't exist
        self.target_dir.mkdir(parents=True, exist_ok=True)

        # Get the file extension from source
        self.file_extension = self.source_path.suffix

        # Validate naming scheme
        if self.naming_scheme.lower() not in ['numbered', 'random']:
            raise ValueError(f"Invalid naming scheme: '{self.naming_scheme}'. Must be 'numbered' or 'random'")

        # Initialize tracking variables
        self.last_modified = 0
        self.highest_number = 0
        self.use_numbered = (self.naming_scheme.lower() == 'numbered')

        # If using numbered scheme, scan existing files once at startup
        if self.use_numbered:
            self.scan_existing_files()

        # Initial check of source file - capture initial state WITHOUT copying
        if self.source_path.exists():
            try:
                self.last_modified = self.source_path.stat().st_mtime
                print(f"Source file found. Initial state captured at: {time.strftime('%H:%M:%S', time.localtime(self.last_modified))}")
                print("Waiting for first change to create first copy...")
            except (OSError, IOError) as e:
                print(f"Warning: Could not read source file: {e}")
                self.last_modified = 0
        else:
            print(f"Warning: Source file {self.source_path} does not exist yet.")
            print(f"The script will start monitoring once the file appears.")

        self.print_status()

    def load_config(self, config_file):
        """Load configuration from INI file."""
        config = configparser.ConfigParser()
        config.read(config_file)

        if 'Settings' not in config:
            raise ValueError("Config file must contain [Settings] section")

        settings = config['Settings']
        self.source_path = Path(settings.get('source_file', '').strip())
        self.target_dir = Path(settings.get('target_directory', '').strip())
        self.naming_scheme = settings.get('naming_scheme', 'numbered').strip().lower()

        # Validate config values
        if not self.source_path or not self.target_dir:
            raise ValueError("source_file and target_directory must be specified in config file")

    def scan_existing_files(self):
        """One-time scan of target directory to find the highest numbered file."""
        print("Scanning existing files for highest number...")

        pattern = f"*{self.file_extension}"
        max_num = 0
        files_found = 0

        for file in self.target_dir.glob(pattern):
            files_found += 1
            # Try to extract number from filename (assuming format: ######.ext)
            name = file.stem
            if name.isdigit() and len(name) == 6:
                try:
                    num = int(name)
                    max_num = max(max_num, num)
                except ValueError:
                    continue

        self.highest_number = max_num
        print(f"Found {files_found} total files with extension {self.file_extension}")
        print(f"Highest numbered file: {self.highest_number:06d}")

    def get_next_numbered_filename(self):
        """Generate next filename using in-memory counter."""
        self.highest_number += 1
        return f"{self.highest_number:06d}{self.file_extension}"

    def get_random_filename(self):
        """Generate a random 14-character filename."""
        chars = string.ascii_letters + string.digits
        random_name = ''.join(random.choices(chars, k=14))
        return f"{random_name}{self.file_extension}"

    def copy_file(self):
        """Copy the source file to the target directory with appropriate naming."""
        if not self.source_path.exists():
            return

        if self.use_numbered:
            filename = self.get_next_numbered_filename()
        else:  # random
            filename = self.get_random_filename()

        target_path = self.target_dir / filename

        # Ensure we don't accidentally overwrite (safety check)
        if target_path.exists():
            if self.use_numbered:
                # This should rarely happen, but just in case
                print(f"Warning: {filename} already exists, scanning for next available...")
                self.scan_existing_files()
                filename = self.get_next_numbered_filename()
                target_path = self.target_dir / filename
            else:
                # For random, just try again (collision probability is extremely low)
                return self.copy_file()

        try:
            shutil.copy2(self.source_path, target_path)
            timestamp = time.strftime("%H:%M:%S")
            print(f"[{timestamp}] Saved: {filename}")
        except (OSError, IOError, PermissionError) as e:
            print(f"Error saving file {filename}: {e}")

    def print_status(self):
        """Print current monitoring status."""
        print("\n" + "="*60)
        print(f"FILE MONITOR ACTIVE")
        print("="*60)
        print(f"Source:      {self.source_path}")
        print(f"Target:      {self.target_dir}")
        print(f"Naming:      {'Numbered (6-digit)' if self.use_numbered else 'Random (14 chars)'}")
        if self.use_numbered:
            print(f"Next number: {self.highest_number + 1:06d}")
        print(f"Check every: {self.check_interval if hasattr(self, 'check_interval') else '1.0'} seconds")
        print("-"*60)
        print("Press Ctrl+C to stop monitoring")
        print("="*60 + "\n")

    def watch(self, check_interval=1.0):
        """
        Watch for file changes.

        Args:
            check_interval: Time in seconds between checks
        """
        self.check_interval = check_interval
        last_display_time = 0
        initial_capture_complete = bool(self.last_modified)  # Track if we've captured initial state

        try:
            while True:
                if self.source_path.exists():
                    try:
                        current_mtime = self.source_path.stat().st_mtime

                        if current_mtime != self.last_modified:
                            # Small delay to ensure file is completely written
                            time.sleep(0.1)

                            # Only copy if we're not on the very first detection
                            # (prevents copying immediately on startup)
                            if self.last_modified != 0:
                                self.copy_file()

                            self.last_modified = current_mtime

                            # If this was the first detection, just inform user
                            if not initial_capture_complete:
                                print("Initial state captured. Ready to monitor changes.")
                                initial_capture_complete = True

                    except (OSError, IOError):
                        # File might be temporarily locked, skip this check
                        pass
                else:
                    # Only show "waiting for file" message occasionally (every 30 seconds)
                    current_time = time.time()
                    if current_time - last_display_time > 30:
                        print(f"Waiting for source file to appear: {self.source_path}")
                        last_display_time = current_time

                time.sleep(check_interval)

        except KeyboardInterrupt:
            print("\n\n" + "="*60)
            print("MONITORING STOPPED")
            print("="*60)
            if self.use_numbered:
                print(f"Last number used: {self.highest_number:06d}")
                print(f"Total versions saved: {self.highest_number}")
            print("="*60)
            sys.exit(0)

def create_config_template(config_path):
    """Create a template configuration file with proper formatting."""
    template_content = """[Settings]
; comments must start with ';' at the beginning of a line
; don't put comments on the same line as a setting value
; if you know a path that you assign to source_file or target_directory is valid but it fails, try double backslashes (\\) or forward slashes (/)

; full path to the file you want to monitor and make numbered or randomly named copies of every time it's changed:
source_file = C:\full_path\to_your\file.ext

; directory to save copies to; will be created if it doesn't exist and a path to it is valid:
target_directory = C:\path_to\target_directory

; naming_scheme must be either "numbered" or "random", without quotes:
naming_scheme = numbered
"""

    with open(config_path, 'w') as f:
        f.write(template_content)

    print(f"\nConfiguration template created at: {config_path}")
    print("\nPlease open it and see instructions in comments therein.")

def main():
    default_config = "fileMonitorAndNumberedSaves.ini"

    # Check if no arguments were provided
    if len(sys.argv) == 1:
        # If default config exists, load it and run
        if Path(default_config).exists():
            print(f"\nFound existing config file: {default_config}")
            print("Loading and starting monitoring...\n")
            try:
                monitor = FileMonitor(config_file=default_config)
                monitor.watch()
            except (ValueError, FileNotFoundError, KeyError) as e:
                print(f"Error loading config: {e}")
                print("\nTroubleshooting tips:")
                print("  - Check that your config file follows the INI format rules")
                print("  - Ensure naming_scheme is exactly 'numbered' or 'random' (no comments on same line)")
                print("  - Make sure all paths are valid and use proper escaping")
                print("  - Run the script again to create a fresh template with correct formatting")
                sys.exit(1)
        else:
            # No config exists, create template and exit
            print("\n" + "="*60)
            print("FILE MONITOR AND NUMBERED SAVES")
            print("="*60)
            print("\nNo configuration file found. Creating default configuration file...\n")

            # Create default config
            create_config_template(default_config)

            print("\n" + "-"*60)
            print("NEXT STEPS:")
            print(f"1. Edit {default_config} with your actual file paths")
            print("2. Run the script again with no arguments to start monitoring")
            print("\nFor more options, use --help")
            print("="*60 + "\n")
        return

    parser = argparse.ArgumentParser(
        description='Monitor a file and create numbered/random copies when changed.',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
QUICK START:
  First run:  python %(prog)s              # Creates default config file
  Second run: python %(prog)s              # Starts monitoring with your edited config

CONFIG FILE MODE (recommended):
  %(prog)s --config                         # Use default config file
  %(prog)s --config myconfig.ini            # Use specific config file

COMMAND LINE MODE:
  %(prog)s --source IMAGE.PNG --target BACKUPDIR [--random] [--interval SECONDS]

For complete documentation, see the comments at the top of this script.
        """
    )
    parser.add_argument('--config', '-c', nargs='?', const='fileMonitorAndNumberedSaves.ini',
                       help='Path to configuration INI file. If specified without a value, '
                            'defaults to "fileMonitorAndNumberedSaves.ini" in current directory.')
    parser.add_argument('--source', '-s', help='Path to the source file to monitor (command line mode)')
    parser.add_argument('--target', '-t', help='Target directory to save copies (command line mode)')
    parser.add_argument('--random', action='store_true',
                       help='Use 14-character random names instead of 6-digit padded numbers')
    parser.add_argument('--interval', '-i', type=float, default=1.0,
                       help='Check interval in seconds (default: 1.0)')
    parser.add_argument('--create-config', metavar='FILENAME',
                       help='Create a template configuration file and exit')

    args = parser.parse_args()

    # Handle config template creation
    if args.create_config:
        create_config_template(args.create_config)
        return

    # Auto-config behavior: if --config is used (with or without value)
    if args.config is not None:
        config_path = Path(args.config)

        # If config doesn't exist, show error and help
        if not config_path.exists():
            print(f"\nError: Config file not found: {config_path}")
            print("\nTo create a default config file, run the script with no arguments:")
            print("  python fileMonitorAndNumberedSaves.py")
            print("\nOr create a custom template:")
            print("  python fileMonitorAndNumberedSaves.py --create-config myconfig.ini")
            sys.exit(1)

        # Check for conflicting arguments
        if args.source or args.target:
            print("\n" + "="*60)
            print("NOTE: Using --config mode. --source and --target arguments are ignored.")
            print("The script will use paths from the config file instead.")
            if args.source:
                print(f"  Ignored --source: {args.source}")
            if args.target:
                print(f"  Ignored --target: {args.target}")
            print("="*60 + "\n")

        # Load config file
        try:
            monitor = FileMonitor(config_file=args.config)

            # Apply command line overrides
            overrides = []
            if args.random:
                monitor.naming_scheme = 'random'
                monitor.use_numbered = False
                overrides.append("naming scheme (→ random)")

            # Start monitoring with possible interval override
            monitor.watch(args.interval)

            # Report any overrides applied
            if overrides:
                print(f"\nCommand line overrides applied: {', '.join(overrides)}")

        except (ValueError, FileNotFoundError, KeyError) as e:
            print(f"Error loading config: {e}")
            print("\nTroubleshooting tips:")
            print("  - Check that your config file follows the INI format rules")
            print("  - Ensure naming_scheme is exactly 'numbered' or 'random' (no comments on same line)")
            print("  - Make sure all paths are valid and use proper escaping")
            sys.exit(1)

    # Command line mode
    else:
        if not args.source or not args.target:
            parser.error("--source and --target are required when not using --config")

        naming = 'random' if args.random else 'numbered'
        try:
            monitor = FileMonitor(source_path=args.source,
                                target_dir=args.target,
                                naming_scheme=naming)
            monitor.watch(args.interval)
        except (ValueError, FileNotFoundError, PermissionError) as e:
            print(f"Error: {e}")
            sys.exit(1)

if __name__ == "__main__":
    main()