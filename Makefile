.PHONY: build snap all clean

build:
	pnpm build

snap:
	snapcraft pack --destructive-mode

all: snap

clean:
	snapcraft clean
	rm -f *.snap
