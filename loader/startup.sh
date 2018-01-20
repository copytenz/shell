#!/bin/bash

################################################################################
# SCRIPT: 	startup.sh
#
# DESCRIPTION:	Provides ability to start loader 
#
# USAGE: 	startup.sh [PROCESS FOLDER]
#		takes as arguments 2 parameters, which however can all be
#		ommited - in this case script will ask for them
#		PROCESS is one of:
#			* LoadProcessNew
#			* replication
#			* localization
#		FOLDER is current loader folder, e.g.:
#			* BARSREP
#			* GLDB
# 
# VERSION: 	2.1 
# VERSION DATE:	2017-11-22
# CHANGE BY:	4e
# CHANGES:	*New script derived from startup.sh in particular loader folders
################################################################################


#-- Set common variables
workDir=/opt/loader
formattedDate=`date +%Y-%m-%d`
[ -z "$formattedDate" ] && formattedDate="2017-01-01"
logDir=$workDir/logs
scriptLog=$logDir/$(basename $0).log.$formattedDate
securityGroup=loader

# If number of arguments is 2, set batchMode to 1 to run in batch mode
 [ $# -eq 2 ] && batchMode=1 || batchMode=0

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

#-- If some script argument is empty, ask to enter it manually
[ -z $1 ] && read -p "Enter process name [ LoadProcessNew | localization | replication ]: " process || process=$1

process=$(echo $process | awk '{print toupper($0)}')
case $process in
	LOADPROCESSNEW)
		class=lv.gcpartners.bank.util.LoadProcessNew
		
		[ -z "$2" ] && read -p "Enter folder, e.g. GLDB or BARSREP: " folder || folder=$2
		until [ ! -z $folder ] && [ -d "$workDir/$folder" ]; do 
			[ $batchMode == 1 ] && break
			read -p "Folder name is empty or doesn't exit, enter folder: " folder 
		done
		folderIndicator="$folder"
	;;
	LOCALIZATION)
		class=lv.gcpartners.bank.corpd.CorectLocalisationBatch
		folder=GLDB
		
		[ $batchMode -eq 0 ] && read -p "Folder is set to GLDB, do you want to change it? [n] " answer
		answer=$(echo "$answer"| awk '{print toupper($0)}')
		if [ "$answer" == "Y" ]; then
			read -p "Enter folder name: " folder
			until [ ! -z $folder ] && [ -d "$workDir/$folder" ]; do 
				[ $batchMode == 1 ] && break
				read -p "Folder name is empty or doesn't exit, enter folder: " folder 
			done
		fi 
		folderIndicator=""
	;;
	REPLICATION)
		class=ru.rb.ucb.loader.replication.BARSReplicatorNew
		folder=BARSREP
		
		[ $batchMode -eq 0 ] && read -p "Folder is set to BARSREP, do you want to change it? [n] " answer
		answer=$(echo "$answer"| awk '{print toupper($0)}')
		if [ "$answer" == "Y" ]; then
			read -p "Enter folder name: " folder
			until [ $batchMode -eq 0 ] && [ ! -z $folder ] && [ -d "$workDir/$folder" ]; do 
				read -p "Folder name is empty or doesn't exit, enter folder: " folder 
			done
		fi 
		folderIndicator=""
	;;
	*)
		echo "Option not set or illegal. You entered: $process"
		echo "Exiting script"
		exit
	;;
esac

#-- Script body

# Initialize log
umask 0002
touch $scriptLog
chgrp $securityGroup $scriptLog 2> /dev/null

log "* Script started: $0 $*"
message=`who -m`
[ ! -z "$message" ] && log "$message"

cd "$workDir/$folder"

log "Script folder = `pwd`"

log "Launch command: 
  nohup java -classpath .:bank.jar:JT400.jar:db2_classes.jar $class $folderIndicator" 

# If working not in batch mode - leave the user chance to break the script if the command is incorrect
if [ $batchMode -eq 0 ]; then
	echo ""
	read -p "pause" keypress
fi

# * Launch loader step
nohup java -classpath .:bank.jar:JT400.jar:db2_classes.jar $class $folderIndicator >> $scriptLog 2>&1  &

log "= Script completed: $0 $*"

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

