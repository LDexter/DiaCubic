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


-- Move entire model to 0,?,0
local function shiftCorner(shapes)
    for key, _ in pairs(shapes) do
        shapes[key].bounds[1] = shapes[key].bounds[1] + 8
        shapes[key].bounds[4] = shapes[key].bounds[4] + 8
        shapes[key].bounds[3] = shapes[key].bounds[3] + 8
        shapes[key].bounds[6] = shapes[key].bounds[6] + 8
    end
    return shapes
end


-- Read and parse files into tables
local tblMain = quill.scribeJSON(file, "r")

-- Create tables for shapes starting at 0,?,0
local tblShapesOff = {}
local tblShapesOn = {}
if tblMain.shapesOff then
    tblShapesOff = shiftCorner(tblMain.shapesOff)
end
if tblMain.shapesOn then
    tblShapesOn = shiftCorner(tblMain.shapesOn)
end

-- Set starting states for more splits
local isMore = {}
isMore.x = true
isMore.y = true
isMore.z = true


-- Check if vertex is within bounds
local function checkVertex(vert)
    if vert < 0 then
        vert = 0
    elseif vert > 16 then
        vert = 16
    end
    return vert
end
-- Check if both vertices are within bounds
local function checkVertices(vert1, vert2)
    vert1 = checkVertex(vert1)
    vert2 = checkVertex(vert2)
    if vert1 == 0 and vert2 == 0 or vert1 == 16 and vert2 == 16 then
        return nil, nil
    end
    return vert1, vert2
end


local function shiftBounds(bounds, dist, axis)
    -- Find axis indecies
    local idx1
    local idx2
    if axis == "x" then
        idx1 = 1
    elseif axis == "y" then
        idx1 = 2
    elseif axis == "z" then
        idx1 = 3
    end
    idx2 = idx1 + 3

    -- Shift boundary locations
    bounds[idx1] = bounds[idx1] - dist
    bounds[idx2] = bounds[idx2] - dist

    -- Check for out-of-bounds
    bounds[idx1], bounds[idx2] = checkVertices(bounds[idx1], bounds[idx2])

    return bounds
end


-- Shift bounds within maximum distance for all axies
local function shiftShapes(shapes, pos)
    -- Iterate through shapes
    for idxShift, shape in pairs(shapes) do
        if shape.bounds then
            -- Shift all bounds per shape
            shapes[idxShift].bounds = shiftBounds(shapes[idxShift].bounds, pos.x, "x")
            shapes[idxShift].bounds = shiftBounds(shapes[idxShift].bounds, pos.y, "y")
            shapes[idxShift].bounds = shiftBounds(shapes[idxShift].bounds, pos.z, "z")
        end
        -- Remove shapes that are out of bounds
        if #shapes[idxShift].bounds < 6 then
            shapes[idxShift] = nil
        end
        -- for idxRemove, boundCheck in pairs(shapes[idxShift].bounds) do
        --     if not boundCheck then
        --         shapes[idxShift].bounds[idxRemove] = nil
        --     end
        -- end
    end
    return shapes
end


-- Check all bound values for more splits
local function checkMore(bounds, pos)
    local yCheck = pos.y + 16
    local zCheck = pos.z + 16
    local xCheck = pos.x + 16
    if bounds[1] > xCheck or bounds[4] > xCheck then
        isMore.x = true
    end
    if bounds[2] > yCheck or bounds[5] > yCheck then
        isMore.y = true
    end
    if bounds[3] > zCheck or bounds[6] > zCheck then
        isMore.z = true
    end
end


-- Move shapes from both states
local function shiftBoth(off, on, pos)
    -- Assume no more splits are needed
    isMore.x = false
    isMore.y = false
    isMore.z = false

    -- Exend loop if more splits are needed
    for _, value in pairs(off) do
        if value.bounds then
            checkMore(value.bounds, pos)
        end
    end
    for _, value in pairs(on) do
        if value.bounds then
            checkMore(value.bounds, pos)
        end
    end

    -- Shift shapes
    off = shiftShapes(off, pos)
    on = shiftShapes(on, pos)

    -- Create new table
    local tblNew = tblMain
    tblNew.shapesOff = off
    tblNew.shapesOn = on

    -- Write new file
    if tblNew.shapesOff[1] and tblNew.shapesOn[1] then
        quill.scribeJSON(pathStart .. "splits/" .. "split-x" .. pos.x .. "-y" .. pos.y .. "-z" .. pos.z, "w", tblNew)
    end
    return off, on
end


-- Split all shapes
local function splitShapes()
    -- Set starting position
    local pos = {}
    pos.x = 0
    pos.y = 0
    pos.z = 0

    -- Loop through all axies
    while isMore.x and isMore.y and isMore.z do
        while isMore.y do
            while isMore.z do
                while isMore.x do
                    shiftBoth(tblShapesOff, tblShapesOn, pos)
                    pos.x = pos.x + 16 -- Move LEFT
                end
                pos.z = pos.z + 16 -- Move FORWARD
            end
            pos.y = pos.y + 16     -- Move UP
        end
    end
end


-- Run program
splitShapes()