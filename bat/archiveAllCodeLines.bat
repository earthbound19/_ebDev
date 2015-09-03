REM For reference/archiving/stats, call this batch with one paramater, a directory name, to merge all C++, IDE resource, batch, and text source lines therein into respective .cpp (with comment sections for the IDE resource lines), .bat, and .txt file archives.

ECHO // ==== START SOURCE CODE::COMPLETE LINES ARCHIVE ==== > %1_all_code_lines.cpp
IF EXIST %1\*.h TYPE %1\*.h >> %1_all_code_lines.cpp
IF EXIST %1\*.hpp TYPE %1\*.hpp >> %1_all_code_lines.cpp
IF EXIST %1\*.c TYPE %1\*.c >> %1_all_code_lines.cpp
IF EXIST %1\*.cc TYPE %1\*.cc >> %1_all_code_lines.cpp
IF EXIST %1\*.cpp TYPE %1\*.cpp >> %1_all_code_lines.cpp
ECHO // ==== END SOURCE CODE::COMPLETE LINES ARCHIVE ==== >> %1_all_code_lines.cpp

ECHO /* ==== START IDE RESOURCE CONTENTS ==== >> %1_all_code_lines.cpp
IF EXIST %1\*.cbp TYPE %1\*.cbp >> %1_all_code_lines.cpp
IF EXIST %1\*.layout TYPE %1\*.layout >> %1_all_code_lines.cpp
IF EXIST %1*.depend\ TYPE %1\*.depend >> %1_all_code_lines.cpp
IF EXIST %1\*.vcxproj TYPE %1\*.vcxproj >> %1_all_code_lines.cpp
IF EXIST %1\*.sln TYPE %1\*.sln >> %1_all_code_lines.cpp
ECHO ==== END IDE RESOURCE CONTENTS ==== */ >> %1_all_code_lines.cpp

ECHO // ==== START BATCH SCRIPTING ARCHIVE ==== > %1_all_batch_script_lines.bat.txt
IF EXIST %1\*.bat TYPE %1\*.bat >> %1_all_code_lines.bat.txt
IF EXIST %1\*.txt TYPE %1\*.txt >> %1_all_code_lines.txt
ECHO // ==== END BATCH SCRIPTING ARCHIVE ==== >> %1_all_batch_script_lines.bat.txt

ECHO // ==== START TEXT RESOURCE ARCHIVE ==== > %1_all_text_resource_lines.txt
IF EXIST %1\*.bat TYPE %1\*.bat >> %1_all_code_lines.bat.txt
IF EXIST %1\*.txt TYPE %1\*.txt >> %1_all_code_lines.txt
ECHO // ==== END TEXT RESOURCE ARCHIVE ==== > %1_all_text_resource_lines.txt