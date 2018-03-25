local particleDelay = 0.08;

local sparkSprite = "effects/spark";
local sparkSpriteCount = 4;
local zapSprite = "effects/tool_tracer";
local zapMaterial = Material( zapSprite );

function EFFECT:Init( cEffectData )
	self.Entity = cEffectData:GetEntity();
	self.Origin = cEffectData:GetOrigin();
	self.Color = cEffectData:GetStart():ToColor();
	self.Normal = cEffectData:GetNormal();

	if IsValid( self.Entity ) then
		self.Emitter = ParticleEmitter( self.Entity:GetPos(), false );
		sound.Play( "ambient.electrical_random_zap_2", self.Entity:GetPos(), 75, 200 + math.random() * 50, 0.75 );
	end

	self.NextParticle = CurTime() + particleDelay;

end

function EFFECT:Think()
	if not IsValid( self.Entity ) then 
		if self.Emitter then self.Emitter:Finish() end;
		return false
	end;

	return true;
end

function EFFECT:Render()
	if CurTime() > self.NextParticle then
		self:SparkPuff( self.Entity:GetPos() );
		self.NextParticle = CurTime() + particleDelay;
	end;

	self:DrawZap( self.Entity:GetPos() );
end

function EFFECT:DrawZap( pos )
	local size = 32 + math.random() * 64;
	local adj = Vector( 1 - math.random() * 2, 0, 1 - math.random() * 2 );

	render.SetMaterial( zapMaterial );
	render.DrawQuadEasy( pos + adj * 32, Vector( 1 - math.random() * 2, 1 - math.random() * 2, 1 - math.random() * 2 ), size, size, Color( self.Color.r, self.Color.g, self.Color.b, 255 ), math.random() * 360 );
	--sound.Play( "ambient.electrical_random_zap_2", self.Entity:GetPos(), 55, 150 + math.random() * 105, 0.5 );
end

function EFFECT:SparkPuff( pos )
	for i = 0, sparkSpriteCount do
		local adj = Vector( 1 - math.random() * 2, 0, 1 - math.random() * 2 ) + self.Normal;
		local spark = self.Emitter:Add( sparkSprite, pos + adj * 16 );
		if spark then
			spark:SetLifeTime( math.random() );
			spark:SetDieTime( 1 );

			spark:SetColor( 255, 255, 255 );
			spark:SetStartSize( 6 + math.random() * 6 );
			spark:SetEndSize( 0 );
			spark:SetStartAlpha( 255 );
			spark:SetEndAlpha( 255 );

			spark:SetVelocity( adj * 200 );
			spark:SetAngles( Angle( math.random() * 360, math.random() * 360, math.random() * 360 ) );

			spark:SetAirResistance( 25 );
			spark:SetGravity( Vector( 0, 0, -1000 ) );
			spark:SetBounce( 1 )

			spark:SetCollide( true );
			spark:SetLighting( false );
		end
	end
end