EFFECT.Lifetime = 0;
EFFECT.MaxLife = 0.18;

local smokeSprite = "particle/smokesprites_000";
local maxSmokeSprite = 8;
local smokeSpriteCount = 24;
local fireballSprite = "effects/fire_cloud";
local fireballMaterials = {
	Material( "effects/fire_cloud1" ),
	Material( "effects/fire_cloud2" )
};
local maxFireballSprite = 2;
local fireballSpriteCount = 5;

local totalFireballs = 0;

function EFFECT:Init( cEffectData )

	self.Origin = cEffectData:GetOrigin();
	self.Color = cEffectData:GetStart():ToColor();
	self.Normal = cEffectData:GetNormal();

	-- local rotatedNormal = self.Normal;
	-- rotatedNormal:Rotate( Angle( 90, 0, 0 ) );

	debugoverlay.Line( self.Origin, self.Origin + self.Normal * 40 );

	self.Emitter = ParticleEmitter( self.Origin, false );
	self.Fireballs = {};

	--for i = 0, fireballSpriteCount do
		local material = math.random() > 0.5 and fireballMaterials[2] or fireballMaterials[1];
		self.Fireballs[1] = Vector( 1 - math.random() * 2, 0, 1 - math.random() * 2 );
		self:DrawFireball( self.Origin, self.Color, material, self.Fireballs[1] );
		self.NextSpriteTime = CurTime() + 0.02;
	--end

	local period = 1 / (smokeSpriteCount - 6) * 2 * math.pi;
	local size = 96;

	for i = 0, smokeSpriteCount do
		
		local xAdjust = i < smokeSpriteCount - 6 and size * math.cos( i / period ) or 0;
		local yAdjust = i < smokeSpriteCount - 6 and size/2 * math.sin( i / period ) or 0;
		local zAdjust = i < smokeSpriteCount - 6 and 0 or size;

		local adj = Vector( 
			math.random() * size/2 + zAdjust ,
			size/2 - math.random() * size + yAdjust, 
			size/2 - math.random() * size + xAdjust
		);
		adj:Rotate( self.Normal:Angle() );
		local spriteNum = math.Rand( 1, maxSmokeSprite );
		local smoke = self.Emitter:Add( smokeSprite..spriteNum, self.Origin + adj );
		if smoke then
			smoke:SetLifeTime( math.random() );
			smoke:SetDieTime( 2 );

			local darkenAmount = math.random() > 0.75 and math.random() * 0.5 or 0;
			smoke:SetColor( self.Color.r * darkenAmount, self.Color.g * darkenAmount, self.Color.b * darkenAmount );
			smoke:SetStartSize( 96 );
			smoke:SetEndSize( 78 );
			smoke:SetStartAlpha( 150 + (50 * math.random()) );

			local velocity = adj;
			smoke:SetVelocity( adj );
			smoke:SetRoll( math.random() );

			smoke:SetAirResistance( 25 );

			smoke:SetCollide( false );
			smoke:SetLighting( false );
		end
	end

	self.Emitter:Finish();

	util.ScreenShake( self.Origin, 1, 0.5, self.MaxLife * 3, 64 );
	util.Decal( "Scorch", self.Origin + self.Normal * 15, self.Origin - self.Normal * 15 )
	sound.Play( "BaseExplosionEffect.Sound", self.Origin, 75, 200 + math.random() * 55, 1 );

end

function EFFECT:Think()
	self.Lifetime = self.Lifetime + FrameTime();
	if self.Lifetime >= self.MaxLife then return false end;
	return true;
end

local function BrightenColor( color, amt )
	local adjustment = 1 / (math.max( color.r, color.g, color.b ) / 255);
	if adjustment == 0 then return Color( 255, 255, 255 ) end;

	return Color( color.r * adjustment + amt, color.g * adjustment + amt, color.b * adjustment + amt);
end

function EFFECT:Render()
	if #self.Fireballs < fireballSpriteCount and CurTime() > self.NextSpriteTime then
		self.Fireballs[#self.Fireballs + 1] = Vector( 1 - math.random() * 2, 0, 1 - math.random() * 2 );
		self.NextSpriteTime = CurTime() + 0.02;
	end

	for i = 0, #self.Fireballs do
		local material = math.random() > 0.5 and fireballMaterials[2] or fireballMaterials[1];
		self:DrawFireball( self.Origin, BrightenColor( self.Color, 35 ), material, self.Fireballs[i] );
	end
end

function EFFECT:DrawFireball( pos, color, material, offset )
	if not offset then return end;

	totalFireballs = totalFireballs + 1;
	-- print( "attempting to draw fireball:", pos, color, material, offset, "-> total air fireballs rendered:", totalFireballs );

	local alpha = 255 - (self.Lifetime and (self.Lifetime / self.MaxLife) * 255 or 0);
	local size = 140 + (self.Lifetime and (self.Lifetime / self.MaxLife) * 56 or 0);
	color.alpha = alpha;

	render.SetMaterial( material );
	render.DrawQuadEasy( pos + offset * 48, EyeAngles():Forward() * -1, size, size, Color( color.r, color.g, color.b, 255 ), 0 );
end