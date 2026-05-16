#? replace(sub = "\t", by = " ")

import std/os

{.passC: "-I" & parentDir(currentSourcePath).}
{.compile: "hex.c".}
{.compile: "strsplit.c".}
{.compile: "urldecode.c".}
{.compile: "urlencode.c".}
{.compile: "fs/fstream.c".}
{.compile: "query.c".}

const HTTPQUERY_SUCCESS*: cint = 0
const HTTPQUERY_ERROR*: cint = -1

let
	BIGINT_MAX* {.importc: "BIGINT_MAX", header: "biggestint.h", nodecl.}: BiggestInt
	BIGUINT_MAX* {.importc: "BIGINT_MAX", header: "biggestint.h", nodecl.}: BiggestUInt
	BIGFLOAT_MAX* {.importc: "BIGFLOAT_MAX", header: "biggestint.h", nodecl.}: BiggestFloat

type
	bigint_t* {.importc: "bigint_t", header: "biggestint.h", nodecl, final.} = BiggestInt
	biguint_t* {.importc: "biguint_t", header: "biggestint.h", nodecl, final.} = BiggestUInt
	bigfloat_t* {.importc: "bigfloat_t", header: "biggestint.h", nodecl, final.} = BiggestFloat
	hquery_param_t* {.final.} = object
		key*: cstring
		value*: cstring
	http_query_t* {.final.} = object
		size*: csize_t
		offset*: csize_t
		parameters*: ptr hquery_param_t
		sep*: cchar
		subsep*: cstring
		options*: cint

func query_add_string*(query: ptr http_query_t, key: cstring, value: cstring): cint {.cdecl, header: "query.h", importc: "query_add_string".}
func query_add_int*(query: ptr http_query_t, key: cstring, value: bigint_t): cint {.cdecl, header: "query.h", importc: "query_add_int".}
func query_add_uint*(query: ptr http_query_t, key: cstring, value: biguint_t): cint {.cdecl, header: "query.h", importc: "query_add_uint".}
func query_add_float*(query: ptr http_query_t, key: cstring, value: bigfloat_t): cint {.cdecl, header: "query.h", importc: "query_add_float".}

func query_get_item*(query: ptr http_query_t, index: csize_t): ptr hquery_param_t {.cdecl, header: "query.h", importc: "query_get_item".}

func query_get_string*(query: ptr http_query_t, key: cstring): cstring {.cdecl, header: "query.h", importc: "query_get_string".}
func param_get_string*(param: ptr hquery_param_t, key: cstring): cstring {.cdecl, header: "query.h", importc: "param_get_string".}

func query_get_int*(query: ptr http_query_t, key: cstring): bigint_t {.cdecl, header: "query.h", importc: "query_get_int".}
func param_get_int*(param: ptr hquery_param_t, key: cstring): bigint_t {.cdecl, header: "query.h", importc: "param_get_int".}

func query_get_uint*(query: ptr http_query_t, key: cstring): biguint_t {.cdecl, header: "query.h", importc: "query_get_uint".}
func param_get_uint*(param: ptr hquery_param_t, key: cstring): biguint_t {.cdecl, header: "query.h", importc: "param_get_uint".}

func query_get_float*(query: ptr http_query_t, key: cstring): bigfloat_t {.cdecl, header: "query.h", importc: "query_get_float".}
func param_get_float*(param: ptr hquery_param_t, key: cstring): bigfloat_t {.cdecl, header: "query.h", importc: "param_get_float".}

func query_get_bool*(query: ptr http_query_t, key: cstring): cint {.cdecl, header: "query.h", importc: "query_get_bool".}
func param_get_bool*(param: ptr hquery_param_t, key: cstring): cint {.cdecl, header: "query.h", importc: "param_get_bool".}

func query_init*(query: ptr http_query_t, sep: cchar, subsep: cstring): void {.cdecl, header: "query.h", importc: "query_init".}
func query_free*(query: ptr http_query_t): void {.cdecl, header: "query.h", importc: "query_free".}

func query_load_string*(query: ptr http_query_t, str: cstring): cint {.cdecl, header: "query.h", importc: "query_load_string".}
func query_load_file*(query: ptr http_query_t, filename: cstring): cint {.cdecl, header: "query.h", importc: "query_load_file".}

func param_free*(param: ptr hquery_param_t): void {.cdecl, header: "query.h", importc: "param_free".}

func query_dump_string*(query: ptr http_query_t, destination: cstring): csize_t {.cdecl, header: "query.h", importc: "query_dump_string".}
func query_dump_file*(query: ptr http_query_t, filename: cstring): csize_t {.cdecl, header: "query.h", importc: "query_dump_file".}

func urldecode*(uri: cstring, destination: cstring): csize_t {.cdecl, header: "urldecode.h", importc: "urldecode".}
