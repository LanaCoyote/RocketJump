AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "item_spawner_base";

ENT.SpawnDelay = 12;
ENT.ItemClass = "rj_missile";

function ENT:Initialize()
	return self.BaseClass.Initialize( self );
end
