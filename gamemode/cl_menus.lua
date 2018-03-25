
local livingUI = {};
local panels = {};

local function ClearLivingUI()
	if #livingUI > 0 then
		for _, panel in ipairs( livingUI ) do
			panel:Remove();
		end

		livingUI = {};
		panels = {};
	end
end

function GM:DrawMenus()
	local currentMenu = LocalPlayer():GetNWString( "ShowMenu" );
	if not currentMenu or currentMenu == "" then 
		ClearLivingUI();
		return false;
	end

	if currentMenu == "welcome" then 
		GAMEMODE:DrawWelcome();
	elseif currentMenu == "help" then 
		ClearLivingUI();
		GAMEMODE:DrawHelp();
	elseif currentMenu == "team" then 
		GAMEMODE:DrawTeam();
	end

	return true;
end

local function DimGameplay( letterSize )
	surface.SetDrawColor( 0, 0, 0, 225 );
	surface.DrawRect( 0, 0, ScrW(), ScrH() );

	surface.SetDrawColor( 0, 0, 0, 245 );
	surface.DrawRect( 0, 0, ScrW(), ScrH() * letterSize );
	surface.DrawRect( 0, ScrH() * ( 1 - letterSize ), ScrW(), ScrH() * letterSize );

	return ScrH() * letterSize;
end

function GM:DrawWelcome()
	DimGameplay( 0.25 );

	local printX = ScrW() / 2;
	local printY = ScrH() * 0.4;

	local _, y = draw.SimpleText( 
		"Rocket Jump Deathmatch",
		"Trebuchet24",
		printX, printY, Color( 255, 235, 0, 255 ), TEXT_ALIGN_CENTER );
	printY = printY + y + 12;

	_, y = draw.SimpleText( 
		"By Lana Coyote",
		"Trebuchet18",
		printX, printY, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER );
	printY = printY + y + 12;
end

local tips = {
	"Primary attack/left click to shoot rockets.",
	"You cannot move normally. Use the explosions of your rockets to propel yourself around.",
	"Hit enemies with rockets to damage them. Direct hits do more damage than catching an opponent in the blast.",
	"You can hold up to 6 rockets and reload over time.",
	"Pick up a rocket powerup to instantly load another rocket.",
	"You reload consecutive rockets faster. It's fastest to reload more than one rocket at a time.",
	"Pick up health kits to heal yourself.",
	"Your rockets have a little bit of recoil that can be used to adjust yourself and maneuver in the air.",
	"You can see further below yourself than above. Use the high ground to surprise enemies. Be wary of ambushes from above!",
	"Keep moving to make yourself a harder target. Balance your clip size between jumping for mobility and retaliating.",
	"A double damage powerup spawns in the middle of the map. Pick it up to become godlike.",
	"Jump off walls while in midair to gain serious height and speed. Keep yourself off the ground to maintain momentum",
	"Fire more than one rocket at a time to jump higher."
};

function GM:DrawHelp()
	local letterHeight = DimGameplay( 0.1 );
	local marginWidth = ScrW() * 0.15;

	local printX = ScrW() / 2;
	local printY = ScrH() * 0.05;

	local _, y = draw.SimpleText( 
		"Help / Tips",
		"Trebuchet24",
		printX, printY, Color( 255, 235, 0, 255 ), TEXT_ALIGN_CENTER );
	
	printX = marginWidth;
	printY = letterHeight + 12;

	for _, tip in ipairs( tips ) do
		_, y = draw.SimpleText( 
			"- "..tip,
			"HudHintTextLarge",
			printX, printY, Color( 255, 255, 255, 255 ) );
		printY = printY + y + 8;
	end
end

local function ChangeModel( modelName )
	RunConsoleCommand( "cl_playermodel", modelName );
	LocalPlayer():ChatPrint( "Player model changed to "..modelName );
end

local function GetLocalPlayerColor()
	local playerColor = LocalPlayer():GetNWString( "PlayerColor" );
	if not playerColor then return end;
	return Vector( playerColor ):ToColor();
end

function GM:DrawTeam()
	local letterHeight = DimGameplay( 0.1 );
	local marginWidth = ScrW() * 0.15;

	local printX = ScrW() / 2;
	local printY = ScrH() * 0.05;

	local _, y = draw.SimpleText( 
		"Player / Team",
		"Trebuchet24",
		printX, printY, Color( 255, 235, 0, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );

	printX = marginWidth;
	printY = letterHeight + 12;
	local columnWidth = ScrW() / 2 - marginWidth - 12;

	_, y = draw.SimpleText( 
		"Choose a Player Model",
		"Trebuchet24",
		printX, printY, Color( 255, 255, 255, 255 ) );
	printY = printY + y + 12;

	if not panels["modelSelector"] then
		local modelSelectorPanel = vgui.Create( "DScrollPanel" );
		modelSelectorPanel:SetSize( columnWidth, math.min( ScrH() - letterHeight * 2 - 24, 610 ) );
		modelSelectorPanel:SetPos( printX, printY );

		table.insert( livingUI, modelSelectorPanel );
		panels["modelSelector"] = modelSelectorPanel;

		local scrWriteX = 0;
		local scrWriteY = 0;

		for k,v in pairs( player_manager.AllValidModels() ) do
			local modelIcon = vgui.Create( "SpawnIcon", modelSelectorPanel );
			modelIcon:SetPos( scrWriteX, scrWriteY );
			modelIcon:SetModel( v );

			modelIcon.DoClick = function() ChangeModel( k ) end;

			scrWriteX = scrWriteX + modelIcon:GetWide();
			if scrWriteX + modelIcon:GetWide() > modelSelectorPanel:GetWide() then
				scrWriteX = 0;
				scrWriteY = scrWriteY + modelIcon:GetTall();
			end

			table.insert( livingUI, modelIcon );
		end
	end
	printY = printY + panels["modelSelector"]:GetTall() + 12;

	-- --------- team selection column

	printX = marginWidth + columnWidth + 24;
	printY = letterHeight + 12;

	_, y = draw.SimpleText( 
		"Select a Team",
		"Trebuchet24",
		printX, printY, Color( 255, 255, 255, 255 ) );
	printY = printY + y + 12;

	if not panels["teamSelector"] then
		local teamSelectorPanel = vgui.Create( "Panel" );
		teamSelectorPanel:SetSize( columnWidth, 160 );
		teamSelectorPanel:SetPos( printX, printY );

		local scrWriteY = 0;

		for k, v in pairs( team.GetAllTeams() ) do
			if v.Joinable then
				local teamButton = vgui.Create( "DColorButton", teamSelectorPanel );
				teamButton:SetSize( columnWidth, 48 );
				teamButton:SetPos( 0, scrWriteY );
				local teamButtonName = k == TEAM_SPECTATOR and "Spectate" or v.Name.." ("..team.NumPlayers( k )..")";
				teamButton:SetText( teamButtonName );
				teamButton:SetColor( v.Color );
				teamButton:SetTooltip( team.NumPlayers( k ).." players" );
				teamButton:SetFont( "DermaDefaultBold" );
				teamButton:SetContentAlignment( 5 );

				local combinedLuminence = v.Color.r + v.Color.g + v.Color.b;
				if combinedLuminence > 448 then
					teamButton:SetTextColor( Color( 0, 0, 0, 255 ) );
				else
					teamButton:SetTextColor( Color( 255, 255, 235, 255 ) );
				end

				function teamButton:DoClick()
					RunConsoleCommand( "changeteam", k ); 
				end

				scrWriteY = scrWriteY + teamButton:GetTall();

				table.insert( livingUI, teamButton );
			end
		end

		table.insert( livingUI, teamSelectorPanel );
		panels["teamSelector"] = teamSelectorPanel;
	end
	printY = printY + panels["teamSelector"]:GetTall() + 12;

	if not GAMEMODE.TeamplayEnabled then
		_, y = draw.SimpleText( 
			"Choose a Player Color",
			"Trebuchet24",
			printX, printY, Color( 255, 255, 255, 255 ) );
		printY = printY + y + 12;

		if not panels["colorSelector"] then
			local colorSelectorPanel = vgui.Create( "DColorMixer" );
			local panelHeight = math.min( ScrH() - printY - letterHeight - 12, 450 );
			colorSelectorPanel:SetSize( columnWidth, panelHeight );
			colorSelectorPanel:SetPos( printX, printY );
			--colorSelectorPanel:SetButtonSize( 32 );

			colorSelectorPanel:SetPalette( true );
			colorSelectorPanel:SetWangs( true ); -- lol
			colorSelectorPanel:SetAlphaBar( false );
			local pColor = GetLocalPlayerColor();
			if pColor then colorSelectorPanel:SetColor( pColor ) end;

			function colorSelectorPanel:ValueChanged( newCol )
				local colorVector = Vector( newCol.r / 255, newCol.g / 255, newCol.b / 255 );
				RunConsoleCommand( "cl_playercolor", tostring( colorVector ) );
				LocalPlayer():ChatPrint( "Player color changed to "..newCol.r.." "..newCol.g.." "..newCol.b );
			end

			table.insert( livingUI, colorSelectorPanel );
			panels["colorSelector"] = colorSelectorPanel;
		end
	end

end