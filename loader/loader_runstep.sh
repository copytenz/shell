#!/bin/bash

################################################################################
# SCRIPT: 	loader_runstep.sh
#
# DESCRIPTION:	Provides ability to run loader steps by launching java 
# 		binary with required arguments 
#
# USAGE: 	loader_run_step.sh [CONTAINER DATE STEP STEP_CODE FOLDER]"
# 		takes as arguments 5 parameters, which however can all be 
#		ommited - in this case script will ask for them 
#
# EXAMPLE java string:
# 		java -classpath .:bank.jar:JT400.jar:db2_classes.jar \
#		ru.rb.ucb.loader.LoaderContainer 2017-10-06 MI1GL MI1GL
# 
# VERSION: 	2.2 
# VERSION DATE:	2017-12-08
# CHANGE BY:	4e
# CHANGES:	* Fixed issue with calculating of prevDay using `date +%-d`
################################################################################


#-- Set common variables
workDir=/opt/loader
formattedDate=`date +%Y-%m-%d`
[ -z "$formattedDate" ] && formattedDate="2017-01-01"
logDir=$workDir/logs
scriptLog=$logDir/$(basename $0).log.$formattedDate
securityGroup=loader

# If number of arguments is 5, set batchMode to 1 to run in batch mode
[ $# -eq 5 ] && batchMode=1 || batchMode=0

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
 	[ "$batchMode" -eq 0 ] && echo "* $message"
}

#-- Script body

#-- If some script argument is empty, ask to enter it manually
[ -z "$1" ] && read -p "Enter container name [ru.rb.ucb.loader.LoaderContainer]: " container || container=$1
[ -z "$container" ] && container="ru.rb.ucb.loader.LoaderContainer"

let prevDay=`date +%-d`-1
# If prevDay is less than 10 force add zero to have two digits day, e.g. "09"
[ "$prevDay" -lt 10 ] && prevDay="0${prevDay}"
[ -z "$2" ] && read -p "Enter operDate in format YYYY-MM-DD [`date +%Y-%m-`$prevDay]: " operDate || operDate=$2
[ -z "$operDate" ] && operDate="`date +%Y-%m-`$prevDay"

[ -z "$3" ] && read -p "Enter step: " step || step=$3
until [ ! -z "$step" ]; do 
	read -p "Step can not be empty, enter step: " step 
done

[ -z "$4" ] && read -p "Enter step code: " code || code=$4
until [ ! -z "$code" ]; do 
	read -p "Code can not be empty, enter code: " code 
done

[ -z "$5" ] && read -p "Enter step folder, e.g. GLDB or BARSREP: " folder || folder=$5
until [ ! -z "$folder" ] && [ -d "$workDir/$folder" ]; do 
	read -p "Folder name is empty or folder $workDir/$folder doesn't exit, enter folder: " folder 
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

cd "$workDir/$folder"
log "Script folder = `pwd`"

log "Launch command: 
  java -classpath .:bank.jar:JT400.jar:db2_classes.jar $container $operDate $step $code " 

# If working not in batch mode - leave the user chance to break the script if the command is incorrect
if [ "$batchMode" -eq 0 ]; then
	echo ""
	read -p "pause" keypress
fi

# * Launch loader step
nohup java -classpath .:bank.jar:JT400.jar:db2_classes.jar $container $operDate $step $code >> $scriptLog 2>&1  &

log "= Script completed: $0"

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
	echo ""
	[ "$answer" == "Y"  ] && tail -f $scriptLog 
fi

