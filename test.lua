local jevko = loadfile("./jevko.lua")()



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

local actual = jevko.encode(parsed.subjevkos[5].jevko)
assert(actual == expected, actual)