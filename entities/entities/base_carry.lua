AddCSLuaFile();

ENT.Type = "anim";
DEFINE_BASECLASS( "item_pickup_base" );

ENT.Expires = false;
ENT.ActiveTime = -1;
ENT.DroppedTime = -1;
ENT.WasTaken = false;

ENT.ExpireSound = Sound( "SuitRecharge.Deny" );

ENT.PickedUp = false;
ENT.TargetPlayer = nil;

function ENT:Initialize()
	self.InitialPosition = self:GetPos();
	self.LastThink = CurTime();

	self:SetNWFloat( "ActiveTime", self.ActiveTime );
	self:SetNWFloat( "DroppedTime", self.DroppedTime );
	return BaseClass.Initialize( self );
end

function ENT:Touch( other )
	if other:IsPlayer() and self:CanBePickedUp( other ) then
		self:EmitSound( self.PickupSound );
		self.TargetPlayer = other;
		self.PickedUp = true;
		self.WasTaken = true;

		if CLIENT and self.BoostPickupSound and other == LocalPlayer() then
			surface.PlaySound( self.PickupSound );
		end

		if SERVER then
			self:OnPickup( other );

			local activeTime = self:GetNWFloat( "ActiveTime" );
			if activeTime < self.ActiveTime * 0.28 then
				self:SetNWFloat( "ActiveTime", self.ActiveTime * 0.28 );
			end
		end
	end
end

if CLIENT then
	function ENT:Think()
		BaseClass.Think( self );

		if IsValid( self.TargetPlayer ) then
			local positionAdjustmentVector = Vector(
				32 * math.sin( math.rad( self.RotationAngle ) ),
				32 * math.cos( math.rad( self.RotationAngle ) ),
				0 );
			self:SetPos( self.TargetPlayer:GetShootPos() + positionAdjustmentVector );

			if self.GlowSprite then self.GlowSprite:SetPos( self:GetPos() ) end;

			if self.Expires then
				local activeTime = self:GetNWFloat( "ActiveTime" );
				if activeTime < self.ActiveTime * 0.12 then
					self:SetRenderFX( 11 );
				elseif activeTime < self.ActiveTime * 0.28 then
					self:SetRenderFX( 10 );
				end	
			end
		end
	end
end

if SERVER then
	function ENT:Think()
		local usedNextThink = false;

		if self.PickedUp and not IsValid( self.TargetPlayer ) then
			-- target player does not exist but item is stuck in limbo
			self.PickedUp = false;
			self:UpdatePositionAfterDrop();
		elseif IsValid( self.TargetPlayer ) then
			if not self.TargetPlayer:Alive() then
				self:Drop();
			return end

			local positionAdjustmentVector = Vector(
				18 * math.sin( CurTime() * 2 ),
				18 * math.cos( CurTime() * 2 ),
				-12 );
			local nextVelocity = self.TargetPlayer:GetVelocity() * FrameTime();
			self:SetPos( self.TargetPlayer:GetShootPos() + nextVelocity + positionAdjustmentVector );
			self:NextThink( CurTime() );
			usedNextThink = true;

			if self.GlowSprite then self.GlowSprite:SetPos( self:GetPos() ) end;

			if self.Expires then
				local activeTime = self:GetNWFloat( "ActiveTime" );
				if activeTime < self.ActiveTime * 0.12 then
					self:SetRenderFX( 11 );
				elseif activeTime < self.ActiveTime * 0.28 then
					self:SetRenderFX( 10 );
				end	
			end
		end

		self:UpdateExpirationTime();
		self.LastThink = CurTime();

		return usedNextThink;
	end

	function ENT:UpdateExpirationTime()
		if not ( self.Expires and self.WasTaken ) then return end;

		local timeVariable = IsValid( self.TargetPlayer ) and "ActiveTime" or "DroppedTime";
		local timeChange = CurTime() - self.LastThink;
		local time = self:GetNWFloat( timeVariable ) - timeChange;

		if time < 0 then self:Expire();
		else self:SetNWFloat( timeVariable, time );
		end
	end

	function ENT:OnDrop( ply, expiring ) end

	function ENT:Drop()
		if not IsValid( self.TargetPlayer ) then return end;

		self:OnDrop( self.TargetPlayer, false );
		self.TargetPlayer = nil;
		self.PickedUp = false;

		self:UpdatePositionAfterDrop();
	end

	function ENT:UpdatePositionAfterDrop()
		local targetPos = self:GetPos();
		targetPos.y = self.InitialPosition and self.InitialPosition.y or 0;
		self:SetPos( targetPos );
		self.GlowSprite:SetPos( targetPos );
	end

	function ENT:Expire()
		self:EmitSound( self.ExpireSound );

		if IsValid( self.TargetPlayer ) then
			self:OnDrop( self.TargetPlayer, true );
		end

		if IsValid( self:GetOwner() ) then
			self:GetOwner():ItemTaken();
		end

		self:Remove();
	end
end