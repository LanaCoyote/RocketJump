AddCSLuaFile();

ENT.Type = "anim";
ENT.Model = Model( "models/weapons/w_crowbar.mdl" );

ENT.RotationAngle = 0;
ENT.RotationSpeed = 90;
ENT.Tilt = 0;
ENT.Scale = 1;

ENT.GlowSpriteColor = Color( 255, 255, 255, 255 );
ENT.GlowSpriteTexture = "sprites/gmdm_pickups/light.vmt";
ENT.GlowSpriteOffset = Vector( 0, 0, 0 );
ENT.GlowSpriteScale = 1;

ENT.PickupSound = Sound( "weapons/shotgun/shotgun_cock.wav" );
ENT.BoostPickupSound = false;

function ENT:Initialize()
	self:SetModel( self.Model );
	self:SetModelScale( self:GetModelScale() * self.Scale );
	self:SetAngles( Angle( self.Tilt, self.RotationAngle, 0 ) );

	if SERVER then
		self:SetMoveType( MOVETYPE_NONE );
		self:SetSolid( SOLID_BBOX );
		self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER );
		self:SetTrigger( true );

		self:CreateGlowSpite();
	end
end

function ENT:CanBePickedUp( other )
	return true;
end

function ENT:OnPickup( other )
	other:SetHealth( 100 );
end

function ENT:Touch( other )
	if other:IsPlayer() and self:CanBePickedUp( other ) then
		self:EmitSound( self.PickupSound );
		if CLIENT and self.BoostPickupSound and other == LocalPlayer() then
			surface.PlaySound( self.PickupSound );
		end

		if SERVER then
			self:OnPickup( other );

			if IsValid( self:GetOwner() ) then
				self:GetOwner():ItemTaken();
			end
		end

		self:Remove();
	end
end

function ENT:OnRemove()
	if self.GlowSprite and IsValid( self.GlowSprite ) then
		self.GlowSprite:Remove();
	end
end

if CLIENT then
	function ENT:Think()
		-- skip if the local player is more than 1280 units away
		if self:GetPos():DistToSqr( LocalPlayer():GetPos() ) > 1638400 then return end;

		self.RotationAngle = self.RotationAngle + ( self.RotationSpeed * FrameTime() );
		self:SetAngles( Angle( self.Tilt, self.RotationAngle, 0 ) );
	end
end

if SERVER then
	function ENT:CreateGlowSpite()
		self.GlowSprite = ents.Create( "env_sprite" );
		if not IsValid( self.GlowSprite ) then
			print( "item pickup "..self:EntIndex().." failed to spawn glow sprite" );
		return end

		self.GlowSprite:SetPos( self:GetPos() + self.GlowSpriteOffset );
		self.GlowSprite:SetRenderMode( RENDERMODE_TRANSALPHA );
		self.GlowSprite:SetColor( self.GlowSpriteColor );
		self.GlowSprite:SetKeyValue( "model", self.GlowSpriteTexture );
		if self.GlowSpriteScale != 1 then self.GlowSprite:SetKeyValue( "scale", self.GlowSpriteScale ) end;
		self.GlowSprite:Spawn();
	end
end