# httpquery

A Nim library for parsing RFC 3986 URL query strings.

## Installation

Install using `nimble`:

```bash
nimble install --accept httpquery
```

## Usage:

Parse an arbitrary query string:

```nim
import httpquery

let q = newHttpQuery()
q.parseString("key=value&anotherkey=anothervalue")

assert q.getString("key") == "value"
assert q.getString("anotherkey") == "anothervalue"
```

Dynamically create query strings:

```nim
import httpquery

let q = newHttpQuery()
q.addString("name", "John Smith")
q.addInt("age", 35)
q.addFloat("height", 1.75)
q.addUInt("score", 1337'u)

echo q
# Output: name=John%20Smith&age=35&height=1.750000&score=1337
```

See the [documentation](https://amanoteam.github.io/httpquery/docs/httpquery.html) for more info.
