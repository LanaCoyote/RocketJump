GM.Name			= "Rocket Jump Deathmatch";
GM.Author		= "Lana Coyote";
GM.Email		= "";
GM.Website		= "lanan.ac";

GM.TeamBased		= true;
GM.TeamplayEnabled 	= false;

function GM:StartCommand( ply, cmd )
	if ply:Team() != TEAM_SPECTATOR then
		cmd:ClearMovement();
		cmd:RemoveKey( IN_DUCK );
		cmd:RemoveKey( IN_JUMP );
	end
end

function GM:SetupMove( ply, cMoveData, cUserInput )
	if ply:Team() == TEAM_SPECTATOR then
		cMoveData:SetMoveAngles( Angle( -90, -90, 0 ) );
	else
		local initialVelocity = cMoveData:GetVelocity();
		initialVelocity.y = 0;
		cMoveData:SetVelocity( initialVelocity );
	end
end

function GM:CreateTeams()
	TEAM_DEATHMATCH = 1;
	TEAM_RED = 2;
	TEAM_BLUE = 3;

	if GAMEMODE.TeamplayEnabled then
		team.SetUp( TEAM_RED, "Red Rockets", Color( 255, 90, 90 ) );
		team.SetSpawnPoint( TEAM_RED, { 
			"info_player_rebel", "info_player_terrorist" 
		});

		team.SetUp( TEAM_BLUE, "Blue Bombers", Color( 90, 120, 255 ) );
		team.SetSpawnPoint( TEAM_BLUE, { 
			"info_player_combine", "info_player_counterterrorist" 
		});
	else
		team.SetUp( TEAM_DEATHMATCH, "Players", Color( 50, 185, 50 ) )
		team.SetSpawnPoint( TEAM_DEATHMATCH, { 
			"info_player_start", "info_player_deathmatch",
			"info_player_rebel", "info_player_terrorist",
			"info_player_combine", "info_player_counterterrorist" 
		});
	end

	team.SetSpawnPoint( TEAM_SPECTATOR, "worldspawn" )
end