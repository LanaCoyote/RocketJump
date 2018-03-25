AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_missile.mdl")

ENT.HoverAlternation = 16;
ENT.RotationAngle = 0;
ENT.RotationSpeed = 90;
ENT.Tilt = -75;

ENT.PickupSound = Sound( "weapons/shotgun/shotgun_cock.wav" );

function ENT:Initialize()
	self.InitialPosition = self:GetPos();
	self:SetModel( self.Model );
	self:SetModelScale( self:GetModelScale() * 1.5 );
	self:SetAngles( Angle( self.Tilt, self.RotationAngle, 0 ) );

	if SERVER then
		self.GlowSprite = ents.Create( "env_sprite" );
		self.GlowSprite:SetPos( self:GetPos() + Vector( 0, -2, 0 ) );
		self.GlowSprite:SetKeyValue( "rendermode", 1 );
		self.GlowSprite:SetKeyValue( "rendercolor", "255 128 0" );
		self.GlowSprite:SetKeyValue( "model", "sprites/gmdm_pickups/light.vmt" );
		self.GlowSprite:Spawn();

		self:SetMoveType( MOVETYPE_NONE );
	   	self:SetSolid( SOLID_BBOX );
	   	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER );
	   	self:SetTrigger( true );
	end
end

function ENT:Think()
	if SERVER then return end;
	if CLIENT and self:GetPos():DistToSqr( LocalPlayer():GetPos() ) > 1638400 then return end;

	self.RotationAngle = self.RotationAngle + ( self.RotationSpeed * FrameTime() );
	self:SetAngles( Angle( self.Tilt, self.RotationAngle, 0 ) );

	-- self:SetPos( self.InitialPosition + Vector( 0, 0, math.sin( CurTime() ) * self.HoverAlternation ) );
end

function ENT:OnRemove()
	if self.GlowSprite and IsValid( self.GlowSprite ) then self.GlowSprite:Remove() end;
end

function ENT:Touch( other )
	if other:IsPlayer() and other:GetActiveWeapon():Clip1() < other:GetActiveWeapon():GetMaxClip1() then
		self:EmitSound( self.PickupSound );
		if CLIENT and other == LocalPlayer() then surface.PlaySound( self.PickupSound ) end;

		if SERVER then
			other:GetActiveWeapon():SetClip1( math.Min( other:GetActiveWeapon():Clip1() + 1, other:GetActiveWeapon():GetMaxClip1() ) );
			if ( IsValid( self:GetOwner() ) ) then self:GetOwner():RocketTaken() end;
		end
		
		self:Remove();
	end
end