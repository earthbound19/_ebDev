username=`whoami`
echo "Username is $username. OVERWRITING configuration of /home/$username/.minttyrc with my.minttyrc.settings.txt. Continue?"
echo "!============================================================"
read -p "DO YOU WISH TO CONTINUE running this script? : y/n" CONDITION;
if [ "$CONDITION" == "y" ]; then
		echo Ok! Attempting overwrite . . .
		cat ./my.minttyrc.settings.txt > /home/$username/.minttyrc
		echo Done. Exit and restart the shell after all of the remaining commands complete, to see if the configuration \"stuck.\"
	else
		echo D\'oh!; exit;
fi