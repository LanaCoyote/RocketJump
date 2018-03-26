
local function RecvPlayerKilledByDirectHit()

	local victim	= net.ReadEntity()
	local inflictor	= net.ReadString()
	local attacker	= net.ReadEntity()

	if ( !IsValid( attacker ) ) then return end
	if ( !IsValid( victim ) ) then return end
	
	GAMEMODE:AddDeathNotice( attacker:Name(), attacker:Team(), "DIRECT_HIT", victim:Name(), victim:Team() )

end
net.Receive( "PlayerKilledByDirectHit", RecvPlayerKilledByDirectHit )

local Color_Icon = Color( 255, 80, 0, 255 );
local NPC_Color = Color( 250, 50, 50, 255 );

local Deaths = {};

local function GetPlayerColor( playerName )
	if not playerName then return Color( 255, 255, 90, 255 ) end;

	for _, ply in pairs( player.GetAll() ) do
		if ply:Name() == playerName then return ply:rj_GetPlayerColor() end;
	end
end

function GM:AddDeathNotice( Attacker, team1, Inflictor, Victim, team2 )

	local Death = {}
	Death.time		= CurTime()

	Death.left		= Attacker
	Death.right		= Victim
	Death.icon		= Inflictor

	if team1 == -1 then Death.color1 = table.Copy( NPC_Color )
	else 
		Death.color1 = table.Copy( GetPlayerColor( Attacker ) );
	end
	
	if team2 == -2 then Death.color1 = table.Copy( NPC_Color )
	else 
		Death.color2 = table.Copy( GetPlayerColor( Victim ) );
	end
	
	if (Death.left == Death.right) then
		Death.left = nil
		Death.icon = "suicide"
	end
	
	table.insert( Deaths, Death )

end

local function DrawDeath( x, y, death, hud_deathnotice_time )

	local w, h = killicon.GetSize( death.icon )
	if ( !w || !h ) then return end
	
	local fadeout = ( death.time + hud_deathnotice_time ) - CurTime()
	
	local alpha = math.Clamp( fadeout * 255, 0, 255 )
	death.color1.a = alpha
	death.color2.a = alpha
	
	-- Draw Icon
	killicon.Draw( x, y, death.icon, alpha )
	
	-- Draw KILLER
	if ( death.left ) then
		draw.SimpleText( death.left,	"ChatFont", x - ( w / 2 ) - 16, y, death.color1, TEXT_ALIGN_RIGHT )
	end
	
	-- Draw VICTIM
	draw.SimpleText( death.right,		"ChatFont", x + ( w / 2 ) + 16, y, death.color2, TEXT_ALIGN_LEFT )
	
	return ( y + h * 0.70 )

end


function GM:DrawDeathNotice( x, y )

	if ( GetConVarNumber( "cl_drawhud" ) == 0 ) then return end

	local hud_deathnotice_time = GetConVar( "hud_deathnotice_time" ):GetFloat();

	x = x * ScrW()
	y = y * ScrH()
	
	-- Draw
	for k, Death in pairs( Deaths ) do

		if ( Death.time + hud_deathnotice_time > CurTime() ) then
	
			if ( Death.lerp ) then
				x = x * 0.3 + Death.lerp.x * 0.7
				y = y * 0.3 + Death.lerp.y * 0.7
			end
			
			Death.lerp = Death.lerp or {}
			Death.lerp.x = x
			Death.lerp.y = y
		
			y = DrawDeath( x, y, Death, hud_deathnotice_time )
		
		end
		
	end
	
	-- We want to maintain the order of the table so instead of removing
	-- expired entries one by one we will just clear the entire table
	-- once everything is expired.
	for k, Death in pairs( Deaths ) do
		if ( Death.time + hud_deathnotice_time > CurTime() ) then
			return
		end
	end
	
	Deaths = {}

end