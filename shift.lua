-- Check and import quill
if not fs.exists("/DiaCubic/lib/quill.lua") then
    error("Library path not found.\n\nPlease clone DiaCubic repo in full:\nhttps://github.com/LDexter/DiaCubic.git", 0)
end
package.path = "/DiaCubic/?.lua;" .. package.path
local quill = require("lib/quill")

-- Get filename
local filename = ...
local pathStart = "./"

-- Read and parse file into table
local object = quill.scribeJSON(pathStart .. filename, "r")
print("Loaded " .. object.label)

-- Determine values
print("Shift direction (N, S, E, W / U, D):")
local dir = string.upper(read())
print("Shift distance (<16):")
local dist = read()

-- Determine indices for direction
local idx1
local idx2
if dir == "E" or dir == "W" then idx1 = 1 end
if dir == "U" or dir == "D" then idx1 = 2 end
if dir == "N" or dir == "S" then idx1 = 3 end
idx2 = idx1 + 3

-- Determine move distance
local move = dist
if dir == "N" or dir == "W" or dir == "D" then move = -dist end

-- Test before states
-- local idxTest = 2
-- print("Before E+W: " .. object.shapesOff[1].bounds[1])
-- print("Before U+D: " .. object.shapesOff[1].bounds[2])
-- print("Before N+S: " .. object.shapesOff[1].bounds[3])

-- Shift object
local shifted = object
if object.shapesOff[1] then
    for key, _ in pairs(shifted.shapesOff) do
        shifted.shapesOff[key].bounds[idx1] = shifted.shapesOff[key].bounds[idx1] + move
        shifted.shapesOff[key].bounds[idx2] = shifted.shapesOff[key].bounds[idx2] + move
    end
end
if object.shapesOn[1] then
    for key, _ in pairs(shifted.shapesOff) do
        shifted.shapesOn[key].bounds[idx1] = shifted.shapesOn[key].bounds[idx1] + move
        shifted.shapesOn[key].bounds[idx2] = shifted.shapesOn[key].bounds[idx2] + move
    end
end

-- Test after states
-- print("After E+W: " .. shifted.shapesOff[idxTest].bounds[1])
-- print("After U+D: " .. shifted.shapesOff[idxTest].bounds[2])
-- print("After N+S: " .. shifted.shapesOff[idxTest].bounds[3])

-- Write to file
quill.scribeJSON(pathStart .. filename, "w", shifted)