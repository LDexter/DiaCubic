-- Import quill
package.path = "/DiaCubic/?.lua;" .. package.path
local quill = require("lib/quill")

-- Pull filenames from user input
-- TODO: add autocomplete
local nameTarget, textureName, replaceName = ...
local texture = "minecraft:block/"..textureName
local replace = "minecraft:block/"..replaceName
local pathStart = "./"

-- Read and parse file into table
local jsonTarget = quill.scribe(pathStart .. nameTarget, "r")
local tblTarget = textutils.unserialiseJSON(jsonTarget)

-- Replace all occurrences of provided texture with new texture
jsonTarget = quill.replace(jsonTarget, texture, replace)
quill.scribe(pathStart..nameTarget, "w", jsonTarget)

print("Replaced all traces of "..textureName.." with "..replaceName)