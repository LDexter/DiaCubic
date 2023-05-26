-- Check and import quill
if not fs.exists("/DiaCubic/lib/quill.lua") then
    error("Library path not found.\n\nPlease clone DiaCubic repo in full:\nhttps://github.com/LDexter/DiaCubic.git", 0)
end
package.path = "/DiaCubic/?.lua;" .. package.path
local quill = require("lib/quill")

-- Set debug state
local doDebugStuff = false

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

-- Move hexcodes to tint
if object.shapesOff[1] then
    for key, _ in pairs(object.shapesOff) do
        local material = object.shapesOff[key].texture
        local idxBlock = string.find(material, "block")
        local idxHash = string.find(material, "#")
        if idxHash then
            local block = string.sub(material, idxBlock + 6, idxHash - 1)
            local hex = string.upper(string.sub(material, idxHash + 1))
            print("Block: " .. block .. " Hexcode: " .. hex)
            object.shapesOff[key].tint = hex
            object.shapesOff[key].texture = string.sub(material, 1, idxHash - 1)
        end
    end
end
if object.shapesOn[1] then
    for key, _ in pairs(object.shapesOn) do
        local material = object.shapesOn[key].texture
        local idxBlock = string.find(material, "block")
        local idxHash = string.find(material, "#")
        if idxHash then
            local block = string.sub(material, idxBlock + 6, idxHash - 1)
            local hex = string.upper(string.sub(material, idxHash + 1))
            print("Block: " .. block .. " Hexcode: " .. hex)
            object.shapesOn[key].tint = hex
            object.shapesOn[key].texture = string.sub(material, 1, idxHash - 1)
        end
    end
end

-- Overwrite file
quill.scribeJSON(file, "w", object)