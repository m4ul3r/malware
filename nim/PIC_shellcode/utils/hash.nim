import winim

proc hashStringDjb2A*(s: cstring): uint32 {.inline.} =
  var hash: uint32 = 0xff
  for i in s: hash = ((hash shl 5) + hash) + cast[uint32](i)
  return hash

proc hashStringDjb2W*(s: wstring): uint32  =
  var hash: uint32 = 0xff
  for i in s: hash = ((hash shl 5) + hash) + cast[uint32](i)
  return hash