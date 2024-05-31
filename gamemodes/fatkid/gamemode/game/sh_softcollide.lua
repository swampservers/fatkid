-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
-- Makes humans push each other and fatkid push skeletons, without anyone getting stuck inside each other
SCpushsize = 20
SCstandheight = 72
SCcrouchheight = 36

-- TODO(winter): Optimize this more; we should NOT be iterating through players twice unless absolutely necessary (is it?)
hook.Add("Move", "SoftCollide", function(ply, data)
    if ply:Team() == TEAM_HUMAN then
        local plypos = ply:GetPos()
        local velchange = Vector(0, 0, 0)

        for k, v in player.Iterator() do
            if IsValid(v) and v:Alive() and v:Team() == TEAM_HUMAN and v ~= ply then
                local check = true
                local otherpos = v:GetPos()
                local mdiff = SCstandheight

                if otherpos.z < plypos.z then
                    if v:Crouching() then
                        mdiff = SCcrouchheight
                    end

                    if plypos.z - otherpos.z > mdiff then
                        check = false
                    end
                end

                if otherpos.z > plypos.z then
                    if ply:Crouching() then
                        mdiff = SCcrouchheight
                    end

                    if otherpos.z - plypos.z > mdiff then
                        check = false
                    end
                end

                --PLAYERS ARE AT SAME HEIGHT
                if check then
                    local plypos2 = Vector(plypos.x, plypos.y, 0)
                    otherpos = Vector(otherpos.x, otherpos.y, 0)

                    if plypos2:Distance(otherpos) < SCpushsize then
                        local mult = Vector(data:GetVelocity().x, data:GetVelocity().y, 0):Length() + 1.2
                        mult = mult * ((10 + SCpushsize - plypos2:Distance(otherpos)) / SCpushsize) * 2
                        local diff = (plypos2 - otherpos):GetNormalized() * mult
                        velchange = velchange + Vector(diff.x, diff.y, 0)
                    end
                end
            end
        end

        data:SetVelocity(data:GetVelocity() + velchange)
        local vdd = Vector(data:GetVelocity().x, data:GetVelocity().y, 0)

        if vdd:Length() > 220 then
            data:SetVelocity(vdd:GetNormalized() * 220 + Vector(0, 0, data:GetVelocity().z))
        end
    end

    if ply:Team() == TEAM_ZOMBIE then
        local plypos = ply:GetPos()
        local velchange = Vector(0, 0, 0)

        for k, v in player.Iterator() do
            if IsValid(v) and v:Alive() and v:Team() == TEAM_AZ and v ~= ply then
                local check = true
                local otherpos = v:GetPos()
                local mdiff = SCstandheight

                if otherpos.z < plypos.z then
                    if v:Crouching() then
                        mdiff = SCcrouchheight
                    end

                    if plypos.z - otherpos.z > mdiff then
                        check = false
                    end
                end

                if otherpos.z > plypos.z then
                    if ply:Crouching() then
                        mdiff = SCcrouchheight
                    end

                    if otherpos.z - plypos.z > mdiff then
                        check = false
                    end
                end

                --PLAYERS ARE AT SAME HEIGHT
                if check then
                    local plypos2 = Vector(plypos.x, plypos.y, 0)
                    otherpos = Vector(otherpos.x, otherpos.y, 0)

                    if plypos2:Distance(otherpos) < SCpushsize * 1.5 then
                        local mult = Vector(data:GetVelocity().x, data:GetVelocity().y, 0):Length() + 5
                        mult = mult * ((10 + SCpushsize * 1.5 - plypos2:Distance(otherpos)) / (SCpushsize * 1.5)) * 2
                        local diff = (plypos2 - otherpos):GetNormalized() * mult
                        velchange = velchange + Vector(diff.x, diff.y, 0)
                    end
                end
            end
        end

        data:SetVelocity(data:GetVelocity() + velchange)
        local vdd = Vector(data:GetVelocity().x, data:GetVelocity().y, 0)

        if vdd:Length() > 450 then
            data:SetVelocity(vdd:GetNormalized() * 450 + Vector(0, 0, data:GetVelocity().z))
        end
    end
end)
