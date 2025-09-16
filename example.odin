package main

import "core:fmt"
import "core:os"

print_results :: proc(query_result: ^duckdb_result) {
	column_count := duckdb_column_count(query_result)
	row_count := duckdb_row_count(query_result)

	fmt.printf("Results (%d rows, %d columns):\n", row_count, column_count)

	// Print column headers
	for i in 0 ..< column_count {
		name := duckdb_column_name(query_result, i)
		fmt.printf("%s\t", name)
	}
	fmt.println()

	// Print data rows
	for row in 0 ..< row_count {
		for col in 0 ..< column_count {
			if duckdb_value_is_null(query_result, col, row) {
				fmt.printf("NULL\t")
				continue
			}

			col_type := duckdb_column_type(query_result, col)

			switch col_type {
			case .INVALID:
				fmt.printf("INVALID\t")
			case .BOOLEAN:
				val := duckdb_value_boolean(query_result, col, row)
				fmt.printf("%t\t", val)
			case .TINYINT:
				val := duckdb_value_int8(query_result, col, row)
				fmt.printf("%d\t", val)
			case .SMALLINT:
				val := duckdb_value_int16(query_result, col, row)
				fmt.printf("%d\t", val)
			case .INTEGER:
				val := duckdb_value_int32(query_result, col, row)
				fmt.printf("%d\t", val)
			case .BIGINT:
				val := duckdb_value_int64(query_result, col, row)
				fmt.printf("%d\t", val)
			case .UTINYINT:
				val := duckdb_value_uint8(query_result, col, row)
				fmt.printf("%d\t", val)
			case .USMALLINT:
				val := duckdb_value_uint16(query_result, col, row)
				fmt.printf("%d\t", val)
			case .UINTEGER:
				val := duckdb_value_uint32(query_result, col, row)
				fmt.printf("%d\t", val)
			case .UBIGINT:
				val := duckdb_value_uint64(query_result, col, row)
				fmt.printf("%d\t", val)
			case .FLOAT:
				val := duckdb_value_float(query_result, col, row)
				fmt.printf("%.2f\t", val)
			case .DOUBLE:
				val := duckdb_value_double(query_result, col, row)
				fmt.printf("%.2f\t", val)
			case .TIMESTAMP:
				// Timestamp as microseconds since epoch
				val := duckdb_value_int64(query_result, col, row)
				fmt.printf("%d\t", val)
			case .DATE:
				// Date as days since epoch
				val := duckdb_value_int32(query_result, col, row)
				fmt.printf("%d\t", val)
			case .TIME:
				// Time as microseconds since midnight
				val := duckdb_value_int64(query_result, col, row)
				fmt.printf("%d\t", val)
			case .INTERVAL:
				fmt.printf("INTERVAL\t") // Complex type, needs special handling
			case .HUGEINT:
				fmt.printf("HUGEINT\t") // 128-bit int, needs special handling
			case .VARCHAR:
				val := duckdb_value_varchar(query_result, col, row)
				fmt.printf("%s\t", val)
			case .BLOB:
				fmt.printf("BLOB\t") // Binary data, needs special handling
			case .DECIMAL:
				fmt.printf("DECIMAL\t") // Needs special handling
			case .TIMESTAMP_S:
				val := duckdb_value_int64(query_result, col, row)
				fmt.printf("%d\t", val)
			case .TIMESTAMP_MS:
				val := duckdb_value_int64(query_result, col, row)
				fmt.printf("%d\t", val)
			case .TIMESTAMP_NS:
				val := duckdb_value_int64(query_result, col, row)
				fmt.printf("%d\t", val)
			case .ENUM:
				fmt.printf("ENUM\t")
			case .LIST:
				fmt.printf("LIST\t")
			case .STRUCT:
				fmt.printf("STRUCT\t")
			case .MAP:
				fmt.printf("MAP\t")
			case .UUID:
				fmt.printf("UUID\t")
			case .UNION:
				fmt.printf("UNION\t")
			case .BIT:
				fmt.printf("BIT\t")
			case .TIME_TZ:
				fmt.printf("TIME_TZ\t")
			case .TIMESTAMP_TZ:
				val := duckdb_value_int64(query_result, col, row)
				fmt.printf("%d\t", val)
			case .UHUGEINT:
				fmt.printf("UHUGEINT\t")
			case .ARRAY:
				fmt.printf("ARRAY\t")
			}
		}
		fmt.println()
	}
}

main :: proc() {
	sql_data, read_ok := os.read_entire_file("example.sql")
	if !read_ok {
		fmt.println("Failed to read example.sql")
		return
	}
	defer delete(sql_data)

	query := string(sql_data)

	db: duckdb_database
	result := duckdb_open(nil, &db) // nil for in-memory database
	if result != .SUCCESS {
		fmt.println("Failed to open database")
		return
	}
	defer duckdb_close(&db)

	conn: duckdb_connection
	result = duckdb_connect(db, &conn)
	if result != .SUCCESS {
		fmt.println("Failed to connect to database")
		return
	}
	defer duckdb_disconnect(&conn)

	query_result: duckdb_result
	query_cstr := fmt.caprintf("%s", query)
	defer delete(query_cstr)

	result = duckdb_query(conn, query_cstr, &query_result)
	if result != .SUCCESS {
		error_msg := duckdb_result_error(&query_result)
		fmt.printf("Query failed: %s\n", error_msg)
		duckdb_destroy_result(&query_result)
		return
	}
	defer duckdb_destroy_result(&query_result)

	print_results(&query_result)
}
