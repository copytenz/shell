# !/bin/sh
# Convert to 1280x1024 
#
#Приложение 'convert' может быть найдено в следующих пакетах:
# * imagemagick
# * graphicsmagick-imagemagick-compat
# Попробуйте: sudo apt-get install <выбранный пакет>

# temp_pwd=`pwd`
# cd /home/atlant/Photos/for_send/to_process/ 

echo "This script resizes all pictures in current folder and below"
echo " to 1280x1024"
echo "!! Use with caution"
echo "Pres ENTER if you want to continue or ctrl+C if you want to cancel"
read Confirmation

mkdir ../_Nearly_Deleted

# ** Backup copy
find . -iname "*.jpg" -exec cp '{}' ../_Nearly_Deleted/ ';'
find . -iname "*.png" -exec cp '{}' ../_Nearly_Deleted/ ';'
# ** convert files
find . -iname "*.jpg" -exec convert '{}' -resize 1280x1024 '{}' ';'
find . -iname "*.png" -exec convert '{}' -resize 1280x1024 '{}' ';'

