-- Check and import quill
if not fs.exists("/DiaCubic/lib/quill.lua") then
    error("Library path not found.\n\nPlease clone DiaCubic repo in full:\nhttps://github.com/LDexter/DiaCubic.git", 0)
end
package.path = "/DiaCubic/?.lua;" .. package.path
local quill = require("lib/quill")

-- Pull filenames from user input
-- local file = ...
-- Get file
print("File:")
local file = read(nil, nil, function(str)
    return fs.complete(str, "./DiaCubic/", {
        include_files = true,
        include_dirs = false,
        include_hidden = false,
    })
end)
local pathStart = ""

-- Read and parse files into tables
local jsonMain = quill.scribe(pathStart .. file, "r")
local tblMain = textutils.unserialiseJSON(jsonMain)

-- Create tables for shapes
local tblShapesOff = tblMain.shapesOff
local tblShapesOn = tblMain.shapesOn
local xDistsOff = {}
local xShapesOff = {}

-- Create directory for split files
fs.makeDir(pathStart .. "splits/")

-- Find the X-axis distance of each shape in OFF state
for key, value in pairs(tblMain.shapesOff) do
    -- Get the X-axis bounds of the shape
    local xStart = value.bounds[1]
    local xEnd = value.bounds[4]
    local xDiff

    -- Find the difference between the bounds
    if xStart > xEnd then
        xDiff = xStart - xEnd
    else
        xDiff = xEnd - xStart
    end
    xDistsOff[key] = xDiff

    -- Create a named index for each shape
    xShapesOff[key] = value
end

for key, value in pairs(xDistsOff) do
    print(value)
end