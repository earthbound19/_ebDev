# \_ebDev scripts usage and developer notes

This is documentation on the scripts and related information in the [`_ebDev`](http://github.com/earthbound19/_ebDev) repository. This document is made on a hobby basis and may have errors, but I try to make it stylistically consistent, complete, and accurate.

The major sections of this document are:

- [**Collated Documentation**](#collated-documentation), which is description and usage etc. documentation from scripts etc. in the repository.
- [**\_ebDev Setup**](#\_ebdev-setup) describes how to set up this repository and its dependencies for use.
- [**Programming Notes**](#programming-notes) has notes related to programming these or any computer programming language scripts similar to them.

I use the term "scripts" more broadly than its actual meaning. While the great majority of files in this repository are computer scripts to be run via language interpreters such as Processing, Python, bash, not all of them are. Some are technical or configuration resources, notes etc., and documentation comments may be collated from those as well.

This document is available in these formats: [Markdown](https://earthbound.io/data/doc/_ebDev/_ebDev_Documentation.md) - [HTML](https://earthbound.io/data/doc/_ebDev/_ebDev_Documentation.html) - [Open Document Text](https://earthbound.io/data/doc/_ebDev/_ebDev_Documentation.odt) - [PDF ](https://earthbound.io/data/doc/_ebDev/_ebDev_Documentation.pdf) - [Word](https://earthbound.io/data/doc/_ebDev/_ebDev_Documentation.docx)


#### How this document is made

See the USAGE comments in [`makeDocumentation.sh`](https://github.com/earthbound19/_ebDev/blob/master/scripts/makeDocumentation.sh) for details, but in summary, it collates and parses documentation from comments in scripts, and combines that with a header and footer document into this larger document.

This is for convenience, but if you find a discrepancy between described behavior from anything collated here and actual script behavior, consult the documentation comments in a script itself. It may be that this document hasn't been updated after a script was updated, as the repository can be in high flux. To quickly locate and open a script, I usually use the [Everything Search Engine](https://www.voidtools.com/) on Windows (with a hotkey set to open the search window from anywhere) or CMD+P (file finder) in the Atom text editor on Mac, then open it for editing. (For Windows I assocaite script file extensions with a text editor so that double clicking it opens it to edit.) Also, if you don't find documentation for a script here, the script may be newer than the last time this document was regenerated.

#### Presentation format of documentation

Documentation for any script is presented after a header which gives the path to the script relative to the `/scripts` subdirectory.

Also, scripts may be listed in this ordering or rank:

- The format of the file (for example `.sh` for bash scripts or `.py` for Python scripts, by order of what I like best for creative coding purposes first.
- When the file was first committed to git, newest first. This is accomplished by updating file modification (and in Windows creation) times to that, via `setFileTimestampsToEarliestGitCommit.sh`.
- However, because I may modify (and commit changes to) files already tracked in git, that ordering may change to show newly modified files first.

The result may be a hybrid rank of what type of script I find most interesting and/or most recently modified.

Also, collated documentation comments may refer you to functional code below the comments, but that code is not copied into this document (only documentation comments are). You must find and open the source code files themselves to look at the functional source code.

## COLLATED DOCUMENTATION