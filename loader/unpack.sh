#!/bin/bash

# VERSION DATE: 2017-11-22
# One-off script for installation on date: 2017-11-24

formattedDate=`date +%Y-%m-%d`
scriptsInstallDir=/opt/loader/install/$formattedDate
tmpUnpackDir=tmp$formattedDate
scriptsArchive=scripts_2017-11-22.tgz 
securityGroup=loader

umask 0002
mkdir -p $scriptsInstallDir
chgrp $securityGroup $scriptsInstallDir

mkdir -p $tmpUnpackDir
cp $scriptsArchive $tmpUnpackDir/
pushd $tmpUnpackDir
tar zxvf $scriptsArchive
cp -f ./*.sh $scriptsInstallDir/
popd
read -p "Do you want to remove temporary folder? (y/n) " answer
[ "$answer" == "y" ] && rm -r $tmpUnpackDir

