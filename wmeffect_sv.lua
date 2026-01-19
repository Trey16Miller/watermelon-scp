AddCSLuaFile("autorun/watermelon_effect_cl.lua")

util.AddNetworkString("WatermelonEffect_Set")

WatermelonEffect = WatermelonEffect or {}

local function SendEffect(ply, on)
    if not IsValid(ply) then return end
    net.Start("WatermelonEffect_Set")
        net.WriteBool(on and true or false)
    net.Send(ply)
end

local function ClearTimers(ply)
    if not IsValid(ply) then return end
    local id = "WatermelonEffect_DOT_" .. ply:EntIndex()
    timer.Remove(id)
end

local function RestorePlayer(ply)
    if not IsValid(ply) then return end

    SendEffect(ply, false)
    ply:SetNWBool("WatermelonEffectOn", false)

    if ply.WMOrigModel then
        ply:SetModel(ply.WMOrigModel)
    end

    if ply.WMOrigHull then
        ply:SetHull(ply.WMOrigHull[1], ply.WMOrigHull[2])
        ply:SetHullDuck(ply.WMOrigHull[3], ply.WMOrigHull[4])
        ply:SetViewOffset(ply.WMOrigHull[5])
        ply:SetViewOffsetDucked(ply.WMOrigHull[6])
    end

    ply.WMOrigModel = nil
    ply.WMOrigHull = nil

    ClearTimers(ply)
end

local function TurnIntoWatermelon(ply)
    if not IsValid(ply) or not ply:Alive() then return end

    SendEffect(ply, false)
    ply:SetNWBool("WatermelonEffectOn", false)

    ply.WMOrigModel = ply.WMOrigModel or ply:GetModel()

    local mins, maxs = ply:GetHull()
    local dmins, dmaxs = ply:GetHullDuck()
    ply.WMOrigHull = ply.WMOrigHull or {
        mins, maxs, dmins, dmaxs,
        ply:GetViewOffset(),
        ply:GetViewOffsetDucked()
    }

    ply:StripWeapons()
    ply:SetModel("models/props_junk/watermelon01.mdl")

    local smallMins = Vector(-10, -10, 0)
    local smallMaxs = Vector(10, 10, 18)
    ply:SetHull(smallMins, smallMaxs)
    ply:SetHullDuck(smallMins, smallMaxs)
    ply:SetViewOffset(Vector(0, 0, 16))
    ply:SetViewOffsetDucked(Vector(0, 0, 16))

    ply:SetWalkSpeed(120)
    ply:SetRunSpeed(160)
end

function WatermelonEffect.InfectPlayer(ply, sourceEnt)
    if not IsValid(ply) or not ply:Alive() then return end
    if ply:GetNWBool("WatermelonEffectOn", false) then return end

    ply:SetNWBool("WatermelonEffectOn", true)
    SendEffect(ply, true)

    ply.WMOrigModel = ply.WMOrigModel or ply:GetModel()
    ply.WMOrigHull = ply.WMOrigHull or {
        ply:GetHull(),
        select(2, ply:GetHull()),
        ply:GetHullDuck(),
        select(2, ply:GetHullDuck()),
        ply:GetViewOffset(),
        ply:GetViewOffsetDucked()
    }

    local id = "WatermelonEffect_DOT_" .. ply:EntIndex()
    local startTime = CurTime()
    local transformAfter = 10
    local dmgPerTick = 2
    local tick = 0.5

    timer.Create(id, tick, 0, function()
        if not IsValid(ply) or not ply:Alive() then
            ClearTimers(ply)
            return
        end

        if not ply:GetNWBool("WatermelonEffectOn", false) then
            ClearTimers(ply)
            return
        end

        local attacker = IsValid(sourceEnt) and sourceEnt or game.GetWorld()
        ply:TakeDamage(dmgPerTick, attacker, attacker)

        if ply:Health() <= 1 then
            ply:SetHealth(1)
            ply:SetNWBool("WatermelonEffectOn", false)
            ClearTimers(ply)
            TurnIntoWatermelon(ply)
            return
        end

        if CurTime() - startTime >= transformAfter then
            ply:SetNWBool("WatermelonEffectOn", false)
            ClearTimers(ply)
            TurnIntoWatermelon(ply)
            return
        end
    end)
end

hook.Add("PlayerDeath", "WatermelonEffect_DeathCleanup", function(ply)
    RestorePlayer(ply)
end)

hook.Add("PlayerSpawn", "WatermelonEffect_SpawnCleanup", function(ply)
    timer.Simple(0, function()
        if IsValid(ply) then
            RestorePlayer(ply)
        end
    end)
end)

end)
