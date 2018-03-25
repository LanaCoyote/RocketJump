AddCSLuaFile()

ENT.Type = "point"

ENT.SpawnDelay = 20;
ENT.HoverDistance = 48;

function ENT:Initialize()
	self:SpawnHealthkit();
end

function ENT:SpawnHealthkit()
	self.RespawnTimerName = "ItemSpawnHealthkit#"..self:EntIndex();
	
	if SERVER then
		if IsValid( self.Healthkit ) then self.Healthkit:Remove() end;

		self.Healthkit = ents.Create( "rj_healthkit" );
		self.Healthkit:SetPos( self:GetPos() + Vector( 0, 0, self.HoverDistance ) );
		self.Healthkit:SetOwner( self );
		self.Healthkit:Spawn();

		if timer.Exists( self.RespawnTimerName ) then timer.Remove( self.RespawnTimerName ) end;

		--self.HealthkitTaken = false;
	end
end

function ENT:HealthkitTaken()
	if SERVER and not timer.Exists( self.RespawnTimerName ) then
		local this = self;
		timer.Create( self.RespawnTimerName, self.SpawnDelay, 1, function() 
			this:SpawnHealthkit();
			this:EmitSound( "ItemBattery.Touch" );
		end );
	end
end
