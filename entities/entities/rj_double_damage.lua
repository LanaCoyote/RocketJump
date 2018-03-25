AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/gibs/agibs.mdl")

ENT.ActiveTime = 25;
ENT.WasTaken = false;
ENT.DroppedTime = 25;

ENT.HoverAlternation = 16;
ENT.RotationAngle = 0;
ENT.RotationSpeed = 90;
ENT.Tilt = 15;

function ENT:Initialize()
	self.InitialPosition = self:GetPos();
	self:SetModel( self.Model );
	self:SetModelScale( self:GetModelScale() * 1.5 );
	self:SetAngles( Angle( self.Tilt, self.RotationAngle, 0 ) );
	self:SetColor( Color( 65, 65, 255, 255) )

	if SERVER then
		self.GlowSprite = ents.Create( "env_sprite" );
		self.GlowSprite:SetPos( self:GetPos() + Vector( 0, -2, -5 ) );
		self.GlowSprite:SetKeyValue( "scale", 2 );
		self.GlowSprite:SetKeyValue( "rendermode", 1 );
		self.GlowSprite:SetKeyValue( "rendercolor", "0 0 255" );
		self.GlowSprite:SetKeyValue( "model", "sprites/gmdm_pickups/light.vmt" );
		self.GlowSprite:Spawn();

		self:SetMoveType( MOVETYPE_NONE );
	   	self:SetSolid( SOLID_BBOX );
	   	self:SetCollisionGroup( COLLISION_GROUP_DEBRIS_TRIGGER );
	   	self:SetTrigger( true );
	end
end

function ENT:Think()
	if CLIENT and self:GetPos():DistToSqr( LocalPlayer():GetPos() ) < 1638400 then
		self.RotationAngle = self.RotationAngle + ( self.RotationSpeed * FrameTime() );
		self:SetAngles( Angle( self.Tilt, self.RotationAngle, 0 ) );
	end

	if IsValid( self.TargetPlayer ) then
		if not self.TargetPlayer:Alive() then
			if SERVER then PrintMessage( HUD_PRINTCENTER, self.TargetPlayer:Name().." dropped Double Damage!" ) end;

			self.TargetPlayer:SetNWBool( "DoubleDamage", false );
			self.TargetPlayer = nil;
			self.PickedUp = false;
			self:StopLoopingSound( self.SoundLoop );

			local targetPos = self:GetPos();
			targetPos.y = 0;
			self:SetPos( targetPos );
			self.GlowSprite:SetPos( targetPos );
		return false end

		local adjustmentVector = Vector( 32 * math.sin( math.rad( self.RotationAngle ) ), 32 * math.cos( math.rad( self.RotationAngle ) ), -24 );
		self:SetPos( self.TargetPlayer:GetShootPos() + adjustmentVector );
		self.GlowSprite:SetPos( self:GetPos() );
		if self.DynamicLight then self.DynamicLight.pos = self:GetPos() end;

		self.ActiveTime = self.ActiveTime - FrameTime();
		if self.ActiveTime <= 0 then
			self.TargetPlayer:SetNWBool( "DoubleDamage", false );
			self:Expire();
		elseif self.ActiveTime < 3 then
			self:SetRenderFX( 11 );
		elseif self.ActiveTime < 7 then
			self:SetRenderFX( 10 );
		end

		self:NextThink( CurTime() );
		return true;
	elseif self.WasTaken then
		self.DroppedTime = self.DroppedTime - FrameTime();
		if self.DroppedTime <= 0 then
			self:Expire();
		end
		self:NextThink( CurTime() );
		return true;
	end
	-- self:SetPos( self.InitialPosition + Vector( 0, 0, math.sin( CurTime() ) * self.HoverAlternation ) );
end

function ENT:OnRemove()
	if self.GlowSprite and IsValid( self.GlowSprite ) then self.GlowSprite:Remove() end;
	if self.SoundLoop then self:StopLoopingSound( self.SoundLoop ) end;
end

function ENT:Touch( other )
	if not self.PickedUp and other:IsPlayer() and not other:GetNWBool( "DoubleDamage" ) then
		self.TargetPlayer = other;
		self.WasTaken = true;
		self.PickedUp = true;
		--self:SetSolid( SOLID_NONE );
		self.SoundLoop = self:StartLoopingSound( "SuitRecharge.ChargingLoop" );

		if SERVER then PrintMessage( HUD_PRINTCENTER, other:Name().." picked up Double Damage!" ) end;

		other:SetNWBool( "DoubleDamage", true );
	end
end

function ENT:Expire()
	self:EmitSound( "SuitRecharge.Deny" );

	if ( IsValid( self:GetOwner() ) ) then self:GetOwner():DoubleDamageExpired() end;

	self:Remove();
end