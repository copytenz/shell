#!/bin/bash

################################################################################
# SCRIPT: 	set_permissions.sh
#
# DESCRIPTION:	Sets permissions to the folder and subfolders including current
# 		permissions and default permissions for future
#
# USAGE: 	set_permissions.sh 
# 
# VERSION: 	1.0 
# VERSION DATE:	2017-11-22
# CHANGE BY:	4e
# CHANGES:	* New script
################################################################################


#-- Set common variables
export workDir=/opt/loader
export securityOwner=srvjavload
export securityGroup=loader
export defaultDirPermissions=775
export defaultShellScriptsPermissions=774

echo "Set correct owner and group recursively"
chown -R $securityOwner:$securityGroup $workDir
chmod -R u+rw,g+rw,o+r $workDir

echo "Give group read,write,exec permissions for currently existing files and folders, recursively"
find $workDir -type d -exec chmod $defaultDirPermissions {} \;
find $workDir -iname "*.sh" -exec chmod $defaultShellScriptsPermissions {} \;

echo "Set superbit for folders, so that all subfolders are created with the same group as an owner"
find $workDir -type d -exec chmod g+s {} \;

echo  "Recursively give user and group \"rwx\" and others \"rx\" by default"
setfacl -R -d -m u::rwx,g::rwx,o::rx "$workDir"
