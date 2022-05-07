.PHONY: clean

lovefile = LovePlayground.love

ifeq ($(findstring Android, $(shell uname -a)), Android)
	buildcommand = build_android
	runcommand = run_android
else
	buildcommand = build_linux
	runcommand = run_linux
endif

make: $(buildcommand)

all: $(buildcommand) $(runcommand)

zip:
	@zip -9 -r $(lovefile) . -x ".*" -x "*.sh" -x "README.md" -x "Makefile"

build_linux: zip
	mkdir -p bin/
	mv $(lovefile) bin/

build_android: zip build_linux
	mkdir -p ~/storage/downloads/lovegame
	cp bin/$(lovefile) ~/storage/downloads/lovegame/

run: $(runcommand)

run_linux:
	love bin/$(lovefile)

run_android:
	am start -S -n "org.love2d.android/.GameActivity" -d "file:///sdcard/Download/lovegame/$(lovefile)"

clean:
	rm -f bin/$(lovefile)
