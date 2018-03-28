AddCSLuaFile();

ENT.Type = "point";

ENT.SpawnDelay = 10;
ENT.HoverDistance = 48;

ENT.ItemClass = nil;
ENT.RespawnSound = Sound( "ItemBattery.Touch" );
ENT.StartSpawned = true;

function ENT:Initialize()
	if self.StartSpawned then self:SpawnItem();
	else self:ItemTaken();
	end
end

function ENT:GetRespawnTimerName()
	return "ItemSpawn#"..self:EntIndex();
end

if SERVER then
	function ENT:Think()
		if self:GetNWBool( "ItemExists" ) and not IsValid( self.Item ) then
			print( "[warn] item spawner "..self:EntIndex().." item was taken without alerting the spawner" );
			self:ItemTaken();
		end
	end

	function ENT:SpawnItem()
		if self:GetNWBool( "ItemExists" ) then return end;

		if self.ItemClass == nil then
			print( "[err] item spawner "..self:EntIndex().." attempted to spawn nil item" );
		return end

		self.Item = ents.Create( self.ItemClass );
		if not IsValid( self.Item ) then
			print( "[err] failed to spawn "..self.ItemClass.." from item spawner "..self:EntIndex() );
		return end

		self.Item:SetPos( self:GetPos() + Vector( 0, 0, self.HoverDistance ) );
		self.Item:SetOwner( self );
		self.Item:Spawn();

		self:SetNWBool( "ItemExists", true );
	end

	function ENT:ItemTaken()
		if not self:GetNWBool( "ItemExists" ) or timer.Exists( self:GetRespawnTimerName() ) then return end;

		self:SetNWBool( "ItemExists", false );

		local this = self; -- closure necessary to preserve self reference
		timer.Create( self:GetRespawnTimerName(), self.SpawnDelay, 1, function()
			this:SpawnItem();
			this:EmitSound( this.RespawnSound );
		end );
	end
end