## \_ebDev SETUP

Many of these scripts have dependencies beyond what are included in your typical GNU core utilities.

To run any of them your operating system must be capable of that and/or you must be able to install things on your operating system to run them, for example:

- `Python` for `.py` scripts
- `bash` for `.sh` scripts
- `DOS` for `.bat` files

Many of these scripts were tested and found to work with both a Unix emulation layer on Windows (such as Cygwin or MSYS2), and also MacOS. Very few of the scripts have been tested on any Linux or other GNU variants, but they will probably work on many of those.

### \_ebDev DEPENDENCIES installation

All the scripts are designed under the assumption that they can be located by your operating system via the PATH environment variable. If you're not sure what that means, see these tutorials:

- A [Unix/Mac-oriented description of the PATH](https://astrobiomike.github.io/unix/modifying_your_path).
- A [DOS-oriented tutorial on PATH](https://www.robvanderwoude.com/path.php).

The scripts can be either dynamically added to the PATH on terminal launch via terminal customization, or permanently (for example as SYSTEM variables in Windows, or via bash profile customization on Unix variants). Sometimes a script calls another script or utilities assumed to be in your PATH.

Many of the bash (`.sh`) scripts that don't call other scripts may be usable locally (if not in your PATH) if you `cd` into their directory, or copy them to a directory with files they would operate on, and then run them with `./` and then the script file name immediately after that, and then any parameters they require as documented in each scripts' USAGE section. `./` means "this directory" to the terminal. For example, if `randomString.sh` is not in your path, you may copy it to any directory, open that directory in the terminal, and run it with `./` before it, like this, to create 12 random strings of length 34:

    ./randomString.sh 12 34
    
    GG67Apt2GnpDkyDPAGn3tPmeAsjACazrRe
    4UYs7tWJWzdueZwvhgpp3hnRzHpGYJQSNt
    7AtkAWXMNQb2pqQY5UgZeAAfWGEwSemsjs
    ZwVSdGpvdmyckfVFMWVgWvxHWVsSmygb5N
    uGh3hpVdsrJ8QqNjFueem8kMyBF6DvhGnm
    AkMgBH68NUAmtQtQ3Jb5RzJuDAW28BqnEq
    d2Tw9jhSRjZDeRpGxfADH5EGDsd9mA6skP
    wmehvT7aq4ZuFRyhYdvYQgZb4yRCjMagES
    MKTna3uFJVx7KbbPD7jRhMEWxBC8nfyRGA
    rhaMnY5AUKxNdtMJEEPvNKEmgW3hq9Tn6Z
    UH64yNkMHs2uPvMtr3D8MfY2XSc39zdBrr
    E9XZyEZpzb4WhFdmTMWpeSTcSxgcBpDk9f

You may want to use utility scripts I wrote and/or utility binaries to get these scripts into your PATH. Explanations of those follow.

#### \_ebPathMan

See the [README.md](https://github.com/earthbound19/_ebPathMan/blob/master/README.md) for `\_ebPathMan` for instructions on how to use scripts/utilities in that repository to get collections of scripts etc. into your PATH, either permanently or dynamically.

#### \_ebSuperBin

A collection of binary utilities etc. See [that repository's](https://github.com/earthbound19/_ebSuperBin) README.md.

#### MacOS dependency/utility managers

- For MacOS dev headers run this, but change the version string to match your version of MacOS; re: https://github.com/pyenv/pyenv/issues/1219
        sudo installer -pkg /Library/Developer/CommandLineTools/Packages/macOS_SDK_headers_for_macOS_10.14.pkg -target /
- Setup and miscellaneous utilities: managed via `macDevSetup.sh` and `installUsedBrewPackages.sh`. Many scripts in this repository are designed to use versions of utilities that those scripts will get into your PATH, and will not work without that setup.
- `Python`: I manage python versions on Mac via `pyenv` (which I prefer over `asdf`, which I think I used and ran into trouble)
- `nodejs`: I manage node versions with `asdf`.

#### Various admin utilities

Examine the scripts etc. in `/scripts/admin`.

### Formats unique to this repository

This repository has scripts that make use of custom file formats. Ones that I remember as I write this (there may be others) are:

- `.hexplt`
- `.rgbplt`
- `.cgp`

A `.hexplt` file is a list of RGB colors expressed as hexadecimal color codes, preceded by a pound or hash sign, one per line. You will find a large collection of these in my [_ebPalettes](https://github.com/earthbound19/_ebPalettes) repository. I acknowledge that many of them have horrible file names that nobody would be able to remember, but the best I can do for so many random palettes is to randomly name their files. Here are links to:

- One such [palette file](https://github.com/earthbound19/_ebPalettes/blob/master/palettes/adobe_color_most_popular_all_time_snapshot/grp_0648/ZGnDYCwi.hexplt).
- A [png render of it](https://github.com/earthbound19/_ebPalettes/blob/master/palettes/adobe_color_most_popular_all_time_snapshot/grp_0648/ZGnDYCwi.png)

This format may already exist under another name somewhere else; I don't know. I am aware that there are other palette formats, but I found them opaque (pun not intended), so I contrived this format. Other formats I have encountered are _binary_ (machine-readable only). I don't see that as useful for easy reference and use by scripts.

An `.rgbplt` format file is analogous to `.hexplt` but without any `#` at the start of list items, and it lists decimal RGB values: three numbers between 0 to 255 per line, separated by spaces.

A `.cgp` file is a color growth preset to be used with `color_growth.py`. Examine the usage comments in the source code of that script and/or the output from `python color_growth.py --help` for details.

### Functional choices for arguments to scripts

For some idea of how arguments to scripts work, examine [this tutorial](https://linuxize.com/post/bash-functions/#:~:text=Bash%20Functions%201%20Bash%20Function%20Declaration%20%23.%20The,allow%20you%20to%20return%20a%20value%20when%20called.) and [this StackOverflow answer](https://stackoverflow.com/a/6212408/1397555). Arguments to bash scripts work the same way as arguments to bash functions.

Two possibilities for parameters to scripts are positional parameters and named parameters.

Positional parameters must always specificy exactly the right kind of argument in exactly the right order, like this example, where the structure of the command to run the script is extremely strict, like `scriptName numericArgument stringArgument`:

	script.sh 14 SNORFBLURN

Named parameters may be designated with switches, and offers more flexibility, with a run command structure like `scriptName [-n numericArgument] [-s stringArgument]`:

    script.sh -s SNORFBLURN -n 14

(Note how the order of `-n` and `-s` were switched there: named arguments may be in any order).

The vast majority of scripts in this repository take positional arguments (or parameters), for these reasons:

- If there are not many arguments, it's simplest to program them that way and simple enough to look up the arguments before I run the script (or code another script to run a script).
- In practice, I very often look at the USAGE comments in the source code to remember them anyway. No way do I remember all these things. That's why I write useful USAGE etc. comments.
- There is only one script in the whole repository which has named parameters that I care enough about to remembember any (but not all!) of them, and for which positional parameters would be more difficult to use, as there are too many possible arguments to easily reference and remember them by position.

## PROGRAMMING NOTES

On one hand, I only want to write things in this section that I would have difficulty remembering (I am motivated to write things down that I would forget; if it is knowledge I take for granted, I don't have a need to write it down for myself). On the other hand, I'm interested in providing information that might be educational to others who are learning. The former purpose may usually win.

Also, I could be quite wrong about the best or proper way to do anything, and I can't guarantee the suitability of this information for any purpose.

A history of a kludge: I have gone back and forth on using versions of four ported tools from Unix: `sed`, `find`, `sort`, and `uniq` as copies from various windows/Mac ports but renamed as `gsed`, `gfind`, `gsort`, and `guniq`, in a subfolder of the `\_ebSuperBin` repository which I include in my PATH on Windows. But I found that MSYS2 updates would leave me with errors about possible cygwin1.dll version conflicts, and broken script runs. So I stopped copying/renaming those GNU utilities to that repo, and instead I use the ones as provided by MSYS2, which it keeps current and in the MSYS2 user bin folder(s), and as originally named (I don't rename them). But there may be scripts in `/_deprecated` that have the names I don't want to use anymore; to further develop or revive any of those use the proper (not `g`-prefixed) names.

Note that tools and scripts in this repository are subject to high flux, because I may edit and develop them as I use them or discover bugs, and/or because I may freely add or remove anything from this archive. Generally I move anything not useful (or redundant) to the `\_deprecated` folder. Things under development or suspended for bugs are in the  `\_in_development`. folder. I have even deliberately rewritten git history at times in the project (to cut down repo bloat).

### Portable scripts

For easier interoperation on various platforms, most of the files in this repo may have Unix line endings, even if they are developed in Windows. I configure my text editor to create Unix line endings by default (which many free and advanced text editors can do). This is only important if you open a file in a text editor that doesn't even know what Unix line endings are. Any modern editor worth using will transparently adapt to whatever line ending style is in any file.

If you want to create computer scripts that can be run on multiple operating systems, some portability concerns (the ability to run a program on different operating systems, or the ability to easily port it to do so) come into play. So do opinions about scripting languages and the utility of them even if they are portable.

When I discovered I can emulate bash scripting via Cygwin on Windows, and that the scripts had hope of running on Unix variants (like MacOS and Linux), _and_ that the bash scripting language is so much more elegant and easy to use, I forsook `.bat` scripts and only looked back when necessary.

Python and Processing are also cross-platform.

If anyone has brought Windows' DOS/CMD/`.bat` scripting to other platforms, I don't know why and I frankly might not care.

#### Unix vs. Windows-style newlines

Windows encodes line endings in text files etc. differently than Unix and Unix variants. Some Unix tools ported to Windows return and manipulate Windows line endings, where other Unix tools don't. The result is that line endings are incompatible between tools that look for one type vs. tools that look for another type, and it breaks things. I have had to dig to that as a root cause of data processing errors many times, but switching to MSYS2 (vs. Cygwin) greatly reduced those headaches.

The `tr` tool can delete Windows newlines from a stream like this:

    cat fileWithWindowsNewlines.txt | tr -d '\15\32'

dos2unix will also change Windows newlines (and possibly other Windows-specific problems like unexpected codepages):

    dos2unix fileWithWindowsNewlines.txt

### Cygwin and MSYS2

MSYS2 is a lightweight GNU emulation toolset and compiler environment for Windows. So is Cygwin. But Cygwin is less lightweight. In early development I used only DOS batch scripts. Later I discovered Unix emulation via Cygwin, and oh how liberating and how much easier bash scripting was. But Cygwin gave me nightmares related to Windows newlines, and I looked for something better and found that in MSYS2.

#### Quickly open MSYS2 terminal to open folder in explorer

See `install_MSYS2_right_click_menu.reg` and/or [my fork of msys2-mingw-shortcut-menus](https://github.com/earthbound19/msys2-mingw-shortcut-menus).

#### Quickly open MSYS2 terminal to path

To clone an open MSYS2 terminal in the same path (for example without interrupting a long run of a script), and launch Windows' file explorer in that path:
- Right-click MSYS2 terminal title bar
- Click "New"
- In the open terminal, type:

    start `pwd`

This uses the fact that the Windows shell environment will interpret a command which is a path to simply open that path in file explorer, and that bash takes something surrounded by backticks to mean "execute this, then pass it to the previous command. `pwd` returns the current path, and MSYS2's terminal automagically converts the unixy path to a Windows path, and passes it to the command `start`.

### Python

#### Python script parameters: switches and named parameters

For switches and named parameters, see how things are handled in `color_growth.py.`

#### Python script parameters: positional and exit if omitted

The below example is copied from `paletteCompareCIECAM02.py`. It checks the length of `sys.argv` to identify whether a required parameter was provided, and if not, prints a helpful error and quits with an error code.

	import sys
	
	if len(sys.argv) > 1:       # positional parameter 1
		hexpltFileNameOnePassedToScript = sys.argv[1]
	else:
		print('\nNo parameter 1 (source .hexplt palette file one) passed to script. Exit.')
		sys.exit(1)
	if len(sys.argv) > 2:       # positional parameter 2
		hexpltFileNameTwoPassedToScript = sys.argv[2]
	else:
		print('\nNo parameter 2 (source .hexplt palette file two) passed to script. Exit.')
		sys.exit(1)

### Bash fundamentals

#### Pipe and redirection operators

Piping with the `|` operator is very common in scripting operations that I do. A pipe passes the result of the command on the left to the command on the right. A lot of Unix and Unix-like tools are designed to do this. Here is [documentation on pipe or pipeline operators](https://www.gnu.org/software/bash/manual/html_node/Pipelines.html#Pipelines).

I also use the redireciton operators `<` and `>`. Here's [a link to documentation on the redirect operators](https://www.gnu.org/software/bash/manual/html_node/Redirections.html).

#### Error Level

Bash has a built-in variable, `$?`, which is assigned the error level (or exit code) of the previous command. By convention when there was no error with a command, error level is set to `0`.

So, for example, to check whether an executable was run successfully (and thereby infer that it is in the PATH and probably works as expected), you can call any executable and then check the error level variable:

    ffmpeg --help
	if [ "$?" == "0" ]; then echo "No error (error level 0) after run of ffmpeg. Assumed to be in PATH and working."; fi

#### stdout and or stderr redirection

If I want to check that a command succeeds, but I don't want to print the output of the command, I'll redirect both `stdout` and `stderr` to `/dev/null`:

    ffmpeg --help &>/dev/null

Over here is a tutorial on [stderr/stdout redirection](https://www.cyberciti.biz/faq/redirecting-stderr-to-stdout/).

Or to redirect both stderr and stdout to a file:

	some command &>log.txt

#### Find the full path to a script in your PATH

See `getFullPathToFile.sh` to work around the problem of `which` and `whereis` being unhelpful finding paths to things on different platforms.

#### Bash initialize variable from result of command

In bash, you can create variables and initialize them with values returned from commands, via command substitution.

A practical example is to get a random number in a range, and assign it to a variable. By piping commands and results from `seq`, `shuf`, and `head -n 1`, we can obtain a random number in a range. `seq` will print numbers in a sequence, like this:

    seq 1 5

Example result output:

	1
	2
	3
	4
	5

If we pipe that `seq` command to shuf (with the pipe operator (`|`), it will take the lines of the input stream and rearrange them randomly, then print them:

    seq 1 5 | shuf

    4
    3
    2
    5
    1

If we pipe _that_ to `head -n 1`, it will print only the first line of the output:

    seq 1 5 | shuf | head -n 1

	3

(If you piped it to `head -n 2`, it would print the first two lines, and `head -n 3` would print the first three, and so on).

If we enclose the series of commands in a dollar sign and parenthesis (which is called command substitution), it is evaluated and we can assign the result to a variable, like this:

    randomNumber=$(seq 1 5 | shuf | head -n 1)
    echo $randomNumber

    4

You can also evaluate and assign it to a variable via backticks, like this:

    randomNumber=`seq 1 5 | shuf | head -n 1`

But you may run into problems, depending, if you use backticks for command substitution. Here are sources on that: [(1)](https://pubs.opengroup.org/onlinepubs/9699919799/xrat/V4_xcu_chap02.html#tag_23_02_06_03) [(2)](https://wiki.bash-hackers.org/syntax/expansion/cmdsubst)

### Bash arrays

A perhaps broader tutorial and reference is [over here](https://www.thegeekstuff.com/2010/06/bash-array-tutorial/).

#### Bash array creation

To create an array from every file of a type, e.g. png, use the find command (here, including a print command that chops off the leading `./` from every result:

    array=( $(find . -maxdepth 1 -type f -iname \*.png -printf '%f\n') )

The second set of parenthesis is explained in this [this StackOverflow answer](https://stackoverflow.com/a/28704824/1397555).

Previously I have created variables by enclosing a command in backticks, but I've learned that can present undue difficulties. Also, I've previously not enclosed the whole command substitution (of the syntax `$()` in further parenthesis (like `( $() )`. To not enclose it in parenthesis, I think, leaves the result as a string (collection of characters), which you may be lucky (depending on how you create it, and maybe also depending on the "Internal Field Separator" or IFS) to be able to count or iterate over. Enclosing it in parenthesis makes it an array.

Another way to create such an array, but sort by file date (and without explanation of `sort` and `sed` here):

    array=( $(find . -name "*.png" -print0 -printf "%T@ %Tc %p\n" | sort -n | sed 's/.*[AM|PM] \.\/\(.*\)/\1/g') )

A way that may work better where the result list would be extremely long (which can cause "too long" errors, depending) is to redirect the result via `>` to a file, then scan every line of the file and perform an operation related to that `$line`, like this:

    find . -maxdepth 1 -type f -iname \*.png -printf '%f\n' > allPNGs.txt
    while IFS= read -r line || [ -n "$line" ]; do
        echo "$line"
    done < allPNGs.txt

Also, this can work:

    readarray -d '' array < <(find . -name "*.png" -print0)

Which results in an array named `array`. Or this, to create an array from every line of a text file:

    array=( $(<inputFile.txt) )
	
Again note the extra parenthesis. They become important if you want to know the length of the array, which is 1 if you don't use parenthesis, because it is not an array if you don't use parenthesis. With parenthesis, the length may be more than one.

#### Bash array subscripting (access array element by index)

Arrays created by all of the above methods are subscriptable; you may access the array elements by index; here is an example for index 4:

    echo "${array[4]}"

	SNEERFBLURN.png

#### Bash array iteration (loop over array)

To iterate over elements of an array and do something with each element:

    for element in ${array[@]}
    do
        echo $element
    done

	chalf
	flibflub
	chulfor
	hooligan
	plibplup

#### Get bash array length

To get the length of an array use `#` inserted in the expression that means "all elements of the array," as follows. These commands create an array of all file names that end with `.txt` in the current directory via a `find` command, then echo the length of the array:

    arr=(`find . -maxdepth 1 -iname \*.txt -printf '%f\n'`)
    echo ${#arr[@]}

Example output:

    8

#### Change a bash array

Suppose you have an array named `directories`, which is the names of all (sub-)directories in your working folder, which you can verify by looping over its contents:

	for element in ${directories[@]}; do echo $element; done
	.
    flarf
    fleur
    florf
    flurf

Suppose also that if you loop over the array and try to do something with the directory `.` (the first element in the array, which is the current directory), your script would do something unexpected, so you don't want that first element of the array. You want to remove it. You can do that like this:

	 directories=(${directories[@]:1})

This might be called "array slicing," I don't know. `:2` will list everything but the first two elements of the array, `:3` will list everything but the first 3, and so on.

I have not had occasion, using bash, to remove or insert specific elements into an array at specific indices. Python does that more easily.

#### Combine bash arrays into one new array

Adapted from TheGeekStuff; if there are duplicates between the arrays they will appear more than once in the new array:

    FLORFELF=('BLORB' 'CHURF' 'LORGL' 'HORCHUF' 'BLEURG');
    BLUBARG=('CHOWF' 'HULP' 'GLOR' 'GLARG' 'FLORG' 'MURG' 'BELG');
    OMNIBLARG=("${FLORFELF[@]}" "${BLUBARG[@]}")

### Bash file information and manipulation

#### Bash count files of type in current directory

To count the number of files of a given type, for example png, run this command:

    ls *.png | wc -l

`count.sh` is a shortcut to this; pass it only the file type with no period:

    count.sh png

count.sh prints the result:

    42

#### Bash get file name without extension

If you have a variable named `filename` with a value `2020_07_15__08_32_50____62b144_colorGrowthPy.png`, this will create a new variable named `fileNameNoExt` without the `.png` at the end (just `2020_07_15__08_32_50____62b144_colorGrowthPy`:

    fileNameNoExt=${filename%.*}

#### Bash get extension of file name

If you have a file named `image.png` stored in a variable named `filename`, this will get the file extension (`png` and store it in the variable `fileExt`:

    fileExt=${filename##*.}

#### Bash get file name without path

This takes a variable whose (string) value is a path to a file and then a file name, and isolates it to just the file name (no path), and assigns it to the variable fileNameNoPath:

    fileNameWithPath='2djio/fefe/fjifeif.txt'
    fileNameNoPath="${fileNameWithPath##*/}"
    echo $fileNameNoPath

    fjifeif.txt

This can also be done with `basename` and command substitution (`fileNameNoPath=$(basename $fileNameWithPath)`), but I prefer this as it avoids even calling an executable (the `echo` command here calls an executable, but that is only to demonstate that it worked. In a script it could be a command with or without echo that makes use of the variable).

#### Bash get path without file name

This takes a variable whose (string) value is a path to a file and then a file name, and isolates it to just the path to the file (no file name), and assigns it to the variable pathNoFileName:

    fileNameWithPath='2djio/fefe/fjifeif.txt'
	pathNoFileName="${fileNameWithPath%\/*}"
    echo $pathNoFileName

    2djio/fefe

This can also be done with `dirname` and command substitution (similarly to the `$fileNameNoPath` example), but here again this avoids calling an external executable (it may be faster).

#### Bash get full path to current directory

This will store the full path of the current directory in a variable named fullPath:

    fullPath=$(pwd)

#### Bash get name of current directory (without path)

This will get the name of the current directory, without the path to it, and store it in a varaible named currentDirNoPath:

	currentDirNoPath=$(basename $(pwd))

(That was nested command substitution.)

### GNU sed

Sed is a GNU (Gnu is Not Unix) core utility. General sed notes:

The sed (stream editor) tool can work with input from a statement made before it via a pipe (`|`):

An example using the echo tool, which prints to the terminal any statement after it:

    echo fleur fleur chalp fleur chulp | sed 's/fleur/flarf/g'

That command results in every instance of the word `fleur` being replaced with `flarf`:

    flarf flarf chalp flarf chulp

The `s` in that command means search, and the `g` at the end of it means "replace every instance of the replacement expression found." Everything between the first and second slashes (`/`) is the search expression, and everything between the second and third slashes is the replace expression.

Some versions of sed work okay without surrounding the command/search/replace expression with single or double quotes, but some don't, so I always surround them.

To overwrite a file with the results of a sed stream edit, use the `-i` switch with sed, and give the file name after the sed search/replace expression:

    sed -i 's/fleur/flarf/g' wut.txt

If you omit the `-i` flag, sed leave the file as-is and print the stream edit result to stdout.

I often use regex groups for sed, like:

    (.*)

That means "group any character (`.`), any number of times (`*`)).

I also use character count ranges, like:

    [a]{2,}
	
That means "two or more `a` characters) in sed. But in the terminal and scripts, because parenthesis (`()`) and curly braces (`{}`) have programmatic functions, they must be escaped for sed to use them instead of the terminal. Those are escaped by prefixing them with a backslash (`\`).

So, the previous two example expressions, escaped for sed, become:

    \(.*\)
	[a]\{2,\}

#### sed optional character or group match

To make a character or group in an expression optional (so that it may be matched zero or more times), use `{0,}` after a character or group in the match expression:

    [a]\{0,\}

That means "zero or more of the character `a`".

Practical example: delete comment markup (`#`) from the start of line, and optionally also delete any space after the comment marker (`# `), but keep the rest of the line (the rest of the line captured with `(.*)` and put into the replace expression with `\1`:

    echo '#flurfefl' | sed 's/^#[ ]\{0,\}\(.*\)/\1/g'

#### sed insanity with newline replacement and repeated pattern

These are notes on a very particular text processing case I had for my wants for this documentation, but it references things that might be useful in other cases.

Before arriving at this I ventured off into Perl instead to try to solve this; I had no success. The match I wanted was easy-peasy in regex101.com, but the Perl CLI did not agree. Code golf: anyone able to do this with Perl?

My criteria:

- Join newlines in the stream for sed to edit (where ordinarily sed operates line-by-line so that it can't see newlines in a match expression)
- Repeat a grouping with a pattern

Reference:

- Joining lines: https://stackoverflow.com/a/1252191/1397555
- Repeat a pattern: https://Unix.stackexchange.com/a/155385/110338

The sed expression:

    sed -i -e ':a;N;$!ba;s/\( \{2,\}[^\n]*\n\)\{2,\}/\n&\n/g' parse.txt

What that expression does is break any lines with at least two spaces at the start of them, and which are one after another:

```
Blah blablabla blah mcbla blah blah
    img_01.ppm
    img_01.png
    img_02.ppm
    img_02.png
Blor mcblorblah blahblah blah mcblor
more blor mcblorblah
    img_01.ppm
    img_02.ppm
    img_02.png
    img_03.ppm
More blahdy blah blah blah
```

into a group with newlines before and after the group, but no newlines within the group:

```
Blah blablabla blah mcbla blah blah

    img_01.ppm
    img_01.png
    img_02.ppm
    img_02.png

Blor mcblorblah blahblah blah mcblor
more blor mcblorblah

    img_01.ppm
    img_02.ppm
    img_02.png
    img_03.ppm

More blahdy blah blah blah
```

### DOS / CMD command prompt

#### Permanent command history for CMD via third-party tool

The `CMD` prompt and Windows do not store a permanent command history, which is a feature I find very handy. However, a third-party tool can provide it! If you use the `CMD` prompt, I strongly suggest you install [`clink`](http://mridgers.github.io/clink/) (I install it via `chocolatey`), which provides this feature. With `clink` installed, you can close a `CMD` prompt, open a new one, type the up arrow, and see your previously typed command (and ones before it with further up arrow presses, and cycle to newer ones again with down arrow key presses). Without it (as Windows/CMD is natively built), you don't get that.

#### Quickly open Windows CMD prompt to same path as MSYS2 terminal

From an MSYS2 terminal, type and enter:

    `cmd`

The Windows command prompt starts right in the MSYS2 terminal interactively.

#### Quickly open Windows cmd prompt anywhere

To install a right-click menu for folders and folder backgrounds to open that folder in Windows `CMD`, double-click this registry import file, then click "Yes" and "OK:"

    installWindowsCMDhere.reg

And/or:

- Navigate to the desired folder in Windows explorer.
- Click in the Explorer address bar, or press `ALT+D` to quickly jump there.
- type `cmd`, then press <ENTER>.

A Windows cmd prompt will open in that directory.

And/or see [StExBar](https://github.com/stefankueng/tools/releases/tag/StExBar_1.11.0).

All these tips re [an "off-topic"](https://stackoverflow.com/q/378319/1397555) post at StackExchange.

# END