AddCSLuaFile()

ENT.Type = "anim"
ENT.Model = Model("models/weapons/w_missile.mdl")

ENT.IsReloading = false;

ENT.Speed = 1000;
ENT.ExplosionForce = 600;
ENT.UpwardsImpulse = 0;

ENT.DamageFalloffMin = 768;
ENT.DamageFalloffMax = 1536;
ENT.DamageFalloffMult = 0.5;

ENT.Damage = 40;
ENT.DirectHitDamage = 25;
ENT.ExplosionRadius = 196;
ENT.DoubleDamage = false;

ENT.ParticleName = "Rocket_Smoke";

function ENT:Initialize()
   	self:SetModel(self.Model)
   	self.StartPos = self:GetPos();

   	if SERVER then
	   --self:PhysicsInit(SOLID_VPHYSICS)
	   self:SetMoveType(MOVETYPE_FLY)
	   self:SetSolid(SOLID_BBOX)
	   self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)

	   self:SetTrigger( true );
   		--self:SetVelocity( self:GetAngles():Forward() * self.Speed )
	end

	-- self:SetParticleTrail( self.ParticleName );
	local playerColor = self:GetOwner() and self:GetOwner():rj_GetPlayerColorVector();

	self.trailEffects = EffectData();
	self.trailEffects:SetEntity( self );
	self.trailEffects:SetOrigin( self:GetPos() );
	self.trailEffects:SetNormal( self:GetVelocity() );
	self.trailEffects:SetStart( playerColor );
	util.Effect( "rocket_trail", self.trailEffects );
	-- trailEffects:SetNormal( self:Ge)
end

function ENT:Think()
	if CLIENT and not self.DoubleDamage then
		if self:GetNWBool( "DoubleDamage" ) then
			util.Effect( "critical_trail", self.trailEffects );
			self.DoubleDamage = true;
		end
	end
end

function ENT:OnRemove()
	-- if CLIENT and IsValid( self.ParticleTrail ) then 
	-- 	local particles = self.ParticleTrail;
	-- 	particles:StopEmission(); 
	-- 	timer.Simple( 5, function() particles:StopEmissionAndDestroyImmediately() end );
	-- end
end

-- if SERVER then
-- 	function ENT:Think()
-- 		-- print(self)
-- 		local spos = self:GetPos();
-- 		local tForward = self:GetAngles():Forward() * 64;
-- 		local tr = util.TraceEntity({start=spos, endpos=spos + tForward, filter={self, self:GetOwner()}}, self)

-- 		if ( tr.Hit ) then
-- 			self:Explode( tr.HitPos );
-- 		end
-- 	end
-- end


function ENT:StartTouch( other )
	local traceResult = nil;
	if other == self:GetOwner() then return end;
	if other:IsPlayer() then 
		other:TakeDamage( self:CalculateDamageFalloff( self.DirectHitDamage, 0.25 ), self:GetOwner(), self );
		other.DirectHit = true;
	elseif other:IsWorld() then
		local traceLength = self:GetVelocity() * FrameTime() * 2;
		local traceData = {
			start = self:GetPos() - traceLength,
			endpos = self:GetPos() + traceLength,
			collisiongroup = COLLISION_GROUP_PROJECTILE,
			filter = self:GetOwner()
		};
		traceResult = util.TraceLine( traceData );

		self:Explode( traceResult.HitPos, traceResult.HitNormal, true );
		return;
	end;

	self:Explode( self:GetPos(), Vector( 0, 0, 1 ), false );
end

function ENT:Explode( pos, normal, world )
	debugoverlay.Cross( pos, 8 );

	-- local explosion = ents.Create( 'env_explosion' );
	-- explosion:SetPos( pos );
	-- explosion:SetOwner( self:GetOwner() );
	-- --explosion:SetKeyValue( "Magnitude", 80 );
	-- explosion:Spawn();
	-- explosion:Fire( "Explode" );

	local playerColor = self:GetOwner() and self:GetOwner():rj_GetPlayerColorVector();
	local explosionData = EffectData();
		explosionData:SetOrigin( pos );
		explosionData:SetStart( playerColor );
		explosionData:SetNormal( normal );
	util.Effect( world and "rocket_explosion" or "rocket_explosion_air", explosionData );
	if self:GetNWBool( "DoubleDamage" ) then util.Effect( "critical_sparks", explosionData ) end;

	if SERVER then 
		util.BlastDamage( self, self:GetOwner(), pos, self.ExplosionRadius, self:CalculateDamageFalloff( self.Damage, 0.5 ) );

		local hitObjects = ents.FindInSphere( pos, self.ExplosionRadius );
		for _, ent in pairs(hitObjects) do
			local phys = ent:IsPlayer() and ent or ent:GetPhysicsObject();
			local scaleFactor = math.abs(1 - (pos:DistToSqr( ent:GetPos() ) / (self.ExplosionRadius * self.ExplosionRadius)));

			-- local safetyTraceStart = pos + (-10 * self:GetVelocity());
			-- local safetyTraceEnd = ent:IsPlayer() and ent:GetPos() + ent:GetViewOffset() or ent:GetPos();
			-- local safetyTrace = util.TraceLine({start = safetyTraceStart, endpos = safetyTraceEnd, mask = MASK_SHOT_PORTAL});

			-- if ent:IsPlayer() then
			-- -- 	phys = ent;
			-- -- 	local damageScaleFactor = math.abs(1 - (pos:DistToSqr( ent:GetPos() + ent:GetViewOffset() ) / 16384))
			-- -- 	if ent != self:GetOwner() then ent:TakeDamage( 80 * scaleFactor, self:GetOwner(), self ) end;
			--  	print( ent:Health() );
			-- end

			if IsValid( phys ) then
				local entPosition = ent:IsPlayer() and ent:GetPos() + ent:GetViewOffset() or ent:GetPos();
				local force = scaleFactor * self.ExplosionForce;
				local direction = (pos - entPosition):GetNormalized();

				local ground = ent:GetGroundEntity();
				if IsValid( ground ) and !ground:IsWorld() then
					local shuntDistance = (pos - phys:GetPos()):GetNormalized() * 16;
					shuntDistance.y = 0;
					ent:SetPos( ent:GetPos() + shuntDistance );
				end

				direction.y = 0;
				--direction.x = direction.x / 2;
				-- if pos.z > entPosition.z then direction end;

				phys:SetVelocity( direction * -force );
			end
		end
	end

	--explosion:Fire( "Kill", nil, 3 );

	self:Remove();

end

function ENT:CalculateDamageFalloff( damage, mult )
	local sqDistanceTravelled = math.abs(self:GetPos():DistToSqr( self.StartPos ));

	if sqDistanceTravelled < self.DamageFalloffMin * self.DamageFalloffMin then
		return damage;
	elseif sqDistanceTravelled > self.DamageFalloffMax * self.DamageFalloffMax then
		return damage * mult;
	end

	local adjustedDistance = math.sqrt(sqDistanceTravelled) - self.DamageFalloffMin;
	local adjustedMaximum = self.DamageFalloffMax - self.DamageFalloffMin;
	local t = 1 - (adjustedDistance / adjustedMaximum);

	return Lerp( t, damage * mult, damage );
end
