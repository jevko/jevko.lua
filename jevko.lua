-- jevko.lua

-- Copyright (c) 2022 Darius J Chuck

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.

local jevko = { _version = "0.1.0" }

local escaper = "`"
local opener = "["
local closer = "]"

local function parse_jevko(str)
  local parents = {}
  local parent = {subjevkos = {}}
  local prefix = ""
  local h = 1
  local is_escaped = false
  local line = 1
  local column = 1

  for i = 1, #str do
    local c = str:sub(i,i)

    if is_escaped then
      if c == opener or c == closer or c == escaper then
        is_escaped = false
      else
        error("Invalid digraph ("..escaper..c..") at "..line..":"..column.."!")
      end
    elseif c == escaper then
      prefix = prefix..str.sub(h, i - 1)
      h = i + 1
      is_escaped = true
    elseif c == opener then
      local jevko = {subjevkos = {}}
      table.insert(parent.subjevkos, {prefix = prefix .. str:sub(h, i - 1), jevko = jevko})
      prefix = ""
      h = i + 1
      table.insert(parents, parent)
      parent = jevko
    elseif c == closer then
      parent.suffix = prefix .. str:sub(h, i - 1)
      prefix = ""
      h = i + 1
      if #parents < 1 then 
        error("Unexpected closer ("..closer..") at "..line..":"..column.."!")
      end
      parent = table.remove(parents)
    end

    if c == '\n' then
      line = line + 1
      column = 1
    else
      column = column + 1
    end
  end

  if is_escaped then error("Unexpected end after escaper (" .. escaper .. ")!") end
  if #parents > 0 then error("Unexpected end: missing "..#parents.." closer(s) ("..closer..")!") end

  parent.suffix = prefix .. str:sub(h, -1)

  return parent
end

local function escape(str)
  local ret = ""
  for i = 1, #str do
    local c = str:sub(i,i)
    if c == opener or c == closer or c == escaper then
      ret = ret..escaper
    end
    ret = ret..c
  end
  return ret
end

local function stringify_jevko(jevko)
  local subjevkos = jevko.subjevkos

  local ret = ""
  for _, v in ipairs(subjevkos) do
    local prefix = v.prefix
    local jevko = v.jevko
    ret = ret..escape(prefix).."["..stringify_jevko(jevko).."]"
  end
  return ret..escape(jevko.suffix)
end

jevko.decode = parse_jevko
jevko.from_string = parse_jevko
jevko.fromString = parse_jevko

jevko.encode = stringify_jevko
jevko.to_string = stringify_jevko
jevko.toString = stringify_jevko

jevko.escape = escape

return jevko