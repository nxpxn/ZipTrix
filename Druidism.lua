local addonName, ns = ...

----------------------------------------------------------------------
-- GLOBALS TO LOCALS FOR PERFORMANCE
----------------------------------------------------------------------
local CreateFrame = CreateFrame
local GetTime = GetTime
local UnitPower = UnitPower
local UnitArmor = UnitArmor
local UnitLevel = UnitLevel
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local GetShapeshiftForm = GetShapeshiftForm
local IsPlayerSpell = IsPlayerSpell
local BreakUpLargeNumbers = BreakUpLargeNumbers
local IsShiftKeyDown = IsShiftKeyDown
local pcall = pcall
local math_abs = math.abs
local string_format = string.format
local table_insert = table.insert
local table_remove = table.remove
local pairs = pairs
local ipairs = ipairs
local select = select
local UIParent = UIParent
local C_PaperDollInfo = C_PaperDollInfo
local issecretvalue = issecretvalue

----------------------------------------------------------------------
-- 1. DATABASE & DEFAULTS
----------------------------------------------------------------------
local defaults = {
    -- Guardian
    guardianTrackerEnabled = true,
    guardianTrackerLocked = false,
    guardianTrackerWidth = 200,
    guardianTrackerHeight = 30,
    guardianTrackerColor = {0, 0, 0, 0.7},
    guardianTickColor = {1, 1, 1, 1},
    guardianFont = "SFAtarianSystem",
    guardianFontSize = 16,
}

local function InitDatabase()
    ZipTrixDB = ZipTrixDB or {}
    ZipTrixDB.Druid = ZipTrixDB.Druid or {}
    for k, v in pairs(defaults) do
        if ZipTrixDB.Druid[k] == nil then ZipTrixDB.Druid[k] = v end
    end
end

----------------------------------------------------------------------
-- 2. GUARDIAN MODULE (Ironfur Tracker)
----------------------------------------------------------------------
local Guardian = {}
-- 12.0 API Guideline: Remove global string names in CreateFrame
Guardian.frame = CreateFrame("Frame", nil, UIParent)
Guardian.activeTicks = {}
Guardian.IRONFUR_ID = 192081
Guardian.URSOCS_ENDURANCE_ID = 393611
Guardian.SPEC_ID = 104
Guardian.currentDuration = 7
Guardian.updateTimer = 0

function Guardian:Init()
    local f = self.frame
    f:SetPoint("CENTER", 0, -200)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", function(self)
        if IsShiftKeyDown() and ZipTrixDB and ZipTrixDB.Druid and not ZipTrixDB.Druid.guardianTrackerLocked then self:StartMoving() end
    end)
    f:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)

    if not f.visualBG then
        f.visualBG = f:CreateTexture(nil, "BACKGROUND", nil, 1)
        f.visualBG:SetAllPoints(f)
    end

    -- Text Elements
    f.rageText = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.rageText:SetPoint("LEFT", 8, 0)
    f.rageText:SetTextColor(0.9, 0.45, 0.1) -- Guardian Druid Orange (Flattened)

    f.armorText = f:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    f.armorText:SetPoint("RIGHT", -8, 0)

    f:SetScript("OnUpdate", function(_, elapsed) self:OnUpdate(elapsed) end)
    f:SetScript("OnEvent", function(_, event, ...) self:OnEvent(event, ...) end)
    
    self:ApplySettings()
end

function Guardian:ApplySettings()
    if not ZipTrixDB or not ZipTrixDB.Druid then return end
    local db = ZipTrixDB.Druid
    local f = self.frame

    f:SetSize(db.guardianTrackerWidth, db.guardianTrackerHeight)
    f:EnableMouse(not db.guardianTrackerLocked)
    
    local c = db.guardianTrackerColor
    f.visualBG:SetColorTexture(1, 1, 1, 1)
    f.visualBG:SetVertexColor(c[1], c[2], c[3], c[4])

    -- Apply Font
    local fontPath = "Interface\\AddOns\\ZipTrix\\assets\\SFAtarianSystem.ttf"
    if db.guardianFont == "Expressway" then fontPath = "Interface\\AddOns\\ZipTrix\\assets\\Expressway.ttf"
    elseif db.guardianFont == "Friz Quadrata TT" then fontPath = "Fonts\\FRIZQT__.TTF"
    elseif db.guardianFont == "Arial Narrow" then fontPath = "Fonts\\ARIALN.TTF" 
    end
    
    -- Fallback if asset missing, though Ziptrix should have it
    local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
    if LSM then fontPath = LSM:Fetch("font", db.guardianFont) or fontPath end

    f.rageText:SetFont(fontPath, db.guardianFontSize, "OUTLINE")
    f.armorText:SetFont(fontPath, db.guardianFontSize, "OUTLINE")

    if db.guardianTrackerEnabled then
        f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        f:RegisterEvent("PLAYER_TALENT_UPDATE")
        f:RegisterEvent("TRAIT_CONFIG_UPDATED")
        f:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
        self:UpdateVisibility()
    else
        f:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
        f:UnregisterEvent("PLAYER_TALENT_UPDATE")
        f:UnregisterEvent("TRAIT_CONFIG_UPDATED")
        f:UnregisterEvent("UPDATE_SHAPESHIFT_FORM")
        f:Hide()
    end
end

function Guardian:UpdateVisibility()
    if not ZipTrixDB or not ZipTrixDB.Druid then return end
    local currentSpec = GetSpecialization()
    local specID = currentSpec and GetSpecializationInfo(currentSpec)
    local formIndex = GetShapeshiftForm()
    local db = ZipTrixDB.Druid
    
    if db.guardianTrackerEnabled and specID == self.SPEC_ID and formIndex == 1 then
        self.frame:Show()
    else
        self.frame:Hide()
        -- Clear ticks
        for i = #self.activeTicks, 1, -1 do
            self.activeTicks[i]:Hide()
            table_remove(self.activeTicks, i)
        end
    end
end

function Guardian:CreateTick()
    local db = ZipTrixDB.Druid
    local t = CreateFrame("Frame", nil, self.frame)
    t:SetSize(3, db.guardianTrackerHeight)
    t.tex = t:CreateTexture(nil, "OVERLAY")
    t.tex:SetAllPoints()
    local c = db.guardianTickColor
    t.tex:SetColorTexture(c[1], c[2], c[3], c[4])
    t.endTime = GetTime() + self.currentDuration
    table_insert(self.activeTicks, t)
end

function Guardian:OnUpdate(elapsed)
    if not self.frame:IsShown() then return end
    local db = ZipTrixDB.Druid
    local now = GetTime()

    -- Process smooth tick movement every frame
    for i = #self.activeTicks, 1, -1 do
        local tick = self.activeTicks[i]
        local remaining = tick.endTime - now
        if remaining <= 0 then 
            tick:Hide() 
            table_remove(self.activeTicks, i)
        else
            tick:SetHeight(db.guardianTrackerHeight)
            local progress = remaining / self.currentDuration
            tick:SetPoint("LEFT", self.frame, "LEFT", progress * db.guardianTrackerWidth, 0)
            tick:Show()
        end
    end

    -- Throttle text updates for performance
    self.updateTimer = self.updateTimer + elapsed
    if self.updateTimer < 0.1 then return end
    self.updateTimer = 0

    -- Update Text
    local rage = UnitPower("player", 1) -- Enum.PowerType.Rage = 1
    if issecretvalue and issecretvalue(rage) then
        self.frame.rageText:SetText("?")
    else
        self.frame.rageText:SetText(rage)
    end

    local baseArmor, effectiveArmor = UnitArmor("player")
    local armorVal = effectiveArmor or baseArmor or 0
    local reduction = 0
    local isSecret = issecretvalue and issecretvalue(armorVal)
    local isValidNumber = not isSecret and pcall(math_abs, armorVal)

    if isValidNumber and C_PaperDollInfo and C_PaperDollInfo.GetArmorEffectiveness then
        -- pcall safely catches restricted execution errors without crashing the addon
        local ok, effectiveness = pcall(C_PaperDollInfo.GetArmorEffectiveness, armorVal, UnitLevel("player") or 1)
        if ok then
            reduction = (effectiveness or 0) * 100
        end
    end

    -- Colors: Druid Orange (Flattened) vs Flat White
    local cDruid = "|cffE6731A"
    local cWhite = "|cffD9D9D9"
    if isValidNumber then
        self.frame.armorText:SetText(string_format("%s%s %s(%s%.1f%%%s)|r", cDruid, BreakUpLargeNumbers(armorVal), cDruid, cWhite, reduction, cDruid))
    else
        -- Fallback display when armor is restricted
        self.frame.armorText:SetText(string_format("%s%s %s(%s--%%%s)|r", cDruid, "???", cDruid, cWhite, cDruid))
    end
end

function Guardian:OnEvent(event, arg1, ...)
    if event == "PLAYER_TALENT_UPDATE" or event == "TRAIT_CONFIG_UPDATED" or event == "UPDATE_SHAPESHIFT_FORM" then
        self:UpdateVisibility()
        self.currentDuration = IsPlayerSpell(self.URSOCS_ENDURANCE_ID) and 9 or 7
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" and arg1 == "player" then
        if select(2, ...) == self.IRONFUR_ID then self:CreateTick() end
    end
end

----------------------------------------------------------------------
-- 3. OPTIONS RENDERER
----------------------------------------------------------------------
function ns.RenderDruidOptions(parent)
    if not parent then return end

    -- Container for dynamic spec options
    local container = CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", 0, -160)
    container:SetPoint("BOTTOMRIGHT", 0, 0)

    local function RefreshOptions()
        -- Clear existing children in container
        for _, child in ipairs({container:GetChildren()}) do
            child:Hide()
            child:SetParent(nil)
        end

        local specIndex = GetSpecialization()
        local specID = specIndex and GetSpecializationInfo(specIndex)
        local yOffset = 0

        -- GUARDIAN (104)
        if specID == 104 then
            local header = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            header:SetPoint("TOPLEFT", 10, yOffset)
            header:SetText("Guardian Counters")
            header:SetTextColor(1, 1, 1)
            yOffset = yOffset - 30

            local cbEnable = ns.CreateToggleSwitch(container, "guardianTrackerEnabled", "Enable Tracker", 20, yOffset, "Druid")
            cbEnable:HookScript("OnClick", function() Guardian:ApplySettings() end)
            
            local cbLock = ns.CreateToggleSwitch(container, "guardianTrackerLocked", "Lock Position", 200, yOffset, "Druid")
            cbLock:HookScript("OnClick", function() Guardian:ApplySettings() end)
            
            yOffset = yOffset - 45

            ns.CreateSliderWithEditBox(container, "guardianTrackerWidth", "Width", 100, 400, 20, yOffset, "Druid")
            ns.CreateSliderWithEditBox(container, "guardianTrackerHeight", "Height", 10, 50, 200, yOffset, "Druid")
            
            yOffset = yOffset - 45
            
            ns.CreateSliderWithEditBox(container, "guardianFontSize", "Font Size", 8, 32, 20, yOffset, "Druid")
            
            local fontBtn = ns.CreateThemedButton(container, "Font: " .. (ZipTrixDB.Druid.guardianFont or "SFAtarianSystem"), 160, 20)
            fontBtn:SetPoint("TOPLEFT", 200, yOffset)
            fontBtn:SetScript("OnClick", function(self)
                local fonts = {"SFAtarianSystem", "Expressway", "Friz Quadrata TT", "Arial Narrow"}
                local current = ZipTrixDB.Druid.guardianFont
                local idx = 1
                for i, f in ipairs(fonts) do if f == current then idx = i break end end
                local nextFont = fonts[(idx % #fonts) + 1]
                ZipTrixDB.Druid.guardianFont = nextFont
                self:SetText("Font: " .. nextFont)
                Guardian:ApplySettings()
            end)

            -- Hook sliders to apply settings immediately
            if _G["ZipTrixSlider_guardianTrackerWidth"] then _G["ZipTrixSlider_guardianTrackerWidth"]:HookScript("OnValueChanged", function() Guardian:ApplySettings() end) end
            if _G["ZipTrixSlider_guardianTrackerHeight"] then _G["ZipTrixSlider_guardianTrackerHeight"]:HookScript("OnValueChanged", function() Guardian:ApplySettings() end) end
            if _G["ZipTrixSlider_guardianFontSize"] then _G["ZipTrixSlider_guardianFontSize"]:HookScript("OnValueChanged", function() Guardian:ApplySettings() end) end

        -- FERAL (103)
        elseif specID == 103 then
            -- Placeholder for Feral
        -- BALANCE (102)
        elseif specID == 102 then
            -- Placeholder for Balance
        -- RESTORATION (105)
        elseif specID == 105 then
            -- Placeholder for Restoration
        end

        -- MACROS (All Specs)
        -- Placeholder for future macros
    end

    container:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    container:SetScript("OnEvent", RefreshOptions)
    container:SetScript("OnShow", RefreshOptions)
    RefreshOptions()
end

----------------------------------------------------------------------
-- 4. INITIALIZATION
----------------------------------------------------------------------
local eventFrame = CreateFrame("Frame", nil, UIParent)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == addonName then
        InitDatabase()
        Guardian:Init()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        Guardian:UpdateVisibility()
    end
end)
