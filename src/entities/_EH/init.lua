

local EH={ }

local vec3=math.vec3
function EH.PV(e,x,y,z)
    -- position : velocity comp adding/
    return e:add("pos",vec3(x,y,z or 0))
        :add("vel",vec3(0,0,0))
end



local PATH = Tools.Path(...)
local basePsys = require(PATH.."._EH.basePsys")

function EH.FR(e)
    --[[
        Standard friction component
    ]]
    e:add("friction", {
        amount = 6; -- The amount of friction given to this entity
        emitter = basePsys:clone();
        required_vel = 10;
    })
    return e
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


Tools.req_TREE('src/misc/behaviour/tasks')


EH.BT   = require("libs.BehaviourTree")
EH.Node = require("libs.BehaviourTree").Node
EH.Task = require("libs.BehaviourTree").Task


EH.Quads = require("assets.atlas").Quads
EH.Atlas = require("assets.atlas")

return EH

