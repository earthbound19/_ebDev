# DESCRIPTION
# Takes an input file of a flat list of unique elements with some duplicates, of length M, and reduces it to (lesser) length N by removing from adjacent duplicate elements, one per group of unique elements, iteratively until it is of length N. And intended purpose is reducing .hexplt pallete files with duplicate colors while maintaining some duplicate colors (for example as placeholders to later interpolate between the start duplicate color and the next color change N spaces away).

# USAGE
# Run with these parameters:
# - -i | --inputFile REQUIRED. Path to the input file.
# - -r | --reduce-to-count-n REQUIRED. How many elements to attempt to reduce the input list to.
# For example, given an input file named input.txt with these contents, which is 13 elements:
#    a
#    a
#    b
#    b
#    b
#    b
#    c
#    c
#    c
# Call this script with these parameters:
#    reduceListByUniqueElementsToCountN.py -i input.txt -r 6
# -- and it will print this reduction of the file, to 8 elements, to stdout:
#    a
#    b
#    b
#    b
#    c
#    c
# NOTES
# To capture the output to a new file, you can use the redirect operator e.g.
#    reduceListByUniqueElementsToCountN.py -i input.txt -r 6 > output.txt
# - The script will catch cases where it can't do its work, and throw errors. That includes an input list shorter than the count for -r, a source list with no duplicate elements, or a source list with too many unique elements to reduce to -r.
# - What is meant by "..removing from adjacent duplicate elements, one per group of unique elements, iteratively," is this; in the example, there are two letter 'a's, four letter 'b's, and three letter 'c's, and with -r 6 we tell it to reduce to six elements. It makes groups out of the a, b and c elements, and iterates over those groups, removing one from each per iteration. That means that at the first iteration, it has this:
#    a
#    b
#    b
#    b
#    c
#    c
# -- and the total count of all those elements is 6, so it stops. If we passed it -r 4, it would end up with this:
#    a
#    b
#    b
#    c
# -- and -r 3 would end up with just a, b and c. You can of course use much larger and more complex lists; the simpler list is given here for illustation purposes.
# - This was developed with the assistance of a large language / code model chatGPT, and I don't know the intricacies of how it works. I just know that I described the intended algorithm clearly enough (finally--it took many frustrated tries) for it to do what I want after testing. The chat archive for this is: https://chatgpt.com/share/7bff6174-7342-4904-a06d-2a44be310b5e


# CODE
import argparse
import itertools

def reduce_list(inputList, reduceToElementsN):
    def get_adjacent_unique_elements(lst):
        """Helper function to split list into adjacent unique groups."""
        grouped = []
        for key, group in itertools.groupby(lst):
            grouped.append(list(group))
        return grouped

    def recombine_list(adj_unique_elements):
        """Helper function to recombine the adjacent unique elements."""
        final_list = []
        for group in sorted(adj_unique_elements, key=lambda x: x[1]):
            final_list.extend(group[0])
        return final_list
    
    # Initial validations
    if not inputList:
        return ["Error: The source list is empty."]
    
    if reduceToElementsN <= 0:
        return ["Error: reduceToElementsN must be a positive integer."]
    
    # Step 1: Parse the input list
    adj_unique_elements = []
    last_element = None
    for index, element in enumerate(inputList):
        if element != last_element:
            if last_element is not None:
                adj_unique_elements.append((current_group, original_index))
            current_group = []
            original_index = len(adj_unique_elements) + 1
            last_element = element
        current_group.append(element)
    
    # Don't forget to append the last group
    if current_group:
        adj_unique_elements.append((current_group, original_index))
    
    # Error handling for the list with no duplicates
    if len(adj_unique_elements) == len(inputList):
        return ["Error: The source list does not have any duplicate elements."]
    
    # Calculate the total number of elements
    total_elements = sum(len(group[0]) for group in adj_unique_elements)
    
    # Error handling if it's impossible to reduce to reduceToElementsN
    if reduceToElementsN > total_elements:
        return ["Error: The source list is shorter than reduceToElementsN."]
    
    if reduceToElementsN < len(adj_unique_elements):
        return ["Error: The source list cannot be reduced to the specified number of elements."]
    
    # Step 2: Reduce the list
    while sum(len(group[0]) for group in adj_unique_elements) > reduceToElementsN:
        reduction_done = False
        for i in range(len(adj_unique_elements)):
            if len(adj_unique_elements[i][0]) > 1:
                adj_unique_elements[i] = (adj_unique_elements[i][0][:-1], adj_unique_elements[i][1])
                reduction_done = True
                if sum(len(group[0]) for group in adj_unique_elements) == reduceToElementsN:
                    return recombine_list(adj_unique_elements)
        # If no reduction was done, exit the loop
        if not reduction_done:
            break

    # Return the recombined list if reduction completed
    return recombine_list(adj_unique_elements)

def main():
    parser = argparse.ArgumentParser(description='Process and reduce a list of elements.')
    parser.add_argument('-i', '--inputFile', type=str, required=True, help='Path to the input file.')
    parser.add_argument('-r', '--reduce-to-count-n', type=int, required=True, help='Number of elements to reduce to.')

    args = parser.parse_args()
    
    try:
        with open(args.inputFile, 'r') as file:
            inputList = [line.strip() for line in file]
    except FileNotFoundError:
        print(f"Error: File {args.inputFile} not found.")
        return

    # Process the input list
    result = reduce_list(inputList, args.reduce_to_count_n)

    # Print the final list elements, one per line
    for element in result:
        print(element)

if __name__ == "__main__":
    main()