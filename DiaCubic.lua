-- Check quill
if not fs.exists("/DiaCubic/lib/quill.lua") then
    error("Library path not found.\n\nPlease clone DiaCubic repo in full:\nhttps://github.com/LDexter/DiaCubic.git", 0)
end
-- Import Pine3D and quill
package.path = "/DiaCubic/?.lua;" .. package.path
local Pine3D = require("lib/Pine3D")
local quill = require("lib/quill")

-- Camera movement
local speed = 2
local turnSpeed = 180

-- New frame at fullscreen and camera setup
local ThreeDFrame = Pine3D.newFrame()
local camera = {
    x = 0,
    y = 0,
    z = 0,
    rotX = 0,
    rotY = 0,
    rotZ = 0,
}
ThreeDFrame:setCamera(camera)

-- Define objects
local objects = {
    ThreeDFrame:newObject("DiaCubic/lib/models/box", 0, 0, 0)
}

-- Handle all keypresses in table
local keysDown = {}
local function keyInput()
    while true do
        -- Wait for user input
        local event, key, x, y = os.pullEvent()
        
        if event == "key" then              -- Key press register
            keysDown[key] = true
        elseif event == "key_up" then       -- Key release reset
            keysDown[key] = nil
        end
        -- Check if event was click
        if event == "mouse_click" then
            
        end
    end
end

-- update the camera position based on the keys being pressed
-- and the time passed since the last step
local function handleCameraMovement(dt)
    local dx, dy, dz = 0, 0, 0 -- will represent the movement per second

    -- handle arrow keys for camera rotation
    if keysDown[keys.left] then
        camera.rotY = (camera.rotY - turnSpeed * dt) % 360
    end
    if keysDown[keys.right] then
        camera.rotY = (camera.rotY + turnSpeed * dt) % 360
    end
    if keysDown[keys.down] then
        camera.rotZ = math.max(-80, camera.rotZ - turnSpeed * dt)
    end
    if keysDown[keys.up] then
        camera.rotZ = math.min(80, camera.rotZ + turnSpeed * dt)
    end

    -- handle wasd keys for camera movement
    if keysDown[keys.w] then
        dx = speed * math.cos(math.rad(camera.rotY)) + dx
        dz = speed * math.sin(math.rad(camera.rotY)) + dz
    end
    if keysDown[keys.s] then
        dx = -speed * math.cos(math.rad(camera.rotY)) + dx
        dz = -speed * math.sin(math.rad(camera.rotY)) + dz
    end
    if keysDown[keys.a] then
        dx = speed * math.cos(math.rad(camera.rotY - 90)) + dx
        dz = speed * math.sin(math.rad(camera.rotY - 90)) + dz
    end
    if keysDown[keys.d] then
        dx = speed * math.cos(math.rad(camera.rotY + 90)) + dx
        dz = speed * math.sin(math.rad(camera.rotY + 90)) + dz
    end

    -- space and left shift key for moving the camera up and down
    if keysDown[keys.space] then
        dy = speed + dy
    end
    if keysDown[keys.leftShift] then
        dy = -speed + dy
    end

    -- update the camera position by adding the offset
    camera.x = camera.x + dx * dt
    camera.y = camera.y + dy * dt
    camera.z = camera.z + dz * dt

    ThreeDFrame:setCamera(camera)
end

-- handle game logic
local function handleGameLogic(dt)
    -- set y coordinate to move up and down based on time
    objects[1]:setPos(nil, math.sin(os.clock())*0.25, nil)

    -- set horizontal rotation depending on the time
    -- objects[1]:setRot(nil, os.clock(), nil)
end

-- handle the game logic and camera movement in steps
local function gameLoop()
    local lastTime = os.clock()

    while true do
        -- compute the time passed since last step
        local currentTime = os.clock()
        local dt = currentTime - lastTime
        lastTime = currentTime

        -- run all functions that need to be run
        handleGameLogic(dt)
        handleCameraMovement(dt)

        -- use a fake event to yield the coroutine
        os.queueEvent("gameLoop")
        os.pullEventRaw("gameLoop")
    end
end

-- render the objects
local function rendering()
    while true do
        -- load all objects onto the buffer and draw the buffer
        ThreeDFrame:drawObjects(objects)
        ThreeDFrame:drawBuffer()

        -- use a fake event to yield the coroutine
        os.queueEvent("rendering")
        os.pullEventRaw("rendering")
    end
end

-- start the functions to run in parallel
parallel.waitForAny(keyInput, gameLoop, rendering)