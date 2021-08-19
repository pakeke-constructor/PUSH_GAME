
local DrawSys = Cyan.System("pos", "draw")
--[[

Main drawing system.

Will emit draw calls based on position, and in correct order.


]]



local Tools = _G.Tools
local PATH = Tools.Path(...)
local Set = require ("libs.tools.sets")
local floor = math.floor
local Atlas = require("assets.atlas")
local font = require("src.misc.unique.font")

local push = require("libs.NM_push.push")

--[[push:setupScreen(
    love.graphics.getWidth()/3, 
    love.graphics.getHeight()/3,

    love.graphics.getWidth(),
    love.graphics.getHeight(), 
    {fullscreen = false, pixelperfect=false}
)]]





local Indexer_max_depth = 0
local Indexer_min_depth = 0


local min = math.min
local max = math.max


-- Ordered drawing data structure
local Indexer = setmetatable({},
    --[[
        each pixel is represented by a set in Indexer.
        So, doing Indexer[floor(ent.pos.y + ent.pos.z)] will get the set that holds ent.
    ]]
    {__index = function(t, zindx)
        t[zindx] = Set()
        Indexer_max_depth = max(Indexer_max_depth, zindx)
        Indexer_min_depth = min(Indexer_min_depth, zindx)
        return t[zindx]
    end}
)



-- This table holds Entities that point to `y+z` values that ensure that
-- Entities in Indexer can always be found.  (y+z positions are updated only when system is ready.)
local positions = {}



-- a Set for all shockwave objects that are being drawn
local ShockWaves = Tools.set()





local set, add, remove
do
    function add(ent)
        --[[
            Adds entity to Indexer
        ]]
        local zindx = floor((ent.pos.y + ent.pos.z)/2)
        Indexer[zindx]:add(ent)
    end
    function remove(ent)
        --[[
            Removes entity from previous Indexer location.
        ]]
        local gett = positions[ent]
        Indexer[gett]:remove(ent)
        return gett
    end
    function set(ent)
        --[[
            Sets current position of entity in Indexer, to give system awareness
            of what location ent is currently in in Indexer sets.
        ]]
        positions[ent] = floor((ent.pos.y + ent.pos.z)/2)
    end
end



function DrawSys:added( ent )
    -- Callback for entity addition
    set(ent)
    add(ent)
end



function DrawSys:removed( ent )
    -- Callback for entity removal
    remove(ent)
    positions[ent] = nil
    ent.draw = nil
end




function DrawSys:update(dt)
    for _,sw in ipairs(ShockWaves.objects)do
        sw:update(dt)
        if sw.isFinished then
            ShockWaves:remove(sw)
            sw.colour = nil -- easier on GC
        end
    end
end




local ccall = Cyan.call
local lg = love.graphics

local getW = love.graphics.getWidth
local getH = love.graphics.getHeight

local rawget = rawget
local ipairs = ipairs

local camera = require("src.misc.unique.camera")
local drawShockWaves

local setFont = love.graphics.setFont


local function mainDraw()
    local setColor = lg.setColor
    local isOnScreen = Tools.isOnScreen

    ccall("transform")
    
    setFont(font)
    local w,h = getW(), getH()
    local camx, camy = camera.x, camera.y

    setColor(CONSTANTS.grass_colour)
    lg.rectangle("fill", -10000,-10000, 20000,20000)

    setColor(1,1,1)

    local indx_set

    for z_dep = Indexer_min_depth, Indexer_max_depth do
        if rawget(Indexer, z_dep) then
            indx_set = Indexer[z_dep]
            for _, ent in ipairs(indx_set.objects) do
                if isOnScreen(ent, camera) then
                    setColor(1,1,1)
                    if not ent.hidden then
                        if ent.trivial then
                            ccall("drawTrivial", ent)
                        else
                            if ent.colour then
                                setColor(ent.colour)
                            end
                            ccall("drawEntity", ent)
                        end
                    end
                end
            end
        end
        ccall("drawIndex", z_dep)
    end

    Atlas:flush( )

    drawShockWaves()

    ccall("untransform")
end


function DrawSys:draw()
    mainDraw()
    
    lg.push()
    lg.scale(2)
    ccall("drawUI")
    lg.pop()
end





function DrawSys:setGrassColour(colour, a)
    if a then
        error("Grass colour expected a table, not (R, G, B)")
    end
    if type(colour) == "string" then
        local col = CONSTANTS.GRASS_COLOURS[colour]
        if not col then
            error("Colour string "..colour.." did not have a CONSTANT.GRASS_COLOUR value.")
        end
        CONSTANTS.grass_colour = col
        return
    end
    CONSTANTS.grass_colour = colour
end




local newShockWave = require("src.misc.unique.shockwave")

function DrawSys:shockwave(x, y, start_size, end_size, thickness, time, colour)
    local sw = newShockWave(x,y,start_size, end_size, thickness, time, colour or {1,1,1,1})
    ShockWaves:add(sw)
end

function drawShockWaves()
    for _,sw in ipairs(ShockWaves.objects) do
        sw:draw(  )
    end
end










local IndexSys = Cyan.System("pos", "draw", "vel")



local function fshift(ent)
    --[[
        shifts the entities around in the indexer structure
        in a fast manner
    ]]
    local z_index = floor((ent.pos.y + ent.pos.z)/2)
    if positions[ent] ~= z_index then
        remove(ent)
        set(ent)
        add(ent)
    end
end



function IndexSys:update()
    for _, ent in ipairs(self.group) do
        fshift(ent)
    end
end





