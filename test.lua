local jevko = require "jevko"

function test(name, fn)
  xpcall(function()
    io.write("Running test ["..name.."]... ")
    fn()
    print("passed!")
  end,
  function(err)
    print("failed!\nError: "..err)
  end)
end

local parsed = jevko.decode([[
first name [John]
last name [Smith]
is alive [true]
age [27]
address [
  street address [21 2nd Street]
  city [New York]
  state [NY]
  postal code [10021-3100]
]
phone numbers [
  [
    type [home]
    number [212 555-1234]
  ]
  [
    type [office]
    number [646 555-4567]
  ]
]
children []
spouse []
]])

local expected = [[

  street address [21 2nd Street]
  city [New York]
  state [NY]
  postal code [10021-3100]
]]

test('escapes', function() 
  local t = jevko.from_string("  ````aaa`[bbb`]`]ccc``  ")
  assert(t.suffix == "  ``aaa[bbb]]ccc`  ", t.suffix)
  assert(jevko.from_string("  ````aaa`[bbb`]`]ccc``  []").subjevkos[1].prefix == "  ``aaa[bbb]]ccc`  ")
end)

test('roundtrip', function()
  local actual = jevko.encode(parsed.subjevkos[5].jevko)
  assert(actual == expected, actual)
end)
