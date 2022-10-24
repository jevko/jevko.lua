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

local function escape_prefix(prefix)
  if prefix == "" then
    return ""
  else
    return escape(prefix).." "
  end
end

local function recur(jevko, indent, prevIndent)
  local subjevkos = jevko.subjevkos
  local ret = ""
  
  if #subjevkos > 0 then
    ret = ret.."\n"
    for _, v in ipairs(subjevkos) do
      local prefix = v.prefix
      local jevko = v.jevko
      ret = ret..indent..escape_prefix(prefix).."["..recur(jevko, indent.."  ", indent).."]\n"
    end
    ret = ret..prevIndent
  end

  return ret .. escape(jevko.suffix)
end

local function stringify_jevko_pretty(jevko, indent)
  local subjevkos = jevko.subjevkos
  local suffix = jevko.suffix

  local ret = ""
  for _, v in ipairs(subjevkos) do
    local prefix = v.prefix
    local jevko = v.jevko
    ret = ret..escape_prefix(prefix).."["..recur(jevko, "  ", "").."]\n"
  end
  return ret..escape(suffix)
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
jevko.encode = stringify_jevko
jevko.encode_pretty = stringify_jevko_pretty

return jevko