﻿-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
hook.Add("MapSetup", "Gymnasium_PropFix", function()
    for k, v in next, ents.FindByModel("models/props_c17/lockers001a.mdl") do
        v:GetPhysicsObject():EnableMotion(false)
    end
end)

hook.Add("MapSetup", "Gymnasium_Dodgeballs", function()
    for i = 1, 10 do
        e = ents.Create("dodgeball")
        e:SetPos(Vector(math.random(-325, 325), math.random(0, 545), math.random(100, 300)))
        e:Spawn()
        e:Activate()
    end
end)