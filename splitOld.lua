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
local function stateDiff(state, axis)
    local dists = {}
    local shapes = {}

    -- Iterate through shapes
    for key, value in pairs(state) do
        -- Find axis indecies
        local idxStart
        local idxEnd
        if axis == "x" then
            idxStart = 1
            idxEnd = 4
        elseif axis == "y" then
            idxStart = 2
            idxEnd = 5
        elseif axis == "z" then
            idxStart = 3
            idxEnd = 6
        end

        -- Get the axis-specific bounds of the shape
        local boundStart = value.bounds[idxStart]
        local boundEnd = value.bounds[idxEnd]
        local diff

        -- Find the difference between the bounds
        if boundStart > boundEnd then
            diff = boundStart - boundEnd
        else
            diff = boundEnd - boundStart
        end

        -- Create a named index for each distance
        dists[key] = diff
        -- Create a named index for each shape
        shapes[key] = value
    end

    return dists, shapes
end

-- Read and parse files into tables
local tblMain = quill.scribeJSON(file, "r")

-- Create tables for shapes
local tblShapesOff = tblMain.shapesOff
local tblShapesOn = tblMain.shapesOn

-- Find the X-axis distances for both states
local xDistsOff, xShapesOff = stateDiff(tblShapesOff, "x")
local yDistsOff, yShapesOff = stateDiff(tblShapesOff, "y")
local zDistsOff, zShapesOff = stateDiff(tblShapesOff, "z")
local xDistsOn, xShapesOn = stateDiff(tblShapesOn, "x")
local yDistsOn, yShapesOn = stateDiff(tblShapesOn, "y")
local zDistsOn, zShapesOn = stateDiff(tblShapesOn, "z")

-- Find split count
local function countSplit(dists)
    local splits = {}
    for key, distance in pairs(dists) do
        local extra = distance - 16
        local split = 0
        if extra > 0 then
            split = math.ceil(extra / 16)
            print("Split " .. distance .. " " .. split .. " times")
        end
        splits[key] = split
    end
    return splits
end

local splitsOff = {}
local splitsOn = {}

splitsOff.x = countSplit(xDistsOff)
splitsOff.y = countSplit(yDistsOff)
splitsOff.z = countSplit(zDistsOff)
splitsOn.x = countSplit(xDistsOn)
splitsOn.y = countSplit(yDistsOn)
splitsOn.z = countSplit(zDistsOn)

print("OFF:")
for _, value in pairs(splitsOff.x) do
    print(value)
end
print("ON:")
for _, value in pairs(splitsOn.x) do
    print(value)
end


-- Shift bounds of shapes
local function shiftBounds(shapes, idx1, idx2, dist)
    for key, value in pairs(shapes) do
        local vert1 = value.bounds[idx1] - dist
        local vert2 = value.bounds[idx2] - dist
        
        -- Delete if whole object out of bounds
        if vert1 > 16 and vert2 > 16 then
            shapes[key] = nil
        else
            -- Check if first bounds are within 16
            if vert1 < 16 then
                shapes[key].bounds[idx1] = vert1
            else
                shapes[key].bounds[idx1] = 16
            end
            
            -- Check if second bounds are within 16
            if vert2 < 16 then
                shapes[key].bounds[idx2] = vert2
            else
                shapes[key].bounds[idx2] = 16
            end
        end
    end

    return shapes
end


-- Store new shapes
local shapesFinal = {}


-- Split shape into new objects along final y-axis [2] and [5] (UP)
local function splitY(shapes, pos, splits)
    -- Shift bounds
    local shapesNew = shiftBounds(shapes, 2, 5, pos.y)

    -- Create new shapes
    local block = {}
    block.x = pos.x
    block.y = pos.y
    block.z = pos.z
    local pathNew = pathStart .. "splits/" .. "split-x" .. block.x .. "-y" .. block.y .. "-z" .. block.z

    shapesFinal[pathNew] = shapesNew

    sleep()
end


-- Split along z-axis [3] and [6] (NORTH/SOUTH)
local function splitZ(shapes, pos, splits)
    -- Shift bounds
    local shapesNew = shiftBounds(shapes, 3, 6, pos.z)

    -- Split y-axis
    for i = 1, math.max(table.unpack(splits.y)), 1 do
        splitY(shapesNew, pos, splits)
        pos.y = pos.y + 16
    end
end


-- Split along x-axis [1] and [4] (EAST/WEST)
local function splitX(shapes, pos, splits)
    -- Shift bounds
    local shapesNew = shiftBounds(shapes, 1, 4, pos.x)

    -- Split z-axis
    for i = 1, math.max(table.unpack(splits.z)), 1 do
        splitZ(shapesNew, pos, splits)
        pos.z = pos.z + 16
    end
end


-- Split along all axes
local function splitAll(shapes, splits)
    local shapesNew = shapes
    local pos = {}
    pos.x = 0
    pos.y = 0
    pos.z = 0
    for i = 1, math.max(table.unpack(splits.x)), 1 do
        splitX(shapesNew, pos, splits)
        pos.x = pos.x + 16
    end

    -- Write new shapes to file
end


-- Split shapes
local statesFinal = {}
splitAll(xShapesOff, splitsOff)
statesFinal.shapesOff = shapesFinal
splitAll(xShapesOn, splitsOn)
statesFinal.shapesOn = shapesFinal


local printFinal
for key, value in pairs(statesFinal.shapesOff) do
    printFinal = value
    print("KEY: "..key)
end