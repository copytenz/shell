#!/bin/bash

################################################################################
# SCRIPT: 	kill_loader.sh
#
# DESCRIPTION:	This script looks for the processes using some file and 
# 		provides list of the processes and proposes to kill them 1 by 1
#
# USAGE: 	kill_loader.sh [fileName]
#		The fileName shall be used by the process you want to kill
#
# NOTE:		To test the file create a file test.log open several sessions 
#		of `tail -F test.log &`
#		and try to kill them
#
# VERSION: 	4.1 
# VERSION DATE:	2017-11-22
# CHANGE BY:	4e
# CHANGES:	* Changed script log folder and formatting to more standard one
#		* Added ability to select file
#		* Added ability to see log tail after launching the command in
#		* Added view of processes in non-batch mode at the end of script
#		  non-batch mode
#		* Corrected issue with empty input for process if file doesn't exit
#		* Now logfile permissions are updated to ensure group can write
################################################################################

#-- Set common variables
workDir=/opt/loader
formattedDate=`date +%Y-%m-%d`
[ ! -z "$formattedDate" ] && formattedDate="2017-01-01"
logDir=$workDir/logs
scriptLog=$logDir/$(basename $0).log.$formattedDate
securityGroup=loader

# If number of arguments is 1, run in batch mode
[ $# -eq 1 ] && batchMode=1 || batchMode=0

#-- Set variables specific for this script if applicable
# none

#--  Define function to log script messages
function log {
	# VERSION DATE:	 20171121
	# EXAMPLE:	 log "My Message to be logged"

	# Set message to the arguments of the log function called
	local message=$*
	# Save message to the log file with date and time as prefix
	echo "`date +%Y-%m-%d\" \"%T` $message" >> $scriptLog  2> /dev/null
	# Print message to console if not running in batch mode
 	[ $batchMode -eq 0 ] && echo "* $message"
}

#-- Script body

# Check if the command line parameters are set and correct
[ -z $1 ] && fileName=$1
until [ ! -z "$fileName" ]; do
	echo ""
	echo "Select the file which is being used by your process:"
	echo "1. /opt/loader/BARSREP/bank.jar"
	echo "2. /opt/loader/GLDB/bank.jar"
	echo "3. Manual entry"
	echo ""
	read -p "Select an option by entering a number: " selection
	case $selection in
	1) 
		fileName=/opt/loader/BARSREP/bank.jar
	;;
	2) 
		fileName=/opt/loader/GLDB/bank.jar
	;;
	*)	
		read -p "Please enter non-empty fileName, e.g. /opt/loader/BARSREP/bank.jar: " fileName 
	;;
	esac
done
until [ -f $fileName ] && [ ! -z $fileName ]; do
	read -p "File \"$fileName\" doesn't exist. Please enter correct fileName: " fileName
done

#-- Script execution

# Initialize log
umask 0002
mkdir -p $logDir
touch $scriptLog
chgrp $securityGroup $scriptLog 2> /dev/null 

log "* Script started: $0 $*"
message=`who -m`
[ ! -z "$message" ] && log "$message"



log "Working with the processes using the following file: $fileName"

# * Show messages below only if running not in batch mode
echo ""
[ $batchMode -eq 0 ] &&  echo "* All processes which are using $fileName: "
[ $batchMode -eq 0 ] &&  lsof $fileName

# find all processes and parce them to an array
IFS=' ' read -ra process <<< `lsof -Fp $fileName`
for x in "${process[@]}"; do
    # remove all but digits from the string
    x=$(echo $x | sed -e "s/[^0-9]//g")
    if [ -z $x ]; then
        echo PID $x is empty
    else
	if [ $batchMode -eq 0 ]; then
		echo
		echo "Working with the following process:"
        	ps -q $x -o pid,cmd | grep -v "PID"
        	read -p "Do you really want to kill the process with PID $x? (y/n) [n] " answer
		echo
	else 
		answer="y"
	fi
        [ -z $answer  ] && answer="n"

	# * Finally - kill the process if answer if "y"
        [ $answer = "y" ] &&  kill -9 $x || log "Process with PID $x ignored"

        # * Check if the process still exists
        ps -q $x -o pid,cmd  | grep -v grep | grep  "$x" && check=true;
        [ -z $check ] && log "Process $x doesn't exist anymore" || log "* Process $x still exists"
        unset check
    fi
    # * run only once for batch mode
    [ $batchMode -eq 1 ] && break
done

log "* Script completed: $0 $*"

#-- Post-script procedures

# if running not in batch mode - show the bank.jar processes
if [ $batchMode -eq 0 ]; then
        echo ======================================================================
	echo Active bank.jar processes:
	ps -ef | grep bank.jar | grep -v grep
        echo ======================================================================
	echo "Log is stored to the $scriptLog"
	read -p "Do you want to tail log file to the terminal now? [n] " answer
	answer=$(echo "$answer"| awk '{print toupper($0)}')
        echo ======================================================================
	[ "$answer" == "Y"  ] && echo "Press ctrl+C to exit the log tail"
	[ "$answer" == "Y"  ] && tail -f $scriptLog 
fi

