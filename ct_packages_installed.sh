# !/bin/sh
dpkg --get-selections | grep -v deinstall
