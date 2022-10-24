![jevko.lua logo](logo.svg)

# jevko.lua

A single-file [Jevko](https://jevko.org) library for Lua. Inspired by [rxi/json.lua](https://github.com/rxi/json.lua).

Encodes and decodes plain Jevko.

# Features

* Simple
* Lightweight: ~3 KiB, < 100 SLOC
* Error messages with `line:column` information, e.g. `Invalid digraph (x) at 1:10!`

# Usage

Copy the [jevko.lua](jevko.lua?raw=1) file into your project and require it:

```lua
jevko = require "jevko"
```

You can now use the following functions:

## jevko.from_string(str)

Aliases: `jevko.decode`, `jevko.fromString`.

Turns a string into a Jevko parse tree, e.g.:

```lua
jevko.from_string([=[
id [10]
colors [
  [red]
  [yellow]
  [blue]
]
]=])
```

returns

```lua
{
  subjevkos = {
    {prefix = "id ", jevko = {subjevkos = {}, suffix = "10"}},
    {prefix = "\ncolors ", jevko = {
      subjevkos = {
        {prefix = "\n  ", jevko = {subjevkos = {}, suffix = "red"}},
        {prefix = "\n  ", jevko = {subjevkos = {}, suffix = "yellow"}},
        {prefix = "\n  ", jevko = {subjevkos = {}, suffix = "blue"}},
      },
      suffix = "\n"
    }},
  },
  suffix = "\n"
}
```

## jevko.to_string(jev)

Aliases: `jevko.encode`, `jevko.toString`.

Inverse of [`jevko.from_string`](#jevkofrom_stringstr).

Serializes a Jevko parse tree into a string, e.g.:

```lua
jevko.to_string({
  subjevkos = {
    {prefix = "id ", jevko = {subjevkos = {}, suffix = "10"}},
    {prefix = "\ncolors ", jevko = {
      subjevkos = {
        {prefix = "\n  ", jevko = {subjevkos = {}, suffix = "red"}},
        {prefix = "\n  ", jevko = {subjevkos = {}, suffix = "yellow"}},
        {prefix = "\n  ", jevko = {subjevkos = {}, suffix = "blue"}},
      },
      suffix = "\n"
    }},
  },
  suffix = "\n"
})
```

returns the string

```
id [10]
colors [
  [red]
  [yellow]
  [blue]
]

```

## jevko.escape(str)

A helper function which can be used with custom Jevko encoders.

Turns a string into a Jevko-safe string by escaping special characters, e.g.:

```lua
jevko.escape("Only these three are special: ` [ ]")
```

returns

```lua
"Only these three are special: `` `[ `]"
```

# License

[MIT](LICENSE)