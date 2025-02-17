
--[[
ControlSys:

Handles camera transformations and player motion.

Also handles `pushing` and `pulling` by player,
and HealthBars etc.

TODO: add joystick support, make more robust

]]

local ControlSys = Cyan.System("control")

local Camera = require("src.misc.unique.camera")
local Partition = require 'src.misc.partition'
local TargetPartitions = require("src.misc.unique.partition_targets")


local max, min = math.max, math.min

local ROT_AMPLITUDE = 0.03
local ROT_FREQ = 0.07

local cur_sin_amount = 0
local cam_rot = 0


-- camera position gets locked when all players are killed
local lock_cam_x, lock_cam_y



local dist = Tools.dist
local ccall = Cyan.call
local dot = math.dot



    -- THIS CALLBACK IS FOR DEBUG PURPOSES ONLY !!!!!!!!!!!
function ControlSys:wheelmoved(dx, dy)
    Camera.scale = Camera.scale + (dy/30)
end



function ControlSys:added(e)
    -- just some sanity checks
    e.control.canPush = true
    e.control.canPull = true
end



-- We have to keep a boolean var to check if purge was invoked.
-- (signalling a lose condition during a purge would be terrrrible)
local duringPurge = false


function ControlSys:removed(e)
    if not duringPurge then
        if #self.group == 1 then
            -- then this is the last player in game.
            -- lock the camera, emit the lose callback; worldGen will handle it
            -- from here
            lock_cam_x = e.pos.x
            lock_cam_y = e.pos.y
            ccall("lose")
        end
    end
end




function ControlSys:finalizeWorld()
    -- Play tp down animation
    if #self.group >= 1 then
        ccall("animate", "tp_down", 0,-24,0, 0.6/10, 1, nil, self.group[1], true)
    end
end





local function findEntToPush(ent)
    --[[
        returns the closest ent that is able to be pushed by `ent`.
    ]]
    local min_dist

    if ent.size then
        min_dist = ent.size * 10
    else
        min_dist = 50
    end

    local best_ent = nil
    local epos = ent.pos
    local vx, vy = ent.vel.x, ent.vel.y

    for candidate in Partition:longiter(ent) do
        -- if its not moving, it wont be pushed
        if candidate.vel then
            local ppos = candidate.pos
            local dx, dy

            dx = ppos.x - epos.x
            dy = ppos.y - epos.y
            
            if candidate.pushable then
                local distance = dist(dx, dy)
                if distance < min_dist then
                    -- Is a valid candidate ::
                    if dot(dx, dy, vx,vy) > 0 then
                        best_ent = candidate
                        min_dist = distance
                    end
                end
            end
        end
    end

    return best_ent
end






function ControlSys:update(dt)
    duringPurge = false -- obviously if a frame has passed, it will no longer
        -- be during a purge callback.

    Camera:update(dt)

    for _,ent in ipairs(self.group) do
        local c = ent.control
        local speed = ent.speed.speed or 4

        local dx = 0
        local dy = 0

        if c.move_up then
            dy = -speed
        end
        if c.move_down then
            dy = dy + speed
        end
        if c.move_left then
            dx = -speed
        end
        if c.move_right then
            dx = speed
        end
        ccall("addVel", ent, dx, dy)

        if c.zoomIn then
            Camera.scale = min(Camera.scale * (1+dt), 3)
        end
        if c.zoomOut then
            Camera.scale = max(Camera.scale * (1-dt), 1.5)
        end
    end
end




local r = love.math.random 

local function afterPush(player)
    if Cyan.exists(player) then
        player.control.canPush = true
    end
end

local function pushFeedback(player)
    if Cyan.exists(player)then
        ccall("sound", "reload", 0.2)
        ccall("emit", "shell", player.pos.x, player.pos.y, 1, r(2,3))
    end
end



local function push(ent)
    assert(ent.control,"??????????")

    local shouldStopPush = false

    for e in (TargetPartitions.interact):iter(ent.pos.x, ent.pos.y) do
        if e ~= ent then
        -- ents cannot interact with themself
            if e.onInteract and Tools.edist(ent, e) < e.size then
                shouldStopPush = e:onInteract(ent, "push") or shouldStopPush
            end
        end
    end

    if shouldStopPush then return end

    if ent.control.canPush then
        local x = ent.pos.x
        local y = ent.pos.y
        local z = ent.pos.z

        -- boom will be biased towards enemies with 1.2 radians
        ccall("boom", x, y, ent.strength, 100, 0,0, "enemy", 1.2)
        ccall("animate", "push", x,y+25,z, 0.03) 
        ccall("shockwave", x, y, 4, 130, 7, 0.3)
        ccall("sound", "boom")
        
        -- Camera:shake(8, 1, 60) -- this doesnt work, RIP

        ent.control.canPush = false
        ccall("await", pushFeedback, CONSTANTS.PUSH_COOLDOWN/4, ent)
        ccall("await", afterPush, CONSTANTS.PUSH_COOLDOWN, ent)
    else
        --TODO ::: add feedback here!
        -- the player just tried to push on cooldown
    end
end









local function afterPull(player)
    if Cyan.exists(player) then
        player.control.canPull = true
    end
end



local function pull(ent)
    assert(ent.control, "?????")

    if ent.control.canPull then
        local x,y = ent.pos.x, ent.pos.y

        local shouldStopPull = false

        for e in (TargetPartitions.interact):iter(x, y) do
            if e ~= ent then
                -- ents cannot interact with themself
                if e.onInteract and Tools.edist(ent, e) < e.size then
                    shouldStopPull = e:onInteract(ent, "pull") or shouldStopPull
                end
            end
        end

        if not shouldStopPull then
            ent.control.canPull = false
            ccall("sound", "moob", 0.5, 1, 0, 0.2)
            ccall("shockwave", x, y, 130, 4, 7, 0.3)
            ccall("moob", x, y, ent.strength/2, 300)
            ccall("await", afterPull, CONSTANTS.PULL_COOLDOWN, ent)
        end
    else
        --TODO ::: add feedback here!
        -- the player just tried to pull on cooldown
    end
end





function ControlSys:keypressed(_, key)
    if CONSTANTS.paused then
        return
    end
    for _, ent in ipairs(self.group) do
        local c = ent.control
        if c[key] == 'pull' then
            pull(ent)
        end
    end
end



function ControlSys:keytap(key)
    if CONSTANTS.paused then
        return 
    end
    for _, ent in ipairs(self.group)do
        local c = ent.control
        if c[key] == 'push' then
            push(ent)
        end
    end
end


function ControlSys:mousepressed(_,_,butto)
    if CONSTANTS.paused then
        return
    end
    for _, ent in ipairs(self.group) do
        if butto == 1 then
            push(ent)
        elseif butto == 2 then
            pull(ent)
        end
    end
end



function ControlSys:keydown(key)
    if CONSTANTS.paused then
        return 
    end
    for _, ent in ipairs(self.group) do
        local control = ent.control

        local purpose = control[key]

        if purpose then
            control[purpose] = true
        end
    end
end




local function givePushingFeedback(player, push_ent)
    ccall("sound", "unlock",0.5,2)
    ccall("animate", "hit", 0,0,30, 0.07, nil, nil, push_ent)
end

function ControlSys:keyheld(key, time)
    if CONSTANTS.paused then
        return
    end
    for _, ent in ipairs(self.group) do
        local control=ent.control
        local purpose = control[key]
        if purpose == "push" then
            if not ent.pushing then
                local push_ent = findEntToPush(ent)
                if push_ent then
                    givePushingFeedback(ent,push_ent)
                    ent:add("pushing", push_ent)
                end
            end
        elseif purpose == "pull" then
            if ent.control.canPull then
                pull(ent)
            end
        end
    end
end



function ControlSys:keyup(key)
    for _, ent in ipairs(self.group) do
        local control = ent.control

        local purpose = control[key]

        if purpose then
            control[purpose] = false
            if purpose == "push" then
                if ent:has("pushing") then
                    ent:remove("pushing")
                end
            end
        end
    end
end



local playables = require("src.misc.playables.initialize")
local savedata  = require("src.misc.unique.savedata")


function ControlSys:switchPlayer(type)
    --[[
        changes all players to type `X`
    ]]
    if not playables[type] then
        error("unknown playable: "..tostring(type))
    end
    
    local player = self.group[1]

    playables[player.playerType]:destruct(player)
    playables[type]:construct(player)

    savedata.playerType = type
end








function ControlSys:purge()
    duringPurge = true
    Cyan.clear( ) -- Deletes all entities.
    -- big operation

    -- TODO:
    -- WHY IS THIS HERE??
    -- put this somewhere else
end


function ControlSys:newWorld()
    lock_cam_x = nil
    lock_cam_y = nil
end







local function getAveragePosition(group) -- => (x, y)
    if lock_cam_x then
        assert(lock_cam_y,"?")
        return lock_cam_x, lock_cam_y
    end

    if #group > 0 then
        local x = 0
        local y = 0
        local follow_count = 0
        
        for _, ent in ipairs(group) do
            follow_count = follow_count + 1
            x = x + ent.pos.x
            y = y + ent.pos.y
        end
        
        x = x / follow_count
        y = y / follow_count
        return x,y
    else -- not enough entities to get an average position
        -- (this should never happen btw)
        return 0,0
    end
end




function ControlSys:transform()    
    Camera:attach()

    local x,y = getAveragePosition(self.group)
    
    Camera:follow(x,y)

    Camera:draw()
end


function ControlSys:untransform()
    Camera:detach()
end



