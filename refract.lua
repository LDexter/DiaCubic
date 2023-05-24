-- Check and import quill
if not fs.exists("/DiaCubic/lib/quill.lua") then
    error("Library path not found.\n\nPlease clone DiaCubic repo in full:\nhttps://github.com/LDexter/DiaCubic.git", 0)
end
package.path = "/DiaCubic/?.lua;" .. package.path
local quill = require("lib/quill")

-- Pull filenames from user input
local textureName, replaceName = ...
local texture = "minecraft:block/"..textureName
local replace = "minecraft:block/" .. replaceName
-- Get file
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
local jsonTarget = quill.scribe(pathStart .. file, "r")
local tblTarget = textutils.unserialiseJSON(jsonTarget)

-- Replace all occurrences of provided texture with new texture
jsonTarget = quill.replace(jsonTarget, texture, replace)
quill.scribe(pathStart..file, "w", jsonTarget)

print("Replaced all traces of "..textureName.." with "..replaceName)