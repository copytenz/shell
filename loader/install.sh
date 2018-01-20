#!/bin/bash

################################################################################
# SCRIPT: 	install_2017-11-22.sh
#
# DESCRIPTION:	Installation procedures for RB scripts 2017-11-22
#
# USAGE:	install_2017-11-22.sh 
# 		takes 1 argument, which however can be ommited 
# 
# VERSION: 	1.0 
# VERSION DATE:	2017-11-22
# CHANGE BY:	4e
# CHANGES:	* New script
################################################################################


#-- Set common variables
workDir=/opt/loader
formattedDate=`date +%Y-%m-%d`
[ -z "$formattedDate" ] && formattedDate="2017-01-01"

archiveDir=$workDir/archive/$formattedDate
logDir=$workDir/logs
mkdir -p $logDir
scriptLog=/tmp/$(basename $0).log
securityGroup=loader

#-- Set variables specific for this script if applicable
scriptsInstallDir=install/$formattedDate
fileMask=*.sh

# For script batchMode is always 0, i.e. non-batch
batchMode=0

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

function rename4e {
	# VERSION DATE:	 20171121
	# EXAMPLE:	 rename4e ".log" ".log.`date +%Y-%m-%d`" "*.log"

	# if there are less than 3 parameters exit the function
	if [ "$#" -ne 3 ]; then  echo "Function takes exactly 3 arguments"; return; fi
	local what=$1
	local towhat=$2
	local where=$3
	local rename_ver=`rename -V | grep -c util-linux`
	if [ "$rename_ver" = 0  ]; then
		rename "s/$what/$towhat/g" $where
	else
		rename "$what" "$towhat" $where
	fi
}


#-- Script body and execution

# Initialize log
umask 0002
mkdir -p $logDir
touch $scriptLog
chgrp $securityGroup $scriptLog 2> /dev/null

log "* Script started: $0 $*"
message=`who -m`
[ ! -z "$message" ] && log "$message"

cd $workDir

if [ "$workDir" == `pwd` ]; then
  log "Successfully changed to the $workDir"
else
  log "Cannot enter workDir $workDir - exiting script"
  exit
fi 

#-- Script common part for all installations

log "1. Create archive folder and create copy of current scripts there"
cd $workDir
pwd

ls -l >> $scriptLog

echo  "Create scripts archive dir if it doesn't exist"
for i in "BARSREP" "BARSGL" "GLDB"; do mkdir -p "$archiveDir/$i"; done

echo "Create backup copy of all scripts in the archive folder"
for i in "." "BARSREP" "BARSGL" "GLDB"; do
   for fileName in $i/$fileMask; do
	cp -a "$fileName" "$archiveDir/$i/"
   done
done

log "Files with mask $fileMask are copied to the archiveDir=$archiveDir"
ls -l $archiveDir

echo  "* Step 1 complete. Press ENTER.. " && read

log "2. Copy installation files to workDir=$workDir"
cd $workDir
for i in "." "BARSREP" "BARSGL" "GLDB"; do
	cp -f $scriptsInstallDir/$i/$fileMask $workDir/$i/
done

ls -l $workDir/$fileMask >> $scriptLog
ls -l $workDir/$fileMask

log "Scripts are copied to the workDir=$workDir and its subfolders"

echo  "* Step 2 complete. Press ENTER.. " && read

#-- Script one-off parts

log "3. Move logs to $logDir and rename to proper suffix"

echo "Create logs folder if it doesn't exist"
mv *.log $logDir/

echo "Add suffix with date"
for fileName in $logDir/*.log; do mv $fileName $fileName.$formattedDate; done

ls -l $logDir/ >> $scriptLog
ls -l $logDir

echo  "* Step 3 complete. Press ENTER.. " && read

echo ===================================================================
log "= Script completed: $0"
echo "Final state of the $workDir:"
ls -l $workDir > $scriptLog
ls -l $workDir

