


--[[

TYPE :: 'basic'

tier :: T8 :: 8


]]


--[[

World map will be encoded by a 2d array of characters.
Capital version of any character stands for "spawn multiple."

.  :  nothing (empty space)
#  :  wall
e  :  enemy spawn
r  :  rare enemy spawn
u  :  unique enemy spawn (i.e. crowd control enemy, enemies that are bad solo)
n  :  neutral mob spawn
!  :  Bossfight
$  :  shop (add this at the end)
c  :  coin (add this at the end)
@  :  player spawn
&  :  exit level / next level
p  :  physics object
q :  spiky physics object (damages player upon hit)
^  :  decoration area (grass, nice ground texture, etc)
l  :  large immovable structure (basically a solo wall, ie a pillar, tree, giant mushroom)
*  :  collectable artefact / trophy!!



(NYI:)
In order to spawn entities, the worldGen will pick a random
constructor function from the respective char table.
That constructor function will then be called and an
entity will be placed.


]]
local Ents = require("src.entities")
local WH = require("src.misc.worldGen.WH")
local rand = love.math.random

local enemySpawns = Tools.weighted_selection{
    -- [ Ent spawn function ] = <probability of selection >
    [Ents.devil]      = 0.2;
    [Ents.wizling]     = 0.1;
    [Ents.splatenemy] = 0.4;
    [Ents.boxbully]   = 0.05;
    [Ents.multienemy]   = 0.25;
    [Ents.multiblob]  = 0.25;
    [Ents.boxsplitter]= 0.05;
    [Ents.spookymallow] = 0.4
}


local bigEnemySpawns = Tools.weighted_selection{
    -- [ Ent spawn function ] = <probability of selection >
    [Ents.splatbully]  = 0.5;
    [Ents.spookybully] = 0.5
}


local function spawnBlock(x,y)
    if rand() < 0.2 then
        EH.Ents.immuneblock(x,y)
    else
        EH.Ents.block(x,y)
    end
end



local purge_fn = function(e, cam_x, cam_y)
    -- called at end of level to clear enemies and walls.
    -- (Passed in as a param to `ccall(apply, .)`  ).
    if (e.targetID ~= "player")
    and (Tools.dist(cam_x-e.pos.x,cam_y-e.pos.y) < 160) then
        ccall("damage",e,0xffff)
    end
end


local function spawn_portal(x, y)
    local portal = EH.Ents.portal(x, y)
    ccall("shockwave", x, y, 10,550,30,1)
    ccall("emit", "dust", x, y, 0, 10)
    portal.portalDestination = {
        x = 30;
        y = 30;
        tier = 9;
        type="basic"
    }
end

return {
    construct = function(wor,wmap,px,py)
        WH.zonenum(8, px,py)
        WH.lights(wor, wmap, 15, 500)
        ccall("setGrassColour", "aqua")
    end;
    destruct = function(  )
        ccall("setGrassColour", "green")
    end;


    ratioWin = function(cam_x, cam_y)
        ccall("apply", purge_fn, cam_x, cam_y)
        ccall("await", spawn_portal, 0.8, cam_x, cam_y)
        ccall("shockwave", cam_x,cam_y, 10,250,4,0.43)
    end;

    type = 'basic',
    tier = 8,
    structureRule = 'default_T1', -- Use default Tier 1 structure rule for this tier.
        -- Note that this is NOT referring to the filename,
        -- it is referring to the `id` of the structureRule.

    PROBS = {
            -- World generation:
            -- Probability of each character occuring.
            -- Each value is a weight and does not actually represent the probability.
            -- see `GenerationSys` for what character represents what.
            ["^"] = 0.8;
            ["l"] = 0.12;
            ["p"] = 0.3;
            ["P"] = 0.01;
            ["."] = 0.4
            -- Bossfights, artefacts, are done through special structure generator
            -- Walls, shops, player spawn, and player exit are done uniquely.
    }, -- Can modify the character probabilities by setting
                        -- this to a table. 

    entExclusionZones = nil, -- Can modify this table also.
                            -- See `defaultEntExclusionZones.lua`.

    enemies = {
        n = 32;
        bign = 3
    };

    entities = {
    ["#"] = {
        max = math.huge;
        Ents.spookywall
    };

    ["e"] = {
        max = 200;
        function(x,y)
            for i=-1,rand(1,2) do
                local f = enemySpawns()
                f(x+(i-1)*40, y+(i-1)*40)
            end
        end
    };

    ["E"] = {
        max = 6;
        function(x,y)
            bigEnemySpawns()(x,y)
        end
    };

    ["p"] = {
        max = 300, -- 60 max
        function(x, y)
            for i = 1, rand(1,3) do
                Ents.spookyblock(
                    x + rand(-10, 10),
                    y + rand(-10, 10)
                )
            end
        end
    };

    ["P"] = {
        max = 3, -- Max spawns :: 3
        function(x, y)
            local block_ctor = Ents.block
            for i = 1, rand(3,6) do
                block_ctor(
                    x + rand(-32, 32),
                    y + rand(-32, 32)
                )
            end
        end
    };
    
    ['^'] = {
        max = 0xFFFFFFF;
        function(x,y)
            local grass = Ents.purpgrass
            for i=1, rand(8,9) do
                grass(x + rand(-50, 50), y + rand(-50, 50))
            end
        end
    };

    ['l'] = {
        max = 100;
        function (x, y)
            if rand()<0.5 then
                Ents.bluepine(x+rand(-30,30),y+rand(-30,30))            
            else
                Ents.blue_mushroom(x+rand(-30,30),y+rand(-30,30))
            end
        end
    };

    ["%"] = {
        max=math.huge;
        function(x,y)
            Ents.inviswall(x,y)
            for i=1, (rand()*2) do--4 + rand()*2 do
                local X = x + rand(-45,45)
                local Y = y + rand(-45,45)
                Ents.fakebluepine(X,Y)    
            end
        end
    };

    ["~"] = {
        max=math.huge;
        function(x,y)
            for i=1, rand()*4 do--4 + rand()*2 do
                local X = x + rand(-100,100)
                local Y = y + rand(-100,100)
                Ents.fakebluepine(X,Y)    
            end
        end
    };
}
}

