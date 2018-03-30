
AddCSLuaFile()

if CLIENT then
   SWEP.PrintName       = "Rocket Launcher";
   SWEP.Slot            = 4;

   killicon.Add( "DIRECT_HIT", "HUD/killicons/direct", Color( 255, 80, 0, 255 ) );
   killicon.Add( "rj_rocket", "HUD/killicons/rocket", Color( 255, 80, 0, 255 ) );
   killicon.Add( "goomba_stomp", "HUD/killicons/goomba", Color( 255, 80, 0, 255 ) );
end

SWEP.Base               = "weapon_base";
SWEP.HoldType           = "rpg";
SWEP.IsReloading		= false;

SWEP.Primary.ClipSize		= 6;
SWEP.Primary.DefaultClip	= 6;
SWEP.Primary.Automatic		= false;
SWEP.Primary.Ammo			= "pistol";

SWEP.Secondary.ClipSize		= -1;
SWEP.Secondary.DefaultClip	= -1;
SWEP.Secondary.Ammo			= "none";

SWEP.ReloadTime 	= 1;
SWEP.ReloadSound	= Sound( "npc/turret_floor/click1.wav" );

SWEP.RocketSpeed	= 1000;
SWEP.RecoilForce	= 100;

SWEP.WorldModel		= "models/weapons/w_rocket_launcher.mdl"

function SWEP:Initialize()
	if IsValid( self:GetOwner() ) then self.ReloadTimerName = "RocketReloadPlayer#"..self:GetOwner():Name() end;
end

function SWEP:OwnerChanged()
	if not IsValid( self:GetOwner() ) or not self:GetOwner():IsPlayer() then return end;
	self.ReloadTimerName = "RocketReloadPlayer#"..self:GetOwner():Name();
end

function SWEP:Think()
	if self:GetNextPrimaryFire() < CurTime() and not timer.Exists( self.ReloadTimerName ) then self:Reload() end;
end 

function SWEP:CanPrimaryAttack()
	if ( self.Weapon:Clip1() <= 0 ) then
		self:EmitSound( "Weapon_Pistol.Empty" )
		if not self.IsReloading and self.Weapon:Clip1() <= 0 then self:Reload() end;
		return false;
	end

	return true;
end

function SWEP:Reload()
	-- if self.IsReloading then return end;
	-- self.IsReloading = true;
	-- self.Weapon:DefaultReload( ACT_HL2MP_GESTURE_RELOAD_RPG );
	-- timer.Simple( 1.5, function() self.IsReloading = false end );
	if self:Clip1() < self:GetMaxClip1() and not timer.Exists( self.ReloadTimerName ) then self:ReloadNext() end;
end

function SWEP:ReloadNext()
	self:GetOwner():DoReloadEvent();

	local this = self;
	local reloadTime = self.IsReloading and self.ReloadTime * 0.6 or self.ReloadTime;
	timer.Create( self.ReloadTimerName, reloadTime, 1, function() 
		if IsValid( this ) then this:ReloadOne() end; 
	end );

	self.IsReloading = true;
end

function SWEP:CancelReload()
	if timer.Exists( self.ReloadTimerName ) then 
		timer.Remove( self.ReloadTimerName );
		self:GetOwner():DoAnimationEvent( PLAYERANIMEVENT_RELOAD_END );
		self.IsReloading = false;
	end;
end

function SWEP:ReloadOne()
	self:SetClip1( math.Min( self:Clip1() + 1, self:GetMaxClip1() ) );
	-- if CLIENT then surface.PlaySound( self.ReloadSound ) end;

	if self:Clip1() < self:GetMaxClip1() then self:ReloadNext() else self:CancelReload() end;
end

function SWEP:PrimaryAttack()
	if ( !self:CanPrimaryAttack() ) then return end
	self.Weapon:EmitSound( "Weapon_RPG.Single" );
	self:CancelReload();
	self:GetOwner():DoAttackEvent();

	self:TakePrimaryAmmo( 1 );
	self:SetNextPrimaryFire( CurTime() + 0.2 );
	
	local ply = self:GetOwner();

	if SERVER then
		local rocket = ents.Create( "rj_rocket" );
		if ( !IsValid(rocket) ) then return end;

		local rocketVelocity = ply:EyeAngles():Forward() * self.RocketSpeed;
		local rocketPosition = ply:GetShootPos() + ( rocketVelocity * FrameTime() * 2 );

		rocket:SetPos( rocketPosition );
		rocket:SetAngles( ply:EyeAngles() );
		rocket:SetOwner( ply );

		if ply:GetNWBool( "DoubleDamage" ) then
			rocket.Damage = rocket.Damage * 2;
			rocket.DirectHitDamage = rocket.DirectHitDamage * 2;
			rocket:SetNWBool( "DoubleDamage", true );
		end

		rocket:Spawn();
		rocket:SetVelocity( rocketVelocity );

		ply:SetVelocity( ply:EyeAngles():Forward() * -self.RecoilForce );
	end
	-- local rPhys = rocket:GetPhysicsObject();
	-- rPhys:SetVelocity( ply:EyeAngles() );

end

-- function SWEP:CanSecondaryAttack()
-- 	return true;
-- end	

-- function SWEP:SecondaryAttack()
-- 	self:Reload();
-- end