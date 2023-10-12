-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
GM.Name = "Fat Kid"
GM.RoundDuration = 420
GM.RespawnDelay = 2
GM.AZRespawnDelay = 10
GM.InfectedSpawnDelay = 30
GM.DelayAZSpawn = false
GM.UseAZ = true
GM.KeepScore = false

team.SetColor(TEAM_HUMAN, Color(90, 255, 255))
team.SetColor(TEAM_ZOMBIE, Color(170, 170, 170))
team.SetColor(TEAM_AZ, Color(220, 20, 10))

--Disable friendly fire and self harm
function GM:PlayerShouldTakeDamage(ply, attacker)
    if attacker:IsPlayer() then
        if ply:Team() == attacker:Team() or ply:Team() + attacker:Team() == TEAM_ZOMBIE + TEAM_AZ then return false end
    end

    return true
end

--Funky solution so skeletons can hit fatkid with crowbar
function GM:ShouldCollide(ent1, ent2)
    if ent1:IsPlayer() and ent2:IsPlayer() then
        if ent1:Team() == TEAM_ZOMBIE and ent2:Team() == TEAM_AZ then return false end
        if ent1:Team() == TEAM_AZ and ent2:Team() == TEAM_ZOMBIE then return false end --ent2:KeyDown(IN_ATTACK)
    end

    return true
end
