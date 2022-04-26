#!/data/data/com.termux/files/usr/bin/sh
adb logcat --clear
adb shell am force-stop org.love2d.android
make
adb logcat | grep "SDL/APP"
