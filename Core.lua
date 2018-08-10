

Graphit = LibStub("AceAddon-3.0"):NewAddon("Graphit", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Graphit")

Graphit.version = "1.0"



Graphit.availableSettingsIndex = {

  "horizonStart",
  "farclip",
  "---gap---",
  "lodObjectCullDist",
  "lodObjectCullSize",
  "lodObjectMinSize",
  "lodObjectFadeScale",
  "---gap---",
  "terrainLodDist",
  "wmoLodDist",
  "entityLodDist",
  "---gap---",
  "entityShadowFadeScale",
  "shadowMode",
  "shadowSoft",
  "shadowTextureSize",
  "---gap---",
  "graphicsTextureFiltering",
  "projectedTextures",
  "---gap---",
  "worldBaseMip",
  "terrainMipLevel",
  "componentTextureLevel"

}


Graphit.availableSettings = {

  -- ############################################
  -- ############# View distance  ###############
  -- ############################################

  horizonStart = {
    values = {
      "0.000000", "100.000000", "200.000000", "225.000000", "250.000000", "275.000000", "300.000000", "325.000000", "350.000000", "375.000000", "400.000000", "425.000000", "450.000000", "475.000000", "500.000000", "550.000000", "600.000000", "650.000000", "700.000000", "800.000000", "900.000000", "1000.000000", "1100.000000", "1200.000000", "1300.000000", "1400.000000", "1500.000000", "1600.000000", "1700.000000", "1800.000000", "1900.000000", "2000.000000", "2200.000000", "2400.000000", "2600.000000", "2800.000000", "3000.000000", "3500.000000", "4000.000000", "5000.000000", "6000.000000", "7000.000000", "8000.000000", "9000.000000", "10000.000000"
    },
    valueNames = {
      -- Actually used by Blizzard presets:
      -- "400", "600", "800", "1000", "1400", "1700", "1900", "2400", "3000", "4000"
      "0", "100", "200", "225", "250", "275", "300", "325", "350", "375", "400", "425", "450", "475", "500", "550", "600", "650", "700", "800", "900", "1000", "1100", "1200", "1300", "1400", "1500", "1600", "1700", "1800", "1900", "2000", "2200", "2400", "2600", "2800", "3000", "3500", "4000", "5000", "6000", "7000", "8000", "9000", "10000"
    },
    tooltip = L["horizonStartTooltip"]
  },

  farclip = {
    values = {
      "0.000000", "500.000000", "1000.000000",  "1500.000000", "2000.000000", "2500.000000", "3000.000000", "3500.000000", "4000.000000", "4500.000000", "5000.000000", "5500.000000", "6000.000000", "6500.000000","7000.000000", "7500.000000", "8000.000000", "8500.000000", "9000.000000", "9500.000000", "10000.000000"
    },
    valueNames = {
      -- Actually used by Blizzard presets:
      -- "1500", "2000", "3000", "5000", "6000", "7000", "8000", "10000"
      "0", "500", "1000", "1500", "2000", "2500", "3000", "3500", "4000", "4500", "5000", "5500", "6000", "6500", "7000", "7500", "8000", "8500", "9000", "9500", "10000"

    },
    tooltip = L["farclipTooltip"]
  },

  terrainLodDist = {
    values = {
      "0.000000", "25.000000", "50.000000", "75.000000", "100.000000", "125.000000", "150.000000", "175.000000", "200.000000", "225.000000", "250.000000", "275.000000", "300.000000", "325.000000", "350.000000", "375.000000", "400.000000", "425.000000", "450.000000", "475.000000", "500.000000", "525.000000", "550.000000", "575.000000", "600.000000", "625.000000", "650.000000", "750.000000", "800.000000", "900.000000", "1000.000000", "1250.000000", "1500.000000", "1750.000000", "2000.000000", "2500.000000", "3000.000000"
    },
    valueNames = {
      -- Actually used by Blizzard presets:
      -- "200", "225", "250", "350", "400", "500", "600", "650"
      "0", "25", "50", "75", "100", "125", "150", "175", "200", "225", "250", "275", "300", "325", "350", "375", "400", "425", "450", "475", "500", "525", "550", "575", "600", "625", "650", "700", "800", "900", "1000", "1250", "1500", "1750", "2000", "2500", "3000"
    },
    tooltip = L["terrainLodDistTooltip"]
  },

  entityShadowFadeScale = {
    values = {
      "10.000000", "15.000000", "20.000000", "25.000000", "30.000000", "35.000000", "40.000000", "45.000000", "50.000000", "60.000000", "70.000000", "80.000000", "90.000000", "100.000000"
    },
    valueNames = {
      -- Actually used by Blizzard presets:
      -- "10", "15", "20", "25", "30", "40", "50"
      "10", "15", "20", "25", "30", "35", "40", "45", "50", "60", "70", "80", "90", "100"
    },
    tooltip = L["entityShadowFadeScaleTooltip"]
  },

  entityLodDist = {
    values = {
      "5.000000", "6.000000", "7.000000", "8.000000", "9.000000", "10.000000"
    },
    valueNames = {
      -- Actually used by Blizzard presets:
      -- "5", "7", "8", "10"
      "5", "6", "7", "8", "9", "10"
    },
    tooltip = L["entityLodDistTooltip"]
  },

  wmoLodDist = {
    values = {
      "0.000000", "50.000000", "100.000000", "150.000000", "200.000000", "250.000000", "300.000000", "350.000000", "400.000000"
    },
    valueNames = {
      -- Actually used by Blizzard presets:
      -- "250", "300", "350", "400"
      "0", "50", "100", "150", "200", "250", "300", "350", "400"
    },
    tooltip = L["wmoLodDistTooltip"]
  },




  -- ##################################################
  -- ############# Environment details ################
  -- ##################################################

  lodObjectCullSize = {
    values = {
      "100.000000", "90.000000", "80.000000", "70.000000",  "60.000000", "50.000000", "35.000000", "30.000000", "27.000000", "22.000000", "20.000000", "19.000000", "18.000000", "16.000000", "14.000000", "10.000000", "5.000000", "1.000000"
    },
    valueNames = {
      -- Actually used by Blizzard presets:
      -- "35", "30", "27", "22", "20", "19", "18", "16", "14"
      "100", "90", "80", "70", "60", "50", "35", "30", "27", "22", "20", "19", "18", "16", "14", "10", "5", "1"
    },
    tooltip = L["lodObjectCullSizeTooltip"]
  },

  lodObjectCullDist = {
    values = {
      "1.000000", "5.000000", "10.000000", "15.000000", "20.000000", "25.000000", "30.000000", "31.000000", "50.000000", "75.000000", "100.000000", "125.000000", "150.000000", "175.000000", "200.000000"
    },
    valueNames = {
      -- Actually used by Blizzard presets:
      -- "30", "31"
      "1", "5", "10", "15", "20", "25", "30", "31", "50", "75", "100", "125", "150", "175", "200"
    },
    tooltip = L["lodObjectCullDistTooltip"]
  },

  lodObjectMinSize = {
    values = {
      "0.000000", "10.000000", "20.000000", "30.000000", "40.000000", "50.000000", "75.000000", "100.000000", "150.000000", "200.000000", "250.000000", "500.000000", "750.000000", "1000.000000"
    },
    valueNames = {
      -- Actually used by Blizzard presets:
      -- "0", "20", "30"
      "0", "10", "20", "30", "40", "50", "75", "100", "150", "200", "250", "500", "750", "1000"
    },
    tooltip = L["lodObjectMinSizeTooltip"]
  },

  lodObjectFadeScale = {
    values = {
      "50.000000", "60.000000", "70.000000", "80.000000", "90.000000", "100.000000", "125.000000", "150.000000", "200.000000", "250.000000", "300.000000"
    },
    valueNames = {
      -- Actually used by Blizzard presets:
      -- "50", "80", "90", "100", "125", "150"
      "50", "60", "70", "80", "90", "100", "125", "150", "200", "250", "300"
    },
    tooltip = L["lodObjectFadeScaleTooltip"]
  },




  -- ######################################
  -- ############# Shadows ################
  -- ######################################

  shadowMode = {
    values = {
      "0.000000", "1.000000", "2.000000", "3.000000"
    },
    valueNames = {
      "0", "1", "2", "3"
    },
    tooltip = L["shadowModeTooltip"]
  },

  shadowSoft = {
    values = {
      "0.000000", "1.000000"
    },
    valueNames = {
      "off", "on"
    },
    tooltip = L["shadowSoftTooltip"]
  },

  shadowTextureSize = {
    values = {
      "1024.000000", "2048.000000"
    },
    valueNames = {
      "1024", "2048"
    },
    tooltip = L["shadowTextureSizeTooltip"]
  },




  graphicsTextureFiltering = {
    values = {
      "1", "2", "3", "4", "5", "6"
    },
    valueNames = {
      "Bilinear", "Trilinear", "2x Anisotropic", "4x Anisotropic", "8x Anisotropic", "16x Anisotropic"
    },
    tooltip = L["graphicsTextureFilteringTooltip"]
  },




  projectedTextures = {
    values = {
      "0.000000", "1.000000"
    },
    valueNames = {
      "off", "on"
    },
    tooltip = L["projectedTexturesTooltip"]
  },




  -- #################################################
  -- ############# Texture resolution ################
  -- #################################################
  worldBaseMip = {
    values = {
      "2.000000", "1.000000", "0.000000"
    },
    valueNames = {
      "low", "medium", "high"
    },
    tooltip = L["worldBaseMipTooltip"]
  },

  terrainMipLevel = {
    values = {
      "1.000000", "0.000000"
    },
    valueNames = {
      "low", "high"
    },
    tooltip = L["terrainMipLevelTooltip"]
  },

  componentTextureLevel = {
    values = {
      "1.000000", "0.000000"
    },
    valueNames = {
      "low", "high"
    },
    tooltip = L["componentTextureLevelTooltip"]
  }--,

}



local defaults = {
  global = {
    todoPresets = {}
  }
}




-- Returns the index of this CVAR's current value.
-- This is necessary to know which (if any) is the next (+) or previous (-) value.
function Graphit:GetValueIndex(cVarName)

  local value = GetCVar(cVarName)

  local valueIndex = 1
  for k,v in pairs(self.availableSettings[cVarName].values) do
    if ((v == value) or (tonumber(v) == tonumber(value))) then
      break
    end
    valueIndex = valueIndex + 1
  end

  return valueIndex
end



function Graphit:SetSetting(cVarName, newValueIndex)

  -- Set the CVAR.
  local newValue = self.availableSettings[cVarName].values[newValueIndex]
  SetCVar(cVarName, newValue)

  -- self:Print ("Setting " .. cVarName .. " to " .. newValue)


  -- projectedTextures needs very peculiar special treatment:
  -- graphicsProjectedTextures has to be set as well, even though in case of "enabled"
  -- "graphicsProjectedTextures 2" is not even saved in config.wtf.
  if (cVarName == "projectedTextures") then
    if (newValueIndex == 1) then   -- disabled
      SetCVar("graphicsProjectedTextures", 1)
    elseif (newValueIndex == 2) then   -- enabled
      SetCVar("graphicsProjectedTextures", 2)
    end
  end


  -- Check if factory presets of the video options panel are fulfilled.
  if ((cVarName == "shadowMode") or (cVarName == "shadowSoft") or (cVarName == "shadowTextureSize")) then
    self:CheckForShadowFactoryPreset()
  end

  if ((cVarName == "worldBaseMip") or (cVarName == "terrainMipLevel") or (cVarName == "componentTextureLevel")) then
    self:CheckForTextureResolutionFactoryPreset()
  end

  if ((cVarName == "farclip") or (cVarName == "horizonStart") or (cVarName == "entityShadowFadeScale") or (cVarName == "entityLodDist") or (cVarName == "terrainLodDist") or (cVarName == "wmoLodDist")) then
    self:CheckForViewDistanceFactoryPreset()
  end

  if ((cVarName == "lodObjectCullSize") or (cVarName == "lodObjectCullDist") or (cVarName == "lodObjectMinSize") or (cVarName == "lodObjectFadeScale")) then
    self:CheckForEnvironmentDetailFactoryPreset()
  end



  -- Refresh the stock video options panel.
  for k,v in pairs(VideoData) do
		_G[k].selectedID = nil;
	end
	VideoOptionsPanel_Refresh(Display_);
	VideoOptionsPanel_Refresh(Graphics_);
	VideoOptionsPanel_Refresh(RaidGraphics_);
	VideoOptionsPanel_Refresh(Advanced_);


  -- Refresh all GUI labels and sliders of graphit.
  -- This is a little redundant because
  -- self:UpdateSettingValueLabel(cVarName, newValueIndex, self.valueLabels[cVarName])
  -- should normally suffice.
  -- But updating all labels will let us know immediately, if something went wrong (e.g. when setting the factory preset variables also changes other variables...).
  self:PossibleSettingsUpdate();

end




-- Check if the current combination of shadow settings is one of WOW's "factory" graphicsShadowQuality defaults.
function Graphit:CheckForShadowFactoryPreset()

  shadowModeValue = GetCVar("shadowMode")
  shadowSoftValue = GetCVar("shadowSoft")
  shadowTextureSizeValue = GetCVar("shadowTextureSize")
  -- print (shadowModeValue .. " " .. shadowSoftValue .. " " .. shadowTextureSizeValue)

  -- Ultra High
  if ((tonumber(shadowModeValue) == 3) and
      (tonumber(shadowSoftValue) == 1) and
      (tonumber(shadowTextureSizeValue) == 2048)) then
    -- print ("Ultra High")
    return SetCVar("graphicsShadowQuality", 6)
  end
  -- Ultra
  if ((tonumber(shadowModeValue) == 2) and
      (tonumber(shadowSoftValue) == 1) and
      (tonumber(shadowTextureSizeValue) == 2048)) then
    -- print ("Ultra")
    return SetCVar("graphicsShadowQuality", 5)
  end
  -- High
  if ((tonumber(shadowModeValue) == 2) and
      (tonumber(shadowSoftValue) == 0) and
      (tonumber(shadowTextureSizeValue) == 2048)) then
    -- print ("High")
    return SetCVar("graphicsShadowQuality", 4)
  end
  -- Good
  if ((tonumber(shadowModeValue) == 1) and
      (tonumber(shadowSoftValue) == 0) and
      (tonumber(shadowTextureSizeValue) == 1024)) then
    -- print ("Good")
    return SetCVar("graphicsShadowQuality", 3)
  end
  -- Fair
  if ((tonumber(shadowModeValue) == 0) and
      (tonumber(shadowSoftValue) == 0) and
      (tonumber(shadowTextureSizeValue) == 1024)) then
    -- print ("Fair")
    return SetCVar("graphicsShadowQuality", 2)
  end

  -- print ("Custom")
  SetCVar("graphicsShadowQuality", 0)
  -- Must set the variables again, because setting graphicsShadowQuality to 0 will reset the others.
  SetCVar("shadowMode", shadowModeValue)
  SetCVar("shadowSoft", shadowSoftValue)
  SetCVar("shadowTextureSize", shadowTextureSizeValue)

end



-- Check if the current combination of texture resolution settings is one of WOW's "factory" graphicsTextureResolution defaults.
function Graphit:CheckForTextureResolutionFactoryPreset()

  worldBaseMipValue = GetCVar("worldBaseMip")
  terrainMipLevelValue = GetCVar("terrainMipLevel")
  componentTextureLevelValue = GetCVar("componentTextureLevel")
  -- print (worldBaseMipValue .. " " .. terrainMipLevelValue .. " " .. componentTextureLevelValue)

  -- High
  if ((tonumber(worldBaseMipValue) == 0) and
      (tonumber(terrainMipLevelValue) == 0) and
      (tonumber(componentTextureLevelValue) == 0)) then
    -- print ("High")
    return SetCVar("graphicsTextureResolution", 3)
  end
  -- Fair
  if ((tonumber(worldBaseMipValue) == 1) and
      (tonumber(terrainMipLevelValue) == 1) and
      (tonumber(componentTextureLevelValue) == 1)) then
    -- print ("Fair")
    return SetCVar("graphicsTextureResolution", 2)
  end
  -- Low
  if ((tonumber(worldBaseMipValue) == 2) and
      (tonumber(terrainMipLevelValue) == 1) and
      (tonumber(componentTextureLevelValue) == 1)) then
    -- print ("Low")
    return SetCVar("graphicsTextureResolution", 1)
  end

  -- print ("Custom")
  SetCVar("graphicsTextureResolution", 0)
  -- Must set the variables again, because setting graphicsTextureResolution to 0 will reset the others.
  SetCVar("worldBaseMip", worldBaseMipValue)
  SetCVar("terrainMipLevel", terrainMipLevelValue)
  SetCVar("componentTextureLevel", componentTextureLevelValue)

end



-- Check if the current combination of view distance settings is one of WOW's "factory" graphicsViewDistance defaults.
function Graphit:CheckForViewDistanceFactoryPreset()

  farclipValue = GetCVar("farclip")
  horizonStartValue = GetCVar("horizonStart")
  terrainLodDistValue = GetCVar("terrainLodDist")
  wmoLodDistValue = GetCVar("wmoLodDist")
  entityShadowFadeScaleValue = GetCVar("entityShadowFadeScale")
  entityLodDistValue = GetCVar("entityLodDist")

  -- 10
  if ((tonumber(farclipValue) >= 10000) and
      (tonumber(horizonStartValue) >= 4000) and
      (tonumber(entityShadowFadeScaleValue) >= 50) and
      (tonumber(entityLodDistValue) >= 10) and
      (tonumber(terrainLodDistValue) >= 650) and
      (tonumber(wmoLodDistValue) >= 400)) then
    -- print ("10")
    SetCVar("graphicsViewDistance", 10)
  -- 9
  elseif ((tonumber(farclipValue) >= 8000) and
      (tonumber(horizonStartValue) >= 3000) and
      (tonumber(entityShadowFadeScaleValue) >= 40) and
      (tonumber(entityLodDistValue) >= 10) and
      (tonumber(terrainLodDistValue) >= 650) and
      (tonumber(wmoLodDistValue) >= 400)) then
    -- print ("9")
    SetCVar("graphicsViewDistance", 9)
  -- 8
  elseif ((tonumber(farclipValue) >= 8000) and
      (tonumber(horizonStartValue) >= 2400) and
      (tonumber(entityShadowFadeScaleValue) >= 30) and
      (tonumber(entityLodDistValue) >= 10) and
      (tonumber(terrainLodDistValue) >= 600) and
      (tonumber(wmoLodDistValue) >= 400)) then
    -- print ("8")
    SetCVar("graphicsViewDistance", 8)
  -- 7
  elseif ((tonumber(farclipValue) >= 7000) and
      (tonumber(horizonStartValue) >= 1900) and
      (tonumber(entityShadowFadeScaleValue) >= 25) and
      (tonumber(entityLodDistValue) >= 10) and
      (tonumber(terrainLodDistValue) >= 500) and
      (tonumber(wmoLodDistValue) >= 400)) then
    -- print ("7")
    SetCVar("graphicsViewDistance", 7)
  -- 6
  elseif ((tonumber(farclipValue) >= 6000) and
      (tonumber(horizonStartValue) >= 1700) and
      (tonumber(entityShadowFadeScaleValue) >= 20) and
      (tonumber(entityLodDistValue) >= 8) and
      (tonumber(terrainLodDistValue) >= 500) and
      (tonumber(wmoLodDistValue) >= 350)) then
    -- print ("6")
    SetCVar("graphicsViewDistance", 6)
  -- 5
  elseif ((tonumber(farclipValue) >= 6000) and
      (tonumber(horizonStartValue) >= 1400) and
      (tonumber(entityShadowFadeScaleValue) >= 20) and
      (tonumber(entityLodDistValue) >= 8) and
      (tonumber(terrainLodDistValue) >= 400) and
      (tonumber(wmoLodDistValue) >= 350)) then
    -- print ("5")
    SetCVar("graphicsViewDistance", 5)
  -- 4
  elseif ((tonumber(farclipValue) >= 5000) and
      (tonumber(horizonStartValue) >= 1000) and
      (tonumber(entityShadowFadeScaleValue) >= 15) and
      (tonumber(entityLodDistValue) >= 7) and
      (tonumber(terrainLodDistValue) >= 350) and
      (tonumber(wmoLodDistValue) >= 300)) then
    -- print ("4")
    SetCVar("graphicsViewDistance", 4)
  -- 3
  elseif ((tonumber(farclipValue) >= 3000) and
      (tonumber(horizonStartValue) >= 800) and
      (tonumber(entityShadowFadeScaleValue) >= 10) and
      (tonumber(entityLodDistValue) >= 5) and
      (tonumber(terrainLodDistValue) >= 250) and
      (tonumber(wmoLodDistValue) >= 300)) then
    -- print ("3")
    SetCVar("graphicsViewDistance", 3)
  -- 2
  elseif ((tonumber(farclipValue) >= 2000) and
      (tonumber(horizonStartValue) >= 600) and
      (tonumber(entityShadowFadeScaleValue) >= 10) and
      (tonumber(entityLodDistValue) >= 5) and
      (tonumber(terrainLodDistValue) >= 225) and
      (tonumber(wmoLodDistValue) >= 250)) then
    -- print ("2")
    SetCVar("graphicsViewDistance", 2)
  -- 1
  elseif ((tonumber(farclipValue) <= 1500) and
      (tonumber(horizonStartValue) <= 400) and
      (tonumber(entityShadowFadeScaleValue) <= 10) and
      (tonumber(entityLodDistValue) <= 5) and
      (tonumber(terrainLodDistValue) <= 200) and
      (tonumber(wmoLodDistValue) <= 250)) then
    -- print ("1")
    SetCVar("graphicsViewDistance", 1)
  end

  -- Must set the variables again, because setting graphicsViewDistance will reset the others.
  SetCVar("farclip", farclipValue)
  SetCVar("horizonStart", horizonStartValue)
  SetCVar("entityShadowFadeScale", entityShadowFadeScaleValue)
  SetCVar("entityLodDist", entityLodDistValue)
  SetCVar("terrainLodDist", terrainLodDistValue)
  SetCVar("wmoLodDist", wmoLodDistValue)

end



-- Check if the current combination of environment detail settings is one of WOW's "factory" graphicsEnvironmentDetail defaults.
function Graphit:CheckForEnvironmentDetailFactoryPreset()

  lodObjectCullSizeValue = GetCVar("lodObjectCullSize")
  lodObjectCullDistValue = GetCVar("lodObjectCullDist")
  lodObjectMinSizeValue = GetCVar("lodObjectMinSize")
  lodObjectFadeScaleValue = GetCVar("lodObjectFadeScale")

  -- 10
  if ((tonumber(lodObjectCullSizeValue) <= 14) and
      (tonumber(lodObjectCullDistValue) >= 30) and
      (tonumber(lodObjectMinSizeValue) >= 20) and
      (tonumber(lodObjectFadeScaleValue) >= 150)) then
    -- print ("10")
    SetCVar("graphicsEnvironmentDetail", 10)
  -- 9
  elseif ((tonumber(lodObjectCullSizeValue) <= 16) and
      (tonumber(lodObjectCullDistValue) >= 30) and
      (tonumber(lodObjectMinSizeValue) >= 30) and
      (tonumber(lodObjectFadeScaleValue) >= 125)) then
    -- print ("9")
    SetCVar("graphicsEnvironmentDetail", 9)
  -- 8
  elseif ((tonumber(lodObjectCullSizeValue) <= 18) and
      (tonumber(lodObjectCullDistValue) >= 31) and
      (tonumber(lodObjectMinSizeValue) >= 0) and
      (tonumber(lodObjectFadeScaleValue) >= 100)) then
    -- print ("8")
    SetCVar("graphicsEnvironmentDetail", 8)
  -- 7
  elseif ((tonumber(lodObjectCullSizeValue) <= 18) and
      (tonumber(lodObjectCullDistValue) >= 30) and
      (tonumber(lodObjectMinSizeValue) >= 0) and
      (tonumber(lodObjectFadeScaleValue) >= 100)) then
    -- print ("7")
    SetCVar("graphicsEnvironmentDetail", 7)
  -- 6
  elseif ((tonumber(lodObjectCullSizeValue) <= 19) and
      (tonumber(lodObjectCullDistValue) >= 30) and
      (tonumber(lodObjectMinSizeValue) >= 0) and
      (tonumber(lodObjectFadeScaleValue) >= 90)) then
    -- print ("6")
    SetCVar("graphicsEnvironmentDetail", 6)
  -- 5
  elseif ((tonumber(lodObjectCullSizeValue) <= 20) and
      (tonumber(lodObjectCullDistValue) >= 30) and
      (tonumber(lodObjectMinSizeValue) >= 0) and
      (tonumber(lodObjectFadeScaleValue) >= 90)) then
    -- print ("5")
    SetCVar("graphicsEnvironmentDetail", 5)
  -- 4
  elseif ((tonumber(lodObjectCullSizeValue) <= 22) and
      (tonumber(lodObjectCullDistValue) >= 30) and
      (tonumber(lodObjectMinSizeValue) >= 0) and
      (tonumber(lodObjectFadeScaleValue) >= 80)) then
    -- print ("5")
    SetCVar("graphicsEnvironmentDetail", 5)
  -- 3
  elseif ((tonumber(lodObjectCullSizeValue) <= 27) and
      (tonumber(lodObjectCullDistValue) >= 30) and
      (tonumber(lodObjectMinSizeValue) >= 0) and
      (tonumber(lodObjectFadeScaleValue) >= 80)) then
    -- print ("3")
    SetCVar("graphicsEnvironmentDetail", 3)
  -- 2
  elseif ((tonumber(lodObjectCullSizeValue) <= 30) and
      (tonumber(lodObjectCullDistValue) >= 30) and
      (tonumber(lodObjectMinSizeValue) >= 0) and
      (tonumber(lodObjectFadeScaleValue) >= 50)) then
    -- print ("2")
    SetCVar("graphicsEnvironmentDetail", 2)
  -- 1
  elseif ((tonumber(lodObjectCullSizeValue) <= 35) and
      (tonumber(lodObjectCullDistValue) >= 30) and
      (tonumber(lodObjectMinSizeValue) >= 0) and
      (tonumber(lodObjectFadeScaleValue) >= 50)) then
    -- print ("1")
    SetCVar("graphicsEnvironmentDetail", 1)
  end

  -- Must set the variables again, because setting graphicsEnvironmentDetail will reset the others.
  SetCVar("lodObjectCullSize", lodObjectCullSizeValue)
  SetCVar("lodObjectCullDist", lodObjectCullDistValue)
  SetCVar("lodObjectMinSize", lodObjectMinSizeValue)
  SetCVar("lodObjectFadeScale", lodObjectFadeScaleValue)

end







function Graphit:UpdateSettingValueLabel(cVarName, newValueIndex, label)

  -- print ("Putting label " .. newValueIndex .. " for " .. cVarName)

  local newValueName = self.availableSettings[cVarName].valueNames[newValueIndex]
  if newValueName ~= true then
    label:SetText("|cffffffff" .. newValueName )
  else
    label:SetText("|cffffffff" .. newValue )
  end

  -- Also update the status bar.
  self.valueStatusBars[cVarName]:SetValue(newValueIndex)

end



function Graphit:TryToSetSetting(cVarName, increase)

  local valueIndex = self:GetValueIndex(cVarName)

  local numberOfSettings = 0
  for k,v in pairs(self.availableSettings[cVarName].values) do
    -- print (cVarName .. ": " .. k .. ", " .. v)
    numberOfSettings = numberOfSettings + 1
  end

  -- print (valueIndex .. " (" .. self.availableSettings[cVarName].values[valueIndex] .. ") is a index " .. valueIndex)

  if increase then
    if valueIndex == numberOfSettings then
      -- print ("Already max value!")
      return
    end

    -- Set the next higher value.
    self:SetSetting(cVarName, valueIndex+1)

  else -- decrease
    if valueIndex == 1 then
      -- print ("Already min value!")
      return
    end

    -- Set the next lower value.
    self:SetSetting(cVarName, valueIndex-1)

  end

end









function Graphit:OnInitialize()

  self.db = LibStub("AceDB-3.0"):New("GraphitDB", defaults, true)

end



function Graphit:OnEnable()

  self:RegisterChatCommand("graphit", "ChatCommand")
  self:RegisterChatCommand("grt", "ChatCommand")

  self:RegisterEvent("ZONE_CHANGED", "ZoneChanged");
  self:RegisterEvent("ZONE_CHANGED_INDOORS", "ZoneChanged");


  -- Still needed to catch variable changes via console/macros.
  self:RegisterEvent("CONSOLE_MESSAGE", "PossibleSettingsUpdate");


  -- Hook BlizzardOptionsPanel_SetCVarSafe function to update graphit,
  -- whenever settings are changed by the game (e.g. video options panel).
  local old_BlizzardOptionsPanel_SetCVarSafe = BlizzardOptionsPanel_SetCVarSafe;
  function BlizzardOptionsPanel_SetCVarSafe(...)
    self:PossibleSettingsUpdate();
    return old_BlizzardOptionsPanel_SetCVarSafe(...);
  end


  -- Flag variables belonging to Graphit.
  self.frameShown = false
  self.frameBuilt = false

  self:BuildFrame()
  -- DEBUG: Comment this to have graphit window shown after reloading UI.
  -- self:HideFrame()

end




function Graphit:OnDisable()

  -- TODO: Undo OnEnable stuff.

end





-- If I make these members of Graphit, I cannot bind the function with setScript.

-- To calculate the average FPS.
local Graphit_timeSinceLastUpdate = 0
local Graphit_fpsSumSinceLastUpdate = 0
local Graphit_fpsNumSinceLastUpdate = 0

local function Graphit_UpdateFramerate(self, elapsed)

  Graphit_timeSinceLastUpdate   = Graphit_timeSinceLastUpdate + elapsed
  Graphit_fpsSumSinceLastUpdate = Graphit_fpsSumSinceLastUpdate + GetFramerate()
  Graphit_fpsNumSinceLastUpdate = Graphit_fpsNumSinceLastUpdate + 1

  if Graphit_timeSinceLastUpdate > .25 then
    local avgFps = Graphit_fpsSumSinceLastUpdate/Graphit_fpsNumSinceLastUpdate
    Graphit_titleFrame.fpsint:SetText("|cffffffff" .. floor(avgFps) )
    Graphit_titleFrame.fpsdec:SetText("|cffffffff." .. floor(10*avgFps)%10 )
    Graphit_timeSinceLastUpdate = 0
    Graphit_fpsSumSinceLastUpdate = 0
    Graphit_fpsNumSinceLastUpdate = 0
	end

end


local function Graphit_MainFrameSizeChanged(self, width, height)

  local availableSpace = height - self.titleFrame:GetHeight() - 20
  local neededSpace = self.scrollFrame.contentFrame:GetHeight()

  local lastScrollPosition = self.scrollFrame.scrollbar:GetValue()

  -- Do we need to scroll?
  if (neededSpace > availableSpace) then
    self.scrollFrame.scrollbar:SetMinMaxValues(0, neededSpace - availableSpace)
    self.scrollFrame.scrollbar:SetValue(lastScrollPosition)
    self.scrollFrame.scrollbar:Show()
  else
    self.scrollFrame.scrollbar:SetValue(0)
    self.scrollFrame.scrollbar:SetMinMaxValues(0, 0)
    self.scrollFrame.scrollbar:Hide()
  end

end




function Graphit:BuildFrame()

  if self.frameShown then
    self:Print("Frame is already shown.")
    return
  end

  if self.frameBuilt then
    self:Print("Frame is already built and hidden. Now showing!")
    self:ShowFrame()
    return
  end


  -- self:Print("Building frame!")
  self.frameShown = true
  self.frameBuilt = true


  local mainFrame = CreateFrame("Frame", nil, UIParent)
  mainFrame:SetPoint("TOPRIGHT", "Minimap", "BOTTOMLEFT", 40, -30)
  mainFrame:SetFrameStrata("FULLSCREEN")
  mainFrame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
                        tile = true, tileSize = 16, edgeSize = 16,
                        insets = { left = 4, right = 4, top = 4, bottom = 4 }})
  mainFrame:SetBackdropColor(0.0, 0.0, 0.0, 1.0)



  -- Enable dragging.
  mainFrame:SetMovable(true)
  mainFrame:EnableMouse(true)
  mainFrame:RegisterForDrag("LeftButton")
  mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
  mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
  mainFrame:SetClampedToScreen(true)


  -- Set the dimensions.
  local fixedWidth = 230
  local minHeight = 200
  local maxHeight = 800
  local initHeight = 400
  local sliderOffset = 26

  mainFrame:SetWidth(fixedWidth)
  mainFrame:SetHeight(initHeight)

  -- Enable resizing.
  mainFrame:SetResizable(true)
  mainFrame:SetMaxResize(fixedWidth, maxHeight)
  mainFrame:SetMinResize(fixedWidth, minHeight)

  -- For mouse wheel scrolling.
  mainFrame:EnableMouseWheel(true)

  self.mainFrame = mainFrame




  -- Set the window title.
  local titleFrame = CreateFrame("Frame", "Graphit_titleFrame", self.mainFrame)
  titleFrame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background",
                        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border",
                        tile = true, tileSize = 16, edgeSize = 16,
                        insets = { left = 4, right = 4, top = 4, bottom = 4 }})
  titleFrame:SetBackdropColor(0.0, 0.0, 0.0, 0.0)

  titleFrame:SetWidth(self.mainFrame:GetWidth())
  titleFrame:SetHeight(26)
  titleFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 0, 0)

  titleFrame.title = titleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  titleFrame.title:SetPoint("TOPLEFT", titleFrame, "TOPLEFT", 12, -8)
  titleFrame.title:SetText("|cffffffffGRAPHIT " .. self.version)

  -- Set the FPS display.
  titleFrame.fps = titleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  titleFrame.fps:SetPoint("LEFT", titleFrame.title, "RIGHT", 28, 0)
  titleFrame.fps:SetText("|cffffffffFPS :")
  titleFrame.fpsint = titleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  titleFrame.fpsint:SetPoint("RIGHT", titleFrame.fps, "RIGHT", 28, 0)
  titleFrame.fpsdec = titleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  titleFrame.fpsdec:SetPoint("LEFT", titleFrame.fpsint, "RIGHT", 0, 0)

  self.mainFrame.titleFrame = titleFrame


  -- Set close button.
  local closeButton = CreateFrame("Button", nil, self.mainFrame, "UIPanelCloseButtonNoScripts")
  closeButton:SetPoint("TOPRIGHT", self.mainFrame, "TOPRIGHT", 3, 3.5)
  closeButton:SetScript("OnClick",
    function()
      PlaySound(851) -- SOUNDKIT.IG_MAINMENU_CLOSE
      self:HideFrame()
    end
  )

  self.mainFrame.closeButton = closeButton



  -- Set the scrollable content window.
  local scrollFrame = CreateFrame("ScrollFrame", nil, self.mainFrame)

  -- scrollFrame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background" })
  -- scrollFrame:SetBackdropColor(0.0, 0.0, 1.0, 1.0)

  scrollFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 0, -self.mainFrame.titleFrame:GetHeight())
  scrollFrame:SetPoint("BOTTOMRIGHT", self.mainFrame, "BOTTOMRIGHT", -sliderOffset, 6)

  scrollFrame:SetResizable(true)
  scrollFrame:SetMaxResize(fixedWidth - sliderOffset, maxHeight - self.mainFrame.titleFrame:GetHeight())
  scrollFrame:SetMinResize(fixedWidth - sliderOffset, minHeight - self.mainFrame.titleFrame:GetHeight())

  self.mainFrame.scrollFrame = scrollFrame



  -- Scrollbar.
  local scrollbar = CreateFrame("Slider", nil, self.mainFrame.scrollFrame, "UIPanelScrollBarTemplate")
  scrollbar:SetPoint("TOPLEFT", self.mainFrame.scrollFrame, "TOPRIGHT", 5, -15)
  scrollbar:SetPoint("BOTTOMLEFT", self.mainFrame.scrollFrame, "BOTTOMRIGHT", 5, 15)
  scrollbar:SetValueStep(1)
  scrollbar.scrollStep = 1

  scrollbar:SetScript("OnValueChanged",
    function (self, value)
      self:GetParent():SetVerticalScroll(value)
    end
  )

  self.mainFrame.scrollFrame.scrollbar = scrollbar




  -- Content frame.
  local contentFrame = CreateFrame("Frame", nil, self.mainFrame.scrollFrame)
  contentFrame:SetSize(fixedWidth - sliderOffset, 1)


  self.mainFrame.scrollFrame.contentFrame = contentFrame


  self.mainFrame.scrollFrame:SetScrollChild(self.mainFrame.scrollFrame.contentFrame)


  local numberOfSettings = 0
  local numberOfGaps = 0
  for k,v in pairs(self.availableSettingsIndex) do
    -- print (v .. " is at " .. k)

    self:PutSetting(v, numberOfSettings, numberOfGaps, self.mainFrame.scrollFrame.contentFrame)

    if (v == "---gap---") then
      numberOfGaps = numberOfGaps + 1
    else
      numberOfSettings = numberOfSettings + 1
    end

  end


  Graphit_MainFrameSizeChanged(self.mainFrame, self.mainFrame:GetWidth(), self.mainFrame:GetHeight())




  -- Resize button.
  local resizeButton = CreateFrame("Button", nil, self.mainFrame, "UIPanelButtonTemplate")
  resizeButton:SetWidth(150)
  resizeButton:SetHeight(20)
  resizeButton:SetPoint("BOTTOM", self.mainFrame, "BOTTOM", 0, -5)
  resizeButton:SetText(L["Resize"])
  resizeButton:SetScript("OnMouseDown",
    function()
      -- Don't know why StartSizing sometimes sets a new bigger size...
      -- self:Print("Height before StartSizing: " .. mainFrame:GetHeight())
      local preserveHeight = self.mainFrame:GetHeight()
      self.mainFrame:StartSizing("BOTTOM")
      -- self:Print("Height after StartSizing: " .. mainFrame:GetHeight())
      self.mainFrame:SetHeight(preserveHeight)
    end
  )
  resizeButton:SetScript("OnMouseUp",
    function()
      self.mainFrame:StopMovingOrSizing()
    end
  )

  resizeButton:SetFrameStrata("FULLSCREEN_DIALOG")

  self.mainFrame.resizeButton = resizeButton



  -- Register the functions.
  self.mainFrame:SetScript("OnUpdate", Graphit_UpdateFramerate)

  self.mainFrame:SetScript("OnSizeChanged", Graphit_MainFrameSizeChanged)

  self.mainFrame:SetScript("OnMouseWheel",
    function(self, delta)
      self.scrollFrame.scrollbar:SetValue(self.scrollFrame.scrollbar:GetValue() - 15*delta)
    end
  )

end






function Graphit:cVarNameLabelOnEnter(cVarName, ownerFrame)
  GameTooltip:SetOwner(ownerFrame, "ANCHOR_TOPRIGHT")

  GameTooltip:AddLine(cVarName, 1, 0.8, 0, 1, 1)
  GameTooltip:AddLine(self.availableSettings[cVarName].tooltip, 1, 1, 1, 1, 1)
  GameTooltip:Show()
end

function Graphit:cVarNameLabelOnLeave(cVarName)
  GameTooltip:Hide()
end





-- Storing the links to value labels.
Graphit.valueLabels = {}

-- Storing the valueStatusBars.
Graphit.valueStatusBars = {}



function Graphit:PutSetting(cVarName, numberOfSettings, numberOfGaps, targetFrame)

  -- Where to put this frame in the targetFrame.
  local topOffset = 10
  local settingElementHeight = 50
  local gapHeight = 25


  -- If this call was to place a gap, we just increase the targetFrame's height by one gap height and return.
  if (cVarName == "---gap---") then
    targetFrame:SetSize(targetFrame:GetWidth(), topOffset + settingElementHeight*numberOfSettings + gapHeight*(numberOfGaps+1))
    return
  end


  -- Else this call is to place a setting element, so we increase the targetFrame's height by one setting element height.
  targetFrame:SetSize(targetFrame:GetWidth(), topOffset + settingElementHeight*(numberOfSettings+1) + gapHeight*numberOfGaps)

  -- This becomes the top x-coordinate of this setting element.
  local top = -topOffset -settingElementHeight*numberOfSettings -gapHeight*numberOfGaps

  -- Create a new frame for this settings element.
  local SettingElementFrame = CreateFrame("Frame", nil, targetFrame)
  SettingElementFrame:SetWidth(targetFrame:GetWidth())
  SettingElementFrame:SetHeight(settingElementHeight)
  SettingElementFrame:SetPoint("TOPLEFT", targetFrame, "TOPLEFT", 0, top)


  -- Create a frame for the setting name.
  local cVarNameLabelFrame = CreateFrame("Frame", nil, SettingElementFrame)

  -- Put the setting name font string.
  cVarNameLabelFrame.cVarNameLabel = SettingElementFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  cVarNameLabelFrame.cVarNameLabel:SetPoint("TOPLEFT", SettingElementFrame, "TOPLEFT", 15, -8)
  cVarNameLabelFrame.cVarNameLabel:SetText("|cffffffff" .. cVarName)

  -- Increase the frame to the size of the font string.
  cVarNameLabelFrame:SetPoint("TOPLEFT", cVarNameLabelFrame.cVarNameLabel, "TOPLEFT", 0, 0)
  cVarNameLabelFrame:SetPoint("BOTTOMRIGHT", cVarNameLabelFrame.cVarNameLabel, "BOTTOMRIGHT", 0, 0)

  -- Assing tooltip functions.
  cVarNameLabelFrame:SetScript("OnEnter", function()
    self:cVarNameLabelOnEnter(cVarName, cVarNameLabelFrame)
  end )

  cVarNameLabelFrame:SetScript("OnLeave", function()
    self:cVarNameLabelOnLeave(cVarName)
  end )


  local MinusButton = CreateFrame("Button", nil, SettingElementFrame, "UIPanelButtonTemplate")
  MinusButton:SetWidth(25)
  MinusButton:SetPoint("TOPLEFT", SettingElementFrame, "TOPLEFT", 30, -24)
  MinusButton:SetText("-")
  MinusButton:SetScript("OnClick", function()
    PlaySound(799) -- SOUNDKIT.GS_TITLE_OPTION_EXIT
    self:TryToSetSetting(cVarName, false)
  end )

  local PlusButton = CreateFrame("Button", nil, SettingElementFrame, "UIPanelButtonTemplate")
  PlusButton:SetWidth(25)
  PlusButton:SetPoint("TOPRIGHT", SettingElementFrame, "TOPRIGHT", -5, -24)
  PlusButton:SetText("+")
  PlusButton:SetScript("OnClick", function()
    PlaySound(799) -- SOUNDKIT.GS_TITLE_OPTION_EXIT
    self:TryToSetSetting(cVarName, true)
  end )


  -- Get the number of values for this setting.
  local numberOfSettings = 0
  for k,v in pairs(self.availableSettings[cVarName].values) do
    -- print (cVarName .. ": " .. k .. ", " .. v)
    numberOfSettings = numberOfSettings + 1
  end

  self.valueStatusBars[cVarName] = CreateFrame("StatusBar", nil, SettingElementFrame)
  self.valueStatusBars[cVarName]:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  self.valueStatusBars[cVarName]:GetStatusBarTexture():SetHorizTile(false)
  self.valueStatusBars[cVarName]:SetMinMaxValues(1, numberOfSettings)
  self.valueStatusBars[cVarName]:SetHeight(12)
  self.valueStatusBars[cVarName]:SetPoint("LEFT", MinusButton, "RIGHT", 4, 0)
  self.valueStatusBars[cVarName]:SetPoint("RIGHT", PlusButton, "LEFT", -5, 0)
  self.valueStatusBars[cVarName]:SetStatusBarColor(0,0.5,0,0.8)

  local statusBarBorder = CreateFrame("Frame", nil, self.valueStatusBars[cVarName])
  statusBarBorder:SetPoint("TOPLEFT", self.valueStatusBars[cVarName], "TOPLEFT", -3, 4)
  statusBarBorder:SetPoint("BOTTOMRIGHT", self.valueStatusBars[cVarName], "BOTTOMRIGHT", 4, -5)
  statusBarBorder:SetBackdrop({
      bgFile = nil,
      edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
      tile = true, tileSize = 32, edgeSize = 16,
      insets = { left = 0, right = 0, top = 0, bottom = 0}
    })
  statusBarBorder:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)


  local SettingElementLabelFrame = CreateFrame("Frame", nil, statusBarBorder)
  SettingElementLabelFrame:SetPoint("CENTER", SettingElementFrame, "TOPLEFT", (55 + 160)/2 , -34)

  self.valueLabels[cVarName] = SettingElementLabelFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
  self.valueLabels[cVarName]:SetPoint("CENTER", statusBarBorder, "CENTER")
  -- print (cVarName .. " is currently " .. GetCVar(cVarName) .. " which is index " .. self:GetValueIndex(cVarName))
  self:UpdateSettingValueLabel(cVarName, self:GetValueIndex(cVarName), self.valueLabels[cVarName])

end





function Graphit:ShowFrame()
  self.mainFrame:Show()
  self.frameShown = true
end

function Graphit:HideFrame()
  self.mainFrame:Hide()
  self.frameShown = false
end



function Graphit:ChatCommand()
  self:ShowFrame()
end







function Graphit:PossibleSettingsUpdate(event, arg1)
  -- self:Print("PossibleSettingsUpdate")

  for k,v in pairs(self.availableSettingsIndex) do
    if (v ~= "---gap---") then
      self:UpdateSettingValueLabel(v, self:GetValueIndex(v), self.valueLabels[v])
    end
  end

end




function Graphit:ZoneChanged(event)
  -- self:Print(event .. ": " .. GetZoneText() .. " (" .. GetSubZoneText() .. ")" )
end

