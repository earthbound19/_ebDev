# DESCRIPTION
# Prints a modification of a palette where adjacent duplicates are changed to a gradient to the next different color. Takes an input .hexplt palette file and modifies it such that any adjacent duplicate colors in it are changed to interpolate from the first duplicate of the color until the next changed color, at N interpolation steps, where N is the number of adjacent duplicates. Interpolation is done with an external script which may be overridden.

# DEPENDENCIES
# `interpolateTwoSRGBColors_coloraide.py` or any alternate interpolation script which you may provide as a parameter. See USAGE.

# USAGE
# See help print from calling this script with no parameters.
# NOTES
# - Results printed to stdout; you may capture them to a file with e.g. a redirect operator:
#    printPaletteDuplicateColorsInterpolated.py -i 182_2tsudrw7_palette.hexplt > result.hexplt
# -- or call this script from another script and capture the output.
# - If the input file ends with a series of duplicate colors, a gradient is made from the last duplicate color to the previous different color.
# This code is a collaboration between a human and a large-language model tuned to "know" things about code and a lot of things. Changes for final use were by me and I don't know how the details work. Source at chatGPT: https://chatgpt.com/share/82b84cb6-28bf-45b5-bac1-fc0e72e3bd10


# CODE
import os, sys, subprocess, shutil, argparse

parser = argparse.ArgumentParser(description='Prints a modification of a palette where adjacent duplicates are changed to a gradient to the next different color. Takes an input .hexplt palette file and modifies it such that any adjacent duplicate colors in it are changed to interpolate from the first duplicate of the color until the next changed color, at N interpolation steps, where N is the number of adjacent duplicates. Interpolation is done with an external script which may be overridden. Results printed to stdout; capture them to a file with e.g. a redirect operator. If the input file ends with a series of duplicate colors, a gradient is made from the last duplicate color to the previous different color.')
parser.add_argument('-i', '--INPUTFILENAME', type=str, required=True, help='Path to input file.')
parser.add_argument('-e', '--EXTERNALSCRIPTFILENAME', type=str, required=False, default='interpolateTwoSRGBColors_coloraide.py', help='File name of external script, in your PATH, expected to manupulate values passed to it and return the manipulation to stdout, which this calling script will patch over a changed copy of -i printed to stdout. Default interpolateTwoSRGBColors_coloraide.py if not provided. NOTE that any alternate script used must use the same parameters which this default external script expects: -s, -n, and -e. At this writing, alternate scripts untested. It may be possible to use additional parameters to an external script by enclosing them with the script name in single quote marks.')
args = parser.parse_args()

inputFileName = args.INPUTFILENAME
externalScriptFileName = args.EXTERNALSCRIPTFILENAME
# print('inputFileName is', inputFileName)
# print('externalScriptFileName is', externalScriptFileName)

def find_script_in_path(externalScriptFileName):
    # Search the system PATH for the script
    return shutil.which(externalScriptFileName)

def invoke_script(script_path, first_element, count, next_element):
    if script_path is None:
        print(f"Script '{script_path}' not found in system PATH.")
        return None
    
    # Ensure next_element is a string; replace None with an empty string
    next_element = next_element if next_element is not None else ''
    
    # Construct the command
    command = [
        'python', script_path, '-s', first_element, '-n', str(count), '-e', next_element
    ]
    
    # Execute the command and capture the output
    result = subprocess.run(command, capture_output=True, text=True)
    
    if result.returncode == 0:
        # Assume the script returns the output as a flat list of elements
        return result.stdout.strip().split('\n')
    else:
        print(f"Error running script '{script_path}': {result.stderr}")
        return None

def parse_elements_with_indices(inputFileName):
    with open(inputFileName, 'r') as file:
        elements = [line.strip() for line in file.readlines()]
    
    element_info = []
    current_element = None
    start_index = None
    count = 0
    
    for i, element in enumerate(elements):
        if element == current_element:
            count += 1
        else:
            if current_element is not None:
                element_info.append({
                    'element': current_element,
                    'count': count,
                    'start_index': start_index
                })
            current_element = element
            start_index = i
            count = 1
    
    # Handle the last element in the list
    if current_element is not None:
        element_info.append({
            'element': current_element,
            'count': count,
            'start_index': start_index
        })
    
    return elements, element_info

def patch_and_print(elements, element_info, externalScriptFileName):
    # Find the script in the system PATH
    script_path = find_script_in_path(externalScriptFileName)
    
    for i, info in enumerate(element_info):
        if info['count'] > 1:
            # Handle the last element safely
            if i + 1 == len(element_info):
                # Special case: duplicates at the end of the list
                previous_element = element_info[i - 1]['element'] if i > 0 else None
                next_element = info['element']
                count = len(elements) - info['start_index']
                count_plus_one = count + 1
                
                # Invoke the external script with the parameters
                modified_values = invoke_script(script_path, previous_element, count_plus_one, next_element)
                
                if modified_values:
                    # Remove the first element from the modified values
                    modified_values = modified_values[1:]
                    # Patch the original list with the modified values
                    elements[info['start_index']:info['start_index'] + len(modified_values)] = modified_values

            else:
                # Normal case
                next_element = element_info[i + 1]['element'] if i + 1 < len(element_info) else None
                count = info['count']
                count_plus_one = count + 1
                
                # Invoke the external script with the parameters
                modified_values = invoke_script(script_path, info['element'], count_plus_one, next_element)
                
                if modified_values:
                    # Remove the last element from the modified values
                    modified_values = modified_values[:-1]
                    # Patch the original list with the modified values
                    elements[info['start_index']:info['start_index'] + len(modified_values)] = modified_values

    # Print the final elements, one per line
    for element in elements:
        print(element)

# Process the file and get element information
elements, element_info = parse_elements_with_indices(inputFileName)

# Patch and print the final modified list
patch_and_print(elements, element_info, externalScriptFileName)