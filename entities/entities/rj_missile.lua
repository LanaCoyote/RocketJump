AddCSLuaFile();

ENT.Type = "anim";
ENT.Base = "item_pickup_base";
ENT.Model = Model( "models/weapons/w_missile.mdl" );

ENT.Tilt = -75;
ENT.Scale = 1.5;
ENT.GlowSpriteColor = Color( 255, 128, 0, 200 );
ENT.GlowSpriteOffset = Vector( 0, -2, 0 );
ENT.PickupSound = Sound( "weapons/shotgun/shotgun_cock.wav" );
ENT.BoostPickupSound = true;

function ENT:Initialize()
	return self.BaseClass.Initialize( self );
end

function ENT:CanBePickedUp( ply )
	local plyWeapon = ply:GetActiveWeapon();
	return IsValid( plyWeapon ) and plyWeapon:Clip1() < plyWeapon:GetMaxClip1();
end

function ENT:OnPickup( ply )
	local plyWeapon = ply:GetActiveWeapon();
	if not IsValid( plyWeapon ) then return end;

	plyWeapon:SetClip1( math.Min( plyWeapon:Clip1() + 1, plyWeapon:GetMaxClip1() ) );
end
