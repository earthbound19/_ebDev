# DESCRIPTION
# SEE USAGE. Prints unique presets from an XML file containing multiple Filter Forge filter user presets (which XML files are stored in a "My Presets" user folder with a Filter Forge install). This printout may be pasted over the entire original preset list again and saved. Has the effect of deleting duplicate presets (which appear when I merge presets by hand from multiple sources).

# DEPENDENCIES
# xmlstarlet installed in your PATH as 'xml', sed installed as gsed.

# USAGE
# - suppose you have two different versions of a Filter Forge user preset file (e.g. Library_14934.xml) from different machines (from the "My Presets" subfolder in the Filter Forge user data folder). If you cut and pasted all of the <element> fields of one into the other (combined all those fields), you would end up with new unique elements but a lot of duplicated elements. This script assists in eliminating the duplicate elements. Do this: 
# - cut and paste the <presets> XML elements from one file into the other (right after all of the <element> fields of the other; combining them; we'll say we've cut and pasted them into a file named Library_14934.xml). Then run this script like this:
# ./sort_uniq_FFXML_user_filters.sh Library_14934.xml > deduped_elements.xml
# - then cut and paste deduped_elements.xml over the elements in Library_14934.xml (replacing all of the <element> fields, not appending to them).
# - copy the merged and deduplicated user presets file over the original in the "/My Presets" user folder of your Filter Forge install
# - at this writing, Filter Forge sadly doesn't detect stale preset image caches, and goes right on using the same images even if presets were reordered/deleted/inserted outside the program, meaning that you'll get wrong thumbnails. As a workaround, delete the thumbnail data file named after the filter you deduplicate. You'll find it inin the /System/Thumbnails subfolder of the user folder for your Filter Forge install.
# - start Filter Forge and verify that it has all the new presets but no duplicates.
# - once you know that worked, discard the file from which you have now successfully merged and deduplicated fields.


# CODE
# select all preset XML, pipe to tr and delete all newlines, and pipe to a temp text file:
xml sel -t -m 'MyPresets/Preset' -c '.' -nl $1 | tr -d '\n' > tmp_rSnzR26vhdi8Uy.txt
# split that text file on presets:
gsed -i 's/<\/Preset>/<\/Preset>\n/g' tmp_rSnzR26vhdi8Uy.txt
# delete tabs (which fortunately only appear between > and <):
gsed -i "s/\t//g" tmp_rSnzR26vhdi8Uy.txt
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
# </xml>

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
# </xml>

# Recover malformed XML document
# xml fo -R xml/malformed.xml 2>/dev/null
# Input:
# 
# <test_output>
#    <test_name>foo</testname>
#    <subtest>...</subtest>
# </test_output>

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
# </xsl:template>
# <xsl:template name="t1">
#   <xsl:for-each select="/xml/table/rec">
#     <xsl:sort order="descending" data-type="number" 
#       case-order="upper-first" select="@id"/>
#     <xsl:value-of select="concat(@id,'|',numField,'|',stringField)"/>
#     <xsl:value-of select="'&#10;'"/>
#   </xsl:for-each>
# </xsl:template>
# </xsl:stylesheet>