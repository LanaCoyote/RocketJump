AddCSLuaFile()

ENT.Type = "point"

ENT.SpawnDelay = 12;
ENT.HoverDistance = 48;

function ENT:Initialize()
	self:SpawnRocket();
end

function ENT:SpawnRocket()
	self.RespawnTimerName = "ItemSpawnRocket#"..self:EntIndex();
	
	if SERVER then
		if IsValid( self.Rocket ) then self.Rocket:Remove() end;

		self.Rocket = ents.Create( "rj_missile" );
		self.Rocket:SetPos( self:GetPos() + Vector( 0, 0, self.HoverDistance ) );
		self.Rocket:SetOwner( self );
		self.Rocket:Spawn();

		if timer.Exists( self.RespawnTimerName ) then timer.Remove( self.RespawnTimerName ) end;

		--self.RocketTaken = false;
	end
end

function ENT:RocketTaken()
	if SERVER and not timer.Exists( self.RespawnTimerName ) then
		local this = self;
		timer.Create( self.RespawnTimerName, self.SpawnDelay, 1, function() 
			this:SpawnRocket();
			this:EmitSound( "ItemBattery.Touch" );
		end );
	end
end
