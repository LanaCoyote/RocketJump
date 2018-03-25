AddCSLuaFile()

ENT.Type = "anim";
ENT.Model = Model("models/props_junk/rock001a.mdl");

function ENT:Initialize()
   	self:SetModel(self.Model);

    self:PhysicsInit(SOLID_VPHYSICS);

    local phys = self:GetPhysicsObject();
    phys:SetMass( 2 );
    phys:SetDamping( 0, 0 );
    phys:SetMaterial( "flesh" );
    self:BlastOff();

    self:SetCollisionGroup(COLLISION_GROUP_DEBRIS);

    self:SetColor( Color( 255, 0, 0, 255 ) );
    self:SetModelScale( self:GetModelScale() * (math.random() + 0.5) );

    self:PhysWake();

    if SERVER then
	    local this = self;
	    timer.Simple( 10, function() if IsValid( this ) then this:Remove() end; end );
    end

end

function ENT:BlastOff()
	local BlastForce = Vector( 400 - math.random() * 800, 200 - math.random() * 400, math.random() * 900 );
	local phys = self:GetPhysicsObject();
	if IsValid( phys ) then phys:SetVelocity( BlastForce ) end;
	self:SetAngles( Angle( math.random() * 360, math.random() * 360, math.random() * 360 ) );
end

function ENT:PhysicsCollide( collisionData, collider )

	util.Decal( "Blood", collisionData.HitPos - collisionData.HitNormal, collisionData.HitPos + collisionData.HitNormal );

end