-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
GM.Human.ScoreboardName = "skinny kid "
GM.Zombie.ScoreboardName = "skeleton "
GM.AZ.ScoreboardName = "FAT KID"
GM.Human.HintText = "You're a skinny kid! Your goal is to survive the round. Break down barricades to get better weapons, and run from the Fat Kid!"
GM.Zombie.HintText = "You're a skeleton! You're fast but die easily. Use your speed to run down and kill the skinny kids!"
GM.AZ.HintText = "You're the Fat Kid! Your goal is to eat all the skinny kids. Left click to eat a player, and right click to stun nearby skinny kids!"

hook.Add("HUDPaint", "FatKidTip", function()
    if not LocalPlayer():Alive() then return end

    if IsValid(LocalPlayer():GetActiveWeapon()) then
    else
        return
    end

    if LocalPlayer():GetActiveWeapon():GetClass() == "weapon_fatkid" then
    else
        return
    end

    local cfg = GAMEMODE:SelectPlayerConfig(LocalPlayer())
    local cvName = "infection_" .. GAMEMODE.variant .. "_" .. cfg.ShortName .. "_hint"
    local cv = GetConVar(cvName)
    if not cv:GetBool() then return end
    msg = "Left Click: Eat  |  Right Click: Stun"
    surface.SetFont(GAMEMODE.UI.LargeText)
    local w, h = surface.GetTextSize(msg)
    local inc = h
    draw.WordBox(GAMEMODE.UI.BorderSize, ((ScrW() - w) / 2) - GAMEMODE.UI.BorderSize, ScrH() * 0.7, msg, GAMEMODE.UI.LargeText, GAMEMODE.UI.BGColor, GAMEMODE.UI.TextColor)
    msg = "Press F1 to hide this."
    surface.SetFont(GAMEMODE.UI.SmallText)
    local w, h = surface.GetTextSize(msg)
    draw.WordBox(GAMEMODE.UI.BorderSize, ((ScrW() - w) / 2) - GAMEMODE.UI.BorderSize, (ScrH() * 0.7) + (inc * 2), msg, GAMEMODE.UI.SmallText, GAMEMODE.UI.BGColor, GAMEMODE.UI.TextColor)
end)

--Give third person view to fat kid
hook.Add("CalcView", "FatKid_Thirdperson", function(ply, pos, angles, fov)
    if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_fatkid" then
        local dist = 60

        local trace = {
            start = pos,
            endpos = pos - (angles:Forward() * dist),
            mask = MASK_SOLID_BRUSHONLY
        }

        trace = util.TraceLine(trace)
        local view = {}

        if trace.Hit then
            view.origin = pos - (angles:Forward() * ((dist * trace.Fraction) - 5))
        else
            view.origin = pos - (angles:Forward() * dist)
        end

        view.angles = angles
        view.fov = fov

        return view
    end
end)

hook.Add("ShouldDrawLocalPlayer", "FatKid_DrawThirdPerson", function(ply)
    if IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon():GetClass() == "weapon_fatkid" then return true end
end)