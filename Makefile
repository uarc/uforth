UASM_U0_32_CONFIG ?= ~/.config/uasm/u0-32.json

all:
	mkdir -p out
	uasm -f hex-list -c $(UASM_U0_32_CONFIG) -o out/seg0 -o out/seg1 $(wildcard src/*.asm)
