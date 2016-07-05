UASM_U0_32_CONFIG ?= ~/.config/uasm/u0-32.json

all:
	mkdir -p out
	uasm -f hex-list -c $(UASM_U0_32_CONFIG) -o out/prog -o out/data $(wildcard src/*.asm)
