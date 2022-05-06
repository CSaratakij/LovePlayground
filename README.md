# LovePlayground
- Personal love2d playground in Termux (Android, aarch64, non-proot)

# Getting Started
1) Setup termux storage with "termux-setup-storage"
2) Make sure all dependencies satify
3) Run "make all", ".love" will store in bin directory
4) Close love2d app before restart to guarantee fresh start (not required with run 'debug' option)

# Run Option
- $make : build .love
- $make all : build & run .love (local)
- $make run : run previous build .love (local)
- $debug-local.sh : build, run & print logcat (adb to localhost required)
- $debug-external.sh : build, run & print logcat of other device (adb to other devices required, other device need to install love2d app as well)

# Note
- Before $adb connect, don't forget to pair first

# Dependencies
- make
- zip
- android-tools
- Termux (from F-Droid)
- love2d (android app)
