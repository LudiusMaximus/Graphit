local _, Graphit = ...

-- =====================================================================
-- Our DECLARATIVE customizations. (Per-setting behaviour -- enableWhen, value transforms,
-- smart tooltips -- is its own hand-edited file, Settings_Logic.lua.)
--
-- Settings_Source.lua and Settings_Dump.lua are mechanical and never hand-edited:
-- Settings_Source.lua mirrors Blizzard's Graphics.lua (the settings, their
-- names, controls, and order), and Settings_Dump.lua is the runtime dump
-- (each meta's raw child CVars and their value at every quality level). The UI
-- renders straight from those two on its own: every Layer-2 setting in Blizzard's
-- order, and -- for an expandable meta -- its Layer-3 children, each as a slider by
-- default (a Blizzard dropdown keeps its labels on the slider readout). A child a
-- future patch adds therefore shows up with no change here.
--
-- This file is the overlay of our declarative decisions on top of that. Every field is
-- optional; an empty descriptor changes nothing. There are five independent parts, so
-- assigning a section to a tab, reordering it, overriding it, and adding a custom
-- setting never interfere:
--
--   sectionTab  Which tab a section appears on: 1 = "Performance vs. Quality" (the
--               default), 2 = "General and Static". Keyed by the section's header
--               global-string key; the header and every setting under it (down to the
--               next header) move together. The nameless top section and the Graphics
--               Quality group have no header, so they always stay on tab 1.
--                   sectionTab = { ["COMPATIBILITY_SETTINGS"] = 2 },
--
--   order       A list of Layer-2 CVars to show first, in this order; the rest
--               keep Blizzard's order after them.
--                   order = { "graphicsViewDistance", "graphicsShadowQuality" },
--
--   childOrder  Per meta, a list of child CVars to show first; the rest follow
--               alphabetically.
--                   childOrder = {
--                     ["graphicsViewDistance"] = { "farclip", "horizonStart" },
--                   },
--
--   overrides   Per CVar (Layer 2 or Layer 3), a table that may set:
--                 hidden = true    removes the row from the list. The CVar still
--                                  cascades from the parent and still counts
--                                  toward the parent's level; it is only hidden.
--                 control = {...}  every setting defaults to a slider (a Blizzard
--                                  dropdown keeps its labels on the slider readout);
--                                  use this to adjust the control. It MERGES over the
--                                  base, at any layer -- state only what changes, e.g.
--                                  control = { step = 1 }. An explicit kind = "dropdown"
--                                  forces a real dropdown instead of the slider default.
--                                  Fields: kind = "slider" | "dropdown" |
--                                  "checkbox" (a checkbox is for a 0/1 CVar); a
--                                  slider's min / max / step and optional labels = { [0] =
--                                  "Off", [1] = "On" } naming the readout; a Layer-3
--                                  dropdown's values = { 0, 1, 2 } (a Layer-2
--                                  dropdown reuses Blizzard's labelled options unless
--                                  it lists its own); and betterIsLower = true when a
--                                  smaller raw value means higher quality, which
--                                  reverses the control so its better (lower) end
--                                  leads -- the right on a slider, the Forward
--                                  stepper / worst-to-best menu on a dropdown.
--                 deferApply = true  park this CVar for the Apply button instead of
--                                  writing it live. For a Layer-3 child that freezes the
--                                  game, only a change reached through its parent / the
--                                  master is parked (its own control still applies at
--                                  once, freeze accepted). For a standalone Layer-1
--                                  setting (uiscale) the setting's own control stages too,
--                                  used when a live write is disruptive mid-edit.
--                 confirmApply = true  a stronger deferApply (implies it): after the Apply
--                                  button commits this setting, a countdown popup appears
--                                  and reverts it unless kept -- for a setting that can make
--                                  the client unusable (RenderScale at 200% drops FPS to ~1).
--                 tooltip = "..."  the hover tooltip shown over the row's name. For
--                                  Layer 1 / Layer 2 it overrides Blizzard's; for a
--                                  Layer-3 child it is the only source (none shows
--                                  otherwise). Literal text, or a global-string key
--                                  (resolved at display time).
--                   overrides = {
--                     ["horizonClip"]           = { hidden = true },
--                     ["lodObjectMinSize"]      = { control = { kind = "slider", min = 0, max = 50 } },
--                     ["cameraFov"]             = { control = { step = 1 } },  -- finer step; keeps the runtime min/max
--                     ["graphicsShadowQuality"] = { control = { kind = "dropdown" } },  -- keep Blizzard's labelled dropdown
--                     ["worldBaseMip"]          = { deferApply = true, tooltip = "Texture streaming base mip; lower is sharper." },
--                   },
--
--   custom      A list of settings defined entirely here -- a CVar with no Blizzard
--               panel control and no dump entry. Each entry is a full row: cvar, name,
--               a control (typically a checkbox for a 0/1 CVar), and an optional
--               tooltip (literal text or a global-string key). They render as plain
--               rows after the Blizzard list, in the order listed (unless `order`
--               hoists one above).
--                   custom = {
--                     { cvar = "ResampleAlwaysSharpen", name = "Always Sharpen",
--                       control = { kind = "checkbox" }, tooltip = "..." },
--                   },
-- =====================================================================

Graphit.descriptor = {

  sectionTab = {
    ["COMPATIBILITY_SETTINGS"] = 2,  -- the Compatibility section moves to the static tab
  },

  childOrder = {
    ["graphicsEnvironmentDetail"] = { "doodadLodScale", "lodObjectFadeScale", "lodObjectCullSize", "lodObjectMinSize" },
  },

  overrides = {

    -- graphicsViewDistance

    -- beyond 1024 has no effect
    ["TerrainLodDiv"] = { control = { min=0, max=1024, step=32 } },

    -- original 5-10
    ["entityLodDist"] = { control = { min=0, max=50, step=1 } },

    -- original 10-50
    ["entityShadowFadeScale"] = { control = { min=0, max=200, step=5 } },


    -- Draw less detailed terrain in the distance.
    -- Small values also hide horizonStart renderings.
    -- original 1500-10000
    -- below 1000 has no effect any more.
    ["farclip"] = { control = { min=1000, max=20000, step=10 } },


    -- Does nothing at all.
    -- original 1500-10000
    ["horizonClip"] = { hidden=true },


    -- Detailed rendering distance (replaces non-detailed farclip rendering)
    -- original 400-4000
    -- beyond 6000 has no effect.
    ["horizonStart"] = { control = { min=0, max=6000, step=10 } },
  

    -- more polygons/textures for terrain in distance
    -- original 200-650
    ["terrainLodDist"] = { control = { min=0, max=3000, step=5 } },

    -- more polygons/textures/lighting effects for objects, particularly buildings in distance.
    -- original 250-400
    ["wmoLodDist"] = { control = { min=0, max=2000, step=5 } },
    

    -- graphicsEnvironmentDetail


    -- original 50-150
    ["doodadLodScale"] = { control = { min=0, max=500, step=1 } },

    -- original 50-150
    -- When you go below 50, the engine snaps back to 50 when you change other cvars. 
    ["lodObjectFadeScale"] = { control = { min=50, max=500, step=1 } },


    -- original 35-14
    ["lodObjectCullSize"] = { control = { min=1, max=50, step=1, betterIsLower=true } },

    -- original 30-0
    ["lodObjectMinSize"]  = { control = { min=0, max=50, step=1, betterIsLower=true } },


    -- graphicsTextureResolution

    -- Changing worldBaseMip stalls the game for several seconds, so defer it when
    -- it is reached through Texture Resolution or the master slider; its own
    -- drop-down still applies immediately.
    ["worldBaseMip"] = { deferApply = true },

    
    ["shadowTextureSize"] = { control = { step=1024 } },


    -- Camera FOV (top section)

    -- Blizzard steps the FOV slider by 5; we prefer step 1. We change only `step`: the
    -- override merges over the base, so the base's runtime min/max (GetCameraFOVDefaults)
    -- are kept -- and those are the only USABLE bounds, since the camera engine clamps the
    -- FOV to that range anyway. (A static min/max here would widen the bar but not the
    -- usable range; it would just add positions the engine clamps back.)
    ["cameraFov"] = { control = { step = 1 } },


    -- UI Scale (top section)

    -- Writing uiscale live rescales the whole UI, sliding the Graphit frame out from under
    -- the slider mid-drag. Stage it for the Apply button instead (the compound stages its
    -- useUiScale enable along with it), so the rescale happens once, on apply.
    ["uiscale"] = { deferApply = true },


    -- Render Scale (top section)

    -- A high render scale can crater FPS (200% -> ~1 FPS), so applying it live is risky.
    -- confirmApply stages it AND, after the Apply button, pops a countdown popup that
    -- reverts unless kept (see MainFrame's ApplyPending / RevertConfirmSnapshot).
    ["RenderScale"] = { confirmApply = true },

    -- TODO (next): Ray Traced Shadows need at least Shadow Quality "Good"
    -- (shadowMode >= 2, shadowNumCascades >= 2) or they have no effect.


  },

  custom = {
    -- A 0/1 CVar with no Blizzard panel control and no dump entry; defined here in
    -- full. Forces image sharpening even at 100% render scale, where the resample
    -- pass (and thus the sharpen filter) is normally skipped.
    {
      cvar    = "ResampleAlwaysSharpen",
      name    = "Always Sharpen",
      control = { kind = "checkbox" },
      tooltip = "Forces image sharpening even at 100% render scale, where it is normally skipped.\nTakes a few seconds to show its effect.",
    },
  },

}
