-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
GM.AZCount = 1
GM.AZWinsTimeout = true
GM.EndIfNoHumans = true
GM.EndIfNoZombies = true
GM.EndIfNoAZs = true
GM.HumanWinMessage = "Ducks win!"
GM.ZombieWinMessage = "Hunter wins!"
GM.NewZombieMessage = "is the new Hunter!"
GM.NewZombiesMessage = "are the new Hunters!"
GM.AZAbandonMessage = "The Hunter has abandoned the game!"
GM.Human.Health = 100
GM.Human.HealthRecharge = 0
GM.Human.InflictDamageScale = 1
GM.Human.TakeDamageScale = 1
GM.Zombie.HeadshotMultiplier = 10
GM.Human.Speed = 170
GM.Human.JumpPower = 200
GM.Human.SpawnWeapon = ""
GM.Human.CanPickupWeapons = true
GM.Human.ReceiveAmmo = true

GM.Human.PlayerModels = {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", "models/player/group01/male_03.mdl", "models/player/group01/male_04.mdl", "models/player/group01/male_05.mdl", "models/player/group01/male_06.mdl", "models/player/group01/male_07.mdl", "models/player/group01/male_08.mdl", "models/player/group01/male_09.mdl", "models/player/group01/female_01.mdl", "models/player/group01/female_02.mdl", "models/player/group01/female_03.mdl", "models/player/group01/female_04.mdl", "models/player/group01/female_05.mdl", "models/player/group01/female_06.mdl"}

GM.Human.HideHands = false
GM.Zombie.Health = 100
GM.Zombie.HealthRecharge = 0
GM.Zombie.InflictDamageScale = 1
GM.Zombie.TakeDamageScale = 5
GM.Zombie.HeadshotMultiplier = 2
GM.Zombie.Speed = 500
GM.Zombie.CrouchSpeedMod = 0.4
GM.Zombie.JumpPower = 0
GM.Zombie.SpawnWeapon = "weapon_crowbar"
GM.Zombie.CanPickupWeapons = false
GM.Zombie.ReceiveAmmo = false

GM.Zombie.PlayerModels = {"models/player/charple.mdl"}

GM.Zombie.HideHands = true
GM.AZ.Health = 100
GM.AZ.HealthRecharge = 0
GM.AZ.HealthRechargeDelay = 1
GM.AZ.InflictDamageScale = 1 -- changes, see below
GM.AZ.TakeDamageScale = 5
GM.AZ.HeadshotMultiplier = 1
GM.AZ.FallDamageMultiplier = 1
GM.AZ.Speed = 200
GM.AZ.CrouchSpeedMod = 0.6
GM.AZ.JumpPower = 180
GM.AZ.SpawnWeapon = "weapon_crossbow"
GM.AZ.CanPickupWeapons = false
GM.AZ.ReceiveAmmo = true

GM.AZ.PlayerModels = {"models/player/combine_super_soldier.mdl"}

GM.AZ.HideHands = true
GM.AZ.Lives = 1

GM.AmmoRegen = {
    {
        type = "XBowBolt",
        amount = 999,
        delay = 1
    }
}

GM.MapWeapons = {
    {
        class = "weapon_crossbow",
        respawn = true,
        freeze = true
    }
}

hook.Add("RoundStart", "DuckHunt_Balancing", function()
    local pc = #player.GetAll()
    local hits = 1

    if pc < 10 then
        hits = 2
    end

    if pc < 6 then
        hits = 3
    end

    if pc < 4 then
        hits = 4
    end

    GAMEMODE.AZ.InflictDamageScale = 1.1 / hits
end)

RunConsoleCommand("sv_maxvelocity", "20000")

hook.Add("OnEntityCreated", "FasterBolts", function(ent)
    if ent:GetClass() == "crossbow_bolt" then
        ent:SetVelocity(ent:GetVelocity() * 2)

        timer.Simple(0.05, function()
            if IsValid(ent) then
                util.SpriteTrail(ent, 0, Color(255, 255, 255, 200), false, 4, 1, 0.5, 1 / (4 + 1) * 0.5, "trails/smoke.vmt")
            end
        end)
    end
end)

hook.Add("Tick", "DuckHunt_OutOfWater", function()
    for k, v in pairs(player.GetAll()) do
        if v:Team() == TEAM_ZOMBIE and v:Alive() then
            if v:WaterLevel() == 0 then
                if v.GotInWater then
                    v:Kill()
                end
            else
                v.GotInWater = true
            end
        end
    end
end)

hook.Add("EntityTakeDamage", "SharkNoDrown", function(target, dmginfo)
    if (not target:IsPlayer() or target:Team() == TEAM_ZOMBIE) and dmginfo:GetDamageType() == DMG_DROWN then return true end
end)

function GM:PlayerCanHearPlayersVoice(listener, talker)
    return true, false
end

local BaseSpawn = GM.PlayerSpawn

function GM:PlayerSpawn(ply)
    BaseSpawn(self, ply)
    ply:SetGravity(1)
    ply:SetViewOffset(Vector(0, 0, 64))
    ply:SetViewOffsetDucked(Vector(0, 0, 28))

    if ply:Team() == TEAM_AZ then
        ply:SetModelScale(2)
        ply:SetViewOffset(Vector(0, 0, 1.7 * 64))
        ply:SetViewOffsetDucked(Vector(0, 0, 1.7 * 28))
        ply:SetNoCollideWithTeammates(true)
    else
        ply:SetModelScale(1)
        ply:SetViewOffset(Vector(0, 0, 64))
        ply:SetViewOffsetDucked(Vector(0, 0, 28))
        ply:SetNoCollideWithTeammates(false)
    end

    ply.GotInWater = false
end

local BaseChooseNextZombies = GM.ChooseNextZombies

function GM:ChooseNextZombies()
    self.AZCount = 1

    if #player.GetAll() >= 18 then
        self.AZCount = 2
    end

    return BaseChooseNextZombies(self)
end

local BaseSetModel = GM.PlayerSetModel

function GM:PlayerSetModel(ply)
    BaseSetModel(self, ply)

    if ply:Team() == TEAM_HUMAN then
        ply:SetPlayerColor(Vector(1, 1, 0))
    else
        ply:SetPlayerColor(Vector(0, 0, 0))
    end
end

util.AddNetworkString("ToggleViewModel")

net.Receive("ToggleViewModel", function(len, ply)
    ply:DrawViewModel(net.ReadBool())
end)
