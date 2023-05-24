-- Check and import quill
if not fs.exists("/DiaCubic/lib/quill.lua") then
    error("Library path not found.\n\nPlease clone DiaCubic repo in full:\nhttps://github.com/LDexter/DiaCubic.git", 0)
end
package.path = "/DiaCubic/?.lua;" .. package.path
local quill = require("lib/quill")

-- Pull filenames from user input
-- local file, fileSecond = ...
-- Get files
print("File:")
local file = read(nil, nil, function(str)
    return fs.complete(str, "", {
        include_files = true,
        include_dirs = false,
        include_hidden = false,
    })
end)
local pathStart = "./"

-- Read and parse file into table
local object = quill.scribeJSON(file, "r")
print("Loaded " .. object.label)

-- Remove second frame and overwrite file
object.shapesOn = {}
quill.scribeJSON(file, "w", object)
print("Unbound second frame (ON state) from " .. file .. ".")
