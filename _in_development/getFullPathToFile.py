# DESCRIPTION
# Searches all PATHS in the operating system for a given file and returns the full path if found. For use with Python where (it seems) it doesn't search PATH "out of the box."

# TO DO: learn what every line of the source I adapt this from does, and correct, adapt or omit code lines as necessary (with any corrections from answers where the question was asked), re: https://codereview.stackexchange.com/q/123597/147213 -- AT THIS WRITING I find no change in script behavior for my purposes by commenting out the extensions-related code, so I comment that out. NOTE that the answer https://codereview.stackexchange.com/a/123602/147213 may have utility for me in searching sub-paths (I could adapt _ebPathMan functionality to not have to bother with sub-paths of a project folder).

import os

class CytherError(Exception):
    pass

def where(name, flags=os.F_OK):
    result = []
    # extensions = os.environ.get('PATHEXT', '').split(os.pathsep)
    # if not extensions:
        # raise CytherError("The 'PATHEXT' environment variable doesn't exist")

    paths = os.environ.get('PATH', '').split(os.pathsep)
    if not paths:
        raise CytherError("The 'PATH' environment variable doesn't exist")

    for path in paths:
        path = os.path.join(path, name)
        if os.access(path, flags):
            result.append(os.path.normpath(path))
        # for ext in extensions:
            # whole = path + ext
            # if os.access(whole, flags):
                # result.append(os.path.normpath(whole))
    return result

felf = where("genRandomColorsGrayMathGallery.sh")

print(felf)