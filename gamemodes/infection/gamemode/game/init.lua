-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
GM.Human = GM.Human or {}
GM.Zombie = GM.Zombie or {}
GM.AZ = GM.AZ or {}
--Default balancing settings
--See additional settings in sh_init.lua
GM.AZCount = 1 --How many players start as zombies
GM.AZWinsTimeout = false --If you use this, make sure GM.AZ.Lives > 0 so it's possible for humans to win
GM.EndIfNoHumans = true
GM.EndIfNoZombies = true
GM.EndIfNoAZs = false
GM.HumanWinMessage = "Humans win!"
GM.ZombieWinMessage = "Zombies win!"
GM.NewZombieMessage = "is the next Zombie!"
GM.NewZombiesMessage = "are the next Zombies!"
GM.AZAbandonMessage = "The infected have abandonded the game!"
GM.Human.Health = 100
GM.Human.HealthRecharge = 1
GM.Human.HealthRechargeDelay = 2
GM.Human.InflictDamageScale = 1
GM.Human.TakeDamageScale = 1
GM.Human.HeadshotMultiplier = 2
GM.Human.FallDamageMultiplier = 1
GM.Human.Speed = 250
GM.Human.CrouchSpeedMod = 0.6
GM.Human.JumpPower = 200
GM.Human.SpawnWeapon = "weapon_shotgun"
GM.Human.CanPickupWeapons = true
GM.Human.ReceiveAmmo = true

GM.Human.PlayerModels = {"models/player/group01/male_01.mdl", "models/player/group01/male_02.mdl", "models/player/group01/male_03.mdl", "models/player/group01/male_04.mdl", "models/player/group01/male_05.mdl", "models/player/group01/male_06.mdl", "models/player/group01/male_07.mdl", "models/player/group01/male_08.mdl", "models/player/group01/male_09.mdl", "models/player/group01/female_01.mdl", "models/player/group01/female_02.mdl", "models/player/group01/female_03.mdl", "models/player/group01/female_04.mdl", "models/player/group01/female_05.mdl", "models/player/group01/female_06.mdl"}

GM.Human.HideHands = false
GM.Human.Lives = 1 --One life, then become a zombie
GM.Zombie.Health = 60
GM.Zombie.HealthRecharge = 5
GM.Zombie.HealthRechargeDelay = 1
GM.Zombie.InflictDamageScale = 1
GM.Zombie.TakeDamageScale = 1
GM.Zombie.HeadshotMultiplier = 2
GM.Zombie.FallDamageMultiplier = 0
GM.Zombie.Speed = 300
GM.Zombie.CrouchSpeedMod = 0.6
GM.Zombie.JumpPower = 250
GM.Zombie.SpawnWeapon = "weapon_crowbar"
GM.Zombie.CanPickupWeapons = false
GM.Zombie.ReceiveAmmo = false

GM.Zombie.PlayerModels = {"models/player/zombie_classic.mdl", "models/player/zombie_fast.mdl"}

GM.Zombie.HideHands = false
GM.Zombie.Lives = 0 --Infinite lives (finite zombie lives TODO)

--Make AZ match Zombie
for k, v in next, GM.Zombie do
    GM.AZ[k] = GM.AZ[k] or v
end

GM.AmmoRegen = {
    {
        type = "Buckshot",
        amount = 999,
        delay = 1
    },
    {
        type = "RPG_Round",
        amount = 1,
        delay = 50,
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
        class = "weapon_*",
        respawn = false,
        freeze = true
    }
}

DROPWEAPON_HELD = 1 --weapon should drop only if it is held, and cleanup when the player respawns
DROPWEAPON_ALWAYS = 2 --weapon should always drop, and stick around (for valuable weapons)

GM.DropWeapons = {
    weapon_crowbar = DROPWEAPON_HELD,
    weapon_shotgun = DROPWEAPON_ALWAYS
}

util.AddNetworkString("RoundTimer")
util.AddNetworkString("Announce")
util.AddNetworkString("ToggleHint")

function GM:ShowHelp(ply)
    net.Start("ToggleHint")
    net.Send(ply)
end

function Announce(str)
    print("Announcing: " .. str)
    net.Start("Announce")
    net.WriteString(str)
    net.Broadcast()
end

concommand.Add("nextround", function(ply)
    if not IsValid(ply) or ply:IsAdmin() then
        RoundTimer = 1
    end
end)

concommand.Add("resetmap", function(ply)
    if not IsValid(ply) or ply:IsAdmin() then
        RunConsoleCommand("changelevel", game.GetMap())
    end
end)

if not GM.LastClockAt then
    GM.LastClockAt = SysTime()
end

function GM:PlayerJoinTeam(ply, teamid)
    ply:SetTeam(teamid)
    ply.Lives = self:SelectPlayerConfig(ply).Lives
end

function GM:PlayerInitialSpawn(ply)
    ply:PrintMessage(HUD_PRINTCENTER, "Welcome to " .. string.upper(self.Name) .. "!")
    self:PlayerJoinTeam(ply, TEAM_ZOMBIE)

    timer.Simple(0.1, function()
        if RoundTimer > (self.RoundDuration - self.InfectedSpawnDelay) then
            ply:Kill()
        end
    end)
end

function GM:PlayerSpawn(ply)
    ply:UnSpectate()
    local config = self:SelectPlayerConfig(ply)
    ply:SetHealth(config.Health)
    ply:SetMaxHealth(config.Health)
    ply:SetRunSpeed(config.Speed)
    ply:SetWalkSpeed(config.Speed)
    ply:SetJumpPower(config.JumpPower)

    -- TODO why is this necessary
    timer.Simple(0, function()
        ply:SetJumpPower(config.JumpPower)
    end)

    ply:SetCrouchedWalkSpeed(config.CrouchSpeedMod)
    hook.Run("PlayerSetModel", ply)
    ply:SetupHands()

    if config.HideHands then
        ply:GetHands():SetMaterial("models/effects/vol_light001")
    end

    hook.Run("PlayerLoadout", ply)
end

function GM:PlayerSetModel(ply)
    local config = self:SelectPlayerConfig(ply)
    ply:SetModel(config.PlayerModels[math.random(#config.PlayerModels)])

    if ply:Team() == TEAM_HUMAN then
        --Use a player's chosen color, unless they're default blue, in which case choose a random color
        local plycolor = Vector(ply:GetInfo("cl_playercolor"))

        if plycolor:Distance(Vector("0.24 0.34 0.41")) < 0.02 then
            ply:SetPlayerColor(Vector(math.Rand(0, 1), math.Rand(0, 1), math.Rand(0, 1)))
        else
            ply:SetPlayerColor(plycolor)
        end
    else
        ply:SetPlayerColor(Vector(1, 1, 1))
    end
end

function GM:PlayerLoadout(ply)
    local class = self:SelectPlayerConfig(ply).SpawnWeapon

    if class ~= nil and class ~= "" then
        ply:Give(class)
    end
end

hook.Add("MapSetup", "Infection_SpawnPoints", function()
    local spawnTypes = {"info_player_start", "info_player_human", "info_player_deathmatch", "info_player_combine", "info_player_counterterrorist", "info_player_allies", "gmod_player_start", "info_player_teamspawn", "ins_spawnpoint", "aoc_spawnpoint", "dys_spawn_point", "info_player_knight", "diprip_start_team_blue", "info_player_blue", "info_player_coop"}

    GAMEMODE.Human.Spawns = ents.FindByClasses(spawnTypes)

    spawnTypes = {"info_player_zombie", "info_zombie_start", "info_player_rebel", "info_player_terrorist", "info_player_axis", "info_player_pirate", "info_player_viking", "diprip_start_team_red", "info_player_red"}

    GAMEMODE.Zombie.Spawns = ents.FindByClasses(spawnTypes)

    spawnTypes = {"info_player_az", "info_az_start", "info_player_oz", "info_oz_start", "info_player_zombiemaster"}

    GAMEMODE.AZ.Spawns = ents.FindByClasses(spawnTypes)
    table.Shuffle(GAMEMODE.Human.Spawns)
    table.Shuffle(GAMEMODE.Zombie.Spawns)
    table.Shuffle(GAMEMODE.AZ.Spawns)

    if #GAMEMODE.Zombie.Spawns == 0 then
        GAMEMODE.Zombie.Spawns = GAMEMODE.Human.Spawns
    end

    if #GAMEMODE.AZ.Spawns == 0 then
        GAMEMODE.AZ.Spawns = GAMEMODE.Zombie.Spawns
    end

    SpawnIndex = 0
end)

hook.Add("MapSetup", "Infection_WeaponRespawnSetup", function()
    local entList = {}

    for k, v in next, GAMEMODE.MapWeapons do
        for k2, v2 in next, ents.FindByClass(v.class) do
            if not IsValid(v2:GetOwner()) and not table.HasValue(entList, v2) then
                if v.freeze then
                    v2:GetPhysicsObject():EnableMotion(false)
                end

                if v.respawn and v2:GetName() ~= "norespawn" then
                    table.insert(entList, v2)
                end
            end
        end
    end

    GAMEMODE.RespawningWeaponCache = {}

    for k, v in next, entList do
        table.insert(GAMEMODE.RespawningWeaponCache, {
            class = v:GetClass(),
            pos = v:GetPos(),
            ang = v:GetAngles(),
            freeze = (not v:GetPhysicsObject():IsMotionEnabled()),
            lastIndex = v:EntIndex()
        })
    end
end)

hook.Add("Clock", "Infection_WeaponRespawn", function()
    if not GAMEMODE.RespawningWeaponCache then return end

    for k, v in next, GAMEMODE.RespawningWeaponCache do
        local last = ents.GetByIndex(v.lastIndex)

        if not IsValid(last) or IsValid(last:GetOwner()) then
            e = ents.Create(v.class)
            e:SetPos(v.pos)
            e:SetAngles(v.ang)
            e:Spawn()
            e:Activate()

            if v.freeze then
                e:GetPhysicsObject():EnableMotion(false)
            end

            v.lastIndex = e:EntIndex()
        end
    end
end)

function GM:PlayerSelectSpawn(ply)
    local spawns = self:SelectPlayerConfig(ply).Spawns

    if spawns == nil or #spawns == 0 then
        print("Error finding spawn for " .. ply:Nick())

        return table.Random(ents.FindByClass("info_player_start"))
    end

    local spawn = nil

    for i = 0, 10 do
        SpawnIndex = SpawnIndex + 1
        spawn = spawns[(SpawnIndex % #spawns) + 1]
        if hook.Run("IsSpawnpointSuitable", ply, spawn, false) then return spawn end
    end

    return spawn
end

--PlayerLoadout will NOT override this function when giving loadout
function GM:PlayerCanPickupWeapon(ply, wep)
    local config = self:SelectPlayerConfig(ply)
    if config.CanPickupWeapons or wep:GetClass() == config.SpawnWeapon then return not ply:HasWeapon(wep:GetClass()) end

    return false
end

function GM:DoPlayerDeath(ply, attacker, dmginfo)
    ply.DeathTime = CurTime()
    ply:SendLua("LocalPlayer().DeathTime=" .. tostring(ply.DeathTime))
    ply:CreateRagdoll()

    if self.KeepScore then
        ply:AddDeaths(1)

        if IsValid(attacker) and attacker:IsPlayer() and attacker ~= ply then
            attacker:AddFrags(1)
        end
    end

    ply:Spectate(OBS_MODE_CHASE)
    ply:SpectateEntity(ply:GetRagdollEntity())
end

hook.Add("DoPlayerDeath", "Infection_DropWeapons", function(ply)
    local v = ply:GetActiveWeapon()
    if not IsValid(v) then return end

    if GAMEMODE.DropWeapons[v:GetClass()] then
        GAMEMODE:DeathDropWeapon(ply, v, GAMEMODE.DropWeapons[v:GetClass()])
    end

    for k, v in next, ply:GetWeapons() do
        if GAMEMODE.DropWeapons[v:GetClass()] == DROPWEAPON_ALWAYS then
            GAMEMODE:DeathDropWeapon(ply, v, DROPWEAPON_ALWAYS)
        end
    end
end)

hook.Add("PlayerSpawn", "Infection_DroppedWeaponCleanup", function(ply)
    if ply.CleanupDroppedWeapon and IsValid(ply.CleanupDroppedWeapon) and not IsValid(ply.CleanupDroppedWeapon:GetOwner()) then
        ply.CleanupDroppedWeapon:Remove()
    end
end)

function GM:DeathDropWeapon(ply, ent, flag)
    ply:DropWeapon(ent)

    if IsValid(ent:GetPhysicsObject()) then
        ent:GetPhysicsObject():SetVelocity(ply:GetVelocity() * 0.6)
        ent:GetPhysicsObject():SetMaterial("default_silent")
    end

    if flag == DROPWEAPON_HELD then
        --NOTE: If a player leaves without respawning the dropped weapon will stay until the end of round
        ply.CleanupDroppedWeapon = ent
    end
end

function GM:PostPlayerDeath(ply)
    if RoundTimer > 0 then
        --Delay so killfeed shows them dying as the old team
        timer.Simple(0.2, function()
            if not IsValid(ply) then return end
            ply.Lives = ply.Lives - 1
            if ply.Lives ~= 0 then return end

            if ply:Alive() then
                ply:Kill()
            end

            self:PlayerJoinTeam(ply, TEAM_ZOMBIE)
        end)
    end
end

function GM:PlayerDeathThink(ply)
    if self:TimeTilSpawn(ply) > 0 then return end

    if ply:IsBot() or ply:KeyPressed(IN_ATTACK) or ply:KeyPressed(IN_ATTACK2) or ply:KeyPressed(IN_JUMP) then
        ply:Spawn()
    end
end

function GM:Tick()
    if math.floor(SysTime()) > self.LastClockAt then
        self.LastClockAt = math.max(self.LastClockAt + 1, SysTime() - 1)
        self:Clock()
    end
end

-- Periodic every-second updates
function GM:Clock()
    RoundTimer = RoundTimer - 1

    if RoundTimer == 0 then
        hook.Run("RoundEnd")
    end

    if RoundTimer == math.floor(self.BetweenRoundDuration * -0.5) then
        hook.Run("RoundSetup")
    end

    if RoundTimer <= -self.BetweenRoundDuration then
        RoundTimer = self.RoundDuration
        hook.Run("RoundStart")
    end

    net.Start("RoundTimer")
    net.WriteInt(RoundTimer, 16)
    net.Broadcast()
    hook.Call("Clock", nil)
end

hook.Add("Clock", "Infection_PlayerHealth", function()
    for k, v in next, player.GetAll() do
        local config = GAMEMODE:SelectPlayerConfig(v)

        if RoundTimer % config.HealthRechargeDelay == 0 then
            v:SetHealth(math.min(v:Health() + config.HealthRecharge, config.Health))
        end
    end
end)

hook.Add("Clock", "Infection_RoundEnd", function()
    if CurTime() < 15 then return end
    if RoundTimer <= 1 then return end
    if #player.GetAll() < 2 then return end
    local noHuman = GAMEMODE.EndIfNoHumans
    local noZombie = GAMEMODE.EndIfNoZombies
    local noAZ = GAMEMODE.EndIfNoAZs

    for k, v in next, player.GetAll() do
        if v:Team() == TEAM_HUMAN then
            noHuman = false
        elseif v:Team() == TEAM_ZOMBIE then
            noZombie = false
        elseif v:Team() == TEAM_AZ then
            noAZ = false
            noZombie = false
        end
    end

    if noHuman or noZombie or noAZ then
        --Next clock will end round
        RoundTimer = 1
    end
end)

hook.Add("Clock", "Infection_PlayerAmmo", function()
    for k, v in next, player.GetAll() do
        local config = GAMEMODE:SelectPlayerConfig(v)

        if config.ReceiveAmmo then
            for _, a in next, GAMEMODE.AmmoRegen do
                if RoundTimer % a.delay == 0 then
                    if a.requireWeapon == nil or v:HasWeapon(a.requireWeapon) then
                        v:SetAmmo(math.min(v:GetAmmoCount(a.type) + a.amount, 999), a.type)
                    end
                end
            end
        end
    end
end)

function GM:RoundEnd()
    local HumansWin = self.AZWinsTimeout
    local TargetTeam = self.AZWinsTimeout and TEAM_AZ or TEAM_HUMAN

    for k, v in next, player.GetAll() do
        if v:Alive() then
            if v:Team() == TargetTeam then
                HumansWin = not self.AZWinsTimeout
            end

            v:Kill()
        end
    end

    hook.Run("RoundResult", HumansWin)
end

--Perhaps add "zombies abandoned" round end type?
function GM:RoundResult(HumansWin)
    if HumansWin then
        Announce("Round over! " .. self.HumanWinMessage)
    else
        Announce("Round over! " .. self.ZombieWinMessage)
    end
end

function GM:InitPostEntity()
    hook.Run("MapSetup")
end

function GM:PostCleanupMap()
    hook.Run("MapSetup")
end

function GM:RoundSetup()
    game.CleanUpMap() --use MapSetup hook for functions that run after map is cleaned up
    self.AZs = self:ChooseNextZombies()

    if #self.AZs > 1 then
        local st = self.AZs[1]:Nick() .. " and " .. self.AZs[2]:Nick()
        local i = 3

        while i <= #self.AZs do
            st = self.AZs[i]:Nick() .. ", " .. st
            i = i + 1
        end

        Announce(st .. " " .. self.NewZombiesMessage)
    elseif #self.AZs == 1 then
        Announce(self.AZs[1]:Nick() .. " " .. self.NewZombieMessage)
    end
end

function GM:ChooseNextZombies()
    local players = table.Copy(player.GetAll())
    local zombies = {}

    while #zombies < self.AZCount and #players > 1 do
        table.insert(zombies, table.remove(players, math.random(#players)))
    end

    --Set teams now to show in scoreboard
    for k, v in next, player.GetAll() do
        if table.HasValue(zombies, v) then
            if self.UseAZ then
                self:PlayerJoinTeam(v, TEAM_AZ)
            else
                self:PlayerJoinTeam(v, TEAM_ZOMBIE)
            end
        else
            self:PlayerJoinTeam(v, TEAM_HUMAN)
        end
    end

    return zombies
end

function GM:RoundStart()
    local AZleft = #self.AZs > 0

    for k, v in next, player.GetAll() do
        if table.HasValue(self.AZs, v) then
            AZleft = false
        end
    end

    if AZleft then
        Announce(self.AZAbandonMessage)
        RoundTimer = 0

        return
    end

    for k, v in next, player.GetAll() do
        --Set teams again to be sure
        if v:Alive() then
            v:Kill()
        end

        if table.HasValue(self.AZs, v) then
            if self.UseAZ then
                self:PlayerJoinTeam(v, TEAM_AZ)
            else
                self:PlayerJoinTeam(v, TEAM_ZOMBIE)
            end

            foundAZ = true

            if self.DelayAZSpawn then
                timer.Simple(self.InfectedSpawnDelay, function()
                    if RoundTimer <= (self.RoundDuration - self.InfectedSpawnDelay) + 1 and RoundTimer > 0 then
                        v:Spawn()
                    end
                end)
            else
                v:Spawn()
            end
        else
            self:PlayerJoinTeam(v, TEAM_HUMAN)
            v:Spawn()
        end
    end
end

function GM:EntityTakeDamage(target, dmg)
    local att = dmg:GetAttacker()
    local inf = dmg:GetInflictor()

    -- Patch the crowbar damage from a gmod update...
    if IsValid(att) and att:IsPlayer() and IsValid(att:GetActiveWeapon()) and att:GetActiveWeapon():GetClass() == "weapon_crowbar" and dmg:GetDamageType() == DMG_CLUB and dmg:GetDamage() == 10 then
        dmg:SetDamage(25)
    end

    if att:IsPlayer() then
        dmg:ScaleDamage(self:SelectPlayerConfig(att).InflictDamageScale)
    end

    if target:IsPlayer() then
        dmg:ScaleDamage(self:SelectPlayerConfig(target).TakeDamageScale)

        if target:Team() == TEAM_HUMAN then
            --todo do this smarter
            local lms = true

            for i, v in ipairs(player.GetAll()) do
                if v:Team() == TEAM_HUMAN and v ~= target then
                    lms = false
                    break
                end
            end

            if lms then
                dmg:ScaleDamage(GAMEMODE.LastManStandingDamageScale)
            end
        end

        if dmg:IsFallDamage() then
            dmg:ScaleDamage(self:SelectPlayerConfig(target).FallDamageMultiplier)
        end
    end
end

function GM:ScalePlayerDamage(ply, hitgroup, dmg)
    if hitgroup == HITGROUP_HEAD then
        dmg:ScaleDamage(self:SelectPlayerConfig(ply).HeadshotMultiplier)
    end
end