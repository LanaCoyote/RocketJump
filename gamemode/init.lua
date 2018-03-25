AddCSLuaFile( "cl_deathnotice.lua" );
AddCSLuaFile( "cl_hud.lua" );
AddCSLuaFile( "cl_init.lua" );
AddCSLuaFile( "cl_menus.lua" );
AddCSLuaFile( "cl_scoreboard.lua" );
AddCSLuaFile( "shared.lua" );

include( "shared.lua" );

GM.SpawnProtectedPlayers = {};
GM.NextRemoveArmorTick = CurTime() + 1;

function GM:Initialize()
	game.ConsoleCommand( "sv_friction 4\n" );
end

function GM:Think()
	if CurTime() > GAMEMODE.NextRemoveArmorTick then
		for i, ply in pairs( GAMEMODE.SpawnProtectedPlayers ) do
			if ply:Armor() > 0 then ply:SetArmor( ply:Armor() - 2 );
			else 
				table.remove( GAMEMODE.SpawnProtectedPlayers, i );
				ply:SetRenderFX( kRenderFxNone );
			end
		end

		GAMEMODE.NextRemoveArmorTick = CurTime() + 1;
	end
end

function GM:PlayerSetModel( ply )
	local cl_playermodel = ply:GetInfo( "cl_playermodel" )
	local modelname = player_manager.TranslatePlayerModel( cl_playermodel )
	util.PrecacheModel( modelname )
	ply:SetModel( modelname )

	local playerColorString = ply:GetInfo( "cl_playercolor" );
	if playerColorString then
		ply:SetNWString( "PlayerColor", playerColorString );
		local playerColorVector = Vector( playerColorString );

		ply:SetPlayerColor( playerColorVector );
	end
end

function GM:PlayerLoadout( ply )
	ply:SetArmor( 100 );
	table.insert( GAMEMODE.SpawnProtectedPlayers, ply );
	ply:SetRenderFX( kRenderFxStrobeFast );

	ply:CrosshairDisable();
	ply:Give( "weapon_rocketlauncher" );
	ply:SetAmmo( 9999, "pistol" );
	ply:SetFriction( 0 );
	ply.DirectHit = false;
	return true;
end

function GM:GetFallDamage( ply, speed )
	return 0;
end

function GM:EntityTakeDamage( ent, cTakeDamageInfo )
	if ent == cTakeDamageInfo:GetAttacker() then
		if ent:IsPlayer() then 
			ent.LastAttackingPlayer = nil; 
			ent:SetArmor( 0 );
		end
		return true
	elseif cTakeDamageInfo:GetAttacker():IsValid() and cTakeDamageInfo:GetAttacker():IsPlayer() then
		ent.LastAttackingPlayer = cTakeDamageInfo:GetAttacker();

		if ent.DirectHit and ent:Health() > cTakeDamageInfo:GetDamage() then 
			ent.DirectHit = false;
		end
	elseif cTakeDamageInfo:GetAttacker():IsValid() and cTakeDamageInfo:GetAttacker():GetClass() == "func_physbox" and cTakeDamageInfo:GetDamage() > 20 then
		cTakeDamageInfo:SetDamage( 20 );
	end
end

function GM:OnDamagedByExplosion( ply, dmginfo )
	ply:SetDSP( 35, CLIENT );
end

util.AddNetworkString( "PlayerKilledByDirectHit" );

function GM:DoPlayerDeath( ply, attacker, cTakeDamageInfo )

	if ( cTakeDamageInfo:IsExplosionDamage() and ply:Health() < -15 ) then
		for i = 1,8 do
			local giblet = ents.Create( "rj_gib" );
			giblet:SetPos( ply:GetShootPos() - Vector( 0, 0, i * 4 ) );

			giblet:Spawn();

			if player_manager.TranslateToPlayerModelName( ply:GetModel() ) == "skeleton" then
				giblet:SetModel( "models/gibs/hgibs_scapula.mdl" );
				giblet:SetModelScale( math.random() * 2 );
				giblet:SetColor( Color( 255, 255, 255, 255 ) );
			end	
		end
	else
		ply:CreateRagdoll();
	end

	ply:AddDeaths( 1 );
	
	if attacker:IsValid() and attacker:IsPlayer() then
		if ( attacker == ply ) then
			attacker:AddFrags( -1 )
		else
			attacker:AddFrags( 1 )
			ply:ChatPrint( "Your killer had "..attacker:Health().."% health left" );
		end
	end

	if attacker:GetClass() == "trigger_hurt" or attacker:GetClass() == "func_physbox" and ply.LastAttackingPlayer then
		if IsValid( ply.LastAttackingPlayer ) and ply.LastAttackingPlayer:IsPlayer() then 
			ply.LastAttackingPlayer:AddFrags( 1 ) ;
			ply:ChatPrint( "Your killer had "..ply.LastAttackingPlayer:Health().."% health left" );
		end;
	end

end

function Explode( ply )
	local explodeDamage = DamageInfo();
	explodeDamage:SetAttacker( game.GetWorld() );
	explodeDamage:SetInflictor( game.GetWorld() );
	explodeDamage:SetDamage( 9999 );
	explodeDamage:SetDamageType( DMG_BLAST );

	ply:TakeDamageInfo( explodeDamage );
end

concommand.Add( "explode2", Explode )

function GM:PlayerDeath( ply, inflictor, attacker )

	if ( IsValid( attacker ) or attacker:GetClass() == "trigger_hurt" or attacker:GetClass() == "func_physbox" ) then 
		attacker = IsValid( ply.LastAttackingPlayer ) and ply.LastAttackingPlayer or ply; 
	end

	if ( !IsValid( inflictor ) && IsValid( attacker ) ) then
		inflictor = attacker
	end

	if ( IsValid( inflictor ) && inflictor == attacker && ( inflictor:IsPlayer() || inflictor:IsNPC() ) ) then

		inflictor = inflictor:GetActiveWeapon()
		if ( !IsValid( inflictor ) ) then inflictor = attacker end

	end

	-- Don't spawn for at least 2 seconds
	ply.NextSpawnTime = CurTime() + (attacker == ply and 5 or 3);
	ply:SetNWFloat( "NextSpawnTime", ply.NextSpawnTime );
	ply.DeathTime = CurTime();

	if ( attacker == ply ) then

		net.Start( "PlayerKilledSelf" )
			net.WriteEntity( ply )
		net.Broadcast()

		MsgAll( attacker:Nick() .. " suicided!\n" )

	return end

	if ( attacker:IsPlayer() ) then

		if ply.DirectHit then
			net.Start( "PlayerKilledByDirectHit" );

				net.WriteEntity( ply );
				net.WriteString( "DIRECT_HIT" );
				net.WriteEntity( attacker );

			net.Broadcast();

			MsgAll( attacker:Nick() .. " killed " .. ply:Nick() .. " using DIRECT_HIT!!!\n" );
		else
			net.Start( "PlayerKilledByPlayer" );

				net.WriteEntity( ply );
				net.WriteString( inflictor:GetClass() );
				net.WriteEntity( attacker );

			net.Broadcast();

			MsgAll( attacker:Nick() .. " killed " .. ply:Nick() .. " using " .. inflictor:GetClass() .. "\n" );
		end

		

	return end

	net.Start( "PlayerKilled" )

		net.WriteEntity( ply )
		net.WriteString( inflictor:GetClass() )
		net.WriteString( attacker:GetClass() )

	net.Broadcast()

	MsgAll( ply:Nick() .. " was killed by " .. attacker:GetClass() .. "\n" )

end

function GM:ShowHelp( ply )
	if ply:GetNWString("ShowMenu") == "help" then ply:SetNWString("ShowMenu","") return end;
	ply:SetNWString("ShowMenu", "help");
end

function GM:ShowTeam( ply )
	if ply:GetNWString("ShowMenu") == "team" then 
		ply:SetNWString("ShowMenu","");
		self:PlayerSetModel( ply );
	return end;
	ply:SetNWString("ShowMenu","team");
end

function GM:PlayerButtonDown( ply, btn )
	if ply:IsConnected() and ply:GetNWString("ShowMenu") == "welcome" then
		ply:SetNWString("ShowMenu", "team");
	end
end

function GM:OnPlayerChangedTeam( ply, oldTeam, newTeam )
	if ply:GetNWString("ShowMenu") == "team" then
		ply:SetNWString("ShowMenu", "")
	end

	if oldTeam == TEAM_SPECTATOR or oldTeam == TEAM_UNASSIGNED or newTeam == TEAM_SPECTATOR then
		local oldPos = ply:GetPos();
		ply:Spawn();
		if newTeam == TEAM_SPECTATOR then ply:SetPos( oldPos ) end;
	end
end

function GM:PlayerInitialSpawn( pl )
	pl:SetTeam( TEAM_UNASSIGNED )
	pl:SetNWString( "ShowMenu", "welcome" );
end