----------------------------------------------------------------------
-- 1. INITIALIZATION & DATABASE
----------------------------------------------------------------------
local addonName, ns = ...
local CreateFrame = CreateFrame
local frame = CreateFrame("Frame")
ns.frame = frame

-- Internal Localization
local L = {
    TOOLTIP_HEADER = "Tooltip Customization",
    ANCHOR_CURSOR = "Enable Anchor to Cursor",
    HIDE_COMBAT = "Hide Tooltip in Combat",
    HIDE_HEALTH = "Hide Health Bar",
    SHOW_ITEM_ID = "Show Item ID",
    SHOW_SPELL_ID = "Show Spell ID",
    ENABLE_UPGRADE_CLARITY = "Enable Upgrade Clarity",
    SHOW_SOURCES = "Show Crest Sources",
    ANCHOR_POINT = "Anchor Point",
    ANCHOR_LABEL = "Anchor: ",
    BORDER_STYLE = "Border Style",
    BORDER_LABEL = "Border: ",
    OFFSET_X = "Offset X",
    OFFSET_Y = "Offset Y",
    CHAR_HEADER = "Character Options",
    PALADIN_HEADER = "Paladin (Lightsmith)",
    SHAMAN_HEADER = "Shaman Options",
    SHAMAN_MAELSTROM_BAR = "Enable Maelstrom Bar",
    SHAMAN_MAELSTROM_TOOLTIP = "Replaces the default Maelstrom Weapon spell alert with a combo-point style resource bar.\n\nTracks up to 10 stacks.\n\nNote: A UI Reload (/reload) is required to fully enable or disable this feature.",
    MACRO_TRAVEL_TOOLTIP = "Creates 'ZipTravel' macro.\n\nPrioritizes Ghost Wolf in combat/indoors.\nSummons random favorite mount otherwise.",
    MACRO_UTILITY_TOOLTIP = "Creates 'ZipUtility' macro.\n\nMouseover Hex (Harm) or Cleanse Spirit (Help).\nCancels casting/queued spells.",
    MACRO_INTERRUPT_TOOLTIP = "Creates 'ZipInterrupt' macro.\n\nMouseover or Target Wind Shear.\nCancels casting/queued spells.",
    CREATE_MACRO = "Create Imbue Macro",
    MACRO_CLEANUP = "Macro Clean Up",
    MACRO_CLEANUP_NOTE = "Removes duplicate character macros (may freeze mom entarily)",
    GATEWAY_HEADER = "Gateway Options",
    ENABLE_GATEWAYS = "Enable Gateways",
    ENABLE_GATEWAYS_TOOLTIP = "Adds a side panel to the World Map containing shortcuts to various teleports, portals, and hearthstones.",
    SHOW_GATEWAY_TOOLTIPS = "Show Gateway Tooltips",
    SHOW_GATEWAY_TOOLTIPS_TOOLTIP = "Displays information about the destination or item when hovering over icons in the Gateway panel.",
    SHOW_SEASON = "Show Season Teleports",
    SHOW_SEASON_TOOLTIP = "Includes a section for current Mythic+ Season dungeon teleports if you have completed the required achievements.",
    BANK_NOTE = "Note: Green icons indicate items found in your bank.",
    INTERFACE_HEADER = "Interface Customization",
    ENABLE_THEMING = "Enable Button Theming",
    ENABLE_GRADIENTS = "Enable Class-Spec Gradients",
    ENABLE_FRAMEWORX = "Enable ZipTrix Frameworx",
    BUTTON_STYLE = "Button Style",
    STYLE_LABEL = "Style: ",
    NAV_TOOLTIP = "Tooltip",
    NAV_CHARACTER = "Character",
    NAV_GATEWAY = "Gateway",
    NAV_INTERFACE = "Interface",
    NAV_TWILIGHT = "Twilight Highlands",
    NAV_LOOTZ = "Lootz",
    NAV_ABOUT = "About",
    ENABLE_SECRETS = "Enable Secrets Helper",
    ENABLE_SECRETS_TOOLTIP = "Enables a button on the Gateway panel to toggle the 'Everything Else' view.",
    UNLOCK_FRAMES = "Unlock Blizzard Frames",
    UNLOCK_FRAMES_TOOLTIP = "Blizzard has locked the interface for new characters until reaching certain milestones.\n\nThis button will unlock the interface until new characters reach Level 10 and select their specialization.",
    UNLOCK_CONFIRM = "This action cannot be undone.\n\nAre you sure you want to force unlock the Blizzard Edit Mode?",
    RELOAD_CONFIRM = "Changing this setting requires a UI Reload to function correctly.\n\nReload now?",
    RELOAD_TOOLTIP = "This setting requires a UI Reload to take effect.\n\nAfter reload, cycle through specializations and enjoy!\n\n* Devourer Demon Hunter colorway will only be available after the full release of Midnight",
    GRADIENT_REQ = "Requirements: Level 10+ and active Specialization.",
    ENABLE_PORTRAIT = "Custom Character Sheet",
    CUSTOM_CHAR_SHEET_TOOLTIP = "This will enable Jibberish icons to be used on your character pane instead of your portrait.\n\nRight-click your portrait on the Character sheet and select your choice of icon.",
    PORTRAIT_STYLE = "Portrait Style",
    PORTRAIT_LABEL = "Style: ",
    ENABLE_TRANSMOG_RARITY = "Transmog Rarity",
    ENABLE_TRANSMOG_RARITY_TOOLTIP = "Displays a rarity percentage on item previews in the Transmogrify window and adds a button to sort by rarity.",
}

-- Default Settings
local defaults = {
    anchorCursor = true,
    anchorPoint = "BOTTOMLEFT",
    borderStyle = "Blizzard", -- New Setting
    offsetX = 0,
    offsetY = 0,
    hideInCombat = false,
    hideHealthBar = false,
    showItemID = false,
    showSpellID = false,
    -- Teleport Panel Defaults
    teleportsWorldMapEnabled = true,
    portalShowTooltip = true,
    teleportFavorites = {},
    teleportsWorldMapShowSeason = true,
    characterPortraitEnabled = false,
    characterPortraitStyle = "Fabled",
    shamanMaelstromBar = false,
    maelstromBarPoint = "CENTER",
    maelstromBarX = 0,
    maelstromBarY = -200,
    maelstromBarWidth = 200,
    maelstromBarHeight = 20,
    -- Interface Options
    interfaceThemeEnabled = true,
    interfaceButtonStyle = "Expansion",
    enableSpecGradient = true,
    enableFrameworx = false,
    upgradeClarityEnabled = true,
    upgradeClarityShowSources = true,
    enableSecretsHelper = false,
    transmogRarityEnabled = false,
    enableUnitFrameOverlay = false,
    enableLootz = true,
    lootzFeedbackEnabled = true,
    lootzSyntax = "+",
    lootzColor = {r = 0, g = 1, b = 0},
    lootzCurrencyFeedbackEnabled = true,
    lootzCurrencySyntax = "+",
    lootzCurrencyColor = {r = 0, g = 1, b = 0},
    lootzExpFeedbackEnabled = true,
    lootzExpSyntax = "+",
    lootzExpColor = {r = 0, g = 1, b = 0},
    lootzGoldFeedbackEnabled = true,
    lootzGoldSyntax = "+",
    lootzGoldColor = {r = 0, g = 1, b = 0},
    lootzGatheringFeedbackEnabled = true,
    lootzGatheringSyntax = "+",
    lootzGatheringColor = {r = 0, g = 1, b = 0},
    lootzPreyFeedbackEnabled = true,
    lootzPreySyntax = "+",
    lootzPreyColor = {r = 0, g = 1, b = 0},
    lootzRepFeedbackEnabled = true,
    lootzRepSyntax = "+",
    lootzRepColor = {r = 0, g = 1, b = 0},
}

local anchorPoints = { "BOTTOMLEFT", "BOTTOMRIGHT", "TOPLEFT", "TOPRIGHT", "CENTER" }
local borderStyles = { "Blizzard", "Blizzard Dark", "Dark", "Expansion", "Class" } -- Cycle Options
local portraitStyles = { "Fabled", "Fabled Core", "Fabled Myth", "Fabled Realm", "Into The Void", "Blizzard Default", "Hidden" }

-- Forward declarations
local ApplyButtonTheme

----------------------------------------------------------------------
-- F. Wardrobe Icon Search
----------------------------------------------------------------------
-- Table format: [Spec_ID] = {r, g, b}
local SpecColors = {
    -- DEATH KNIGHT
    [250] = {0.50, 0.05, 0.10}, -- Blood (Dark Red)
    [251] = {0.00, 0.80, 1.00}, -- Frost (Ice Blue)
    [252] = {0.30, 0.70, 0.20}, -- Unholy (Plague Green)
    -- DEMON HUNTER
    [577] = {0.10, 0.60, 0.10}, -- Havoc (Dark Fel Green)
    [581] = {0.65, 0.35, 0.65}, -- Vengeance (Dark Lavender)
    [582] = {0.24, 0.19, 0.96}, -- Devourer (Devourer Blue)
    -- DRUID
    [102] = {0.30, 0.60, 0.90}, -- Balance (Astral Blue)
    [103] = {0.90, 0.20, 0.20}, -- Feral (Bleed Red)
    [104] = {0.40, 0.20, 0.10}, -- Guardian (Bear Brown)
    [105] = {0.60, 0.75, 0.20}, -- Restoration (Autumn Green-Yellow)
    -- EVOKER
    [1467] = {0.85, 0.35, 0.75}, -- Devastation (Cosmic Pink/Purple)
    [1468] = {0.80, 0.70, 0.40}, -- Preservation (Bronze/Time)
    [1473] = {0.92, 0.80, 0.50}, -- Augmentation (Shiny Brass)
    -- HUNTER
    [253] = {0.05, 0.35, 0.10}, -- Beast Mastery (Dark Hunter Green)
    [254] = {0.40, 0.50, 0.30}, -- Marksmanship (Sniper Camo Green)
    [255] = {0.55, 0.65, 0.20}, -- Survival (Autumn Green)
    -- MAGE
    [62] = {0.80, 0.40, 0.90},  -- Arcane (Arcane Purple)
    [63] = {1.00, 0.30, 0.00},  -- Fire (Fire Orange)
    [64] = {0.40, 0.70, 1.00},  -- Frost (Frost Blue)
    -- MONK
    [268] = {0.60, 0.55, 0.35}, -- Brewmaster (Matted Brew)
    [270] = {0.05, 0.45, 0.35}, -- Mistweaver (Dark Jade)
    [269] = {0.30, 0.60, 0.90}, -- Windwalker (Wind Blue)
    -- PALADIN
    [65] = {1.00, 0.90, 0.60},  -- Holy (Light Yellow)
    [66] = {0.37, 0.13, 0.26},  -- Protection (Void/Plum)
    [70] = {1.00, 0.70, 0.20},  -- Retribution (Ret Gold)
    -- PRIEST
    [256] = {0.65, 0.60, 0.45}, -- Discipline (Matted Shield Yellow)
    [257] = {0.85, 0.65, 0.12}, -- Holy (Goldenrod)
    [258] = {0.40, 0.20, 0.60}, -- Shadow (Void Purple)
    -- ROGUE
    [259] = {0.10, 0.55, 0.15}, -- Assassination (Dark Venom Green)
    [260] = {0.55, 0.15, 0.15}, -- Outlaw (Dark Dirty Red)
    [261] = {0.40, 0.10, 0.35}, -- Subtlety (Shadowy Burgundy)
    -- SHAMAN
    [262] = {0.10, 0.50, 1.00}, -- Elemental (Lightning Blue)
    [263] = {0.45, 0.55, 0.65}, -- Enhancement (Steel Blue)
    [264] = {0.00, 0.80, 0.60}, -- Restoration (Water Green-Blue)
    -- WARLOCK
    [265] = {0.50, 0.30, 0.70}, -- Affliction (Shadow)
    [266] = {0.20, 0.80, 0.20}, -- Demonology (Fel)
    [267] = {0.90, 0.30, 0.10}, -- Destruction (Fire)
    -- WARRIOR
    [71] = {0.50, 0.60, 0.75},  -- Arms (Blueish Steel)
    [72] = {0.65, 0.05, 0.05},  -- Fury (Dark Raging Red)
    [73] = {0.40, 0.35, 0.32},  -- Protection (Burnt Iron)
}

local ClassIconCoords = {
    ["WARRIOR"]     = {0.000, 0.125, 0.000, 0.125},
    ["MAGE"]        = {0.125, 0.250, 0.000, 0.125},
    ["ROGUE"]       = {0.250, 0.375, 0.000, 0.125},
    ["DRUID"]       = {0.375, 0.500, 0.000, 0.125},
    ["EVOKER"]      = {0.500, 0.625, 0.000, 0.125},
    ["HUNTER"]      = {0.000, 0.125, 0.125, 0.250},
    ["SHAMAN"]      = {0.125, 0.250, 0.125, 0.250},
    ["PRIEST"]      = {0.250, 0.375, 0.125, 0.250},
    ["WARLOCK"]     = {0.375, 0.500, 0.125, 0.250},
    ["PALADIN"]     = {0.000, 0.125, 0.250, 0.375},
    ["DEATHKNIGHT"] = {0.125, 0.250, 0.250, 0.375},
    ["MONK"]        = {0.250, 0.375, 0.250, 0.375},
    ["DEMONHUNTER"] = {0.375, 0.500, 0.250, 0.375},
}

local function InitTransmogRarity()
    if not WardrobeCollectionFrame then return end
    local itemsFrame = WardrobeCollectionFrame.ItemsCollectionFrame
    if not itemsFrame then return end

    -- 1. Rarity Percentage Overlay
    hooksecurefunc(itemsFrame, "UpdateItems", function(self)
        if not ZipTrixDB.transmogRarityEnabled then 
            for _, model in ipairs(self.Models) do
                if model.ZipTrixRarity then model.ZipTrixRarity:Hide() end
                if model.ZipTrixRarityBg then model.ZipTrixRarityBg:Hide() end
            end
            return 
        end
        
        for _, model in ipairs(self.Models) do
            if model:IsShown() then
                if not model.ZipTrixRarity then
                    model.ZipTrixRarity = model:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    model.ZipTrixRarity:SetPoint("BOTTOMRIGHT", -4, 4)
                    model.ZipTrixRarity:SetTextColor(1, 1, 1)
                    
                    model.ZipTrixRarityBg = model:CreateTexture(nil, "BACKGROUND")
                    model.ZipTrixRarityBg:SetColorTexture(0, 0, 0, 0.6)
                    model.ZipTrixRarityBg:SetPoint("TOPLEFT", model.ZipTrixRarity, "TOPLEFT", -2, 2)
                    model.ZipTrixRarityBg:SetPoint("BOTTOMRIGHT", model.ZipTrixRarity, "BOTTOMRIGHT", 2, -2)
                end
                
                local visualInfo = model.visualInfo
                if visualInfo then
                    local sources = C_TransmogCollection.GetAppearanceSources(visualInfo.visualID)
                    if sources and sources[1] then
                        local _, _, quality = C_TransmogCollection.GetAppearanceSourceInfo(sources[1].sourceID)
                        -- Heuristic Rarity Percentage based on Quality
                        local pct = 100
                        if quality == 1 then pct = 90      -- Common
                        elseif quality == 2 then pct = 50  -- Uncommon
                        elseif quality == 3 then pct = 20  -- Rare
                        elseif quality == 4 then pct = 5   -- Epic
                        elseif quality == 5 then pct = 1   -- Legendary
                        elseif quality == 6 then pct = 0.1 -- Artifact
                        end
                        
                        model.ZipTrixRarity:SetText(pct .. "%")
                        model.ZipTrixRarity:Show()
                        model.ZipTrixRarityBg:Show()
                    else
                        model.ZipTrixRarity:Hide()
                        model.ZipTrixRarityBg:Hide()
                    end
                end
            end
        end
    end)

    -- 2. Rarity Sort Button
    local sortBtn = CreateFrame("Button", nil, WardrobeCollectionFrame, "UIMenuButtonStretchTemplate")
    sortBtn:SetText("Rarity Sort")
    sortBtn:SetSize(90, 22)
    sortBtn:SetPoint("RIGHT", WardrobeCollectionFrame.FilterButton, "LEFT", -5, 0)
    sortBtn:SetScript("OnClick", function()
        itemsFrame.ZipTrixSortByRarity = true
        itemsFrame:UpdateItems()
    end)
    sortBtn:SetScript("OnShow", function(self)
        self:SetShown(ZipTrixDB.transmogRarityEnabled)
    end)

    -- Hook Sorting Logic
    hooksecurefunc(itemsFrame, "SortVisuals", function(self, visualsList)
        if self.ZipTrixSortByRarity then
            table.sort(visualsList, function(a, b)
                local qA, qB = 0, 0
                local sA = C_TransmogCollection.GetAppearanceSources(a.visualID)
                if sA and sA[1] then local _, _, q = C_TransmogCollection.GetAppearanceSourceInfo(sA[1].sourceID); qA = q or 0 end
                local sB = C_TransmogCollection.GetAppearanceSources(b.visualID)
                if sB and sB[1] then local _, _, q = C_TransmogCollection.GetAppearanceSourceInfo(sB[1].sourceID); qB = q or 0 end
                return qA > qB -- Descending Quality (Most Rare First)
            end)
            self.ZipTrixSortByRarity = false
        end
    end)
end

local function InitWardrobeSearch()
    local frame = WardrobeOutfitEditFrame
    if not frame or frame.ZipTrixSearchBox then return end

    local sb = CreateFrame("EditBox", nil, frame, "SearchBoxTemplate")
    sb:SetSize(115, 20)
    -- Position: Left of the Dropdown
    if frame.FilterDropDown then
        sb:SetPoint("RIGHT", frame.FilterDropDown, "LEFT", -5, 2)
    else
        sb:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -140, -35)
    end
    sb:SetFrameLevel(frame:GetFrameLevel() + 10)
    sb:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)
        frame:Update()
    end)
    frame.ZipTrixSearchBox = sb

    hooksecurefunc(frame, "Update", function(self)
        local text = sb:GetText()
        if not text or text == "" then return end

        local searchIcon = nil
        local id = tonumber(text)
        if id then
            -- Try SpellID
            local spellInfo = C_Spell.GetSpellInfo(id)
            if spellInfo then searchIcon = spellInfo.iconID end
            -- Try ItemID
            if not searchIcon then
                local _, _, _, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(id)
                if itemIcon then searchIcon = itemIcon end
            end
            -- Fallback: Raw ID
            if not searchIcon then searchIcon = id end
        else
            -- Try Spell Name
            local spellInfo = C_Spell.GetSpellInfo(text)
            if spellInfo then searchIcon = spellInfo.iconID end
            -- Try Item Name
            if not searchIcon then
                local _, _, _, _, _, _, _, _, _, itemIcon = C_Item.GetItemInfo(text)
                if itemIcon then searchIcon = itemIcon end
            end
        end

        if searchIcon then
            self.icons = { searchIcon }
        else
            self.icons = {}
        end
        if self.ScrollFrame and self.ScrollFrame.update then
            self.ScrollFrame.update()
        end
    end)
end

local playerSpecR, playerSpecG, playerSpecB = 0.5, 0.5, 0.5
local gradientsAvailable = false
local function CheckGradientRequirements()
    local level = UnitLevel("player")
    local spec = GetSpecialization()
    if level and level >= 10 and spec then
        gradientsAvailable = true
        
        -- Cache Player Spec Color
        local specID = GetSpecializationInfo(spec)
        if specID and SpecColors[specID] then
            local c = SpecColors[specID]
            playerSpecR, playerSpecG, playerSpecB = c[1], c[2], c[3]
        else
            local _, classFile = UnitClass("player")
            local c = C_ClassColor.GetClassColor(classFile)
            if c then playerSpecR, playerSpecG, playerSpecB = c.r, c.g, c.b end
        end
    else
        gradientsAvailable = false
    end
end

-- Generic Hook for Class Resource Bars (Holy Power, Soul Shards, Chi, Combo Points, Arcane Charges, Runes, Essence)
local function UpdateClassResourceColor(self)
    if not ZipTrixDB or not ZipTrixDB.enableSpecGradient or not gradientsAvailable then return end
    
    local r, g, b = playerSpecR, playerSpecG, playerSpecB

    -- Identify the table holding the resource points
    local points = self.classResourceButtonTable or self.ComboPoints or self.Shards or self.Runes
    
    if points then
        for _, btn in pairs(points) do
            if btn then
                for _, region in ipairs({btn:GetRegions()}) do
                    if region:IsObjectType("Texture") then
                        -- Desaturate first to remove default class colors (e.g. Gold/Yellow)
                        -- This allows the custom vertex color to apply purely, creating the correct "glow"
                        region:SetDesaturated(true)
                        region:SetVertexColor(r, g, b)
                    end
                end
            end
        end
    end
end

local function InitResourceBarHooks()
    local resourceFrames = {
        PaladinPowerBar,
        MonkHarmonyBarFrame,
        WarlockPowerFrame,
        MageArcaneChargesFrame,
        ComboPointPlayerFrame,
        EssencePlayerFrame,
        RuneFrame, 
    }

    for _, frame in ipairs(resourceFrames) do
        if frame then
            if frame.UpdatePower then hooksecurefunc(frame, "UpdatePower", UpdateClassResourceColor) end
            if frame == RuneFrame and frame.UpdateRunes then hooksecurefunc(frame, "UpdateRunes", UpdateClassResourceColor) end
        end
    end
end

----------------------------------------------------------------------
-- J. Bag & Container Hooks
----------------------------------------------------------------------
local openableCache = {}
local function IsItemOpenable(itemID)
    if not itemID then return false end
    if openableCache[itemID] ~= nil then return openableCache[itemID] end
    
    local data = C_TooltipInfo.GetItemByID(itemID)
    if data and data.lines then
        for _, line in ipairs(data.lines) do
            local text = line.leftText
            if text and (text:find("Right Click to Open") or text:find("Right-Click to Open") or text:find("<Right Click to Open>") or text:find("Use: Open")) then
                openableCache[itemID] = true
                return true
            end
        end
    end
    openableCache[itemID] = false
    return false
end

local function UpdateBagItemStyle(button)
    if not ZipTrixDB or not ZipTrixDB.interfaceThemeEnabled then return end
    
    local bag = button:GetBagID()
    local slot = button:GetID()
    local info = C_Container.GetContainerItemInfo(bag, slot)
    
    if not button.ZipTrixGlow then
        button.ZipTrixGlow = button:CreateTexture(nil, "OVERLAY")
        button.ZipTrixGlow:SetTexture("Interface\\Buttons\\UI-NewItem")
        button.ZipTrixGlow:SetPoint("CENTER")
        button.ZipTrixGlow:SetSize(50, 50) -- Slightly larger than the button for the glow effect
        button.ZipTrixGlow:SetBlendMode("ADD")
        button.ZipTrixGlow:Hide()
    end

    -- Reset
    if button.icon then button.icon:SetDesaturated(false) end
    button.ZipTrixGlow:Hide()

    if info and info.itemID then
        if IsItemOpenable(info.itemID) then
            if button.icon then button.icon:SetDesaturated(true) end
            button.ZipTrixGlow:Show()
            
            local r, g, b = 1, 1, 1
            local style = ZipTrixDB.interfaceButtonStyle or "Expansion"
            if style == "Dark" then r,g,b = 0.4, 0.4, 0.4
            elseif style == "Expansion" then r,g,b = 0.6, 0.2, 1.0
            elseif style == "Class" then
                local _, classFilename = UnitClass("player")
                local c = C_ClassColor.GetClassColor(classFilename)
                if c then r,g,b = c.r, c.g, c.b end
            elseif style == "Blizzard" then r,g,b = 1, 0.8, 0
            end
            
            button.ZipTrixGlow:SetVertexColor(r, g, b)
        end
    end
end

local function InitBagHooks()
    if ContainerFrame_Update then
        hooksecurefunc("ContainerFrame_Update", function(frame)
            local name = frame:GetName()
            if not name or not frame.size then return end
            for i = 1, frame.size do
                local button = _G[name .. "Item" .. i]
                if button then
                    UpdateBagItemStyle(button)
                end
            end
        end)
    end
end

local function UpdateZipTrixPortrait()
    if not CharacterFrame then return end

    -- Identify the portrait texture (Modern WoW uses PortraitContainer)
    local portrait = CharacterFrame.PortraitContainer and CharacterFrame.PortraitContainer.portrait
    if not portrait then portrait = CharacterFramePortrait end
    if not portrait then return end
    
    if not ZipTrixDB.characterPortraitEnabled or ZipTrixDB.characterPortraitStyle == "Blizzard Default" then
        SetPortraitTexture(portrait, "player")
        portrait:SetTexCoord(0, 1, 0, 1)
        portrait:SetVertexColor(1, 1, 1, 1)
        portrait:Show()
    elseif ZipTrixDB.characterPortraitStyle == "Hidden" then
        portrait:SetTexture("Interface\\Buttons\\WHITE8x8")
        portrait:SetTexCoord(0, 1, 0, 1)
        portrait:SetVertexColor(0, 0, 0, 1)
        portrait:Show()
    else
        portrait:Show()
        portrait:SetVertexColor(1, 1, 1, 1)
        local _, classFilename = UnitClass("player")
        local coords = ClassIconCoords[classFilename]
        if coords then
            local style = ZipTrixDB.characterPortraitStyle or "Fabled"
            local fileStyle = style:lower():gsub(" ", "")
            local texturePath = "Interface\\AddOns\\ZipTrix\\assets\\" .. fileStyle .. ".tga"
            portrait:SetTexture(texturePath)
            portrait:SetTexCoord(unpack(coords))
        end
    end
end

local CharacterPortraitHooked = false
local function InitCharacterPortraitHook()
    if CharacterPortraitHooked then return end
    if not CharacterFrame then return end
    CharacterPortraitHooked = true

    -- Hook into the standard character frame portrait update if it exists
    if CharacterFrame_UpdatePortrait then
        hooksecurefunc("CharacterFrame_UpdatePortrait", UpdateZipTrixPortrait)
    end

    -- Always hook OnShow with a delay to ensure our icon persists
    CharacterFrame:HookScript("OnShow", function()
        UpdateZipTrixPortrait()
        C_Timer.After(0.1, UpdateZipTrixPortrait)
    end)

    -- Hook PaperDollFrame OnShow to ensure portrait persists when switching back to character tab
    if PaperDollFrame then
        PaperDollFrame:HookScript("OnShow", function()
            UpdateZipTrixPortrait()
        end)
    end

    CharacterFrame:HookScript("OnEvent", function(self, event)
        if event == "UNIT_PORTRAIT_UPDATE" or event == "PORTRAITS_UPDATED" or event == "PLAYER_ENTERING_WORLD" then
            UpdateZipTrixPortrait()
        end
    end)

    -- Hook SetPortraitTexture to catch Blizzard updates (fixes revert on show)
    hooksecurefunc("SetPortraitTexture", function(texture, unit)
        if ZipTrixDB.characterPortraitEnabled and ZipTrixDB.characterPortraitStyle ~= "Blizzard Default" then
            local portrait = CharacterFrame.PortraitContainer and CharacterFrame.PortraitContainer.portrait
            if not portrait then portrait = CharacterFramePortrait end
            if texture == portrait then
                UpdateZipTrixPortrait()
            end
        end
    end)

        -- Add Click Handler for Right-Click Cycle
        local portraitContainer = CharacterFrame.PortraitContainer
        if portraitContainer and not portraitContainer.ZipTrixClicker then
            local btn = CreateFrame("Button", nil, portraitContainer)
            btn:SetAllPoints(portraitContainer)
            btn:RegisterForClicks("RightButtonUp")
            if btn.SetPassThroughButtons then
                btn:SetPassThroughButtons("LeftButton", "MiddleButton", "Button4", "Button5")
            end
            btn:SetScript("OnClick", function(self, button)
                if button == "RightButton" and ZipTrixDB.characterPortraitEnabled then
                    local current = ZipTrixDB.characterPortraitStyle or "Fabled"
                    local idx = 1
                    for i, p in ipairs(portraitStyles) do if p == current then idx = i break end end
                    ZipTrixDB.characterPortraitStyle = portraitStyles[(idx % #portraitStyles) + 1]
                    if CharacterFrame_UpdatePortrait then
                        CharacterFrame_UpdatePortrait()
                    else
                        UpdateZipTrixPortrait()
                    end
                end
            end)
            portraitContainer.ZipTrixClicker = btn
        end

    -- Force update immediately if visible (fixes reload issue)
    if CharacterFrame:IsVisible() then
        UpdateZipTrixPortrait()
    end
end

local function InitBlizzardButtonHooks()
    if GameMenuFrame then
        GameMenuFrame:HookScript("OnShow", function()
            for _, child in ipairs({GameMenuFrame:GetChildren()}) do
                if child:IsObjectType("Button") then
                    ApplyButtonTheme(child)
                end
            end
        end)
    end
end

local function InitTalentFrameHooks()
    if PlayerSpellsFrame then
        local function SkinTalentButtons()
            if PlayerSpellsFrame.SpecFrame and PlayerSpellsFrame.SpecFrame.ActivateButton then
                ApplyButtonTheme(PlayerSpellsFrame.SpecFrame.ActivateButton)
            end
            if PlayerSpellsFrame.TalentsFrame then
                if PlayerSpellsFrame.TalentsFrame.ApplyButton then ApplyButtonTheme(PlayerSpellsFrame.TalentsFrame.ApplyButton) end
                if PlayerSpellsFrame.TalentsFrame.InspectCopyButton then ApplyButtonTheme(PlayerSpellsFrame.TalentsFrame.InspectCopyButton) end
            end
        end
        if not PlayerSpellsFrame.ZipTrixHooked then
            PlayerSpellsFrame:HookScript("OnShow", SkinTalentButtons)
            PlayerSpellsFrame.ZipTrixHooked = true
        end
        if PlayerSpellsFrame:IsVisible() then SkinTalentButtons() end
    end
end

----------------------------------------------------------------------
-- K. Dressing Room Hooks
----------------------------------------------------------------------
local Races = {
    Alliance = {
        { id = 1, name = "Human" },
        { id = 3, name = "Dwarf" },
        { id = 4, name = "Night Elf" },
        { id = 7, name = "Gnome" },
        { id = 11, name = "Draenei" },
        { id = 22, name = "Worgen" },
        { id = 24, name = "Pandaren" },
        { id = 29, name = "Void Elf" },
        { id = 30, name = "Lightforged" },
        { id = 32, name = "Kul Tiran" },
        { id = 34, name = "Dark Iron" },
        { id = 37, name = "Mechagnome" },
        { id = 70, name = "Dracthyr" },
        { id = 73, name = "Earthen" },
    },
    Horde = {
        { id = 2, name = "Orc" },
        { id = 5, name = "Undead" },
        { id = 6, name = "Tauren" },
        { id = 8, name = "Troll" },
        { id = 9, name = "Goblin" },
        { id = 10, name = "Blood Elf" },
        { id = 24, name = "Pandaren" },
        { id = 27, name = "Nightborne" },
        { id = 28, name = "Highmountain" },
        { id = 31, name = "Zandalari" },
        { id = 35, name = "Vulpera" },
        { id = 36, name = "Mag'har Orc" },
        { id = 70, name = "Dracthyr" },
        { id = 73, name = "Earthen" },
    }
}

local currentFaction = UnitFactionGroup("player") or "Alliance"
local _, _, currentRaceID = UnitRace("player")
local currentGender = (UnitSex("player") == 3) and 1 or 0

local function GetRaceName(id)
    for _, fac in pairs(Races) do
        for _, r in ipairs(fac) do
            if r.id == id then return r.name end
        end
    end
    return "Unknown"
end

local function UpdateDressingRoomModel()
    if not DressUpFrame then return end

    local _, _, playerRaceID = UnitRace("player")
    local playerGender = (UnitSex("player") == 3) and 1 or 0
    local isCustom = (currentRaceID ~= playerRaceID) or (currentGender ~= playerGender)

    -- If we're not using a custom model, hide our frame and show Blizzard's
    if not isCustom then
        if DressUpFrame.ZipTrixModel then DressUpFrame.ZipTrixModel:Hide() end
        if DressUpFrame.ModelScene then DressUpFrame.ModelScene:Show() end
        return
    end

    -- Create our custom model frame if it doesn't exist
    if not DressUpFrame.ZipTrixModel then
        local model = CreateFrame("DressUpModel", nil, DressUpFrame)
        if DressUpFrame.ModelScene then
            model:SetAllPoints(DressUpFrame.ModelScene)
            model:SetFrameLevel(DressUpFrame.ModelScene:GetFrameLevel() + 1)
        else
            model:SetAllPoints(DressUpFrame)
        end
        model:SetUnit("player") -- Start with player model
        model:SetAutoDress(true)

        -- Mirror default rotation functionality
        model:EnableMouse(true)
        model:SetScript("OnMouseDown", function(self, button)
            if button == "LeftButton" then
                self.isRotating = true
                self.cursorX = GetCursorPosition()
            end
        end)
        model:SetScript("OnMouseUp", function(self, button)
            if button == "LeftButton" then
                self.isRotating = false
            end
        end)
        model:SetScript("OnUpdate", function(self, elapsed)
            self.elapsed_accum = (self.elapsed_accum or 0) + elapsed
            if self.elapsed_accum >= 0.1 then
                self.elapsed_accum = 0
                if self.isRotating then
                    local x = GetCursorPosition()
                    local diff = (x - self.cursorX) * 0.01
                    self:SetFacing(self:GetFacing() + diff)
                    self.cursorX = x
                end
            end
        end)
        
        DressUpFrame.ZipTrixModel = model
    end

    local model = DressUpFrame.ZipTrixModel
    model:Show()
    if DressUpFrame.ModelScene then DressUpFrame.ModelScene:Hide() end

    -- Get the outfit from the (now hidden) native actor
    local actor = DressUpFrame.ModelScene and DressUpFrame.ModelScene:GetPlayerActor()
    local outfit = actor and actor.GetItemTransmogInfoList and actor:GetItemTransmogInfoList()

    -- This is the key change: Use the new API on our custom model frame
    if type(model.SetPlayerModelFromGlues) == "function" then
        model:SetPlayerModelFromGlues(currentRaceID, currentGender)
    else
        -- Fallback or error if the function doesn't exist on DressUpModel either
        model:SetUnit("player")
    end

    -- Re-apply the outfit to our custom model
    if outfit then
        model:Undress() -- Undress first to clear any previous state
        for slotID, itemTransmogInfo in pairs(outfit) do
            if itemTransmogInfo and itemTransmogInfo.appearanceID and itemTransmogInfo.appearanceID > 0 then
                model:TryOn(itemTransmogInfo.appearanceID)
            end
        end
    end
end

local function CreateDressingRoomControls()
    if not DressUpFrame then return end
    if DressUpFrame.ZipTrixPanel then return end
    
    -- Create Side Panel
    local panel = CreateFrame("Frame", nil, DressUpFrame, "BackdropTemplate")
    panel:SetSize(200, 160)
    panel:SetPoint("TOPRIGHT", DressUpFrame, "TOPLEFT", -2, 0)
    panel:SetFrameLevel(DressUpFrame:GetFrameLevel() + 5)
    
    panel:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    panel:SetBackdropColor(0.05, 0.05, 0.05, 0.95)
    panel:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    
    local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOP", 0, -12)
    title:SetText("Model Options")
    
    local closeBtn = CreateFrame("Button", nil, panel, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -2, -2)
    
    panel:Hide()
    DressUpFrame.ZipTrixPanel = panel
    
    -- Create Toggle Button
    local toggleBtn = CreateFrame("Button", nil, DressUpFrame)
    local refBtn = DressUpFrame.ToggleCustomSetDetailsButton or DressUpFrame.ToggleCusotmSetDetailsButton or DressUpFrame.ToggleOutfitDetailsButton
    
    if refBtn then
        toggleBtn:SetSize(refBtn:GetWidth(), refBtn:GetHeight())
        toggleBtn:SetPoint("RIGHT", refBtn, "LEFT", -2, 0)
        
        local normal = refBtn:GetNormalTexture()
        if normal then
            if normal:GetAtlas() then toggleBtn:SetNormalAtlas(normal:GetAtlas())
            else toggleBtn:SetNormalTexture(normal:GetTexture()) end
        end
        
        local pushed = refBtn:GetPushedTexture()
        if pushed then
            if pushed:GetAtlas() then toggleBtn:SetPushedAtlas(pushed:GetAtlas())
            else toggleBtn:SetPushedTexture(pushed:GetTexture()) end
        end
        
        local highlight = refBtn:GetHighlightTexture()
        if highlight then
            if highlight:GetAtlas() then toggleBtn:SetHighlightAtlas(highlight:GetAtlas())
            else toggleBtn:SetHighlightTexture(highlight:GetTexture()) end
            toggleBtn:GetHighlightTexture():SetBlendMode(highlight:GetBlendMode() or "ADD")
        end
        
        if refBtn.Icon then
            toggleBtn.Icon = toggleBtn:CreateTexture(nil, "ARTWORK")
            toggleBtn.Icon:SetAllPoints()
            if refBtn.Icon:GetAtlas() then toggleBtn.Icon:SetAtlas(refBtn.Icon:GetAtlas())
            else toggleBtn.Icon:SetTexture(refBtn.Icon:GetTexture()) end
        end
    else
        toggleBtn:SetSize(32, 32)
        if DressUpFrame.ResetButton then
            toggleBtn:SetPoint("RIGHT", DressUpFrame.ResetButton, "LEFT", -2, 0)
        else
            toggleBtn:SetPoint("TOPRIGHT", DressUpFrame, "TOPRIGHT", -40, -35)
        end
        toggleBtn:SetNormalTexture("Interface\\Buttons\\UI-SquareButton-Up")
        toggleBtn:SetPushedTexture("Interface\\Buttons\\UI-SquareButton-Down")
        toggleBtn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
    end
    
    toggleBtn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Model Options")
        GameTooltip:Show()
    end)
    toggleBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

    toggleBtn:SetScript("OnClick", function()
        if panel:IsShown() then
            panel:Hide()
        else
            panel:Show()
        end
    end)
    
    local factionBtn = CreateFrame("Button", nil, panel, "UIMenuButtonStretchTemplate")
    factionBtn:SetHeight(26)
    factionBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", 15, -45)
    factionBtn:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -20, -45)
    factionBtn:SetText("Faction: " .. currentFaction)
    
    local genderBtn = CreateFrame("Button", nil, panel, "UIMenuButtonStretchTemplate")
    genderBtn:SetHeight(26)
    genderBtn:SetPoint("TOPLEFT", factionBtn, "BOTTOMLEFT", 0, -10)
    genderBtn:SetPoint("TOPRIGHT", factionBtn, "BOTTOMRIGHT", 0, -10)
    genderBtn:SetText("Body: " .. (currentGender == 0 and "1 (Male)" or "2 (Female)"))
    
    local raceBtn = CreateFrame("Button", nil, panel, "UIMenuButtonStretchTemplate")
    raceBtn:SetHeight(26)
    raceBtn:SetPoint("TOPLEFT", genderBtn, "BOTTOMLEFT", 0, -10)
    raceBtn:SetPoint("TOPRIGHT", genderBtn, "BOTTOMRIGHT", 0, -10)
    raceBtn:SetText("Race: " .. GetRaceName(currentRaceID))
    
    panel.factionBtn = factionBtn
    panel.genderBtn = genderBtn
    panel.raceBtn = raceBtn
    
    factionBtn:SetScript("OnClick", function(self)
        if MenuUtil then
            MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
                rootDescription:CreateTitle("Select Faction")
                rootDescription:CreateButton("Alliance", function()
                    currentFaction = "Alliance"
                    currentRaceID = Races.Alliance[1].id
                    factionBtn:SetText("Faction: " .. currentFaction)
                    raceBtn:SetText("Race: " .. GetRaceName(currentRaceID))
                    UpdateDressingRoomModel()
                end)
                rootDescription:CreateButton("Horde", function()
                    currentFaction = "Horde"
                    currentRaceID = Races.Horde[1].id
                    factionBtn:SetText("Faction: " .. currentFaction)
                    raceBtn:SetText("Race: " .. GetRaceName(currentRaceID))
                    UpdateDressingRoomModel()
                end)
            end)
        end
    end)
    
    genderBtn:SetScript("OnClick", function(self)
        if MenuUtil then
            MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
                rootDescription:CreateTitle("Select Body Type")
                rootDescription:CreateButton("Body 1 (Male)", function()
                    currentGender = 0
                    genderBtn:SetText("Body: 1 (Male)")
                    UpdateDressingRoomModel()
                end)
                rootDescription:CreateButton("Body 2 (Female)", function()
                    currentGender = 1
                    genderBtn:SetText("Body: 2 (Female)")
                    UpdateDressingRoomModel()
                end)
            end)
        end
    end)
    
    raceBtn:SetScript("OnClick", function(self)
        if MenuUtil then
            MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
                rootDescription:CreateTitle("Select Race")
                local list = Races[currentFaction] or Races.Alliance
                for _, r in ipairs(list) do
                    rootDescription:CreateButton(r.name, function()
                        currentRaceID = r.id
                        raceBtn:SetText("Race: " .. r.name)
                        UpdateDressingRoomModel()
                    end)
                end
            end)
        end
    end)
end

local function InitDressingRoomHooks()
    if not DressUpFrame then return end
    
    DressUpFrame:HookScript("OnShow", CreateDressingRoomControls)
    
    local function ResetDressingRoomOptions()
        currentFaction = UnitFactionGroup("player") or "Alliance"
        local _, _, raceID = UnitRace("player")
        currentRaceID = raceID
        currentGender = (UnitSex("player") == 3) and 1 or 0
        
        if DressUpFrame.ZipTrixPanel then
            local factionBtn = DressUpFrame.ZipTrixPanel.factionBtn
            local genderBtn = DressUpFrame.ZipTrixPanel.genderBtn
            local raceBtn = DressUpFrame.ZipTrixPanel.raceBtn
            if factionBtn then factionBtn:SetText("Faction: " .. currentFaction) end
            if genderBtn then genderBtn:SetText("Body: " .. (currentGender == 0 and "1 (Male)" or "2 (Female)")) end
            if raceBtn then raceBtn:SetText("Race: " .. GetRaceName(currentRaceID)) end
        end

        if DressUpFrame.ZipTrixModel then
            DressUpFrame.ZipTrixModel:Hide()
        end
        if DressUpFrame.ModelScene then
            DressUpFrame.ModelScene:Show()
            local actor = DressUpFrame.ModelScene:GetPlayerActor()
            if actor then
                local outfit = actor.GetItemTransmogInfoList and actor:GetItemTransmogInfoList()
                actor:SetModelByUnit("player")
                if outfit then
                    for slotID, itemTransmogInfo in pairs(outfit) do
                        if itemTransmogInfo then actor:SetItemTransmogInfo(itemTransmogInfo, slotID) end
                    end
                end
            end
        end
    end
    
    DressUpFrame:HookScript("OnHide", ResetDressingRoomOptions)
    
    if DressUpFrame.ResetButton then
        DressUpFrame.ResetButton:HookScript("OnClick", ResetDressingRoomOptions)
    end
end

local InitUnitFrameHooks
local InitDropdownHooks
local InitMaelstromBar

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
frame:SetScript("OnEvent", function(self, event, arg1)
    if arg1 == addonName then
        ZipTrixDB = ZipTrixDB or {}

        -- Migration: Rename "ElvUI" style to "Dark"
        if ZipTrixDB.borderStyle == "ElvUI" then ZipTrixDB.borderStyle = "Dark" end
        if ZipTrixDB.interfaceButtonStyle == "ElvUI" then ZipTrixDB.interfaceButtonStyle = "Dark" end

        for k, v in pairs(defaults) do
            if ZipTrixDB[k] == nil then ZipTrixDB[k] = v end
        end

        -- Register fonts from the assets folder with LibSharedMedia-3.0
        local LSM = LibStub and LibStub("LibSharedMedia-3.0", true)
        if LSM then
            LSM:Register("font", "AtkinsonHyperlegibleNext-Bold", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-Bold.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-BoldItalic", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-BoldItalic.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-ExtraBold", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-ExtraBold.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-ExtraBoldItalic", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-ExtraBoldItalic.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-ExtraLight", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-ExtraLight.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-ExtraLightItalic", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-ExtraLightItalic.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-Italic", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-Italic.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-Light", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-Light.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-LightItalic", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-LightItalic.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-Medium", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-Medium.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-MediumItalic", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-MediumItalic.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-Regular", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-Regular.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-SemiBold", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-SemiBold.ttf")
            LSM:Register("font", "AtkinsonHyperlegibleNext-SemiBoldItalic", "Interface\\AddOns\\ZipTrix\\assets\\AtkinsonHyperlegibleNext-SemiBoldItalic.ttf")
            LSM:Register("font", "Expressway", "Interface\\AddOns\\ZipTrix\\assets\\Expressway.ttf")
            LSM:Register("font", "SFAtarianSystem", "Interface\\AddOns\\ZipTrix\\assets\\SFAtarianSystem.ttf")
            LSM:Register("font", "SFAtarianSystemBold", "Interface\\AddOns\\ZipTrix\\assets\\SFAtarianSystemBold.ttf")
            LSM:Register("font", "SFAtarianSystemBoldItalic", "Interface\\AddOns\\ZipTrix\\assets\\SFAtarianSystemBoldItalic.ttf")
            LSM:Register("font", "SFAtarianSystemItalic", "Interface\\AddOns\\ZipTrix\\assets\\SFAtarianSystemItalic.ttf")
            LSM:Register("font", "ZillaSlab-Bold", "Interface\\AddOns\\ZipTrix\\assets\\ZillaSlab-Bold.ttf")
            LSM:Register("font", "ZillaSlab-BoldItalic", "Interface\\AddOns\\ZipTrix\\assets\\ZillaSlab-BoldItalic.ttf")
            LSM:Register("font", "ZillaSlab-Italic", "Interface\\AddOns\\ZipTrix\\assets\\ZillaSlab-Italic.ttf")
            LSM:Register("font", "ZillaSlab-Light", "Interface\\AddOns\\ZipTrix\\assets\\ZillaSlab-Light.ttf")
            LSM:Register("font", "ZillaSlab-LightItalic", "Interface\\AddOns\\ZipTrix\\assets\\ZillaSlab-LightItalic.ttf")
            LSM:Register("font", "ZillaSlab-Medium", "Interface\\AddOns\\ZipTrix\\assets\\ZillaSlab-Medium.ttf")
            LSM:Register("font", "ZillaSlab-MediumItalic", "Interface\\AddOns\\ZipTrix\\assets\\ZillaSlab-MediumItalic.ttf")
            LSM:Register("font", "ZillaSlab-Regular", "Interface\\AddOns\\ZipTrix\\assets\\ZillaSlab-Regular.ttf")
            LSM:Register("font", "ZillaSlab-SemiBold", "Interface\\AddOns\\ZipTrix\\assets\\ZillaSlab-SemiBold.ttf")
            LSM:Register("font", "ZillaSlab-SemiBoldItalic", "Interface\\AddOns\\ZipTrix\\assets\\ZillaSlab-SemiBoldItalic.ttf")
            LSM:Register("font", "Epic Fusion", "Interface\\AddOns\\ZipTrix\\assets\\epic-fusion.ttf")
        -- dndFonts
            LSM:Register("font", "Bookinsanity Bold Italic.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Bookinsanity Bold Italic.ttf")
            LSM:Register("font", "Bookinsanity Bold.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Bookinsanity Bold.ttf")
            LSM:Register("font", "Bookinsanity Italic.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Bookinsanity Italic.ttf")
            LSM:Register("font", "Bookinsanity.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Bookinsanity.ttf")
            LSM:Register("font", "Dungeon Drop Case.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Dungeon Drop Case.ttf")
            LSM:Register("font", "Mr Eaves Small Caps.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Mr Eaves Small Caps.ttf")
            LSM:Register("font", "Nodesto Caps Condensed.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Nodesto Caps Condensed.ttf")
            LSM:Register("font", "NodestoCapsCondensed-Bold Italic.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\NodestoCapsCondensed-Bold Italic.ttf")
            LSM:Register("font", "NodestoCapsCondensed-Bold.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\NodestoCapsCondensed-Bold.ttf")
            LSM:Register("font", "NodestoCapsCondensed-Italic.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\NodestoCapsCondensed-Italic.ttf")
            LSM:Register("font", "Scaly Sans Bold Italic.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Scaly Sans Bold Italic.ttf")
            LSM:Register("font", "Scaly Sans Bold.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Scaly Sans Bold.ttf")
            LSM:Register("font", "Scaly Sans Caps Bold Italic.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Scaly Sans Caps Bold Italic.ttf")
            LSM:Register("font", "Scaly Sans Caps Bold.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Scaly Sans Caps Bold.ttf")
            LSM:Register("font", "Scaly Sans Caps Italic.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Scaly Sans Caps Italic.ttf")
            LSM:Register("font", "Scaly Sans Caps.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Scaly Sans Caps.ttf")
            LSM:Register("font", "Scaly Sans Italic.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Scaly Sans Italic.ttf")
            LSM:Register("font", "Scaly Sans.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Scaly Sans.ttf")
            LSM:Register("font", "Solbera Imitation.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Solbera Imitation.ttf")
            LSM:Register("font", "Zatanna Misdirection Bold Italic.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Zatanna Misdirection Bold Italic.ttf")
            LSM:Register("font", "Zatanna Misdirection Bold.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Zatanna Misdirection Bold.ttf")
            LSM:Register("font", "Zatanna Misdirection Italic.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Zatanna Misdirection Italic.ttf")
            LSM:Register("font", "Zatanna Misdirection.ttf", "Interface\\AddOns\\ZipTrix\\assets\\dndFonts\\Zatanna Misdirection.ttf")

            -- ==========================================
            -- Status Bar / Health Bar Textures
            -- ==========================================
            LSM:Register("statusbar", "ztBloodyBg01", "Interface\\AddOns\\ZipTrix\\assets\\ztBloodyBg01.tga")
            LSM:Register("statusbar", "ztBloodyBg02", "Interface\\AddOns\\ZipTrix\\assets\\ztBloodyBg02.tga")
            LSM:Register("statusbar", "ztBloodyBg03", "Interface\\AddOns\\ZipTrix\\assets\\ztBloodyBg03.tga")
            LSM:Register("statusbar", "ztBloodyBg04", "Interface\\AddOns\\ZipTrix\\assets\\ztBloodyBg04.tga")
            LSM:Register("statusbar", "ztWallstone", "Interface\\AddOns\\ZipTrix\\assets\\ztWallstone.tga")
        end

        -- Initialize Teleport Panel
        if ns.InitWorldMapTeleportPanel then
            ns.InitWorldMapTeleportPanel()
        end
        local version, build, date, tocversion = GetBuildInfo()
        print("|cffA330C9ZipTrix|r (v1.0.17) loaded on Client " .. version .. ". Type |cffA330C9/zt|r for options.")
        
        -- Check if Collections is already loaded
        if C_AddOns.IsAddOnLoaded("Blizzard_Collections") then
            InitWardrobeSearch()
            InitTransmogRarity()
        end
    elseif arg1 == "Blizzard_Settings" then
        if SettingsPanel and not SettingsPanel.ZipTrixHooked then
            SettingsPanel.ZipTrixHooked = true
            SettingsPanel:HookScript("OnShow", function()
                if SettingsPanel.ClosePanelButton then ApplyButtonTheme(SettingsPanel.ClosePanelButton) end
                if SettingsPanel.Container and SettingsPanel.Container.SettingsList and SettingsPanel.Container.SettingsList.Footer and SettingsPanel.Container.SettingsList.Footer.DefaultsButton then
                    ApplyButtonTheme(SettingsPanel.Container.SettingsList.Footer.DefaultsButton)
                end
                if SettingsPanel.ApplyButton then ApplyButtonTheme(SettingsPanel.ApplyButton) end
            end)
        end
    elseif arg1 == "AccountPlayed" then
        if ns.InitFrameworxHooks then ns.InitFrameworxHooks() end
    elseif arg1 == "Blizzard_CharacterFrame" then
        InitCharacterPortraitHook()
    elseif arg1 == "Blizzard_Collections" then
        InitWardrobeSearch()
        InitTransmogRarity()
    elseif arg1 == "Blizzard_PlayerSpells" then
        InitTalentFrameHooks()
    elseif event == "PLAYER_LOGIN" then
        InitResourceBarHooks()
        InitUnitFrameHooks()
        InitBagHooks()
        InitDropdownHooks()
        InitBlizzardButtonHooks()
        InitTalentFrameHooks()
        InitCharacterPortraitHook()
        InitDressingRoomHooks()
        InitMaelstromBar()
        CheckGradientRequirements()
        if ns.InitFrameworxHooks then ns.InitFrameworxHooks() end
    elseif event == "PLAYER_LEVEL_UP" or event == "PLAYER_SPECIALIZATION_CHANGED" then
        CheckGradientRequirements()
    end
end)

----------------------------------------------------------------------
-- 2. TOOLTIP LOGIC
----------------------------------------------------------------------

-- A. Positioning Logic
local function UpdateTooltipPosition(self)
    if not ZipTrixDB or not ZipTrixDB.anchorCursor then return end
    
    -- Prevent layout taint errors for tooltips containing widgets (e.g. World Map POIs)
    if self.widgetSetID then return end

    local uiScale = self:GetEffectiveScale()
    if not uiScale or uiScale == 0 then uiScale = 1 end
    local x, y = GetCursorPosition()
    x = x / uiScale
    y = y / uiScale
    local finalX = x + (ZipTrixDB.offsetX or 0)
    local finalY = y + (ZipTrixDB.offsetY or 0)
    self:ClearAllPoints()
    self:SetPoint(ZipTrixDB.anchorPoint or "BOTTOMLEFT", UIParent, "BOTTOMLEFT", finalX, finalY)
end

GameTooltip:HookScript("OnUpdate", function(self, elapsed)
    self.elapsed_accum = (self.elapsed_accum or 0) + (elapsed or 0.05)
    if self.elapsed_accum >= 0.1 then
        self.elapsed_accum = 0
        if ZipTrixDB and ZipTrixDB.anchorCursor and self:GetOwner() then UpdateTooltipPosition(self) end
    end
end)

-- B. Visual & Border Logic
local tooltipBorders = {}

local function ApplyTooltipStyle(tooltip)
    if not ZipTrixDB then return end
    if tooltip.IsForbidden and tooltip:IsForbidden() then return end
    local style = ZipTrixDB.borderStyle or "Blizzard"

    -- 1. Create our custom border frame if it doesn't exist yet
    local border = tooltipBorders[tooltip]
    if not border then
        border = CreateFrame("Frame", nil, tooltip)
        border:SetAllPoints(tooltip)
        border:SetFrameLevel(tooltip:GetFrameLevel()) 
        
        -- Create Background
        border.bg = border:CreateTexture(nil, "BACKGROUND")
        border.bg:SetAllPoints()
        border.bg:SetTexture("Interface\\Buttons\\WHITE8x8")
        
        -- Create Borders (Top, Bottom, Left, Right)
        local function CreateLine() local t = border:CreateTexture(nil, "BORDER"); t:SetTexture("Interface\\Buttons\\WHITE8x8"); return t end
        border.top = CreateLine()
        border.top:SetPoint("TOPLEFT"); border.top:SetPoint("TOPRIGHT"); border.top:SetHeight(1)
        border.bottom = CreateLine()
        border.bottom:SetPoint("BOTTOMLEFT"); border.bottom:SetPoint("BOTTOMRIGHT"); border.bottom:SetHeight(1)
        border.left = CreateLine()
        border.left:SetPoint("TOPLEFT"); border.left:SetPoint("BOTTOMLEFT"); border.left:SetWidth(1)
        border.right = CreateLine()
        border.right:SetPoint("TOPRIGHT"); border.right:SetPoint("BOTTOMRIGHT"); border.right:SetWidth(1)
        
        tooltipBorders[tooltip] = border
    end

    -- 2. Logic: Blizzard vs Custom
    if style == "Blizzard" then
        -- Restore Default
        border:Hide()
        if tooltip.NineSlice then
            for _, region in ipairs({tooltip.NineSlice:GetRegions()}) do
                if region:IsObjectType("Texture") then region:SetAlpha(1) end
            end
        end
        -- We don't touch the backdrop color in Blizzard mode, letting the game handle it
    else
        -- Apply Custom Look
        border:Show()
        if tooltip.NineSlice then
            for _, region in ipairs({tooltip.NineSlice:GetRegions()}) do
                if region:IsObjectType("Texture") then region:SetAlpha(0) end
            end
        end

        -- Set Background (Deep Dark)
        border.bg:SetVertexColor(0.05, 0.05, 0.05, 0.9)

        -- Determine Border Color
        local r, g, b = 0, 0, 0
        if style == "Dark" then
            -- Sharp Black/Dark Gray
            r, g, b = 0.1, 0.1, 0.1
        elseif style == "Expansion" then
            -- Neon Purple
            r, g, b = 0.6, 0.2, 1.0
        elseif style == "Class" then
            -- Get Player Class Color
            local _, classFilename = UnitClass("player")
            local color = C_ClassColor.GetClassColor(classFilename)
            if color then r, g, b = color.r, color.g, color.b end
        end
        border.top:SetVertexColor(r, g, b, 1)
        border.bottom:SetVertexColor(r, g, b, 1)
        border.left:SetVertexColor(r, g, b, 1)
        border.right:SetVertexColor(r, g, b, 1)
    end
end

-- Process tooltips using the modern TooltipDataProcessor API
local function ProcessTooltipPostCall(tooltip)
    if not ZipTrixDB then return end
    if tooltip.IsForbidden and tooltip:IsForbidden() then return end
    if tooltip == GameTooltip and ZipTrixDB.hideInCombat and InCombatLockdown() then
        tooltip:Hide()
        return
    end
    ApplyTooltipStyle(tooltip)
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
    for _, dataType in pairs(Enum.TooltipDataType) do
        TooltipDataProcessor.AddTooltipPostCall(dataType, ProcessTooltipPostCall)
    end
else
    -- Fallback for older clients
    GameTooltip:HookScript("OnShow", function(self)
        if not ZipTrixDB then return end
        if self.IsForbidden and self:IsForbidden() then return end
        if ZipTrixDB.hideInCombat and InCombatLockdown() then self:Hide() end
        ApplyTooltipStyle(self)
    end)
    if SharedTooltip_SetBackdropStyle then
        hooksecurefunc("SharedTooltip_SetBackdropStyle", function(self)
            if self.IsForbidden and self:IsForbidden() then return end
            if self == GameTooltip then
                ApplyTooltipStyle(self)
            end
        end)
    end
end

InitDropdownHooks = function()
    for i = 1, 5 do
        local menu = _G["DropDownList"..i]
        if menu then
            menu:HookScript("OnShow", ApplyTooltipStyle)
        end
        local libMenu = _G["L_DropDownList"..i]
        if libMenu then
            libMenu:HookScript("OnShow", ApplyTooltipStyle)
        end
    end
end

-- C. Health Bar Logic
local function OnTooltipSetUnit(tooltip)
    if ZipTrixDB and ZipTrixDB.hideHealthBar then
        if tooltip.StatusBar then tooltip.StatusBar:Hide()
        elseif _G["GameTooltipStatusBar"] then _G["GameTooltipStatusBar"]:Hide() end
    end
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, OnTooltipSetUnit)
else
    hooksecurefunc(GameTooltip, "SetUnit", function(self) OnTooltipSetUnit(self) end)
end

-- D. ID Logic (Item/Spell)
local function OnTooltipSetItem(tooltip, data)
    if not ZipTrixDB or not ZipTrixDB.showItemID then return end
    local id = data and data.id
    if not id then
        local _, link = tooltip:GetItem()
        if link then id = C_Item.GetItemInfoInstant(link) end
    end
    if id then
        local right = _G[tooltip:GetName() .. "TextRight1"]
        if right then
            right:SetFontObject(GameTooltipText)
            right:SetText("|cff808080ID: " .. id .. "|r")
            right:Show()
        end
    end
end

local function OnTooltipSetSpell(tooltip, data)
    if not ZipTrixDB then return end
    
    local id = data and data.id
    if not id then
        local _, spellID = tooltip:GetSpell()
        id = spellID
    end

    if ZipTrixDB.showSpellID and id then
        local right = _G[tooltip:GetName() .. "TextRight1"]
        if right then
            right:SetFontObject(GameTooltipText)
            right:SetText("|cff808080ID: " .. id .. "|r")
            right:Show()
        end
    end
end

if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, OnTooltipSetItem)
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, OnTooltipSetSpell)
else
    hooksecurefunc(GameTooltip, "SetItem", function(self) OnTooltipSetItem(self) end)
    hooksecurefunc(GameTooltip, "SetSpell", function(self) OnTooltipSetSpell(self) end)
end

----------------------------------------------------------------------
-- H. Unit Frame Gradient Logic
----------------------------------------------------------------------
local minColor = CreateColor(0, 0, 0, 1)
local maxColor = CreateColor(0, 0, 0, 1)

local function UpdateZiptrixGradient(statusbar, unit)
    -- 1. Safety Checks
    if not unit or not statusbar then return end
    if not statusbar:IsVisible() then return end
    
    -- 2. Check User Preference
    if not ZipTrixDB or not ZipTrixDB.enableSpecGradient or not gradientsAvailable then return end

    -- 3. Respect Status (Dead/Disconnected/Tapped)
    if UnitIsDeadOrGhost(unit) or not UnitIsConnected(unit) or UnitIsTapDenied(unit) then
        return
    end
    
    -- 4. Determine Colors
    local cR, cG, cB, sR, sG, sB
    
    -- Get Left Side (Class Color) - Overrides default green
    local _, classFile = UnitClass(unit)
    local classColor = classFile and C_ClassColor.GetClassColor(classFile)
    if classColor then
        cR, cG, cB = classColor.r, classColor.g, classColor.b
    else
        cR, cG, cB = 0.5, 0.5, 0.5
    end

    -- Get Right Side (Spec Color for Player, Darker Class for others)
    if unit == "player" then
        sR, sG, sB = playerSpecR, playerSpecG, playerSpecB
    else
        sR, sG, sB = cR * 0.5, cG * 0.5, cB * 0.5
    end

    -- 5. Apply the Gradient
    local texture = statusbar:GetStatusBarTexture()
    local texPath = texture and texture:GetTexture()
    local isBloody = type(texPath) == "string" and string.match(string.lower(texPath), "ztbloodybg")

    if isBloody then
        -- Calculation magic: The texture is naturally red and black. 
        -- If we apply full class colors (like blue or green) to a red texture, it turns black/invisible.
        -- To maintain the bloody colorway, we calculate a luma value to apply a subtle class-themed tint
        -- while preserving the strong red base.
        local cLuma = 0.2126 * cR + 0.7152 * cG + 0.0722 * cB
        local sLuma = 0.2126 * sR + 0.7152 * sG + 0.0722 * sB
        
        -- We keep the red channel dominant (mixed with white) and let green/blue follow luma for a subtle tint
        local blendR_c = 1 - ((1 - cR) * 0.3)
        local blendR_s = 1 - ((1 - sR) * 0.3)
        
        minColor:SetRGBA(blendR_c, cLuma * 0.6, cLuma * 0.6, 1)
        maxColor:SetRGBA(blendR_s, sLuma * 0.6, sLuma * 0.6, 1)
        
        texture:SetGradient("HORIZONTAL", minColor, maxColor)
    else
        -- Force a flat white texture to ensure colors are pure (fixes "green tint" on default textures)
        statusbar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")
        texture = statusbar:GetStatusBarTexture()
        if texture then
            -- Apply smooth gradient from Class Color (Left) to Spec Color (Right)
            minColor:SetRGBA(cR, cG, cB, 1)
            maxColor:SetRGBA(sR, sG, sB, 1)
            texture:SetGradient("HORIZONTAL", minColor, maxColor)
        end
    end
end

local playerOverlay
local targetOverlay

function ns.UpdateUnitFrameOverlay()
    if not ZipTrixDB then return end
    
    if ZipTrixDB.enableUnitFrameOverlay then
        if not playerOverlay and ElvUF_Player then
            playerOverlay = ElvUF_Player:CreateTexture("ZipTrixPlayerOverlay", "OVERLAY")
            playerOverlay:SetTexture("Interface\\AddOns\\ZipTrix\\assets\\FrameBorderUlraHD03.tga")
            playerOverlay:SetPoint("TOPLEFT", ElvUF_Player, "TOPLEFT", -20, 20)
            playerOverlay:SetPoint("BOTTOMRIGHT", ElvUF_Player, "BOTTOMRIGHT", 20, -20)
        end
        if playerOverlay then playerOverlay:Show() end

        if not targetOverlay and ElvUF_Target then
            targetOverlay = ElvUF_Target:CreateTexture("ZipTrixTargetOverlay", "OVERLAY")
            targetOverlay:SetTexture("Interface\\AddOns\\ZipTrix\\assets\\FrameBorderUlraHD03.tga")
            targetOverlay:SetTexCoord(1, 0, 0, 1) -- Horizontally invert
            targetOverlay:SetPoint("TOPLEFT", ElvUF_Target, "TOPLEFT", -20, 20)
            targetOverlay:SetPoint("BOTTOMRIGHT", ElvUF_Target, "BOTTOMRIGHT", 20, -20)
        end
        if targetOverlay then targetOverlay:Show() end
    else
        if playerOverlay then playerOverlay:Hide() end
        if targetOverlay then targetOverlay:Hide() end
    end
end

InitUnitFrameHooks = function()
    hooksecurefunc("UnitFrameHealthBar_Update", UpdateZiptrixGradient)

    -- Hook for Party/Raid Frames (CompactUnitFrames)
    if CompactUnitFrame_UpdateHealthColor then
        hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(frame)
            if frame and not frame:IsForbidden() and frame.healthBar and frame.displayedUnit then
                UpdateZiptrixGradient(frame.healthBar, frame.displayedUnit)
            end
        end)
    end

    if ns.UpdateUnitFrameOverlay then
        -- Delay slightly to ensure ElvUI frames have populated if ZipTrix loads first
        C_Timer.After(1, function()
            ns.UpdateUnitFrameOverlay()
            if _G.ElvUI then
                hooksecurefunc(_G.ElvUI[1], "UpdateUnitFrames", function() ns.UpdateUnitFrameOverlay() end)
            end
        end)
    end
end

----------------------------------------------------------------------
-- I. Shaman Maelstrom Bar
----------------------------------------------------------------------
local maelstromFrame = nil

local function UpdateMaelstromBar()
    if not maelstromFrame then return end
    if not ZipTrixDB.shamanMaelstromBar then 
        maelstromFrame:Hide()
        return 
    end
    maelstromFrame:Show()

    local count = 0
    local aura = C_UnitAuras.GetPlayerAuraBySpellID(344179) -- Maelstrom Weapon Buff
    if aura then count = aura.applications end

    for i = 1, 10 do
        if i <= count then
            maelstromFrame.points[i]:SetVertexColor(0.2, 0.6, 1, 1) -- Electric Blue
            maelstromFrame.points[i]:SetAlpha(1)
        else
            maelstromFrame.points[i]:SetVertexColor(0.2, 0.2, 0.2, 1) -- Empty Gray
            maelstromFrame.points[i]:SetAlpha(0.3)
        end
    end

    if count >= 10 then
        if not maelstromFrame.isFull then
            maelstromFrame.isFull = true
            if maelstromFrame.lightning then maelstromFrame.lightning:Show() end
        end
    else
        if maelstromFrame.isFull then
            maelstromFrame.isFull = false
            if maelstromFrame.lightning then maelstromFrame.lightning:Hide() end
        end
    end
end

InitMaelstromBar = function()
    local _, class = UnitClass("player")
    if class ~= "SHAMAN" or maelstromFrame then return end

    maelstromFrame = CreateFrame("Frame", nil, UIParent)
    maelstromFrame:SetSize(ZipTrixDB.maelstromBarWidth, ZipTrixDB.maelstromBarHeight)
    maelstromFrame:SetPoint(ZipTrixDB.maelstromBarPoint, UIParent, ZipTrixDB.maelstromBarPoint, ZipTrixDB.maelstromBarX, ZipTrixDB.maelstromBarY)
    maelstromFrame:SetFrameStrata("LOW")
    maelstromFrame:SetMovable(true)
    maelstromFrame:SetResizable(true)
    maelstromFrame:SetResizeBounds(100, 10, 600, 100)
    maelstromFrame:EnableMouse(true)
    
    maelstromFrame:SetScript("OnMouseDown", function(self, button)
        if IsShiftKeyDown() then
            if button == "LeftButton" then
                self:StartMoving()
                self.isMoving = true
            elseif button == "RightButton" then
                self:StartSizing()
                self.isSizing = true
            end
        end
    end)
    
    maelstromFrame:SetScript("OnMouseUp", function(self, button)
        if self.isMoving then
            self:StopMovingOrSizing()
            self.isMoving = false
            local point, _, _, x, y = self:GetPoint()
            ZipTrixDB.maelstromBarPoint = point
            ZipTrixDB.maelstromBarX = x
            ZipTrixDB.maelstromBarY = y
        elseif self.isSizing then
            self:StopMovingOrSizing()
            self.isSizing = false
            -- Snap to 5px
            local w, h = self:GetSize()
            w = math.floor(w / 5 + 0.5) * 5
            h = math.floor(h / 5 + 0.5) * 5
            self:SetSize(w, h)
            ZipTrixDB.maelstromBarWidth = w
            ZipTrixDB.maelstromBarHeight = h
        end
    end)

    -- Add a background so we can see the frame bounds
    local bg = maelstromFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.5)
    maelstromFrame.bg = bg

    -- Lightning Effect for 10 stacks
    local lightning = maelstromFrame:CreateTexture(nil, "OVERLAY")
    lightning:SetAllPoints()
    lightning:SetTexture("Interface\\WorldMap\\WorldMap-QuestArea-Highlight")
    lightning:SetTexCoord(0, 1, 0, 1)
    lightning:SetBlendMode("ADD")
    lightning:SetVertexColor(0.6, 0.9, 1, 0.6) -- Electric Blue
    lightning:Hide()
    maelstromFrame.lightning = lightning

    maelstromFrame:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed_accum = (self.elapsed_accum or 0) + elapsed
        if self.elapsed_accum >= 0.1 then
            self.elapsed_accum = 0
            if self.isFull and self.lightning then
                local scroll = (self.scroll or 0) - (elapsed * 0.8)
                if scroll < 0 then scroll = scroll + 1 end
                self.scroll = scroll
                self.lightning:SetTexCoord(scroll, scroll + 1, 0, 1)
            end
        end
    end)

    maelstromFrame.points = {}
    for i = 1, 10 do
        local t = maelstromFrame:CreateTexture(nil, "ARTWORK")
        t:SetTexture("Interface\\Buttons\\WHITE8x8")
        maelstromFrame.points[i] = t
    end

    -- Resize logic for points
    maelstromFrame:SetScript("OnSizeChanged", function(self, width, height)
        local num = 10
        local gap = 2
        local pointW = (width - (gap * (num - 1))) / num
        if pointW < 1 then pointW = 1 end
        
        for i = 1, num do
            local t = self.points[i]
            if t then
                t:SetSize(pointW, height)
                t:SetPoint("LEFT", (i-1)*(pointW+gap), 0)
            end
        end
    end)
    
    -- Trigger initial layout
    maelstromFrame:GetScript("OnSizeChanged")(maelstromFrame, maelstromFrame:GetSize())

    maelstromFrame:RegisterUnitEvent("UNIT_AURA", "player")
    maelstromFrame:RegisterEvent("PLAYER_ENTERING_WORLD") -- Ensure update on zone in
    maelstromFrame:SetScript("OnEvent", UpdateMaelstromBar)
    
    -- Hook to hide default spell alert
    if SpellActivationOverlayFrame then
        hooksecurefunc(SpellActivationOverlayFrame, "ShowOverlay", function(self, spellID, texturePath)
            if ZipTrixDB and ZipTrixDB.shamanMaelstromBar then
                local isMaelstrom = (spellID == 344179)
                
                if not isMaelstrom and texturePath and type(texturePath) == "string" then
                    local lowerPath = texturePath:lower()
                    if lowerPath:find("maelstrom") or lowerPath:find("lightning") then
                        isMaelstrom = true
                    end
                end

                if not isMaelstrom and spellID then
                    local info = C_Spell.GetSpellInfo(spellID)
                    if info and info.name == "Maelstrom Weapon" then
                        isMaelstrom = true
                    end
                end

                if isMaelstrom then
                    self:HideOverlays(spellID)
                end
            end
        end)
    end

    UpdateMaelstromBar()
end

----------------------------------------------------------------------
-- 3. THE "MIDNIGHT" GUI V2
----------------------------------------------------------------------
local headerFont = "Interface\\AddOns\\ZipTrix\\assets\\SFAtarianSystem.ttf"

local gui = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
gui:SetSize(600, 520)
gui:SetPoint("CENTER")
gui:SetFrameStrata("HIGH")
gui:EnableMouse(true)
gui:SetMovable(true)
gui:RegisterForDrag("LeftButton")
gui:SetScript("OnDragStart", gui.StartMoving)
gui:SetScript("OnDragStop", gui.StopMovingOrSizing)
gui:Hide()

gui:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 2,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
})
gui:SetBackdropColor(0.03, 0.01, 0.05, 0.98) 
gui:SetBackdropBorderColor(0.5, 0.1, 0.9, 1)

local titleIcon = gui:CreateTexture(nil, "OVERLAY")
titleIcon:SetSize(20, 20)
titleIcon:SetPoint("TOPLEFT", 15, -15)
titleIcon:SetTexture("Interface\\Icons\\Ability_Rogue_TricksOfTheTrade") 

local title = gui:CreateFontString(nil, "OVERLAY")
title:SetFont(headerFont, 24, "OUTLINE")
title:SetPoint("LEFT", titleIcon, "RIGHT", 8, 0)
title:SetText("|cffA330C9ZipTrix|r")

local closeBtn = CreateFrame("Button", nil, gui, "UIPanelCloseButton")
closeBtn:SetPoint("TOPRIGHT", -5, -5)

local sidebar = CreateFrame("Frame", nil, gui, "BackdropTemplate")
sidebar:SetSize(150, 460)
sidebar:SetPoint("TOPLEFT", 10, -50)
sidebar:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})
sidebar:SetBackdropColor(0.05, 0.02, 0.1, 0.8) 
sidebar:SetBackdropBorderColor(0.3, 0.1, 0.5, 0.5)

local content = CreateFrame("Frame", nil, gui)
content:SetSize(420, 460)
content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 10, 0)

local pageChar = CreateFrame("Frame", nil, content)
pageChar:SetAllPoints()
pageChar:Hide()
local pageMap = CreateFrame("Frame", nil, content)
pageMap:SetAllPoints()
pageMap:Hide()
local pageInterface = CreateFrame("Frame", nil, content)
pageInterface:SetAllPoints()
pageInterface:Hide()
local pageTwilight = CreateFrame("Frame", nil, content)
pageTwilight:SetAllPoints()
pageTwilight:Hide()
local pageLootz = CreateFrame("Frame", nil, content)
pageLootz:SetAllPoints()
pageLootz:Hide()
local pageAbout = CreateFrame("Frame", nil, content)
pageAbout:SetAllPoints()
pageAbout:Hide()

----------------------------------------------------------------------
-- CUSTOM UI HELPERS
----------------------------------------------------------------------
local themedButtons = {}
local function ApplyFrameTheme()
    if not ZipTrixDB then return end
    local style = ZipTrixDB.interfaceButtonStyle or "Expansion"
    local enabled = ZipTrixDB.interfaceThemeEnabled
    
    local r, g, b = 0.5, 0.1, 0.9 -- Default Purple
    
    if enabled then
        if style == "Dark" then
            r, g, b = 0.1, 0.1, 0.1
        elseif style == "Expansion" then
            r, g, b = 0.5, 0.1, 0.9
        elseif style == "Class" then
            local _, classFilename = UnitClass("player")
            local c = C_ClassColor.GetClassColor(classFilename)
            if c then r, g, b = c.r, c.g, c.b end
        elseif style == "Blizzard" then
            r, g, b = 0.8, 0.2, 0.2
        end
    end
    
    if gui then gui:SetBackdropBorderColor(r, g, b, 1) end
    if sidebar then sidebar:SetBackdropBorderColor(r * 0.7, g * 0.7, b * 0.7, 0.8) end

    -- Frameworx: Apply style to supported external frames
    if ZipTrixDB.enableFrameworx then
        local apFrame = _G["AccountPlayedPopup"]
        if apFrame then
            apFrame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
                insets = { left = 0, right = 0, top = 0, bottom = 0 }
            })
            apFrame:SetBackdropColor(0.03, 0.01, 0.05, 0.98)
            apFrame:SetBackdropBorderColor(r, g, b, 1)
        end
    end
end

if gui then gui:HookScript("OnShow", ApplyFrameTheme) end

ApplyButtonTheme = function(btn)
    if not ZipTrixDB then return end
    local enabled = ZipTrixDB.interfaceThemeEnabled
    local style = ZipTrixDB.interfaceButtonStyle or "Expansion"

    if enabled then
        -- Hide Blizzard Textures
        if btn.Left then btn.Left:Hide() end
        if btn.Right then btn.Right:Hide() end
        if btn.Middle then btn.Middle:Hide() end
        
        if not btn.SetBackdrop then
            Mixin(btn, BackdropTemplateMixin)
        end

        -- Apply Custom Backdrop
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })

        local r, g, b = 0.2, 0.2, 0.2
        local br, bg, bb = 0, 0, 0

        if style == "Dark" then
            r, g, b = 0.1, 0.1, 0.1
            br, bg, bb = 0, 0, 0
        elseif style == "Expansion" then
            r, g, b = 0.2, 0.05, 0.3
            br, bg, bb = 0.4, 0.1, 0.6
        elseif style == "Class" then
            local _, classFilename = UnitClass("player")
            local c = C_ClassColor.GetClassColor(classFilename)
            if c then 
                r, g, b = c.r * 0.3, c.g * 0.3, c.b * 0.3
                br, bg, bb = c.r, c.g, c.b
            end
        elseif style == "Blizzard Dark" then
            r, g, b = 0.15, 0.15, 0.15
            br, bg, bb = 0.3, 0.3, 0.3
        elseif style == "Blizzard" then
            -- Flat Red style if they want "Blizzard" color but flat theme
            r, g, b = 0.5, 0.1, 0.1
            br, bg, bb = 0.8, 0.2, 0.2
        end

        btn:SetBackdropColor(r, g, b, 1)
        btn:SetBackdropBorderColor(br, bg, bb, 1)
        
        -- Hook OnEnter/OnLeave for hover effects in custom mode
        if not btn.hoverHooked then
            btn:HookScript("OnEnter", function(self)
                if ZipTrixDB.interfaceThemeEnabled then
                    local cr, cg, cb = self:GetBackdropColor()
                    self:SetBackdropColor(math.min(cr+0.1, 1), math.min(cg+0.1, 1), math.min(cb+0.1, 1), 1)
                    self:SetBackdropBorderColor(0.6, 0.2, 1.0, 1)
                end
            end)
            btn:HookScript("OnLeave", function(self)
                if ZipTrixDB.interfaceThemeEnabled then
                    ApplyButtonTheme(self) -- Re-apply base color
                end
            end)
            btn.hoverHooked = true
        end
    else
        -- Restore Blizzard Textures
        if btn.Left then btn.Left:Show() end
        if btn.Right then btn.Right:Show() end
        if btn.Middle then btn.Middle:Show() end
        btn:SetBackdrop(nil)
    end
end

local function UpdateAllButtons()
    for _, btn in ipairs(themedButtons) do
        ApplyButtonTheme(btn)
    end
end

local function CreateThemedButton(parent, text, width, height)
    local btn = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate, BackdropTemplate")
    btn:SetSize(width, height)
    btn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    local bgColor = {r = 0.2, g = 0.05, b = 0.3, a = 1}
    local borderColor = {r = 0.4, g = 0.1, b = 0.6, a = 1}
    btn:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
    btn:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    btn:SetNormalFontObject("GameFontNormal")
    btn:SetHighlightFontObject("GameFontHighlight")
    btn:SetText(text)
    btn:SetScript("OnEnter", function(self)
         self:SetBackdropColor(0.3, 0.1, 0.5, 1)
         self:SetBackdropBorderColor(0.6, 0.2, 1.0, 1)
    end)
    btn:SetScript("OnLeave", function(self)
         self:SetBackdropColor(bgColor.r, bgColor.g, bgColor.b, bgColor.a)
         self:SetBackdropBorderColor(borderColor.r, borderColor.g, borderColor.b, borderColor.a)
    end)
    
    table.insert(themedButtons, btn)
    -- Apply initial theme (deferred slightly to ensure DB is ready if called early)
    if ZipTrixDB then ApplyButtonTheme(btn) end
    btn:HookScript("OnShow", function() ApplyButtonTheme(btn) end)
    
    return btn
end
ns.CreateThemedButton = CreateThemedButton

local function CreateSliderWithEditBox(parent, key, label, minVal, maxVal, xOffset, yOffset, subTableKey)
    local name = "ZipTrixSlider_" .. key
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", xOffset, yOffset)
    slider:SetWidth(130) -- Shrink slider slightly to make room for box
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)

    -- Labels
    local labelText = _G[name.."Text"]
    local lowText = _G[name.."Low"]
    local highText = _G[name.."High"]
    
    labelText:SetTextColor(0.8, 0.5, 1.0)
    lowText:SetTextColor(0.5, 0.3, 0.7)
    highText:SetTextColor(0.5, 0.3, 0.7)
    
    labelText:SetText(label)
    lowText:SetText(minVal)
    highText:SetText(maxVal)

    -- THE EDIT BOX (Input)
    local editBox = CreateFrame("EditBox", nil, slider, "InputBoxTemplate")
    editBox:SetSize(40, 20)
    editBox:SetPoint("LEFT", slider, "RIGHT", 15, 0)
    editBox:SetAutoFocus(false)
    editBox:SetJustifyH("CENTER")

    -- LOGIC: Slider Updates -> DB & EditBox
    slider:SetScript("OnValueChanged", function(self, value)
        if not ZipTrixDB then return end
        local db = ZipTrixDB
        if subTableKey then
            db[subTableKey] = db[subTableKey] or {}
            db = db[subTableKey]
        end
        local val = math.floor(value + 0.5)
        
        -- Update DB
        db[key] = val
        -- Update EditBox text (avoid loop if user typed it)
        if not editBox:HasFocus() then
            editBox:SetText(val)
        end
    end)

    -- LOGIC: EditBox Updates -> DB & Slider
    editBox:SetScript("OnEnterPressed", function(self)
        local val = tonumber(self:GetText())
        if val then
            -- Clamp value between min and max
            val = math.max(minVal, math.min(maxVal, math.floor(val)))
            self:SetText(val) -- Fix text if clamped
            local db = ZipTrixDB
            if subTableKey then
                db[subTableKey] = db[subTableKey] or {}
                db = db[subTableKey]
            end
            db[key] = val
            slider:SetValue(val) -- Move slider visual
        end
        self:ClearFocus()
    end)

    -- LOGIC: Sync on Show (Fixes the "Not showing saved value" bug)
    slider:SetScript("OnShow", function(self)
        if not ZipTrixDB then return end
        local db = ZipTrixDB
        if subTableKey and db[subTableKey] then db = db[subTableKey] end
        
        if db and db[key] then
            local val = db[key]
            self:SetValue(val)
            editBox:SetText(val)
        end
    end)
end
ns.CreateSliderWithEditBox = CreateSliderWithEditBox

local function CreateToggleSwitch(parent, key, label, xOffset, yOffset, subTableKey)
    local f = CreateFrame("Button", nil, parent, "BackdropTemplate")
    f:SetSize(40, 20)
    f:SetPoint("TOPLEFT", xOffset, yOffset)
    
    -- Label
    f.text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    f.text:SetPoint("LEFT", f, "RIGHT", 10, 0)
    f.text:SetText(label)
    f.text:SetTextColor(0.9, 0.9, 1)

    -- Thumb (Indicator)
    f.Thumb = f:CreateTexture(nil, "ARTWORK")
    f.Thumb:SetSize(16, 16)
    f.Thumb:SetTexture("Interface\\Buttons\\WHITE8x8")
    
    local function UpdateVisuals()
        if not ZipTrixDB then return end
        local db = ZipTrixDB
        if subTableKey and db[subTableKey] then db = db[subTableKey] end
        local checked = db[key]
        if checked then
            f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1})
            f:SetBackdropColor(0.2, 0.8, 0.2, 1) -- Green
            f:SetBackdropBorderColor(0, 0, 0, 1)
            f.Thumb:ClearAllPoints()
            f.Thumb:SetPoint("RIGHT", -2, 0)
            f.Thumb:SetVertexColor(1, 1, 1)
        else
            f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1})
            f:SetBackdropColor(0.3, 0.3, 0.3, 1) -- Gray
            f:SetBackdropBorderColor(0, 0, 0, 1)
            f.Thumb:ClearAllPoints()
            f.Thumb:SetPoint("LEFT", 2, 0)
            f.Thumb:SetVertexColor(0.8, 0.8, 0.8)
        end
    end

    f:SetScript("OnEnter", function(self)
        -- Highlight: Purple glow to match themed buttons
        self:SetBackdropBorderColor(0.6, 0.2, 1.0, 1)
        
        if self.tooltipText then
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
            GameTooltip:Show()
        end
    end)

    f:SetScript("OnLeave", function(self)
        UpdateVisuals()
        GameTooltip:Hide()
    end)

    f:SetScript("OnClick", function()
        if ZipTrixDB then 
            local db = ZipTrixDB
            if subTableKey then
                db[subTableKey] = db[subTableKey] or {}
                db = db[subTableKey]
            end
            db[key] = not db[key] 
            if ns.RefreshWorldMapTeleportPanel then ns.RefreshWorldMapTeleportPanel() end
            UpdateVisuals()
        end
    end)
    
    f:SetScript("OnShow", UpdateVisuals)
    
    -- Initial update
    if ZipTrixDB then UpdateVisuals() end

    return f
end
ns.CreateToggleSwitch = CreateToggleSwitch

-- Frameworx Initialization
ns.InitFrameworxHooks = function()
    if SlashCmdList["ACCOUNTPLAYEDPOPUP"] then
        hooksecurefunc(SlashCmdList, "ACCOUNTPLAYEDPOPUP", function()
            C_Timer.After(0.05, ApplyFrameTheme)
        end)
    end
end

----------------------------------------------------------------------
-- BUILD THE PAGES
----------------------------------------------------------------------
-- 2. Character Page
local charHeader = pageChar:CreateFontString(nil, "OVERLAY")
charHeader:SetFont(headerFont, 16, "OUTLINE")
charHeader:SetPoint("TOPLEFT", 0, 0)
charHeader:SetText(L.CHAR_HEADER)
charHeader:SetTextColor(0.8, 0.4, 1.0)

local cbPortrait = CreateToggleSwitch(pageChar, "characterPortraitEnabled", L.ENABLE_PORTRAIT, 10, -40)
local portraitBtn = CreateThemedButton(pageChar, L.PORTRAIT_STYLE, 160, 25)
portraitBtn:SetPoint("TOPLEFT", 220, -40)

local function UpdatePortraitBtnState()
    if ZipTrixDB.characterPortraitEnabled then
        portraitBtn:Enable()
        portraitBtn:SetAlpha(1)
    else
        portraitBtn:Disable()
        portraitBtn:SetAlpha(0.5)
    end
end

cbPortrait:HookScript("OnClick", function() 
    if CharacterFrame_UpdatePortrait then
        CharacterFrame_UpdatePortrait()
    else
        UpdateZipTrixPortrait()
    end
    UpdatePortraitBtnState()
end)
cbPortrait:HookScript("OnShow", UpdatePortraitBtnState)

cbPortrait:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L.CUSTOM_CHAR_SHEET_TOOLTIP, nil, nil, nil, nil, true)
    GameTooltip:Show()
end)
cbPortrait:HookScript("OnLeave", function(self) GameTooltip:Hide() end)

local function UpdatePortraitBtnText()
    portraitBtn:SetText(L.PORTRAIT_LABEL .. (ZipTrixDB.characterPortraitStyle or "Fabled"))
end
portraitBtn:SetScript("OnShow", function()
    UpdatePortraitBtnText()
    UpdatePortraitBtnState()
end)
portraitBtn:SetScript("OnClick", function()
    local idx = 1
    for i, p in ipairs(portraitStyles) do
        if p == ZipTrixDB.characterPortraitStyle then idx = i; break end
    end
    ZipTrixDB.characterPortraitStyle = portraitStyles[(idx % #portraitStyles) + 1]
    UpdatePortraitBtnText()
    if CharacterFrame_UpdatePortrait then
        CharacterFrame_UpdatePortrait()
    else
        UpdateZipTrixPortrait()
    end
end)

local cleanupBtn = CreateThemedButton(pageChar, L.MACRO_CLEANUP, 160, 25)
cleanupBtn:SetPoint("TOPLEFT", 10, -85)

cleanupBtn:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L.MACRO_CLEANUP_NOTE)
    GameTooltip:Show()
end)
cleanupBtn:HookScript("OnLeave", function(self) GameTooltip:Hide() end)

cleanupBtn:SetScript("OnClick", function()
    if InCombatLockdown() then return end
    local numGlobal, numPerChar = GetNumMacros()
    local seen = {}
    
    -- 1. Index Global Macros (Keep these as the "originals")
    for i = 1, numGlobal do
        local body = GetMacroBody(i)
        if body then seen[body] = true end
    end

    -- 2. Check Character Macros (Iterate backwards to safely delete without shifting indices)
    local deleted = 0
    for i = 120 + numPerChar, 121, -1 do
        local body = GetMacroBody(i)
        if body and seen[body] then
            DeleteMacro(i)
            deleted = deleted + 1
        elseif body then
            seen[body] = true
        end
    end
    print("|cffA330C9ZipTrix|r: Cleanup complete. Removed " .. deleted .. " duplicate macros.")
end)

local trackerCleanupBtn = CreateThemedButton(pageChar, "Tracker Cleanup", 160, 25)
trackerCleanupBtn:SetPoint("TOPLEFT", 180, -85)

trackerCleanupBtn:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Tracker Cleanup", 1, 1, 1)
    GameTooltip:AddLine("Loops through your current quest watch list and untracks all quests.", nil, nil, nil, true)
    GameTooltip:AddLine("Runs a quick sort to refresh the objective tracker UI.", nil, nil, nil, true)
    GameTooltip:AddLine("Loops through any achievements you are tracking and removes them.", nil, nil, nil, true)
    GameTooltip:Show()
end)
trackerCleanupBtn:HookScript("OnLeave", function(self) GameTooltip:Hide() end)

trackerCleanupBtn:SetScript("OnClick", function()
    for i=C_QuestLog.GetNumQuestWatches(), 1, -1 do C_QuestLog.RemoveQuestWatch(C_QuestLog.GetQuestIDForQuestWatchIndex(i)) end C_QuestLog.SortQuestWatches()
    if C_ContentTracking and C_ContentTracking.GetTrackedIDs then
        local tracked = C_ContentTracking.GetTrackedIDs(Enum.ContentTrackingType.Achievement)
        for _, id in ipairs(tracked) do
            C_ContentTracking.StopTracking(Enum.ContentTrackingType.Achievement, id, Enum.ContentTrackingStopType.Manual)
        end
    elseif GetNumTrackedAchievements then
        for i=1,GetNumTrackedAchievements() do RemoveTrackedAchievement(GetTrackedAchievement(1)) end
    end
end)

local charSpacer = pageChar:CreateTexture(nil, "ARTWORK")
charSpacer:SetSize(400, 1)
charSpacer:SetPoint("TOPLEFT", 10, -115)
charSpacer:SetColorTexture(1, 1, 1, 0.2)

local function CreateAndPlaceMacro(macroName, iconID, body, strict)
    if InCombatLockdown() then 
        print("|cffA330C9ZipTrix|r: Cannot create macro in combat.") 
        return 
    end

    local macroIndex = GetMacroIndexByName(macroName)

    -- Strict Mode: If exists, abort completely (do not recreate, do not place)
    if strict and macroIndex > 0 then
        print("|cffA330C9ZipTrix|r: Macro '"..macroName.."' is already available.")
        return
    end
    
    -- 1. Create if missing (Character Specific)
    if macroIndex == 0 then
        macroIndex = CreateMacro(macroName, iconID, body, true) -- true = per-character
        print("|cffA330C9ZipTrix|r: Macro '"..macroName.."' created!")
    end

    -- 2. Check if already on Action Bars
    if macroIndex then
        for i = 1, 120 do
            local type, id = GetActionInfo(i)
            if type == "macro" then
                local name = GetMacroInfo(id)
                if name == macroName then
                    print("|cffA330C9ZipTrix|r: Macro found at Action Button " .. i .. ".")
                    return
                end
            end
        end

        -- 3. Place on first empty slot
        for i = 1, 120 do
            if not GetActionInfo(i) then
                PickupMacro(macroName)
                PlaceAction(i)
                ClearCursor()
                print("|cffA330C9ZipTrix|r: Added to Action Bar slot " .. i .. ".")
                return
            end
        end
        print("|cffA330C9ZipTrix|r: No empty action bar slots found.")
    end
end

local classNameLocal, classFilename = UnitClass("player")
local classColor = C_ClassColor.GetClassColor(classFilename)
local classColorHex = classColor and classColor:GenerateHexColor() or "ffffffff"

local classHeader = pageChar:CreateFontString(nil, "OVERLAY")
classHeader:SetFont(headerFont, 16, "OUTLINE")
classHeader:SetPoint("TOPLEFT", 0, -130)

if classFilename == "PALADIN" then
    classHeader:SetText(L.PALADIN_HEADER)
    classHeader:SetTextColor(0.96, 0.55, 0.73)

    local macroBtn = CreateThemedButton(pageChar, L.CREATE_MACRO, 160, 25)
    macroBtn:SetPoint("TOPLEFT", 10, -160)

    macroBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Creates 'ZipImbue' & adds to Action Bar")
        GameTooltip:Show()
    end)
    macroBtn:HookScript("OnLeave", function(self) GameTooltip:Hide() end)

    macroBtn:SetScript("OnClick", function()
        local macroName = "ZipImbue"
        local body = "#showtooltip\n/cast [known:Rite of Sanctification] Rite of Sanctification; [known:Rite of Adjuration] Rite of Adjuration\n/use 16"
        local icon = 135920 -- Spell_Holy_RighteousnessAura
        CreateAndPlaceMacro(macroName, icon, body)
    end)
elseif classFilename == "SHAMAN" then
    classHeader:SetText(L.SHAMAN_HEADER)
    classHeader:SetTextColor(0.0, 0.44, 0.87) -- Shaman Blue

    local macroBtn = CreateThemedButton(pageChar, "Create Travel Macro", 160, 25)
    macroBtn:SetPoint("TOPLEFT", 10, -160)

    macroBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.MACRO_TRAVEL_TOOLTIP)
        GameTooltip:Show()
    end)
    macroBtn:HookScript("OnLeave", function(self) GameTooltip:Hide() end)

    macroBtn:SetScript("OnClick", function()
        local macroName = "ZipTravel"
        local body = "#showtooltip Ghost Wolf\n/cast [combat] Ghost Wolf\n/cast [indoors] Ghost Wolf\n/run if IsOutdoors() and not IsPlayerMoving() and not IsMounted() then C_MountJournal.SummonByID(0) end\n/cast [nomounted] Ghost Wolf"
        local icon = 136095 -- Spell_Nature_SpiritWolf
        CreateAndPlaceMacro(macroName, icon, body)
    end)

    local utilBtn = CreateThemedButton(pageChar, "Create Utility Macro", 160, 25)
    utilBtn:SetPoint("TOPLEFT", 10, -190)

    utilBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.MACRO_UTILITY_TOOLTIP)
        GameTooltip:Show()
    end)
    utilBtn:HookScript("OnLeave", function(self) GameTooltip:Hide() end)

    utilBtn:SetScript("OnClick", function()
        local macroName = "ZipUtility"
        local body = "#showtooltip\n/cqs\n/stopcasting\n/stopcasting\n/cast [@mouseover,harm,nodead] Hex; [@mouseover,help,nodead] Cleanse Spirit; [harm] Hex; Cleanse Spirit"
        local icon = 136048 -- Spell_Shaman_Hex
        CreateAndPlaceMacro(macroName, icon, body, true) -- strict = true
    end)

    local intBtn = CreateThemedButton(pageChar, "Create Interrupt Macro", 160, 25)
    intBtn:SetPoint("TOPLEFT", 10, -220)

    intBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.MACRO_INTERRUPT_TOOLTIP)
        GameTooltip:Show()
    end)
    intBtn:HookScript("OnLeave", function(self) GameTooltip:Hide() end)

    intBtn:SetScript("OnClick", function()
        local macroName = "ZipInterrupt"
        local body = "#showtooltip\n/cqs\n/stopcasting\n/cast [@mouseover,harm,nodead][] Wind Shear"
        local icon = 136018 -- Spell_Nature_Cyclone
        CreateAndPlaceMacro(macroName, icon, body, true) -- strict = true
    end)

    local cbMaelstrom = CreateToggleSwitch(pageChar, "shamanMaelstromBar", L.SHAMAN_MAELSTROM_BAR, 10, -250)
    cbMaelstrom:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(L.SHAMAN_MAELSTROM_TOOLTIP)
        GameTooltip:Show()
    end)
    cbMaelstrom:HookScript("OnLeave", function(self) GameTooltip:Hide() end)
    cbMaelstrom:HookScript("OnClick", function()
        if not maelstromFrame then InitMaelstromBar() end
        UpdateMaelstromBar()
    end)
elseif classFilename == "WARLOCK" then
    classHeader:SetText("Warlock Options")
    classHeader:SetTextColor(0.53, 0.53, 0.93)

    local macroBtn = CreateThemedButton(pageChar, "Create Felguard Macro", 160, 25)
    macroBtn:SetPoint("TOPLEFT", 10, -160)

    macroBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Creates 'QuickFelguard' macro.\n\nInstantly summons Felguard.")
        GameTooltip:SetText("Creates 'QuickFelguard' macro.\n\nUsed to summon the Felguard quickly should he fall in combat.")
        GameTooltip:Show()
    end)
    macroBtn:HookScript("OnLeave", function(self) GameTooltip:Hide() end)

    macroBtn:SetScript("OnClick", function()
        local macroName = "QuickFelguard"
        local body = "#showtooltip\n/cast Fel Domination\n/cast Summon Felguard\n/cqs"
        local icon = 136216 -- Spell_Shadow_SummonFelGuard
        CreateAndPlaceMacro(macroName, icon, body)
    end)
elseif classFilename == "DEATHKNIGHT" then
    classHeader:SetText("Death Knight Options")
    classHeader:SetTextColor(0.77, 0.12, 0.23)

    local macroBtn = CreateThemedButton(pageChar, "Create Mobility Macro", 160, 25)
    macroBtn:SetPoint("TOPLEFT", 10, -160)

    macroBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Creates 'ZipMobility' macro.\n\nCombat: Acherus Deathcharger\nMoving: Death's Advance\nElse: Random Favorite Mount")
        GameTooltip:Show()
    end)
    macroBtn:HookScript("OnLeave", function(self) GameTooltip:Hide() end)

    macroBtn:SetScript("OnClick", function()
        local macroName = "ZipMobility"
        local body = "#showtooltip Death's Advance\n/cast [combat] Acherus Deathcharger\n/run if not InCombatLockdown() and not IsPlayerMoving() and IsOutdoors() then C_MountJournal.SummonByID(0) end\n/cast Death's Advance"
        local icon = 136149 -- Spell_Shadow_DemonicEmpathy (Death's Advance)
        CreateAndPlaceMacro(macroName, icon, body)
    end)
elseif classFilename == "PRIEST" then
    classHeader:SetText("Priest Options")
    classHeader:SetTextColor(1.0, 1.0, 1.0)

    local macroBtn = CreateThemedButton(pageChar, "Create Feather Macro", 160, 25)
    macroBtn:SetPoint("TOPLEFT", 10, -160)

    macroBtn:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText("Creates 'ZipFeather' macro.\n\nCombat/Indoors: Angelic Feather (@player)\nElse: Random Favorite Mount")
        GameTooltip:Show()
    end)
    macroBtn:HookScript("OnLeave", function(self) GameTooltip:Hide() end)

    macroBtn:SetScript("OnClick", function()
        local macroName = "ZipFeather"
        local body = "#showtooltip Angelic Feather\n/cast [@player,combat][@player,indoors] Angelic Feather\n/run if IsOutdoors() and not InCombatLockdown() then C_MountJournal.SummonByID(0) end"
        local icon = 136053 -- Spell_Holy_AngelicFeather
        CreateAndPlaceMacro(macroName, icon, body)
    end)
else
    classHeader:SetText(classNameLocal .. " Options")
    if classColor then
        classHeader:SetTextColor(classColor.r, classColor.g, classColor.b)
    else
        classHeader:SetTextColor(1, 1, 1)
    end

    local comingSoon = pageChar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    comingSoon:SetPoint("TOPLEFT", 10, -160)
    comingSoon:SetWidth(380)
    comingSoon:SetJustifyH("LEFT")
    comingSoon:SetText("The |c" .. classColorHex .. classNameLocal .. "|r class specific options will be available in the next version.")
end

-- 3. Map Options Page
local mapHeader = pageMap:CreateFontString(nil, "OVERLAY")
mapHeader:SetFont(headerFont, 16, "OUTLINE")
mapHeader:SetPoint("TOPLEFT", 0, 0)
mapHeader:SetText(L.GATEWAY_HEADER)
mapHeader:SetTextColor(0.8, 0.4, 1.0)

local cbEnable = CreateToggleSwitch(pageMap, "teleportsWorldMapEnabled", L.ENABLE_GATEWAYS, 10, -40)
cbEnable.tooltipText = L.ENABLE_GATEWAYS_TOOLTIP
local cbTooltips = CreateToggleSwitch(pageMap, "portalShowTooltip", L.SHOW_GATEWAY_TOOLTIPS, 10, -70)
cbTooltips.tooltipText = L.SHOW_GATEWAY_TOOLTIPS_TOOLTIP
local cbSeason = CreateToggleSwitch(pageMap, "teleportsWorldMapShowSeason", L.SHOW_SEASON, 10, -100)
cbSeason.tooltipText = L.SHOW_SEASON_TOOLTIP
local cbSecrets = CreateToggleSwitch(pageMap, "enableSecretsHelper", L.ENABLE_SECRETS, 10, -130)
cbSecrets.tooltipText = L.ENABLE_SECRETS_TOOLTIP

local bankNote = pageMap:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
bankNote:SetPoint("TOPLEFT", 10, -160)
bankNote:SetText(L.BANK_NOTE)
bankNote:SetTextColor(0.6, 1.0, 0.6)

local function UpdateMapOptionsVisibility()
    local enabled = ZipTrixDB and ZipTrixDB.teleportsWorldMapEnabled
    cbTooltips:SetShown(enabled)
    cbSeason:SetShown(enabled)
    cbSecrets:SetShown(enabled)
end
cbEnable:HookScript("OnClick", UpdateMapOptionsVisibility)
cbEnable:HookScript("OnShow", UpdateMapOptionsVisibility)

-- 4. Interface Page
local interfaceHeader = pageInterface:CreateFontString(nil, "OVERLAY")
interfaceHeader:SetFont(headerFont, 16, "OUTLINE")
interfaceHeader:SetPoint("TOPLEFT", 0, 0)
interfaceHeader:SetText(L.INTERFACE_HEADER)
interfaceHeader:SetTextColor(0.8, 0.4, 1.0)

local cbTheme = CreateToggleSwitch(pageInterface, "interfaceThemeEnabled", L.ENABLE_THEMING, 10, -40)
-- Hook moved below to include btnStyle logic

local cbFrameworx = CreateToggleSwitch(pageInterface, "enableFrameworx", L.ENABLE_FRAMEWORX, 220, -40)
cbFrameworx:HookScript("OnClick", function()
    ApplyFrameTheme()
end)

local cbUnitFrameOverlay = CreateToggleSwitch(pageInterface, "enableUnitFrameOverlay", "UnitFrame Overlay", 220, -70)
cbUnitFrameOverlay:HookScript("OnClick", function() if ns.UpdateUnitFrameOverlay then ns.UpdateUnitFrameOverlay() end end)

local cbGradient = CreateToggleSwitch(pageInterface, "enableSpecGradient", L.ENABLE_GRADIENTS, 10, -70)
cbGradient:SetMotionScriptsWhileDisabled(true)

local function UpdateGradientToggle()
    CheckGradientRequirements() -- Ensure status is fresh
    if not gradientsAvailable then
        cbGradient:Disable()
        cbGradient:SetAlpha(0.5)
        cbGradient.tooltipText = L.GRADIENT_REQ
    else
        cbGradient:Enable()
        cbGradient:SetAlpha(1)
        cbGradient.tooltipText = L.RELOAD_TOOLTIP
    end
end

cbGradient:HookScript("OnShow", UpdateGradientToggle)
cbGradient:RegisterEvent("PLAYER_LEVEL_UP")
cbGradient:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
cbGradient:SetScript("OnEvent", UpdateGradientToggle)

UpdateGradientToggle()

cbGradient:HookScript("OnClick", function(self)
    StaticPopup_Show("ZIPTRIX_RELOAD_UI")
end)

local btnStyle = CreateThemedButton(pageInterface, L.BUTTON_STYLE, 200, 25)
btnStyle:SetPoint("TOPLEFT", 10, -110)

local function UpdateBtnStyleText()
    btnStyle:SetText(L.STYLE_LABEL .. (ZipTrixDB.interfaceButtonStyle or "Expansion"))
end

local function UpdateBtnStyleState()
    if ZipTrixDB.interfaceThemeEnabled then
        btnStyle:Enable()
        btnStyle:SetAlpha(1)
    else
        btnStyle:Disable()
        btnStyle:SetAlpha(0.5)
    end
end

cbTheme:HookScript("OnClick", function() 
    UpdateAllButtons() 
    UpdateBtnStyleState()
    ApplyFrameTheme()
end)

btnStyle:SetScript("OnShow", function()
    UpdateBtnStyleText()
    UpdateBtnStyleState()
end)

btnStyle:SetScript("OnClick", function(self)
    local idx = 1
    for i, p in ipairs(borderStyles) do
        if p == ZipTrixDB.interfaceButtonStyle then idx = i break end
    end
    ZipTrixDB.interfaceButtonStyle = borderStyles[(idx % #borderStyles) + 1]
    UpdateBtnStyleText()
    UpdateAllButtons()
    ApplyFrameTheme()
    if GameTooltip:GetOwner() == self then self:GetScript("OnEnter")(self) end
end)

btnStyle:HookScript("OnEnter", function(self)
    if not ZipTrixDB.interfaceThemeEnabled then return end
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Available Styles")
    
    local current = ZipTrixDB.interfaceButtonStyle
    local r, g, b = 1, 1, 1
    
    if current == "Expansion" then
        r, g, b = 0.6, 0.2, 1.0
    elseif current == "Blizzard" then
        r, g, b = 0.8, 0.2, 0.2
    elseif current == "Class" then
        local _, classFilename = UnitClass("player")
        local c = C_ClassColor.GetClassColor(classFilename)
        if c then r, g, b = c.r, c.g, c.b end
    elseif current == "Blizzard Dark" then
        r, g, b = 0.5, 0.5, 0.5
    elseif current == "Dark" then
        r, g, b = 0.6, 0.6, 0.6
    end

    for _, style in ipairs(borderStyles) do
        if style == current then
            GameTooltip:AddLine(style, r, g, b)
        else
            GameTooltip:AddLine(style, 1, 1, 1)
        end
    end
    GameTooltip:Show()
end)
btnStyle:HookScript("OnLeave", function(self) GameTooltip:Hide() end)

StaticPopupDialogs["ZIPTRIX_UNLOCK_UI"] = {
    text = L.UNLOCK_CONFIRM,
    button1 = YES,
    button2 = CANCEL,
    OnAccept = function()
        if InCombatLockdown() then
            print("|cffA330C9ZipTrix|r: Cannot unlock frames in combat.")
            return
        end
        ShowUIPanel(EditModeManagerFrame)
        if EditModeManagerFrame:IsShown() then
            print("|cffA330C9ZipTrix|r: Interface unlocked successfully.")
        else
            print("|cffA330C9ZipTrix|r: Unlock command executed.")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["ZIPTRIX_RELOAD_UI"] = {
    text = L.RELOAD_CONFIRM,
    button1 = YES,
    button2 = NO,
    OnAccept = function()
        ReloadUI()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["ZIPTRIX_COPY_URL"] = {
    text = "Press Ctrl+C to copy the URL:",
    button1 = OKAY,
    hasEditBox = true,
    editBoxWidth = 350,
    OnShow = function(self, data)
        self.EditBox:SetText(data)
        self.EditBox:SetFocus()
        self.EditBox:HighlightText()
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

local unlockBtn = CreateThemedButton(pageInterface, L.UNLOCK_FRAMES, 200, 25)
unlockBtn:SetPoint("TOPLEFT", 10, -145)
unlockBtn:HookScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText(L.UNLOCK_FRAMES_TOOLTIP, nil, nil, nil, nil, true)
    GameTooltip:Show()
end)
unlockBtn:HookScript("OnLeave", function(self) GameTooltip:Hide() end)
unlockBtn:SetScript("OnClick", function() StaticPopup_Show("ZIPTRIX_UNLOCK_UI") end)

-- Tooltip Section (Moved to Interface Tab)
local tooltipHeader = pageInterface:CreateFontString(nil, "OVERLAY")
tooltipHeader:SetFont(headerFont, 16, "OUTLINE")
tooltipHeader:SetPoint("TOPLEFT", 0, -185)
tooltipHeader:SetText(L.TOOLTIP_HEADER)
tooltipHeader:SetTextColor(0.8, 0.4, 1.0)

CreateToggleSwitch(pageInterface, "hideInCombat", L.HIDE_COMBAT, 10, -215)
CreateToggleSwitch(pageInterface, "hideHealthBar", L.HIDE_HEALTH, 10, -245)
CreateToggleSwitch(pageInterface, "showItemID", L.SHOW_ITEM_ID, 10, -275)
CreateToggleSwitch(pageInterface, "showSpellID", L.SHOW_SPELL_ID, 220, -275)
CreateToggleSwitch(pageInterface, "upgradeClarityEnabled", L.ENABLE_UPGRADE_CLARITY, 10, -305)
CreateToggleSwitch(pageInterface, "upgradeClarityShowSources", L.SHOW_SOURCES, 220, -305)

CreateToggleSwitch(pageInterface, "anchorCursor", L.ANCHOR_CURSOR, 10, -345)

-- BUTTON 1: ANCHOR POINT
local anchorBtn = CreateThemedButton(pageInterface, L.ANCHOR_POINT, 200, 25)
anchorBtn:SetPoint("TOPLEFT", 10, -375)
local function UpdateAnchorText()
    anchorBtn:SetText(L.ANCHOR_LABEL .. (ZipTrixDB.anchorPoint or "BOTTOMLEFT"))
end
anchorBtn:SetScript("OnShow", UpdateAnchorText)
anchorBtn:SetScript("OnClick", function()
    local idx = 1
    for i, p in ipairs(anchorPoints) do
        if p == ZipTrixDB.anchorPoint then idx = i break end
    end
    ZipTrixDB.anchorPoint = anchorPoints[(idx % #anchorPoints) + 1]
    UpdateAnchorText()
end)

-- BUTTON 2: BORDER STYLE
local borderBtn = CreateThemedButton(pageInterface, L.BORDER_STYLE, 200, 25)
borderBtn:SetPoint("TOPLEFT", 220, -375)
local function UpdateBorderText()
    borderBtn:SetText(L.BORDER_LABEL .. (ZipTrixDB.borderStyle or "Blizzard"))
end
borderBtn:SetScript("OnShow", UpdateBorderText)
borderBtn:SetScript("OnClick", function()
    local idx = 1
    for i, p in ipairs(borderStyles) do
        if p == ZipTrixDB.borderStyle then idx = i break end
    end
    ZipTrixDB.borderStyle = borderStyles[(idx % #borderStyles) + 1]
    UpdateBorderText()
    if GameTooltip:IsShown() then
         GameTooltip:Hide(); GameTooltip:Show()
    end
end)

CreateSliderWithEditBox(pageInterface, "offsetX", L.OFFSET_X, -100, 100, 10, -415)
CreateSliderWithEditBox(pageInterface, "offsetY", L.OFFSET_Y, -100, 100, 220, -415)

----------------------------------------------------------------------
-- 5. TWILIGHT HIGHLANDS VENDOR PAGE
----------------------------------------------------------------------
--[[
local twilightHeader = pageTwilight:CreateFontString(nil, "OVERLAY")
twilightHeader:SetFont(headerFont, 16, "OUTLINE")
twilightHeader:SetPoint("TOPLEFT", 0, 0)
twilightHeader:SetText("Twilight Highlands Vendor")
twilightHeader:SetTextColor(0.8, 0.4, 1.0)

local helpBtn = CreateFrame("Button", nil, pageTwilight)
helpBtn:SetSize(24, 24)
helpBtn:SetPoint("TOPRIGHT", -10, 5)
local helpIcon = helpBtn:CreateTexture(nil, "ARTWORK")
helpIcon:SetAllPoints()
helpIcon:SetTexture("Interface\\common\\help-i")
helpBtn:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    GameTooltip:SetText("Twilight Vendor Guide", 1, 1, 1)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("This panel simplifies purchasing from the Twilight Highlands event vendor by filtering items for your class.", nil, nil, nil, true)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Indicators:", 0.8, 0.4, 1.0)
    GameTooltip:AddLine("|TInterface\\Buttons\\UI-GroupLoot-Coin-Up:16:16:0:0|t Green Arrow: Item is an upgrade", 1, 1, 1)
    GameTooltip:AddLine("|A:transmog-icon-purple:16:16|a Purple Eye: Appearance not collected", 1, 1, 1)
    GameTooltip:AddLine("Grayed Out: Already owned or cannot afford", 0.7, 0.7, 0.7)
    GameTooltip:AddLine(" ")
    GameTooltip:AddLine("Interactions:", 0.8, 0.4, 1.0)
    GameTooltip:AddLine("Click: Buy Item", 1, 1, 1)
    GameTooltip:AddLine("Ctrl+Click: Preview", 1, 1, 1)
    GameTooltip:AddLine("Shift+Click: Link", 1, 1, 1)
    GameTooltip:Show()
end)
helpBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)

local twilightBlurb = pageTwilight:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
twilightBlurb:SetPoint("TOPLEFT", 0, -25)
twilightBlurb:SetWidth(380)
twilightBlurb:SetJustifyH("LEFT")
twilightBlurb:SetText("This tab only populates when accessing the appropriate vendors.")
twilightBlurb:SetTextColor(0.6, 0.6, 0.6)

local twilightScroll = CreateFrame("ScrollFrame", nil, pageTwilight, "UIPanelScrollFrameTemplate")
twilightScroll:SetPoint("TOPLEFT", 0, -45)
twilightScroll:SetPoint("BOTTOMRIGHT", -25, 10)
local twilightContent = CreateFrame("Frame", nil, twilightScroll)
twilightContent:SetSize(380, 850)
twilightScroll:SetScrollChild(twilightContent)

local function GetPlayerArmorType()
    local _, classFilename = UnitClass("player")
    if classFilename == "WARRIOR" or classFilename == "PALADIN" or classFilename == "DEATHKNIGHT" then return 4 end -- Plate
    if classFilename == "HUNTER" or classFilename == "SHAMAN" or classFilename == "EVOKER" then return 3 end -- Mail
    if classFilename == "ROGUE" or classFilename == "DRUID" or classFilename == "MONK" or classFilename == "DEMONHUNTER" then return 2 end -- Leather
    return 1 -- Cloth (Mage, Priest, Warlock)
end

local function GetPlayerWeaponPermissions()
    local _, class = UnitClass("player")
    local weapons = {}
    local shields = false
    local offhands = false
    
    -- 0=Axe1H, 1=Axe2H, 2=Bow, 3=Gun, 4=Mace1H, 5=Mace2H, 6=Polearm, 7=Sword1H, 8=Sword2H, 9=Warglaive, 10=Staff, 13=Fist, 15=Dagger, 18=Crossbow, 19=Wand
    if class == "WARRIOR" then 
        weapons = {0,1,4,5,6,7,8,10,13,15}
        shields = true
    elseif class == "PALADIN" then 
        weapons = {0,1,4,5,6,7,8}
        shields = true
        offhands = true
    elseif class == "HUNTER" then 
        weapons = {0,1,2,3,6,7,8,10,13,15,18}
    elseif class == "ROGUE" then 
        weapons = {0,4,7,13,15}
    elseif class == "PRIEST" then 
        weapons = {4,10,15,19}
        offhands = true
    elseif class == "DEATHKNIGHT" then 
        weapons = {0,1,4,5,6,7,8}
    elseif class == "SHAMAN" then 
        weapons = {0,1,4,5,10,13,15}
        shields = true
        offhands = true
    elseif class == "MAGE" then 
        weapons = {7,10,15,19}
        offhands = true
    elseif class == "WARLOCK" then 
        weapons = {7,10,15,19}
        offhands = true
    elseif class == "MONK" then 
        weapons = {0,4,6,7,10,13}
        offhands = true
    elseif class == "DRUID" then 
        weapons = {4,5,6,10,13,15}
        offhands = true
    elseif class == "DEMONHUNTER" then 
        weapons = {0,7,9,13}
    elseif class == "EVOKER" then 
        weapons = {0,1,4,5,7,8,10,13,15}
        offhands = true
    end
    
    local wLookup = {}
    for _, id in ipairs(weapons) do wLookup[id] = true end
    return wLookup, shields, offhands
end

local weaponButtons = {}
local armorButtons = {}

local function IsItemUpgrade(itemLink)
    -- 1. Pawn Integration
    if _G.PawnIsItemAnUpgrade and _G.PawnGetItemData then
        local itemData = _G.PawnGetItemData(itemLink)
        if itemData then
            return _G.PawnIsItemAnUpgrade(itemData)
        end
        return false
    end

    -- 2. Fallback: Simple Item Level Check
    local _, _, _, equipLoc = C_Item.GetItemInfoInstant(itemLink)
    local slotID = nil
    
    -- Map equipLoc to SlotID for comparison
    if equipLoc == "INVTYPE_HEAD" then slotID = 1
    elseif equipLoc == "INVTYPE_NECK" then slotID = 2
    elseif equipLoc == "INVTYPE_SHOULDER" then slotID = 3
    elseif equipLoc == "INVTYPE_CHEST" or equipLoc == "INVTYPE_ROBE" then slotID = 5
    elseif equipLoc == "INVTYPE_WAIST" then slotID = 6
    elseif equipLoc == "INVTYPE_LEGS" then slotID = 7
    elseif equipLoc == "INVTYPE_FEET" then slotID = 8
    elseif equipLoc == "INVTYPE_WRIST" then slotID = 9
    elseif equipLoc == "INVTYPE_HAND" then slotID = 10
    elseif equipLoc == "INVTYPE_FINGER" then slotID = 11 -- Check first ring slot as proxy
    elseif equipLoc == "INVTYPE_TRINKET" then slotID = 13 -- Check first trinket slot as proxy
    elseif equipLoc == "INVTYPE_CLOAK" then slotID = 15
    elseif equipLoc == "INVTYPE_WEAPON" or equipLoc == "INVTYPE_2HWEAPON" or equipLoc == "INVTYPE_WEAPONMAINHAND" then slotID = 16
    elseif equipLoc == "INVTYPE_WEAPONOFFHAND" or equipLoc == "INVTYPE_SHIELD" or equipLoc == "INVTYPE_HOLDABLE" then slotID = 17
    end

    if slotID then
        local currentLink = GetInventoryItemLink("player", slotID)
        if not currentLink then return true end -- Empty slot is an upgrade
        
        local currentLvl = C_Item.GetDetailedItemLevelInfo(currentLink)
        local newLvl = C_Item.GetDetailedItemLevelInfo(itemLink)
        if newLvl and currentLvl and newLvl > currentLvl then
            return true
        end
    end
    return false
end

local function UpdateVendorTab()
    local numItems = GetMerchantNumItems()
    if numItems == 0 then
        twilightScroll:Hide()
        twilightBlurb:Show()
        return
    end
    twilightScroll:Show()
    twilightBlurb:Hide()

    -- Reset Buttons
    for _, btn in pairs(weaponButtons) do btn:Hide() end
    for _, btn in pairs(armorButtons) do btn:Hide() end

    local playerArmorType = GetPlayerArmorType()
    local allowedWeapons, canUseShields, canUseOffhands = GetPlayerWeaponPermissions()
    local usableWeapons = {}
    local armorItems = {} -- Key by slot name

    -- 1. Scan Merchant
    for m = 1, numItems do
        local link = GetMerchantItemLink(m)
        if link then
            -- Use GetItemInfoInstant for reliable filtering (returns: id, type, subtype, equipLoc, icon, classID, subclassID)
            local itemID, _, _, equipLoc, iconID, classID, subclassID = C_Item.GetItemInfoInstant(link)
            if itemID then C_Item.RequestLoadItemDataByID(itemID) end -- Ensure data loads for tooltips
            
            -- local isUsable = C_Item.IsUsableItem(link) -- Removed strict usability check to ensure items populate

            if classID then
                -- Weapons (ClassID 2) or Shields/Offhands
                if classID == 2 or equipLoc == "INVTYPE_SHIELD" or equipLoc == "INVTYPE_HOLDABLE" then
                    local isAllowed = false
                    if classID == 2 then
                        isAllowed = allowedWeapons[subclassID]
                    elseif equipLoc == "INVTYPE_SHIELD" then
                        isAllowed = canUseShields
                    elseif equipLoc == "INVTYPE_HOLDABLE" then
                        isAllowed = canUseOffhands
                    end

                    if isAllowed then
                        table.insert(usableWeapons, { index = m, link = link })
                    end
                
                -- Armor (ClassID 4)
                elseif classID == 4 then
                    local validArmor = false
                    if equipLoc == "INVTYPE_CLOAK" then validArmor = true end
                    if subclassID == playerArmorType then validArmor = true end
                    if subclassID == 0 then validArmor = true end -- Jewelry
                    if subclassID == 5 then validArmor = true end -- Cosmetic

                    if validArmor then
                        local slotKey = equipLoc
                        if slotKey == "INVTYPE_ROBE" then slotKey = "INVTYPE_CHEST" end
                        
                        if not armorItems[slotKey] then armorItems[slotKey] = {} end
                        table.insert(armorItems[slotKey], { index = m, link = link, id = itemID, icon = iconID })
                    end
                end
            end
        end
    end

    -- 2. Render Weapons (Top Row)
    local wX, wY = 10, -10
    for i, data in ipairs(usableWeapons) do
        local btn = weaponButtons[i]
        if not btn then
            btn = CreateFrame("Button", nil, twilightContent)
            btn:SetSize(37, 37)
            
            btn.icon = btn:CreateTexture(nil, "ARTWORK")
            btn.icon:SetAllPoints()
            btn.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92) -- Zoom in slightly to avoid square edges showing

            -- Circular Mask
            local mask = btn:CreateMaskTexture()
            mask:SetTexture("Interface\\CHARACTERFRAME\\TempPortraitAlphaMask", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetAllPoints(btn.icon)
            btn.icon:AddMaskTexture(mask)

            -- Circular Border
            btn.Border = btn:CreateTexture(nil, "OVERLAY")
            btn.Border:SetAllPoints()
            btn.Border:SetAtlas("Talent-Node-Circle-Locked") -- Clean circular ring
            
            -- Upgrade Icon (Green Arrow)
            btn.upgradeIcon = btn:CreateTexture(nil, "OVERLAY")
            btn.upgradeIcon:SetSize(16, 16)
            btn.upgradeIcon:SetPoint("TOPRIGHT", 2, 2)
            btn.upgradeIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong")
            
            weaponButtons[i] = btn
        end
        btn:SetPoint("TOPLEFT", wX, wY)
        btn:Show()

        local itemID = C_Item.GetItemInfoInstant(data.link)
        if btn.icon then btn.icon:SetTexture(C_Item.GetItemIconByID(itemID)) end
        
        -- Check Upgrade
        local isUpgrade = IsItemUpgrade(data.link)
        if isUpgrade then
            btn.upgradeIcon:Show()
        else
            btn.upgradeIcon:Hide()
        end

        local isOwned = C_Item.GetItemCount(itemID, true) > 0
        if isOwned then
            if btn.icon then btn.icon:SetDesaturated(true) end
            if btn.Border then btn.Border:SetVertexColor(0.5, 0.5, 0.5) end -- Gray border
            btn:SetAlpha(0.5)
            btn:Disable()
            if btn.SetMotionScriptsWhileDisabled then btn:SetMotionScriptsWhileDisabled(true) end
        else
            if btn.icon then btn.icon:SetDesaturated(false) end
            if btn.Border then btn.Border:SetVertexColor(1, 1, 1) end -- Default white border
            btn:SetAlpha(1)
            btn:Enable()
            btn:SetScript("OnClick", function()
                if IsModifiedClick() then
                    HandleModifiedItemClick(data.link)
                else
                    BuyMerchantItem(data.index)
                end
            end)
        end

        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetHyperlink(data.link)
            GameTooltip:AddLine(" ")
            
            if isOwned then
                GameTooltip:AddLine("Status: Previously Purchased", 1, 0.2, 0.2)
            else
                local info = C_MerchantFrame.GetItemInfo(data.index)
                local price = info and info.price or 0
                local isPurchasable = info and info.isPurchasable
                
                if not isPurchasable or price > GetMoney() then
                    GameTooltip:AddLine("Status: Cannot Afford", 1, 0.2, 0.2)
                else
                    GameTooltip:AddLine("Status: Available", 0.2, 1, 0.2)
                end
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)

        wX = wX + 45
        if wX > 350 then wX = 10; wY = wY - 45 end
    end

    -- 3. Render Armor (Two Columns)
    local layout = {
        { label = "Head", slot = "INVTYPE_HEAD", x = 10, y = wY - 50 },
        { label = "Shoulders", slot = "INVTYPE_SHOULDER", x = 10, y = wY - 85 },
        { label = "Chest", slot = "INVTYPE_CHEST", x = 10, y = wY - 120 },
        { label = "Waist", slot = "INVTYPE_WAIST", x = 10, y = wY - 155 },
        { label = "Wrist", slot = "INVTYPE_WRIST", x = 10, y = wY - 190 },
        { label = "Hands", slot = "INVTYPE_HAND", x = 10, y = wY - 225 },
        { label = "Legs", slot = "INVTYPE_LEGS", x = 10, y = wY - 260 },
        { label = "Feet", slot = "INVTYPE_FEET", x = 10, y = wY - 295 },
        
        { label = "Back", slot = "INVTYPE_CLOAK", x = 190, y = wY - 50 },
        { label = "Neck", slot = "INVTYPE_NECK", x = 190, y = wY - 85 },
        { label = "Ring 1", slot = "INVTYPE_FINGER", x = 190, y = wY - 120 },
        { label = "Ring 2", slot = "INVTYPE_FINGER", x = 190, y = wY - 155 },
        { label = "Trinket 1", slot = "INVTYPE_TRINKET", x = 190, y = wY - 190 },
        { label = "Trinket 2", slot = "INVTYPE_TRINKET", x = 190, y = wY - 225 },
    }

    local btnIndex = 1
    for _, entry in ipairs(layout) do
        -- Get next available item for this slot
        local itemData = nil
        if armorItems[entry.slot] and #armorItems[entry.slot] > 0 then
            itemData = table.remove(armorItems[entry.slot], 1)
        end

        local btn = armorButtons[btnIndex]
        if not btn then
            btn = CreateThemedButton(twilightContent, "", 170, 30)
            
            -- Item Icon (Inside Left)
            local icon = btn:CreateTexture(nil, "ARTWORK")
            icon:SetSize(24, 24)
            icon:SetPoint("LEFT", 3, 0)
            btn.Icon = icon
            
            -- Adjust Text
            local fs = btn:GetFontString()
            if fs then
                fs:ClearAllPoints()
                fs:SetPoint("LEFT", icon, "RIGHT", 5, 0)
                fs:SetPoint("RIGHT", -5, 0)
                fs:SetJustifyH("LEFT")
            end

            local tmog = btn:CreateTexture(nil, "OVERLAY")
            tmog:SetSize(20, 20)
            tmog:SetPoint("RIGHT", btn, "LEFT", -2, 0)
            tmog:SetAtlas("transmog-icon-purple")
            btn.tmogIcon = tmog
            
            -- Upgrade Icon (Green Arrow)
            btn.upgradeIcon = btn:CreateTexture(nil, "OVERLAY")
            btn.upgradeIcon:SetSize(16, 16)
            btn.upgradeIcon:SetPoint("RIGHT", -5, 0)
            btn.upgradeIcon:SetTexture("Interface\\PetBattles\\BattleBar-AbilityBadge-Strong")
            
            armorButtons[btnIndex] = btn
        end
        btnIndex = btnIndex + 1

        btn:SetPoint("TOPLEFT", entry.x, entry.y)
        btn:Show()

        if itemData then
            local itemID = itemData.id
            local isOwned = C_Item.GetItemCount(itemID, true) > 0
            local isCollected = false
            
            -- Transmog Check
            if C_TransmogCollection then
                local appearanceID = C_TransmogCollection.GetItemInfo(itemData.link)
                if appearanceID then
                    isCollected = C_TransmogCollection.PlayerHasTransmog(itemID)
                end
            end

            -- Upgrade Check
            local isUpgrade = IsItemUpgrade(itemData.link)

            btn:SetText(entry.label .. ": " .. (C_Item.GetItemNameByID(itemData.link) or "Loading..."))
            btn.Icon:SetTexture(itemData.icon)
            
            if isOwned then
                btn:Disable()
                -- Allow tooltip while disabled
                if btn.SetMotionScriptsWhileDisabled then 
                    btn:SetMotionScriptsWhileDisabled(true) 
                end
                btn:SetAlpha(0.5)
                btn.tmogIcon:Hide()
                btn.upgradeIcon:Hide()
            else
                btn:Enable()
                btn:SetAlpha(1)
                if isUpgrade then
                    btn:SetBackdropColor(0, 0.3, 0, 1) -- Slight Green tint
                    btn.upgradeIcon:Show()
                else
                    ApplyButtonTheme(btn) -- Reset to theme
                    btn.upgradeIcon:Hide()
                end
                
                if not isCollected then
                    btn.tmogIcon:Show()
                else
                    btn.tmogIcon:Hide()
                end
                btn:SetScript("OnClick", function()
                    if IsModifiedClick() then
                        HandleModifiedItemClick(itemData.link)
                    else
                        BuyMerchantItem(itemData.index)
                    end
                end)
            end

            -- Custom Tooltip Logic
            btn:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(itemData.link)
                GameTooltip:AddLine(" ")
                
                if isOwned then
                    GameTooltip:AddLine("Status: Previously Purchased", 1, 0.2, 0.2)
                else
                    -- Check Affordability
                    local info = C_MerchantFrame.GetItemInfo(itemData.index)
                    local price = info and info.price or 0
                    local isPurchasable = info and info.isPurchasable

                    local canAfford = true
                    if not isPurchasable then canAfford = false end
                    if price > GetMoney() then canAfford = false end
                    
                    if not canAfford then
                        GameTooltip:AddLine("Status: Cannot Afford", 1, 0.2, 0.2)
                    else
                        GameTooltip:AddLine("Status: Available", 0.2, 1, 0.2)
                    end

                    if isCollected then
                        GameTooltip:AddLine("Appearance: Collected", 0.5, 0.5, 1)
                    end
                end
                GameTooltip:Show()
            end)
            btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
        else
            btn:SetText(entry.label .. ": Not Available")
            btn:Disable()
            btn.Icon:SetTexture(nil)
            btn:SetAlpha(0.3)
            btn.tmogIcon:Hide()
            -- Clear tooltip scripts for empty buttons
            btn:SetScript("OnEnter", nil)
            btn:SetScript("OnLeave", nil)
        end
    end
end

pageTwilight:SetScript("OnShow", UpdateVendorTab)

-- Event Handler for Vendor Open

]]

----------------------------------------------------------------------
-- 5. LOOTZ PAGE
----------------------------------------------------------------------
local lootzHeader = pageLootz:CreateFontString(nil, "OVERLAY")
lootzHeader:SetFont(headerFont, 16, "OUTLINE")
lootzHeader:SetPoint("TOPLEFT", 0, 0)
lootzHeader:SetText("Loot Options")
lootzHeader:SetTextColor(0.8, 0.4, 1.0)

local cbEnableLootz = CreateToggleSwitch(pageLootz, "enableLootz", "Enable Lootz Module", 10, -40)

local function CreateFeedbackRow(parent, yOffset, labelText, toggleKey, syntaxKey, colorKey)
    local cb = CreateToggleSwitch(parent, toggleKey, labelText, 10, yOffset)
    
    local syntaxLabel = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    syntaxLabel:SetPoint("TOPLEFT", 220, yOffset - 2)
    syntaxLabel:SetText("Syntax:")

    local syntaxBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
    syntaxBox:SetSize(60, 20)
    syntaxBox:SetPoint("LEFT", syntaxLabel, "RIGHT", 10, 0)
    syntaxBox:SetAutoFocus(false)
    syntaxBox:SetScript("OnShow", function(self)
        if ZipTrixDB then self:SetText(ZipTrixDB[syntaxKey] or "+") end
    end)
    syntaxBox:SetScript("OnTextChanged", function(self, userInput)
        if ZipTrixDB and userInput then ZipTrixDB[syntaxKey] = self:GetText() end
    end)

    local colorBtn = CreateFrame("Button", nil, parent, "BackdropTemplate")
    colorBtn:SetSize(20, 20)
    colorBtn:SetPoint("LEFT", syntaxBox, "RIGHT", 10, 0)
    colorBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 10,
        insets = { left = 2, right = 2, top = 2, bottom = 2 }
    })
    
    local function UpdateColorBtn()
        if not ZipTrixDB then return end
        local c = ZipTrixDB[colorKey] or {r=0, g=1, b=0}
        colorBtn:SetBackdropColor(c.r, c.g, c.b, 1)
    end
    colorBtn:SetScript("OnShow", UpdateColorBtn)
    colorBtn:SetScript("OnClick", function()
        local c = ZipTrixDB[colorKey] or {r=0, g=1, b=0}
        local function ColorCallback(restore)
            local newR, newG, newB
            if restore then
                newR, newG, newB = restore.r, restore.g, restore.b
            else
                newR, newG, newB = ColorPickerFrame:GetColorRGB()
            end
            ZipTrixDB[colorKey] = {r=newR, g=newG, b=newB}
            UpdateColorBtn()
        end
        ColorPickerFrame:SetupColorPickerAndShow({
            r = c.r,
            g = c.g,
            b = c.b,
            hasOpacity = false,
            swatchFunc = ColorCallback,
            cancelFunc = ColorCallback,
        })
    end)

    return cb, syntaxLabel, syntaxBox, colorBtn
end

local cbLootFeedback, lootLabel, lootBox, lootColor = CreateFeedbackRow(pageLootz, -70, "Enable Looting Feedback", "lootzFeedbackEnabled", "lootzSyntax", "lootzColor")
local cbCurrencyFeedback, currLabel, currBox, currColor = CreateFeedbackRow(pageLootz, -100, "Enable Currency Feedback", "lootzCurrencyFeedbackEnabled", "lootzCurrencySyntax", "lootzCurrencyColor")
local cbExpFeedback, expLabel, expBox, expColor = CreateFeedbackRow(pageLootz, -130, "Enable Experience Feedback", "lootzExpFeedbackEnabled", "lootzExpSyntax", "lootzExpColor")
local cbGoldFeedback, goldLabel, goldBox, goldColor = CreateFeedbackRow(pageLootz, -160, "Enable Gold Feedback", "lootzGoldFeedbackEnabled", "lootzGoldSyntax", "lootzGoldColor")
local cbGatherFeedback, gatherLabel, gatherBox, gatherColor = CreateFeedbackRow(pageLootz, -190, "Enable Gathering Feedback", "lootzGatheringFeedbackEnabled", "lootzGatheringSyntax", "lootzGatheringColor")
local cbPreyFeedback, preyLabel, preyBox, preyColor = CreateFeedbackRow(pageLootz, -220, "Enable Prey Feedback", "lootzPreyFeedbackEnabled", "lootzPreySyntax", "lootzPreyColor")
local cbRepFeedback, repLabel, repBox, repColor = CreateFeedbackRow(pageLootz, -250, "Enable Reputation Feedback", "lootzRepFeedbackEnabled", "lootzRepSyntax", "lootzRepColor")

local function UpdateLootzState()
    if not ZipTrixDB then return end
    local enabled = ZipTrixDB.enableLootz
    cbLootFeedback:SetShown(enabled)
    lootLabel:SetShown(enabled)
    lootBox:SetShown(enabled)
    lootColor:SetShown(enabled)

    cbCurrencyFeedback:SetShown(enabled)
    currLabel:SetShown(enabled)
    currBox:SetShown(enabled)
    currColor:SetShown(enabled)
    
    cbExpFeedback:SetShown(enabled)
    expLabel:SetShown(enabled)
    expBox:SetShown(enabled)
    expColor:SetShown(enabled)
    
    cbGoldFeedback:SetShown(enabled)
    goldLabel:SetShown(enabled)
    goldBox:SetShown(enabled)
    goldColor:SetShown(enabled)

    cbGatherFeedback:SetShown(enabled)
    gatherLabel:SetShown(enabled)
    gatherBox:SetShown(enabled)
    gatherColor:SetShown(enabled)

    cbPreyFeedback:SetShown(enabled)
    preyLabel:SetShown(enabled)
    preyBox:SetShown(enabled)
    preyColor:SetShown(enabled)
    
    cbRepFeedback:SetShown(enabled)
    repLabel:SetShown(enabled)
    repBox:SetShown(enabled)
    repColor:SetShown(enabled)
end
cbEnableLootz:HookScript("OnClick", UpdateLootzState)
cbEnableLootz:HookScript("OnShow", UpdateLootzState)

-- Chat Filter for Loot
local function LootMessageFilter(self, event, msg, ...)
    if not ZipTrixDB or not ZipTrixDB.enableLootz then return false end
    
    local lowerMsg = msg:lower()
    local isCurrency = string.match(lowerMsg, "you receive.- currency:")
    local isLoot = string.match(lowerMsg, "you receive.- loot:") or string.match(lowerMsg, "you receive.- item:")
    
    -- Broadened to catch item, currency, battlepet links
    local itemLink = string.match(msg, "(|c%x+|H.-|h%[.-%]|h|r)") or string.match(msg, "(|H.-|h%[.-%]|h)")
    if not itemLink then return false end

    -- Extract quantity if present
    local quantity = string.match(msg, "x%s*(%d+)%W*$")
    local qStr = ""
    if quantity and tonumber(quantity) > 1 then qStr = " x" .. quantity end

    -- Preserve any icons that might be prefixed
    local prefix = string.match(msg, "^(|T.-|t%s*)") or ""
    local playerLink = string.match(msg, "(|Hplayer:.-|h%[.-%]|h)")
    
    if isCurrency then
        if not ZipTrixDB.lootzCurrencyFeedbackEnabled then return false end
        local syntax = ZipTrixDB.lootzCurrencySyntax or "+"
        local color = ZipTrixDB.lootzCurrencyColor or {r=0, g=1, b=0}
        local hex = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
        local newMsg = prefix .. hex .. syntax .. "|r " .. itemLink .. qStr
        return false, newMsg, ...
    end

    if not ZipTrixDB.lootzFeedbackEnabled then return false end
    local syntax = ZipTrixDB.lootzSyntax or "+"
    local color = ZipTrixDB.lootzColor or {r=0, g=1, b=0}
    local hex = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
    
    if playerLink and not isLoot then
        local newMsg = prefix .. playerLink .. " " .. hex .. syntax .. "|r " .. itemLink .. qStr
        return false, newMsg, ...
    else
        -- It's our own loot
        local newMsg = prefix .. hex .. syntax .. "|r " .. itemLink .. qStr
        return false, newMsg, ...
    end

    return false
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_LOOT", LootMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CURRENCY", LootMessageFilter)

local function MoneyMessageFilter(self, event, msg, ...)
    if not ZipTrixDB or not ZipTrixDB.enableLootz or not ZipTrixDB.lootzGoldFeedbackEnabled then return false end
    
    local syntax = ZipTrixDB.lootzGoldSyntax or "+"
    local color = ZipTrixDB.lootzGoldColor or {r=0, g=1, b=0}
    local hex = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

    local str = string.match(msg, "You loot (.*)") or string.match(msg, "Your share of the loot is (.*)") or string.match(msg, "You receive (.*)")
    if str and not string.match(str, "|H.-:") then
        return false, hex .. syntax .. "|r " .. str, ...
    end
    
    return false
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_MONEY", MoneyMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", MoneyMessageFilter)

local function ExperienceMessageFilter(self, event, msg, ...)
    if not ZipTrixDB or not ZipTrixDB.enableLootz or not ZipTrixDB.lootzExpFeedbackEnabled then return false end
    
    local syntax = ZipTrixDB.lootzExpSyntax or "+"
    local color = ZipTrixDB.lootzExpColor or {r=0, g=1, b=0}
    local hex = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

    local xp = string.match(msg, "gain (.- experience.*)") or string.match(msg, "Experience gained: (.*)")
    if xp then
        return false, hex .. syntax .. "|r " .. xp, ...
    end
    
    return false
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_XP_GAIN", ExperienceMessageFilter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", ExperienceMessageFilter)

local function GatheringMessageFilter(self, event, msg, ...)
    if not ZipTrixDB or not ZipTrixDB.enableLootz or not ZipTrixDB.lootzGatheringFeedbackEnabled then return false end
    
    local syntax = ZipTrixDB.lootzGatheringSyntax or "+"
    local color = ZipTrixDB.lootzGatheringColor or {r=0, g=1, b=0}
    local hex = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

    -- Covers Gathering, Milling, Prospecting, Disenchanting, etc.
    -- e.g., "You perform Midnight Mining on Refulgent Copper." -> "You | Midnight Mining + Refulgent Copper"
    local player, profession, object = string.match(msg, "^(.-) performs? (.-) on (.-)%.?$")
    if player and profession and object then
        local lowerAction = profession:lower()
        if lowerAction:match("trap") or lowerAction:match("prey") or lowerAction:match("lure") or lowerAction:match("bait") or lowerAction:match("snare") then
            return false
        end
        return false, player .. " | " .. profession .. " " .. hex .. syntax .. "|r " .. object, ...
    end

    -- Covers Profession Skill-Ups
    -- e.g., "Your skill in Khaz Algar Enchanting has increased to 25." -> "Skill | Khaz Algar Enchanting + 25"
    local skillProf, skillLevel = string.match(msg, "skill in (.-) has increased to (%d+)%.?")
    if skillProf and skillLevel then
        return false, "Skill | " .. skillProf .. " " .. hex .. syntax .. "|r " .. skillLevel, ...
    end
    
    return false
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", GatheringMessageFilter)

local function PreyMessageFilter(self, event, msg, ...)
    if not ZipTrixDB or not ZipTrixDB.enableLootz or not ZipTrixDB.lootzPreyFeedbackEnabled then return false end
    
    local syntax = ZipTrixDB.lootzPreySyntax or "+"
    local color = ZipTrixDB.lootzPreyColor or {r=0, g=1, b=0}
    local hex = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

    local player, action, object = string.match(msg, "^(.-) performs? (.-) on (.-)%.?$")
    if player and action and object then
        local lowerAction = action:lower()
        if lowerAction:match("trap") or lowerAction:match("prey") or lowerAction:match("lure") or lowerAction:match("bait") or lowerAction:match("snare") then
            return false, hex .. player .. " | " .. action .. " " .. syntax .. " " .. object .. "|r", ...
        end
    end
    
    return false
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", PreyMessageFilter)

local function RepMessageFilter(self, event, msg, ...)
    if not ZipTrixDB or not ZipTrixDB.enableLootz or not ZipTrixDB.lootzRepFeedbackEnabled then return false end
    
    local syntax = ZipTrixDB.lootzRepSyntax or "+"
    local color = ZipTrixDB.lootzRepColor or {r=0, g=1, b=0}
    local hex = string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

    local faction, amount = string.match(msg, "Your Warband's reputation with (.-) increased by (%d+)%.?")
    if faction and amount then
        faction = faction:gsub(":%s*", " ")
        return false, "Warband | " .. faction .. " " .. hex .. syntax .. amount .. "|r", ...
    end
    local factionDec, amountDec = string.match(msg, "Your Warband's reputation with (.-) decreased by (%d+)%.?")
    if factionDec and amountDec then
        factionDec = factionDec:gsub(":%s*", " ")
        return false, "Warband | " .. factionDec .. " " .. hex .. "-" .. amountDec .. "|r", ...
    end
    
    faction, amount = string.match(msg, "Reputation with (.-) increased by (%d+)%.?")
    if faction and amount then
        faction = faction:gsub(":%s*", " ")
        return false, faction .. " " .. hex .. syntax .. amount .. "|r", ...
    end
    factionDec, amountDec = string.match(msg, "Reputation with (.-) decreased by (%d+)%.?")
    if factionDec and amountDec then
        factionDec = factionDec:gsub(":%s*", " ")
        return false, factionDec .. " " .. hex .. "-" .. amountDec .. "|r", ...
    end
    
    return false
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", RepMessageFilter)

----------------------------------------------------------------------
-- 6. ABOUT PAGE
----------------------------------------------------------------------
local changelogText = [[
2026-05-23    Update 1.0.17 - Textures & Overlays
    * Unit Frames & Textures:
        - Registered new "ztBloodyBg" textures via LibSharedMedia for health and status bars.
        - Added dynamic luma calculations to preserve the red/black colorway while subtly tinting with class colors.
        - Added an ElvUI UnitFrame Overlay feature (applies to Player and Target frames).
        - Added "UnitFrame Overlay" toggle to the Interface Customization tab.

2026-05-19    Update 1.0.16 - Lootz Module
    * New Feature: Lootz
        - Added a new "Lootz" tab to the ZipTrix options.
        - Allows truncating and customizing chat feedback for Loot, Currency, Experience, and Gold gains.
        - Customize syntax and color for each feedback type.
        - Added Gathering Feedback (e.g., Herb Gathering, Mining, Skinning).
        - Added Prey Feedback (e.g., Disarm Trap) with full string coloring.
        - Added Warband and standard Reputation Feedback.
    * Upgrade Clarity:
        - Added "Ritual Sites" as a dynamic crest source for Champion and Hero tracks.
        - Applied custom hex colors to each upgrade track (Adventurer, Veteran, Champion, Heroic, Mythic) to accurately reflect their associated crests.

2026-05-18    Update 1.0.15 - Model API Fix
    * Fixes:
        - Completely bypassed broken internal scene actors by re-introducing the native DressUpModel overlay.
        - Overlay accurately builds outfits securely mapping `TryOn()` methods using transmog appearanceIDs without crashing.
        - Models and gear instantly load accurately mapped to correct racial skeletons.

2026-05-18    Update 1.0.13 - Dressing Room Controls
    * Interface Enhancements:
        - Added Faction, Body Type, and Race selection dropdowns to a new standalone left-side panel on the Dressing Room frame.
        - Frame updated to match the NineSlice "No Portrait" style of the CustomSetDetailsPanel.
        - Model Options toggle button now matches the native Custom Set Details button icon and securely anchors beside it.
        - Easily preview any transmog combination on different races and body types without losing your applied outfit.
        - Adjusted gender IDs to correctly map Body 1 and Body 2 onto the model actor.

2026-03-03    Update 1.0.12 - Midnight & Fixes
    * Updates:
        - Updated Interface version for Midnight (12.0).
        - Fixed a taint issue causing errors with tooltip widgets.

2026-02-11    Update 1.0.11 - Secrets & Cleanup
    * Secrets Helper:
        - Fixed waypoint buttons not functioning (now using SecureActionButtonTemplate).
        - Fixed layout issues where dropdown items overlapped headers.
        - Added "World Quest" style banners to secret headers.
        - "Mind-Seeker" section now tracks progress (Secrets: X/Y).
    * Character Options:
        - Added "Tracker Cleanup" button to untrack all quests and achievements.
    * Fixes:
        - Fixed Lua error when clicking Link pills (StaticPopup EditBox casing).
        - Fixed waypoint macro execution reliability.

2026-02-08    Update 1.0.10 - Outlaw Rogue
    * Gear Preferences:
        - Updated Outlaw Rogue stat weights, enchants, and consumables.

2026-02-08    Update 1.0.9 - Marksmanship Hunter
    * Gear Preferences:
        - Updated Marksmanship Hunter stat weights, enchants, and consumables.
        - Added missing enchant definition (Scout's March).

2026-02-07    Update 1.0.8 - Survival Hunter & Data Updates
    * Gear Preferences:
        - Updated Survival and Beast Mastery Hunter stat weights, enchants, and consumables for The War Within S1 / Midnight Pre-Patch.
        - Added missing enchant definitions (Council's Guile, Stonebound Artistry, Chant of Leeching Fangs).

2026-02-06    Update 1.0.7 - Cleanup & Bag Visuals
    * Interface Enhancements:
        - Added "Openable Item Glow" to bag slots. Containers and caches now glow with the current interface theme color.
    * Gear Preferences:
        - Updated Guardian Druid stat weights, enchants, and consumables for The War Within S1 / Midnight Pre-Patch.
        - Fixed visual bug where previous character tabs remained visible under the Gear Prefs pane.
        - Added opaque background to Gear Prefs pane to prevent transparency issues.
    * Cleanup & Fixes:
        - Completely removed "Death Strike Predictor" module due to persistent protected function errors.
        - Fixed Lua errors related to bag hook initialization.

2026-02-02    Update 1.0.6 - GearPrefs Polish & Fixes
    * Gear Preferences:
        - Expanded compatibility to support The War Within (11.0+) clients.
        - Implemented widget pooling to prevent memory leaks during spec switches.
        - Visual Overhaul: Aligned fonts and row styling with the default Character Stats pane.
        - Added inline Stat Ratings and Percentages to the default Character Stats pane.
        - Added Diminishing Returns (DR) threshold indicators for secondary stats.
        - Converted Consumables list to text rows with hoverable tooltips.
        - Added hoverable tooltips for Enchants (Item/Spell details).
        - Fixed panel overlapping issues when switching between Character tabs.
        - Updated data for Midnight Pre-Patch (Consumables, Enchants, Hunter Scopes, DK Runeforges).

2026-02-02    Update 1.0.5 - Shaman & Gear Preferences
    * Shaman Enhancements:
        - Added custom Maelstrom Weapon resource bar (tracks 1-10 stacks).
        - Replaces default spell alert with a movable/resizable bar.
        - Features lightning animation at full stacks.
        - Movable via Shift+LeftClick, Resizable via Shift+RightClick.
    * Gear Preferences (Midnight Beta Feature):
        - Added new "Gear Preferences" tab to the Character Pane.
        - Displays Stat Weights, Gems, Enchants, and Consumables for current spec.
        - Populated with Midnight Pre-Patch data for all classes.
        - Interactive consumable icons (Link/Tooltip).
        - Only active on Interface 12.0+ clients.
    * Cleanup & Fixes:
        - Removed "Next Rare" floating button module.
        - Updated TOC to Interface 120000.

2026-01-29    Update 1.0.4.1 - Vendor Overhaul & Polish
    * Twilight Highlands Vendor:
        - Fixed the upgrade icon in the Twilight Highlands Vendor section.

2026-01-29    Update 1.0.4 - Vendor Overhaul & Polish
    * Twilight Highlands Vendor:
        - Fixed item population issues (Robes/Cosmetics) and removed strict usability checks.
        - Replaced broken "ItemButtonTemplate" with custom button logic.
        - Added Class-Specific Weapon filtering.
        - Integrated "Upgrade Clarity" logic (Pawn support + Item Level fallback).
        - Added visual indicators: Green Arrow (Upgrade), Purple Eye (Uncollected Transmog).
        - Enhanced Tooltips: Now display status (Available, Cannot Afford, Owned) and Transmog status.
        - Added Help (?) button with usage guide.
    * UI Improvements:
        - Increased main window height to 520.
        - Fixed Character Portrait persistence when switching tabs.
        - Updated API calls for Midnight/The War Within compatibility.

2026-01-28    Update 1.0.3 - Twilight Highlands Readiness
    * Twilight Highlands:
        - Next rare button enabled only in Twilight Highlands.
        - Added event timer for the hourly event.
        - Started work on class-spec specific armor purchases (WIP: not working, still needs work).

2026-01-27    Update 1.0.2 - Character & Visual Polish
    * Character Customization:
        - Added "Custom Character Sheet" option to replace the player portrait with stylized class icons.
        - Includes styles: Fabled, Core, Myth, Realm, Void, and Hidden.
        - Right-click the portrait on the Character Sheet to cycle through styles.
    * Collections:
        - Added "Wardrobe Icon Search" to the Outfit Editor (search by Icon ID, Spell ID/Name, or Item ID/Name).
    * Visuals:
        - Fixed Class-Spec color gradients for Party and Raid frames (CompactUnitFrames).
        - Added "LFG Eye Tracking" - the queue eye now follows your cursor.
    * Cleanup:
        - Removed deprecated auto-loot/auto-learn features to comply with API restrictions.

2026-01-25    Update 1.0.1 - Class & Visual Refinement
    * Class Options:
        - Added Shaman section with Travel, Utility, and Interrupt macro generators.
	- Added Paladin  section with Utility macro generators.
        - Added "Macro Clean Up" tool to remove duplicate character macros.
        - Added class-specific visibility logic for character options.
    * Visuals & Theming:
        - Refined Class-Spec gradient colors for all classes.
        - Extended gradients to Party/Raid frames and Class Resource bars (Holy Power, etc.).
        - Replaced checkboxes with animated Toggle Switches for key interface settings.
        - Added "Unlock Blizzard Frames" utility for new characters.
    * Performance & Fixes:
        - Optimized loot scanning with item caching and removed protected automation calls.
        - Added debouncing to Gateway panel refreshes.
        - Fixed tooltip styling issues in Talent UI.

2026-01-24 - Version 1.0.0
Initial Testing Release
    Contains minor forks of the following addons:
	Enhance QoL by R41Z0R (World map teleports)
    	Item Upgrade Quality Icons by keyboardturner, SolanyaStormbreaker
	

    Core Suite Features (ZipTrix)
    * Tooltip Customization: Cursor anchoring, custom borders/themes, ID display, and combat visibility options.
    * Interface Enhancements: Global button theming and Unit Frame health bar gradients (Class-Spec colors).
    * Quality of Life: Auto-opening containers, auto-learning decor/schematics, and Paladin weapon imbue helper.
    * Media: Registers custom fonts (SF Atarian System, Expressway) via LibSharedMedia.

    Note: Detailed changes for specific modules can be found in:
    * CHANGES-WMDP.txt (World Map Dungeon Portals / Gateways)
    * CHANGES-UC.txt (Upgrade Clarity)
]]


local aboutHeader = pageAbout:CreateFontString(nil, "OVERLAY")
aboutHeader:SetFont(headerFont, 24, "OUTLINE")
aboutHeader:SetPoint("TOP", 0, -20)
aboutHeader:SetText("|cffA330C9ZipTrix|r")

local aboutIcon = pageAbout:CreateTexture(nil, "ARTWORK")
aboutIcon:SetSize(64, 64)
aboutIcon:SetPoint("TOP", aboutHeader, "BOTTOM", 0, -10)
aboutIcon:SetTexture("Interface\\Icons\\Ability_Rogue_TricksOfTheTrade")

local aboutVersion = pageAbout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
aboutVersion:SetPoint("TOP", aboutIcon, "BOTTOM", 0, -10)
aboutVersion:SetText("Version: 1.0.17")
aboutVersion:SetTextColor(0.8, 0.8, 0.8)

local aboutDate = pageAbout:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
aboutDate:SetPoint("TOP", aboutVersion, "BOTTOM", 0, -5)
aboutDate:SetText("Released: 2026-05-23")

-- Buy Me a Coffee
local bmacLabel = pageAbout:CreateFontString(nil, "OVERLAY", "GameFontNormal")
bmacLabel:SetPoint("TOP", aboutDate, "BOTTOM", 0, -20)
bmacLabel:SetText("Support the Project:")

local bmacInput = CreateFrame("EditBox", nil, pageAbout, "InputBoxTemplate")
bmacInput:SetSize(250, 30)
bmacInput:SetPoint("TOP", bmacLabel, "BOTTOM", 0, -5)
bmacInput:SetText("https://buymeacoffee.com/popgozip")
bmacInput:SetAutoFocus(false)
bmacInput:SetScript("OnTextChanged", function(self)
    self:SetText("https://buymeacoffee.com/popgozip")
    self:HighlightText()
end)
bmacInput:SetScript("OnCursorChanged", function(self)
    self:HighlightText()
end)
bmacInput:SetScript("OnChar", function(self) self:SetText("https://buymeacoffee.com/popgozip"); self:HighlightText() end)

-- Changelog ScrollFrame
local changeLogLabel = pageAbout:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
changeLogLabel:SetPoint("TOPLEFT", 20, -220)
changeLogLabel:SetText("Changelog")

local scrollContainer = CreateFrame("Frame", nil, pageAbout, "BackdropTemplate")
scrollContainer:SetPoint("TOPLEFT", 20, -250)
scrollContainer:SetPoint("BOTTOMRIGHT", -20, 20)
scrollContainer:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = "Interface\\Buttons\\WHITE8x8",
    edgeSize = 1,
})
scrollContainer:SetBackdropColor(0, 0, 0, 0.5)
scrollContainer:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

local scrollFrame = CreateFrame("ScrollFrame", nil, scrollContainer, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 5, -5)
scrollFrame:SetPoint("BOTTOMRIGHT", -25, 5)

local scrollContent = CreateFrame("Frame", nil, scrollFrame)
scrollContent:SetSize(350, 1000)
scrollFrame:SetScrollChild(scrollContent)

local changeLogFS = scrollContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightLeft")
changeLogFS:SetPoint("TOPLEFT", 0, 0)
changeLogFS:SetWidth(350)
changeLogFS:SetJustifyH("LEFT")
changeLogFS:SetText(changelogText)

scrollContent:SetHeight(changeLogFS:GetStringHeight() + 20)

--[[
local vendorFrame = CreateFrame("Frame")
vendorFrame:RegisterEvent("MERCHANT_SHOW")
vendorFrame:RegisterEvent("MERCHANT_CLOSED")
vendorFrame:RegisterEvent("GET_ITEM_INFO_RECEIVED")
vendorFrame:SetScript("OnEvent", function(self, event)
    if event == "MERCHANT_CLOSED" then
        if gui:IsShown() and pageTwilight:IsVisible() then
            gui:Hide()
        end
        return
    end

    -- Check if we are in Twilight Highlands (Map ID 241)
    local mapID = C_Map.GetBestMapForUnit("player")
    if mapID == 241 then
        local targetName = UnitName("target")
        if targetName == "Armorer Kalinovan" then
            if event == "MERCHANT_SHOW" then
                gui:Show()
                pageChar:Hide()
                pageMap:Hide()
                pageInterface:Hide()
                pageTwilight:Show()
                pageAbout:Hide()
                UpdateVendorTab()
            elseif event == "GET_ITEM_INFO_RECEIVED" and pageTwilight:IsVisible() then
                UpdateVendorTab()
            end
        end
    end
end)
--]]

-- DEBUG EXPORTER
----------------------------------------------------------------------
local function ShowDebugExport()
    local f = _G["ZipTrixDebugFrame"]
    if not f then
        f = CreateFrame("Frame", nil, UIParent, "ButtonFrameTemplate")
        f:SetSize(400, 500)
        f:SetPoint("CENTER")
        f:SetFrameStrata("DIALOG")
        if f.SetTitle then f:SetTitle("ZipTrix Model Debug Export") end
        
        local sf = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
        sf:SetPoint("TOPLEFT", 10, -30)
        sf:SetPoint("BOTTOMRIGHT", -30, 10)
        
        local eb = CreateFrame("EditBox", nil, sf)
        eb:SetWidth(sf:GetWidth() - 20)
        eb:SetMultiLine(true)
        eb:SetFontObject("ChatFontNormal")
        eb:SetAutoFocus(true)
        eb:SetScript("OnEscapePressed", function(self) f:Hide() end)
        sf:SetScrollChild(eb)
        f.EditBox = eb
    end
    
    local out = {}
    table.insert(out, "=== ZipTrix Model Debug ===")
    local v, b = GetBuildInfo()
    table.insert(out, "Client: " .. v .. " (" .. b .. ")")
    if not DressUpFrame or not DressUpFrame.ModelScene then
        table.insert(out, "Error: DressUpFrame.ModelScene not found.")
    else
        local actor = DressUpFrame.ModelScene:GetPlayerActor()
        if not actor then
            table.insert(out, "Error: PlayerActor not found.")
        else
            table.insert(out, "Actor ObjectType: " .. tostring(actor:GetObjectType()))
            table.insert(out, "--- Relevant Methods ---")
            local mt = getmetatable(actor)
            local methods = {}
            if mt and mt.__index then
                for k, func in pairs(mt.__index) do
                    if type(func) == "function" then
                        local kl = k:lower()
                        if kl:find("race") or kl:find("model") or kl:find("custom") or kl:find("dress") or kl:find("transmog") or kl:find("item") then
                            table.insert(methods, k)
                        end
                    end
                end
            end
            table.sort(methods)
            for _, m in ipairs(methods) do
                table.insert(out, m)
            end
        end
    end
    f.EditBox:SetText(table.concat(out, "\n"))
    f.EditBox:HighlightText()
    f:Show()
end

----------------------------------------------------------------------
-- NAVIGATION
----------------------------------------------------------------------
local function CreateNavButton(text, index, pageFrame)
    local btn = CreateThemedButton(sidebar, text, 130, 25)
    btn:SetPoint("TOP", 0, -10 - ((index-1) * 35))
    btn:GetFontString():SetFont(headerFont, 14, "OUTLINE")
    btn:SetScript("OnClick", function()
        pageChar:Hide()
        pageMap:Hide()
        pageInterface:Hide()
        pageTwilight:Hide()
        pageLootz:Hide()
        pageAbout:Hide()
        pageFrame:Show()
    end)
    return btn
end
CreateNavButton(L.NAV_INTERFACE, 1, pageInterface)
CreateNavButton(L.NAV_CHARACTER, 2, pageChar)
CreateNavButton(L.NAV_GATEWAY, 3, pageMap)
-- CreateNavButton(L.NAV_TWILIGHT, 4, pageTwilight)
CreateNavButton(L.NAV_LOOTZ, 4, pageLootz)
CreateNavButton(L.NAV_ABOUT, 5, pageAbout)

----------------------------------------------------------------------
-- 4. SLASH COMMANDS
----------------------------------------------------------------------
SLASH_ZIPTRIX1 = "/zt"
SLASH_ZIPTRIX2 = "/ziptrix"
SlashCmdList["ZIPTRIX"] = function(msg)
    if msg and msg:lower() == "debug" then
        ShowDebugExport()
    elseif msg and msg:lower() == "map" then
        gui:Show()
        pageChar:Hide()
        pageMap:Show()
        pageInterface:Hide()
        pageTwilight:Hide()
        pageLootz:Hide()
        pageAbout:Hide()
    elseif gui:IsShown() then gui:Hide() else gui:Show() end
end