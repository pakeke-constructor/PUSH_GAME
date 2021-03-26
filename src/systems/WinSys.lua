
--[[
    handles win conditions.

There are multiple win conditions that are emitted.

 * ccall( ratioWin ) 
    When the enemy : total enemy ration is less than CONSTANTS.WIN_RATIO

 * ccall( voidWin )
    when enemyCount == 0
 
]]


local WinSys = Cyan.System("targetID")


local enemyCount = 0

local enemyCountTotal = 0



function WinSys:added(e)
    if e.targetID == "enemy" then
        enemyCount = enemyCount + 1
        enemyCountTotal = enemyCountTotal + 1
    end
end


local function checkWin(dt)
    --[[
        TODO:
        maybe add an extra check to account
        for bosses. We dont want to spawn an exit
        portal if the player is halfway thru fighting
        a boss
    ]]
    if (enemyCount / enemyCountTotal) < CONSTANTS.WIN_RATIO then
        ccall("ratioWin")-- yyeahhh baby
    end
    if enemyCount <= 0 then
        ccall("voidWin")
    end
end


function WinSys:removed(e)
    if e.targetID == "enemy" then
        enemyCount = enemyCount - 1
    end
    checkWin()
end



