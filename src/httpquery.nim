#? replace(sub = "\t", by = " ")

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
	query_init(query = addr result.data, sep = sep, subsep = cstring(subsep))

proc addString*(query: httpQuery, key: string, value: string): void =
	let status: cint = query_add_string(
		query = addr query.data,
		key = cstring(key),
		value = cstring(value)
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise newException(OutOfMemDefect, "Could not allocate memory")

proc addInt*(query: httpQuery, key: string, value: BiggestInt): void =
	let status: cint = query_add_int(
		query = addr query.data,
		key = cstring(key),
		value = value
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise newException(OutOfMemDefect, "Could not allocate memory")

proc addUInt*(query: httpQuery, key: string, value: BiggestUInt): void =
	let status: cint = query_add_uint(
		query = addr query.data,
		key = cstring(key),
		value = value
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise newException(OutOfMemDefect, "Could not allocate memory")

proc addFloat*(query: httpQuery, key: string, value: BiggestFloat): void =
	let status: cint = query_add_float(
		query = addr query.data,
		key = cstring(key),
		value = value
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise newException(OutOfMemDefect, "Could not allocate memory")

proc getItem*(query: httpQuery, index: int): hquery_param_t =
	let param: ptr hquery_param_t = query_get_item(
		query = addr query.data,
		index = csize_t(index)
	)
	
	if param.isNil:
		raise newException(IndexDefect, $index)
	
	result = param[]


proc getString*(query: httpQuery, key: string, decode: bool = true): string =
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
	let value: BiggestInt = query_get_int(
		query = addr query.data,
		key = cstring(key)
	)
	
	if value == BIGINT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getInt*(param: httpParam, key: string): BiggestInt =
	let value: BiggestInt = param_get_int(
		param = addr param.data,
		key = cstring(key)
	)
	
	if value == BIGINT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getUInt*(query: httpQuery, key: string): BiggestUInt =
	let value: BiggestUInt = query_get_uint(
		query = addr query.data,
		key = cstring(key)
	)
	
	if value == BIGUINT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getUInt*(param: httpParam, key: string): BiggestUInt =
	let value: BiggestUInt = param_get_uint(
		param = addr param.data,
		key = cstring(key)
	)
	
	if value == BIGUINT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getFloat*(query: httpQuery, key: string): BiggestFloat =
	let value: BiggestFloat = query_get_float(
		query = addr query.data,
		key = cstring(key)
	)
	
	if value == BIGFLOAT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getFloat*(param: httpParam, key: string): BiggestFloat =
	let value: BiggestFloat = param_get_float(
		param = addr param.data,
		key = cstring(key)
	)
	
	if value == BIGFLOAT_MAX:
		raise newException(KeyError, key)
	
	result = value

proc getBool*(query: httpQuery, key: string): bool =
	let value: cint = query_get_bool(
		query = addr query.data,
		key = cstring(key)
	)
	
	if value == HTTPQUERY_ERROR:
		raise newException(KeyError, key)
	
	result = bool(value)

proc getBool*(param: httpParam, key: string): bool =
	let value: cint = param_get_bool(
		param = addr param.data,
		key = cstring(key)
	)
	
	if value == HTTPQUERY_ERROR:
		raise newException(KeyError, key)
	
	result = bool(value)

proc parseString*(query: httpQuery, str: string): void =
	let status: cint = query_load_string(
		query = addr query.data,
		str = cstring(str)
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise (ref HTTPQueryParseException)(msg: "Parse error")

proc parseFile*(query: httpQuery, filename: string): void =
	let status: cint = query_load_file(
		query = addr query.data,
		filename = cstring(filename)
	)
	
	if status != HTTPQUERY_SUCCESS:
		raise (ref HTTPQueryParseException)(msg: "Parse error")

proc dumpString*(query: httpQuery): string =
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
	query_free(query = addr query.data)

proc `$`*(query: httpQuery): string =
	result = dumpString(query = query)

proc `=destroy`*(query: httpQuery): void =
	query_free(query = addr query.data)

proc len*(query: httpQuery): int =
	result = int(query.data.offset)
