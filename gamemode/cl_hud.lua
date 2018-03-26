include( "cl_menus.lua" );
include( "cl_scoreboard.lua" );

local PlaceholderColor = table.Random({
	"255 0 0 255",
	"255 255 0 255",
	"0 255 255 255",
	"0 255 0 255",
	"255 0 255 255",
	"0 0 255 255",
	"255 155 0 255",
	"155 0 255 255",
	"0 155 255 255",
	"155 255 0 255"
});

LocalPlayer().ShowMenu = nil;

function GM:HUDShouldDraw( element )
	if element == "CHudDamageIndicator" and LocalPlayer():Alive() then return false end;
	return true;
end

function GM:HUDPaint()

	hook.Run( "HUDDrawPickupHistory" );
	hook.Run( "DrawDeathNotice", 0.85, 0.04 );

	self:DrawLaserPointer();

	local menuOpen = self:DrawMenus();
	if menuOpen then return end;

	self:DrawPlayerNames();
	self:DrawRespawnTimer();
	self:DrawScoreboard();

end

function GM:DrawLaserPointer()
	if not IsValid( LocalPlayer():GetActiveWeapon() ) then return end;
	local beamColor = LocalPlayer():rj_GetPlayerColor();
	local beamLength = 150;

	local pTraceData = util.GetPlayerTrace( LocalPlayer() );
	local pTrace = util.TraceLine( {
		start = LocalPlayer():GetShootPos(),
		endpos = LocalPlayer():GetShootPos() + LocalPlayer():EyeAngles():Forward() * 1280,
		filter = LocalPlayer(),
		collisiongroup = COLLISION_GROUP_PROJECTILE
	} );

	local beamStart = LocalPlayer():GetShootPos() - Vector( 0, 0, 10 ) + LocalPlayer():EyeAngles():Forward() * 15; --LocalPlayer():GetActiveWeapon():GetAttachment( 3 ).Pos;
	local beamEnd = pTrace.HitPos;
	--if beamStart:DistToSqr( beamEnd ) > beamLength * beamLength then beamEnd = beamStart.Sub( beamEnd ):Normalize() * beamLength end;

	cam.Start3D();
	--local prevClippingValue = render.EnableClipping( true );

		render.SetMaterial( Material("effects/laser1") );
		local w = 3 + math.random() * 3;
		render.DrawBeam( beamStart, beamEnd, w, 0, 12.5, beamColor );

		-- draw the dot too
		local r = 15 + math.random() * 15;
		render.SetMaterial( Material("sprites/light_glow02_add_noz") );
		render.DrawQuadEasy( pTrace.HitPos, pTrace.HitNormal, r, r, beamColor, 0)

	--render.EnableClipping( prevClippingValue );
	cam.End3D();
end

function GM:DrawPlayerNames()
	local players = player.GetAll();

	for _, ply in pairs( players ) do
		if not IsValid(ply) or ply == LocalPlayer() or ply:Team() > 1000 then continue end;
		local namePosition = ply:GetShootPos():ToScreen();
		local nameToDisplay = ply:Alive() and ply:Name() or "*DEAD* "..ply:Name();
		local colorToDisplay = ply:Alive() and ply:rj_GetPlayerColor() or Color( 100, 100, 100, 255 );

		draw.SimpleText( nameToDisplay, "TargetID", namePosition.x, namePosition.y - 24, colorToDisplay, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM );
		if GAMEMODE.TeamplayEnabled and ply:Team() == LocalPlayer():Team() then
			draw.SimpleText( ply:Health().."%", "TargetIDSmall", namePosition.x, namePosition.y - 24, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP );
		end
	end
end

function GM:DrawRespawnTimer()
	if LocalPlayer():Alive() then return end;

	local respawnTime = LocalPlayer():GetNWFloat( "NextSpawnTime" );
	if respawnTime == nil then return end;

	local timeToRespawn = math.ceil( (respawnTime - CurTime()) * 10 ) / 10;
	local textToDisplay = timeToRespawn > 0 and "Respawn in "..timeToRespawn.." seconds..." or "Click to respawn";

	draw.SimpleText( textToDisplay, "CenterPrintText", ScrW() / 2, ScrH() / 2, Color( 255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER );
end
