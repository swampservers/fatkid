-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
GM.AZCount = 1 --How many players start as zombies
GM.EndIfNoHumans = true
GM.EndIfNoZombies = true
GM.EndIfNoAZs = true
GM.HumanWinMessage = "Skinny Kids win!"
GM.ZombieWinMessage = "Fat Kid wins!"
GM.NewZombieMessage = "is the new Fat Kid!"
GM.NewZombiesMessage = "are the new Fat Kids!"
GM.AZAbandonMessage = "The Fat Kid has abandoned the game!"
GM.Human.Health = 100
GM.Human.HealthRecharge = 1
GM.Human.HealthRechargeDelay = 2
GM.Human.InflictDamageScale = 1
GM.Human.TakeDamageScale = 1.6
GM.Human.Speed = 225
GM.Human.JumpPower = 200
GM.Human.SpawnWeapon = ""
GM.Human.CanPickupWeapons = true
GM.Human.ReceiveAmmo = true

GM.Human.PlayerModels = {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", "models/player/group01/male_03.mdl", "models/player/group01/male_04.mdl", "models/player/group01/male_05.mdl", "models/player/group01/male_06.mdl", "models/player/group01/male_07.mdl", "models/player/group01/male_08.mdl", "models/player/group01/male_09.mdl", "models/player/group01/female_01.mdl", "models/player/group01/female_02.mdl", "models/player/group01/female_03.mdl", "models/player/group01/female_04.mdl", "models/player/group01/female_05.mdl", "models/player/group01/female_06.mdl"}

GM.Human.HideHands = false
GM.Zombie.Health = 100
GM.Zombie.HealthRecharge = 2
GM.Zombie.HealthRechargeDelay = 1
GM.Zombie.InflictDamageScale = 1
GM.Zombie.TakeDamageScale = 5
GM.Zombie.HeadshotMultiplier = 2
GM.Zombie.Speed = 425 --Changes, see below
GM.Zombie.CrouchSpeedMod = 0.4
GM.Zombie.JumpPower = 240
GM.Zombie.SpawnWeapon = "weapon_crowbar"
GM.Zombie.CanPickupWeapons = false
GM.Zombie.ReceiveAmmo = false

GM.Zombie.PlayerModels = {"models/player/skeleton.mdl"}

GM.Zombie.HideHands = true
GM.AZ.Health = 999
GM.AZ.HealthRecharge = 1
GM.AZ.HealthRechargeDelay = 1
GM.AZ.InflictDamageScale = 1
GM.AZ.TakeDamageScale = 1 --Changes, see below
GM.AZ.HeadshotMultiplier = 1
GM.AZ.FallDamageMultiplier = 1
GM.AZ.Speed = 50 --Changes, see below
GM.AZ.CrouchSpeedMod = 0.6
GM.AZ.JumpPower = 180
GM.AZ.SpawnWeapon = "weapon_fatkid"
GM.AZ.CanPickupWeapons = false
GM.AZ.ReceiveAmmo = false

GM.AZ.PlayerModels = {"models/obese_male.mdl"}

GM.AZ.HideHands = true

GM.AmmoRegen = {
    {
        type = "Pistol",
        amount = 999,
        delay = 1
    },
    {
        type = "357",
        amount = 999,
        delay = 1
    },
    {
        type = "Buckshot",
        amount = 999,
        delay = 1
    },
    {
        type = "AR2",
        amount = 999,
        delay = 1
    },
    {
        type = "SMG1",
        amount = 999,
        delay = 1
    },
    {
        type = "Grenade",
        amount = 1,
        delay = 50,
        requireWeapon = "weapon_frag"
    },
    {
        type = "SMG1_Grenade",
        amount = 1,
        delay = 60,
        requireWeapon = "weapon_smg1"
    },
    {
        type = "RPG_Round",
        amount = 1,
        delay = 80,
        requireWeapon = "weapon_rpg"
    }
}

GM.MapWeapons = {
    {
        class = "weapon_crowbar",
        respawn = true,
        freeze = true
    },
    {
        class = "weapon_pistol",
        respawn = true,
        freeze = true
    },
    {
        class = "weapon_357",
        respawn = true,
        freeze = true
    },
    {
        class = "weapon_shotgun",
        respawn = true,
        freeze = true
    },
    {
        class = "weapon_ar2",
        respawn = true,
        freeze = true
    },
    {
        class = "weapon_frag",
        respawn = false,
        freeze = true
    },
    {
        class = "weapon_rpg",
        respawn = false,
        freeze = true
    },
    {
        class = "weapon_smg1",
        respawn = false,
        freeze = true
    }
}

GM.DropWeapons = {
    weapon_smg1 = DROPWEAPON_ALWAYS,
    weapon_rpg = DROPWEAPON_ALWAYS,
    weapon_frag = DROPWEAPON_ALWAYS,
    weapon_slam = DROPWEAPON_ALWAYS,
    weapon_dodgeball = DROPWEAPON_HELD,
    weapon_crowbar = DROPWEAPON_HELD,
    weapon_pistol = DROPWEAPON_HELD,
    weapon_357 = DROPWEAPON_HELD,
    weapon_shotgun = DROPWEAPON_HELD,
    weapon_ar2 = DROPWEAPON_HELD
}

GM.AZ.StartSpeed = 55
GM.AZ.EndSpeed = 105
GM.Zombie.StartSpeed = 425
GM.Zombie.EndSpeed = 500

hook.Add("Clock", "Fatkid_Balancing", function()
    local humans = 0

    for k, v in next, player.GetAll() do
        if v:Team() == TEAM_HUMAN then
            humans = humans + 1
        end
    end

    local progress = 1 - (RoundTimer / GAMEMODE.RoundDuration)
    GAMEMODE.BarricadeDamageMod = (2.0 / (math.max(humans, 3))) + 0.08
    GAMEMODE.AZ.TakeDamageScale = (GAMEMODE.FatKidDamageMod or 1) * ((0.55 / (math.max(humans, 3))) + 0.09)
    GAMEMODE.AZ.Speed = Lerp(progress, GAMEMODE.AZ.StartSpeed, GAMEMODE.AZ.EndSpeed)
    GAMEMODE.Zombie.Speed = Lerp(progress, GAMEMODE.Zombie.StartSpeed, GAMEMODE.Zombie.EndSpeed)

    for k, v in next, player.GetAll() do
        if v:Team() == TEAM_AZ then
            v:SetRunSpeed(GAMEMODE.AZ.Speed)
            v:SetWalkSpeed(GAMEMODE.AZ.Speed)
        end

        if v:Team() == TEAM_ZOMBIE then
            v:SetRunSpeed(GAMEMODE.Zombie.Speed)
            v:SetWalkSpeed(GAMEMODE.Zombie.Speed)
        end
    end
end)

function GM:PlayerCanHearPlayersVoice(listener, talker)
    return true, false
end

local BaseSpawn = GM.PlayerSpawn

function GM:PlayerSpawn(ply)
    BaseSpawn(self, ply)
    ply:SetGravity(1)
    ply:SetNoCollideWithTeammates(true)
    ply:SetCustomCollisionCheck(true)
    ply:ResetHull()
    ply:SetBloodColor(BLOOD_COLOR_RED)
    ply:SetCanWalk(ply:Team() ~= TEAM_AZ) -- Walk mode is faster than the fat kid

    if ply:Team() == TEAM_ZOMBIE then
        -- Skeletons crouch lower to enter tunnels (old solution; new solution is func_skeletonpass)
        ply:SetHullDuck(Vector(-16, -16, 0), Vector(16, 16, 30))
    end

    if ply:GetModel() == "models/player/skeleton.mdl" then
        ply:SetBloodColor(BLOOD_COLOR_MECH)
    end
end

local BaseSetModel = GM.PlayerSetModel

function GM:PlayerSetModel(ply)
    BaseSetModel(self, ply)

    --Fix the bones on the obese_male model and make him slightly smaller
    if ply:GetModel() == "models/obese_male.mdl" then
        ply:SetModelScale(0.95)
        ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_UpperArm"), Vector(1, 1, -1))
        ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_L_UpperArm"), Vector(1, 1, 1))
        ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"), Vector(0, 0, -1.5))
        ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Clavicle"), Vector(0, 0, 1.5))
    else
        ply:SetModelScale(1)
        ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_UpperArm"), Vector(0, 0, 0))
        ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_L_UpperArm"), Vector(0, 0, 0))
        ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_R_Clavicle"), Vector(0, 0, 0))
        ply:ManipulateBonePosition(ply:LookupBone("ValveBiped.Bip01_L_Clavicle"), Vector(0, 0, 0))
    end
end

GM.BarricadeBaseHealth = 1000
GM.BarricadeDamageMod = 1

GM.BarricadeDamageTypeMod = {
    [DMG_CLUB] = 1.2,
    [DMG_CRUSH] = 0,
    [DMG_BLAST] = 0.1 -- scale down explosive damage a lot because all boxes in the area take damage
    
}

hook.Add("MapSetup", "Fatkid_Barricades", function()
    GAMEMODE.Barricades = {}

    for k, v in next, ents.GetAll() do
        local name = v:GetName()

        if name:sub(1, 9) == "barricade" then
            if GAMEMODE.Barricades[name] == nil then
                GAMEMODE.Barricades[name] = {
                    health = GAMEMODE.BarricadeBaseHealth,
                    props = {}
                }
            end

            table.insert(GAMEMODE.Barricades[name].props, v)

            for i = 0, v:GetPhysicsObjectCount() - 1 do
                v:GetPhysicsObjectNum(i):EnableMotion(false)
            end
        end
    end
end)

hook.Add("EntityTakeDamage", "Fatkid_BarricadeDamage", function(target, dmg)
    local name = target:GetName()

    if name:sub(1, 9) == "barricade" then
        local att = dmg:GetAttacker()
        local inf = dmg:GetInflictor()
        if att:EntIndex() == 0 then return end

        if att:IsPlayer() then
            if GAMEMODE.Barricades[name] == nil then return end
            if att:Team() == TEAM_ZOMBIE then return true end
            if att:Team() == TEAM_AZ then return end
            dmg:ScaleDamage(GAMEMODE:SelectPlayerConfig(att).InflictDamageScale)

            if GAMEMODE.BarricadeDamageTypeMod[dmg:GetDamageType()] ~= nil then
                dmg:ScaleDamage(GAMEMODE.BarricadeDamageTypeMod[dmg:GetDamageType()])
            end

            GAMEMODE.Barricades[name].health = GAMEMODE.Barricades[name].health - (dmg:GetDamage() * GAMEMODE.BarricadeDamageMod)

            if GAMEMODE.Barricades[name].health <= 0 then
                for k, v in next, GAMEMODE.Barricades[name].props do
                    if IsValid(v) then
                        v:TakeDamage(500, Entity(0), Entity(0))

                        for i = 0, v:GetPhysicsObjectCount() - 1 do
                            v:GetPhysicsObjectNum(i):EnableMotion(true)
                        end
                    end
                end

                GAMEMODE.Barricades[name] = nil
            end
        end
        --attacker is not a player

        return true
    end
end)

hook.Add("EntityTakeDamage", "Fatkid_AntiGrenadeKill", function(target, dmg)
    local att = dmg:GetAttacker()

    if att:IsPlayer() then
        if att:Team() == TEAM_ZOMBIE and (not dmg:IsDamageType(DMG_CLUB)) then return true end
    end
end)

hook.Add("EntityTakeDamage", "Fatkid_BuffShotgun", function(target, dmg)
    if target:IsPlayer() and dmg:IsDamageType(DMG_BUCKSHOT) then
        dmg:ScaleDamage(1.25)
    end
end)

-- Prevent fatkid from carrying prop as shield
function GM:AllowPlayerPickup(ply, ent)
    return ply:Team() ~= TEAM_AZ
end