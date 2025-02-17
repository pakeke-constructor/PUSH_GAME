
--[[

Hell-ish version of `mallow` ent.


]]


local Atlas = require("assets.atlas")
local Quads = Atlas.Quads
local EH = EH
local BT = EH.BT
local ccall = Cyan.call
local rand = love.math.random


local COLOUR={0.68,0.9,0.47}

local MINION_COLOUR = {0.78, 1, 0.6}

local BULLET_SPEED = 170




-- motion animation 
local up,down,left,right
up={}
down={}
left={}
right={}
local ti = table.insert
for i=1,4 do
    ti(down, EH.Quads["mallow_down_"..tostring(i)])
    ti(up, EH.Quads["mallow_up_"..tostring(i)])
    ti(left, EH.Quads["mallow_left_"..tostring(i)])
    ti(right, EH.Quads["mallow_right_"..tostring(i)])
end



local atlas = EH.Atlas
local Quads= atlas.Quads

local psys = love.graphics.newParticleSystem(atlas.image)
psys:setQuads(Quads.beet, Quads.bat, Quads.bot)
psys:setParticleLifetime(0.4, 0.8)
--psys:setLinearAcceleration(0,0,200,200)
psys:setDirection(180)
psys:setSpeed(5,15)
psys:setEmissionRate(50)
psys:setSpread(math.pi/2)
psys:setEmissionArea("uniform", 6,0)
psys:setColors({0.5,0.5,0.5})
psys:setSpin(-40,40)
psys:setRotation(0, 2*math.pi)
psys:setRelativeRotation(false)
local _,_, pW, pH = psys:getQuads()[1]:getViewport( )
psys:setOffset(pW/2, pH/2)






local Tree = EH.Node("demon behaviour tree")


local Camera = require("src.misc.unique.camera")

function Tree.choose(tree, e)
    if (e.hp.hp < e.hp.max_hp) or (Tools.distToPlayer(e, Camera) < 250) then
        if rand() < 0.5 then
            --print("mallow tree: angry")
            return "angry"
        else
            return "spin"
        end
    else
        --print("mallow tree: idle")
        return "idle"
    end
end



local mallow_spin_task = EH.Task("_demon spin task")

mallow_spin_task.start = function(t,e)
    ccall("setMoveBehaviour", e,"IDLE")
    ccall("setVel", e, 0,0)
    ccall("animate", 'mallowspin', 0,0,0, 0.1, 3, COLOUR, e, true)
end

mallow_spin_task.update=function(t,e)
    ccall("setVel",e,0,0)
    if e.hidden then
        -- Repeat until the entity is no longer hidden.
        return "r"
    else
        return "n"
    end
end


Tree.spin = {
    mallow_spin_task,
    "move::LOCKON",
    "wait::3"
}

Tree.angry = {
    "move::ORBIT",
    "wait::4"
}

Tree.idle = {
    "move::RAND",
    "wait::3"
}



local physColFunc = function(e1, e2, speed)
    if EH.PC(e1,e2,speed) then
        ccall("sound","hit")
    end
end



local r = love.math.random


local function spawnAfterDeath(x,y,z)
    local e1=EH.Ents.mallow(x,y+5)
    local e2=EH.Ents.mallow(x,y-5)
    e1.colour = MINION_COLOUR
    e2.colour = MINION_COLOUR

    ccall("emit", "guts", x,y,z,r(13,18))
    ccall("animate", "push", x,y+25,z, 0.03)
    ccall("damage",e1,e1.hp.max_hp/2) -- Lets weaken em a bit so they aren't OP!
    ccall("damage",e2,e2.hp.max_hp/2)
    ccall("sound","glassbreak",0.3,1,0,0.3)
end



local function spawnBullets(x,y)
    for vx=-1,1 do
        for vy=-1,1 do
            if vx~=0 or vy~=0 then
                ccall("shoot", x + vx*17, y + vy*17,
                    BULLET_SPEED*vx, BULLET_SPEED*vy)  
            end
        end
    end
end

local function onDeath(e)
    local p = e.pos
    ccall("emit", "guts", p.x, p.y, p.z, r(6,10))
    ccall("shockwave", p.x,p.y, 160, 3, 9, .4)
    ccall("await", spawnAfterDeath, .3, p.x,p.y,p.z)
    ccall("await", spawnBullets, 0.2, p.x, p.y)
    ccall("sound","glassbreak",0.25,0.5,0,0.3)
    EH.TOK(e,r(2,4))
end



-- ctor
return function(x, y)
    local e = Cyan.Entity()
    EH.PV(e,x,y)

    e.hp={
        hp=2000,
        max_hp=2000
    }

    e.bobbing={magnitude=0.25}

    e.speed = {speed = 90, max_speed = 100}

    e.pushable=false

    e.targetID = "enemy"

    EH.PHYS(e,7,"dynamic")

    e:add("friction", {
        amount = 6;
        emitter = psys:clone();
        required_vel = 10;
    })

    e.collisions = {
        physics = physColFunc
    }

    e.motion = {
        up=up;
        down=down;
        left=left;
        right=right;

        current=0;
        interval=0.3;
        required_vel=1
    }

    e.onDeath = onDeath

    e.colour = COLOUR

    e.behaviour = {
        move={
            type="IDLE",
            id="player",
            
            orbit_tick = 0,
            orbit_speed = 1.2
        };
        tree=Tree
    }

    return e
end

