# Pass this script one paramater, being $1 a file name to wipe the metadata from in-place. WARNING: Do this only on data for which you have a backup! If something goes wrong with this, it can be a permanent kablooey for the affected files.

# Additional reference (to whatever else I originally looked up to develop this) ; e.g. nuke everything (really? Something else maybe indicated that -all= doesn't encompass all the other thing:all= nuke swithces I added here--and is that correct?) : http://photography-on-the.net/forum/showthread.php?p=13543203
# -- I think that is NOT correct, and the way to wipe all metadata of every kind is just -all= , re: https://martin.hoppenheit.info/blog/2015/useful-exiftool-commands/

# DANGEROUS CHEAT: to wipe all metadata from all supported file types, pass $1 as . (meaning '.' or just a dot).

	# DEPRECATED; I've read that the second next line does all this anyway:
	# exiftool -all= -CommonIFD0= -adobe:all= -xmp:all= -photoshop:all= -iptc:all= -m -overwrite_original -k $1
exiftool -all= -m -overwrite_original -k $1