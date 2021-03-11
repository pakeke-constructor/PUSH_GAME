

local EH={ 
    --[[

Entity constructor helper functions.

Most of these have relatively small names,
in order to keep coding entities fast and easy and concise.

    ]]
}


local rand=love.math.random

local vec3=math.vec3
function EH.PV(e,x,y,z)
    -- position : velocity comp adding/
    e:add("pos",vec3(x,y,0))
     :add("vel",vec3(0,0,0))
    if z then
       e.pos.z = z 
    end
    
    return e
end



local PATH = Tools.Path(...)
local basePsys = require(PATH.."._EH.basePsys")

function EH.FR(e)
    --[[
        Standard friction component
    ]]
    return e:add("friction", {
        amount = 6; -- The amount of friction given to this entity
        emitter = basePsys:clone();
        required_vel = 10;
    })
end


function EH.BOB(e)
    return e:add("bobbing",{
        magnitude = 0.1;
        value=0
    })
end


local circleShapes = {
    -- cache circle shape (love.physics) objects
    -- so we don't construct duplicates with same radius.
}


function EH.PHYS(e, rad, type)
    -- default type: dynamic (but could be "kinematic" or "static")
    if not circleShapes[rad] then
        circleShapes[rad] = love.physics.newCircleShape(rad)
    end
    e:add("physics",{
        shape = circleShapes[rad];
        body = (type or "dynamic") -- (dynamic, static, kinematic)
    })
    return e
end


function EH.PC(e1,e2,speed)
    --[[
        default physics collision function.
        Entity takes damage from source, and damages player if applicable.

        Returns `true` if the collision was a hard collision,
        `false` otherwise.
    ]]
    if e1.targetID=="enemy" then
        if e2.targetID=="player" then
            ccall("damage", e2, (e1.strength or 20))
        end
    end

    if speed > CONSTANTS.ENT_DMG_SPEED then
        if e1.vel then
            ccall("damage", e1, (speed - e1.vel:len()))
        else
            ccall("damage",e1,speed)
        end
        return true -- Yes, the speed collision is greater than required
    end
    return false -- No, the collision speed was not enough to warrant hard collision
end
--[[
Common idiom here:


local function entColFunc( e1, e2, spd )
    
    if EH.PC( e1, e2, spd ) then

        ... Do stuff here, like make noise, spawn tokens, IDK.
    end
end

]]






Tools.req_TREE('src/misc/behaviour/tasks')


local PROXY = { }
EH.entities = setmetatable({___PROXY = PROXY}, {__newindex = function(t,k,v)
    if rawget(PROXY,k) then
        error("Entity file already had the name : "..k .. ". Duplicate names not allowed!")
    end
    rawset(PROXY,k,v)
end;
__index = PROXY
})
EH.Ents=EH.entities



function EH.TOK(e, amount)
    --[[
        spawns `amount` tokens around an entity.
    ]]
    local x,y = e.pos.x,e.pos.y
    for i=1,amount do
        EH.Ents.tok(x+(60*(rand()-0.5)), y+(60*(rand()-0.5)))
    end
end



local function spawnCoin(p)
    entities.coin(p.x,p.y)
end

function EH.COIN(chance)
    if rand() < chance then
        ccall('await', spawnCoin)
    end
end




EH.BT   = require("libs.BehaviourTree")
EH.Node = require("libs.BehaviourTree").Node
EH.Task = require("libs.BehaviourTree").Task

EH.Quads = require("assets.atlas").Quads
EH.Atlas = require("assets.atlas")

return EH

