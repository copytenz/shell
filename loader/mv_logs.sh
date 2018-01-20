#!/bin/bash

################################################################################
# SCRIPT: 	mv_logs.sh
#
# DESCRIPTION:	This script: 
#		1)  moves all files with suffix *.log.YYYY-MM-DD 
#		to the folder YYY_MM/
#		(the folder is created if it doesn't exist)
#		2) GZips the folder two months old and removes it after that
#
# USAGE: 	mv_logs.sh [baseFolder]
# 		takes an optional  argument with the path to target folder
#
# VERSION: 	2.2 
# VERSION DATE:	2017-12-08
# CHANGE BY:	4e
# CHANGES:	* Fixed issue with calculating of oldMonth using `date +%-m`
################################################################################


#-- Set common variables
workDir=/opt/loader
formattedDate=`date +%Y-%m-%d`
[ -z "$formattedDate" ] && formattedDate="2017-01-01"
logDir=$workDir/logs
scriptLog=$logDir/$(basename $0).log.$formattedDate
securityGroup=loader

# If number of arguments is 1, run in batch mode
[ $# -eq 1 ] && batchMode=1 || batchMode=0

#-- Set variables specific for this script if applicable
currentYear=`date +%Y`
currentMonth=`date +%m`

# If script argument is set than use it as baseFolder, otherwise use current folder
baseFolder="$1"
[ -z "$baseFolder" ] && baseFolder="."  


#--  Define function to log script messages
function log {
	# Set message to the arguments of the log function called
	local message=$*
	# Save message to the log file with date and time as prefix
	echo "`date +%Y-%m-%d\" \"%T` $message" >> $scriptLog  2> /dev/null
	# Print message to console if not running in batch mode
 	[ $batchMode -eq 0 ] && echo "* $message"
}

#-- Define function to archive files
function mvFilesByName {
	local fileName=$1
	targetYear=${fileName:${#fileName}-10:4}
	targetMonth=${fileName:${#fileName}-5:2}
	targetFolder="${targetYear}_${targetMonth}"

        # 4e 20171121 replaced: fileSuffixMask="${targetYear}-${targetMonth}-[0-3][0-9]"
        fileSuffixMask="${targetYear}-${targetMonth}-*"
        
	# Check if the current month folder exists. If it doesn't - create it
	[ ! -d $targetFolder ] && mkdir -p $targetFolder 
	log "Moving files to $targetFolder"
	
	# Move files with matching mask
	mv *.log.$fileSuffixMask ./$targetFolder/
}

#-- Script body and execution

# Initialize log
umask 0002
mkdir -p $logDir
touch $scriptLog
 
cd $baseFolder

chgrp $securityGroup $scriptLog 2> /dev/null

log "* Script started: $0 $*"
message=`who -m`
[ ! -z "$message" ] && log "$message"

log "baseFolder="$baseFolder 
log "Current folder `pwd`"

# find file with suffix in YYYY-MM-DD format
while true; do
  if ls -w1 *.log.2[0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] > /dev/null 2>&1; then
    export fileName=`ls -w1 *.log.2[0-9][0-9][0-9]-[0-1][0-9]-[0-3][0-9] | head  -1` 
    if [ ! -f ./$fileName ] ; then
        log  "Script completed"
	break
    else
	mvFilesByName $fileName
    fi
  else
    log "* No files to move"
    break
  fi
done

# * Section 2 - gzip two months old folder

let oldMonth=`date +%-m`-2
# If the month is nov or dec, than the year we archive is previous
[ $oldMonth -ge 10 ] &&  let oldYear=`date +%Y`-1 || let oldYear=`date +%Y`

# if the month is less than 10, add leading zero
[ $oldMonth -lt 10 ] && oldMonth="0${oldMonth}"

oldFolder="${oldYear}_${oldMonth}"
#echo $oldFolder
if [ -d $oldFolder ]; then
	log "Archiving old folder $oldFolder"
	tar zcf $oldFolder.tar.gz $oldFolder && rm -r $oldFolder	
fi 

# * Update group for the manually created files and folders where possible
chgrp loader ./* > /dev/null 2>&1

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
	echo ""
	[ "$answer" == "Y"  ] && tail -f $scriptLog 
fi

