-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
hook.Add("MapSetup", "Gymnasium_Dodgeballs", function()
    for i = 1, 5 do
        e = ents.Create("dodgeball")
        e:SetPos(Vector(math.random(280, 960), math.random(660, 1000), math.random(70, 90)))
        e:Spawn()
        e:Activate()
    end
end)

GM.BarricadeBaseHealth = 800
GM.FatKidDamageMod = 1.25
local childScale = 0.85
GM.Human.Speed = GM.Human.Speed * childScale
GM.AZ.StartSpeed = 44 * childScale
GM.AZ.EndSpeed = 80 * childScale
GM.Zombie.StartSpeed = 280 * childScale
GM.Zombie.EndSpeed = 360 * childScale
GM.Zombie.CrouchSpeedMod = 0.5
local BaseSpawn = GM.PlayerSpawn

function GM:PlayerSpawn(ply)
    BaseSpawn(self, ply)
    ply:SetModelScale(childScale)
    ply:SetViewOffset(Vector(0, 0, childScale * 64))
    ply:SetViewOffsetDucked(Vector(0, 0, childScale * 28))

    if PonyRound and ply:Team() == TEAM_ZOMBIE then
        ply:SetViewOffset(Vector(0, 0, childScale * 42))
        ply:SetViewOffsetDucked(Vector(0, 0, childScale * 32))
    end

    if ply:Team() == TEAM_AZ then
        ply:SetModel(GAMEMODE.AZ.PlayerModels[1])
        ply:SetPos(ply:GetPos() + Vector(8, 0, 0))
    end
end

hook.Add("PlayerShouldTakeDamage", "Skellynoshock", function(ply, att)
    if ply:Team() == TEAM_ZOMBIE and att:GetClass() == "trigger_hurt" then return false end
end)

hook.Add("EntityTakeDamage", "Minigundmg", function(target, dmginfo)
    if (IsValid(dmginfo:GetInflictor()) and dmginfo:GetInflictor():GetClass() == "func_tank") then
        dmginfo:ScaleDamage(4)
    end
end)

hook.Add("PlayerUse", "minigunblock", function(ply, ent)
    if ply:Team() ~= TEAM_HUMAN and ent:GetClass() == "func_tank" then return false end
end)