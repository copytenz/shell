#!/bin/bash

################################################################################
# SCRIPT: 	plymouth-install.sh
#
# DESCRIPTION:	Installs plymouth theme from the current folder
#		NOTE, the script:
# 		* assumes that the system is using alternatives
#		* assumes that the folder is located in current folder and shall
#		  be copied to /usr/share/plymouth/themes
#		* assumes that the ".script" file and ".plymouth" file are named
#		  with the same name as theme name 
#
# USAGE: 	plymouth-install.sh [themeFolder]
# 		if themeFolder is not set, the scripts asks for it and checks that
#		  such subfolder exists in the current one
#
# VERSION: 	1.0 
# VERSION DATE:	2018-01-20
# CHANGE BY:	4e
# CHANGES:	* new script
################################################################################


# Check if I am root - then I am krut, otherwise re-run this script as root
 if [ $(whoami) == "root" ];then
	 echo "Running install-plymouth.sh as root" 
 else
	echo "The script is started without root priveledges, trying to restart it with sudo"
	sudo /bin/bash $0
	exit
 fi


# variable for theme name, so that one don't need to enter it everytime he wants to install new one
# if set as parameter 1 to the script - use it as theme name 
# not the best example of code, but if such subfolder exists in your space than treat this as bad luck
[ -z $1 ] && themeName="NOT-SET" || themeName=$1

echo "The name of theme is $themeName"
read -p "just a stop on my way" anykey
while true; do
	read -p "Enter theme name. Please ensure that folder with such name exists in the current directory: " themeName
	[ -d "./$themeName" ] &&  break || echo "Folder ./$themeName doesn't exist"	
done

 if [ ! $(pwd) == "/usr/share/plymouth/themes" ]; then	
	cp -r  "./$themeName" "/usr/sharee/plymouth/themes/"
	chgrp users /usr/share/pymouth/themes
	chmod u+rwX,g+rwX /usr/share/plymouth/themes
	cd /usr/share/plymouth/themes
 fi
	
update-alternatives --install "/usr/share/plymouth/themes/default.plymouth" "default.plymouth" "/usr/share/plymouth/themes/$themeName/$themeName.plymouth" 200
update-alternatives --config default.plymouth

update-initramfs -u
