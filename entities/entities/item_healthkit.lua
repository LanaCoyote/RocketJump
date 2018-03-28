AddCSLuaFile()

ENT.Type = "point";
ENT.Base = "item_spawner_base";

ENT.SpawnDelay = 20;
ENT.ItemClass = "rj_healthkit";

function ENT:Initialize()
	return self.BaseClass.Initialize( self );
end
