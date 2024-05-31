-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
SWEP.PrintName = "Fat Kid"
SWEP.Purpose = "Eat skinny kids"
SWEP.Instructions = "Primary: Eat\nSecondary: Stun"
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.DrawWeaponInfoBox = true
SWEP.ViewModelFOV = 85
SWEP.ViewModelFlip = false
SWEP.Slot = 0
SWEP.SlotPos = 3
SWEP.Spawnable = false
SWEP.AdminSpawnable = false
SWEP.ViewModel = Model("models/weapons/c_arms.mdl")
--random model to give it appearance if it is dropped somehow
SWEP.WorldModel = Model("models/props_junk/MetalBucket01a.mdl")
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
    self:SetHoldType("normal")
end

function SWEP:PrimaryAttack()
    self:SetNextPrimaryFire(CurTime() + 1) --0.38)

    --This is necessary to make the attack animation show in third person
    if CLIENT and IsFirstTimePredicted() then
        playAttack = true

        timer.Create("PrimaryAttackAnim", 0.01, 20, function()
            if IsValid(self) and IsValid(self.Owner) and playAttack then
                if self:GetHoldType() == "duel" then
                    timer.Simple(0.01, function()
                        if IsValid(self) and IsValid(self.Owner) then
                            self.Owner:SetAnimation(PLAYER_ATTACK1)
                        end
                    end)

                    playAttack = false
                end
            end
        end)
    end

    if SERVER then
        self:SetHoldType("duel")
        self.Owner:SetAnimation(PLAYER_ATTACK1)

        timer.Simple(0.3, function()
            if IsValid(self.Owner) then
                self:SetHoldType("normal")
            end
        end)

        local center = self.Owner:GetPos() + self.Owner:GetAimVector() * 48
        local closestDist = 1000
        local ply = nil

        for k, v in ipairs(ents.FindInSphere(center, 50)) do
            if v:IsPlayer() and v ~= self.Owner and v:Alive() and GAMEMODE:PlayerShouldTakeDamage(v, self.Owner) then
                local dist = v:GetPos():Distance(self.Owner:GetPos())

                if dist < closestDist then
                    ply = v
                    closestDist = dist
                end
            end
        end

        if ply then
            local wsp = ply:GetWalkSpeed()
            --if wsp>1 then v.properWSP = wsp end
            local rsp = ply:GetRunSpeed()
            --if rsp>1 then v.properRSP = rsp end
            ply:SetWalkSpeed(1)
            ply:SetRunSpeed(1)

            --In case the fat kid is killed mid-feast
            timer.Simple(0.34, function()
                if ply:Alive() then
                    ply:SetWalkSpeed(ply.properWSP or 1)
                    ply:SetRunSpeed(ply.properRSP or 1)
                end
            end)

            local healthLoss = math.floor(ply:Health() / 15)

            timer.Create("FatKidEat" .. tostring(ply:EntIndex()), .02, 15, function()
                if IsValid(ply) and ply:Alive() and IsValid(self.Owner) and self.Owner:Alive() then
                    for i = 0, 4 do
                        --blood decal
                        local st = ply:GetPos() + Vector(0, 0, 40)
                        local add = Vector(math.random(-100, 100), math.random(-100, 100), math.random(-500, 0))

                        local tr = util.TraceLine({
                            start = st,
                            endpos = st + add,
                            mask = MASK_SOLID_BRUSHONLY
                        })

                        if tr.Hit then
                            local Pos1 = tr.HitPos + tr.HitNormal
                            local Pos2 = tr.HitPos - tr.HitNormal
                            local Bone = tr.Entity:GetPhysicsObjectNum(tr.PhysicsBone or 0)

                            if not Bone then
                                Bone = tr.Entity
                            end

                            util.Decal("Blood", Pos1, Pos2)
                        end
                    end

                    --2 blood effects
                    local effectdata = EffectData()
                    effectdata:SetOrigin(ply:GetPos() + Vector(0, 0, 40))
                    effectdata:SetNormal(VectorRand())
                    effectdata:SetMagnitude(1)
                    effectdata:SetScale(5)
                    effectdata:SetColor(BLOOD_COLOR_RED)
                    effectdata:SetFlags(3)
                    util.Effect("BloodImpact", effectdata, true, true)
                    util.Effect("bloodspray", effectdata, true, true)

                    --drain their health
                    if ply:Health() > healthLoss then
                        ply:SetHealth(ply:Health() - healthLoss)
                    end
                end
            end)

            self.Owner:EmitSound("physics/flesh/flesh_bloody_break.wav")
            ply:EmitSound("ambient/creatures/town_child_scream1.wav")

            timer.Simple(0.3, function()
                if IsValid(ply) and ply:Alive() and IsValid(self.Owner) and self.Owner:Alive() then
                    ply:SetModel("models/player/skeleton.mdl")
                    local dmginfo = DamageInfo()
                    dmginfo:SetAttacker(self.Owner)
                    dmginfo:SetInflictor(self)
                    dmginfo:SetDamageForce(Vector(0, 0, 0))
                    dmginfo:SetDamage(1000)
                    ply:TakeDamageInfo(dmginfo)
                    -- Give 10% of missing health
                    self.Owner:SetHealth(self.Owner:Health() + math.floor((self.Owner:GetMaxHealth() - self.Owner:Health()) * 0.1))
                end
            end)
        else
            --this bit lets us eat breakable props like boxes
            for k, v in ipairs(ents.FindInSphere(center, 50)) do
                if v:GetClass():find("prop") then
                    local dist = v:GetPos():Distance(self.Owner:GetPos())

                    if dist < closestDist then
                        ply = v
                        closestDist = dist
                    end
                end
            end

            if ply then
                if ply.TakeDamage then
                    timer.Simple(0.01, function()
                        ply:TakeDamage(500, self.Owner, self)
                    end)
                end
            end
        end
    end
end

function SWEP:SecondaryAttack()
    self:SetNextSecondaryFire(CurTime() + 3)

    --This is necessary to make the attack animation show in third person
    if CLIENT and IsFirstTimePredicted() then
        playAttack = true

        timer.Create("PrimaryAttackAnim", 0.01, 20, function()
            if IsValid(self) and IsValid(self.Owner) and playAttack then
                if self:GetHoldType() == "melee" then
                    timer.Simple(0.01, function()
                        self.Owner:SetAnimation(PLAYER_ATTACK1)
                    end)

                    playAttack = false
                end
            end
        end)
    end

    if SERVER then
        self.Owner:EmitSound("weapons/physcannon/energy_sing_flyby1.wav", 75, 100, 0.25)
        self:SetHoldType("melee")
        self.Owner:SetAnimation(PLAYER_ATTACK1)

        timer.Simple(0.4, function()
            if IsValid(self) then
                self:SetHoldType("normal")
            end
        end)

        timer.Simple(0.3, function()
            if IsValid(self) and IsValid(self.Owner) and self.Owner:Alive() then
                local v = self.Owner:EyeAngles():Forward()
                v = Vector(v.x, v.y, 0):GetNormalized()
                SlamCenter = self.Owner:GetPos() + v * 90 + Vector(0, 0, 1)
                SlamCenter = FindFloor(SlamCenter)
                --do raycast to prevent going thru celing
                local ForceCenter = self.Owner:GetPos() - Vector(0, 0, 100)

                for k, v in ipairs(ents.FindInSphere(SlamCenter, 100)) do
                    if v:IsPlayer() and v ~= self.Owner then
                        if v:Team() == TEAM_HUMAN then
                            v:SetPos(v:GetPos() + Vector(0, 0, 1))
                            v:SetVelocity(Vector(0, 0, 130) - v:GetVelocity())
                            v:SetGravity(0.25)
                            local wsp = v:GetWalkSpeed()

                            if wsp > 1 then
                                v.properWSP = wsp
                            end

                            local rsp = v:GetRunSpeed()

                            if rsp > 1 then
                                v.properRSP = rsp
                            end

                            v:SetWalkSpeed(1)
                            v:SetRunSpeed(1)

                            timer.Simple(1.25, function()
                                v:SetGravity(1)

                                if v:Alive() then
                                    v:SetWalkSpeed(v.properWSP or 1)
                                    v:SetRunSpeed(v.properRSP or 1)
                                end
                            end)
                        else
                            v:SetPos(v:GetPos() + Vector(0, 0, 1))
                            v:SetVelocity((v:GetPos() - ForceCenter):GetNormalized() * 150)
                        end
                    end

                    if not v:IsPlayer() then
                        if v.TakeDamage then
                            v:TakeDamage(500, self.Owner, self)
                        end

                        if IsValid(v) then
                            v:SetPhysicsAttacker(self.Owner)
                            FatKidSlamForce(v, SlamCenter, ForceCenter, self.Owner:GetPos())
                        end

                        if v:GetClass() == "dodgeball" then
                            local effectdata = EffectData()
                            effectdata:SetOrigin(v:GetPos())
                            util.Effect("cball_explode", effectdata, true, true)
                            v:Remove()
                        end
                    end
                end

                net.Start("FatKidSlam")
                net.WriteVector(SlamCenter)
                net.WriteVector(ForceCenter)
                net.WriteVector(self.Owner:GetPos())
                net.Broadcast()
            end
        end)
    end
end

function SWEP:Deploy()
    self.Owner:DrawViewModel(false)
end

function SWEP:DrawWorldModel()
    if not IsValid(self.Owner) then
        self:DrawModel()
    end
end

if SERVER then
    util.AddNetworkString("FatKidSlam")
else
    net.Receive("FatKidSlam", function()
        local SlamCenter = net.ReadVector()
        local ForceCenter = net.ReadVector()
        local PlayerPos = net.ReadVector()
        sound.Play("npc/scanner/cbot_energyexplosion1.wav", SlamCenter + Vector(0, 0, 10))
        util.ScreenShake(SlamCenter, 15, 10, 0.7, 500)

        --water effect to show boundary
        for i = 0, 340, 20 do
            local effectdata = EffectData()
            effectdata:SetOrigin(FindFloor(SlamCenter + Vector(math.sin(math.rad(i)) * 95, math.cos(math.rad(i)) * 95, 0)))
            effectdata:SetScale(5)
            effectdata:SetFlags(0)
            util.Effect("watersplash", effectdata, true, true)
        end

        --particles
        for i = 0, 315, 45 do
            for j = 1, 2 do
                local effectdata = EffectData()
                effectdata:SetOrigin(FindFloor(SlamCenter + Vector(math.sin(math.rad(i)) * 45 * j, math.cos(math.rad(i)) * 45 * j, 0)))
                util.Effect("GlassImpact", effectdata, true, true)
            end
        end

        --flash of light
        local dlight = DynamicLight(LocalPlayer():EntIndex())

        if dlight then
            dlight.pos = SlamCenter
            dlight.r = 100
            dlight.g = 100
            dlight.b = 100
            dlight.brightness = 0
            dlight.Decay = 1200
            dlight.Size = 500
            dlight.DieTime = CurTime() + 1
        end

        --physics effect on local objects - use slight delay in case new gibs were created by server from this slam
        timer.Simple(0.05, function()
            for k, v in ipairs(ents.FindInSphere(SlamCenter, 100)) do
                if v:EntIndex() == -1 or v:GetClass() == "class C_HL2MPRagdoll" then
                    FatKidSlamForce(v, SlamCenter, ForceCenter, PlayerPos)
                end
            end
        end)
    end)
end

function FatKidSlamForce(ent, SlamCenter, ForceCenter, PlayerPos)
    local vmod = 1

    --if ent:GetClass()=="class C_HL2MPRagdoll" then vmod=0.7 end
    for i = 0, ent:GetPhysicsObjectCount() - 1 do
        local phys = ent:GetPhysicsObjectNum(i)

        if IsValid(phys) and (not WorldOccludes(SlamCenter + Vector(0, 0, 20), phys:GetPos() + Vector(0, 0, 1)) or not WorldOccludes(PlayerPos + Vector(0, 0, 32), phys:GetPos() + Vector(0, 0, 1))) then
            phys:Wake()
            phys:EnableMotion(true)
            local force = phys:GetPos() - ForceCenter
            local scale = 360 - force:Length()
            force:Normalize()
            scale = scale * (phys:GetMass() + 2)
            phys:ApplyForceCenter(force * vmod * scale)
            phys:AddAngleVelocity(Vector(math.Rand(-1, 1), math.Rand(-1, 1), math.Rand(-1, 1)) * vmod * scale / phys:GetMass())
        end
    end
end

function FindFloor(pos)
    local tr = util.TraceLine({
        start = pos + Vector(0, 0, 50),
        endpos = pos - Vector(0, 0, 200),
        mask = MASK_SOLID_BRUSHONLY
    })

    if tr and tr.Hit and tr.HitNormal.z > 0.1 then return tr.HitPos + Vector(0, 0, 1) end

    return pos
end

function WorldOccludes(pos1, pos2)
    local tr = util.TraceLine({
        start = pos1,
        endpos = pos2,
        mask = MASK_SOLID_BRUSHONLY
    })

    return tr and tr.Hit
end
