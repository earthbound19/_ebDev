# DESCRIPTION
# Prints information about a Python module, such as functions. re: https://stackoverflow.com/a/31005891

# USAGE
# Run through the Python interpreter, with this script as the first parameter (to python) and the script to analyze as the second parameter:
#    python /path_to/this_script/analyse_module.py module_script.py


# CODE
import ast
import sys

def top_level_functions(body):
    return (f for f in body if isinstance(f, ast.FunctionDef))

def parse_ast(filename):
    with open(filename, "rt") as file:
        return ast.parse(file.read(), filename=filename)

if __name__ == "__main__":
    for filename in sys.argv[1:]:
        print(filename)
        tree = parse_ast(filename)
        for func in top_level_functions(tree.body):
            print("  %s" % func.name)