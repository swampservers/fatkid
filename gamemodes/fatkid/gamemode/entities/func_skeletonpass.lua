-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
ENT.Type = "brush"
ENT.PrintName = "Skeleton Barrier Brush"

-- Pushes non-skeleton players away
-- TODO: Figure out how to make it solid to non-skeleton players instead
function ENT:Initialize()
    self:SetTrigger(true)
    self:UseTriggerBounds(true)
end

function ENT:Touch(e)
    if not e:IsPlayer() then return end
    if e:Team() == TEAM_ZOMBIE then return end
    local v = e:GetPos() - self:OBBCenter()
    v = 100 * v / v:Length()
    e:SetVelocity(v - e:GetVelocity())
    e:SendLua("SkeletonAreaNotify=CurTime()+1.7")
end

if CLIENT then
    SkeletonAreaNotify = 0

    hook.Add("HUDPaint", "SkeletonAreaNotify", function()
        if SkeletonAreaNotify > CurTime() then
            draw.DrawText(GAMEMODE.SkeletonAreaMessage, "DermaLarge", ScrW() * 0.5, ScrH() * 0.55, Color(255, 0, 0, 255), TEXT_ALIGN_CENTER)
        end
    end)
end
