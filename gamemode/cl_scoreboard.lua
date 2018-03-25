
local livingAvatars = {};
local livingMuteButtons = {};
local scoreboardVisible = false;

function GM:ScoreboardShow()
	scoreboardVisible = true;
end

function GM:ScoreboardHide()
	scoreboardVisible = false;
	GAMEMODE:CleanupScoreboardUI();
end

function GM:CleanupScoreboardUI()
	if #livingAvatars == 0 then return end;

	for _, panel in pairs( livingAvatars ) do
		panel:Remove();
	end

	for _, panel in pairs( livingMuteButtons ) do
		panel:Remove();
	end

	livingAvatars = {};
	livingMuteButtons = {};
end

function GM:DrawScoreboard()
	if not scoreboardVisible then return end;

	local headerHeight = 64;
	local playerRowHeight = 32;
	local margin = 12;
	local activePlayerCount = player.GetCount() - team.NumPlayers( TEAM_SPECTATOR ) - team.NumPlayers( TEAM_UNASSIGNED );

	local expectedHeight = headerHeight + activePlayerCount * playerRowHeight + margin * 2 + 48;
	local width = math.min( ScrW() * 0.75, 800 );

	local topLeftX = ( ScrW() - width ) / 2;
	local topLeftY = ScrH() * 0.15;

	surface.SetDrawColor( 0, 0, 0, 225 );
	surface.DrawRect( topLeftX, topLeftY, width, expectedHeight );

	draw.SimpleText(
		GetHostName(),
		"Trebuchet24",
		ScrW() / 2, topLeftY + margin, Color( 255, 235, 0, 255 ), TEXT_ALIGN_CENTER );

	draw.SimpleText(
		GAMEMODE.TeamplayEnabled and "Team Deathmatch" or "Deathmatch",
		"Trebuchet18",
		ScrW() / 2, topLeftY + margin + 24, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER );

	local printY = topLeftY + headerHeight + margin;
	local killColumnStart = topLeftX + ( width / 3 ) * 2;
	local columnWidth = 64;

	-- draw header
	draw.SimpleText(
		"Player",
		"Trebuchet18",
		topLeftX + 32, printY, Color( 255, 255, 255, 255 ) );
	draw.SimpleText(
		"Frags",
		"Trebuchet18",
		killColumnStart + columnWidth / 2, printY, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER );
	draw.SimpleText(
		"Deaths",
		"Trebuchet18",
		killColumnStart + columnWidth * 1.5, printY, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER );
	local _, y = draw.SimpleText(
		"Ping",
		"Trebuchet18",
		killColumnStart + columnWidth * 2.5, printY, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER );
	printY = printY + y;

	local sortedPlayerList = player.GetAll();
	table.sort( sortedPlayerList, function ( a, b ) 
		if a:Frags() == b:Frags() then return a:Deaths() < b:Deaths() end;
		return a:Frags() > b:Frags() 
	end );

	for idx, ply in ipairs( sortedPlayerList ) do
		if ply:Team() > 1000 then continue end;

		local playerColor = ply:GetNWString( "PlayerColor" );
		if playerColor then playerColor = Vector( playerColor ):ToColor() else Color( 255, 205, 0, 255 ) end;
		local totalLuminence = ( playerColor.r + playerColor.g + playerColor.b ) / ( 255 * 3 );

		local textColor = Color( 0, 0, 0, 255 );
		if totalLuminence < 0.4 then textColor = Color( 255, 255, 255, 255 ) end;

		surface.SetDrawColor( playerColor.r, playerColor.g, playerColor.b, 255 );
		surface.DrawRect( topLeftX, printY, width, playerRowHeight );

		-- avatar ui
		if not livingAvatars[idx] then
			local avatar = vgui.Create( "AvatarImage" );
			avatar:SetSize( 32, 32 );
			avatar:SetPos( topLeftX + margin, printY );
			avatar:SetPlayer( ply, 32 );
			avatar:SetMouseInputEnabled( false );

			livingAvatars[idx] = avatar;
		end

		draw.SimpleText(
			ply:Name(),
			"Trebuchet18",
			topLeftX + margin * 2 + 32, printY + playerRowHeight / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER );
		
		if not ply:Alive() then
			draw.SimpleText(
				"DEAD",
				"Trebuchet18",
				killColumnStart - columnWidth, printY + playerRowHeight / 2, textColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER );
		end

		draw.SimpleText(
			ply:Frags(),
			"Trebuchet18",
			killColumnStart + columnWidth / 2, printY + playerRowHeight / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
		draw.SimpleText(
			ply:Deaths(),
			"Trebuchet18",
			killColumnStart + columnWidth * 1.5, printY + playerRowHeight / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
		draw.SimpleText(
			ply:Ping(),
			"Trebuchet18",
			killColumnStart + columnWidth * 2.5, printY + playerRowHeight / 2, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );

		if not livingMuteButtons[idx] then
			local mute = vgui.Create( "DImageButton" );
			mute:SetSize( 32, 32 );
			mute:SetPos( topLeftX + width - margin - 32, printY );
			mute.DoClick = function()
				ply:SetMuted( !ply:IsMuted() );
			end

			livingMuteButtons[idx] = mute;
		end

		if ply:IsMuted() then
			livingMuteButtons[idx]:SetImage( "icon32/muted.png" )
		else
			livingMuteButtons[idx]:SetImage( "icon32/unmuted.png" )
		end

		printY = printY + playerRowHeight;
	end

	local spectators = team.GetPlayers( TEAM_SPECTATOR );
	if #spectators > 0 then
		local spectatorNames = "Spectators (" .. #spectators .. "): ";
		for idx, ply in ipairs( spectators ) do
			spectatorNames = spectatorNames .. ply:Name();
			if idx < #spectators then spectatorNames = spectatorNames .. ", " end;
		end

		draw.SimpleText(
			spectatorNames,
			"Trebuchet18",
			topLeftX + margin, printY + margin, Color( 255, 255, 255, 255 ) );
	end

end