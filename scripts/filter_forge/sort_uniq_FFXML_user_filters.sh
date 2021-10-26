# DESCRIPTION
# Prints unique presets from an XML file containing multiple Filter Forge filter user presets (which XML files are stored in a "My Presets" user folder with a Filter Forge install). This printout may be pasted over the entire original preset list again and saved. Has the effect of deleting duplicate presets (which appear when I merge presets by hand from multiple sources).

# DEPENDENCIES
# xmlstarlet installed in your PATH as 'xml', sed.

# USAGE
# Suppose you have two or more different versions of a Filter Forge user preset file (e.g. Library_14934.xml) from different machines (from the "My Presets" subfolder in the Filter Forge user data folder). If you cut and paste all of the <element> fields of one into the other (combined all those fields), you may end up with new unique elements but also a lot of duplicated elements. This script assists in eliminating the duplicate elements (so that you retain only one unique instance of each new element).
# Steps to accomplish this:
# - In Filter Forge, navigate to the filter you wish to merge presets from other copies of Filter Forge into. Right-or-alt-click it and click "Locate File." This will open the folder where the .ffxml file resides, with the file highlighted. This is our "preset merge file," and for our examples it is named Library_14934.xml.
# - Back up this preset merge file somewhere completely other than the Filter Forge user or install folder, to somewhere safe you can restor the file from if things go wrong.
# - Open the preset merge file and your other copies of the same file (otherwise known as user preset files) from other machines or installs of Filter Forge.
# - Cut and paste the <presets> XML elements from all other copies of the user preset file into the preset merge file Library_14934.xml, to combine them all into one master filter file. (This is manual collation which will almost certainly lead to duplicate presets in the file, which is the problem this script helps solve).
# - Restart Filter Forge, open the preview for the filter (the preset merge file Library_14934.xml), and open and test render different presets to be sure everything is functioning OK. You may notice here that there are identical presets. That's the problem we're solving.
# - Close Filter Forge.
# - To deduplicate the collated filters from the preset merge file, run this script with the preset merge file as the only parameter, and pipe the printed result to a new file, like this:
#        sort_uniq_FFXML_user_filters.sh Library_14934.xml > deduped_elements.xml
# - Cut and paste the deduplicated presets from the new file deduped_elements.xml over the elements in the preset merge file Library_14934.xml. _Replace_ all of the <element> fields in the merge file, do not append more after them.
# - At this writing, because Filter Forge doesn't detect stale preset image caches that resulted from operations outside of Filter Forge. It goes right on using the same cached images even if presets were reordered/deleted/inserted outside the program. This means you'll have wrong preset previews. As a workaround, delete the thumbnail data file named after the filter you deduplicate. You'll find it in the /System/Thumbnails subfolder of the user folder for your Filter Forge install.
# - Start Filter Forge and verify that it has all the new presets but no duplicates.
# - Once you know that worked, discard the new file from which you merged so many deduplicate presets into the preset merge file.


# CODE
if ! [ "$1" ]; then printf "\nNo parameter \$1 (Filter Forge user preset merge file) passed to script. See USAGE comment in script.) Exit."; exit 1; else presetMergeFile=$1; fi

# select all preset XML, pipe to tr and delete all newlines, and pipe to a temp text file:
xml sel -t -m 'MyPresets/Preset' -c '.' -nl $presetMergeFile | tr -d '\n' > tmp_rSnzR26vhdi8Uy.txt
# split that text file on presets:
sed -i 's/<\/Preset>/<\/Preset>\n/g' tmp_rSnzR26vhdi8Uy.txt
# delete tabs (which fortunately only appear between > and <):
sed -i "s/\t//g" tmp_rSnzR26vhdi8Uy.txt
# sort and uniq that, printing to stdout:
sort < tmp_rSnzR26vhdi8Uy.txt | uniq
rm ./tmp_rSnzR26vhdi8Uy.txt


# XMLSTARLET reference commands; re: http://xmlstar.sourceforge.net/doc/UG/xmlstarlet-ug.html#idm47077139594320
# 
# # Update value of an attribute
# xml ed -u "/xml/table/rec[@id=3]/@id" -v 5 xml/tab-obj.xml
# Output:
# 
# <xml>
#   <table>
#     <rec id="1">
#       <numField>123</numField>
#       <stringField>String Value</stringField>
#       <object name="Obj1">
#         <property name="size">10</property>
#         <property name="type">Data</property>
#       </object>
#     </rec>
#     <rec id="2">
#       <numField>346</numField>
#       <stringField>Text Value</stringField>
#     </rec>
#     <rec id="5">
#       <numField>-23</numField>
#       <stringField>stringValue</stringField>
#     </rec>
#   </table>
#  xml>

# Update value of an element
# xml ed -u "/xml/table/rec[@id=1]/numField" -v 0 xml/tab-obj.xml
# Output:
# 
# <xml>
#   <table>
#     <rec id="1">
#       <numField>0</numField>
#       <stringField>String Value</stringField>
#       <object name="Obj1">
#         <property name="size">10</property>
#         <property name="type">Data</property>
#       </object>
#     </rec>
#     <rec id="2">
#       <numField>346</numField>
#       <stringField>Text Value</stringField>
#     </rec>
#     <rec id="3">
#       <numField>-23</numField>
#       <stringField>stringValue</stringField>
#     </rec>
#   </table>
#  xml>

# Recover malformed XML document
# xml fo -R xml/malformed.xml 2>/dev/null
# Input:
# 
# <test_output>
#    <test_name>foo</testname>
#    <subtest>...</subtest>
#  test_output>

# Let's take a look at XSLT produced by the following 'xml sel' command:
# 
# # Query XML document and produce sorted text table
# xml sel -T -t -m /xml/table/rec -s D:N:- "@id" \
#    -v "concat(@id,'|',numField,'|',stringField)" -n xml/table.xml
# <xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
# <xsl:output omit-xml-declaration="yes" indent="no" method="text"/>
# <xsl:param name="inputFile">-</xsl:param>
# <xsl:template match="/">
#   <xsl:call-template name="t1"/>
#  xsl:template>
# <xsl:template name="t1">
#   <xsl:for-each select="/xml/table/rec">
#     <xsl:sort order="descending" data-type="number" 
#       case-order="upper-first" select="@id"/>
#     <xsl:value-of select="concat(@id,'|',numField,'|',stringField)"/>
#     <xsl:value-of select="'&#10;'"/>
#   </xsl:for-each>
#  xsl:template>
#  xsl:stylesheet>