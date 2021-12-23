-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
SWEP.PrintName = "Dodgeball"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true
SWEP.DrawWeaponInfoBox = true
SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false
SWEP.Slot = 0
SWEP.SlotPos = 2
SWEP.Purpose = "Push fat kid, kill skeletons"
SWEP.Instructions = "Primary: Throw\nSecondary: Drop"
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.ViewModel = Model("models/XQM/Rails/gumball_1.mdl")
SWEP.WorldModel = Model("models/XQM/Rails/gumball_1.mdl")
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Primary.ClipSize = -1
SWEP.Primary.Damage = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Damage = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

function SWEP:Initialize()
    self:SetHoldType("grenade")

    if SERVER then
        timer.Simple(0.05, function()
            if IsValid(self) and not IsValid(self.Owner) then
                self:OnDrop()
            end
        end)
    end
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1)
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    if SERVER then
        timer.Simple(0.1, function()
            if self and self.Owner then
                local p1 = self.Owner:GetPos() + self.Owner:GetCurrentViewOffset()
                local p2 = p1 + (self.Owner:GetAimVector() * 54)

                local tr = util.TraceLine({
                    start = p1,
                    endpos = p2,
                    mask = MASK_SOLID_BRUSHONLY
                })

                if tr.Hit then
                    p2 = tr.HitPos
                end

                self:Throw(p2 - (self.Owner:GetAimVector() * 18), (self.Owner:GetAimVector() * 900) + self.Owner:GetVelocity(), self.Owner)
            end
        end)
    end
end

function SWEP:SecondaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1)
    self.Owner:SetAnimation(PLAYER_ATTACK1)

    if SERVER then
        timer.Simple(0.05, function()
            if self and self.Owner then
                local p1 = self.Owner:GetPos() + self.Owner:GetCurrentViewOffset()
                local p2 = p1 + (self.Owner:GetAimVector() * 54)

                local tr = util.TraceLine({
                    start = p1,
                    endpos = p2,
                    mask = MASK_SOLID_BRUSHONLY
                })

                if tr.Hit then
                    p2 = tr.HitPos
                end

                self:Throw(p2 - (self.Owner:GetAimVector() * 18), self.Owner:GetVelocity(), self.Owner)
            end
        end)
    end
end

function SWEP:DrawWorldModel()
    render.SetColorModulation(1, 0, 0)
    local ply = self:GetOwner()

    if (IsValid(ply)) then
        local bn = "ValveBiped.Bip01_R_Hand"
        local bon = ply:LookupBone(bn) or 0
        local opos = self:GetPos()
        local oang = self:GetAngles()
        local bp, ba = ply:GetBonePosition(bon)

        if bp then
            opos = bp
        end

        if ba then
            oang = ba
        end

        opos = opos + oang:Right() * 12.5
        self:SetupBones()
        self:SetModelScale(0.8, 0)
        local mrt = self:GetBoneMatrix(0)

        if mrt then
            mrt:SetTranslation(opos)
            mrt:SetAngles(oang)
            self:SetBoneMatrix(0, mrt)
        end
    end

    self:DrawModel()
    render.SetColorModulation(1, 1, 1)
end

function SWEP:PreDrawViewModel(vm, wp, ply)
    render.SetColorModulation(1, 0, 0)
end

function SWEP:GetViewModelPosition(pos, ang)
    pos = pos + ang:Right() * 22
    pos = pos + ang:Up() * -15
    pos = pos + ang:Forward() * 25

    return pos, ang
end

function SWEP:PostDrawViewModel(vm, wp, ply)
    render.SetColorModulation(1, 1, 1)
end

function SWEP:OnDrop()
    self:Throw(self:GetPos(), Vector(0, 0, 0), nil)
end

function SWEP:Throw(pos, vel, owner)
    if CLIENT then return end
    if self.throwin then return end
    self.throwin = true
    self:Remove()
    e = ents.Create("dodgeball")
    e:SetPos(pos)
    e:Spawn()
    e:Activate()
    e:GetPhysicsObject():AddVelocity(vel)

    if owner then
        e.thrower = owner
        e:SetPhysicsAttacker(owner, 10000)
    end
end
