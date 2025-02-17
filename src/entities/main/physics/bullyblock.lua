
--[[
TODO:

This block slows player on hit/

]]


local atlas = require "assets.atlas"
local Quads = atlas.Quads

local psys = love.graphics.newParticleSystem(atlas.image)

do
    psys:setQuads(Quads.circ3, Quads.circ2, Quads.circ1)
    psys:setParticleLifetime(0.4, 0.5)
    --psys:setLinearAcceleration(0,0,200,200)
    psys:setDirection(180)
    psys:setSpeed(5,15)
    psys:setEmissionRate(120)
    psys:setRotation(0,math.pi*2)
    psys:setSpread(math.pi/2)
    psys:setEmissionArea("uniform", 10,0)
    psys:setColors({0.3,0.3,0.3,0.5}, {0.3,0.3,0.3,0.5})
    --psys:setSpin(-40,40)
    --psys:setRotation(0, 2*math.pi)
    --psys:setRelativeRotation(false)
    local _,_, pW, pH = psys:getQuads()[1]:getViewport( )
    psys:setOffset(pW/2, pH/2)
end


local _,_, w,h = Quads.block:getViewport( )
local block_shape = love.physics.newRectangleShape(w/2,h/2)


local sprites = {
    Quads.slant_block, Quads.slant_block2
}


local ccall = Cyan.call
local rand = love.math.random
local cam = require("src.misc.unique.camera")



local PUSH_STRENGTH = 1.5

local collisions = {
    physics = function(ent,col, speed)
        if col.targetID=="physics" then
            ccall("kill",col)
            ccall("kill",ent)
        elseif col.targetID=="static" then
            ccall("kill",ent)
        elseif col.targetID=="player" then
            local physics = col.physics
            if not physics then return end
            local vel = (ent.pos - col.pos):normalize() * ent.vel * PUSH_STRENGTH
            physics.body:applyLinearImpulse(vel.x,vel.y)
            ccall("kill",ent)
        end
        local p = ent.pos
        ccall("animate", "push", p.x,p.y+25,p.z, 0.03) 
    end
}


local colours = {}
for i=120,0,-5 do
    local u = (300 - i)/300
    table.insert(colours, {u,u,u})
end


return function(x,y)
    if (not x) or (not y) then error("hey! stop it") end
    local abs = math.abs
    return Cyan.Entity()
    :add("pos", math.vec3(x,y,0))
    :add("vel", math.vec3(0,0,0))
    :add("acc", math.vec3(0,0,0))
    :add("colour", Tools.rand_choice(colours))
    :add("physics", {
        shape = block_shape;
        body  = "dynamic"
    })
    :add("pushable",true)
    :add("bobbing", {magnitude = 0.15, value = 0})
    :add("friction", {
        emitter = psys:clone();
        required_vel = 2;
        amount = 0.9
    })
    :add("collisions",collisions)--   Turned these off for now
    :add("targetID", "physics")
    :add("image", {quad = Tools.rand_choice(sprites), oy = 20})
end




