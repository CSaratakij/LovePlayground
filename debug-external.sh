#!/data/data/com.termux/files/usr/bin/sh
adb logcat --clear
adb shell am force-stop org.love2d.android
make
LOVEFILE=$(basename bin/*.love)
adb push bin/$LOVEFILE /sdcard
adb shell am start -d "file:///sdcard/$LOVEFILE" --user 0 -t "application/*" -n org.love2d.android/org.love2d.android.GameActivity
adb logcat | grep "SDL/APP"
