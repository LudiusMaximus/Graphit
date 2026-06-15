local _, Graphit = ...

-- =====================================================================
-- Hand-authored graphics settings descriptor (Layers 1 and 2), derived from
-- Blizzard's Graphics.lua.
--
-- This is the user-facing list of Blizzard graphics settings in display
-- order. Each entry holds the localized-string KEYS (name, tooltip, option
-- labels) and the parent control: a dropdown's options or a slider's range.
-- Following the project rule, only keys are stored here and resolved to the
-- player's locale at display time via _G[key].
--
-- It deliberately does not list the Layer-3 children. Which child CVars a
-- meta expands into lives in GraphicsSettings_extracted.lua (the dump), and
-- each child's control type lives in GraphicsSettings_controlTypes.lua; the
-- UI joins the three by CVar name. A setting is expandable exactly when it
-- has an entry in the extracted data.
-- =====================================================================

Graphit.graphicsSettings = {

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

  -- TODO (next pass): the graphicsQuality master (Layer-1 grandparent that
  -- drives the metas above), and the display / advanced / compat blocks
  -- (monitor, display mode, resolution, render scale, UI scale, vsync,
  -- low latency, antialiasing [compound: ffxAntiAliasingMode + MSAAQuality],
  -- camera FOV, triple buffering, texture filtering, ray traced shadows,
  -- resample quality/sharpness, VRS, graphics API, physics, graphics card,
  -- FPS caps, contrast, brightness, gamma, compat toggles). Those carry
  -- commit-flag nuances (GxRestart / ClientRestart) that the UI must mark as
  -- non-live, so capture a `commit` field per setting when adding them.
}
