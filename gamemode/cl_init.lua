include( "cl_deathnotice.lua" );
include( "cl_hud.lua" );

include( "shared.lua" );

local CursorLockConvar = CreateClientConVar( "cl_cursorlock", 1, true, false, "Whether the cursor should be locked to the screen during gameplay" );
local CrosshairCursorConvar = CreateClientConVar( "cl_crosshaircursor", 1, true, false, "Use the crosshair cursor instead of the default pointer" );

function GM:Think() 
	gui.EnableScreenClicker( true );
	vgui.GetWorldPanel():SetWorldClicker( true );
	if CrosshairCursorConvar:GetBool() then vgui.GetWorldPanel():SetCursor( "crosshair" ) else vgui.GetWorldPanel():SetCursor( "none" ) end;

	local ply = LocalPlayer();
	GAMEMODE:CalcPlayerFacing( ply );
	if CursorLockConvar:GetBool() then GAMEMODE:LockCursor() end;

end

function GM:CalcPlayerFacing( ply )
	local plyScreenSpace = ply:GetShootPos():ToScreen();

	local facingBackwards = false;
	local mouseX = gui.MouseX();
	local mouseY = gui.MouseY();

	if ( mouseX > ScrW() / 2 ) then facingBackwards = true end;

	local x = math.deg( math.atan2( plyScreenSpace.x - mouseX, plyScreenSpace.y - mouseY ) ) - 90;
	local y = 0;
	if ( facingBackwards ) then 
		x = 180 - x;
		y = 180;
	end;

	ply:SetEyeAngles( Angle( x, y, 0 ) );
end

function GM:LockCursor()
	if gui.IsGameUIVisible() then return end;
	local mouseX, mouseY = gui.MousePos();

	local windowLimitX = math.Max( ScrW() * 0.02, 16 );
	local windowLimitY = math.Max( ScrH() * 0.02, 16 );

	if mouseX < windowLimitX then mouseX = windowLimitX;
	elseif mouseX > ScrW() - windowLimitX then mouseX = ScrW() - windowLimitX;
	end;

	if mouseY < windowLimitY then mouseY = windowLimitY;
	elseif mouseY > ScrH() - windowLimitY then mouseY = ScrH() - windowLimitY;
	end;

	input.SetCursorPos( mouseX, mouseY );
end

function GM:CalcView( ply, origin, angles, fov, znear, zfar )
	local viewAdjustmentVector = Vector( 0, 600, 100 );
	local viewAdjustmentAngle = Angle( 15, -90, 0 );

	local view = {};
	view.origin		= ply:Alive() and origin + viewAdjustmentVector or ply:GetPos() + viewAdjustmentVector;
	view.angles		= viewAdjustmentAngle;
	view.fov		= fov;
	view.znear		= znear;
	view.zfar		= zfar;
	view.drawviewer	= false;

	return view;
end

function GM:ShouldDrawLocalPlayer( ply )
	return true;
end	

function GM:OnPlayerChat( player, strText, bTeamOnly, bPlayerIsDead )
	local chatLine = {};
	if bPlayerIsDead then
		table.insert( chatLine, "*DEAD* " );
	end

	if GAMEMODE.TeamplayEnabled and IsValid( player ) then
		table.insert( chatLine, team.GetColor( player:Team() ) );

		if bTeamOnly then
			table.insert( chatLine, "(TEAM) " );
		end
	elseif IsValid( player ) then	
		local playerColor = player:GetNWString( "PlayerColor" );
		if playerColor then
			table.insert( chatLine, Vector( playerColor ):ToColor() );
		end
	end

	if IsValid( player ) then
		table.insert( chatLine, player:Name() );
	else
		table.insert( chatLine, "Console" );
	end

	table.insert( chatLine, Color( 255, 255, 255 ) )
	table.insert( chatLine, ": " .. strText )

	chat.AddText( unpack(chatLine) )

	return true
end