#convert all svg in folder to png with widtch 30
for file in *.svg; do inkscape $file -w30 -e ${file%svg}png; done 1> /dev/null

#convert black color in all png in folder to #5c5959
for file in *.png; do convert $file -fuzz 10% -fill "#5c5959" -opaque black $file; done

