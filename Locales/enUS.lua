local L = LibStub("AceLocale-3.0"):NewLocale("Graphit", "enUS", true)

-- Some descriptions are taken from: https://www.reddit.com/r/wow/comments/902f8e/console_cvar_settings_to_push_wows_detail_a/


L["This is Graphit!"] = true
L["Loaded!"] = true

L["TODO"] = true

L["Resize"] = true

L["shadowModeTooltip"] = "Determines how many shadows are rendered."
L["shadowTextureSizeTooltip"] = "Determines if shadows are rendered with lower or higher resolution."
L["shadowSoftTooltip"] = "Determines whether shadows are rendered more smoothly. Difference might be difficult to spot depending on other shadow settings."

L["worldBaseMipTooltip"] = "Determines the detail level of terrain textures. |cffff0000(Game may be unresponsive for a short time after switching.)"
L["terrainMipLevelTooltip"] = "Determines the quality of terrain texture blending. |cffff0000(Game may be unresponsive for a short time after switching to 'low' while worldBaseMipTooltip is 'high'.)"
L["componentTextureLevelTooltip"] = "Determines the detail level of textures used for player gear such as armor. Only models of newer WoW expansions seem to be affected. |cffff0000(Game may be unresponsive for a short time after switching to 'low' while worldBaseMipTooltip is 'high'.)"

L["graphicsTextureFilteringTooltip"] = "Increase texture sharpness, particularly for textures viewed at an angle."
L["projectedTexturesTooltip"] = "Enables the projection of textures to the environment. E.g. certain AoE spells."




L["horizonStartTooltip"] = "Determines the rendering distance of everything. Maximum values only come into effect when farclip is set to maximum as well."
L["farclipTooltip"] = "Determines how terrain around the horizon is rendered. Maximum values only come into effect when horizonStart is set to maximum as well."

L["terrainLodDistTooltip"] = "Determines at which distance a lower level of details (LOD) for terrain should be used."



L["entityShadowFadeScaleTooltip"] = "Determines at which distance the shadows of objects should be faded out."



L["lodObjectCullSizeTooltip"] = "Objects that would appear smaller than this value will be culled. Interacts with lodObjectCullDist! |cffff0000(Changing this setting may make all objects disappear for an instant before being redrawn.)"
L["lodObjectCullDistTooltip"] = "Objects further away than this value will be culled. The Blizzard settings leave it at 30 for almost every preset. Interacts with lodObjectCullSize! |cffff0000(Changing this setting may make all objects disappear for an instant before being redrawn.)"
L["lodObjectMinSizeTooltip"] = "If lodObjectCullSize and lodObjectCullDist are on their lowest values, this can be set high to avoid big objects (like trees) from being faded. However, the Blizzard settings have it set to 0 for almost every preset. |cffff0000(Changing this setting may make all objects disappear for an instant before being redrawn.)"
L["lodObjectFadeScaleTooltip"] = "Determines the distance at which objects with low level of details (LOD) should be faded out. |cffff0000(Changing this setting may make all objects disappear for an instant before being redrawn.)"







L["graphicsDepthEffects"] = "If you find out what this does, please let me know! :-)"
L["ffxAntiAliasingMode"] = "Named Post-Process AA in den game settings menue. Smoothens all edges in the image."