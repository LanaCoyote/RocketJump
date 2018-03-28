AddCSLuaFile();

ENT.Type = "anim";
ENT.Base = "item_pickup_base";
ENT.Model = Model("models/items/healthkit.mdl");

ENT.Healing = 25;

ENT.Tilt = 75;
ENT.Scale = 1.5;
ENT.GlowSpriteColor = Color( 0, 255, 255, 200 );
ENT.GlowSpriteOffset = Vector( 0, -2, -5 );
ENT.PickupSound = Sound( "HealthKit.Touch" );

function ENT:Initialize()
	return self.BaseClass.Initialize( self );
end

function ENT:CanBePickedUp( ply )
	return ply:Alive() and ply:Health() < ply:GetMaxHealth();
end

function ENT:OnPickup( ply )
	ply:SetHealth( math.Min( ply:Health() + self.Healing, ply:GetMaxHealth() ) );
end