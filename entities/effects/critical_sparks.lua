EFFECT.Lifetime = 0;
EFFECT.MaxLife = 0.18;

local sparkSprite = "effects/spark";
local sparkSpriteCount = 36;
local zapSprite = "effects/tool_tracer";
local zapMaterial = Material( zapSprite );

function EFFECT:Init( cEffectData )

	self.Origin = cEffectData:GetOrigin();
	self.Color = cEffectData:GetStart():ToColor();
	self.Normal = cEffectData:GetNormal();

	self.Emitter = ParticleEmitter( self.Origin, false );

	for i = 0, sparkSpriteCount do
		local adj = Vector( 1 - math.random() * 2, 1 - math.random() * 2, 1 - math.random() * 2 ) + self.Normal;
		local spark = self.Emitter:Add( sparkSprite, self.Origin + adj * 32 );
		if spark then
			spark:SetLifeTime( math.random() );
			spark:SetDieTime( 2 );

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

	self.Emitter:Finish();

	util.ScreenShake( self.Origin, 1, 0.5, 0.5, 64 );
	sound.Play( "ambient.electrical_random_zap_1", self.Origin, 55, 150 + math.random() * 105, 0.5 );

end

function EFFECT:Think()
	self.Lifetime = self.Lifetime + FrameTime();
	if self.Lifetime >= self.MaxLife then return false end;
	return true;
end

function EFFECT:Render()
	self:DrawZap( self.Origin );
end

function EFFECT:DrawZap( pos )
	local size = 256 + (self.Lifetime and (self.Lifetime / self.MaxLife) * 56 or 0);

	render.SetMaterial( zapMaterial );
	render.DrawQuadEasy( pos, Vector( 1 - math.random() * 2, 1 - math.random() * 2, 1 - math.random() * 2 ), size, size, Color( self.Color.r, self.Color.g, self.Color.b, 255 ), math.random() * 360 );
end