# DESCRIPTION
# Converts a fountain format plain text file screenplay into a formatted PDF via a
# CLI tool (two options, uncomment the option you want). Optionally joins semantic linefeeds
# (AKA ventilated prose or sense lines).

# USAGE
# With this script and dependencies in your PATH:
# fountain2pdf.sh fountain-source-file.fountain foo
# --where "foo" is optional, and may be anything, which if present, causes the script to join
# semantic linefeeds in action or dialogue (to a temp file) before PDF conversion.
# SEE comments in "START PDF RENDER OPTIONS" section for different possible dependencies to use (via comment/uncomment of code lines)).

# NOTES
# THIS SCRIPT expects everything after the title page of the screenplay (the actual
# screenplay body text) to start with:
# > FADE IN:
# and you may expect this script to wnot ork if that is not the case.
# ALSO, the "wrap" CLI option expects those specific font files (given in this script)
# to be (I think) in the same PATH as the source fountain file. Also, the optional last
# line of this script opens the output pdf.

# DEPENDENCIES
# wrap or afterwriting CLI (depending on which you choose and which code line you uncomment
# for either, respectively), (g)sed, (g)awk, (those last all from gnuwin32 coreutils), head,
# tail, dos2unix


# CODE
if [ ! -e $1 ]; then echo proposed input file $1 not found. Terminating script.; fi

fileNameNoExt=${1%.*}

# if optional parameter 2 provided, join semantic linefeeds into a temp doc and swap it for
# the original before PDF print:
if ! [ -z ${2+x} ]
then
	# Kludgy and arbitrarily inflexible (instead of pattern matching any title page elements
	# and temporarily cutting them out), but:
	# - to avoid the gsed command mangling title page info, cut everything before and after
	# the initial > FADE IN: (which is now an exact match requirement--MUST be present in the
	# fountain script!--) into two separate files, work on the second, then rejoin them:
	#  - get line number (of match) to split on:
	tail_from=`awk '/> FADE IN:/{print NR;exit}' $1`
	let head_to=tail_from-1
	head -n $head_to $1 > tmp_head_wYSNpHgq.fountain
	tail -n +$tail_from $1 > tmp_tail_wYSNpHgq.fountain
	dos2unix tmp_head_wYSNpHgq.fountain tmp_tail_wYSNpHgq.fountain
	#  - delete lines that start with markdown image syntax (used to double for eBook output via fountain2ePub (using pandoc), but they'll interfere here:
		# deletes the line:
		# gsed -i '/\!\[.*/d' tmp_tail_wYSNpHgq.fountain
	# deletes the line and the line after it (I think?--it leaves one space instead of two) :
	gsed -i ':begin;$!N;/\!\[.*/d;tbegin;P;D' tmp_tail_wYSNpHgq.fountain
	#  - join semantic linefeeds into that tail file, in-place:
	# Adapted from: https://backreference.org/2009/12/23/how-to-match-newlines-in-sed/
	# sed ':begin;$!N;s/FOO\nBAR/FOOBAR/;tbegin;P;D'   # if a line ends in FOO and the next
	# starts with BAR, join them
	#   - Also don't match [ .@~] characters at start of line (don't join if those fountain syntax
	# marks are present:
	gsed -i ':begin;$!N;s/\(^[^ .\(~@\n].*[a-z].*\)\n\(^[^ .\(~@\n].*[a-z].*\)/\1 \2/;tbegin;P;D' tmp_tail_wYSNpHgq.fountain
	# - back original fountain file up:
	mv ./$1 ./$1.fountain-bak.txt
	# - overwrite original with semantic linefeed-joined version (backed up original will be
	# restored later) :
	cat tmp_head_wYSNpHgq.fountain tmp_tail_wYSNpHgq.fountain > $1
	rm ./tmp_head_wYSNpHgq.fountain ./tmp_tail_wYSNpHgq.fountain
fi

# ====
# START PDF RENDER OPTIONS:
# UNCOMMENT THIS: "wrap" CLI option, uses specific fonts--
wrap pdf $1 --font "CourierMegaRS-SemiCondensed.ttf, CourierMegaRS-SemiCondensedBold.ttf, CourierMegaRS-SemiCondensedItalic.ttf, CourierMegaRS-SemiCondensedBoldItalic.ttf"

# _OR_ UNCOMMENT THIS: "afterwriting" CLI option--
# afterwriting --source $1 --overwrite --pdf
# I gave my best effort and the following method of loading fonts is *stupid* arcane (*_two_ json files?!_*) and doesn't seem to work:
# --config courierMegaConfig.json --fonts CourierMega.json
# END PDF RENDER OPTIONS
# ====

# If we joined semantic linefeeds, restore backed-up fountain file over original:
if ! [ -z ${2+x} ]
then
	mv ./$1.fountain-bak.txt ./$1
fi

# Optionally open result PDF; change `open` to `cygstart` for Cygwin:
open ./$fileNameNoExt.pdf