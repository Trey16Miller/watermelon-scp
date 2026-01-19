local wm_on = false

net.Receive("WatermelonEffect_Set", function()
    wm_on = net.ReadBool()
end)

hook.Add("RenderScreenspaceEffects", "WatermelonEffect_GreenScreen", function()
    if not wm_on then return end

    local cm = {}
    cm["$pp_colour_addr"] = 0
    cm["$pp_colour_addg"] = 0.2
    cm["$pp_colour_addb"] = 0
    cm["$pp_colour_brightness"] = -0.05
    cm["$pp_colour_contrast"] = 1.1
    cm["$pp_colour_colour"] = 0.2
    cm["$pp_colour_mulr"] = 0
    cm["$pp_colour_mulg"] = 0.6
    cm["$pp_colour_mulb"] = 0

    DrawColorModify(cm)
end)

end)
