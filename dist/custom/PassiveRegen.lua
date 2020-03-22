-- Lua Library inline imports
function __TS__ObjectKeys(obj)
    local result = {}
    for key in pairs(obj) do
        result[#result + 1] = key
    end
    return result
end

function __TS__ArrayForEach(arr, callbackFn)
    do
        local i = 0
        while i < #arr do
            callbackFn(_G, arr[i + 1], i, arr)
            i = i + 1
        end
    end
end

function PassiveRegenOnTimer()
    PassiveRegen:onTimer()
end
PassiveRegen = {
    timerInterval = 2500,
    fatigueMin = 0.9,
    healthRate = 0.25,
    healthBucket = 0,
    healthRegenMax = 0.5,
    magickaRate = 0.1,
    magickaBucket = 0,
    magickaRegenMax = 0.5,
    regenTimerId = nil,
    onTimer = function()
        __TS__ArrayForEach(
            __TS__ObjectKeys(Players),
            function(____, pid)
                local player = Players[pid]
                if (player == nil) or (not player:IsLoggedIn()) then
                    return
                end
                local healthBase = player.data.stats.healthBase
                local magickaBase = player.data.stats.magickaBase
                local fatigueBase = player.data.stats.fatigueBase
                local healthCurrent = tes3mp.GetHealthCurrent(pid)
                local magickaCurrent = tes3mp.GetMagickaCurrent(pid)
                local fatigueCurrent = tes3mp.GetFatigueCurrent(pid)
                PassiveRegen.healthBucket = PassiveRegen.healthBucket + ((PassiveRegen.healthRate * PassiveRegen.timerInterval) * 0.001)
                PassiveRegen.magickaBucket = PassiveRegen.magickaBucket + ((PassiveRegen.magickaRate * PassiveRegen.timerInterval) * 0.001)
                local changed = false
                if healthBase > 1 then
                    if fatigueCurrent > (fatigueBase * PassiveRegen.fatigueMin) then
                        if ((healthBase * PassiveRegen.healthRegenMax) > healthCurrent) and (PassiveRegen.healthBucket >= 1) then
                            player.data.stats.healthCurrent = healthCurrent + math.floor(PassiveRegen.healthBucket)
                            tes3mp.SetHealthCurrent(pid, player.data.stats.healthCurrent)
                        end
                        if ((magickaBase * PassiveRegen.magickaRegenMax) > magickaCurrent) and (PassiveRegen.magickaBucket >= 1) then
                            player.data.stats.magickaCurrent = magickaCurrent + math.floor(PassiveRegen.magickaBucket)
                            tes3mp.SetMagickaCurrent(pid, player.data.stats.magickaCurrent)
                        end
                        tes3mp.SendStatsDynamic(pid)
                    end
                end
            end
        )
        if PassiveRegen.healthBucket >= 1 then
            PassiveRegen.healthBucket = PassiveRegen.healthBucket - math.floor(PassiveRegen.healthBucket)
        end
        if PassiveRegen.magickaBucket >= 1 then
            PassiveRegen.magickaBucket = PassiveRegen.magickaBucket - math.floor(PassiveRegen.magickaBucket)
        end
        tes3mp.RestartTimer(PassiveRegen.regenTimerId, PassiveRegen.timerInterval)
    end,
    init = function()
        PassiveRegen.regenTimerId = tes3mp.CreateTimer("PassiveRegenOnTimer", PassiveRegen.timerInterval)
        tes3mp.StartTimer(PassiveRegen.regenTimerId)
    end
}
PassiveRegen:init()
