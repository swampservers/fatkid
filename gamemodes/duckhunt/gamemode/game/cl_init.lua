-- Copyright (C) 2021 Swamp Servers. https://github.com/swampservers/fatkid
-- Use is subject to a restrictive license, please see: https://github.com/swampservers/fatkid/blob/master/LICENSE
GM.Human.ScoreboardName = "Duck"
GM.Zombie.ScoreboardName = "Shark"
GM.AZ.ScoreboardName = "Hunter"
GM.Human.ScoreboardColor = Color(240, 240, 120, 255)
GM.Human.HintText = "You're a duck! Your goal is to kill the hunter, and to do so you must get through the map without getting shot!"
GM.Zombie.HintText = "You're a shark! You can swim quickly and kill any duck that falls in the water. Wait for the next round!"
GM.AZ.HintText = "You're the hunter! Your goal is to kill all the ducks. Don't let them get to the end, or they can kill you!"
local ViewModelHidden = false

hook.Add("CalcView", "Duckhunt_CbowZoom", function(ply, pos, angles, fov)
    local view = {}
    view.origin = pos
    view.angles = angles
    view.drawviewer = false

    if fov < 22 then
        if ViewModelHidden == false then
            ViewModelHidden = true
            net.Start("ToggleViewModel")
            net.WriteBool(not ViewModelHidden)
            net.SendToServer()
        end

        view.fov = 16
    else
        if ViewModelHidden then
            ViewModelHidden = false
            net.Start("ToggleViewModel")
            net.WriteBool(not ViewModelHidden)
            net.SendToServer()
        end

        view.fov = fov
    end

    return view
end)

timer.Simple(0, function()
    RunConsoleCommand("cl_detaildist", 2400)
end)