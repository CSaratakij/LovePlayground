.PHONY: clean

lovefile = LovePlayground.love

all: zip run_android

zip:
	@zip -9 -r $(lovefile) .
	mv $(lovefile) bin/

run_android:
	cp bin/$(lovefile) ~/storage/downloads/lovegame/
	am start -d "file:///sdcard/Download/lovegame/$(lovefile)" --user 0 -t "application/*" -n org.love2d.android/org.love2d.android.GameActivity

clean:
	rm -f bin/$(lovefile)
