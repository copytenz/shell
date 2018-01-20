#!/bin/bash

################################################################################
# SCRIPT: 	process_killer.sh
#
# DESCRIPTION:	This script looks for the processes using a mask and  
# 		provides list of the processes and proposes to kill them 1 by 1
#
# USAGE: 	process_killer.sh [mask]
#		The fileName shall be used by the process you want to kill
#
# NOTE:		To test the file create a file test.log open several sessions 
#		of `tail -F test.log &`
#		and try to kill them
#
# VERSION: 	1.3 
# VERSION DATE:	2017-11-22
# CHANGE BY:	4e
# CHANGES:	* Changed script log folder and formatting to more standard one
#		* Added logging
#		* Now logfile permissions are updated to ensure group can write
################################################################################


#-- Set common variables
workDir=/opt/loader
formattedDate=`date +%Y-%m-%d`
[ -z "$formattedDate" ] && formattedDate="2017-01-01"
logDir=$workDir/logs
scriptLog=$logDir/$(basename $0).log.$formattedDate
securityGroup=loader

# Never run in a batch mode
batchMode=0

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

# Initialize log
umask 0002
mkdir -p $logDir
touch $scriptLog
chgrp $securityGroup $scriptLog  2> /dev/null

log "* Script started: $0 $*"
message=`who -m`
[ ! -z "$message" ] && log "$message"

# Read mask to be grepped in the process list
mask=""
read -p "Enter mask to grep [bank.jar]: " mask

# Remove all but letters for security reasons from the variable mask
mask=$(echo $mask | sed -e "s/[;,|]//g")

# If the mask is not set, use BARS as a mask
[ -z "$mask" ] &&  mask="bank.jar"

process_id=""
while true; do
  clear
  echo "List of processes containing $mask:"
  ps aux | grep -v grep | grep $mask
  echo ""
  read -p "Enter process ID to be killed or \"x\" for exit: " process_id
  if [ "$process_id" = "x" ]; then break;fi

  # to be on a safe side - remove all non-digits from the input
  process_id=$(echo $process_id | sed -e "s/[^0-9]//g")

  if [ -z "$process_id" ]; then
    echo "Process ID is empty or process doesn't exist - nothing to kill";
  else
    echo "Trying the following command if PID exists: kill -9 $process_id"
    echo "List of all processes containing $process_id before kill: "
    ps -eo pid  | grep -v grep | grep  "$process_id" && kill -9 $process_id

  fi

  read -p "Press ENTER to continue..." anykey
done


log "= Script completed: $0"

