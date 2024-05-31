-- Retrieved from https://github.com/swampservers/fatkid
surface.CreateFont("ScoreboardDefault", {
    font = "Helvetica",
    size = 22,
    weight = 800
})

surface.CreateFont("ScoreboardDefault2", {
    font = "Helvetica",
    --italic  = true,
    size = 22,
    weight = 800
})

surface.CreateFont("ScoreboardDefault3", {
    font = "Helvetica",
    --italic  = true,
    size = 18,
    weight = 800
})

surface.CreateFont("ScoreboardDefaultTitle", {
    font = "Helvetica",
    size = 32,
    weight = 800
})

local PLAYER_LINE = {
    Init = function(self)
        local tcolor = Color(62, 62, 62)
        self.AvatarButton = self:Add("DButton")
        self.AvatarButton:Dock(LEFT)
        self.AvatarButton:SetSize(32, 32)

        self.AvatarButton.DoClick = function()
            self.Player:ShowProfile()
        end

        self.Avatar = vgui.Create("AvatarImage", self.AvatarButton)
        self.Avatar:SetSize(32, 32)
        self.Avatar:SetMouseInputEnabled(false)
        self.Name = self:Add("DLabel")
        self.Name:Dock(FILL)
        self.Name:SetFont("ScoreboardDefault")
        self.Name:SetTextColor(tcolor)
        self.Name:DockMargin(8, 0, 0, 0)
        self.Mute = self:Add("DImageButton")
        self.Mute:SetSize(32, 32)
        self.Mute:Dock(RIGHT)
        self.Ping = self:Add("DLabel")
        self.Ping:Dock(RIGHT)
        self.Ping:SetWidth(70)
        self.Ping:SetFont("ScoreboardDefault")
        self.Ping:SetTextColor(tcolor)
        self.Ping:SetContentAlignment(5)
        --[[
		self.Deaths = self:Add( "DLabel" )
		self.Deaths:Dock( RIGHT )
		self.Deaths:SetWidth( 50 )
		self.Deaths:SetFont( "ScoreboardDefault" )
		self.Deaths:SetTextColor(tcolor)
		self.Deaths:SetContentAlignment( 5 )
		]]
        --
        --[[
		self.Kills = self:Add( "DLabel" )
		self.Kills:Dock( RIGHT )
		self.Kills:SetWidth( 50 )
		self.Kills:SetFont( "ScoreboardDefault" )
		self.Kills:SetTextColor(tcolor)
		self.Kills:SetContentAlignment( 5 )
		]]
        --
        self.Team = self:Add("DLabel")
        self.Team:Dock(RIGHT)
        self.Team:SetWidth(200)
        self.Team:SetFont("ScoreboardDefault2")
        self.Team:SetTextColor(tcolor)
        self.Team:SetContentAlignment(6)
        self:Dock(TOP)
        self:DockPadding(3, 3, 3, 3)
        self:SetHeight(32 + 3 * 2)
        self:DockMargin(2, 0, 2, 2)
    end,
    Setup = function(self, pl)
        self.Player = pl
        self.Avatar:SetPlayer(pl)
        self:Think(self)
    end,
    --local friend = self.Player:GetFriendStatus() --MsgN( pl, " Friend: ", friend )
    Think = function(self)
        if not IsValid(self.Player) then
            self:SetZPos(9999) -- Causes a rebuild
            self:Remove()

            return
        end

        if self.PName == nil or self.PName ~= self.Player:Nick() then
            self.PName = self.Player:Nick()
            self.Name:SetText(self.PName)
        end

        --[[
		if ( self.NumKills == nil || self.NumKills != self.Player:Frags() ) then
			self.NumKills = self.Player:Frags()
			self.Kills:SetText( self.NumKills )
		end
		]]
        --
        --[[
		if ( self.NumDeaths == nil || self.NumDeaths != self.Player:Deaths() ) then
			self.NumDeaths = self.Player:Deaths()
			self.Deaths:SetText( self.NumDeaths )
		end
		]]
        --
        if self.NumPing == nil or self.NumPing ~= self.Player:Ping() then
            self.NumPing = self.Player:Ping()
            self.Ping:SetText(self.NumPing)
        end

        local scoremod = 0

        if self.Player:Team() == TEAM_AZ then
            scoremod = -20000
            self.Team:SetFont("ScoreboardDefault2")
        elseif self.Player:Team() == TEAM_ZOMBIE then
            scoremod = -10000
            self.Team:SetFont("ScoreboardDefault3")
        else
            self.Team:SetFont("ScoreboardDefault3")
        end

        self.Team:SetText(GAMEMODE:SelectPlayerConfig(self.Player).ScoreboardName)

        if self.Muted == nil or self.Muted ~= self.Player:IsMuted() then
            self.Muted = self.Player:IsMuted()

            if self.Muted then
                self.Mute:SetImage("icon32/muted.png")
            else
                self.Mute:SetImage("icon32/unmuted.png")
            end

            self.Mute.DoClick = function()
                self.Player:SetMuted(not self.Muted)
            end
        end

        if self.Player:Team() == TEAM_CONNECTING then
            self:SetZPos(2000 + self.Player:EntIndex())

            return
        end

        --self:SetZPos( ( self.NumKills * -1 ) + scoremod ) --+ self.Player:EntIndex() )
        self:SetZPos(scoremod + self.Player:EntIndex())
    end,
    Paint = function(self, w, h)
        if not IsValid(self.Player) then return end
        draw.RoundedBox(4, 0, 0, w, h, GAMEMODE:SelectPlayerConfig(self.Player).ScoreboardColor)
    end
}

PLAYER_LINE = vgui.RegisterTable(PLAYER_LINE, "DPanel")

local SCORE_BOARD = {
    Init = function(self)
        self.Header = self:Add("Panel")
        self.Header:Dock(TOP)
        self.Header:SetHeight(100)
        self.Name = self.Header:Add("DLabel")
        self.Name:SetFont("ScoreboardDefaultTitle")
        self.Name:SetTextColor(Color(255, 255, 255, 255))
        self.Name:Dock(TOP)
        self.Name:SetHeight(40)
        self.Name:SetContentAlignment(5)
        self.Name:SetExpensiveShadow(2, Color(0, 0, 0, 200))
        self.NumPlayers = self.Header:Add("DLabel")
        self.NumPlayers:SetFont("ScoreboardDefault")
        self.NumPlayers:SetTextColor(Color(255, 255, 255, 255))
        self.NumPlayers:Dock(TOP)
        self.NumPlayers:SetHeight(40)
        self.NumPlayers:SetContentAlignment(5)
        self.NumPlayers:SetExpensiveShadow(2, Color(0, 0, 0, 200))
        self.Scores = self:Add("DScrollPanel")
        self.Scores:Dock(FILL)
    end,
    PerformLayout = function(self)
        self:SetSize(700, ScrH() - 200)
        self:SetPos(ScrW() / 2 - 350, 100)
    end,
    Paint = function(self, w, h) end,
    --draw.RoundedBox( 4, 0, 0, w, h, Color( 0, 0, 0, 200 ) )
    Think = function(self, w, h)
        self.Name:SetText(GetHostName())
        self.NumPlayers:SetText(tostring(player.GetCount()) .. " players online")

        for id, pl in player.Iterator() do
            if IsValid(pl.ScoreEntry) then continue end
            pl.ScoreEntry = vgui.CreateFromTable(PLAYER_LINE, pl.ScoreEntry)
            pl.ScoreEntry:Setup(pl)
            self.Scores:AddItem(pl.ScoreEntry)
        end
    end
}

SCORE_BOARD = vgui.RegisterTable(SCORE_BOARD, "EditablePanel")

function GM:ScoreboardShow()
    if not IsValid(g_Scoreboard) then
        g_Scoreboard = vgui.CreateFromTable(SCORE_BOARD)
    end

    if IsValid(g_Scoreboard) then
        g_Scoreboard:Show()
        g_Scoreboard:MakePopup()
        g_Scoreboard:SetKeyboardInputEnabled(false)
    end
end

function GM:ScoreboardHide()
    if IsValid(g_Scoreboard) then
        g_Scoreboard:Hide()
    end
end

function GM:HUDDrawScoreBoard()
end
