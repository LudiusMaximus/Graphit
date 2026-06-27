local _, Graphit = ...

-- =====================================================================
-- Settings_Source -- the graphics settings transcribed by hand from Blizzard's source
-- (Graphics.lua in Blizzard_SettingsDefinitions_Shared). This is the half of our data we
-- get by reading code; Settings_Dump.lua is the counterpart we get by running the game.
-- It mirrors the game's own options in Blizzard's display order: the top-level section
-- layout and standalone settings (Graphit.layer1) and the Graphics Quality group
-- (Graphit.layer2), each with its localized-string KEYS (name, tooltip, option labels)
-- and control -- a dropdown's options or a slider's range.
--
-- Re-transcribe it wholesale when a client patch changes Graphics.lua; do not otherwise
-- hand-tweak it. Per the project rule, only keys are stored; they resolve to the player's
-- locale at display time via _G[key]. The patch-day routine lives in DumpSettings.lua.
--
-- Our deviations from this mirror live alongside it, so they stay recognisable as ours:
-- declarative ones (reordering, control swaps, Layer-3 child overrides) in Settings_Custom.lua,
-- behavioural ones (enableWhen, value transforms, smart tooltips) in Settings_Logic.lua. A
-- meta's Layer-3 child CVars and their per-level values come from Settings_Dump.lua.
-- =====================================================================

Graphit.layer2 = {

  { -- Graphics Quality (Layer-1 master: drives every meta below it; MainFrame renders
    -- it as the leading row of the Graphics Quality section and writes each meta
    -- directly, since the master does not cascade via SetCVar). We keep Blizzard's
    -- GRAPHICS_QUALITY label: its BASE_GRAPHICS_QUALITY only existed to tell this apart
    -- from Raid Graphics, and Graphit's per-scenario profiles make that distinction
    -- unnecessary.
    cvar    = "graphicsQuality",
    name    = "GRAPHICS_QUALITY",
    -- Blizzard passes this key to InitControlSlider but never defines the global,
    -- so it resolves to nil (no tooltip) -- kept as the faithful mirror; override
    -- it in Settings_Custom for a real one.
    tooltip = "OPTION_TOOLTIP_GRAPHICS_QUALITY",
    control = { kind = "slider", min = 0, max = 9, step = 1, displayOffset = 1 },
  },

  { -- Shadow Quality
    cvar    = "graphicsShadowQuality",
    name    = "SHADOW_QUALITY",
    tooltip = "OPTION_TOOLTIP_SHADOW_QUALITY",
    control = { kind = "dropdown", options = {
      { value = 0, label = "VIDEO_OPTIONS_LOW",        tooltip = "VIDEO_OPTIONS_SHADOW_QUALITY_LOW"        },
      { value = 1, label = "VIDEO_OPTIONS_FAIR",       tooltip = "VIDEO_OPTIONS_SHADOW_QUALITY_FAIR"       },
      { value = 2, label = "VIDEO_OPTIONS_MEDIUM",     tooltip = "VIDEO_OPTIONS_SHADOW_QUALITY_MEDIUM"     },
      { value = 3, label = "VIDEO_OPTIONS_HIGH",       tooltip = "VIDEO_OPTIONS_SHADOW_QUALITY_HIGH"       },
      { value = 4, label = "VIDEO_OPTIONS_ULTRA",      tooltip = "VIDEO_OPTIONS_SHADOW_QUALITY_ULTRA"      },
      { value = 5, label = "VIDEO_OPTIONS_ULTRA_HIGH", tooltip = "VIDEO_OPTIONS_SHADOW_QUALITY_ULTRA_HIGH" },
    } },
  },

  { -- Liquid Detail
    cvar    = "graphicsLiquidDetail",
    name    = "LIQUID_DETAIL",
    tooltip = "OPTION_TOOLTIP_LIQUID_DETAIL",
    control = { kind = "dropdown", options = {
      { value = 0, label = "VIDEO_OPTIONS_LOW",    tooltip = "VIDEO_OPTIONS_LIQUID_DETAIL_LOW"    },
      { value = 1, label = "VIDEO_OPTIONS_FAIR",   tooltip = "VIDEO_OPTIONS_LIQUID_DETAIL_FAIR"   },
      { value = 2, label = "VIDEO_OPTIONS_MEDIUM", tooltip = "VIDEO_OPTIONS_LIQUID_DETAIL_MEDIUM" },
      { value = 3, label = "VIDEO_OPTIONS_HIGH",   tooltip = "VIDEO_OPTIONS_LIQUID_DETAIL_ULTRA"  },
    } },
  },

  { -- Particle Density
    cvar    = "graphicsParticleDensity",
    name    = "PARTICLE_DENSITY",
    tooltip = "OPTION_TOOLTIP_PARTICLE_DENSITY",
    control = { kind = "dropdown", options = {
      { value = 0, label = "VIDEO_OPTIONS_DISABLED", warning = "VIDEO_OPTIONS_COMBAT_CUES_DISABLED_WARNING" },
      { value = 1, label = "VIDEO_OPTIONS_LOW"    },
      { value = 2, label = "VIDEO_OPTIONS_FAIR"   },
      { value = 3, label = "VIDEO_OPTIONS_MEDIUM" },
      { value = 4, label = "VIDEO_OPTIONS_HIGH"   },
      { value = 5, label = "VIDEO_OPTIONS_ULTRA"  },
    } },
  },

  { -- SSAO (single child: SSAO; direct control)
    cvar    = "graphicsSSAO",
    name    = "SSAO_LABEL",
    tooltip = "OPTION_TOOLTIP_SSAO",
    control = { kind = "dropdown", options = {
      { value = 0, label = "VIDEO_OPTIONS_DISABLED" },
      { value = 1, label = "VIDEO_OPTIONS_LOW"      },
      { value = 2, label = "VIDEO_OPTIONS_MEDIUM"   },
      { value = 3, label = "VIDEO_OPTIONS_HIGH"     },
      { value = 4, label = "VIDEO_OPTIONS_ULTRA"    },
    } },
  },

  { -- Depth Effects
    cvar    = "graphicsDepthEffects",
    name    = "DEPTH_EFFECTS",
    tooltip = "OPTION_TOOLTIP_DEPTH_EFFECTS",
    control = { kind = "dropdown", options = {
      { value = 0, label = "VIDEO_OPTIONS_DISABLED", tooltip = "VIDEO_OPTIONS_DEPTH_EFFECTS_DISABLED" },
      { value = 1, label = "VIDEO_OPTIONS_LOW",      tooltip = "VIDEO_OPTIONS_DEPTH_EFFECTS_LOW"      },
      { value = 2, label = "VIDEO_OPTIONS_MEDIUM",   tooltip = "VIDEO_OPTIONS_DEPTH_EFFECTS_MEDIUM"   },
      { value = 3, label = "VIDEO_OPTIONS_HIGH",     tooltip = "VIDEO_OPTIONS_DEPTH_EFFECTS_HIGH"     },
    } },
  },

  { -- Compute Effects
    cvar    = "graphicsComputeEffects",
    name    = "COMPUTE_EFFECTS",
    tooltip = "OPTION_TOOLTIP_COMPUTE_EFFECTS",
    control = { kind = "dropdown", options = {
      { value = 0, label = "VIDEO_OPTIONS_DISABLED", tooltip = "VIDEO_OPTIONS_COMPUTE_EFFECTS_DISABLED" },
      { value = 1, label = "VIDEO_OPTIONS_LOW",      tooltip = "VIDEO_OPTIONS_COMPUTE_EFFECTS_LOW"      },
      { value = 2, label = "VIDEO_OPTIONS_MEDIUM",   tooltip = "VIDEO_OPTIONS_COMPUTE_EFFECTS_MEDIUM"   },
      { value = 3, label = "VIDEO_OPTIONS_HIGH",     tooltip = "VIDEO_OPTIONS_COMPUTE_EFFECTS_HIGH"     },
      { value = 4, label = "VIDEO_OPTIONS_ULTRA",    tooltip = "VIDEO_OPTIONS_COMPUTE_EFFECTS_ULTRA"    },
    } },
  },

  { -- Outline Mode (single child: OutlineEngineMode; direct control)
    cvar    = "graphicsOutlineMode",
    name    = "OUTLINE_MODE",
    tooltip = "OPTION_TOOLTIP_OUTLINE_MODE",
    control = { kind = "dropdown", options = {
      { value = 0, label = "VIDEO_OPTIONS_DISABLED" },
      { value = 1, label = "VIDEO_OPTIONS_MEDIUM"   },
      { value = 2, label = "VIDEO_OPTIONS_HIGH"     },
    } },
  },

  { -- Texture Resolution
    cvar    = "graphicsTextureResolution",
    name    = "TEXTURE_DETAIL",
    tooltip = "OPTION_TOOLTIP_TEXTURE_DETAIL",
    control = { kind = "dropdown", options = {
      { value = 0, label = "VIDEO_OPTIONS_LOW",  tooltip = "VIDEO_OPTIONS_TEXTURE_DETAIL_LOW"  },
      { value = 1, label = "VIDEO_OPTIONS_FAIR", tooltip = "VIDEO_OPTIONS_TEXTURE_DETAIL_FAIR" },
      { value = 2, label = "VIDEO_OPTIONS_HIGH", tooltip = "VIDEO_OPTIONS_TEXTURE_DETAIL_HIGH" },
    } },
  },

  { -- Spell Density (only if C_VideoOptions.IsSpellVisualDensitySystemSupported())
    cvar    = "graphicsSpellDensity",
    name    = "SPELL_DENSITY",
    tooltip = "OPTION_TOOLTIP_SPELL_DENSITY",
    gate    = function() return C_VideoOptions and C_VideoOptions.IsSpellVisualDensitySystemSupported() end,
    control = { kind = "dropdown", options = {
      { value = 0, label = "VIDEO_OPTIONS_SFX_DENSITY_MIN",     tooltip = "VIDEO_OPTIONS_SFX_DENSITY_MIN_TOOLTIP"     },
      { value = 1, label = "VIDEO_OPTIONS_SFX_DENSITY_REDUCED", tooltip = "VIDEO_OPTIONS_SFX_DENSITY_REDUCED_TOOLTIP" },
      { value = 2, label = "VIDEO_OPTIONS_SFX_DENSITY_FULL",    tooltip = "VIDEO_OPTIONS_SFX_DENSITY_FULL_TOOLTIP"    },
    } },
  },

  { -- Projected Textures (single child: projectedTextures; direct control)
    cvar    = "graphicsProjectedTextures",
    name    = "PROJECTED_TEXTURES",
    tooltip = "OPTION_TOOLTIP_PROJECTED_TEXTURES",
    control = { kind = "dropdown", options = {
      { value = 0, label = "VIDEO_OPTIONS_DISABLED", warning = "VIDEO_OPTIONS_COMBAT_CUES_DISABLED_WARNING" },
      { value = 1, label = "VIDEO_OPTIONS_ENABLED" },
    } },
  },

  { -- View Distance (Blizzard shows 1-10 for values 0-9)
    cvar    = "graphicsViewDistance",
    name    = "FARCLIP",
    tooltip = "OPTION_TOOLTIP_FARCLIP",
    control = { kind = "slider", min = 0, max = 9, step = 1, displayOffset = 1 },
  },

  { -- Environment Detail
    cvar    = "graphicsEnvironmentDetail",
    name    = "ENVIRONMENT_DETAIL",
    tooltip = "OPTION_TOOLTIP_ENVIRONMENT_DETAIL",
    control = { kind = "slider", min = 0, max = 9, step = 1, displayOffset = 1 },
  },

  { -- Ground Clutter
    cvar    = "graphicsGroundClutter",
    name    = "GROUND_CLUTTER",
    tooltip = "OPTION_TOOLTIP_GROUND_CLUTTER",
    control = { kind = "slider", min = 0, max = 9, step = 1, displayOffset = 1 },
  },

}


-- =====================================================================
-- Layer-1 layout: the top-level graphics sections in Blizzard's display order,
-- mirroring how the Settings panel groups the options. Each entry is one of:
--   { header = "KEY" }   a section-header row (KEY is a global-string key; an
--                        optional `gate` hides the header when its block is absent).
--   { quality = true }   the Graphics Quality group -- the master preset and its
--                        meta rows from Graphit.layer2, rendered as before.
--   a setting            a standalone Layer-1 row. Common fields: cvar, name, tooltip,
--                        commit, gate. The `control` is `{ kind, ... }`; beyond a static
--                        list it may carry optionsFunc (runtime / validated options),
--                        minFunc / maxFunc (runtime slider range), or values (an
--                        enumerated slider). A setting may also carry get / set value
--                        transforms (when the CVar value differs from the control value),
--                        enableWhen (grey the control while a precondition is unmet), or --
--                        for a CVar-less setting (Resolution) -- read / write closures in
--                        place of cvar. See DumpSettings.lua for the full toolbox and
--                        how each maps from Blizzard.
--
-- The nameless top section has no header; its rows simply lead. `placeholder = true`
-- renders the row greyed with no control yet -- none remain, but a future patch's setting
-- can use it until wired up.
-- `commit` mirrors Blizzard's commit flags and drives
-- how a change lands: "live" applies on write; "windowUpdate" applies and refreshes
-- the window (light, no freeze); "gxRestart" is staged for the Apply button, which
-- restarts the graphics device on commit (held back since that restart may be heavy);
-- "clientRestart" is saved but takes effect only after a full game restart. A `gate`
-- shows the row only when it returns true (a setting Blizzard shows conditionally).
-- =====================================================================

-- IsGraphicsCVarValueSupported(cvar, value) returns 0 when supported, else an index into
-- this list (transcribed from Graphics.lua's ErrorMessages). Used to explain in a
-- setting's tooltip why an option we filtered out is unavailable. Keys, resolved at use.
local GFX_VALUE_ERRORS = {
  "VRN_ILLEGAL", "VRN_UNSUPPORTED", "VRN_GRAPHICS", "VRN_DUALCORE", "VRN_QUADCORE",
  "VRN_CPUMEM_2GB", "VRN_CPUMEM_4GB", "VRN_CPUMEM_8GB", "VRN_NEEDS_5_0", "VRN_NEEDS_6_0",
  "VRN_NEEDS_RT", "VRN_NEEDS_DX12", "VRN_NEEDS_DX12_VRS2", "VRN_NEEDS_APPLE_GPU",
  "VRN_NEEDS_AMD_GPU", "VRN_NEEDS_INTEL_GPU", "VRN_NEEDS_NVIDIA_GPU", "VRN_NEEDS_QUALCOMM_GPU",
  "VRN_NEEDS_MACOS_10_13", "VRN_NEEDS_MACOS_10_14", "VRN_NEEDS_MACOS_10_15", "VRN_NEEDS_MACOS_11_0",
  "VRN_NEEDS_MACOS_12_0", "VRN_NEEDS_MACOS_13_0", "VRN_NEEDS_WINDOWS_10", "VRN_NEEDS_WINDOWS_11",
  "VRN_MACOS_UNSUPPORTED", "VRN_WINDOWS_UNSUPPORTED", "VRN_LEGACY_UNSUPPORTED", "VRN_DX11_UNSUPPORTED",
  "VRN_DX12_WIN7_UNSUPPORTED", "VRN_REMOTE_DESKTOP_UNSUPPORTED", "VRN_WINE_UNSUPPORTED",
  "VRN_NVAPI_WINE_UNSUPPORTED", "VRN_APPLE_UNSUPPORTED", "VRN_AMD_UNSUPPORTED", "VRN_INTEL_UNSUPPORTED",
  "VRN_NVIDIA_UNSUPPORTED", "VRN_QUALCOMM_UNSUPPORTED", "VRN_GPU_DRIVER", "VRN_COMPAT_MODE",
}

-- The "unavailable" reason for a graphics CVar value, or nil when it is supported.
-- IsGraphicsCVarValueSupported returns 0 (supported) or an index into GFX_VALUE_ERRORS. Exposed
-- on Graphit so Settings_Logic's per-option checks (VRS) resolve the reason without this local.
function Graphit.GraphicsCVarError(cvar, value)
  local err = IsGraphicsCVarValueSupported and IsGraphicsCVarValueSupported(cvar, value) or 0
  return err ~= 0 and (_G[GFX_VALUE_ERRORS[err]] or "") or nil
end

-- Build an option list checked against IsGraphicsCVarValueSupported (Blizzard's
-- AddValidatedCVarOption). An unsupported value is tagged `unavailable` with its reason;
-- the renderer drops it from the control and lists "<option>: <reason>" in the tooltip.
-- `defs` are { value = N, label = "GLOBAL_STRING_KEY" [, tooltip = "KEY"] } in display order;
-- the optional per-option tooltip surfaces in the row's hover detail (see OptionDetailFunc).
local function ValidatedOptions(cvar, defs)
  local opts = {}
  for _, d in ipairs(defs) do
    local o = { value = d.value, label = _G[d.label] or d.label }
    if d.tooltip then o.tooltip = _G[d.tooltip] or d.tooltip end
    o.unavailable = Graphit.GraphicsCVarError(cvar, d.value)  -- nil when supported
    opts[#opts + 1] = o
  end
  return opts
end

-- Like ValidatedOptions but with no per-option support check -- every option always stays in
-- the list. For a setting whose availability is all-or-nothing and shown by greying the whole
-- control (VRS, overruled by Multisample AA) rather than dropping individual options, which
-- would otherwise shrink the control to a lone readout and only correct on /reload.
local function PlainOptions(defs)
  local opts = {}
  for _, d in ipairs(defs) do
    local o = { value = d.value, label = _G[d.label] or d.label }
    if d.tooltip then o.tooltip = _G[d.tooltip] or d.tooltip end
    opts[#opts + 1] = o
  end
  return opts
end

-- Blizzard formats a window size as "WxH"; these helpers are local to its Graphics.lua,
-- so we mirror them. FormatScreenResolution builds the string, ExtractSizeFromFormattedSize
-- parses it back to width, height.
local function FormatScreenResolution(width, height)
  return math.floor(width) .. "x" .. math.floor(height)
end

local function ExtractSizeFromFormattedSize(formattedSize)
  local x, y = formattedSize:match("([^,]+)x([^,]+)")
  return tonumber(x), tonumber(y)
end

-- Blizzard's FormatScaledPercentage (a local in Graphics.lua): a 0-100 value as a percent.
local function FormatScaledPercentage(value)
  return FormatPercentage(value / 100)
end

-- The current game window size for the active monitor and display mode (gxMonitor /
-- gxMaximize), falling back to the monitor's default. Drives the Resolution row and the
-- Render Scale label (Blizzard reads these through C_VideoOptions, not a plain CVar).
local function CurrentWindowSize()
  if not (C_VideoOptions and C_VideoOptions.GetCurrentGameWindowSize) then return nil end
  local monitor = tonumber(GetCVar("gxMonitor")) or 0
  local fullscreen = tonumber(GetCVar("gxMaximize")) == 1
  local size = C_VideoOptions.GetCurrentGameWindowSize(monitor, fullscreen)
  if (not size or size.x == 0 or size.y == 0) and C_VideoOptions.GetDefaultGameWindowSize then
    size = C_VideoOptions.GetDefaultGameWindowSize(monitor)
  end
  return size
end

Graphit.layer1 = {

  -- Top section (nameless): the display settings, in Blizzard's order.
  { cvar = "gxMonitor", name = "PRIMARY_MONITOR", tooltip = "OPTION_TOOLTIP_PRIMARY_MONITOR", commit = "windowUpdate",
    control = { kind = "dropdown", optionsFunc = function()
      local opts = { { value = 0, label = VIDEO_OPTIONS_MONITOR_PRIMARY } }  -- 0 = the primary monitor
      for index = 2, GetMonitorCount() do
        local value = index - 1
        local label, isPrimary = GetMonitorName(index)
        if not label then label = VIDEO_OPTIONS_MONITOR:format(value) end
        if isPrimary then label = ("%s [%s]"):format(label, VIDEO_OPTIONS_MONITOR_PRIMARY) end
        opts[#opts + 1] = { value = value, label = label }
      end
      return opts
    end } },
  { cvar = "gxMaximize", name = "DISPLAY_MODE", tooltip = "OPTION_TOOLTIP_DISPLAY_MODE", commit = "windowUpdate",
    control = { kind = "dropdown", optionsFunc = function()
      return {
        { value = 1, label = VIDEO_OPTIONS_WINDOWED_FULLSCREEN },
        { value = 0, label = VIDEO_OPTIONS_WINDOWED },
      }
    end } },
  { name = "WINDOW_SIZE", tooltip = "OPTION_TOOLTIP_WINDOW_SIZE", commit = "windowUpdate",
    -- CVar-less: Blizzard drives resolution through C_VideoOptions (the resolution CVars
    -- do not cover every size), so we read / write / list it the same way. Graphit's behaviour
    -- (disable while the window is maximised, and say why) lives in Settings_Logic["WINDOW_SIZE"].
    read = function()
      local size = CurrentWindowSize()
      return size and FormatScreenResolution(size.x, size.y) or ""
    end,
    write = function(value)
      if not (C_VideoOptions and C_VideoOptions.SetGameWindowSize) then return end
      local x, y = ExtractSizeFromFormattedSize(value)
      C_VideoOptions.SetGameWindowSize(x, y)
    end,
    control = { kind = "dropdown", optionsFunc = function()
      local opts = {}
      if not (C_VideoOptions and C_VideoOptions.GetGameWindowSizes) then return opts end
      local monitor = tonumber(GetCVar("gxMonitor")) or 0
      local fullscreen = tonumber(GetCVar("gxMaximize")) == 1
      if fullscreen then opts[#opts + 1] = { value = FormatScreenResolution(0, 0), label = "DEFAULT" } end
      for _, size in ipairs(C_VideoOptions.GetGameWindowSizes(monitor, fullscreen) or {}) do
        local v = FormatScreenResolution(size.x, size.y)
        opts[#opts + 1] = { value = v, label = v }
      end
      return opts
    end } },
  { cvar = "RenderScale", name = "RENDER_SCALE", tooltip = "OPTION_TOOLTIP_RENDER_SCALE", commit = "live",
    control = { kind = "slider", step = 0.01,
      minFunc = function() return GetMinRenderScale() end,
      maxFunc = function() return GetMaxRenderScale() end,
      -- Blizzard's RenderScaleFormat is the render resolution (window size times the scale)
      -- and the percentage. Stacked on three lines so it fits the narrow readout column:
      --   1024
      --   x768
      --   (100%)
      format = function(value)
        local size = CurrentWindowSize()
        if size and size.x ~= 0 and size.y ~= 0 then
          return string.format("%d\nx%d\n(%s)", math.floor(size.x * value), math.floor(size.y * value), FormatPercentage(value))
        end
        return FormatPercentage(value)
      end } },
  { cvar = "uiscale", name = "UI_SCALE", tooltip = "OPTION_TOOLTIP_UI_SCALE", commit = "live",
    control = { kind = "checkboxSlider", check = "useUiScale",
      min = 0.65, max = 1.15, step = 0.01,
      format = function(v) return FormatPercentageRounded(v) end } },
  { cvar = "vsync", name = "VERTICAL_SYNC", tooltip = "OPTION_TOOLTIP_VERTICAL_SYNC", commit = "windowUpdate",
    control = { kind = "checkbox" } },
  { cvar = "NotchedDisplayMode", name = "NOTCH_MODE", tooltip = "OPTION_TOOLTIP_NOTCH_MODE", commit = "windowUpdate",
    gate = function() return C_UI and C_UI.DoesAnyDisplayHaveNotch and C_UI.DoesAnyDisplayHaveNotch() end,
    control = { kind = "dropdown", options = {
      { value = 0, label = "NOTCH_MODE_OVERLAP",      tooltip = "VIDEO_OPTIONS_NOTCH_MODE_OVERLAP"      },
      { value = 1, label = "NOTCH_MODE_SHIFT_UI",     tooltip = "VIDEO_OPTIONS_NOTCH_MODE_SHIFT_UI"     },
      { value = 2, label = "NOTCH_MODE_WINDOW_BELOW", tooltip = "VIDEO_OPTIONS_NOTCH_MODE_WINDOW_BELOW" },
    } } },
  -- Multi-value and hardware-dependent (Built-in / NVIDIA Reflex / Reflex Boost / Intel
  -- XeLL). We return every mode but tag the unsupported ones with `unavailable` (the
  -- reason); the renderer drops those from the dropdown and lists "<mode>: <reason>" in
  -- the tooltip instead. A dropdown, not a checkbox: the set varies by GPU.
  { cvar = "LowLatencyMode", name = "LOW_LATENCY_MODE", tooltip = "OPTION_TOOLTIP_LOW_LATENCY_MODE", commit = "live",
    control = { kind = "dropdown", optionsFunc = function()
      return ValidatedOptions("LowLatencyMode", {
        { value = 0, label = "VIDEO_OPTIONS_DISABLED" },
        { value = 1, label = "VIDEO_OPTIONS_BUILTIN" },
        { value = 2, label = "VIDEO_OPTIONS_NVIDIA_REFLEX" },
        { value = 3, label = "VIDEO_OPTIONS_NVIDIA_REFLEX_BOOST" },
        { value = 4, label = "VIDEO_OPTIONS_INTEL_XELL" },
      })
    end } },
  -- Antialiasing: Blizzard's "Antialiasing" parent dropdown (None / Image-Based /
  -- Multisample / Advanced) carries no state -- it only derives from, and gates, the two
  -- child controls (its "Advanced" does nothing; pick it, leave a child at None, and it
  -- collapses back). So we drop the parent and expose the children directly as L1 rows.
  -- CMAA / CMAA2 are added only where the hardware supports them (AntiAliasingSupported
  -- returns fxaa, cmaa, cmaa2 booleans -- no reason string, so they are simply omitted).
  { cvar = "ffxAntiAliasingMode", name = "FXAA_CMAA_LABEL", tooltip = "OPTION_TOOLTIP_ANTIALIASING_IB", commit = "live",
    control = { kind = "slider", optionsFunc = function()
      local opts = {
        { value = 0, label = VIDEO_OPTIONS_NONE },
        { value = 1, label = ANTIALIASING_FXAA_LOW,  tooltip = OPTION_TOOLTIP_ANTIALIASING_FXAA_LOW  },
        { value = 2, label = ANTIALIASING_FXAA_HIGH, tooltip = OPTION_TOOLTIP_ANTIALIASING_FXAA_HIGH },
      }
      local _, cmaa, cmaa2 = AntiAliasingSupported()
      if cmaa  then opts[#opts + 1] = { value = 3, label = ANTIALIASING_CMAA,  tooltip = OPTION_TOOLTIP_ANTIALIASING_CMAA  } end
      if cmaa2 then opts[#opts + 1] = { value = 4, label = ANTIALIASING_CMAA2, tooltip = OPTION_TOOLTIP_ANTIALIASING_CMAA2 } end
      return opts
    end } },
  -- Multisample: an enumerated slider (None -> 2x -> 4x -> 8x is a clear quality ramp) over
  -- the GPU's supported formats; "None" = 0 is always present. Values are non-contiguous
  -- (0, 2, 4, 8, ...), so the slider indexes into them. The CVar packs "msaa,coverage", so
  -- the GET reads only the msaa part; the SET writes the plain number, exactly as Blizzard.
  { cvar = "MSAAQuality", name = "MSAA_LABEL", tooltip = "OPTION_TOOLTIP_ADVANCED_MSAA", commit = "live",
    get = function(raw) return tonumber((strsplit(",", raw or "0"))) or 0 end,
    control = { kind = "slider", optionsFunc = function()
      local opts = { { value = 0, label = VIDEO_OPTIONS_NONE } }
      local function add(...)
        for i = 1, select("#", ...), 3 do
          local msaaQuality, sampleCount, coverageCount = select(i, ...)
          -- "Color 8x / Depth 8x" is too wide for the readout column; the sample count is
          -- the meaningful part, so reduce it to just the "8x" (keep the full text if no
          -- such "<n>x" is present, e.g. "None" or an unexpected locale format).
          local formatted = ADVANCED_ANTIALIASING_MSAA_FORMAT:format(sampleCount, coverageCount)
          opts[#opts + 1] = {
            value = tonumber((strsplit(",", msaaQuality))),
            label = formatted:match("%d+x") or formatted,
          }
        end
      end
      add(MultiSampleAntiAliasingSupported())
      return opts
    end } },
  { cvar = "msaaAlphaTest", name = "MULTISAMPLE_ALPHA_TEST", tooltip = "OPTION_TOOLTIP_MULTISAMPLE_ALPHA_TEST", commit = "live",
    control = { kind = "checkbox" },
    -- Dead while Multisample AA is None (MSAAQuality's msaa part is 0); Blizzard gates it
    -- the same way. "None" is value 0 -- statically known -- so this needs no runtime list.
    enableWhen = function()
      local v = (C_CVar and C_CVar.GetCVar("MSAAQuality")) or "0"
      return (tonumber(strsplit(",", v)) or 0) ~= 0
    end },
  -- Range is runtime: GetCameraFOVDefaults returns (default, min, max); step 5 as Blizzard.
  { cvar = "cameraFov", name = "CAMERA_FOV", tooltip = "OPTION_TOOLTIP_CAMERA_FOV", commit = "live",
    control = { kind = "slider", step = 5,
      minFunc = function() local _, lo = GetCameraFOVDefaults(); return lo end,
      maxFunc = function() local _, _, hi = GetCameraFOVDefaults(); return hi end } },

  -- Graphics Quality: the master leads its own section (no header band -- its row is
  -- already labelled "Graphics Quality"), with its meta rows from Graphit.layer2.
  { quality = true },

  -- Advanced
  { header = "ADVANCED_LABEL" },

  -- Boolean stored oddly: gxMaxFrameLatency is 2 (off) / 3 (on). GET maps it to a 0/1
  -- checkbox, SET writes 2/3 back.
  { cvar = "gxMaxFrameLatency", name = "TRIPLE_BUFFER", tooltip = "OPTION_TOOLTIP_TRIPLE_BUFFER", commit = "gxRestart",
    get = function(raw) return raw == "3" and 1 or 0 end,
    set = function(v) return v == 1 and "3" or "2" end,
    control = { kind = "checkbox" } },

  -- Texture Filtering and Ray Traced Shadows are quality sliders whose options Blizzard
  -- validates per hardware (AddValidatedCVarOption); ValidatedOptions drops the unsupported
  -- ones and the label tooltip greys each with the engine's reason in red (OptionDetailFunc).
  -- (Resample Quality is not validated, so it stays a plain static slider. VRS is validated
  -- too, but a live dependency -- see its grey-in-place dropdown below.)
  { cvar = "textureFilteringMode", name = "ANISOTROPIC", tooltip = "OPTION_TOOLTIP_ANISOTROPIC", commit = "live",
    control = { kind = "slider", optionsFunc = function()
      return ValidatedOptions("textureFilteringMode", {
        { value = 0, label = "VIDEO_OPTIONS_BILINEAR" },
        { value = 1, label = "VIDEO_OPTIONS_TRILINEAR" },
        { value = 2, label = "VIDEO_OPTIONS_2XANISOTROPIC" },
        { value = 3, label = "VIDEO_OPTIONS_4XANISOTROPIC" },
        { value = 4, label = "VIDEO_OPTIONS_8XANISOTROPIC" },
        { value = 5, label = "VIDEO_OPTIONS_16XANISOTROPIC" },
      })
    end } },

  -- Ray Traced Shadows. The pure mirror; Graphit's behaviour (grey while shadows are off, the
  -- effective-Disabled readout, the Shadow Quality notes) lives in Settings_Logic["shadowrt"].
  { cvar = "shadowrt", name = "RT_SHADOW_QUALITY", tooltip = "OPTION_TOOLTIP_RT_SHADOW_QUALITY", commit = "live",
    control = { kind = "slider", optionsFunc = function()
      return ValidatedOptions("shadowrt", {
        { value = 0, label = "VIDEO_OPTIONS_DISABLED" },
        { value = 1, label = "VIDEO_OPTIONS_FAIR",   tooltip = "VIDEO_OPTIONS_RT_SHADOW_QUALITY_FAIR"   },
        { value = 2, label = "VIDEO_OPTIONS_MEDIUM", tooltip = "VIDEO_OPTIONS_RT_SHADOW_QUALITY_MEDIUM" },
        { value = 3, label = "VIDEO_OPTIONS_HIGH",   tooltip = "VIDEO_OPTIONS_RT_SHADOW_QUALITY_HIGH"   },
      })
    end } },

  { cvar = "ResampleQuality", name = "RESAMPLE_QUALITY", tooltip = "OPTION_TOOLTIP_RESAMPLE_QUALITY", commit = "live",
    control = { kind = "dropdown", options = {
      { value = 0, label = "RESAMPLE_QUALITY_POINT",    tooltip = "VIDEO_OPTIONS_RESAMPLE_QUALITY_POINT"    },
      { value = 1, label = "RESAMPLE_QUALITY_BILINEAR", tooltip = "VIDEO_OPTIONS_RESAMPLE_QUALITY_BILINEAR" },
      { value = 2, label = "RESAMPLE_QUALITY_BICUBIC",  tooltip = "VIDEO_OPTIONS_RESAMPLE_QUALITY_BICUBIC"  },
      { value = 3, label = "RESAMPLE_QUALITY_FSR",      tooltip = "VIDEO_OPTIONS_RESAMPLE_QUALITY_FSR"      },
    } } },

  -- VRS rendered as a real dropdown (PlainOptions keeps all options, so it never collapses to a
  -- readout) so Graphit can grey it in place. That behaviour -- the grey-out, the effective
  -- "Disabled" readout, the per-option reasons and the MSAA note -- lives in
  -- Settings_Logic["vrsValar"]. This entry is otherwise the mirror.
  { cvar = "vrsValar", name = "VRS_MODE", tooltip = "OPTION_TOOLTIP_VRS_MODE", commit = "live",
    control = { kind = "dropdown", optionsFunc = function()
      return PlainOptions({
        { value = 0, label = "VIDEO_OPTIONS_DISABLED" },
        { value = 1, label = "VIDEO_OPTIONS_STANDARD",   tooltip = "OPTION_TOOLTIP_VRS_STANDARD"   },
        { value = 2, label = "VIDEO_OPTIONS_AGGRESSIVE", tooltip = "OPTION_TOOLTIP_VRS_AGGRESSIVE" },
      })
    end } },

  -- gxapi stores an API name; it is matched case-insensitively against the available
  -- APIs. GET normalises to one of them (the last if the value is not among them); the
  -- option values are the lowercased API names, and SET writes one back as-is.
  { cvar = "gxapi", name = "GXAPI", tooltip = "OPTION_TOOLTIP_GXAPI", commit = "gxRestart",
    get = function(raw)
      local apis = { GetGraphicsAPIs() }
      for i, a in ipairs(apis) do apis[i] = string.lower(a) end
      return apis[tIndexOf(apis, string.lower(raw or "")) or #apis]
    end,
    control = { kind = "dropdown", optionsFunc = function()
      local opts = {}
      for _, api in ipairs({ GetGraphicsAPIs() }) do
        opts[#opts + 1] = { value = string.lower(api), label = _G["GXAPI_" .. string.upper(api)] or api }
      end
      return opts
    end } },
  { cvar = "physicsLevel", name = "PHYSICS_INTERACTION", tooltip = "OPTION_PHYSICS_OPTIONS", commit = "clientRestart",
    gate = function() return C_CVar and C_CVar.GetCVar("physicsLevel") ~= nil end,
    control = { kind = "dropdown", options = {
      { value = 0, label = "NO_ENVIRONMENT_INTERACTION" },
      { value = 1, label = "PLAYER_ONLY_INTERACTION"    },
      { value = 2, label = "PLAYER_AND_NPC_INTERACTION" },
    } } },
  -- gxAdapter stores an adapter name ("" = auto-detect); plain get/set. The option list
  -- is the detected adapters, labelled external / low-power where applicable.
  { cvar = "gxAdapter", name = "GRAPHICS_CARD", tooltip = "OPTION_TOOLTIP_GRAPHICS_CARD", commit = "gxRestart",
    control = { kind = "dropdown", optionsFunc = function()
      local opts = { { value = "", label = GX_ADAPTER_AUTO_DETECT } }
      for _, adapter in ipairs(C_VideoOptions.GetGxAdapterInfo()) do
        local name = adapter.name
        if adapter.isExternal then name = GX_ADAPTER_EXTERNAL:format(adapter.name)
        elseif adapter.isLowPower then name = GX_ADAPTER_LOW_POWER:format(adapter.name) end
        opts[#opts + 1] = { value = adapter.name, label = name }
      end
      return opts
    end } },

  { cvar = "maxFPS", name = "MAXFPS", tooltip = "OPTION_MAXFPS_CHECK", commit = "live",
    control = { kind = "checkboxSlider", check = "useMaxFPS",
      min = 8, max = 200, step = 1, format = function(v) return (SETTINGS_FMT_FPS or "%d"):format(v) end } },
  { cvar = "maxFPSBk", name = "MAXFPSBK", tooltip = "OPTION_MAXFPSBK_CHECK", commit = "live",
    control = { kind = "checkboxSlider", check = "useMaxFPSBk",
      min = 8, max = 200, step = 1, format = function(v) return (SETTINGS_FMT_FPS or "%d"):format(v) end } },
  { cvar = "targetFPS", name = "TARGETFPS", tooltip = "OPTION_TARGETFPS_CHECK", commit = "live",
    control = { kind = "checkboxSlider", check = "useTargetFPS",
      min = 8, max = 200, step = 1, format = function(v) return (SETTINGS_FMT_FPS or "%d"):format(v) end } },

  { cvar = "ResampleSharpness", name = "RESAMPLE_SHARPNESS", tooltip = "OPTION_TOOLTIP_SHARPNESS", commit = "live",
    -- Blizzard reverses this bar (max on the left, min on the right) via a reversed proxy;
    -- betterIsLower reproduces it exactly (bar = max - value, label = value, since min = 0).
    control = { kind = "slider", min = 0, max = 2, step = 0.1, betterIsLower = true } },

  { cvar = "Contrast",   name = "OPTION_CONTRAST",   tooltip = "OPTION_TOOLTIP_CONTRAST",   commit = "live",
    control = { kind = "slider", min = 0, max = 100, step = 1, format = FormatScaledPercentage } },
  { cvar = "Brightness", name = "OPTIONS_BRIGHTNESS", tooltip = "OPTION_TOOLTIP_BRIGHTNESS", commit = "live",
    control = { kind = "slider", min = 0, max = 100, step = 1, format = FormatScaledPercentage } },
  { cvar = "Gamma",      name = "GAMMA", tooltip = "OPTION_TOOLTIP_GAMMA", commit = "live",
    control = { kind = "slider", min = 0.3, max = 2.8, step = 0.1 } },

  -- Compatibility Settings (each shown only if its CVar exists; all need a GX restart)
  { header = "COMPATIBILITY_SETTINGS", gate = function() return _G.COMPATIBILITY_SETTINGS ~= nil end },

  { cvar = "GxCompatOptionalGpuFeatures", name = "COMPAT_SETTING_OPTIONAL_GPU_FEATURES",
    tooltip = "OPTION_TOOLTIP_COMPAT_SETTING_OPTIONAL_GPU_FEATURES", commit = "gxRestart",
    gate = function() return C_CVar and C_CVar.GetCVar("GxCompatOptionalGpuFeatures") ~= nil end,
    control = { kind = "checkbox" } },
  { cvar = "GxCompatAsyncShaderCompilation", name = "COMPAT_SETTING_DEVICE_MULTITHREADING",
    tooltip = "OPTION_TOOLTIP_COMPAT_SETTING_DEVICE_MULTITHREADING", commit = "gxRestart",
    gate = function() return C_CVar and C_CVar.GetCVar("GxCompatAsyncShaderCompilation") ~= nil end,
    control = { kind = "checkbox" } },
  { cvar = "GxCompatCommandListMultiThreading", name = "COMPAT_SETTING_CMDLIST_MULTITHREADING",
    tooltip = "OPTION_TOOLTIP_COMPAT_SETTING_CMDLIST_MULTITHREADING", commit = "gxRestart",
    gate = function() return C_CVar and C_CVar.GetCVar("GxCompatCommandListMultiThreading") ~= nil end,
    control = { kind = "checkbox" } },
  { cvar = "GxCompatWorkSubmitOptimizations", name = "COMPAT_SETTING_ADV_WORK_SUBMIT",
    tooltip = "OPTION_TOOLTIP_COMPAT_SETTING_ADV_WORK_SUBMIT", commit = "gxRestart",
    gate = function() return C_CVar and C_CVar.GetCVar("GxCompatWorkSubmitOptimizations") ~= nil end,
    control = { kind = "checkbox" } },
}
