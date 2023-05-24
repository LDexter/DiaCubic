-- Check and import quill
if not fs.exists("/DiaCubic/lib/quill.lua") then
    error("Library path not found.\n\nPlease clone DiaCubic repo in full:\nhttps://github.com/LDexter/DiaCubic.git", 0)
end
package.path = "/DiaCubic/?.lua;" .. package.path
local quill = require("lib/quill")

-- Set debug state
local doDebugStuff = false
local idxTest1 = 1
local idxTest2 = 2

-- Get file
print("File:")
local file = read(nil, nil, function(str)
    return fs.complete(str, "", {
        include_files = true,
        include_dirs = false,
        include_hidden = false,
    })
end)

-- Read and parse file into table
local object = quill.scribeJSON(file, "r")
print("Loaded " .. object.label)

-- Determine values
print("Shift direction (N, S, E, W / U, D):")
local dir = string.upper(read())
print("Shift distance (<16):")
local dist = read()

-- Determine indices for direction
local idx1
local idx2
if dir == "E" or dir == "W" then idx1 = 1
elseif dir == "U" or dir == "D" then idx1 = 2
elseif dir == "N" or dir == "S" then idx1 = 3
else error("Invalid direction") end
idx2 = idx1 + 3
print("")

-- Determine movement bounaries
local maxPos = 1
local minPos = 15
if object.shapesOff[1] then
    for key, _ in pairs(object.shapesOff) do
        local vertex1 = object.shapesOff[key].bounds[idx1]
        local vertex2 = object.shapesOff[key].bounds[idx2]
        if doDebugStuff then print("minPos: "..minPos.." maxPos: "..maxPos) end
        minPos = math.min(table.unpack({minPos, vertex1, vertex2}))
        maxPos = math.max(table.unpack({maxPos, vertex1, vertex2}))
    end
end
if object.shapesOn[1] then
    for key, _ in pairs(object.shapesOff) do
        local vertex1 = object.shapesOn[key].bounds[idx1]
        local vertex2 = object.shapesOn[key].bounds[idx2]
        if doDebugStuff then print("minPos: "..minPos.." maxPos: "..maxPos) end
        minPos = math.min(table.unpack({ minPos, vertex1, vertex2 }))
        maxPos = math.max(table.unpack({ maxPos, vertex1, vertex2 }))
    end
end

-- Calculate differences
local diffMinus = minPos
local diffPlus = 16 - maxPos

if doDebugStuff then
    print("Diff-: " .. diffMinus)
    print("Diff+: " .. diffPlus)
end

-- Determine move distance
dist = tonumber(dist)
local move
if dir == "N" or dir == "W" or dir == "D" then
    if dist < diffMinus then
        move = -dist
    else
        move = -diffMinus
    end
else
    if dist < diffPlus then
        move = dist
    else
        move = diffPlus
    end
end

-- Debug before states
if doDebugStuff then
    print("\nFirst before E/W: " .. object.shapesOff[idxTest1].bounds[1] .. " Sec before E/W: " .. object.shapesOff[idxTest2].bounds[1])
    print("First before U/D: " .. object.shapesOff[idxTest1].bounds[2] .. " Sec before U/D: " .. object.shapesOff[idxTest2].bounds[2])
    print("First before N/S: " .. object.shapesOff[idxTest1].bounds[3] .. " Sec before N/S: " .. object.shapesOff[idxTest2].bounds[3] .. "\n")
    print("First before E/W: " .. object.shapesOff[idxTest1].bounds[4] .. " Sec before E/W: " .. object.shapesOff[idxTest2].bounds[4])
    print("First before U/D: " .. object.shapesOff[idxTest1].bounds[5] .. " Sec before U/D: " .. object.shapesOff[idxTest2].bounds[5])
    print("First before N/S: " .. object.shapesOff[idxTest1].bounds[6] .. " Sec before N/S: " .. object.shapesOff[idxTest2].bounds[6] .. "\n")
end

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

-- Display details of movement
print("Shifted " .. object.label .. " " .. move .. ", " .. dir)

-- Debug after states
if doDebugStuff then
    print("\nFirst after E/W: " .. shifted.shapesOff[idxTest1].bounds[1] .. " Sec after E/W: " .. shifted.shapesOff[idxTest2].bounds[1])
    print("First after U/D: " .. shifted.shapesOff[idxTest1].bounds[2] .. " Sec after U/D: " .. shifted.shapesOff[idxTest2].bounds[2])
    print("First after N/S: " .. shifted.shapesOff[idxTest1].bounds[3] .. " Sec after N/S: " .. shifted.shapesOff[idxTest2].bounds[3] .. "\n")
    print("First after E/W: " .. shifted.shapesOff[idxTest1].bounds[4] .. " Sec after E/W: " .. shifted.shapesOff[idxTest2].bounds[4])
    print("First after U/D: " .. shifted.shapesOff[idxTest1].bounds[5] .. " Sec after U/D: " .. shifted.shapesOff[idxTest2].bounds[5])
    print("First after N/S: " .. shifted.shapesOff[idxTest1].bounds[6] .. " Sec after N/S: " .. shifted.shapesOff[idxTest2].bounds[6])
end

-- Overwrite file
quill.scribeJSON(file, "w", shifted)