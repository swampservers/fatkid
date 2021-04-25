-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Car"

-- TODO: Make this entity less garbagey (needs clientside interpolation for the movement)
function ENT:Initialize()
    if CLIENT then return end
    self:NextThink(CurTime())
    self:SetModel("models/props_vehicles/car004a.mdl")

    if math.random(1, 3) == 1 then
        self:SetModel("models/props_vehicles/car002a.mdl")
    end

    self:SetColor(Color(math.random(100, 255), math.random(100, 255), math.random(100, 255), 255))
    self:PhysicsInit(SOLID_VPHYSICS)
    self:SetMoveType(MOVETYPE_VPHYSICS)
    self:SetSolid(SOLID_VPHYSICS)
    local phys = self:GetPhysicsObject()
    phys:EnableMotion(false)
    phys:Wake()
    self.POS = self:GetPos()
end

function ENT:Touch(ent)
    if ent:IsPlayer() then
        if ent:Alive() then
            ent:Kill()
            ent:ChatPrint("Don't play in traffic!")
        end
    end
end

function ENT:PhysicsCollide(data, phys)
    local ent = data.HitEntity

    if ent:IsPlayer() then
        self:Touch(ent)
    end
end

function zzero(v)
    return Vector(v.x, v.y, 0)
end

function ENT:Think()
    if CLIENT then return end
    self.POS = self.POS or self:GetPos()

    if CurTime() - 1 > (self.LastTargetTime or 0) then
        self.LastTargetTime = CurTime()
        self.TARGET = nil

        if self.SEEKPLAYERY then
            for k, v in pairs(player.GetAll()) do
                if v:Alive() and v:GetPos().y > self.SEEKPLAYERY then
                    self.TARGET = v
                end
            end
        end
    end

    self:NextThink(CurTime())
    local nh = self.DEFAULTDIR * self.VELOCITY

    --and self.HEADING~=nil then
    if IsValid(self.TARGET) and self.TARGET:Alive() then
        local v = self.TARGET

        if v:GetPos():Distance(self.POS) < 72 then
            self:Touch(v)
        else
            nh = zzero(v:GetPos() - self.POS):GetNormalized() * self.VELOCITY
        end
    end

    if self.HEADING then
        nh:Rotate(Angle(0, -self.HEADING:Angle().y, 0))
        local a = nh:Angle().y

        if a > 180 then
            a = a - 360
        end

        local mt = 120 * FrameTime()

        if math.abs(a) > mt then
            a = mt * a / math.abs(a)
        end

        self.HEADING:Rotate(Angle(0, a, 0))
    else
        self.HEADING = nh
    end

    self.POS = self.POS + (self.HEADING * FrameTime())
    self:SetPos(self.POS)
    self:SetAngles(self.HEADING:Angle())

    --self:GetPhysicsObject():SetVelocity(self.HEADING)
    if (self.POS.x < self.MINX or self.POS.x > self.MAXX or self.POS.y < (self.SEEKPLAYERY or 0)) then
        self:Remove()
    end

    return true
end