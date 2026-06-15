local _, Graphit = ...

-- =====================================================================
-- Graphit settings extraction tool.
--
-- This is a developer/maintenance tool, but we ship it with the addon anyway:
-- the footprint is tiny (it lazily builds its window and registers a few slash
-- commands), and excluding one file from a release would mean keeping a
-- .pkgmeta ignore and the TOC in sync, which is not worth it.
--
-- It builds GraphicsSettings_extracted.lua. For each Blizzard "meta" graphics
-- setting (Layer 2, e.g. graphicsViewDistance) it discovers which raw engine
-- CVars (Layer 3, e.g. farclip) that meta drives, and the value each takes at
-- every level. The client computes this mapping in C; it is not in
-- wow-ui-source. So we sweep the meta CVar through its levels and diff the full
-- CVar table at each step, one meta at a time, so a changed raw CVar is
-- unambiguously a child of that meta.
--
-- The master setting graphicsQuality (Layer 1) does NOT cascade via SetCVar
-- (Blizzard maps it in Lua), so for it we query the C function
-- GetGraphicsCVarValueForQualityLevel directly. See RunQualityMatrix.
--
-- Commands:
--   /graphitdump <metaCVar> [maxLevel]   sweep one setting -> window
--   /graphitdumpall                      sweep every setting -> a complete,
--                                        paste-ready GraphicsSettings_extracted.lua
--   /graphitcontroltypes                 from the loaded extracted data, emit a
--                                        GraphicsSettings_controlTypes.lua skeleton
--                                        (heuristic suggestions + TODOs)
--
-- =====================================================================
-- PATCH-DAY MAINTENANCE  (after a client patch touches graphics options)
-- =====================================================================
-- Regenerating the data is a multi-step job: reconcile this tool with the
-- Blizzard Lua source, dump the values, then regenerate the control types.
--
-- (1) SOURCE INVESTIGATION  (in the wow-ui-source repo)
--
--   File: Blizzard_Settings_Shared/Mainline/GraphicsOverrides.lua
--     CreateAdvancedSettingsTable() lists every Layer-2 meta CVar
--     (graphicsQuality, graphicsShadowQuality, ... graphicsGroundClutter)
--     in the order Blizzard displays them.
--       -> Reconcile with META_SETTINGS below: add / remove / rename /
--          reorder to match. Note conditional entries (e.g. graphicsSpellDensity
--          is gated by C_VideoOptions.IsSpellVisualDensitySystemSupported()).
--
--   File: Blizzard_SettingsDefinitions_Shared/Graphics.lua
--     - Option-builder functions (GetShadowQualityOptions,
--       GetLiquidDetailOptions, ...) add one entry per selectable value; the
--       highest value is that meta's max level. The three slider metas
--       (graphicsViewDistance / EnvironmentDetail / GroundClutter) use the
--       0-9 slider (search `minValue, maxValue, step = 0, 9, 1`).
--       -> Update the maxLevel in META_SETTINGS below for any meta whose
--          value count changed.
--     - SettingsAdvancedQualityControlsMixin:Init and the OnGCChanged path
--       confirm the master still cascades through
--       GetGraphicsCVarValueForQualityLevel(cvar, level, raid). If Blizzard
--       changes that mechanism, update RunQualityMatrix.
--
--   (The hand-authored descriptor GraphicsSettings.lua -- full settings
--    list, localized-string KEYS, control types, option enums, gates -- is
--    also derived from Graphics.lua Register(). Review it the same patch,
--    but that is a separate file from this tool.)
--
-- (2) DUMP THE VALUES
--
--   /reload, then /graphitdumpall. Each meta flickers through its levels
--   (~30-40s total) and restores its original value. If a meta reports
--   "no child CVars changed", the SetCVar cascade no longer works for it --
--   investigate in source before trusting the output. Select All -> copy ->
--   replace the ENTIRE contents of GraphicsSettings_extracted.lua. `git diff`
--   it: the build stamp always changes; added / removed child CVars and
--   retuned values are the real patch changes.
--
-- (3) REGENERATE THE CONTROL TYPES
--
--   /reload (so the new extracted data loads), then /graphitcontroltypes. It
--   reads the loaded data and emits a GraphicsSettings_controlTypes.lua
--   skeleton: a control type per child, pre-filled by heuristic, with TODO
--   comments where you must decide. Carry your previous decisions over,
--   resolve the TODOs, and reconcile GraphicsSettings.lua with any new parent
--   settings.
-- =====================================================================


-- The Layer-1 master setting (the overall "Graphics Quality" 0-9 slider).
-- Handled on its own path: it does NOT cascade via SetCVar, so it is not
-- swept like the metas below; RunQualityMatrix queries it through
-- GetGraphicsCVarValueForQualityLevel instead.
local MASTER_CVAR = "graphicsQuality"
local MASTER_MAX_LEVEL = 9

-- =====================================================================
-- THE patch-day table. Every Layer-2 meta CVar (each swept via SetCVar),
-- in Blizzard's display order, with its max level (0-based, inclusive).
-- Reconcile with the Blizzard source after a client patch (see header).
-- This is the single source of truth; the code iterates it directly.
-- =====================================================================
local META_SETTINGS = {
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

-- Scope note: only MULTI-child Layer-2 settings produce generated data. The
-- other Blizzard graphics settings -- the display / advanced / compat blocks
-- (vsync, textureFilteringMode, shadowrt, ResampleQuality, vrsValar,
-- LowLatencyMode, antialiasing, gamma, render scale, FPS caps, ...) -- were
-- swept once and found to be direct single-CVar controls (no cascade), so
-- they live in the descriptor, not here; no need to re-sweep them each patch.
-- Single-child metas are likewise omitted by the dump (see BuildResult): a
-- lone child is a 1:1 alias with nothing to expand.

-- Max level for a meta CVar by name, for the single-CVar /graphitdump
-- command (unknown CVars fall back to 9). /graphitdumpall does not need
-- this -- it reads each entry's maxLevel straight from META_SETTINGS.
local function MaxLevelFor(cvar)
  for _, entry in ipairs(META_SETTINGS) do
    if entry.cvar == cvar then return entry.maxLevel end
  end
  return 9
end




-- ---------------------------------------------------------------------
-- Tunables
-- ---------------------------------------------------------------------
-- Seconds to wait after writing a meta CVar before snapshotting, so the
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

  outerFrame = CreateFrame("Frame", "GraphitExtractSettingsFrame", UIParent, "TooltipBackdropTemplate")
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
-- Output helpers shared by the single-CVar and master dumps.
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
local function BuildResult(meta, maxLevel, names, snapshots)
  -- A CVar is a child of `meta` if its value was not constant across the
  -- whole sweep.
  local children = {}
  for _, name in ipairs(names) do
    if name ~= meta then
      local base = snapshots[0][name]
      for level = 1, maxLevel do
        if snapshots[level][name] ~= base then
          children[#children + 1] = name
          break
        end
      end
    end
  end
  table.sort(children)

  local lines = {}
  local function add(s) lines[#lines + 1] = s end

  if not batchMode then
    add(StandaloneHeader(meta, maxLevel))
  end
  if #children == 0 then
    add("-- WARNING: no child CVars changed during the sweep.")
    add("-- Setting this meta CVar via SetCVar may not cascade immediately")
    add("-- (might need an apply/restart); another trigger may be required.")
    AppendOutput(table.concat(lines, "\n"))
    Report("ff8800", "no children changed for %s - see window.", meta)
    return
  end

  if #children == 1 then
    -- A lone child means the meta is a 1:1 alias of that one raw CVar, so
    -- there is nothing to expand; the descriptor exposes the meta directly.
    add(("-- %s: single child (%s); direct control, not expanded."):format(meta, children[1]))
    AppendOutput(table.concat(lines, "\n"))
    Report("66ff66", "%s -> 1 child (%s), omitted as a direct control.", meta, children[1])
    return
  end

  add(("-- %s: %d child CVar(s): %s"):format(meta, #children, table.concat(children, ", ")))
  if not batchMode then
    add("-- min/max = lowest/highest value OBSERVED; not engine limits (widen by hand).")
  end
  add(("[%q] = {"):format(meta))
  for _, child in ipairs(children) do
    add(FormatEntry(child, maxLevel, function(level) return snapshots[level][child] or "" end))
  end
  add("},")

  AppendOutput(table.concat(lines, "\n"))
  Report("66ff66", "%s -> %d child CVar(s).", meta, #children)
end


-- ---------------------------------------------------------------------
-- The sweep itself: step the meta CVar 0..maxLevel, snapshotting all
-- CVars after a short settle delay at each level, then restore.
-- ---------------------------------------------------------------------
local sweepRunning = false

local function RunSweep(meta, maxLevel, onComplete)
  if sweepRunning then
    Report("ff8800", "a sweep is already running.")
    return
  end
  if not GetAllCommands then
    Report("ff4040", "no CVar enumeration API on this client (ConsoleGetAllCommands / C_Console.GetAllCommands).")
    return
  end
  if GetCVar(meta) == nil then
    Report("ff4040", "unknown CVar '%s', skipped.", meta)
    if onComplete then onComplete() end
    return
  end

  sweepRunning = true
  local names = GetAllCVarNames()
  local original = GetCVar(meta)
  local snapshots = {}

  Report("66ccff", "sweeping %s (0-%d) over %d CVars...", meta, maxLevel, #names)

  local level = 0
  local function StepIn()
    SetCVar(meta, tostring(level))
    -- Let the engine cascade the meta change to its raw CVars before we read.
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
        SetCVar(meta, original)  -- restore (re-cascades children back)
        sweepRunning = false
        BuildResult(meta, maxLevel, names, snapshots)
        if onComplete then onComplete() end
      end
    end)
  end
  StepIn()
end


-- graphicsQuality (the Layer 1 master) does NOT cascade to its meta CVars
-- via SetCVar; Blizzard's UI maps it in Lua through
-- GetGraphicsCVarValueForQualityLevel. So for the master we query that
-- function directly: master level -> each meta CVar's level (Layer 1->2).
local function RunQualityMatrix(onComplete)
  local fn = _G.GetGraphicsCVarValueForQualityLevel
  if not fn then
    AppendOutput(("-- %s: GetGraphicsCVarValueForQualityLevel unavailable on this client."):format(MASTER_CVAR))
    if onComplete then onComplete() end
    return
  end

  local maxLevel = MASTER_MAX_LEVEL
  local lines = {}
  local function add(s) lines[#lines + 1] = s end

  if not batchMode then
    add(StandaloneHeader(MASTER_CVAR, maxLevel))
  end
  add(("-- %s: master -> meta CVar level (Layer 1->2)"):format(MASTER_CVAR))
  add(("[%q] = {"):format(MASTER_CVAR))
  for _, entry in ipairs(META_SETTINGS) do
    local meta = entry.cvar
    add(FormatEntry(meta, maxLevel, function(level) return tostring(fn(meta, level, false)) end))
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
    "-- AUTO-GENERATED by ExtractSettings.lua via /graphitdumpall.",
    ("-- WoW %s build %s - %s."):format(version, build, date("%Y-%m-%d")),
    "-- Do not edit by hand; re-run the dump after each client patch.",
    "--",
    "-- Layout: [metaCVar] = { [childCVar] = { min, max, [level]=value, ... } }",
    "-- Values/min/max are OBSERVED, not engine limits (CVars accept any value).",
    "-- For graphicsQuality the children are the Layer-2 meta CVars and the",
    "-- values are their target levels (Layer 1->2).",
    "-- ===================================================================",
    "Graphit.generatedGraphicsData = {",
  }, "\n")
end

-- Sweep every meta in META_SETTINGS one after another, appending each
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
    local entry = META_SETTINGS[index]
    if entry then
      RunSweep(entry.cvar, entry.maxLevel, RunNext)
    else
      -- All Layer-2 metas done; finish with the Layer-1 master, then close.
      RunQualityMatrix(Finish)
    end
  end
  RunNext()
end


-- ---------------------------------------------------------------------
-- Control-types skeleton (/graphitcontroltypes): suggest a control type
-- per Layer-3 child from the extracted values, for the human to finalize.
-- ---------------------------------------------------------------------

-- Distinct per-level sample values of a child entry, sorted ascending.
local function DistinctValues(child)
  local seen, list = {}, {}
  for key, value in pairs(child) do
    if type(key) == "number" and not seen[value] then
      seen[value] = true
      list[#list + 1] = value
    end
  end
  table.sort(list, function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end)
  return list
end

-- Suggest a control type for a child from its observed values. Returns the
-- type, a short note for the comment, and a TODO string when the call is a
-- judgment the human must confirm (nil when confident).
local function SuggestType(child)
  local vals = DistinctValues(child)
  local count = #vals
  local lo, hi = tonumber(child.min), tonumber(child.max)
  local range = (lo and hi) and (hi - lo) or 0

  if count >= 4 and range > count then
    return "slider", ("%d values, %s..%s"):format(count, child.min, child.max), nil
  end

  local listed = table.concat(vals, "/")
  if count == 2 and vals[1] == "0" and vals[2] == "1" then
    return "dropdown", nil, "0/1 -- checkbox if truly binary, else dropdown"
  elseif count >= 4 then
    return "dropdown", nil, ("dense set %s -- dropdown or stepped slider"):format(listed)
  else
    return "dropdown", nil, ("%s -- confirm dropdown (or slider if continuous)"):format(listed)
  end
end

-- The namespace header that opens GraphicsSettings_controlTypes.lua.
local function ControlTypesHeader()
  return table.concat({
    "local _, Graphit = ...",
    "",
    "-- ===================================================================",
    "-- AUTO-GENERATED skeleton by ExtractSettings.lua via /graphitcontroltypes.",
    "-- Pre-filled with heuristic suggestions -- resolve every TODO by hand.",
    "-- type = \"slider\" | \"dropdown\" | \"checkbox\". Ranges/values come from",
    "-- GraphicsSettings_extracted.lua; to override, replace the string with a",
    "-- table -- a slider's range/step or a dropdown's value list:",
    "--   { type = \"slider\",   min = .., max = .., step = .. }",
    "--   { type = \"dropdown\", values = { 0, 1, 2 } }",
    "-- Re-generate after a dump changes child CVars, then re-apply decisions.",
    "-- ===================================================================",
    "Graphit.controlTypes = {",
  }, "\n")
end

local function RunControlTypes()
  local data = Graphit.generatedGraphicsData
  if not data then
    Report("ff4040", "GraphicsSettings_extracted.lua not loaded -- /graphitdumpall, paste, /reload first.")
    return
  end

  local lines = { ControlTypesHeader() }
  local function add(s) lines[#lines + 1] = s end

  for _, entry in ipairs(META_SETTINGS) do
    local children = data[entry.cvar]
    if children then  -- nil for single-child / omitted metas
      add("")
      add("  -- " .. entry.cvar)
      local names = {}
      for cvar in pairs(children) do names[#names + 1] = cvar end
      table.sort(names)
      for _, cvar in ipairs(names) do
        local typ, note, todo = SuggestType(children[cvar])
        local comment = todo and ("-- TODO: " .. todo) or ("-- " .. note)
        add(("  [%q] = %q,  %s"):format(cvar, typ, comment))
      end
    end
  end
  add("")
  add("}")

  ClearOutput()
  AppendOutput(table.concat(lines, "\n"))
  Report("66ff66", "control-types skeleton generated; resolve the TODOs, then paste.")
end


-- ---------------------------------------------------------------------
-- Slash commands.
-- ---------------------------------------------------------------------
SLASH_GRAPHITDUMP1 = "/graphitdump"
SlashCmdList["GRAPHITDUMP"] = function(msg)
  local meta, maxArg = msg:match("^%s*(%S+)%s*(%S*)%s*$")
  if not meta or meta == "" then
    Report("66ccff", "usage: /graphitdump <metaCVar> [maxLevel]")
    print("  e.g. /graphitdump graphicsViewDistance 9")
    print("  /graphitdumpall          sweep every meta CVar -> extracted data")
    print("  /graphitcontroltypes     control-types skeleton from extracted data")
    return
  end
  ClearOutput()
  if meta == MASTER_CVAR then
    RunQualityMatrix()
    return
  end
  local maxLevel = tonumber(maxArg) or MaxLevelFor(meta)
  RunSweep(meta, maxLevel)
end

SLASH_GRAPHITDUMPALL1 = "/graphitdumpall"
SlashCmdList["GRAPHITDUMPALL"] = function()
  RunAll()
end

SLASH_GRAPHITCONTROLTYPES1 = "/graphitcontroltypes"
SlashCmdList["GRAPHITCONTROLTYPES"] = function()
  RunControlTypes()
end
