package main

foreign import duckdb "libduckdb/libduckdb.dylib"

// Enums
duckdb_type :: enum i32 {
	INVALID      = 0,
	BOOLEAN      = 1,
	TINYINT      = 2,
	SMALLINT     = 3,
	INTEGER      = 4,
	BIGINT       = 5,
	UTINYINT     = 6,
	USMALLINT    = 7,
	UINTEGER     = 8,
	UBIGINT      = 9,
	FLOAT        = 10,
	DOUBLE       = 11,
	TIMESTAMP    = 12,
	DATE         = 13,
	TIME         = 14,
	INTERVAL     = 15,
	HUGEINT      = 16,
	VARCHAR      = 17,
	BLOB         = 18,
	DECIMAL      = 19,
	TIMESTAMP_S  = 20,
	TIMESTAMP_MS = 21,
	TIMESTAMP_NS = 22,
	ENUM         = 23,
	LIST         = 24,
	STRUCT       = 25,
	MAP          = 26,
	UUID         = 27,
	UNION        = 28,
	BIT          = 29,
	TIME_TZ      = 30,
	TIMESTAMP_TZ = 31,
	UHUGEINT     = 32,
	ARRAY        = 33,
}

duckdb_state :: enum i32 {
	SUCCESS = 0,
	ERROR   = 1,
}

// Types
idx_t :: u64

duckdb_database :: rawptr
duckdb_connection :: rawptr
duckdb_result :: rawptr
duckdb_prepared_statement :: rawptr
duckdb_appender :: rawptr

duckdb_date :: struct {
	days: i32,
}

duckdb_time :: struct {
	micros: i64,
}

duckdb_timestamp :: struct {
	micros: i64,
}

duckdb_interval :: struct {
	months: i32,
	days:   i32,
	micros: i64,
}

duckdb_hugeint :: struct {
	lower: u64,
	upper: i64,
}

duckdb_decimal :: struct {
	width: u8,
	scale: u8,
	value: duckdb_hugeint,
}

@(default_calling_convention = "c")
foreign duckdb {
	// Database connection
	duckdb_open :: proc(path: cstring, out_database: ^duckdb_database) -> duckdb_state ---
	duckdb_close :: proc(database: ^duckdb_database) ---
	duckdb_connect :: proc(database: duckdb_database, out_connection: ^duckdb_connection) -> duckdb_state ---
	duckdb_disconnect :: proc(connection: ^duckdb_connection) ---

	// Query execution
	duckdb_query :: proc(connection: duckdb_connection, query: cstring, out_result: ^duckdb_result) -> duckdb_state ---
	duckdb_destroy_result :: proc(result: ^duckdb_result) ---

	// Result inspection
	duckdb_column_count :: proc(result: ^duckdb_result) -> idx_t ---
	duckdb_row_count :: proc(result: ^duckdb_result) -> idx_t ---
	duckdb_rows_changed :: proc(result: ^duckdb_result) -> idx_t ---
	duckdb_column_name :: proc(result: ^duckdb_result, col: idx_t) -> cstring ---
	duckdb_column_type :: proc(result: ^duckdb_result, col: idx_t) -> duckdb_type ---
	duckdb_result_error :: proc(result: ^duckdb_result) -> cstring ---

	// Value access
	duckdb_value_boolean :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> bool ---
	duckdb_value_int8 :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> i8 ---
	duckdb_value_int16 :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> i16 ---
	duckdb_value_int32 :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> i32 ---
	duckdb_value_int64 :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> i64 ---
	duckdb_value_uint8 :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> u8 ---
	duckdb_value_uint16 :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> u16 ---
	duckdb_value_uint32 :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> u32 ---
	duckdb_value_uint64 :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> u64 ---
	duckdb_value_float :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> f32 ---
	duckdb_value_double :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> f64 ---
	duckdb_value_varchar :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> cstring ---
	duckdb_value_is_null :: proc(result: ^duckdb_result, col: idx_t, row: idx_t) -> bool ---

	// Prepared statements
	duckdb_prepare :: proc(connection: duckdb_connection, query: cstring, out_prepared_statement: ^duckdb_prepared_statement) -> duckdb_state ---
	duckdb_destroy_prepare :: proc(prepared_statement: ^duckdb_prepared_statement) ---
	duckdb_execute_prepared :: proc(prepared_statement: duckdb_prepared_statement, out_result: ^duckdb_result) -> duckdb_state ---

	// Parameter binding
	duckdb_bind_boolean :: proc(prepared_statement: duckdb_prepared_statement, param_idx: idx_t, val: bool) -> duckdb_state ---
	duckdb_bind_int32 :: proc(prepared_statement: duckdb_prepared_statement, param_idx: idx_t, val: i32) -> duckdb_state ---
	duckdb_bind_int64 :: proc(prepared_statement: duckdb_prepared_statement, param_idx: idx_t, val: i64) -> duckdb_state ---
	duckdb_bind_double :: proc(prepared_statement: duckdb_prepared_statement, param_idx: idx_t, val: f64) -> duckdb_state ---
	duckdb_bind_varchar :: proc(prepared_statement: duckdb_prepared_statement, param_idx: idx_t, val: cstring) -> duckdb_state ---
	duckdb_bind_null :: proc(prepared_statement: duckdb_prepared_statement, param_idx: idx_t) -> duckdb_state ---

	// Appender
	duckdb_appender_create :: proc(connection: duckdb_connection, schema: cstring, table: cstring, out_appender: ^duckdb_appender) -> duckdb_state ---
	duckdb_appender_destroy :: proc(appender: ^duckdb_appender) -> duckdb_state ---
	duckdb_appender_end_row :: proc(appender: duckdb_appender) -> duckdb_state ---
	duckdb_append_int32 :: proc(appender: duckdb_appender, value: i32) -> duckdb_state ---
	duckdb_append_int64 :: proc(appender: duckdb_appender, value: i64) -> duckdb_state ---
	duckdb_append_double :: proc(appender: duckdb_appender, value: f64) -> duckdb_state ---
	duckdb_append_varchar :: proc(appender: duckdb_appender, val: cstring) -> duckdb_state ---
	duckdb_append_null :: proc(appender: duckdb_appender) -> duckdb_state ---

	// Memory management
	duckdb_free :: proc(ptr: rawptr) ---
}
