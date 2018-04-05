

Graphit = LibStub("AceAddon-3.0"):NewAddon("Graphit", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Graphit")

Graphit.version = "1.0"



Graphit.availableSettings = {

  shadowMode = {
    values = {
      "0.000000", "1.000000", "2.000000", "3.000000", "4.000000"
    },
    valueNames = {
      "0", "1", "2", "3", "4"
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
  }--,
  
  -- -- Multisampling AA quality
  -- MSAAQuality = {
    -- values = {
      -- "0", "1,0", "2,0", "3,0"
    -- },
    -- valueNames = {
      -- "None", "2x", "4x", "8x"
    -- },
    -- tooltip = L["TODO"]
  -- }
  
  
  -- graphicsDepthEffects = {
    -- values = {
      -- 1, 2, 3, 4
    -- },
    -- valueNames = {
      -- "Disabled", "Low", "Good", "High"
    -- },
    -- tooltip = L["graphicsDepthEffects"]
  -- },
  
  -- ffxAntiAliasingMode = {
    -- values = {
      -- 0, 1, 2, 3
    -- },
    -- valueNames = {
      -- "None", "FXAA Low", "FXAA High", "CMAA"
    -- },
    -- tooltip = L["ffxAntiAliasingMode"]
  -- },

  -- graphicsLightingQuality = {
    -- values = {
      -- 1, 2, 3
    -- },
    -- valueNames = {
      -- "Low", "Good", "High"
    -- },
    -- tooltip = L["TODO"]
  -- },
  
  
  
  

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
  
  -- Update the GUI label.
  self:UpdateSettingValueLabel(cVarName, newValueIndex, self.valueLabels[cVarName])
  
  self:Print ("Setting " .. cVarName .. " to " .. newValue)
  
  if ((cVarName == "shadowMode") or (cVarName == "shadowSoft") or (cVarName == "shadowTextureSize")) then
    self:CheckForShadowFactoryPreset()
  end
  
end


-- Check if the current combination of shadow settings is one of WOW's "factory" graphicsShadowQuality defaults. 
function Graphit:CheckForShadowFactoryPreset()

  shadowModeValue = GetCVar("shadowMode")
  shadowSoftValue = GetCVar("shadowSoft")
  shadowTextureSizeValue = GetCVar("shadowTextureSize")

  -- print (shadowModeValue .. " " .. shadowSoftValue .. " " .. shadowTextureSizeValue)
  
  -- Ultra High
  if ((tonumber(shadowModeValue) == 4) and (tonumber(shadowSoftValue) == 1) and (tonumber(shadowTextureSizeValue) == 2048)) then
    -- print ("Ultra High")
    return SetCVar("graphicsShadowQuality", 6)
  end
  -- Ultra
  if ((tonumber(shadowModeValue) == 3) and (tonumber(shadowSoftValue) == 1) and (tonumber(shadowTextureSizeValue) == 2048)) then
    -- print ("Ultra")
    return SetCVar("graphicsShadowQuality", 5)
  end
  -- High
  if ((tonumber(shadowModeValue) == 3) and (tonumber(shadowSoftValue) == 0) and (tonumber(shadowTextureSizeValue) == 2048)) then
    -- print ("High")
    return SetCVar("graphicsShadowQuality", 4)
  end
  -- Good
  if ((tonumber(shadowModeValue) == 2) and (tonumber(shadowSoftValue) == 0) and (tonumber(shadowTextureSizeValue) == 1024)) then
    -- print ("Good")
    return SetCVar("graphicsShadowQuality", 3)
  end
  -- Fair
  if ((tonumber(shadowModeValue) == 1) and (tonumber(shadowSoftValue) == 0) and (tonumber(shadowTextureSizeValue) == 1024)) then
    -- print ("Fair")
    return SetCVar("graphicsShadowQuality", 2)
  end
  -- Low
  if ((tonumber(shadowModeValue) == 0) and (tonumber(shadowSoftValue) == 0) and (tonumber(shadowTextureSizeValue) == 1024)) then
    -- print ("Low")
    return SetCVar("graphicsShadowQuality", 1)
  end
  
  -- print ("Custom")
  SetCVar("graphicsShadowQuality", 0)
  -- Must set the variables again, because setting graphicsShadowQuality to 0 will reset the others.
  SetCVar("shadowMode", shadowModeValue)
  SetCVar("shadowSoft", shadowSoftValue)
  SetCVar("shadowTextureSize", shadowTextureSizeValue)
  
end




function Graphit:UpdateSettingValueLabel(cVarName, newValueIndex, label)
  
  -- print ("Putting label " .. newValueIndex .. " for " .. cVarName)
  
  local newValueName = self.availableSettings[cVarName].valueNames[newValueIndex]
  if newValueName ~= true then
    label:SetText("|c00ffffff" .. newValueName )
  else
    label:SetText("|c00ffffff" .. newValue )
  end
end



function Graphit:TryToSetSetting(cVarName, increase)
  
  local valueIndex = self:GetValueIndex(cVarName)
  
  local numberOfSettings = 0
  for k,v in pairs(self.availableSettings[cVarName].values) do
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
    return
  end
  
  -- Else must be decrease.
  if valueIndex == 1 then
    -- print ("Already min value!")
    return
  end
  
  -- Set the next lower value.
  self:SetSetting(cVarName, valueIndex-1)
  

end









function Graphit:OnInitialize()
  -- Called when the addon is loaded
  
  self.db = LibStub("AceDB-3.0"):New("GraphitDB", defaults, true)
  
  self:RegisterChatCommand("graphit", "ChatCommand")
  self:RegisterChatCommand("grt", "ChatCommand")
end

function Graphit:OnEnable()
  -- Called when the addon is enabled
  
  self:RegisterEvent("ZONE_CHANGED", "ZoneChanged");
  self:RegisterEvent("ZONE_CHANGED_INDOORS", "ZoneChanged");
  
  
  self:RegisterEvent("CONSOLE_MESSAGE", "PossibleSettingsUpdate");
  
  
  -- Flag variables belonging to Graphit.
  self.frameShown = false
  self.frameBuilt = false
  
  self:BuildFrame()
  self:HideFrame()
end

function Graphit:OnDisable()
  -- Called when the addon is disabled
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
    Graphit_titleFrame.fpsint:SetText("|c00ffffff" .. floor(avgFps) )
    Graphit_titleFrame.fpsdec:SetText("|c00ffffff." .. floor(10*avgFps)%10 )
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
  mainFrame:ClearAllPoints()
  mainFrame:SetPoint("TOPRIGHT", "Minimap", "BOTTOMLEFT", 40, -30)
  mainFrame:SetFrameStrata("FULLSCREEN_DIALOG")
  mainFrame:SetBackdrop({ bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
                        edgeFile = "Interface/DialogFrame/UI-DialogBox-Border", 
                        tile = true, tileSize = 16, edgeSize = 16, 
                        insets = { left = 4, right = 4, top = 4, bottom = 4 }})
  mainFrame:SetBackdropColor(0.0, 0.0, 0.0, 1.0)
  
  -- Alternatives:
  -- Interface/DialogFrame/UI-DialogBox-Border
  -- Interface/Tooltips/UI-Tooltip-Border
  -- Interface/TutorialFrame/TutorialFrameBackground
  -- Interface/Tooltips/UI-Tooltip-Background
  

  -- Enable dragging.
  mainFrame:SetMovable(true)
  mainFrame:EnableMouse(true)
  mainFrame:RegisterForDrag("LeftButton")
  mainFrame:SetScript("OnDragStart", mainFrame.StartMoving)
  mainFrame:SetScript("OnDragStop", mainFrame.StopMovingOrSizing)
  mainFrame:SetClampedToScreen(true)
  
  
  -- Set the dimensions.
  local fixedWidth = 220
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
  titleFrame:ClearAllPoints()
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
  titleFrame.title:SetText("|c00ffffffGRAPHIT " .. self.version)	

  -- Set the FPS display.
  titleFrame.fps = titleFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  titleFrame.fps:SetPoint("LEFT", titleFrame.title, "RIGHT", 28, 0)
  titleFrame.fps:SetText("|c00ffffffFPS :")
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
  scrollFrame:ClearAllPoints()
  
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
  
  
  local settingNumber = 0
  for cVarName in pairs(self.availableSettings) do
    self:PutSetting(cVarName, settingNumber, self.mainFrame.scrollFrame.contentFrame)
    settingNumber = settingNumber + 1
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
  
  resizeButton:SetFrameStrata("TOOLTIP")
  
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


-- Storing the links to value labels.
Graphit.valueLabels = {}


function Graphit:PutSetting(cVarName, settingNumber, targetFrame)

  -- Where to put this frame in the targetFrame.
  local topOffset = 10
  local settingElementHeight = 50
  local top = -topOffset -settingElementHeight*settingNumber

  -- Increase the targetFrame's height.
  targetFrame:SetSize(targetFrame:GetWidth(), topOffset + settingElementHeight*(settingNumber+1)) 
  
  
  -- Create a new frame for this settings element.
  local SettingElementFrame = CreateFrame("Frame", nil, targetFrame)
  SettingElementFrame:ClearAllPoints()

  SettingElementFrame:SetWidth(targetFrame:GetWidth())
  SettingElementFrame:SetHeight(settingElementHeight)
  SettingElementFrame:SetPoint("TOP", targetFrame, "TOP", 0, top)
    
  SettingElementFrame.cVarNameLabel = SettingElementFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  SettingElementFrame.cVarNameLabel:SetPoint("TOPLEFT", SettingElementFrame, "TOPLEFT", 15, -8)
  SettingElementFrame.cVarNameLabel:SetText("|c00ffffff" .. cVarName)
    
  
  local MinusButton = CreateFrame("Button", nil, SettingElementFrame, "UIPanelButtonTemplate")
  MinusButton:SetWidth(25)
  MinusButton:SetPoint("TOPLEFT", SettingElementFrame, "TOPLEFT", 30, -24)
  MinusButton:SetText("-")
  MinusButton:SetScript("OnClick", function()
    PlaySound(799) -- SOUNDKIT.GS_TITLE_OPTION_EXIT
    self:TryToSetSetting(cVarName, false)
  end )
  
  
  self.valueLabels[cVarName] = SettingElementFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  self.valueLabels[cVarName]:SetPoint("CENTER", SettingElementFrame, "TOPLEFT", (55 + 160)/2 , -34)
  -- print (cVarName .. " is currently " .. GetCVar(cVarName) .. " which is index " .. self:GetValueIndex(cVarName))
  self:UpdateSettingValueLabel(cVarName, self:GetValueIndex(cVarName), self.valueLabels[cVarName])
  

  -- MyStatusBar = CreateFrame("StatusBar", nil, content)
  -- MyStatusBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  -- MyStatusBar:GetStatusBarTexture():SetHorizTile(false)
  -- MyStatusBar:SetMinMaxValues(0, 100)
  -- MyStatusBar:SetValue(100)
  -- MyStatusBar:SetWidth(200)
  -- MyStatusBar:SetHeight(10)
  -- MyStatusBar:SetPoint("CENTER",content,"CENTER")
  -- MyStatusBar:SetStatusBarColor(0,0.6,0)   
      
      
      
      
  local PlusButton = CreateFrame("Button", nil, SettingElementFrame, "UIPanelButtonTemplate")
  PlusButton:SetWidth(25)
  PlusButton:SetPoint("TOPLEFT", SettingElementFrame, "TOPLEFT", 160, -24)
  PlusButton:SetText("+")
  PlusButton:SetScript("OnClick", function()
    PlaySound(799) -- SOUNDKIT.GS_TITLE_OPTION_EXIT
    self:TryToSetSetting(cVarName, true)
  end )
  
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
  -- self:Print("PossibleSettingsUpdate: " .. event .. "  "  .. arg1)
  
  for cVarName in pairs(self.availableSettings) do
    self:UpdateSettingValueLabel(cVarName, self:GetValueIndex(cVarName), self.valueLabels[cVarName])
  end
  
end




function Graphit:ZoneChanged(event)
  -- self:Print(event .. ": " .. GetZoneText() .. " (" .. GetSubZoneText() .. ")" )
end

