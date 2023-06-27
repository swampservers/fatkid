-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
AddCSLuaFile()
GM.Human = GM.Human or {}
GM.Zombie = GM.Zombie or {}
GM.AZ = GM.AZ or {}

GM.Human.SpawnpointClasses = {"info_player_start", "info_player_human", "info_player_deathmatch", "info_player_combine", "info_player_counterterrorist", "info_player_allies", "gmod_player_start", "info_player_teamspawn", "ins_spawnpoint", "aoc_spawnpoint", "dys_spawn_point", "info_player_knight", "diprip_start_team_blue", "info_player_blue", "info_player_coop"}

GM.Zombie.SpawnpointClasses = {"info_player_zombie", "info_zombie_start", "info_player_rebel", "info_player_terrorist", "info_player_axis", "info_player_pirate", "info_player_viking", "diprip_start_team_red", "info_player_red"}

GM.AZ.SpawnpointClasses = {"info_player_az", "info_az_start", "info_player_oz", "info_oz_start", "info_player_zombiemaster"}

-- Makes a spawnpoint entity under a bunch of different classnames
ENT = {}
DEFINE_BASECLASS("base_anim")

if CLIENT then
    function ENT:Draw()
    end
end

for _, group in pairs({GM.Human, GM.Zombie, GM.AZ}) do
    for _, cls in pairs(group.SpawnpointClasses) do
        scripted_ents.Register(ENT, cls)
        print("Registering " .. cls)
    end
end

ENT = nil
