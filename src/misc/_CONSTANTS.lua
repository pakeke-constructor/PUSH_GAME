

return{
    MAX_DT = 0.05 -- Maximum value `dt` will ever take.
,
    GRAVITY = -981
,
    MAX_VEL = 10000
,
    AVERAGE_DT = 1/60
,
    PUSH_RANGE = 50
,
    PHYSICS_LINEAR_DAMPING = 0.05
,
    ENT_DMG_SPEED = 260 -- ents hit faster than this will be damaged (except player!)
,
    PROBS = {
        -- World generation:
        -- Probability of each character occuring.
        -- Each value is a weight and does not actually represent the probability.
        -- see `GenerationSys` for what character represents what.
        ["e"] = 0.2;
        ["E"] = 0.005;
        ["r"] = 0.02; -- 0.02 weight chance of spawning on random tile.
        ["R"] = 0.005;
        ["u"] = 0.01;
        ["U"] = 0.003;
        ["^"] = 0.8;
        ["l"] = 0.03;
        ["p"] = 0.3;
        ["P"] = 0.01;
        ["."] = 0.4
        -- Bossfights, artefacts, are done through special structure generator
        -- Walls, shops, player spawn, and player exit are done uniquely.
    }
,
    TARGET_GROUPS = {
        "player";
        "physics";
        "enemy";
        "neutral";
        "interact";
        "coin"
    }
,
    paused = false -- debug only  (if not debug only, make an cyan.call event for this)
,
    GRASS_COLOUR = {0.2,1,0.2} -- colour of ground grass
,
    COLOURBLIND = false
,
    DEBUG = true
}

