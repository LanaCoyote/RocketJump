AddCSLuaFile();

ENT.Type = "anim";
ENT.Base = "base_carry";
ENT.Model = Model("models/gibs/agibs.mdl");

ENT.Expires = true;
ENT.ActiveTime = 25;
ENT.DroppedTime = 25;

ENT.Tilt = 15;
ENT.Scale = 1.5;
ENT.GlowSpriteColor = Color( 0, 0, 255, 255 );
ENT.GlowSpriteOffset = Vector( 0, -2, -5 );
ENT.GlowSpriteScale = 2;
-- --ENT.PickupSound = Sound( "weapons/shotgun/shotgun_cock.wav" );

ENT.LoopingSound = "SuitRecharge.ChargingLoop";

function ENT:Initialize()
	self:SetColor( Color( 65, 65, 255, 255 ) );

	return self.BaseClass.Initialize( self );
end

function ENT:OnRemove()
	if self.SoundLoop then self:StopLoopingSound( self.SoundLoop ) end;
	return self.BaseClass.OnRemove( self );
end

function ENT:CanBePickedUp( ply )
	return not ( self.PickedUp or ply:GetNWBool( "DoubleDamage" ) );
end

function ENT:OnPickup( ply )
	self.SoundLoop = self:StartLoopingSound( self.LoopingSound );
	ply:SetNWBool( "DoubleDamage", true );

	if SERVER then
		PrintMessage( HUD_PRINTCENTER, ply:Name().." picked up Double Damage!" );
	end
end

function ENT:OnDrop( ply, expiring )
	if self.SoundLoop then self:StopLoopingSound( self.SoundLoop ) end;
	ply:SetNWBool( "DoubleDamage", false );

	if SERVER and not expiring then
		PrintMessage( HUD_PRINTCENTER, ply:Name().." dropped Double Damage" );
	end
end
