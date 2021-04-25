-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Dodgeball"

function ENT:Initialize()
    if CLIENT then return end
    self:SetModel("models/XQM/Rails/gumball_1.mdl")
    self:SetColor(Color(255, 0, 0, 255))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    phys:Wake()
    phys:SetMass(phys:GetMass() * 1.75)
    phys:SetMaterial("rubber")
    self.birth = CurTime()
end

function ENT:Use(activator, caller)
    if caller:IsPlayer() and caller:Team() == TEAM_HUMAN then
        self:Pickup(caller)
    end
end

function ENT:Touch(ent)
    if ent:IsPlayer() then
        if ent:Team() == TEAM_HUMAN then
            self:Pickup(ent)
        end

        if ent:Team() == TEAM_ZOMBIE then
            if IsValid(self.thrower) and self.thrower:Team() == TEAM_HUMAN then
                local dmginfo = DamageInfo()
                dmginfo:SetAttacker(self.thrower)
                dmginfo:SetInflictor(self)
                dmginfo:SetDamageForce(self:GetVelocity())
                dmginfo:SetDamage(1000)
                ent:TakeDamageInfo(dmginfo)
            else
                ent:Kill()
            end
        end
    end
end

function ENT:Pickup(ply)
    if ply == self.thrower and CurTime() - self.birth < 0.4 then return end
    if ply:HasWeapon("weapon_dodgeball") then return end
    if self.pickinup then return end
    self.pickinup = true
    self:Remove()
    ply:Give("weapon_dodgeball")
    --ply:SelectWeapon("weapon_dodgeball")
end

function ENT:PhysicsCollide(data, phys)
    local ent = data.HitEntity

    if ent:IsPlayer() then
        if ent:Team() == TEAM_HUMAN then
            self:Pickup(ent)
        end

        if ent:Team() == TEAM_AZ and data.Speed > 100 then
            if not ent.lastfatcry then
                ent.lastfatcry = 0
            end

            if ent.lastfatcry + 0.5 < CurTime() then
                ent:EmitSound("vo/npc/female01/pain01.wav")
                ent.lastfatcry = CurTime()
            end
        end
    else
        if data.Speed > 100 then
            self:EmitSound("physics/rubber/rubber_tire_impact_" .. ((data.Speed > 200) and "hard" or "soft") .. tostring(math.random(3)) .. ".wav")
        end
    end
end

hook.Add("EntityTakeDamage", "nophysicskill", function(target, dmg)
    if (dmg:GetInflictor():GetClass() == "dodgeball" or target:IsPlayer()) and dmg:GetDamageType() == 1 then return true end
end)

if CLIENT then
    killicon.AddAlias("dodgeball", "prop_physics")
end