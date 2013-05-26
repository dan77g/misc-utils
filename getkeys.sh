#!/bin/bash
 
# Store old Internal File Separator to return IFS to its former value in the end. Setting IFS to $'\n' enables the very useful for...in... loop to read entire lines

OLDIFS=$IFS
IFS=$'\n'

# Check if script is run as root.
if [ $(id -u) -ne 0 ]
	then echo "Please run this script with sudo or as root. Exiting..."

# If root, run the script.
# Store missing keys in ~/keys and count them.

	else echo -n "Running aptitude update to get IDs of missing keys... "

	sudo aptitude update >/dev/null 2>~/errors 
	cat ~/errors | grep "signatures" | cut -d " " -f 21 >~/keys
	numberkeys=$(wc -l ~/keys | cut -d " " -f 1)

	echo "done."
	echo "Need to retrieve $numberkeys keys..."

# Execute this block only if there are keys to retrieve.
	
	# Retrieve keys one by one, incrementing count to display progress to user.

	if [ $numberkeys -gt 0 ]	
		then count=1
		for key in $(cat ~/keys)
			do echo -n "   Retrieving key $count/$numberkeys... "	
			sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys $key >/dev/null 2>/dev/null
			echo "done."
			(( count=$count+1 ))
		done
		rm ~/keys

	# Before exit, verify that all keys are now accounted for. 
	# Therefore store possible missing keys in ~/keys.

		echo -n "Verifying success... "
		sudo aptitude update >/dev/null 2>~/errors
		cat ~/errors | grep "signatures" | cut -d " " -f 21 >~/keys

	# If file ~/keys is empty, then no keys need to be retrieved any more.

		if [ $(wc -l ~/keys | cut -d " " -f 1) -eq 0 ]
			then echo "Job succeeded"\!
			
			else echo "Arg"\!" Something failed..."
			echo "More keys still seem to be missing, run this script again to try to fix the issue. If the problem persists , run sudo aptitude update to find out what is going wrong."
			rm ~/errors	
		fi
	fi	

# End of the block executed only if keys were missing.
	
# If errors aptitude update output errors, tell user and ask him if he wants them displayed. Act accordingly.
	
	if [ $(wc -l ~/errors | cut -d " " -f 1) -eq 0 ]
		then rm ~/errors

		else echo "While running aptitude update, the script has encountered problems, even if no keys are missing. Do you want to display these errors?(yes,no): "
		read choice

		while [ "$choice" != "yes" ] && [ "$choice" != "no" ]
			do echo "Please answer yes or no :"
			read choice
		done

		if [ "$choice" == "yes" ]
			then echo "These errors are stored in $HOMEDIR/log :"
			cat ~/errors
		fi
	fi

# Clean up before exit.

	echo "Job finished, cleaning up."	
	rm ~/keys
fi

IFS=$OLDIFS
