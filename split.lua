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
    return fs.complete(str, "", {
        include_files = true,
        include_dirs = false,
        include_hidden = false,
    })
end)
local pathStart = "./DiaCubic/"

-- Create directory for split files
fs.makeDir(pathStart .. "splits/")


-- Find the X-axis distance of each shape for a state
local function stateDiff(shapes)
    local xDists = {}
    local xShapes = {}
    for key, value in pairs(shapes) do
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
        xDists[key] = xDiff

        -- Create a named index for each shape
        xShapes[key] = value
    end
    return xDists, xShapes
end

-- Read and parse files into tables
local tblMain = quill.scribeJSON(file, "r")

-- Create tables for shapes
local tblShapesOff = tblMain.shapesOff
local tblShapesOn = tblMain.shapesOn

-- Find the X-axis distances for both states
local xDistsOff, xShapesOff = stateDiff(tblShapesOff)
local xDistsOn, xShapesOn = stateDiff(tblShapesOn)

print("OFF:")
for key, value in pairs(xDistsOff) do
    print(value)
end
print("ON:")
for key, value in pairs(xDistsOn) do
    print(value)
end