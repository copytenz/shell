#!/bin/bash

################################################################################
# SCRIPT: 	tz_archive_dropbox.sh
#
# DESCRIPTION:	Archive Dropbox Camera Uploads so that the space is not eaten
#
# USAGE: 	
#
# VERSION: 	0.1 
# VERSION DATE:	2017-12-08
# CHANGE BY:	4e
# CHANGES:	* New script
################################################################################

workDir="/mnt/storage/Dropbox/Camera Uploads"
screenShotsDir=/mnt/granary/manual-backup/screenshots
photosDir=/mnt/granary/private/photos/CameraUploads

cd "$workDir"

#for folder in "$screenShotsDir" "$photosDir"; do mkdir -p $folder; done
for folder in "$screenShotsDir" "$photosDir"; do mkdir  $folder; done

function mv_files_to_targetFolder {
	export  fileMask targetDir
	[ -z "$1" ] && fileMask="*.jpg" || fileMask=$1 
	[ -z "$2" ] && targetDir="$photosDir" || targetDir=$2 
		
	subDir=$(ls $fileMask 2> /dev/null | head -1)
	if [ -z "$subDir" ]; then
		echo "* No files with mask $fileMask"
		return 1
	fi
	subDir=${subDir:0:7} 
	targetDir=$targetDir/$subDir
	echo "`date +%Y-%m-%d" "%H:%M:%S` * Archiving to folder $targetDir"
#	mkdir -p "$targetDir"
	mkdir  "$targetDir"
	# echo "${subDir}${fileMask}" "$targetDir/" 
	mv ${subDir}${fileMask} "$targetDir/"
	return 0
}

#[ -f "*.png" ] && mv *.png "$screenShotsDir/" || echo "* No PNG files in the folder"
[ -n "$(ls *.png)" ] && mv *.png "$screenShotsDir/" || echo "* No PNG files in the folder"

i=0
while true; do
	[ "$i" -gt 1000 ] && break

	mv_files_to_targetFolder "*.jpg" "$photosDir"
	[ "$?" -eq 1 ] && break

	let i=$i+1
done
echo "Number of folder iterations for mask *.jpg is i=$i"

i=0
while true; do
	[ "$i" -gt 1000 ] && break

	mv_files_to_targetFolder "*.png" "$screenShotsDir"
	[ "$?" -eq 1 ] && break

	let i=$i+1
done
echo "Number of folder iterations for mask *.png is i=$i"

echo "`date +%Y-%m-%d" "%H:%M:%S` * Finished archving"
