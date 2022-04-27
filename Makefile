.PHONY: clean

lovefile = LovePlayground.love

ifeq ($(findstring Android, $(shell uname -a)), Android)
	runcommand = run_android
else
	runcommand = run_linux
endif

all: zip $(runcommand)

zip:
	@zip -9 -r $(lovefile) . -x ".*"
	mkdir -p bin/
	mv $(lovefile) bin/

run_linux:
	love bin/$(lovefile)

run_android:
	mkdir -p ~/storage/downloads/lovegame
	cp bin/$(lovefile) ~/storage/downloads/lovegame/
	am start -d "file:///sdcard/Download/lovegame/$(lovefile)" --user 0 -t "application/*" -n org.love2d.android/org.love2d.android.GameActivity

clean:
	rm -f bin/$(lovefile)
