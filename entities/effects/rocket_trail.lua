local smokeSprite = "particle/particle_smokegrenade";
local smokeSpriteCount = 6;
local particleDelay = 0.01;
local tau = math.pi * 2

function EFFECT:Init( cEffectData )

	self.Entity = cEffectData:GetEntity();
	self.Color = cEffectData:GetStart():ToColor();
	self.Normal = cEffectData:GetNormal();

	if IsValid( self.Entity ) then
		self.Emitter = ParticleEmitter( self.Entity:GetPos(), false );
	end

	self.NextParticle = CurTime() + particleDelay; 

end

function EFFECT:Think()
	if not IsValid( self.Entity ) then 
		if self.Emitter then self.Emitter:Finish() end;
		return false
	end;

	if CurTime() > self.NextParticle then
		for i = 0, smokeSpriteCount do
			self:PuffSmoke( i > 0 );
		end;
		self.NextParticle = CurTime() + particleDelay;
	end

	return true;
end

function EFFECT:Render()
	return false;
end

function EFFECT:PuffSmoke( dark )
	local offset = dark and Vector( 1 - math.random() * 2, 1 - math.random() * 2, 1 - math.random() * 2 ) or Vector( 0, 0, 0 );
	local smoke = self.Emitter:Add( smokeSprite, self.Entity:GetPos() + offset * 12 );

	smoke:SetLifeTime( math.random() );
	smoke:SetDieTime( 1 );

	smoke:SetStartSize( 8 + math.random() * 8 );
	smoke:SetEndSize( 32 + math.random() * 16 );
	smoke:SetStartAlpha( 255 );
	smoke:SetRoll( math.random() * tau * 2 - tau );
	smoke:SetRollDelta( 1 - math.random() * 2 );

	smoke:SetGravity( Vector( 32, 0, 115 ) );
	smoke:SetCollide( false );
	smoke:SetLighting( false );

	smoke:SetColor( dark and self.Color.r * 0.1 or self.Color.r, dark and self.Color.g * 0.1 or self.Color.g, dark and self.Color.b * 0.1 or self.Color.b );
end