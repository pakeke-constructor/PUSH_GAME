

local EPOCH_TIME = 40 -- 40 seconds per upgrade interval

local SPAWN_TIME = 3 -- seconds


local START_SPAWN_MIN = 2 -- starting spawn rates
local START_SPAWN_MAX = 4


local rand = love.math.random


local function rblock(x,y)
    local rr = rand()
    if rr < 0.1 then
        EH.Ents.mushroomblock(x,y)
    elseif rr < 0.2 then 
        EH.Ents.multiblock(x,y)
    else
        EH.Ents.block(x,y)
    end
end


local function spawnGroup(ent, x, y)
    local spawn = ent._mediator_spawners[ent._mediator_spawner_index]

    local min, max = ent._mediator_min_spawns, ent._mediator_max_spawns
    local amount = min + (rand() * (max - min))

    ccall('shockwave', x, y, 20, 120, 12, 0.4)

    for i=1, amount do
        spawn()(x + rand(-34, 34), y + rand(-34, 34))
    end

    for i=1, 3 do
        rblock(x + rand(-40, 40), y + rand(-40, 40))
    end
end



local directions = {
    {0, 1};
    {1, 0};
    {0, -1};
    {-1, 0}
}

local function spawnEnemies(ent)
    local x, y = ent._mediator_orig_x, ent._mediator_orig_y + CONSTANTS.TILESIZE
    local dist = CONSTANTS.TILESIZE * 4
    local dir_i = ent._mediator_direction_index

    local dir = directions[dir_i]
    local xmod, ymod = dir[1], dir[2]

    spawnGroup(ent, x + xmod * dist, y + ymod * dist)

    ent._mediator_direction_index = (dir_i % (#directions)) + 1
end



local function makeGameHarder(e)
    local spawners = e._mediator_spawners
    local i = e._mediator_spawner_index
    if i >= #spawners then
        -- Then increase spawn amount
        e._mediator_max_spawns = e._mediator_max_spawns * 1.1
        e._mediator_min_spawns = e._mediator_min_spawns * 1.1
    else
        -- else, move level up
        e._mediator_spawner_index = i + 1
    end
end


local function onUpdate( ent,dt )
    local epoch_t = ent._mediator_epoch_time
    local spawn_t = ent._mediator_spawn_time
    
    ent._mediator_epoch_time = epoch_t + dt
    ent._mediator_spawn_time = spawn_t + dt

    if spawn_t > SPAWN_TIME then
        spawnEnemies(ent)
        ent._mediator_spawn_time = 0
    end

    if epoch_t > EPOCH_TIME then
        makeGameHarder(ent)
        ent._mediator_epoch_time = 0
    end

    ent.text = Tools.totime(CONSTANTS.runtime)
end




local spawn_lv1
local spawn_lv2
local spawn_lv3
local spawn_lv4



local function initSpawners()
    if not spawn_lv1 then
        local E = EH.Ents

        spawn_lv1 = Tools.weighted_selection{
            [E.enemy] = 0.4;
            [E.huhu] = 0.2;
            [E.splatenemy] = 0.2;
            [E.mallow] = 0.2;
            [E.boxenemy] = 0.2;
            [E.boxblob] = 0.2;
            [E.ghost] = 0.1
        }

        spawn_lv2 = Tools.weighted_selection{
            [E.mallow] = 0.2;
            [E.boxbully] = 0.2;
            [E.demon] = 0.3;
            [E.splatenemy] = 0.2;
            [E.boxenemy] = 0.2;
            [E.ghost_squad] = 0.2;
            [E.bully] = 0.2
        }

        spawn_lv3 = Tools.weighted_selection{
            [E.demon] = 0.3;
            [E.multienemy] = 0.3;
            [E.multiblob] = 0.3;
            [E.boxbully] = 0.3;
            [E.spookyenemy] = 0.5;
            [E.spookybully] = 0.3;
            [E.mallow] = 0.2;
        }

        spawn_lv4 = Tools.weighted_selection{
            [E.boxbully] = 0.2;
            [E.demon] = 0.4;
            [E.splatenemy] = 0.08;
            [E.boxenemy] = 0.3;
            [E.multienemy] = 0.2;
            [E.multiblob] = 0.2;
            [E.enemy] = 0.3;
            [E.ghost_squad] = 0.2;
            [E.bully] = 0.2;
            [E.spookyenemy] = 0.3;
            [E.spookybully] = 0.1;
            [E.biggerspookyblob] = 0.2;
            [E.blob] = 0.1;
            [E.bigworm] = 0.02;
            [E.bigblob] = 0.01;
            [E.wizling] = 0.2;
        }
    end
end



return function(x,y)
    local e = Cyan.Entity()
    e._mediator_orig_x = x
    e._mediator_orig_y = y

    initSpawners()

    e._mediator_spawners = {
        spawn_lv1,
        spawn_lv2,
        spawn_lv3,
        spawn_lv4
    }

    e._mediator_direction_index = 2 -- Each direction (left, right, up,) has an index
                -- This is the current index the mediator is spawning in.
                -- indexes go from    1 -> 4

    e._mediator_spawner_index = 1 -- current spawner in use
    e._mediator_min_spawns = 2 -- Min spawns for each direction (4 directions, 8 minimum)
    e._mediator_max_spawns = 4 -- Max spawns for each direction ('..', 16 maximum)

    e._mediator_epoch_time = 0 -- Time since last spawner change
    e._mediator_spawn_time = 0 -- Time since last spawn 

    e.pos = math.vec3(x,y+100,50)
    e.text = "0:0"

    e.onUpdate = onUpdate
    e.hybrid = true

    return e
end



