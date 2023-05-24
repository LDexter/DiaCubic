-- Check and import quill
if not fs.exists("/DiaCubic/lib/quill.lua") then
    error("Library path not found.\n\nPlease clone DiaCubic repo in full:\nhttps://github.com/LDexter/DiaCubic.git", 0)
end
package.path = "/DiaCubic/?.lua;" .. package.path
local quill = require("lib/quill")

-- Pull filenames from user input
-- local fileFirst, fileSecond = ...
-- Get files
print("First file:")
local fileFirst = read(nil, nil, function(str)
    return fs.complete(str, "", {
        include_files = true,
        include_dirs = false,
        include_hidden = false,
    })
end)
print("Second file:")
local fileSecond = read(nil, nil, function(str)
    return fs.complete(str, "", {
        include_files = true,
        include_dirs = false,
        include_hidden = false,
    })
end)
local pathStart = "./"

-- Read and parse files into tables
local jsonFirst = quill.scribe(pathStart .. fileFirst, "r")
-- local tblFirst = textutils.unserialiseJSON(jsonFirst)
local jsonSecond = quill.scribe(pathStart .. fileSecond, "r")
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
quill.scribe(pathStart..fileFirst, "w", jsonFirst)

-- Print results
print("Bound "..fileSecond.." to "..fileFirst.." as the second frame.")