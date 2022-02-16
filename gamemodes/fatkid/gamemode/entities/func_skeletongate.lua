-- Retrieved from https://github.com/swampservers/fatkid
AddCSLuaFile()
ENT.Type = "brush"
ENT.PrintName = "func_skeletongate"
ENT.Author = "PYROTEKNIK"
ENT.Category = "PYROTEKNIK"
ENT.Spawnable = true
ENT.AdminSpawnable = true

--ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
function ENT:Initialize()
    self.Entity:PhysicsInit(SOLID_VPHYSICS)
    self.Entity:SetSolid(SOLID_VPHYSICS)
    self.Entity:SetMoveType(MOVETYPE_NONE)
    self:SetTrigger(true)
    self:SetCustomCollisionCheck(true)
end

function ENT:Touch(ply)
end


local function PlayerCanPassSkeletonGate(ply)
    return not ply:IsPlayer() or ply:Team() == 3
end

hook.Add("ShouldCollide", "func_skeletongate_collisionoverride", function(ent1, ent2)
    if ent1:GetClass() == "func_skeletongate" or ent2:GetClass() == "func_skeletongate" then
        if ent1:IsPlayer() and not PlayerCanPassSkeletonGate(ent1) then return true end
        if ent2:IsPlayer() and not PlayerCanPassSkeletonGate(ent2) then return true end

        return false
    end
end)

function ENT:Think()
end

function ENT:UpdateTransmitState()
    return TRANSMIT_ALWAYS
end

function ENT:DrawTranslucent()
    self:DrawModel()
end
