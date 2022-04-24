#!/data/data/com.termux/files/usr/bin/sh
adb logcat --clear
make
adb logcat | grep "SDL/APP"
