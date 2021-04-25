-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
GM.Name = "Infection"
GM.Author = "swamponions (STEAM_0:0:38422842)"
GM.Email = "swampservers@gmail.com"
GM.Website = "https://github.com/swampservers/fatkid"
GM.variant = LoadInfectionGamemode or "base"
--Start by loading base gamemode
LoadFolder(GM.FolderName .. "/gamemode/game")
LoadEntityFolder(GM.FolderName .. "/gamemode/entities")

--Load selected game variant (if it doesn't exist, nothing happens)
if GM.variant ~= "base" then
    LoadFolder(GM.variant .. "/gamemode/game")
    LoadEntityFolder(GM.variant .. "/gamemode/entities")
    --Look for map-configs for the loaded game variant
    local _, maps = file.Find(GM.variant .. "/gamemode/maps/*", "LUA")
    --In case multiple folders match, sort so that the most specific names load last
    table.sort(maps, function(a, b) return string.len(a) < string.len(b) end)

    for k, v in next, maps do
        if string.find(game.GetMap():lower(), v) then
            LoadFolder(GM.variant .. "/gamemode/maps/" .. v)
        end
    end
end