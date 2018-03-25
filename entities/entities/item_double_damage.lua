AddCSLuaFile()

ENT.Type = "point"

ENT.SpawnDelay = 30;
ENT.HoverDistance = 48;

function ENT:Initialize()
	self:SpawnDoubleDamage();
end

function ENT:SpawnDoubleDamage()
	self.RespawnTimerName = "ItemSpawnDoubleDamage#"..self:EntIndex();
	
	if SERVER then
		if IsValid( self.DoubleDamage ) then self.DoubleDamage:Remove() end;

		self.DoubleDamage = ents.Create( "rj_double_damage" );
		self.DoubleDamage:SetPos( self:GetPos() + Vector( 0, 0, self.HoverDistance ) );
		self.DoubleDamage:SetOwner( self );
		self.DoubleDamage:Spawn();

		if timer.Exists( self.RespawnTimerName ) then timer.Remove( self.RespawnTimerName ) end;

		--self.DoubleDamageTaken = false;
	end
end

function ENT:DoubleDamageExpired()
	if SERVER and not timer.Exists( self.RespawnTimerName ) then
		local this = self;
		timer.Create( self.RespawnTimerName, self.SpawnDelay, 1, function() 
			this:SpawnDoubleDamage();
			this:EmitSound( "ItemBattery.Touch" );
		end );
	end
end
