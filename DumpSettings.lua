local _, Graphit = ...

-- =====================================================================
-- Graphit settings dump tool.
--
-- This is a developer/maintenance tool, but we ship it with the addon anyway:
-- the footprint is tiny (it lazily builds its window and registers two slash
-- commands), and excluding one file from a release would mean keeping a
-- .pkgmeta ignore and the TOC in sync, which is not worth it.
--
-- It builds Settings_Dump.lua. For each Blizzard "secondary" graphics setting
-- (a secondary, e.g. graphicsViewDistance) it discovers which raw engine CVars
-- (a tertiary, e.g. farclip) that secondary drives, and the value each takes at every
-- level. The client computes this mapping in C; it is not in wow-ui-source. So
-- we sweep the secondary CVar through its levels and diff the full CVar table at each
-- step, one secondary at a time, so a changed raw CVar is unambiguously a tertiary of
-- that secondary.
--
-- The preset setting graphicsQuality (the preset) does NOT cascade via SetCVar
-- (Blizzard maps it in Lua), so for it we query the C function
-- GetGraphicsCVarValueForQualityLevel directly. See RunQualityMatrix.
--
-- Commands:
--   /graphitdump <secondaryCvar> [maxLevel]   sweep one setting -> window
--   /graphitdumpall                      sweep every setting -> a complete,
--                                        paste-ready Settings_Dump.lua
--
-- =====================================================================
-- PATCH-DAY MAINTENANCE  (after a client patch touches graphics options)
-- =====================================================================
--
-- (1) SOURCE INVESTIGATION  (read wow-ui-source; transcribe into Settings_Source.lua)
--
--   COMPLETENESS SWEEP -- catch NEW and REMOVED settings, not only changes to ones we have.
--   Read Graphics.lua's Register() top to bottom; every control it creates (Settings.Create
--   Slider / CreateDropdown / CreateCheckbox, CreateSettingsCheckboxSliderInitializer, and
--   the validated / proxy variants) must map to a Settings_Source entry (layer1 or layer2)
--   OR to the deliberate-omissions list below. A control with no match is NEW -> transcribe
--   it. Conversely, every cvar in Settings_Source must still be created somewhere in
--   Register(); one that is gone means Blizzard REMOVED it -> drop ours. While walking,
--   check each initializer for behaviour beyond a plain control and mirror (or consciously
--   skip) it -- the easy-to-miss kind:
--     - per-option tooltip / warning -> container:Add(value, label, TOOLTIP) or .warning
--     - recommended default -> AddRecommended (auto for quality secondaries)
--     - reversed slider -> getValueReversed / (max - value) proxy -> betterIsLower
--     - custom label format -> options:SetLabelFormatter -> control.format
--     - parent gate -> SetParentInitializer + IsModifiable -> enableWhen
--     - runtime option list / range -> GetOptions / GetMinX -> optionsFunc / minFunc, maxFunc
--     - the control's hover detail -> CreateOptionsInitTooltip (the per-option lines)
--
--   Deliberately NOT mirrored (do not re-flag as "missing"):
--     - Raid Graphics (RaidSettingsEnabled, PROXY_RAID_GRAPHICS_QUALITY and its advanced
--       table) -- Graphit's per-scenario profiles supersede a raid-only preset.
--     - The "Antialiasing" parent dropdown -- it only gates its two tertiaries, so we drop it
--       and expose Image-Based / Multisample (+ the alpha-test checkbox) directly as primary rows.
--     - The "New" feature badge (IsNewSettingInCurrentVersion) -- keyed to Blizzard's proxy
--       variables, which we do not register.
--
--   File: Blizzard_Settings_Shared/Mainline/GraphicsOverrides.lua
--     CreateAdvancedSettingsTable() lists every secondary CVar
--     (graphicsQuality, graphicsShadowQuality, ... graphicsGroundClutter)
--     in the order Blizzard displays them.
--       -> Reconcile with SECONDARY_SETTINGS below: add / remove / rename /
--          reorder to match. Note conditional entries (e.g. graphicsSpellDensity
--          is gated by C_VideoOptions.IsSpellVisualDensitySystemSupported()).
--
--   File: Blizzard_SettingsDefinitions_Shared/Graphics.lua
--     - Option-builder functions (GetShadowQualityOptions,
--       GetLiquidDetailOptions, ...) add one entry per selectable value; the
--       highest value is that secondary's max level. The three slider secondaries
--       (graphicsViewDistance / EnvironmentDetail / GroundClutter) use the
--       0-9 slider (search `minValue, maxValue, step = 0, 9, 1`).
--       -> Update the maxLevel in SECONDARY_SETTINGS below for any secondary whose
--          value count changed.
--     - SettingsAdvancedQualityControlsMixin:Init and the OnGCChanged path
--       confirm the preset still cascades through
--       GetGraphicsCVarValueForQualityLevel(cvar, level, raid). If Blizzard
--       changes that mechanism, update RunQualityMatrix.
--     - Settings_Source.lua is transcribed by hand from this file the same patch (a
--       separate file from this tool). It holds TWO tables:
--         * Graphit.layer2 -- the Graphics Quality group: the preset and its
--           secondary settings (names, tooltips, controls, option enums, gates). A
--           setting's tooltip is the OPTION_TOOLTIP_* key passed to its control
--           builder; copy it into `tooltip` (a secondary without one shows no tooltip).
--         * Graphit.layer1 -- the top-level section LAYOUT, mirroring how Graphics.lua's
--           Register() lays the category out: section headers
--           (CreateSettingsListSectionHeaderInitializer -> { header = "KEY" }; the
--           nameless top section has none), a { quality = true } marker where the
--           Graphics Quality group sits, and each standalone display / advanced /
--           compat setting as a row in Blizzard's order. Per standalone setting:
--             - cvar, name, tooltip; and a `control` (see the toolbox below).
--             - commit, read from the setting's SetCommitFlags: GxRestart ->
--               "gxRestart", UpdateWindow -> "windowUpdate", ClientRestart ->
--               "clientRestart", else "live" (a bare Apply flag is panel batching only
--               -> "live"). Drives how MainFrame applies it: live / windowUpdate at once,
--               gxRestart staged on the Apply button (commit runs RestartGx),
--               clientRestart written now but tinted violet until a real restart.
--             - gate, from an AddShownPredicate or a C_CVar.GetCVar(...) check.
--           Control toolbox -- match Blizzard's GetOptions / accessor pattern:
--             * static:        control = { kind = "slider" | "dropdown" | "checkbox", ... }
--                              (a quality scale -> slider, a categorical list -> dropdown).
--             * runtime list:  control.optionsFunc = function() ... return { { value=,
--                              label= }, ... } end -- a Blizzard GetOptions built at run
--                              time (monitor, resolution, graphics API / card, MSAA).
--             * validated list (AddValidatedCVarOption): optionsFunc returning
--                              ValidatedOptions(cvar, defs) -- drops options the hardware
--                              does not support; the label tooltip greys each dropped option
--                              with the engine's reason in red (Low Latency, RT Shadows,
--                              Texture Filtering). Reason strings come from GFX_VALUE_ERRORS,
--                              transcribed from Graphics.lua's ErrorMessages -- re-transcribe
--                              it if it changes. NOTE: VRS (vrsValar) is validated too, but its
--                              availability flips live (Multisample AA overrules it), so it is
--                              deliberately NOT a validated slider -- it is a grey-in-place
--                              dropdown: PlainOptions in Settings_Source, the grey-in-place
--                              behaviour in Settings_Logic. Keep it that way.
--             * runtime range (GetMinX / GetMaxX): control = { kind = "slider",
--                              minFunc =, maxFunc = } (Camera FOV).
--             * value transform (the CVar value differs from the control value): get =
--                              function(raw) ... end and/or set = function(v) ... return
--                              cvarString end (MSAA's "msaa,coverage", Graphics API
--                              case-fold, Triple Buffering's 2/3).
--             * conditional disable (one setting's IsModifiable / a runtime state gates
--                              another): enableWhen = function() return ... end, optionally
--                              with disabledTooltip = "why" so the greyed control still
--                              explains itself on hover (MSAA alpha test; Resolution while
--                              the window is maximised).
--             * checkbox + slider (CreateSettingsCheckboxSliderInitializer): control =
--                              { kind = "checkboxSlider", check = "<enableCVar>", min =,
--                              max =, step =, format = } -- an enable checkbox plus a value
--                              slider that greys while unchecked (Max FPS caps, UI Scale).
--             * CVar-less (a setting Blizzard drives through C_VideoOptions, not a CVar):
--                              drop cvar and give read / write closures, plus an optionsFunc
--                              of literal labels (Resolution). The Render Scale slider keeps
--                              its RenderScale CVar but its label is a runtime format.
--           placeholder = true is for a setting not yet wired up (none at present).
--
--           Where it lands: control structure, and faithful transcriptions of Blizzard's own
--           per-setting code (a value encoding via get / set, a parent IsModifiable gate via
--           enableWhen), go in Settings_Source with the mirror. Graphit's OWN behaviour -- a
--           cross-setting dependency, an effective-value readout, a hand-written tooltip (VRS,
--           Ray Traced Shadows, Resolution's maximised lock) -- goes in Settings_Logic, keyed by
--           CVar (or name for a CVar-less setting) and merged onto the mirror at render.
--
--           Per-option detail: a dropdown option is { value, label }, plus optional tooltip
--           (the per-option explanation) and warning (shown only while that option is the
--           current value). Transcribe BOTH whenever Blizzard's option carries them -- they
--           are no longer dead data: MainFrame appends them to the setting's hover tooltip,
--           mirroring Blizzard's control tooltip (CreateOptionsInitTooltip). The green
--           "Recommended" marker needs no transcription; it is derived at runtime (the
--           option equal to the CVar default) for every quality secondary, as AddRecommended does.
--
--           Two gotchas worth remembering when transcribing:
--             - Helpers called inside Graphics.lua may be `local function`s there
--               (FormatScreenResolution, ExtractSizeFromFormattedSize), NOT globals -- so
--               calling them from the addon is a runtime nil error. Copy a small
--               reimplementation into Settings_Source (see the top of its layer1 block).
--             - A CVar-less or proxy setting has no reliable CVar callback, so it will not
--               sync inward on its own. Register the game event it fires instead, in
--               MainFrame's inward-sync block: resolution -> DISPLAY_SIZE_CHANGED, UI scale
--               -> UI_SCALE_CHANGED, graphics API / card -> GX_RESTARTED.
--
-- (2) DUMP THE VALUES
--
--   /reload, then /graphitdumpall. Each secondary flickers through its levels
--   (~30-40s total) and restores its original value. If a secondary reports
--   "no tertiary CVars changed", the SetCVar cascade no longer works for it --
--   investigate in source before trusting the output. Select All -> copy ->
--   replace the ENTIRE contents of Settings_Dump.lua. `git diff` it: the
--   build stamp always changes; added / removed tertiary CVars and retuned values
--   are the real patch changes.
--
--   There is no third step. tertiaries default to a slider in MainFrame, and
--   any deviations live in Settings_Custom.lua, so a new tertiary CVar appears on its
--   own; revisit the customized overlay only to reorder or
--   re-style it.
-- =====================================================================


-- The preset setting (the overall "Graphics Quality" 0-9 slider).
-- Handled on its own path: it does NOT cascade via SetCVar, so it is not
-- swept like the secondaries below; RunQualityMatrix queries it through
-- GetGraphicsCVarValueForQualityLevel instead.
local PRESET_CVAR = "graphicsQuality"
local MASTER_MAX_LEVEL = 9

-- =====================================================================
-- THE patch-day table. Every secondary CVar (each swept via SetCVar),
-- in Blizzard's display order, with its max level (0-based, inclusive).
-- Reconcile with the Blizzard source after a client patch (see header).
-- This is the single source of truth; the code iterates it directly.
-- =====================================================================
local SECONDARY_SETTINGS = {
  { cvar = "graphicsViewDistance",      maxLevel = 9 },
  { cvar = "graphicsShadowQuality",     maxLevel = 5 },
  { cvar = "graphicsLiquidDetail",      maxLevel = 3 },
  { cvar = "graphicsParticleDensity",   maxLevel = 5 },
  { cvar = "graphicsSSAO",              maxLevel = 4 },
  { cvar = "graphicsDepthEffects",      maxLevel = 3 },
  { cvar = "graphicsComputeEffects",    maxLevel = 4 },
  { cvar = "graphicsOutlineMode",       maxLevel = 2 },
  { cvar = "graphicsTextureResolution", maxLevel = 2 },
  { cvar = "graphicsSpellDensity",      maxLevel = 2 },
  { cvar = "graphicsProjectedTextures", maxLevel = 1 },
  { cvar = "graphicsEnvironmentDetail", maxLevel = 9 },
  { cvar = "graphicsGroundClutter",     maxLevel = 9 },
}

-- Scope note: only MULTI-tertiary secondaries produce generated data. The
-- other Blizzard graphics settings -- the display / advanced / compat blocks
-- (vsync, textureFilteringMode, shadowrt, ResampleQuality, vrsValar,
-- LowLatencyMode, antialiasing, gamma, render scale, FPS caps, ...) -- were
-- swept once and found to be direct single-CVar controls (no cascade), so they
-- live in Graphit.layer1 in Settings_Source.lua, not here; no need to re-sweep them
-- each patch. Single-tertiary secondaries are likewise omitted by the dump (see
-- BuildResult): a lone tertiary is a 1:1 alias with nothing to expand.

-- Max level for a secondary CVar by name, for the single-CVar /graphitdump
-- command (unknown CVars fall back to 9). /graphitdumpall does not need
-- this -- it reads each entry's maxLevel straight from SECONDARY_SETTINGS.
local function MaxLevelFor(cvar)
  for _, entry in ipairs(SECONDARY_SETTINGS) do
    if entry.cvar == cvar then return entry.maxLevel end
  end
  return 9
end




-- ---------------------------------------------------------------------
-- Tunables
-- ---------------------------------------------------------------------
-- Seconds to wait after writing a secondary CVar before snapshotting, so the
-- engine has cascaded the change to its raw CVars.
local SETTLE_DELAY = 0.20
-- Seconds between sweep steps.
local STEP_DELAY = 0.05
-- Output window size, in pixels.
local WINDOW_WIDTH = 720
local WINDOW_HEIGHT = 460


-- ---------------------------------------------------------------------
-- CVar access (use the namespaced C_CVar API, fall back to globals).
-- ---------------------------------------------------------------------
local GetCVar = C_CVar and C_CVar.GetCVar or _G.GetCVar
local SetCVar = C_CVar and C_CVar.SetCVar or _G.SetCVar

-- C_Console was folded back into the global namespace in 10.2.0
-- (ConsoleGetAllCommands); older/Classic clients still expose
-- C_Console.GetAllCommands. Support both.
local GetAllCommands = C_Console and C_Console.GetAllCommands or _G.ConsoleGetAllCommands

-- ---------------------------------------------------------------------
-- The copy-paste output window.
-- ---------------------------------------------------------------------
local outerFrame, editBox, scrollFrame

local function BuildWindow()
  if outerFrame then return end

  outerFrame = CreateFrame("Frame", "GraphitDumpSettingsFrame", UIParent, "TooltipBackdropTemplate")
  outerFrame:SetSize(WINDOW_WIDTH + 60, WINDOW_HEIGHT + 70)
  outerFrame:SetPoint("CENTER")
  outerFrame:SetMovable(true)
  outerFrame:EnableMouse(true)
  outerFrame:RegisterForDrag("LeftButton")
  outerFrame:SetScript("OnDragStart", outerFrame.StartMoving)
  outerFrame:SetScript("OnDragStop", outerFrame.StopMovingOrSizing)
  outerFrame:SetFrameStrata("HIGH")
  outerFrame:SetClampedToScreen(true)

  local title = outerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  title:SetPoint("TOP", outerFrame, "TOP", 0, -10)
  title:SetText("Graphit Dump")

  local scrollBorder = CreateFrame("Frame", nil, outerFrame, "TooltipBackdropTemplate")
  scrollBorder:SetSize(WINDOW_WIDTH + 14, WINDOW_HEIGHT + 10)
  scrollBorder:SetPoint("TOP", title, "BOTTOM", 0, -10)

  scrollFrame = CreateFrame("ScrollFrame", nil, outerFrame, "UIPanelScrollFrameTemplate")
  scrollFrame:SetSize(WINDOW_WIDTH - 20, WINDOW_HEIGHT)
  scrollFrame:SetPoint("TOP", scrollBorder, "TOP", -10, -5)

  editBox = CreateFrame("EditBox", nil, scrollFrame, "InputBoxScriptTemplate")
  editBox:SetMultiLine(true)
  editBox:SetAutoFocus(false)
  editBox:SetFontObject(ChatFontNormal)
  editBox:SetWidth(WINDOW_WIDTH - 20)
  editBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
  scrollFrame:SetScrollChild(editBox)

  local clearBtn = CreateFrame("Button", nil, outerFrame, "UIPanelButtonTemplate")
  clearBtn:SetSize(90, 22)
  clearBtn:SetPoint("BOTTOMLEFT", scrollBorder, "BOTTOMLEFT", 0, -30)
  clearBtn:SetText("Clear")
  clearBtn:SetScript("OnClick", function() editBox:SetText("") end)

  local selectBtn = CreateFrame("Button", nil, outerFrame, "UIPanelButtonTemplate")
  selectBtn:SetSize(90, 22)
  selectBtn:SetPoint("LEFT", clearBtn, "RIGHT", 8, 0)
  selectBtn:SetText("Select All")
  selectBtn:SetScript("OnClick", function()
    editBox:SetFocus()
    editBox:HighlightText()
  end)

  local closeBtn = CreateFrame("Button", nil, outerFrame, "UIPanelButtonTemplate")
  closeBtn:SetSize(90, 22)
  closeBtn:SetPoint("BOTTOMRIGHT", scrollBorder, "BOTTOMRIGHT", 0, -30)
  closeBtn:SetText("Close")
  closeBtn:SetScript("OnClick", function() outerFrame:Hide() end)
end

local function ShowWindow()
  BuildWindow()
  outerFrame:Show()
end

local function ClearOutput()
  ShowWindow()
  editBox:SetText("")
end

local function AppendOutput(text)
  ShowWindow()
  local cur = editBox:GetText()
  editBox:SetText(cur == "" and text or (cur .. "\n\n" .. text))
  editBox:SetCursorPosition(0)
  scrollFrame:SetVerticalScroll(0)
end

-- True while /graphitdumpall is running: per-block standalone headers are
-- suppressed so the appended blocks form one complete, paste-ready file.
local batchMode = false


-- ---------------------------------------------------------------------
-- Output helpers shared by the single-CVar and preset dumps.
-- ---------------------------------------------------------------------

-- Print a status line with the standard colored "Graphit dump:" prefix.
local function Report(color, fmt, ...)
  print(("|cff%sGraphit dump:|r "):format(color) .. fmt:format(...))
end

-- Two comment lines stamping a single-CVar dump. Omitted in batch mode,
-- where FileHeader already stamps the whole file.
local function StandaloneHeader(cvar, maxLevel)
  local version, build = GetBuildInfo()
  return ("-- %s  (levels 0-%d)\n-- generated %s  -  WoW %s build %s")
    :format(cvar, maxLevel, date("%Y-%m-%d"), version, build)
end

-- One data line for the generated file:
--   ["name"] = { min=.., max=.., [0]=.., [1]=.., ... },
-- valueAt(level) returns the (string) value at that level; min/max are the
-- lowest/highest numeric values seen across the levels.
local function FormatEntry(name, maxLevel, valueAt)
  local parts = {}
  local lo, hi, loStr, hiStr
  for level = 0, maxLevel do
    local v = valueAt(level)
    parts[#parts + 1] = ("[%d]=%q"):format(level, v)
    local n = tonumber(v)
    if n then
      if not lo or n < lo then lo, loStr = n, v end
      if not hi or n > hi then hi, hiStr = n, v end
    end
  end
  local range = loStr and ("min=%q, max=%q, "):format(loStr, hiStr) or ""
  return ("  [%q] = { %s%s },"):format(name, range, table.concat(parts, ", "))
end


-- ---------------------------------------------------------------------
-- Enumerate every CVar currently registered on the client.
-- ---------------------------------------------------------------------
local CVAR_COMMAND_TYPE = Enum.ConsoleCommandType and Enum.ConsoleCommandType.Cvar

local function GetAllCVarNames()
  local names, seen = {}, {}
  for _, cmd in ipairs(GetAllCommands()) do
    local name = cmd.command
    if name and not seen[name] then
      -- Prefer the documented commandType field; fall back to a GetCVar
      -- probe if the enum is unavailable on this client.
      local isCVar
      if CVAR_COMMAND_TYPE ~= nil then
        isCVar = cmd.commandType == CVAR_COMMAND_TYPE
      else
        isCVar = GetCVar(name) ~= nil
      end
      if isCVar then
        seen[name] = true
        names[#names + 1] = name
      end
    end
  end
  return names
end


-- ---------------------------------------------------------------------
-- Build and show the result once all snapshots are gathered.
-- ---------------------------------------------------------------------
local function BuildResult(secondary, maxLevel, names, snapshots)
  -- A CVar is a tertiary of `secondary` if its value was not constant across the
  -- whole sweep.
  local tertiaries = {}
  for _, name in ipairs(names) do
    if name ~= secondary then
      local base = snapshots[0][name]
      for level = 1, maxLevel do
        if snapshots[level][name] ~= base then
          tertiaries[#tertiaries + 1] = name
          break
        end
      end
    end
  end
  table.sort(tertiaries)

  local lines = {}
  local function add(s) lines[#lines + 1] = s end

  if not batchMode then
    add(StandaloneHeader(secondary, maxLevel))
  end
  if #tertiaries == 0 then
    add("-- WARNING: no tertiary CVars changed during the sweep.")
    add("-- Setting this secondary CVar via SetCVar may not cascade immediately")
    add("-- (might need an apply/restart); another trigger may be required.")
    AppendOutput(table.concat(lines, "\n"))
    Report("ff8800", "no tertiaries changed for %s - see window.", secondary)
    return
  end

  if #tertiaries == 1 then
    -- A lone tertiary means the secondary is a 1:1 alias of that one raw CVar, so
    -- there is nothing to expand; Settings_Source.lua exposes the secondary directly.
    add(("-- %s: single tertiary (%s); direct control, not expanded."):format(secondary, tertiaries[1]))
    AppendOutput(table.concat(lines, "\n"))
    Report("66ff66", "%s -> 1 tertiary (%s), omitted as a direct control.", secondary, tertiaries[1])
    return
  end

  add(("-- %s: %d tertiary CVar(s): %s"):format(secondary, #tertiaries, table.concat(tertiaries, ", ")))
  if not batchMode then
    add("-- min/max = lowest/highest value OBSERVED; not engine limits (widen by hand).")
  end
  add(("[%q] = {"):format(secondary))
  for _, tertiary in ipairs(tertiaries) do
    add(FormatEntry(tertiary, maxLevel, function(level) return snapshots[level][tertiary] or "" end))
  end
  add("},")

  AppendOutput(table.concat(lines, "\n"))
  Report("66ff66", "%s -> %d tertiary CVar(s).", secondary, #tertiaries)
end


-- ---------------------------------------------------------------------
-- The sweep itself: step the secondary CVar 0..maxLevel, snapshotting all
-- CVars after a short settle delay at each level, then restore.
-- ---------------------------------------------------------------------
local sweepRunning = false

local function RunSweep(secondary, maxLevel, onComplete)
  if sweepRunning then
    Report("ff8800", "a sweep is already running.")
    return
  end
  if not GetAllCommands then
    Report("ff4040", "no CVar enumeration API on this client (ConsoleGetAllCommands / C_Console.GetAllCommands).")
    return
  end
  if GetCVar(secondary) == nil then
    Report("ff4040", "unknown CVar '%s', skipped.", secondary)
    if onComplete then onComplete() end
    return
  end

  sweepRunning = true
  local names = GetAllCVarNames()
  local original = GetCVar(secondary)
  local snapshots = {}

  Report("66ccff", "sweeping %s (0-%d) over %d CVars...", secondary, maxLevel, #names)

  local level = 0
  local function StepIn()
    SetCVar(secondary, tostring(level))
    -- Let the engine cascade the secondary change to its raw CVars before we read.
    C_Timer.After(SETTLE_DELAY, function()
      local snap = {}
      for _, name in ipairs(names) do
        snap[name] = GetCVar(name)
      end
      snapshots[level] = snap

      level = level + 1
      if level <= maxLevel then
        C_Timer.After(STEP_DELAY, StepIn)
      else
        SetCVar(secondary, original)  -- restore (re-cascades tertiaries back)
        sweepRunning = false
        BuildResult(secondary, maxLevel, names, snapshots)
        if onComplete then onComplete() end
      end
    end)
  end
  StepIn()
end


-- graphicsQuality (the preset) does NOT cascade to its secondary CVars
-- via SetCVar; Blizzard's UI maps it in Lua through
-- GetGraphicsCVarValueForQualityLevel. So for the preset we query that
-- function directly: preset level -> each secondary CVar's level (preset -> secondary).
local function RunQualityMatrix(onComplete)
  local fn = _G.GetGraphicsCVarValueForQualityLevel
  if not fn then
    AppendOutput(("-- %s: GetGraphicsCVarValueForQualityLevel unavailable on this client."):format(PRESET_CVAR))
    if onComplete then onComplete() end
    return
  end

  local maxLevel = MASTER_MAX_LEVEL
  local lines = {}
  local function add(s) lines[#lines + 1] = s end

  if not batchMode then
    add(StandaloneHeader(PRESET_CVAR, maxLevel))
  end
  add(("-- %s: preset -> secondary CVar level (preset -> secondary)"):format(PRESET_CVAR))
  add(("[%q] = {"):format(PRESET_CVAR))
  for _, entry in ipairs(SECONDARY_SETTINGS) do
    local secondary = entry.cvar
    add(FormatEntry(secondary, maxLevel, function(level) return tostring(fn(secondary, level, false)) end))
  end
  add("},")

  AppendOutput(table.concat(lines, "\n"))
  Report("66ff66", "graphicsQuality matrix via quality function.")
  if onComplete then onComplete() end
end

-- The namespace header that opens the generated file, with current build
-- stamp, ending at the opening brace of the data table.
local function FileHeader()
  local version, build = GetBuildInfo()
  return table.concat({
    "local _, Graphit = ...",
    "",
    "-- ===================================================================",
    "-- AUTO-GENERATED by DumpSettings.lua via /graphitdumpall.",
    ("-- WoW %s build %s - %s."):format(version, build, date("%Y-%m-%d")),
    "-- Do not edit by hand; re-run the dump after each client patch.",
    "--",
    "-- Layout: [secondaryCvar] = { [tertiaryCvar] = { min, max, [level]=value, ... } }",
    "-- Values/min/max are OBSERVED, not engine limits (CVars accept any value).",
    "-- For graphicsQuality the tertiaries are the secondary CVars and the",
    "-- values are their target levels (preset -> secondary).",
    "-- ===================================================================",
    "Graphit.layer3 = {",
  }, "\n")
end

-- Sweep every secondary in SECONDARY_SETTINGS one after another, appending each
-- result so the whole window becomes one complete, paste-ready file.
local function RunAll()
  if sweepRunning then
    Report("ff8800", "a sweep is already running.")
    return
  end
  batchMode = true
  ClearOutput()
  AppendOutput(FileHeader())

  local function Finish()
    AppendOutput("}")
    batchMode = false
    Report("66ff66", "all sweeps complete; copy the whole window.")
  end

  local index = 0
  local function RunNext()
    index = index + 1
    local entry = SECONDARY_SETTINGS[index]
    if entry then
      RunSweep(entry.cvar, entry.maxLevel, RunNext)
    else
      -- All secondaries done; finish with the preset, then close.
      RunQualityMatrix(Finish)
    end
  end
  RunNext()
end


-- ---------------------------------------------------------------------
-- Slash commands.
-- ---------------------------------------------------------------------
SLASH_GRAPHITDUMP1 = "/graphitdump"
SlashCmdList["GRAPHITDUMP"] = function(msg)
  local secondary, maxArg = msg:match("^%s*(%S+)%s*(%S*)%s*$")
  if not secondary or secondary == "" then
    Report("66ccff", "usage: /graphitdump <secondaryCvar> [maxLevel]")
    print("  e.g. /graphitdump graphicsViewDistance 9")
    print("  /graphitdumpall          sweep every secondary CVar -> Settings_Dump.lua")
    return
  end
  ClearOutput()
  if secondary == PRESET_CVAR then
    RunQualityMatrix()
    return
  end
  local maxLevel = tonumber(maxArg) or MaxLevelFor(secondary)
  RunSweep(secondary, maxLevel)
end

SLASH_GRAPHITDUMPALL1 = "/graphitdumpall"
SlashCmdList["GRAPHITDUMPALL"] = function()
  RunAll()
end

-- Dev convenience: uncomment to auto-open the window on load (this file loads last).
local startUpFrame = CreateFrame("Frame")
startUpFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
startUpFrame:SetScript("OnEvent", function()
  Graphit.ToggleMainFrame()
end)
