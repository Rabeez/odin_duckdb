package main

import "core:fmt"
import "core:os"
import "core:text/table"

print_results :: proc(query_result: ^duckdb_result) {
	column_count := duckdb_column_count(query_result)
	row_count := duckdb_row_count(query_result)

	t := table.init(&table.Table{}, context.allocator)
	defer table.destroy(t)

	// Table metadata
	table.caption(t, fmt.tprintf("Results (%d rows, %d columns):\n", row_count, column_count))
	table.padding(t, 1, 1)

	// Headers
	headers := make([]any, column_count)
	defer delete(headers)

	for i in 0 ..< column_count {
		name := duckdb_column_name(query_result, i)
		headers[i] = string(name)
	}
	table.header(t, ..headers)

	// Data rows
	for row in 0 ..< row_count {
		row_data := make([]any, column_count)
		defer delete(row_data)

		for col in 0 ..< column_count {
			if duckdb_value_is_null(query_result, col, row) {
				row_data[col] = "NULL"
				continue
			}

			col_type := duckdb_column_type(query_result, col)
			switch col_type {
			case .INVALID:
				row_data[col] = "INVALID"
			case .BOOLEAN:
				val := duckdb_value_boolean(query_result, col, row)
				row_data[col] = fmt.tprintf("%t", val)
			case .TINYINT:
				val := duckdb_value_int8(query_result, col, row)
				row_data[col] = fmt.tprintf("%d", val)
			case .SMALLINT:
				val := duckdb_value_int16(query_result, col, row)
				row_data[col] = fmt.tprintf("%d", val)
			case .INTEGER:
				val := duckdb_value_int32(query_result, col, row)
				row_data[col] = fmt.tprintf("%d", val)
			case .BIGINT:
				val := duckdb_value_int64(query_result, col, row)
				row_data[col] = fmt.tprintf("%d", val)
			case .UTINYINT:
				val := duckdb_value_uint8(query_result, col, row)
				row_data[col] = fmt.tprintf("%d", val)
			case .USMALLINT:
				val := duckdb_value_uint16(query_result, col, row)
				row_data[col] = fmt.tprintf("%d", val)
			case .UINTEGER:
				val := duckdb_value_uint32(query_result, col, row)
				row_data[col] = fmt.tprintf("%d", val)
			case .UBIGINT:
				val := duckdb_value_uint64(query_result, col, row)
				row_data[col] = fmt.tprintf("%d", val)
			case .FLOAT:
				val := duckdb_value_float(query_result, col, row)
				row_data[col] = fmt.tprintf("%.2f", val)
			case .DOUBLE:
				val := duckdb_value_double(query_result, col, row)
				row_data[col] = fmt.tprintf("%.2f", val)
			case .TIMESTAMP:
				// Timestamp as microseconds since epoch
				val := duckdb_value_int64(query_result, col, row)
				row_data[col] = fmt.tprintf("%d", val)
			case .DATE:
				// Date as days since epoch
				val := duckdb_value_int32(query_result, col, row)
				fmt.printf("%d\t", val)
			case .TIME:
				// Time as microseconds since midnight
				val := duckdb_value_int64(query_result, col, row)
				row_data[col] = fmt.tprintf("%d", val)
			case .VARCHAR:
				val := duckdb_value_varchar(query_result, col, row)
				row_data[col] = string(val)
			case .INTERVAL:
				row_data[col] = "INTERVAL" // Complex type, needs special handling
			case .HUGEINT:
				row_data[col] = "HUGEINT" // 128-bit int, needs special handling
			case .BLOB:
				row_data[col] = "BLOB" // Binary data, needs special handling
			case .DECIMAL:
				row_data[col] = "DECIMAL" // Needs special handling
			case .TIMESTAMP_S, .TIMESTAMP_MS, .TIMESTAMP_NS, .TIMESTAMP_TZ:
				val := duckdb_value_int64(query_result, col, row)
				row_data[col] = fmt.tprintf("%d", val)
			case .ENUM, .LIST, .STRUCT, .MAP, .UUID, .UNION, .BIT, .TIME_TZ, .UHUGEINT, .ARRAY:
				row_data[col] = fmt.tprintf("%v", col_type)
			}
		}
		table.row(t, ..row_data)
	}

	stdout := table.stdio_writer()
	table.write_plain_table(stdout, t)
}

main :: proc() {
	sql_data, read_ok := os.read_entire_file("example.sql")
	if !read_ok {
		fmt.println("Failed to read example.sql")
		return
	}
	// defer delete(sql_data)

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
	query_cstr := fmt.ctprintf("%s", query)
	// defer delete(query_cstr)

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
