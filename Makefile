all:
	odin build . -extra-linker-flags:"-L./libduckdb -lduckdb" -out:example

run: all
	DYLD_LIBRARY_PATH=./libduckdb ./example

clean:
	rm -f example

.PHONY: all run clean
