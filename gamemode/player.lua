
local PlayerMeta = FindMetaTable( "Player" );
if ( !PlayerMeta ) then
	print( "There was an error loading the player metatable. This is bad and will cause much error!" );
return end


--	player color management
--	lets each player set and retrieve a player color
--	todo:	in team based mode, always return the team's color instead of the player's

if CLIENT then
	PlayerColorConvar = CreateClientConVar( "cl_playercolor", tostring( Vector( 1, 1, 0 ) ), true, true, "Color of the player's choosing" );
end

function PlayerMeta:rj_GetPlayerColorVector()
	local playerColor = self:GetNWString( "PlayerColor" );
	return playerColor and Vector( playerColor ) or Vector( 1, 1, 0 );
end

function PlayerMeta:rj_GetPlayerColor()
	return self:rj_GetPlayerColorVector():ToColor();
end

function PlayerMeta:rj_SetPlayerColorVector( colorVec )
	self:SetNWString( "PlayerColor", tostring( colorVec ) );
end

function PlayerMeta:rj_RefreshPlayerColor()
	local playerColor;
	if SERVER then playerColor = self:GetInfo( "cl_playercolor" );
	else playerColor = PlayerColorConvar and PlayerColorConvar:GetString() or Vector( 1, 1, 0 ); 
	end

	if playerColor then self:rj_SetPlayerColorVector( playerColor ) end;
end