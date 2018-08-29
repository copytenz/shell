#/bin/bash

################################################################################
# SCRIPT: 	rsync.sh
#
# DESCRIPTION: Syncronizes two folders and issues date, source and destination
#	       Used to display date, source and destination in the log file 
#		run by cron
#
# USAGE: 	
#
# VERSION: 	0.1 
# VERSION DATE:	2018-01-28
# CHANGE BY:	4e
# CHANGES:	* New script
################################################################################



what=$1
where=$2

echo "============================================="
date
echo "Source:      $what"
echo "Destination: $where"

rsync -rlptvz "$what" "$where"
