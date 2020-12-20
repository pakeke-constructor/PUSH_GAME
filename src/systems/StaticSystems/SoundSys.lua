


local SoundSys = Cyan.System()
--[[
SOUND FILE NAMES MATTER !!!
SOUND FILE NAMES MATTER !!!
SOUND FILE NAMES MATTER !!!
SOUND FILE NAMES MATTER !!!
SOUND FILE NAMES MATTER !!!
SOUND FILE NAMES MATTER !!!
SOUND FILE NAMES MATTER !!!



System in control of sound handling.

Sounds will be automatically grouped together depending on their
filename.
`main` stands for main sounds,
`bg` stands for background sounds.
(background sounds can vary in volume)
usually the main sounds will be the loudest.


For example:

`boom_main1.ogg`, `boom_main2.ogg`, `boom_bg1.ogg`, `boom_bg2.ogg`.
In this scenario, whenever `boom` is envoked,
either main1 or main2 will play, and BOTH bg (background) sounds will be played.

each soundGroup is represented by this:

exampleSoundGroup {
    mainSounds = { };
    backgroundSounds = { }
}

]]

local sounds = require("src.misc.sound")



-- Hasher to each sound group by KW
local soundGroups = { }


for k,v in pairs(sounds) do
    if k:find("_") then
        local s = k:find("_")
        local groupName = k:sub(1,s-1)
        assert(groupName:len()>0, "Wtf? started with an _ ?? sound_TREE_push not working")

        -- Construction
        soundGroups[groupName] = soundGroups[groupName] or {
            mainSounds = { };
            backgroundSounds = { }
        }

        local group = soundGroups[groupName]

        if k:sub(s+1,s+2)=="bg" then
            table.insert(group.backgroundSounds, v)  
        else
            table.insert(group.mainSounds, v)
        end
    end
end



local rand_choice = Tools.rand_choice
local sin = math.sin
local rand = love.math.random
local play = love.audio.play





local function playSound(src, vol, pitch, vol_v, p_v)
    local origPitch = src:getPitch ( )
    local origVol = src:getVolume  ( )
    src:setVolume(vol + (vol_v) * sin(rand()*3.14))
    src:setPitch (pitch + (p_v) * sin(rand()*3.14))
    play( src )
    src:setVolume( origVol )
    src:setPitch (origPitch)
end




function SoundSys:sound(sound, volume, pitch,
                        volume_variance,  pitch_variance)
    --[[
        sound : string
        volume : 0 no sound   ->   1 max vol
        volume_variance : 0.2 => sound vol will vary by 0.2 (default 0)
        pitch_variance  : 0.1 => pitch will vary by 0.1     (default 0)
    ]]
    volume = volume or 1
    pitch = pitch or 1
    volume_variance = volume_variance or 0
    pitch_variance = pitch_variance or 0

    if soundGroups[sound] then
        local group = soundGroups[sound]
        playSound( rand_choice(group.mainSounds), volume, pitch, volume_variance, pitch_variance )
        for _,src in ipairs(group.backgroundSounds) do
            playSound(src, volume, pitch, volume_variance, pitch_variance )
        end
    else
        if not sounds[sound] then
            error("Missing sound : "..sound)
        end
        playSound(sounds[sound], volume, pitch, volume_variance, pitch_variance)
    end
end





