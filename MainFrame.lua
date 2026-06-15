local _, Graphit = ...

-- =====================================================================
-- Graphit main window.
--
-- A flat PortraitFrame: movable by a title-bar strip, resizable by a
-- bottom-right grip, clamped to the screen, with live FPS in the portrait
-- circle. The body is a scrolling list of Blizzard's graphics settings, built
-- from three data sources joined by CVar name:
--   * GraphicsSettings.lua              the ordered, user-facing settings and
--                                       their parent controls (Layers 1 and 2).
--   * GraphicsSettings_extracted.lua    for each multi-child meta, the raw
--                                       child CVars and their value at every
--                                       quality level (Layer 3).
--   * GraphicsSettings_controlTypes.lua each child's control type.
-- A setting is expandable (gets a "+" expander that reveals its children)
-- exactly when it has an entry in the extracted data.
--
-- Every control goes through a small {get, set} binding so sliders and
-- dropdowns share one implementation. A plain setting binds to its own CVar;
-- an expandable parent binds instead to a computed quality level (row.level).
--
-- A parent and its children stay in sync both ways:
--   * Down: driving a parent writes its meta CVar; the engine cascades that to
--     the raw child CVars after a short delay (CASCADE_SETTLE), after which the
--     child controls refresh.
--   * Up: editing a child reconciles the parent (ReconcileParent). The parent's
--     level becomes the highest one the children still satisfy, with a trailing
--     "+" when any child runs past it. Editing a child never rewrites the meta
--     CVar -- that would cascade and wipe the customization -- so the parent's
--     shown level is deliberately decoupled from the meta CVar.
--
-- The list background is a nine-slice cut from Blizzard's options.blp so the
-- window reads as a small sibling of the in-game Settings panel. Toggle with
-- /graphit.
-- =====================================================================

-- ===== Window frame =====

local FRAME_WIDTH,  FRAME_HEIGHT = 300, 520
-- Both minimums are floored by the inner-frame corner tiles, which must not
-- overlap (see SetResizeBounds), so MIN_WIDTH / MIN_HEIGHT take effect only when
-- they exceed that floor.
local MIN_WIDTH           = 350
local MIN_HEIGHT          = 250
local MAX_WIDTH           = 640   -- hard cap on window width
local MAX_HEIGHT_FRACTION = 1     -- cap on height, as a fraction of screen height

-- ===== Row layout =====

local ROW_HEIGHT       = 35
local EXPANDER_WIDTH   = 22    -- reserved left column for the expander button
local LABEL_WIDTH      = 120   -- setting-name column
local SLIDER_VALUE_GAP = 50    -- room reserved right of a slider for its value readout
local VALUE_WIDTH      = 46    -- value readout column on the right (read-only rows)
local CHILD_INDENT     = 35    -- Layer-3 child row left indent
local CHILD_ROW_HEIGHT = 30

-- ===== List frame: scroll box, scrollbar, and the nine-slice border =====

-- Gap between the scroll box and the outer frame, per side (0 = flush). The
-- scrollbar gets its own channel (SCROLLBAR_CHANNEL) added on the right, so LEFT
-- and RIGHT can stay equal for a symmetric look.
local SCROLL_GAP_TOP    = 70   -- clears the title bar + portrait
local SCROLL_GAP_BOTTOM = 32
local SCROLL_GAP_LEFT   = 20
local SCROLL_GAP_RIGHT  = 20

-- Width reserved to the right of the list for the scrollbar's channel.
local SCROLLBAR_CHANNEL = 20

-- Scrollbar within its channel: X nudges the bar's center (0 = centered in the
-- channel); TOP/BOTTOM inset its ends from the scroll box. The bar keeps its
-- template width (8px) and tracks the right edge on resize.
local SCROLLBAR_X      = 3    -- center nudge within the channel
local SCROLLBAR_TOP    = 4    -- bar top, below the scroll box's top
local SCROLLBAR_BOTTOM = 4    -- bar bottom, above the scroll box's bottom

-- Gap between the inner-frame border and the list + scrollbar channel, per side
-- (0 = flush; positive pushes the border out). LEFT and RIGHT can stay equal.
local INNER_GAP_TOP    = 6
local INNER_GAP_BOTTOM = 6
local INNER_GAP_LEFT   = 10
local INNER_GAP_RIGHT  = 10

-- options.blp inner-frame corner size on screen. Also floors the resizable
-- frame's min size so the 9-slice corners never overlap (see SetResizeBounds).
local INNER_CORNER_W = 60
local INNER_CORNER_H = 180

-- Fixed (non-stretching) padding between the outer frame edge and the inner-
-- frame region, per axis. The region is frameSize minus this, so the resizable
-- min size is 2 corners + chrome (see SetResizeBounds). SCROLLBAR_CHANNEL
-- cancels out: the region's right anchor adds it back.
local CHROME_W = SCROLL_GAP_LEFT + SCROLL_GAP_RIGHT - INNER_GAP_LEFT - INNER_GAP_RIGHT
local CHROME_H = SCROLL_GAP_TOP + SCROLL_GAP_BOTTOM - INNER_GAP_TOP - INNER_GAP_BOTTOM

-- ===== Timing =====

local FPS_INTERVAL   = 0.25   -- matches the game's FRAMERATE_FREQUENCY
-- Seconds to wait after changing a parent before refreshing its children: the
-- engine cascades a meta CVar to its raw CVars with a short delay (mirrors
-- ExtractSettings.SETTLE_DELAY).
local CASCADE_SETTLE = 0.2

local GetCVar = C_CVar and C_CVar.GetCVar or _G.GetCVar
local SetCVar = C_CVar and C_CVar.SetCVar or _G.SetCVar

local frame  -- built lazily on first toggle

-- Resolve a global string key to its localized value, falling back to the
-- key itself so a missing/renamed global stays visible instead of blank.
local function L(key)
  return key and (_G[key] or key) or ""
end

-- Every row registers a Settings-style hover highlight here; the frame's
-- OnUpdate shows the one under the cursor (this works while hovering the
-- child controls too, which a plain OnEnter/OnLeave on the row would not).
local hoverRows = {}

local function AddHover(row)
  row.highlight = row:CreateTexture(nil, "ARTWORK")
  row.highlight:SetColorTexture(1, 1, 1, 0.1)  -- same as the Settings HoverBackground
  row.highlight:SetAllPoints(row)
  row.highlight:Hide()
  hoverRows[#hoverRows + 1] = row
end

-- ===== Controls =====

-- A modern Settings-style slider bound to a `binding` {get, set}: get() returns
-- the value to show, set(v) (a number) is called on user input. Dragging or
-- stepping is live, so the cascade is the preview. displayOffset gives
-- Blizzard's 1-10. A parent shows "+" (row.deviates) when its children run past
-- its level.
local function CreateSlider(row, binding, spec)
  local widget = CreateFrame("Frame", nil, row, "MinimalSliderWithSteppersTemplate")
  widget:SetHeight(20)
  widget:SetPoint("LEFT", row.label, "RIGHT", 8, 0)
  widget:SetPoint("RIGHT", row, "RIGHT", -SLIDER_VALUE_GAP, 0)  -- room for RightText

  local steps  = (spec.max - spec.min) / (spec.step or 1)
  local offset = spec.displayOffset or 0
  local formatters = {
    [MinimalSliderWithSteppersMixin.Label.Right] =
      function(value)
        return tostring(math.floor(value + 0.5) + offset) .. (row.deviates and "+" or "")
      end,
  }

  -- Init wires its OnValueChanged after the initial SetValue, so this does
  -- not echo back to the binding.
  widget:Init(tonumber(binding.get()) or spec.min, spec.min, spec.max, steps, formatters)

  local refreshing = false
  widget:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged,
    function(_, value)
      if refreshing then return end  -- a display re-sync, not a user edit
      binding.set(math.floor(value + 0.5))
    end, row)

  -- Re-render from the binding (e.g. after a cascade) without writing it back;
  -- the formatter picks up row.deviates for the "+". SetValue is a no-op when the
  -- value is unchanged (so it would not refresh the "+"), hence the explicit
  -- FormatValue.
  row.Refresh = function()
    refreshing = true
    widget:SetValue(tonumber(binding.get()) or spec.min)
    widget:FormatValue(widget.Slider:GetValue())
    refreshing = false
  end

  row.control = widget
end

-- The Settings panel's dropdown control bound to `binding` {get, set}: a
-- WowStyle2 dropdown flanked by < > stepper buttons. `options` is a list of
-- { value, text }; the steppers move to the prev/next option (disabled at the
-- ends) and picking calls set(value). The button shows whichever option matches
-- get(). A parent shows "+" (row.deviates) when its children run past its level.
local function CreateDropdown(row, binding, options)
  local dd  = CreateFrame("DropdownButton", nil, row, "WowStyle2DropdownTemplate")
  local dec = CreateFrame("Button", nil, row, "WowStyle2IconButtonTemplate")
  local inc = CreateFrame("Button", nil, row, "WowStyle2IconButtonTemplate")

  -- Layout: [<] [ dropdown fills ] [>]
  dec:SetPoint("LEFT", row.label, "RIGHT", 4, 0)
  inc:SetPoint("RIGHT", row, "RIGHT", -6, 0)
  dd:SetPoint("LEFT", dec, "RIGHT", 2, 0)
  dd:SetPoint("RIGHT", inc, "LEFT", -2, 0)

  dec.normalAtlas, dec.disabledAtlas = "common-dropdown-icon-back", "common-dropdown-icon-back-disabled"
  inc.normalAtlas, inc.disabledAtlas = "common-dropdown-icon-next", "common-dropdown-icon-next-disabled"
  dec:OnButtonStateChanged()
  inc:OnButtonStateChanged()

  -- Append "+" to the shown value when a parent's children run past its level
  -- (nil falls back to the default selection text).
  dd:SetSelectionText(function(selections)
    local sel = selections and selections[1]
    if not sel then return nil end
    return MenuUtil.GetElementText(sel) .. (row.deviates and "+" or "")
  end)

  dd:SetupMenu(function(_, rootDescription)
    for _, opt in ipairs(options) do
      rootDescription:CreateRadio(opt.text,
        function() return tostring(binding.get()) == tostring(opt.value) end,
        function() binding.set(opt.value) end)
    end
  end)

  -- Grey out a stepper at the ends of the option list. dd:Increment/Decrement
  -- do NOT fire OnUpdate, so refresh explicitly after a stepper click as well.
  local function UpdateSteppers()
    local previousRadio, nextRadio = dd:CollectSelectionData()
    dec:SetEnabled(previousRadio ~= nil)
    inc:SetEnabled(nextRadio ~= nil)
  end

  dec:SetScript("OnClick", function() dd:Decrement(); UpdateSteppers(); PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) end)
  inc:SetScript("OnClick", function() dd:Increment(); UpdateSteppers(); PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON) end)

  dd:RegisterCallback(DropdownButtonMixin.Event.OnUpdate, UpdateSteppers, dd)

  -- Re-render the shown selection from the binding: re-runs the generator so the
  -- isSelected predicates re-read it (and the selectionFunc re-applies the "+"),
  -- and refreshes the steppers via OnUpdate.
  row.Refresh = function() dd:GenerateMenu() end

  row.control = dd
end

-- Unique per-level sample values of a child entry, sorted ascending (strings).
local function DistinctChildValues(data)
  local seen, list = {}, {}
  for key, value in pairs(data) do
    if type(key) == "number" and not seen[value] then
      seen[value] = true
      list[#list + 1] = value
    end
  end
  table.sort(list, function(a, b) return (tonumber(a) or 0) < (tonumber(b) or 0) end)
  return list
end

-- ===== Parent level reconciliation =====

-- The sorted list of quality levels a meta defines (children share the set).
local function MetaLevels(matrix)
  local set = {}
  for _, data in pairs(matrix) do
    for k in pairs(data) do
      if type(k) == "number" then set[k] = true end
    end
    break
  end
  local levels = {}
  for lvl in pairs(set) do levels[#levels + 1] = lvl end
  table.sort(levels)
  return levels
end

-- From the current child CVars, return the highest level still fully satisfied
-- (every child at least as high-quality as that level needs) and whether they
-- match it exactly. Each child's quality direction is read from its own matrix
-- (some raw CVars fall as quality rises), so the test is "value has reached the
-- level's threshold" either way. The level is the weakest child's reach; any
-- child beyond it makes it inexact -> the parent gets a "+".
local function HighestSatisfiedLevel(meta)
  local matrix = Graphit.generatedGraphicsData[meta]
  local levels = MetaLevels(matrix)
  local loLevel, hiLevel = levels[1], levels[#levels]

  local minSat
  for childCvar, data in pairs(matrix) do
    local lo, hi = tonumber(data[loLevel]), tonumber(data[hiLevel])
    if lo ~= hi then                       -- constant children carry no level info
      local v = tonumber(GetCVar(childCvar))
      local increasing = hi > lo
      local sat = loLevel - 1              -- below the minimum until proven otherwise
      for _, lvl in ipairs(levels) do
        local target = tonumber(data[lvl])
        local reached
        if increasing then reached = v >= target else reached = v <= target end
        if reached then sat = lvl else break end  -- monotonic: stop at the first gap
      end
      if not minSat or sat < minSat then minSat = sat end
    end
  end

  local level = math.max(minSat or hiLevel, loLevel)

  local exact = true
  for childCvar, data in pairs(matrix) do
    local expected = data[level]
    if expected == nil or tonumber(GetCVar(childCvar)) ~= tonumber(expected) then
      exact = false
      break
    end
  end
  return level, exact
end

-- Reconcile a parent's displayed level + "+" from its children. The shown level
-- (row.level) is decoupled from the meta CVar: editing children never rewrites
-- the meta (which would cascade and wipe the customization) -- it only updates
-- what the parent shows. The meta is written solely when the user drives the
-- parent control.
local function ReconcileParent(parentRow)
  if not parentRow.Refresh then return end
  local level, exact = HighestSatisfiedLevel(parentRow.meta)
  parentRow.level    = level
  parentRow.deviates = not exact
  parentRow.Refresh()
end

-- ===== Rows =====

-- Read-only value column for control kinds that have no live widget yet (the
-- checkbox kind, or an unknown kind). It shows the current CVar string.
local function CreateReadOnlyValue(row, cvar)
  row.valueText = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  row.valueText:SetPoint("RIGHT", -4, 0)
  row.valueText:SetWidth(VALUE_WIDTH)
  row.valueText:SetJustifyH("RIGHT")
  row.valueText:SetText(GetCVar(cvar) or "")
  row.Refresh = function() row.valueText:SetText(GetCVar(cvar) or "") end
end

-- A single Layer-3 child row: the raw CVar name and its control, indented under
-- the parent. The control kind comes from controlTypes (a string, or a table
-- that overrides the range or values); the range and values come from the
-- extracted data. Editing a child reconciles the parent, snapping its level or
-- giving it a "+".
local function CreateChildRow(parent, childCvar, meta, parentRow)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(CHILD_ROW_HEIGHT)
  AddHover(row)

  row.label = row:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
  row.label:SetPoint("LEFT", CHILD_INDENT, 0)
  -- Full label width so the indent carries through to the control too (the
  -- control still anchors its right edge to the row, so its right stays put).
  row.label:SetWidth(LABEL_WIDTH)
  row.label:SetJustifyH("LEFT")
  row.label:SetWordWrap(false)
  row.label:SetTextColor(0.75, 0.75, 0.75)
  row.label:SetText(childCvar)

  local ct    = Graphit.controlTypes and Graphit.controlTypes[childCvar]
  local ctype = type(ct) == "table" and ct.type or ct
  local data  = Graphit.generatedGraphicsData[meta][childCvar]

  -- A child binds straight to its raw CVar; editing it reconciles the parent.
  local binding = {
    get = function() return GetCVar(childCvar) end,
    set = function(v)
      SetCVar(childCvar, tostring(v))
      if parentRow then ReconcileParent(parentRow) end
    end,
  }

  if ctype == "slider" then
    local o = type(ct) == "table" and ct or nil
    CreateSlider(row, binding, {
      min  = (o and o.min)  or tonumber(data.min),
      max  = (o and o.max)  or tonumber(data.max),
      step = (o and o.step) or 1,
    })
  elseif ctype == "dropdown" then
    local o = type(ct) == "table" and ct or nil
    local values = (o and o.values) or DistinctChildValues(data)
    local opts = {}
    for _, v in ipairs(values) do opts[#opts + 1] = { value = v, text = tostring(v) } end
    CreateDropdown(row, binding, opts)
  else
    CreateReadOnlyValue(row, childCvar)
  end
  return row
end

-- Lazily build the indented container of child rows for an expandable row.
local function BuildChildren(row)
  if row.childContainer then return end
  local content   = row:GetParent()
  local container = CreateFrame("Frame", nil, content)
  local childData = Graphit.generatedGraphicsData[row.meta]

  local names = {}
  for cvar in pairs(childData) do names[#names + 1] = cvar end
  table.sort(names)

  container.childRows = {}
  local y = 0
  for _, cvar in ipairs(names) do
    local childRow = CreateChildRow(container, cvar, row.meta, row)
    childRow:SetPoint("TOPLEFT", container, "TOPLEFT", 0, y)
    childRow:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    container.childRows[#container.childRows + 1] = childRow
    y = y - CHILD_ROW_HEIGHT
  end
  container:SetHeight(#names * CHILD_ROW_HEIGHT)
  container:Hide()
  row.childContainer = container
end

-- Stack parent rows top-down, inserting any expanded child container, then
-- size the scroll content and refresh the scroll range.
local function Relayout(content)
  local y = -4
  for _, row in ipairs(content.rows) do
    row:ClearAllPoints()
    row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
    row:SetPoint("RIGHT", content, "RIGHT", 0, 0)
    y = y - ROW_HEIGHT

    if row.childContainer then
      if row.expanded then
        row.childContainer:ClearAllPoints()
        row.childContainer:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
        row.childContainer:SetPoint("RIGHT", content, "RIGHT", 0, 0)
        row.childContainer:Show()
        y = y - row.childContainer:GetHeight()
      else
        row.childContainer:Hide()
      end
    end
  end
  content:SetHeight(-y + 4)
  if content.scrollBox and content.scrollBox:GetView() then
    content.scrollBox:FullUpdate()
  end
end

-- Toggle a row's expander and swap its +/- icon.
local function ToggleExpand(row)
  BuildChildren(row)
  row.expanded = not row.expanded
  if row.expanded then
    row.expander:SetNormalAtlas("common-button-dropdown-open")
    row.expander:SetPushedAtlas("common-button-dropdown-openpressed")
  else
    row.expander:SetNormalAtlas("common-button-dropdown-closed")
    row.expander:SetPushedAtlas("common-button-dropdown-closedpressed")
  end
  Relayout(row:GetParent())
end

-- Re-sync every built child control of a parent row to its (now cascaded) CVar.
-- Unbuilt (never-expanded) children need nothing: they Init from the live CVar.
local function RefreshChildren(row)
  local container = row.childContainer
  if not container or not container.childRows then return end
  for _, childRow in ipairs(container.childRows) do
    if childRow.Refresh then childRow.Refresh() end
  end
end

-- One setting row: optional "+" expander, name, then the control (slider or
-- dropdown, live). A parent with children shows a computed level; a plain
-- setting binds to its own CVar. Unknown control kinds fall back to read-only.
local function CreateRow(parent, setting)
  local row = CreateFrame("Frame", nil, parent)
  row:SetHeight(ROW_HEIGHT)

  AddHover(row)

  -- "+" expander for settings that have extracted Layer-3 children.
  if Graphit.generatedGraphicsData and Graphit.generatedGraphicsData[setting.cvar] then
    row.meta = setting.cvar
    row.expanded = false
    local btn = CreateFrame("Button", nil, row)
    btn:SetSize(16, 16)
    btn:SetPoint("LEFT", 2, 0)
    btn:SetNormalAtlas("common-button-dropdown-closed")
    btn:SetPushedAtlas("common-button-dropdown-closedpressed")
    btn:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight")
    btn:SetScript("OnClick", function() ToggleExpand(row) end)
    row.expander = btn
  end

  row.label = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
  row.label:SetPoint("LEFT", EXPANDER_WIDTH, 0)
  row.label:SetWidth(LABEL_WIDTH)
  row.label:SetJustifyH("LEFT")
  row.label:SetWordWrap(false)
  row.label:SetText(L(setting.name))

  -- A parent with children shows a computed level (row.level), decoupled from the
  -- meta CVar; driving it writes the meta (the engine cascades to the children)
  -- and, once that settles, refreshes the children and re-reconciles. A plain
  -- setting just binds to its own CVar.
  local binding
  if row.meta then
    binding = {
      get = function() return row.level end,
      set = function(v)
        row.level = tonumber(v)
        row.deviates = false
        SetCVar(row.meta, tostring(v))
        C_Timer.After(CASCADE_SETTLE, function()
          RefreshChildren(row)
          ReconcileParent(row)
        end)
      end,
    }
  else
    binding = {
      get = function() return GetCVar(setting.cvar) end,
      set = function(v) SetCVar(setting.cvar, tostring(v)) end,
    }
  end

  if setting.control.kind == "slider" then
    CreateSlider(row, binding, setting.control)
  elseif setting.control.kind == "dropdown" then
    local opts = {}
    for _, o in ipairs(setting.control.options) do
      opts[#opts + 1] = { value = o.value, text = L(o.label) }
    end
    CreateDropdown(row, binding, opts)
  else
    CreateReadOnlyValue(row, setting.cvar)
  end

  -- Seed the parent's displayed level and "+" from the current child CVars.
  if row.meta then ReconcileParent(row) end
  return row
end

-- Build all parent rows (stored on content.rows), then lay them out.
local function BuildRows(content)
  content.rows = {}
  for _, setting in ipairs(Graphit.graphicsSettings) do
    if not setting.gate or setting.gate() then
      content.rows[#content.rows + 1] = CreateRow(content, setting)
    end
  end
  Relayout(content)
end

-- ===== Frame =====

-- "%.0f" rounds to the nearest integer; "%d" would truncate and read ~1 low.
local function UpdateFPS(self, fps)
  self.fpsText:SetText(("%.0f"):format(fps))
end

local function BuildFrame()
  local f = CreateFrame("Frame", "GraphitFrame", UIParent, "PortraitFrameFlatTemplate")
  f:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
  f:SetPoint("CENTER")
  f:SetFrameStrata("HIGH")
  f:SetToplevel(true)
  f:EnableMouse(true)
  f:SetClampedToScreen(true)

  f.TitleContainer.TitleText:SetText("Graphit")
  -- Plain Hide(); the template's default OnClick calls the secure
  -- HideUIPanel(), which is blocked in combat.
  f.CloseButton:SetScript("OnClick", function(self) self:GetParent():Hide() end)

  -- Move via a drag strip across the title bar (stops short of the close button).
  f:SetMovable(true)
  local dragBar = CreateFrame("Frame", nil, f)
  dragBar:SetPoint("TOPLEFT", 0, 0)
  dragBar:SetPoint("TOPRIGHT", -28, 0)
  dragBar:SetHeight(28)
  dragBar:EnableMouse(true)
  -- Move on mouse-down (not OnDragStart, which only fires after the cursor
  -- travels a threshold distance) so the drag is immediate.
  dragBar:SetScript("OnMouseDown", function() f:StartMoving() end)
  dragBar:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

  -- Resize via a bottom-right grip.
  f:SetResizable(true)
  -- Floor the min size so the inner-frame 9-slice corners never overlap: the
  -- content region must fit two corners on each axis, plus the fixed chrome
  -- between the frame edge and that region (CHROME_W / CHROME_H).
  -- The max height tracks the current screen, so recompute it on show and when
  -- the resolution / UI scale changes (the bound is otherwise set just once).
  local function ApplyResizeBounds()
    if not f.SetResizeBounds then return end
    local minW = math.max(MIN_WIDTH, 2 * INNER_CORNER_W + CHROME_W)
    local minH = math.max(MIN_HEIGHT, 2 * INNER_CORNER_H + CHROME_H)
    local maxHeight = math.max(UIParent:GetHeight() * MAX_HEIGHT_FRACTION, minH)
    f:SetResizeBounds(minW, minH, MAX_WIDTH, maxHeight)
    return maxHeight
  end

  -- A display/UI-scale change does not retroactively shrink or move an open
  -- frame, so after refreshing the bounds, shrink past the new height cap and
  -- pull any off-screen edge back into view.
  local function RefreshBoundsAndClamp()
    local maxHeight = ApplyResizeBounds()
    if not maxHeight then return end
    if f:GetHeight() > maxHeight then
      f:SetHeight(maxHeight)
    end
    local left, bottom = f:GetRect()
    if left then
      local screenW, screenH = UIParent:GetWidth(), UIParent:GetHeight()
      left   = math.max(0, math.min(left,   screenW - f:GetWidth()))
      bottom = math.max(0, math.min(bottom, screenH - f:GetHeight()))
      f:ClearAllPoints()
      f:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT", left, bottom)
    end
  end

  ApplyResizeBounds()
  f:HookScript("OnShow", ApplyResizeBounds)
  f:RegisterEvent("DISPLAY_SIZE_CHANGED")
  f:RegisterEvent("UI_SCALE_CHANGED")
  f:HookScript("OnEvent", RefreshBoundsAndClamp)
  local grip = CreateFrame("Button", nil, f)
  grip:SetSize(16, 16)
  grip:SetPoint("BOTTOMRIGHT", -4, 4)
  grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
  grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
  grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
  grip:SetScript("OnMouseDown", function() f:StartSizing("BOTTOMRIGHT") end)
  grip:SetScript("OnMouseUp", function() f:StopMovingOrSizing() end)

  -- Live FPS in the portrait circle (dark fill behind a bright number).
  local portrait = f.PortraitContainer.portrait
  portrait:SetColorTexture(0.05, 0.05, 0.05, 0.9)
  -- Parent to PortraitContainer (frameLevel 400) with a high OVERLAY
  -- sublevel so the number draws above the portrait texture.
  f.fpsText = f.PortraitContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge2")
  f.fpsText:SetDrawLayer("OVERLAY", 7)
  f.fpsText:SetJustifyH("CENTER")          -- center on the current string, any digit count
  f.fpsText:SetPoint("CENTER", portrait, "CENTER", 0, -3)
  f.fpsText:SetTextColor(NORMAL_FONT_COLOR:GetRGB())

  -- "FPS:" caption above the number, in a smaller font, also centered.
  f.fpsLabel = f.PortraitContainer:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  f.fpsLabel:SetDrawLayer("OVERLAY", 7)
  f.fpsLabel:SetPoint("BOTTOM", f.fpsText, "TOP", 0, 0)
  f.fpsLabel:SetTextColor(NORMAL_FONT_COLOR:GetRGB())
  f.fpsLabel:SetText("FPS")

  -- Scrolling settings list (modern ScrollBox + scrollbar). PortraitFrameFlat
  -- has no Inset, so anchor to the frame: below the title bar, inside borders.
  local scrollBox = CreateFrame("Frame", nil, f, "WowScrollBox")
  scrollBox:SetPoint("TOPLEFT", SCROLL_GAP_LEFT, -SCROLL_GAP_TOP)
  scrollBox:SetPoint("BOTTOMRIGHT", -(SCROLL_GAP_RIGHT + SCROLLBAR_CHANNEL), SCROLL_GAP_BOTTOM)

  -- Scrollbar centered in its channel, just right of the scroll box. Anchoring
  -- the top/bottom center points fixes the column and keeps the template width.
  local scrollBar = CreateFrame("EventFrame", nil, f, "MinimalScrollBar")
  scrollBar:SetPoint("TOP", scrollBox, "TOPRIGHT", SCROLLBAR_CHANNEL / 2 + SCROLLBAR_X, -SCROLLBAR_TOP)
  scrollBar:SetPoint("BOTTOM", scrollBox, "BOTTOMRIGHT", SCROLLBAR_CHANNEL / 2 + SCROLLBAR_X, SCROLLBAR_BOTTOM)

  -- The Settings inner-content frame, a nine-slice hand-cut from options.blp so
  -- the corners stay crisp and Blizzard's baked-in category divider is excluded.
  -- The nine pieces are TEXTURES on the frame, drawn behind the scroll box's
  -- children so they back the list without ever covering it. Corners are drawn
  -- at their native CW x CH; the edges and center stretch between them.
  --
  -- Heads-up on the pixel rects: SetTexCoord addresses the grid lines between
  -- pixels, not the pixels, so each coordinate is one more than the image
  -- editor's pixel index. Each corner is held to a clean 60x180 (1:3) by
  -- extending its inner edges (toward the center) by 1px, which only laps into
  -- the stretched border and stays invisible.
  local INNER_FILE = "Interface\\OptionsFrame\\Options"
  local TEX        = 1024
  local CW, CH     = INNER_CORNER_W, INNER_CORNER_H
  local PIECE = {
    TL = {1,   150, 61,  330}, TR = {828, 150, 888, 330},  -- corners (60x180)
    BL = {1,   589, 61,  769}, BR = {828, 589, 888, 769},
    T  = {101, 150, 120, 330}, B  = {101, 589, 120, 769},  -- clean border slices
    L  = {1,   330, 61,  589}, R  = {828, 330, 888, 589},  -- (divider-free)
    C  = {401, 401, 420, 420},                             -- solid center
  }

  -- Invisible region the nine-slice fills (frames the scroll box).
  local region = CreateFrame("Frame", nil, f)
  region:SetPoint("TOPLEFT", scrollBox, "TOPLEFT", -INNER_GAP_LEFT, INNER_GAP_TOP)
  -- Right side adds the scrollbar channel back so the border encloses it too.
  region:SetPoint("BOTTOMRIGHT", scrollBox, "BOTTOMRIGHT", SCROLLBAR_CHANNEL + INNER_GAP_RIGHT, -INNER_GAP_BOTTOM)

  local function piece(name)
    local t = f:CreateTexture(nil, "BACKGROUND")
    t:SetTexture(INNER_FILE)
    local r = PIECE[name]
    t:SetTexCoord(r[1] / TEX, r[3] / TEX, r[2] / TEX, r[4] / TEX)
    return t
  end
  local tl, tr, bl, br = piece("TL"), piece("TR"), piece("BL"), piece("BR")
  tl:SetSize(CW, CH); tl:SetPoint("TOPLEFT",     region, "TOPLEFT")
  tr:SetSize(CW, CH); tr:SetPoint("TOPRIGHT",    region, "TOPRIGHT")
  bl:SetSize(CW, CH); bl:SetPoint("BOTTOMLEFT",  region, "BOTTOMLEFT")
  br:SetSize(CW, CH); br:SetPoint("BOTTOMRIGHT", region, "BOTTOMRIGHT")

  local top = piece("T"); top:SetPoint("TOPLEFT", tl, "TOPRIGHT");    top:SetPoint("BOTTOMRIGHT", tr, "BOTTOMLEFT")
  local bot = piece("B"); bot:SetPoint("TOPLEFT", bl, "TOPRIGHT");    bot:SetPoint("BOTTOMRIGHT", br, "BOTTOMLEFT")
  local lft = piece("L"); lft:SetPoint("TOPLEFT", tl, "BOTTOMLEFT");  lft:SetPoint("BOTTOMRIGHT", bl, "TOPRIGHT")
  local rgt = piece("R"); rgt:SetPoint("TOPLEFT", tr, "BOTTOMLEFT");  rgt:SetPoint("BOTTOMRIGHT", br, "TOPRIGHT")
  local cen = piece("C"); cen:SetPoint("TOPLEFT", tl, "BOTTOMRIGHT"); cen:SetPoint("BOTTOMRIGHT", br, "TOPLEFT")

  -- The scroll child. content.scrollable marks it as the ScrollBox's scroll
  -- target; content.scrollBox lets Relayout refresh the scroll range.
  local content = CreateFrame("Frame", nil, scrollBox)
  content.scrollable = true
  content.scrollBox = scrollBox
  BuildRows(content)
  -- Keep the scroll child width matched to the viewport so rows fill it.
  scrollBox:HookScript("OnSizeChanged", function() content:SetWidth(scrollBox:GetWidth()) end)

  ScrollUtil.InitScrollBoxWithScrollBar(scrollBox, scrollBar, CreateScrollBoxLinearView())
  -- Single-child ScrollBox: the "pan extent" (per step / per wheel notch)
  -- defaults to the whole content frame, so a step would jump to min/max.
  -- Make a step one row instead.
  scrollBox:SetPanExtent(ROW_HEIGHT)
  scrollBox:FullUpdate()

  -- OnUpdate (runs only while shown): row hover every frame, plus FPS measured
  -- from real frame deltas over a short window so it tracks the true value within
  -- FPS_INTERVAL (GetFramerate() is engine-smoothed and lags ~2-3s).
  -- Hidden rows (collapsed children) report IsMouseOver() false, so the hover
  -- pass is safe to run over all registered rows.
  local fpsFrames, fpsElapsed = 0, 0
  f:SetScript("OnUpdate", function(self, dt)
    for _, row in ipairs(hoverRows) do
      row.highlight:SetShown(row:IsMouseOver())
    end
    fpsFrames  = fpsFrames + 1
    fpsElapsed = fpsElapsed + dt
    if fpsElapsed >= FPS_INTERVAL then
      UpdateFPS(self, fpsFrames / fpsElapsed)
      fpsFrames, fpsElapsed = 0, 0
    end
  end)
  UpdateFPS(f, GetFramerate())  -- initial value before the first measured window

  f:Hide()  -- start hidden; the first Toggle shows it
  return f
end

local function Toggle()
  if not frame then frame = BuildFrame() end
  frame:SetShown(not frame:IsShown())
end

SLASH_GRAPHIT1 = "/graphit"
SlashCmdList["GRAPHIT"] = Toggle

Graphit.ToggleMainFrame = Toggle
