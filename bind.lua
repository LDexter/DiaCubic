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

-- Get options
print("Choose frame 1/2 (state off/on):")
local frame = read()
print("Replace chosen frame? (y/n):")
local replace = read()

-- Translate to boolean
local isReplace = false
if replace == "y" then
    isReplace = true
end

-- Read and parse files into tables
-- Read and parse file into table
local objFinal = quill.scribeJSON(fileFirst, "r")
local objToCopy = quill.scribeJSON(fileSecond, "r")
print("Loaded " .. objFinal.label.." to receive "..objToCopy.label)

local frameText = ""
if frame == 1 then
    if isReplace or not objFinal.shapesOff[1] then
        objFinal.shapesOff = objToCopy.shapesOff
    else
        for _, value in pairs(objToCopy.shapesOff) do
            table.insert(objFinal.shapesOff, value)
        end
    end
    frameText = "first"

else
    if isReplace or not objFinal.shapesOn[1] then
        objFinal.shapesOn = objToCopy.shapesOff
    else
        for _, value in pairs(objToCopy.shapesOff) do
            table.insert(objFinal.shapesOn, value)
        end
    end
    frameText = "second"
end
-- Write copy object shapes over final
-- Parse back and overwrite


-- -- Serialise first frame of second table
-- local jsonFrame = textutils.serialiseJSON(tblSecond.shapesOff)
-- -- Write into second frame of first table
-- jsonFirst = quill.replace(jsonFirst, "\"shapesOn\": []", "\"shapesOn\": " .. jsonFrame)

-- Overwrite file
quill.scribeJSON(fileFirst, "w", objFinal)

-- Print results
print("Bound "..fileSecond.." to "..fileFirst.." as the "..frameText.." frame.")