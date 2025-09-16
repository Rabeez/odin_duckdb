package main

foreign import duckdb "libduckdb/libduckdb.dylib"

@(default_calling_convention="c")
foreign duckdb {
    duckdb_open :: proc(path: cstring, out_database: rawptr) -> i32 ---
    duckdb_close :: proc(database: rawptr) ---
}
