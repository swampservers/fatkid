-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
GM.Human = GM.Human or {}
GM.Zombie = GM.Zombie or {}
GM.AZ = GM.AZ or {}
--Basic config
GM.RoundDuration = 360
GM.BetweenRoundDuration = 10
GM.RespawnDelay = 2
GM.AZRespawnDelay = 2
GM.InfectedSpawnDelay = 10
GM.DelayAZSpawn = true
GM.UseAZ = false --Use seperate Original Zombie settings?
GM.KeepScore = true --Track frags/deaths?
TEAM_HUMAN = 2
TEAM_ZOMBIE = 3
TEAM_AZ = 4 -- Alpha Zombie
team.SetUp(TEAM_HUMAN, "Humans", Color(255, 255, 100))
team.SetUp(TEAM_ZOMBIE, "Zombies", Color(255, 50, 50))
team.SetUp(TEAM_AZ, "Original Zombies", Color(150, 10, 10))
GM.Human.ShortName = "human"
GM.Zombie.ShortName = "zombie"
GM.AZ.ShortName = "az"
--Global timer variable:
--Round starts at RoundTimer = RoundDuration, ends at 0, and restarts at -BetweenRoundDuration
RoundTimer = RoundTimer or 10

function GM:SelectPlayerConfig(ply)
    if ply then
        if ply:Team() == TEAM_HUMAN then return self.Human end
        if self.UseAZ and ply:Team() == TEAM_AZ then return self.AZ end
    end

    return self.Zombie
end

--Disable friendly fire
function GM:PlayerShouldTakeDamage(ply, attacker)
    if attacker:IsPlayer() and attacker ~= ply then
        if ply:Team() == attacker:Team() or ply:Team() + attacker:Team() == TEAM_ZOMBIE + TEAM_AZ then return false end
    end

    return true
end

function GM:TimeTilSpawn(ply)
    if RoundTimer <= 0 then return math.max(self.BetweenRoundDuration + RoundTimer, 0) end
    local delay = math.max(self.RespawnDelay, 1)

    if ply:Team() == TEAM_AZ then
        delay = self.AZRespawnDelay
    end

    local deathTime = ply.DeathTime or 0

    return math.max(math.floor((deathTime + delay) - CurTime()), RoundTimer - (self.RoundDuration - self.InfectedSpawnDelay), 0)
end

function ents.FindByClasses(types)
    local mapping = {}

    for _, cls in pairs(types) do
        mapping[cls] = true
    end

    local out = {}

    for k, v in next, ents.GetAll() do
        if mapping[v:GetClass()] then
            table.insert(out, v)
        end
    end

    return out
end

function table.Shuffle(t)
    local n = #t

    while n > 2 do
        local k = math.random(n)
        t[n], t[k] = t[k], t[n]
        n = n - 1
    end

    return t
end
