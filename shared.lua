ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Watermelon SCP"
ENT.Author = "Craig D"
ENT.Spawnable = true
ENT.AdminSpawnable = true
ENT.Category = "Fun"

function ENT:Initialize()
    if SERVER then
        self:SetModel("models/props_junk/watermelon01.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then phys:Wake() end

        self:SetTrigger(true)
        self:SetUseType(SIMPLE_USE)
    end
end

if SERVER then
    function ENT:StartTouch(ent)
        if not IsValid(ent) or not ent:IsPlayer() then return end
        if ent:GetNWBool("WatermelonEffectOn", false) then return end
        if WatermelonEffect and WatermelonEffect.InfectPlayer then
            WatermelonEffect.InfectPlayer(ent, self)
        end
    end
end
