#? replace(sub = "\t", by = " ")

## A Nim library for parsing RFC 3986 URL query strings.

import chttpquery

type
	HTTPQueryException* {.pure, inheritable.} = object of CatchableError
	HTTPQueryParseException* {.pure, inheritable.} = object of HTTPQueryException

type
	httpQuery* {.final.} = object
		data: http_query_t
	httpParam* {.final.} = object
		data: hquery_param_t

proc newHttpQuery*(sep: char = '&', subsep: string = "="): httpQuery =
	## Creates a new empty `httpQuery` object.
	## 
	## - `sep`: character used to separate parameters (default `&`).
	## - `subsep`: string used to separate key from value (default `=`).
	
	query_init(query = addr result.data, sep = sep, subsep = cstring(subsep))

proc addString*(query: httpQuery, key: string, value: string): void =
	## Adds a string key-value pair to the query.
	
	let status: cint = query_add_string(
		query = addr query.data,
		key = cstring(key),
		value = cstring(value)
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise newException(OutOfMemDefect, "Could not allocate memory")

proc addInt*(query: httpQuery, key: string, value: BiggestInt): void =
	## Adds an integer key-value pair to the query.
	
	let status: cint = query_add_int(
		query = addr query.data,
		key = cstring(key),
		value = value
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise newException(OutOfMemDefect, "Could not allocate memory")

proc addUInt*(query: httpQuery, key: string, value: BiggestUInt): void =
	## Adds an unsigned integer key-value pair to the query.
	
	let status: cint = query_add_uint(
		query = addr query.data,
		key = cstring(key),
		value = value
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise newException(OutOfMemDefect, "Could not allocate memory")

proc addFloat*(query: httpQuery, key: string, value: BiggestFloat): void =
	## Adds a floating-point key-value pair to the query.
	
	let status: cint = query_add_float(
		query = addr query.data,
		key = cstring(key),
		value = value
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise newException(OutOfMemDefect, "Could not allocate memory")

proc getItem*(query: httpQuery, index: int): hquery_param_t =
	## Returns the raw `hquery_param_t` at the given `index` (0-based).
	
	let param: ptr hquery_param_t = query_get_item(
		query = addr query.data,
		index = csize_t(index)
	)
	
	if param.isNil:
		raise newException(IndexDefect, $index)
	
	result = param[]

proc getString*(query: httpQuery, key: string, decode: bool = true): string =
	## Retrieves a string value by key from the query.
	## 
	## - If `decode` is `true` (default), the value is URL-decoded.
	
	var value: cstring = query_get_string(
		query = addr query.data,
		key = cstring(key)
	)
	
	if value.isNil:
		raise newException(KeyError, key)
	
	if not decode:
		result = $value
		return
			
	var decodedValue: cstring = cast[cstring](alloc(urldecode(value, nil)))
	discard urldecode(value, decodedValue)
	
	result = $decodedValue
	dealloc(decodedValue)

proc getString*(param: httpParam, key: string, decode: bool = true): string =
	## Retrieves a string value by key from a single `httpParam`.
	## 
	## - If `decode` is `true` (default), the value is URL-decoded.
	
	let value: cstring = param_get_string(
		param = addr param.data,
		key = cstring(key)
	)
	
	if value.isNil:
		raise newException(KeyError, key)
	
	if not decode:
		result = $value
		return
			
	var decodedValue: cstring = cast[cstring](alloc(urldecode(value, nil)))
	discard urldecode(value, decodedValue)
	
	result = $decodedValue
	dealloc(decodedValue)

proc getInt*(query: httpQuery, key: string): BiggestInt =
	## Retrieves an integer value by key from the query.
	
	let value: BiggestInt = query_get_int(
		query = addr query.data,
		key = cstring(key)
	)
	
	if value == BIGINT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getInt*(param: httpParam, key: string): BiggestInt =
	## Retrieves an integer value by key from a single `httpParam`.
	
	let value: BiggestInt = param_get_int(
		param = addr param.data,
		key = cstring(key)
	)
	
	if value == BIGINT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getUInt*(query: httpQuery, key: string): BiggestUInt =
	## Retrieves an unsigned integer value by key from the query.
	
	let value: BiggestUInt = query_get_uint(
		query = addr query.data,
		key = cstring(key)
	)
	
	if value == BIGUINT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getUInt*(param: httpParam, key: string): BiggestUInt =
	## Retrieves an unsigned integer value by key from a single `httpParam`.
	
	let value: BiggestUInt = param_get_uint(
		param = addr param.data,
		key = cstring(key)
	)
	
	if value == BIGUINT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getFloat*(query: httpQuery, key: string): BiggestFloat =
	## Retrieves a float value by key from the query.
	
	let value: BiggestFloat = query_get_float(
		query = addr query.data,
		key = cstring(key)
	)
	
	if value == BIGFLOAT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getFloat*(param: httpParam, key: string): BiggestFloat =
	## Retrieves a float value by key from a single `httpParam`.
	
	let value: BiggestFloat = param_get_float(
		param = addr param.data,
		key = cstring(key)
	)
	
	if value == BIGFLOAT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getBool*(query: httpQuery, key: string): bool =
	## Retrieves a boolean value by key from the query.
	
	let value: cint = query_get_bool(
		query = addr query.data,
		key = cstring(key)
	)
	
	if value == HTTPQUERY_ERROR:
		raise newException(KeyError, key)
	
	result = bool(value)

proc getBool*(param: httpParam, key: string): bool =
	## Retrieves a boolean value by key from a single `httpParam`.
	
	let value: cint = param_get_bool(
		param = addr param.data,
		key = cstring(key)
	)
	
	if value == HTTPQUERY_ERROR:
		raise newException(KeyError, key)
	
	result = bool(value)

proc parseString*(query: httpQuery, str: string): void =
	## Parses a query string (e.g. `"key1=value1&key2=value2"`) into the `httpQuery` object.
	
	let status: cint = query_load_string(
		query = addr query.data,
		str = cstring(str)
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise (ref HTTPQueryParseException)(msg: "Parse error")

proc parseFile*(query: httpQuery, filename: string): void =
	## Loads and parses a query string from a file.
	
	let status: cint = query_load_file(
		query = addr query.data,
		filename = cstring(filename)
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise (ref HTTPQueryParseException)(msg: "Parse error")

proc dumpString*(query: httpQuery): string =
	## Serializes the query back into a query string (e.g. `"key1=value1&..."`).
	## The returned string is properly encoded.
	
	let size: csize_t = query_dump_string(
		query = addr query.data,
		destination = nil
	)
	let value: cstring = cstring(newStringUninit(size))
	
	discard query_dump_string(
		query = addr query.data,
		destination = value
	)
	
	result = $value

proc clear*(query: httpQuery): void =
	## Clears all parameters from the query and frees internal memory.
	query_free(query = addr query.data)

proc `$`*(query: httpQuery): string =
	## Converts the `httpQuery` to its string representation (same as `dumpString`).
	
	result = dumpString(query = query)

proc `=destroy`*(query: httpQuery): void =
	## Destructor. Automatically frees the internal query resources.
	
	query_free(query = addr query.data)

proc len*(query: httpQuery): int =
	## Returns the number of parameters currently in the query.
	
	result = int(query.data.offset)