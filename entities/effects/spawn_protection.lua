

function EFFECT:Init( cEffectData )
	self.Entity = cEffectData:GetEntity();

	if not ( self.Entity and IsValid( self.Entity ) ) then return end;
	self.Model = ClientsideModel( self.Entity:GetModel() );
	self.Model:SetMaterial( "models/props_combine/stasisshield_sheet" );
end

function EFFECT:Think()
	if not ( self.Entity and IsValid( self.Entity ) and self.Entity:Armor() > 0 ) then
		print("removed");
		self.Model:Remove();
		return false;
	end

	return true;
end

function EFFECT:Render()
	self.Model:SetModelScale( 1.2 + ( 0.2 * math.sin( CurTime() ) ) );
	render.Model({
		model = self.Entity:GetModel(),
		pos = self.Entity:GetPos(),
		angle = self.Entity:GetAngles()
	}, self.Model);
end