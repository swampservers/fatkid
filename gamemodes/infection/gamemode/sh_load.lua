-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
-- Load folder recursively
function LoadFolder(folder)
    local files, folders = file.Find(folder .. "/*", "LUA")

    for k, v in ipairs(files) do
        local prefix = string.sub(v, 0, 2)
        v = folder .. "/" .. v

        if SERVER then
            if prefix == "cl" then
                AddCSLuaFile(v)
            elseif prefix == "sh" then
                AddCSLuaFile(v)
                include(v)
            else
                include(v)
            end
        else
            include(v)
        end
    end

    for k, v in ipairs(folders) do
        if v == "entities" then
            LoadEntityFolder(folder .. "/" .. v)
        else
            LoadFolder(folder .. "/" .. v)
        end
    end
end

-- Load a folder containing SENTS/SWEPS
function LoadEntityFolder(folder)
    local files, folders = file.Find(folder .. "/*", "LUA")

    -- Load single file entities
    for k, v in ipairs(files) do
        entName = string.Explode(".", v, false)[1] --remove file extension
        v = folder .. "/" .. v

        if SERVER then
            AddCSLuaFile(v)
        end

        _G.ENT = {}

        _G.SWEP = {
            Base = "weapon_base",
            Folder = folder .. "/" .. entName,
            Primary = {},
            Secondary = {}
        }

        include(v)

        if table.Count(_G.ENT) > 0 then
            scripted_ents.Register(_G.ENT, entName)
        end

        if table.Count(_G.SWEP) > 4 then
            weapons.Register(_G.SWEP, entName)
        end

        _G.ENT = nil
        _G.SWEP = nil
    end

    -- Load folder entities
    for k, v in ipairs(folders) do
        entName = v
        local subfiles, _ = file.Find(folder .. "/" .. v .. "/*", "LUA")
        _G.ENT = {}

        _G.SWEP = {
            Base = "weapon_base",
            Folder = folder .. "/" .. entName,
            Primary = {},
            Secondary = {}
        }

        for k2, v2 in ipairs(subfiles) do
            local prefix = string.sub(v2, 0, 2)
            v2 = folder .. "/" .. v .. "/" .. v2

            if SERVER then
                if prefix == "cl" then
                    AddCSLuaFile(v2)
                elseif prefix == "sh" then
                    AddCSLuaFile(v2)
                    include(v2)
                else
                    include(v2)
                end
            else
                include(v2)
            end
        end

        if table.Count(_G.ENT) > 0 then
            scripted_ents.Register(_G.ENT, entName)
        end

        if table.Count(_G.SWEP) > 4 then
            weapons.Register(_G.SWEP, entName)
        end

        _G.ENT = nil
        _G.SWEP = nil
    end
end
