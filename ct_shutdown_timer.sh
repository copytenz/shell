#!/bin/sh
# ** This script shutdowns the unix system in required number of minutes

echo "---------------------------------------------------------
Enter time before shutdown in minutes:"
read x

echo "
The system will be stopped in $x minutes

To stop shutdown process press ctrl+c
---------------------------------------------------------"

sudo /sbin/shutdown -h $x
sleep 100
