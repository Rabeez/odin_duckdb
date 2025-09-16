all:
	odin build . -extra-linker-flags:"-L./libduckdb -lduckdb" -out:example

run: all
	LD_LIBRARY_PATH=./libduckdb ./example

clean:
	rm -f example

.PHONY: all run clean
