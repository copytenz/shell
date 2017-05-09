#!/bin/sh
# Version 2.0
# Change size of all video files to the smaller one. 
# Creates small file near the old ones with
#  ending _LQ.mov
#

echo "This script changes size of all movies with extention MOV and mp4 "
echo " in this folder and below to the smaller size and "
echo "creates new files with ending _LQ.avi"
echo "!! Use with caution"
echo "Pres ENTER if you want to continue or ctrl+C if you want to cancel"
read Confirmation



#cd
#cd /media/atlant/EOS_DIGITAL/DCIM/100CANON || cd /media/atlant/Kingston/DCIM/100CANON
#cd ~/Downloads/video


# ** if ffmmpeg is not found
#sudo add-apt-repository ppa:mc3man/trusty-media
#sudo apt-get update
#sudo apt-get install ffmpeg 



find . -name "*.MOV" -exec sh -c 'ffmpeg -i "{}" -vcodec libx264 -b 2000k -r 30 -vf scale=640:ih*640/iw "`basename \"{}\" .MOV`_LQ.avi" && mv "{}" "`basename \"{}\" .avi`" ' \; 2> _ffmpeg.log
find . -name "*.mp4" -exec sh -c 'ffmpeg -i "{}" -vcodec libx264 -b 2000k -r 30 -vf scale=640:ih*640/iw "`basename \"{}\" .mp4`_LQ.avi" && mv "{}" "`basename \"{}\" .avi`" ' \; 2> _ffmpeg.log

#cp *.mov /mnt/granary/private/photos/2014/2014_Video

mkdir _Nearly_Deleted
# ** Move old BIG files
find . -name "*.MOV" -exec mv '{}' ./_Nearly_Deleted/ ';'
find . -name "*.THM" -exec mv '{}' ./_Nearly_Deleted/ ';'

