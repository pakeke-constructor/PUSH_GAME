



local atlas = require "assets.atlas"
local Quads = atlas.Quads

-- This emitter's ParticleSystems must not have particles that survive for
-- any longer than this!
local MAX_PARTICLE_TIME = 1.4


local psys = love.graphics.newParticleSystem(atlas.image)


do
    psys:setQuads(Quads.shotgunshell)

    psys:setParticleLifetime(1.2, MAX_PARTICLE_TIME)
    --psys:setLinearAcceleration(0,0,200,200)
    psys:setDirection(-math.pi/2)
    psys:setSpeed(100,110)
    psys:setEmissionRate(0)
    psys:setSpread(math.pi/4)
    psys:setEmissionArea("uniform", 3,2)
    psys:setColors({1,1,1}, {1,1,1,0.9})
    psys:setSpin(-5,-5)
    psys:setRotation(-2*math.pi, 2*math.pi)
    psys:setRelativeRotation(false)
    psys:setLinearAcceleration(0, 250)

    local _,_, pW, pH = psys:getQuads()[1]:getViewport( )
    psys:setOffset(pW/2, pH/2)
end


local psyses = {
    psys
}




local emitter
emitter = {
    psyses = {},
    type = "shell",
    runtime = 0
}

emitter.mt = {__index = emitter}


local ceil = math.ceil
local rand = math.random
local setColor = love.graphics.setColor

function emitter:emit(x,y,n, colour)
    self.colour = colour
    setColor(self.colour)
    for i, ps in ipairs(self.psyses) do
        ps:emit(n)
    end
end


function emitter:clone()
    local tab = setmetatable({
        psyses = {};
        runtime = 0;
        mt = self.mt
    }, self.mt)
    
    for i,ps in ipairs(psyses)do
        table.insert(tab.psyses, ps:clone())
    end

    return tab
end


local draw = love.graphics.draw

function emitter:draw(x,y,z)
    for i,ps in ipairs(self.psyses) do
        draw(ps, x,y - z/2)
    end
end



function emitter:update(dt)
    for i,ps in ipairs(self.psyses) do
        ps:update(dt)
    end
    self.runtime = self.runtime + dt
end


function emitter:isFinished()
    return self.runtime > MAX_PARTICLE_TIME
end


function emitter:release()
    for k,ps in ipairs(self.psyses)do
        ps:release()
    end
end




return emitter

