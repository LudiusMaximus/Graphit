local folderName, Graphit = ...

-- Locals for frequently used global frames and functions.
local GameTooltip_AddBlankLineToTooltip  = _G.GameTooltip_AddBlankLineToTooltip
local GameTooltip_AddInstructionLine     = _G.GameTooltip_AddInstructionLine
local GameTooltip_AddNormalLine          = _G.GameTooltip_AddNormalLine
local GameTooltip_SetTitle               = _G.GameTooltip_SetTitle

-- Cache of global WoW API tables/functions.
local tinsert = _G.tinsert


-- The button can show a live FPS number instead of the icon (right-click checkbox).
local FPS_INTERVAL  = 0.25  -- averaging window, matching the window's readout
-- Position of the number within the button, per digit count -- the two fonts differ
-- in size, so each gets its own nudge.
local FPS_SMALL_X, FPS_SMALL_Y = 0.5, 0   -- 1-2 digits (GameFontNormalSmall)
local FPS_TINY_X,  FPS_TINY_Y  = 0, 0.5   -- 3 digits (GameFontNormalTiny)


-- Toggle the minimap button's hidden state, persisted in the LibDBIcon DB. Reached
-- only from "/graphit minimap" (the right-click menu toggles the FPS display instead).
function Graphit.ToggleMinimapButton()
  Graphit_config = Graphit_config or {}
  Graphit_config.minimap = Graphit_config.minimap or {}
  Graphit_config.minimap.hide = not Graphit_config.minimap.hide
  local icon = LibStub("LibDBIcon-1.0", true)
  if not icon then return end
  if Graphit_config.minimap.hide then
    icon:Hide(folderName)
  else
    icon:Show(folderName)
  end
end


-- Minimap icon via LibDataBroker + LibDBIcon. A launcher: left-click toggles the
-- Graphit window, right-click opens a context menu. Position and hidden state persist
-- in Graphit_config.minimap (the table LibDBIcon owns).
do
  local ldb = LibStub("LibDataBroker-1.1", true)
  if not ldb then return end


  local atlasInfo = C_Texture.GetAtlasInfo("UI-Frame-DastardlyDuos-icon-Speed")
  local plugin = ldb:NewDataObject(folderName, {
    type = "launcher",
    icon = atlasInfo.file,
    iconCoords = {atlasInfo.leftTexCoord, atlasInfo.rightTexCoord, atlasInfo.topTexCoord, atlasInfo.bottomTexCoord},
  })

  function plugin.OnTooltipShow(tooltip)
    GameTooltip_SetTitle(tooltip, folderName)
    GameTooltip_AddNormalLine(tooltip, "Fine-grained graphics settings.", true)
    GameTooltip_AddBlankLineToTooltip(tooltip)
    GameTooltip_AddInstructionLine(tooltip, "Left-click to open / close.")
    GameTooltip_AddInstructionLine(tooltip, "Right-click for options.")
  end

  function plugin.OnClick(self, button)
    if button == "LeftButton" then
      Graphit.ToggleMainFrame()
    elseif button == "RightButton" then
      MenuUtil.CreateContextMenu(UIParent, function(_, menu)
        menu:CreateTitle(folderName)
        menu:CreateCheckbox(
          "Replace minimap icon with live FPS",
          function() return Graphit_config and Graphit_config.minimap and Graphit_config.minimap.showFPS end,
          function()
            Graphit_config = Graphit_config or {}
            Graphit_config.minimap = Graphit_config.minimap or {}
            Graphit_config.minimap.showFPS = not Graphit_config.minimap.showFPS
            Graphit.SetMinimapDisplay()
          end
        )
      end)
    end
  end

  -- The button can show a live FPS number in place of the icon, toggled by the
  -- right-click checkbox. SetMinimapDisplay() applies the saved choice; it runs on
  -- registration and after every toggle. The button, its FPS font string, and the
  -- ticker that measures FPS are assigned once the button exists (see below).
  local minimapButton = nil
  local fpsText = nil
  local ticker = nil

  function Graphit.SetMinimapDisplay()
    if not minimapButton then return end
    local showFPS = Graphit_config.minimap.showFPS
    if minimapButton.icon then minimapButton.icon:SetShown(not showFPS) end
    fpsText:SetShown(showFPS)
    ticker:SetShown(showFPS)
  end

  local iconFrame = CreateFrame("Frame")
  iconFrame:SetScript("OnEvent", function()
    local icon = LibStub("LibDBIcon-1.0", true)
    if icon then
      Graphit_config = Graphit_config or {}
      Graphit_config.minimap = Graphit_config.minimap or {}
      icon:Register(folderName, plugin, Graphit_config.minimap)

      -- On first registration (no saved position), avoid overlapping other minimap icons.
      if not Graphit_config.minimap.minimapPos then
        local MIN_DISTANCE = 15  -- minimum degrees apart
        local occupied = {}
        for _, name in ipairs(icon:GetButtonList()) do
          if name ~= folderName then
            local btn = icon:GetMinimapButton(name)
            if btn then
              tinsert(occupied, (btn.db and btn.db.minimapPos) or btn.minimapPos or 225)
            end
          end
        end
        local function isTooClose(p)
          for _, o in ipairs(occupied) do
            local diff = math.abs(p - o)
            if diff > 180 then diff = 360 - diff end
            if diff < MIN_DISTANCE then return true end
          end
          return false
        end
        if isTooClose(225) then
          for offset = MIN_DISTANCE, 360 - MIN_DISTANCE, MIN_DISTANCE do
            local candidate = (225 + offset) % 360
            if not isTooClose(candidate) then
              Graphit_config.minimap.minimapPos = candidate
              icon:SetButtonToPosition(folderName, candidate)
              break
            end
            candidate = (225 - offset) % 360
            if not isTooClose(candidate) then
              Graphit_config.minimap.minimapPos = candidate
              icon:SetButtonToPosition(folderName, candidate)
              break
            end
          end
        end
      end

      minimapButton = icon:GetMinimapButton(folderName)
      if minimapButton then
        -- Resize and vertically nudge the icon texture within the button. LibDBIcon
        -- sets it to 18px centred once at registration and does not touch it again for
        -- a static launcher, so adjusting it here sticks.
        if minimapButton.icon then
          minimapButton.icon:SetSize(14, 14)
          minimapButton.icon:ClearAllPoints()
          minimapButton.icon:SetPoint("CENTER", minimapButton, "CENTER", 0, 1)
        end

        -- Just the number (no caption), the same value as the window's readout. A
        -- hidden ticker measures it from real frame deltas (running only while FPS
        -- mode is on) and picks the font by digit count -- the small font for 1-2
        -- digits, the tinier one so a 3-digit value still fits the button.
        fpsText = minimapButton:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
        fpsText:SetPoint("CENTER", minimapButton, "CENTER", FPS_SMALL_X, FPS_SMALL_Y)
        fpsText:Hide()

        local frames, elapsed = 0, 0
        ticker = CreateFrame("Frame")
        ticker:Hide()
        ticker:SetScript("OnUpdate", function(_, dt)
          frames, elapsed = frames + 1, elapsed + dt
          if elapsed >= FPS_INTERVAL then
            local fps = math.floor(frames / elapsed + 0.5)
            fpsText:ClearAllPoints()
            if fps >= 100 then
              fpsText:SetFontObject(GameFontNormalTiny)
              fpsText:SetPoint("CENTER", minimapButton, "CENTER", FPS_TINY_X, FPS_TINY_Y)
            else
              fpsText:SetFontObject(GameFontNormalSmall)
              fpsText:SetPoint("CENTER", minimapButton, "CENTER", FPS_SMALL_X, FPS_SMALL_Y)
            end
            fpsText:SetText(fps)
            frames, elapsed = 0, 0
          end
        end)

        Graphit.SetMinimapDisplay()
      end
    end
  end)
  iconFrame:RegisterEvent("PLAYER_LOGIN")
end
