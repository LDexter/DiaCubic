-- Import quill
package.path = "/DiaCubic/?.lua;" .. package.path
local quill = require("lib/quill")

-- Pull filenames from user input
-- TODO: add autocomplete
local nameFirst, nameSecond = ...
local pathStart = "./"

-- Read and parse files into tables
local jsonFirst = quill.scribe(pathStart .. nameFirst, "r")
-- local tblFirst = textutils.unserialiseJSON(jsonFirst)
local jsonSecond = quill.scribe(pathStart .. nameSecond, "r")
local tblSecond = textutils.unserialiseJSON(jsonSecond)

--? Could not find solution to control ordering of JSON items after serialisation
-- Write second table shapes into first
-- tblFirst.shapesOn = tblSecond.shapesOff
-- Parse back and overwrite
-- jsonFirst = textutils.serialiseJSON(tblFirst)

-- Serialise first frame of second table
local jsonFrame = textutils.serialiseJSON(tblSecond.shapesOff)
-- Write into second frame of first table
jsonFirst = quill.replace(jsonFirst, "\"shapesOn\": []", "\"shapesOn\": " .. jsonFrame)

-- Overwrite first file as main
quill.scribe(pathStart..nameFirst, "w", jsonFirst)

-- Print results
print("Bound "..nameSecond.." to "..nameFirst.." as the second frame.")