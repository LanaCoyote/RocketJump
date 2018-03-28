AddCSLuaFile()

ENT.Type = "point"
ENT.Base = "item_spawner_base";

ENT.SpawnDelay = 30;
ENT.ItemClass = "rj_double_damage";
ENT.StartSpawned = true;

function ENT:Initialize()
	return self.BaseClass.Initialize( self );
end
