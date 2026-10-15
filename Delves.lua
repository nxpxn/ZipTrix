local addonName, ns = ...

local f = CreateFrame("Frame")

local totalCuriosities = 10
local curiositiesFound = 0
local inDelve = false

local trackerFrame = nil
local trackerIcon = nil
local trackerText = nil

local function UpdateTrackerText(foundLoot)
    if trackerText then
        local remaining = totalCuriosities - curiositiesFound
        if remaining < 0 then remaining = 0 end
        trackerText:SetText(tostring(remaining))
        
        if foundLoot and trackerFrame and trackerFrame.animGroup then
            trackerFrame.animGroup:Stop()
            trackerFrame.animGroup:Play()
        end
    end
end

local function SetupTrackerFrame()
    if trackerFrame then return end
    
    -- Create a floating frame
    trackerFrame = CreateFrame("Frame", "ZipTrixDelveCuriosityTracker", UIParent)
    trackerFrame:SetSize(44, 44)
    trackerFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -150)
    trackerFrame:SetMovable(true)
    trackerFrame:EnableMouse(true)
    trackerFrame:RegisterForDrag("LeftButton")
    trackerFrame:SetScript("OnDragStart", function(self)
        if IsShiftKeyDown() then
            self:StartMoving()
        end
    end)
    trackerFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
    end)
    
    -- Create Icon
    trackerIcon = trackerFrame:CreateTexture(nil, "BACKGROUND")
    trackerIcon:SetAllPoints()
    trackerIcon:SetTexture("Interface\\Icons\\inv_misc_treasurechest04")
    trackerIcon:SetDesaturated(true)
    trackerIcon:SetVertexColor(0.6, 0.6, 0.6)
    
    local mask = trackerFrame:CreateMaskTexture()
    mask:SetTexture("Interface\\CharacterFrame\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    mask:SetAllPoints(trackerIcon)
    trackerIcon:AddMaskTexture(mask)

    -- Create Text
    trackerText = trackerFrame:CreateFontString(nil, "OVERLAY")
    trackerText:SetFont("Fonts\\FRIZQT__.TTF", 24, "OUTLINE")
    trackerText:SetTextColor(1, 1, 1)
    trackerText:SetPoint("CENTER", trackerFrame, "CENTER", 0, 0)
    trackerText:SetText("10")
    
    -- Animation Group
    trackerFrame.animGroup = trackerText:CreateAnimationGroup()
    
    local grow = trackerFrame.animGroup:CreateAnimation("Scale")
    grow:SetOrder(1)
    grow:SetScale(2, 2)
    grow:SetDuration(0.15)
    grow:SetSmoothing("OUT")
    
    local shrink = trackerFrame.animGroup:CreateAnimation("Scale")
    shrink:SetOrder(2)
    shrink:SetScale(0.5, 0.5)
    shrink:SetDuration(0.3)
    shrink:SetSmoothing("IN")
end

local function ResetTracker()
    curiositiesFound = 0
    totalCuriosities = 10
    if trackerFrame then
        UpdateTrackerText()
        trackerFrame:Show()
    end
end

local function HideTracker()
    if trackerFrame then
        trackerFrame:Hide()
    end
end

local function CheckForDelve()
    local name, instanceType = GetInstanceInfo()
    if instanceType == "scenario" then
        inDelve = true
        SetupTrackerFrame()
        ResetTracker()
    else
        inDelve = false
        HideTracker()
    end
end

f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
f:RegisterEvent("CHAT_MSG_LOOT")
f:RegisterEvent("CHAT_MSG_SYSTEM")
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
f:RegisterEvent("QUEST_LOG_UPDATE")

-- A lot of curiosities use hidden quest tracking or item looting.
-- For a basic heuristic:
local lastLootTime = 0

f:SetScript("OnEvent", function(self, event, ...)
    if not ZipTrixDB or not ZipTrixDB.delvesMislaidCuriositiesTracking then
        HideTracker()
        return
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "ZONE_CHANGED_NEW_AREA" then
        CheckForDelve()
    elseif inDelve then
        -- Delves have events when interacting with curiosities
        local timeNow = GetTime()
        if event == "CHAT_MSG_LOOT" then
            local msg = ...
            if msg:find("Resonance Crystal") or msg:find("Undercoin") or msg:find("Companion Experience") then
                if timeNow - lastLootTime > 2 then
                    curiositiesFound = curiositiesFound + 1
                    UpdateTrackerText(true)
                    lastLootTime = timeNow
                end
            end
        elseif event == "CHAT_MSG_SYSTEM" then
            local msg = ...
            if msg:find("experience") and msg:find("Brann") then
                if timeNow - lastLootTime > 2 then
                    curiositiesFound = curiositiesFound + 1
                    UpdateTrackerText(true)
                    lastLootTime = timeNow
                end
            end
        elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
            local unit, castGUID, spellID = ...
            if unit == "player" then
                -- Add spellID check if you discover the actual spell
                if spellID == 447021 or spellID == 447020 then -- Placeholders
                    if timeNow - lastLootTime > 2 then
                        curiositiesFound = curiositiesFound + 1
                        UpdateTrackerText(true)
                        lastLootTime = timeNow
                    end
                end
            end
        end
    end
end)

C_Timer.NewTicker(2, function()
    if inDelve and not trackerFrame and ZipTrixDB and ZipTrixDB.delvesMislaidCuriositiesTracking then
        SetupTrackerFrame()
        if trackerFrame then
            UpdateTrackerText()
        end
    end
end)
