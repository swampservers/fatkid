-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
GM.Human = GM.Human or {}
GM.Zombie = GM.Zombie or {}
GM.AZ = GM.AZ or {}
GM.Human.ScoreboardName = "Human"
GM.Zombie.ScoreboardName = "Zombie"
GM.AZ.ScoreboardName = "Alpha Zombie"
GM.Human.ScoreboardColor = Color(240, 240, 240, 255)
GM.Zombie.ScoreboardColor = Color(160, 160, 160, 255)
GM.AZ.ScoreboardColor = Color(240, 120, 120, 255)
GM.UI = {}
GM.UI.AnnounceText = "DermaLarge"
GM.UI.LargeText = "Trebuchet24"
GM.UI.SmallText = "HudHintTextLarge"
GM.UI.BGColor = Color(0, 0, 0, 128)
GM.UI.TextColor = Color(255, 255, 255, 255)
GM.UI.BorderSize = 10

CreateConVar("cl_playercolor", "0.24 0.34 0.41", {FCVAR_ARCHIVE, FCVAR_USERINFO, FCVAR_DONTRECORD}, "The value is a Vector - so between 0-1 - not between 0-255")

CreateClientConVar("infection_" .. GM.variant .. "_human_hint", 1, true, false)
CreateClientConVar("infection_" .. GM.variant .. "_zombie_hint", 1, true, false)
CreateClientConVar("infection_" .. GM.variant .. "_az_hint", 1, true, false)
GM.Human.HintText = "You're a human. Shoot the infected. Stay alive at all costs!"
GM.Zombie.HintText = "You're a zombie. You will come back to life if you are killed. Destroy the survivors!"
GM.AZ.HintText = "You're an alpha zombie. Kill the humans. Spread the virus!"

net.Receive("RoundTimer", function()
    RoundTimer = net.ReadInt(16)
end)

net.Receive("Announce", function()
    AnnounceTime = CurTime()
    AnnounceText = net.ReadString()
end)

net.Receive("ToggleHint", function()
    local cvName = "infection_" .. GAMEMODE.variant .. "_" .. GAMEMODE:SelectPlayerConfig(LocalPlayer()).ShortName .. "_hint"
    local cv = GetConVar(cvName)
    cv:SetBool(not cv:GetBool())
end)

hook.Add("HUDPaint", "DrawHint", function()
    if not LocalPlayer():Alive() then return end
    local cfg = GAMEMODE:SelectPlayerConfig(LocalPlayer())
    local cvName = "infection_" .. GAMEMODE.variant .. "_" .. cfg.ShortName .. "_hint"
    local cv = GetConVar(cvName)
    if not cv:GetBool() then return end
    local msg = cfg.HintText .. " (press F1 to toggle hint)"
    surface.SetFont(GAMEMODE.UI.SmallText)
    local w, h = surface.GetTextSize(msg)
    draw.WordBox(GAMEMODE.UI.BorderSize, (ScrW() - w) / 2 - GAMEMODE.UI.BorderSize, ScrH() - (h + 3 * GAMEMODE.UI.BorderSize), msg, GAMEMODE.UI.SmallText, GAMEMODE.UI.BGColor, GAMEMODE.UI.TextColor)
end)

hook.Add("HUDPaint", "Announcement", function()
    if not AnnounceTime then return end
    local alpha = CurTime() - AnnounceTime
    if alpha > 5 then return end
    alpha = math.min(4 * alpha, 5 - alpha) * 255
    draw.DrawText(AnnounceText, GAMEMODE.UI.AnnounceText, ScrW() / 2 + 2, ScrH() * 0.3 + 2, ColorAlpha(Color(0, 0, 0), alpha), TEXT_ALIGN_CENTER)
    draw.DrawText(AnnounceText, GAMEMODE.UI.AnnounceText, ScrW() / 2, ScrH() * 0.3, ColorAlpha(GAMEMODE.UI.TextColor, alpha), TEXT_ALIGN_CENTER)
end)

hook.Add("HUDPaint", "RespawnTime", function()
    if LocalPlayer():Alive() then return end
    if RoundTimer <= 0 then return end
    local msg = GAMEMODE:TimeTilSpawn(LocalPlayer())

    if msg <= 0 then
        msg = "Click to Respawn"
    else
        msg = "Respawning in " .. FormatSeconds(msg)
    end

    surface.SetFont(GAMEMODE.UI.LargeText)
    local w, h = surface.GetTextSize(msg)
    draw.WordBox(GAMEMODE.UI.BorderSize, (ScrW() - w) / 2 - GAMEMODE.UI.BorderSize, ScrH() * 0.8, msg, GAMEMODE.UI.LargeText, GAMEMODE.UI.BGColor, GAMEMODE.UI.TextColor)
end)

hook.Add("HUDPaint", "OnePlayerOnline", function()
    if player.GetCount() > 1 then return end
    local msg = "Waiting for another player to join..."
    surface.SetFont(GAMEMODE.UI.LargeText)
    local w, h = surface.GetTextSize(msg)
    draw.WordBox(GAMEMODE.UI.BorderSize, (ScrW() - w) / 2 - GAMEMODE.UI.BorderSize, ScrH() * 0.8 - 2.5 * h, msg, GAMEMODE.UI.LargeText, GAMEMODE.UI.BGColor, GAMEMODE.UI.TextColor)
end)

hook.Add("HUDPaint", "RoundTime", function()
    if RoundTimer <= 0 then return end
    local msg = "Time Left: " .. FormatSeconds(RoundTimer)
    surface.SetFont(GAMEMODE.UI.LargeText)
    local w, h = surface.GetTextSize(msg)
    draw.WordBox(GAMEMODE.UI.BorderSize, ScrW() - (w + GAMEMODE.UI.BorderSize * 4), ScrH() * 0.8, msg, GAMEMODE.UI.LargeText, GAMEMODE.UI.BGColor, GAMEMODE.UI.TextColor)
end)

function FormatSeconds(secs)
    local mins = math.floor(secs / 60)
    secs = secs - mins * 60

    if secs < 10 then
        secs = "0" .. secs
    end

    return mins .. ":" .. secs
end
