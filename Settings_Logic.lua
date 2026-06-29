local _, Graphit = ...

-- =====================================================================
-- Settings_Logic -- Graphit's per-setting BEHAVIOUR, keyed by CVar (or by name for a CVar-less
-- setting like Resolution). This is where the smart cross-setting logic lives (a control greys
-- when another setting forbids it, a tooltip warns that a value has no effect right now, a
-- readout shows an effective rather than a stored value), kept out of Settings_Source so that
-- file stays a clean, 1:1 mirror of Blizzard's Graphics.lua. Settings_Custom holds our
-- DECLARATIVE decisions (order, tabs, control swaps, hidden, deferApply); this file holds the
-- IMPERATIVE ones (closures).
--
-- MainFrame overlays this entry onto the mirror (MergeLogic, by CVar or name), so any field a
-- setting can carry works here: get / set value transforms, enableWhen (grey the control while a
-- precondition is unmet) with an optional disabledTooltip, optionDisabled(value) (a per-option
-- red reason in the tooltip), and the trailing tooltip notes optionsHint (always, normal) and
-- optionsWarning (conditional, warning colour). A Layer-3 child entry may carry the notes too.
--
-- User-facing strings name other settings / options via numbered %1$s... placeholders fed from
-- the game's own localised globals (so a translation can reorder them and they always match the
-- live UI labels); MainFrame's FormatHint runs L on the template, then format inserts the names.
-- =====================================================================

-- shadowMode 0 = no shadows at all, which is the only state that fully disables Ray Traced
-- Shadows. Keyed on the child CVar, not the Shadow Quality preset, so it reacts to a direct
-- shadowMode child edit as well as a preset change (the preset CVar would not move for that).
local function ShadowMode()
  return tonumber((C_CVar and C_CVar.GetCVar("shadowMode")) or "0") or 0
end

-- Ray Traced Shadows enabled (any non-Disabled level). While on, the traditional shadow-shaping
-- children below have no effect.
local function RayTracedShadowsOn()
  return (tonumber((C_CVar and C_CVar.GetCVar("shadowrt")) or "0") or 0) > 0
end

-- A warning for a Shadow Quality child that the engine ignores while Ray Traced Shadows is on.
local function IgnoredWhileRayTraced()
  if RayTracedShadowsOn() then
    return "Only takes effect while \"%1$s\" is disabled.", RT_SHADOW_QUALITY
  end
end

-- The game window is "maximised" (windowed but filling the screen) when it is not fullscreen yet
-- its width already equals the monitor's full width. The OS then fixes the size, so picking a
-- resolution has no effect. Mirrors ScreenManager's check; it only misfires with a left/right
-- Windows taskbar, which almost nobody uses.
local function IsWindowMaximized()
  if GetCVar("gxMaximize") ~= "0" then return false end  -- fullscreen: not maximised-windowed
  if not (C_VideoOptions and C_VideoOptions.GetDefaultGameWindowSize and GetPhysicalScreenSize) then return false end
  local def = C_VideoOptions.GetDefaultGameWindowSize(tonumber(GetCVar("gxMonitor")) or 0)
  return def ~= nil and GetPhysicalScreenSize() == def.x
end

local RESAMPLE_BICUBIC, RESAMPLE_FSR = 2, 3  -- ResampleQuality option values (see Settings_Source)
local RESAMPLE_SHARPNESS_MAX = 2  -- the slider's max readout; reversed bar, so this is no sharpening

local function StoredResampleQuality()
  return tonumber((C_CVar and C_CVar.GetCVar("ResampleQuality")) or "0") or 0
end
local function AlwaysSharpenOn()
  return (tonumber((C_CVar and C_CVar.GetCVar("ResampleAlwaysSharpen")) or "0") or 0) ~= 0
end

-- The Resample Quality in effect for a given "render scale is upscaling" state: the stored choice
-- while upscaling, otherwise Bicubic (the engine resamples with Bicubic at 100% and above).
local function ResampleQualityFor(upscaling)
  if not upscaling then return RESAMPLE_BICUBIC end
  return StoredResampleQuality()
end
-- Whether sharpening is applied for that state: FSR upscaling, or Always Sharpen forcing it on.
local function SharpeningFor(upscaling)
  return AlwaysSharpenOn() or ResampleQualityFor(upscaling) == RESAMPLE_FSR
end

-- Render Scale is a fraction (1.0 = 100%) and only upscales below it. The pending-aware read
-- honours a staged change; the committed read is the live CVar. They differ exactly while a Render
-- Scale change is uncommitted -- which is how the dependent rows flag themselves pending by proxy.
local function PendingUpscaling() return (tonumber(Graphit.LogicalValue("RenderScale")) or 1) < 1 end
local function LiveUpscaling()    return (tonumber(GetCVar("RenderScale")) or 1) < 1 end

-- Orange note on a dependent row whose effective value follows an uncommitted Render Scale change.
local PENDING_PROXY = "This reflects your uncommitted \"%1$s\" change."

Graphit.logic = {

  -- Variable Rate Shading: Multisample AA overrules it -- while MSAA is on the engine reports
  -- Standard/Aggressive unsupported, and IsGraphicsCVarValueSupported flips the instant MSAA
  -- changes. enableWhen greys the whole dropdown (re-checked on every refresh, which the MSAA
  -- edit triggers); it also greys permanently on hardware with no VRS support at all. get then
  -- reports the effective state (Disabled), the stored CVar left intact so the choice returns
  -- when VRS is available again. optionDisabled puts each unsupported level's reason (red) in
  -- the label tooltip; optionsHint names MSAA as the likely cause while it is on.
  ["vrsValar"] = {
    get = function(raw)
      if IsGraphicsCVarValueSupported and IsGraphicsCVarValueSupported("vrsValar", 1) ~= 0 then return 0 end
      return tonumber(raw) or 0
    end,
    enableWhen = function()
      return not IsGraphicsCVarValueSupported or IsGraphicsCVarValueSupported("vrsValar", 1) == 0
    end,
    optionDisabled = function(value)
      return Graphit.GraphicsCVarError("vrsValar", value)
    end,
    optionsHint = function()
      local msaa = tonumber((strsplit(",", (C_CVar and C_CVar.GetCVar("MSAAQuality")) or "0"))) or 0
      if msaa ~= 0 then
        return "VRS gets automatically disabled by the game while \"%1$s\" is enabled.", MSAA_LABEL
      end
    end,
  },

  -- Ray Traced Shadows render only once shadow rendering is on (shadowMode > 0): Shadow Quality
  -- Low leaves shadowMode 0, Fair lifts it to 1 (shadows on the player); reaching the world
  -- environment needs BOTH shadowMode >= 2 and shadowNumCascades >= 2, which the preset first
  -- meets together at Medium. The grey-out only cares about no shadows at all (shadowMode 0); get
  -- then shows the effective state (Disabled), the stored level left untouched so it snaps back
  -- once shadows return. optionsHint always states the relationship; optionsWarning calls out the
  -- current Low state in warning colour.
  ["shadowrt"] = {
    enableWhen = function() return ShadowMode() > 0 end,
    get = function(raw)
      if ShadowMode() == 0 then return 0 end
      return tonumber(raw) or 0
    end,
    optionsHint = function()
      return "Ray Traced Shadows follow the \"%1$s\" setting: at \"%2$s\" there are none, at \"%3$s\" they fall on your character only, and from \"%4$s\" upward they also reach the world environment.",
        SHADOW_QUALITY, VIDEO_OPTIONS_LOW, VIDEO_OPTIONS_FAIR, VIDEO_OPTIONS_MEDIUM
    end,
    optionsWarning = function()
      if ShadowMode() == 0 then
        return "Your \"%1$s\" is currently set to \"%2$s\", so Ray Traced Shadows are disabled.",
          SHADOW_QUALITY, VIDEO_OPTIONS_LOW
      end
    end,
  },

  -- Shadow Quality children the engine ignores while Ray Traced Shadows is on: warn (do not
  -- disable -- the user may still set them for when they turn Ray Traced Shadows off).
  ["shadowSoft"]        = { optionsWarning = IgnoredWhileRayTraced },
  ["shadowTextureSize"] = { optionsWarning = IgnoredWhileRayTraced },

  -- Resample Quality only has an effect while the render scale is upscaling (below 100%); at or
  -- above 100% the engine always uses Bicubic. Grey the dropdown there and show Bicubic as the
  -- effective choice, the stored value left intact so it returns once the render scale drops back
  -- below 100%. A normal-font hint explains why (like VRS, not a red warning).
  ["ResampleQuality"] = {
    enableWhen = function() return PendingUpscaling() end,
    get = function(raw)
      if not PendingUpscaling() then return RESAMPLE_BICUBIC end
      return tonumber(raw) or 0
    end,
    optionsHint = function()
      if not PendingUpscaling() then
        return "At a \"%1$s\" of 100%% or higher the game always resamples with \"%2$s\".",
          RENDER_SCALE, RESAMPLE_QUALITY_BICUBIC
      end
    end,
    pendingProxy = function()
      if ResampleQualityFor(PendingUpscaling()) ~= ResampleQualityFor(LiveUpscaling()) then
        return PENDING_PROXY, RENDER_SCALE
      end
    end,
  },

  -- Resample Sharpness only sharpens FSR upscaling, unless Always Sharpen forces it on. Otherwise
  -- grey the slider and pin its readout to the max (2.0 = no sharpening), the stored value left
  -- intact. A red warning names the FSR requirement (like the Ray Traced Shadow note).
  ["ResampleSharpness"] = {
    enableWhen = function() return SharpeningFor(PendingUpscaling()) end,
    get = function(raw)
      if not SharpeningFor(PendingUpscaling()) then return RESAMPLE_SHARPNESS_MAX end
      return tonumber(raw) or 0
    end,
    optionsWarning = function()
      if not SharpeningFor(PendingUpscaling()) then
        return "Only has an effect while \"%1$s\" is set to \"%2$s\", unless \"Always Sharpen\" is enabled.", RESAMPLE_QUALITY, RESAMPLE_QUALITY_FSR
      end
    end,
    pendingProxy = function()
      if SharpeningFor(PendingUpscaling()) ~= SharpeningFor(LiveUpscaling()) then
        return PENDING_PROXY, RENDER_SCALE
      end
    end,
  },

  -- Resolution (CVar-less, keyed by its name): a maximised window has its size fixed by the OS,
  -- so disable the control and say why. The mirror's read / write / option list stays in
  -- Settings_Source; only this Graphit behaviour lives here.
  ["WINDOW_SIZE"] = {
    enableWhen = function() return not IsWindowMaximized() end,
    disabledTooltip = "Resolution is locked to your screen size while the game window is maximized. Un-maximising the window or switching to Fullscreen will enable resolution changes again.",
  },
}
