local addonName, ns = ...

-- Version Check: Only load for Midnight Beta (Interface 12.0+)
-- Supports The War Within (11.0) and Midnight (12.0)
local _, _, _, interfaceVersion = GetBuildInfo()
if interfaceVersion < 110000 then
    return
end

----------------------------------------------------------------------
-- Gear Preferences (Beta Only)
----------------------------------------------------------------------

-- Enchants Database (Local Helper)
local E = {
    -- Weapons
    FallenCrusader = {text="Weapon: Rune of the Fallen Crusader", id=53344, type="spell"},
    Sanguination = {text="Weapon: Rune of Sanguination", id=326805, type="spell"},
    UnendingThirst = {text="Weapon: Rune of Unending Thirst", id=326808, type="spell"},
    AuthStorms = {text="Weapon: Authority of Storms", id=223781},
    AuthFiery = {text="Weapon: Authority of Fiery Resolve", id=223784},
    AuthRadiant = {text="Weapon: Authority of Radiant Power", id=223787},
    WeaponGuile = {text="Weapon: Council's Guile", id=223775},
    WeaponStonebound = {text="Weapon: Stonebound Artistry", id=223772},
    ThermalScanner = {text="Weapon: High Intensity Thermal Scanner", id=223769}, -- Scope
    Oathsworn = {text="Weapon: Oathsworn's Tenacity", id=223778},
    
    -- Chest
    JewelerSetting = {text="Socket: Magnificent Jeweler's Setting", id=215133},
    ChestJuggernaut = {text="Chest: Council's Juggernaut", id=223696},
    ChestRadiance = {text="Chest: Crystalline Radiance", id=223693},
    ChestStrength = {text="Chest: Council's Strength", id=223705},
    ChestAgility = {text="Chest: Council's Agility", id=223699},
    ChestIntellect = {text="Chest: Council's Intellect", id=223702},
    
    -- Legs
    LegsStormbound = {text="Legs: Stormbound Leggings", id=219914},
    LegsSunset = {text="Legs: Sunset Spellthread", id=222893},
    
    -- Rings
    RingCrit = {text="Ring: Radiant Critical Strike", id=223681},
    RingHaste = {text="Ring: Radiant Haste", id=223684},
    RingMastery = {text="Ring: Radiant Mastery", id=223687},
    RingVers = {text="Ring: Radiant Versatility", id=223690},
    
    -- Misc
    WristSpeed = {text="Wrist: Chant of Armored Speed", id=223661},
    WristAvoidance = {text="Wrist: Chant of Armored Avoidance", id=223664},
    WristLeech = {text="Wrist: Chant of Armored Leech", id=223658},
    CloakRapidity = {text="Cloak: Chant of Burrowing Rapidity", id=223667},
    CloakGrace = {text="Cloak: Chant of Winged Grace", id=223670},
    CloakLeech = {text="Cloak: Chant of Leeching Fangs", id=223673},
    BootsMarch = {text="Boots: Defender's March", id=223655},
    BootsScout = {text="Boots: Scout's March", id=223652},
}

-- 1. DATA TABLE
-- Note: Using War Within (Tier 3/Season 4) & Midnight Pre-Patch data.
local SpecPrefs = {
    -- DEATH KNIGHT
    [250] = { -- Blood
        stats = {"Strength", "Versatility", "Haste", "Crit", "Mastery"},
        gems = {"Culminating Blasphemite", "Versatile Emerald"},
        enchants = {E.FallenCrusader, E.ChestJuggernaut, E.LegsStormbound},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212265}, {type="Potion", id=212257}} -- Hearty Stew, Tempered Vers, Tempered Potion
    },
    [251] = { -- Frost
        stats = {"Strength", "Crit", "Mastery", "Haste", "Versatility"},
        gems = {"Culminating Blasphemite", "Masterful Sapphire"},
        enchants = {E.FallenCrusader, E.ChestStrength},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}} -- Alchemical Chaos, Tempered Potion
    },
    [252] = { -- Unholy
        stats = {"Strength", "Crit", "Mastery", "Haste", "Versatility"},
        gems = {"Indecipherable Eversong Diamond", "Flawless Deadly Amethyst", "Flawless Masterful Garnet", "Flawless Deadly Peridot"},
        enchants = {
            "Weapon: Rune of the Apocalypse",
            "Head: Empowered Rune of Avoidance",
            "Shoulders: Amirdrassil's Grace",
            "Chest: Crystalline Radiance",
            "Legs: Forest Hunter's Armor Kit",
            "Boots: Lynx's Dexterity",
            "Rings: Zul'jin's Mastery",
            "Sockets: Radiant Jewelbinder"
        },
        consumables = {
            {type="Food", name="Harandar Celebration / Silvermoon Parade"},
            {type="Flask", name="Flask of the Shattered Sun"},
            {type="Combat Potion", name="Potion of Recklessness"},
            {type="Health Potion", name="Silvermoon Health Potion"},
            {type="Weapon Buff", name="Thalassian Phoenix Oil"},
            {type="Augment Rune", name="Void-Touched Augment Rune"}
        }
    },
    -- DEMON HUNTER
    [577] = { -- Havoc
        stats = {"Agility", "Crit", "Mastery", "Haste", "Versatility"},
        gems = {"Culminating Blasphemite", "Deadly Onyx"},
        enchants = {E.AuthStorms, E.ChestAgility, E.LegsStormbound},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Stone", id=224103}}
    },
    [581] = { -- Vengeance
        stats = {"Agility", "Haste", "Versatility", "Crit", "Mastery"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthFiery, E.ChestJuggernaut},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212265}, {type="Potion", id=212257}, {type="Stone", id=224103}}
    },
    [582] = { -- Devourer (New Spec)
        stats = {"Intellect", "Haste", "Mastery", "Crit", "Versatility"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Oil", id=224107}}
    },
    -- DRUID
    [102] = { -- Balance
        stats = {"Intellect", "Haste", "Mastery", "Crit", "Versatility"},
        gems = {"Culminating Blasphemite", "Masterful Sapphire"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Oil", id=224107}}
    },
    [103] = { -- Feral
        stats = {"Agility", "Crit", "Mastery", "Versatility", "Haste"},
        gems = {"Culminating Blasphemite", "Deadly Onyx"},
        enchants = {E.AuthStorms, E.ChestAgility},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Stone", id=224103}}
    },
    [104] = { -- Guardian
        stats = {"Agility", "Haste", "Versatility", "Mastery", "Crit"},
        gems = {"Elusive Blasphemite", "Versatile Emerald"},
        enchants = {E.Oathsworn, E.ChestRadiance, E.LegsStormbound, E.WristLeech, E.CloakGrace, E.BootsMarch, E.RingHaste},
        consumables = {
            {type="Food", id=222744}, {type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, 
            {type="Weapon Buff", id=224107}, {type="Augment Rune", id=224572}, {type="Health Potion", id=211880}
        }
    },
    [105] = { -- Restoration
        stats = {"Intellect", "Haste", "Mastery", "Versatility", "Crit"},
        gems = {"Elusive Blasphemite", "Masterful Emerald"},
        enchants = {E.AuthStorms, E.ChestRadiance, E.LegsSunset, E.WristLeech, E.CloakLeech, E.BootsMarch, E.RingHaste},
        consumables = {
            {type="Food", id=222744}, {type="Flask", id=212265}, {type="Potion", id=212257}, 
            {type="Weapon Buff", id=224107}, {type="Augment Rune", id=224572}, {type="Health Potion", id=211880}
        }
    },
    -- EVOKER
    [1467] = { -- Devastation
        stats = {"Intellect", "Mastery", "Crit", "Haste", "Versatility"},
        gems = {"Culminating Blasphemite", "Masterful Sapphire"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Oil", id=224107}}
    },
    [1468] = { -- Preservation
        stats = {"Intellect", "Crit", "Mastery", "Haste", "Versatility"},
        gems = {"Culminating Blasphemite", "Deadly Onyx"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212241}, {type="Oil", id=224107}}
    },
    [1473] = { -- Augmentation
        stats = {"Intellect", "Mastery", "Haste", "Crit", "Versatility"},
        gems = {"Culminating Blasphemite", "Masterful Sapphire"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Oil", id=224107}}
    },
    -- HUNTER
    [253] = { -- Beast Mastery
        stats = {"Weapon Damage", "Crit", "Haste", "Mastery", "Versatility", "Agility"},
        gems = {"Culminating Blasphemite", "Deadly Onyx", "Quick Ruby", "Deadly Sapphire", "Deadly Emerald"},
        enchants = {E.WeaponGuile, E.CloakGrace, E.ChestRadiance, E.LegsStormbound, E.WristLeech, E.BootsMarch, E.RingCrit},
        consumables = {
            {type="Flask", id=212264}, {type="Augment Rune", id=224572}, {type="Weapon Buff", id=224107},
            {type="Combat Potion", id=212257}, {type="Health Potion", id=211880}, {type="Food", id=222735}
        }
    },
    [254] = { -- Marksmanship
        stats = {"Agility", "Crit", "Mastery", "Haste", "Versatility"},
        gems = {"Culminating Blasphemite", "Deadly Onyx", "Masterful Ruby", "Deadly Sapphire", "Deadly Emerald"},
        enchants = {E.AuthRadiant, E.CloakGrace, E.ChestRadiance, E.LegsStormbound, E.WristLeech, E.BootsScout, E.RingCrit},
        consumables = {
            {type="Flask", id=212264}, {type="Augment Rune", id=224572}, {type="Weapon Buff", id=224107},
            {type="Combat Potion", id=212257}, {type="Health Potion", id=211880}, {type="Food", id=222735}
        }
    },
    [255] = { -- Survival
        stats = {"Agility", "Mastery", "Crit", "Haste", "Versatility"},
        gems = {"Culminating Blasphemite", "Deadly Onyx"},
        enchants = {E.WeaponGuile, E.WeaponStonebound, E.CloakLeech, E.ChestRadiance, E.LegsStormbound, E.WristLeech, E.BootsMarch, E.RingMastery},
        consumables = {
            {type="Flask", id=212264}, {type="Augment Rune", id=224572}, {type="Weapon Buff", id=224107},
            {type="Combat Potion", id=212257}, {type="Health Potion", id=211880}, {type="Food", id=222735}
        }
    },
    -- MAGE
    [62] = { -- Arcane
        stats = {"Intellect", "Crit", "Mastery", "Haste", "Versatility"},
        gems = {"Culminating Blasphemite", "Deadly Onyx"},
        enchants = {E.AuthRadiant, E.ChestIntellect, E.LegsSunset, E.RingCrit, E.WristSpeed, E.CloakGrace, E.BootsMarch},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Oil", id=224107}}
    },
    [63] = { -- Fire
        stats = {"Intellect", "Haste", "Versatility", "Mastery", "Crit"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthRadiant, E.ChestIntellect, E.LegsSunset, E.RingHaste, E.WristSpeed, E.CloakGrace, E.BootsMarch},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Oil", id=224107}}
    },
    [64] = { -- Frost
        stats = {"Intellect", "Mastery", "Crit", "Haste", "Versatility"},
        gems = {"Culminating Blasphemite", "Masterful Sapphire"},
        enchants = {E.AuthRadiant, E.ChestIntellect, E.LegsSunset, E.RingMastery, E.WristSpeed, E.CloakGrace, E.BootsMarch},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Oil", id=224107}}
    },
    -- MONK
    [268] = { -- Brewmaster
        stats = {"Agility", "Crit", "Versatility", "Mastery", "Haste"},
        gems = {"Culminating Blasphemite", "Deadly Onyx"},
        enchants = {E.AuthFiery, E.ChestJuggernaut},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212265}, {type="Potion", id=212257}, {type="Stone", id=224103}}
    },
    [270] = { -- Mistweaver
        stats = {"Intellect", "Haste", "Crit", "Versatility", "Mastery"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212241}, {type="Oil", id=224107}}
    },
    [269] = { -- Windwalker
        stats = {"Agility", "Versatility", "Crit", "Mastery", "Haste"},
        gems = {"Culminating Blasphemite", "Versatile Emerald"},
        enchants = {E.AuthStorms, E.ChestAgility},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Stone", id=224103}}
    },
    -- PALADIN
    [65] = { -- Holy
        stats = {"Intellect", "Haste", "Mastery", "Versatility", "Crit"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212241}, {type="Oil", id=224107}}
    },
    [66] = { -- Protection
        stats = {"Strength", "Haste", "Mastery", "Versatility", "Crit"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthFiery, E.ChestJuggernaut},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212265}, {type="Potion", id=212257}, {type="Stone", id=224103}}
    },
    [70] = { -- Retribution
        stats = {"Strength", "Mastery", "Crit", "Versatility", "Haste"},
        gems = {"Culminating Blasphemite", "Masterful Sapphire"},
        enchants = {E.AuthStorms, E.ChestStrength},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Stone", id=224103}}
    },
    -- PRIEST
    [256] = { -- Discipline
        stats = {"Intellect", "Haste", "Crit", "Mastery", "Versatility"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212241}, {type="Oil", id=224107}}
    },
    [257] = { -- Holy
        stats = {"Intellect", "Crit", "Mastery", "Versatility", "Haste"},
        gems = {"Culminating Blasphemite", "Masterful Sapphire"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212241}, {type="Oil", id=224107}}
    },
    [258] = { -- Shadow
        stats = {"Intellect", "Haste", "Mastery", "Crit", "Versatility"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Oil", id=224107}}
    },
    -- ROGUE
    [259] = { -- Assassination
        stats = {"Agility", "Crit", "Mastery", "Haste", "Versatility"},
        gems = {"Culminating Blasphemite", "Deadly Onyx"},
        enchants = {E.AuthStorms, E.ChestAgility},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}}
    },
    [260] = { -- Outlaw
        stats = {"Agility", "Crit", "Haste", "Versatility", "Mastery"},
        gems = {"Culminating Blasphemite", "Versatile Emerald"},
        enchants = {E.Oathsworn, E.WeaponGuile, E.CloakGrace, E.ChestRadiance, E.LegsStormbound, E.WristLeech, E.BootsMarch, E.RingVers},
        consumables = {
            {type="Flask", id=212264}, {type="Augment Rune", id=224572}, {type="Weapon Buff", id=222468},
            {type="Combat Potion", id=212257}, {type="Health Potion", id=211880}, {type="Food", id=222744}
        }
    },
    [261] = { -- Subtlety
        stats = {"Agility", "Mastery", "Crit", "Versatility", "Haste"},
        gems = {"Culminating Blasphemite", "Masterful Sapphire"},
        enchants = {E.AuthStorms, E.ChestAgility},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}}
    },
    -- SHAMAN
    [262] = { -- Elemental
        stats = {"Intellect", "Haste", "Crit", "Versatility", "Mastery"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Oil", id=224107}}
    },
    [263] = { -- Enhancement
        stats = {"Agility", "Haste", "Mastery", "Crit", "Versatility"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthStorms, E.ChestAgility},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}}
    },
    [264] = { -- Restoration
        stats = {"Intellect", "Crit", "Versatility", "Haste", "Mastery"},
        gems = {"Culminating Blasphemite", "Deadly Onyx"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212241}, {type="Oil", id=224107}}
    },
    -- WARLOCK
    [265] = { -- Affliction
        stats = {"Intellect", "Haste", "Mastery", "Crit", "Versatility"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Oil", id=224107}}
    },
    [266] = { -- Demonology
        stats = {"Intellect", "Haste", "Crit", "Mastery", "Versatility"},
        gems = {"Elusive Blasphemite", "Masterful Emerald"},
        enchants = {E.AuthRadiant, E.ChestRadiance, E.LegsSunset, E.WristLeech, E.CloakGrace, E.BootsMarch, E.RingHaste},
        consumables = {
            {type="Food", id=222744}, {type="Flask", id=212264}, {type="Potion", id=212257}, 
            {type="Weapon Buff", id=224107}, {type="Augment Rune", id=224572}, {type="Health Potion", id=211880}
        }
    },
    [267] = { -- Destruction
        stats = {"Intellect", "Haste", "Mastery", "Crit", "Versatility"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthRadiant, E.ChestIntellect},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Oil", id=224107}}
    },
    -- WARRIOR
    [71] = { -- Arms
        stats = {"Strength", "Crit", "Haste", "Mastery", "Versatility"},
        gems = {"Culminating Blasphemite", "Deadly Onyx"},
        enchants = {E.AuthStorms, E.ChestStrength},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Stone", id=224103}}
    },
    [72] = { -- Fury
        stats = {"Strength", "Mastery", "Haste", "Versatility", "Crit"},
        gems = {"Culminating Blasphemite", "Masterful Sapphire"},
        enchants = {E.AuthStorms, E.ChestStrength},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212264}, {type="Potion", id=212257}, {type="Stone", id=224103}}
    },
    [73] = { -- Protection
        stats = {"Strength", "Haste", "Versatility", "Mastery", "Crit"},
        gems = {"Culminating Blasphemite", "Quick Ruby"},
        enchants = {E.AuthFiery, E.ChestJuggernaut},
        consumables = {{type="Food", id=222735}, {type="Flask", id=212265}, {type="Potion", id=212257}, {type="Stone", id=224103}}
    },
}

-- 2. UI CREATION
local tabFrame = nil
local contentFrame = nil
local widgetPool = {
    fontStrings = {},
    textures = {},
    rowButtons = {},
    infoButtons = {},
}

local function ReleaseWidgets()
    for _, pool in pairs(widgetPool) do
        for _, widget in ipairs(pool) do
            widget:Hide()
            widget:ClearAllPoints()
        end
    end
end

local function GetFontString(parent, style)
    for _, fs in ipairs(widgetPool.fontStrings) do
        if not fs:IsShown() then
            fs:SetParent(parent)
            fs:SetFontObject(style)
            fs:Show()
            return fs
        end
    end
    local fs = parent:CreateFontString(nil, "OVERLAY", style)
    table.insert(widgetPool.fontStrings, fs)
    fs:Show()
    return fs
end

local function GetTexture(parent)
    for _, tex in ipairs(widgetPool.textures) do
        if not tex:IsShown() then
            tex:SetParent(parent)
            tex:SetColorTexture(0,0,0,0)
            tex:SetTexture(nil)
            tex:Show()
            return tex
        end
    end
    local tex = parent:CreateTexture(nil, "ARTWORK")
    table.insert(widgetPool.textures, tex)
    tex:Show()
    return tex
end

local function GetRowButton(parent)
    for _, btn in ipairs(widgetPool.rowButtons) do
        if not btn:IsShown() then
            btn:SetParent(parent)
            btn:Show()
            return btn
        end
    end
    local btn = CreateFrame("Button", nil, parent)
    btn:SetHeight(14)
    btn.text = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.text:SetPoint("LEFT", 0, 0)
    btn.icon = btn:CreateTexture(nil, "ARTWORK")
    btn.icon:SetSize(14, 14)
    btn.icon:SetPoint("LEFT", 0, 0)
    btn.icon:Hide()
    btn.rightText = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    btn.rightText:SetPoint("RIGHT", 0, 0)
    table.insert(widgetPool.rowButtons, btn)
    return btn
end

local function GetInfoButton(parent)
    for _, btn in ipairs(widgetPool.infoButtons) do
        if not btn:IsShown() then
            btn:SetParent(parent)
            btn:Show()
            return btn
        end
    end
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(16, 16)
    btn:SetNormalTexture("Interface\\common\\help-i")
    table.insert(widgetPool.infoButtons, btn)
    return btn
end

local function CreateCategoryHeader(parent, text, yOffset, showInfo)
    local header = GetFontString(parent, "GameFontNormal")
    header:SetPoint("TOPLEFT", 10, yOffset)
    header:SetText(text)
    -- header:SetTextColor(1, 0.82, 0) -- GameFontNormal is already gold
    
    if showInfo then
        local infoBtn = GetInfoButton(parent)
        infoBtn:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, yOffset + 2)
        infoBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText("Stat Priority", 1, 1, 1)
            GameTooltip:AddLine("All values are for current Class, Spec and Hero choices.", nil, nil, nil, true)
            GameTooltip:Show()
        end)
        infoBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    local line = GetTexture(parent)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 10, yOffset - 14)
    line:SetPoint("RIGHT", -10, 0)
    line:SetColorTexture(1, 1, 1, 0.2)
    
    return yOffset - 20
end

local function CreateTextRow(parent, text, yOffset, color, rightText, tooltipData, iconTexture)
    local btn = GetRowButton(parent)
    btn:SetPoint("TOPLEFT", 20, yOffset)
    btn:SetPoint("RIGHT", -20, 0)
    
    if iconTexture then
        btn.icon:SetTexture(iconTexture)
        btn.icon:Show()
        btn.text:SetPoint("LEFT", btn.icon, "RIGHT", 5, 0)
    else
        btn.icon:Hide()
        btn.text:SetPoint("LEFT", 0, 0)
    end

    btn.text:SetText(text)
    if color then btn.text:SetTextColor(unpack(color)) else btn.text:SetTextColor(1, 1, 1) end

    if rightText then
        btn.rightText:SetText(rightText)
        btn.rightText:Show()
        if color then btn.rightText:SetTextColor(unpack(color)) else btn.rightText:SetTextColor(1, 1, 1) end
    else
        btn.rightText:Hide()
    end

    if tooltipData then
        btn:EnableMouse(true)
        btn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            if tooltipData.type == "item" then
                GameTooltip:SetItemByID(tooltipData.id)
            elseif tooltipData.type == "spell" then
                GameTooltip:SetSpellByID(tooltipData.id)
            end
            GameTooltip:Show()
        end)
        btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
    else
        btn:EnableMouse(false)
        btn:SetScript("OnEnter", nil)
        btn:SetScript("OnLeave", nil)
    end

    return yOffset - 16
end

local function CreateIconRow(parent, icon, text, yOffset)
    local tex = GetTexture(parent)
    tex:SetSize(14, 14)
    tex:SetPoint("TOPLEFT", 20, yOffset)
    tex:SetTexture(icon)
    
    local fs = GetFontString(parent, "GameFontHighlightSmall")
    fs:SetPoint("LEFT", tex, "RIGHT", 5, 0)
    fs:SetText(text)
    
    return yOffset - 16
end

local function GetStatString(statName)
    -- Primary Stats: Show Current Value
    if statName == "Strength" then
        local _, val = UnitStat("player", 1)
        return BreakUpLargeNumbers(val)
    elseif statName == "Agility" then
        local _, val = UnitStat("player", 2)
        return BreakUpLargeNumbers(val)
    elseif statName == "Intellect" then
        local _, val = UnitStat("player", 4)
        return BreakUpLargeNumbers(val)
    elseif statName == "Stamina" then
        local _, val = UnitStat("player", 3)
        return BreakUpLargeNumbers(val)
    end

    -- Secondary Stats: Show DR Threshold (30%)
    local ratingID
    if statName == "Crit" then ratingID = CR_CRIT_MELEE
    elseif statName == "Haste" then ratingID = CR_HASTE_MELEE
    elseif statName == "Mastery" then ratingID = CR_MASTERY
    elseif statName == "Versatility" then ratingID = CR_VERSATILITY_DAMAGE_DONE
    end

    if ratingID then
        local currentRating = GetCombatRating(ratingID)
        local currentBonus = GetCombatRatingBonus(ratingID) -- % from rating
        if currentBonus and currentBonus > 0 then
            local ratio = currentRating / currentBonus
            local capRating = ratio * 30
            return string.format("|cffffd100%s|r |cffaaaaaa(30%%)|r", BreakUpLargeNumbers(math.floor(capRating + 0.5)))
        end
        return "|cff808080(N/A)|r"
    end
    return ""
end

local function UpdateContent()
    if not contentFrame then return end
    ReleaseWidgets()

    local specIndex = GetSpecialization()
    if not specIndex then return end
    local specID = GetSpecializationInfo(specIndex)
    
    local data = SpecPrefs[specID]
    -- Support dynamic data generation (e.g. for Hero Talents)
    if type(data) == "function" then data = data() end
    
    if not data then
        local fs = GetFontString(contentFrame.scrollChild, "GameFontNormal")
        fs:SetPoint("CENTER")
        fs:SetText("No preference data available for this specialization.")
        return
    end

    local y = -10
    
    -- 1. Stat Weights
    y = CreateCategoryHeader(contentFrame.scrollChild, "Stat Weights", y, true)
    for i, stat in ipairs(data.stats) do
        local color = (i == 1) and {0, 1, 0} or {1, 1, 1} -- Green for primary
        local valStr = GetStatString(stat)
        y = CreateTextRow(contentFrame.scrollChild, i .. ". " .. stat, y, color, valStr)
    end
    y = y - 10

    -- 2. Gems
    y = CreateCategoryHeader(contentFrame.scrollChild, "Gems", y)
    for _, gem in ipairs(data.gems) do
        local gemName = type(gem) == "table" and gem.text or gem
        local gemID = type(gem) == "table" and gem.id or nil
        
        -- Determine Socket Color
        local socketIcon = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic"
        if gemName:find("Blasphemite") then socketIcon = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Meta"
        elseif gemName:find("Ruby") then socketIcon = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Red"
        elseif gemName:find("Sapphire") then socketIcon = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Blue"
        elseif gemName:find("Emerald") then socketIcon = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Green"
        elseif gemName:find("Onyx") then socketIcon = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic" -- Often hybrid/purple
        elseif gemName:find("Amber") then socketIcon = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Yellow"
        elseif gemName:find("Diamond") then socketIcon = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Meta"
        elseif gemName:find("Amethyst") then socketIcon = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Prismatic"
        elseif gemName:find("Garnet") then socketIcon = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Red"
        elseif gemName:find("Peridot") then socketIcon = "Interface\\ItemSocketingFrame\\UI-EmptySocket-Green"
        end

        local tooltipData = nil
        if gemID then
            tooltipData = {type="item", id=gemID}
        end

        -- Use CreateTextRow to support tooltips if ID is present
        y = CreateTextRow(contentFrame.scrollChild, gemName, y, nil, nil, tooltipData, socketIcon)
    end
    y = y - 10

    -- 3. Enchants
    y = CreateCategoryHeader(contentFrame.scrollChild, "Enchants", y)
    for _, enchant in ipairs(data.enchants) do
        local text = enchant
        local tooltipData = nil
        if type(enchant) == "table" then
            text = enchant.text
            if enchant.id then 
                tooltipData = {type=enchant.type or "item", id=enchant.id} 
            end
        end
        y = CreateTextRow(contentFrame.scrollChild, text, y, nil, nil, tooltipData)
    end
    y = y - 10

    -- 4. Consumables
    y = CreateCategoryHeader(contentFrame.scrollChild, "Consumables", y)
    for _, cons in ipairs(data.consumables) do
        local itemName = cons.name or (cons.id and C_Item.GetItemNameByID(cons.id)) or "Unknown Item"
        local text = cons.type .. ": " .. itemName
        
        -- Determine Icon
        local icon = nil
        if cons.type == "Food" then icon = 136000 -- Spell_Misc_Food (Well Fed)
        elseif cons.type == "Combat Potion" then icon = cons.id and C_Item.GetItemIconByID(cons.id) or 134877
        elseif cons.type == "Health Potion" then icon = 132095 -- inv_potion_51 (Red)
        elseif cons.type == "Augment Rune" then icon = 134419 -- inv_misc_rune_01
        elseif cons.type == "Flask" then icon = 134877 -- inv_potion_119
        elseif cons.type == "Weapon Buff" then icon = 135274 -- inv_sword_04
        else icon = cons.id and C_Item.GetItemIconByID(cons.id) or 136121 end

        -- Clean up text to just show Item Name if icon is present and type is generic
        text = itemName

        local tooltipData = cons.id and {type="item", id=cons.id} or nil
        y = CreateTextRow(contentFrame.scrollChild, text, y, nil, nil, tooltipData, icon)
        
        -- Request load if name missing
        if cons.id and not C_Item.GetItemNameByID(cons.id) then
            C_Item.RequestLoadItemDataByID(cons.id)
        end
    end

    contentFrame.scrollChild:SetHeight(math.abs(y) + 20)
end

local function InitGearPrefsTab()
    if not CharacterFrame then return end
    if tabFrame then return end -- Prevent duplicate creation

    -- Create Sidebar Tab (Button)
    -- Parent to PaperDollSidebarTabs so it inherits visibility/strata from the sidebar system
    -- Manually create button to avoid template OnLoad errors in Beta
    tabFrame = CreateFrame("Button", "ZipTrixGearPrefsTab", PaperDollSidebarTabs)
    tabFrame:SetSize(33, 35)
    tabFrame:SetID(4) -- Custom ID

    -- Background (Active State)
    local tabBg = tabFrame:CreateTexture(nil, "BACKGROUND")
    tabBg:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Real-Hilight")
    tabBg:SetPoint("TOPLEFT", 1, 5)
    tabBg:SetPoint("BOTTOMRIGHT", -1, 1)
    tabBg:SetTexCoord(0.1953125, 0.8046875, 0.005, 0.995)
    tabBg:Hide()
    tabFrame.TabBg = tabBg
    
    -- Set Icon
    local icon = tabFrame:CreateTexture(nil, "ARTWORK")
    icon:SetTexture("Interface\\Icons\\Ability_Rogue_TricksOfTheTrade")
    icon:SetPoint("BOTTOMRIGHT", -1, 1)
    icon:SetSize(30, 30)
    tabFrame.Icon = icon

    -- Highlight
    local highlight = tabFrame:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-Tab-Highlight")
    highlight:SetPoint("TOPLEFT", 1, 5)
    highlight:SetPoint("BOTTOMRIGHT", -1, 1)
    highlight:SetTexCoord(0.1953125, 0.8046875, 0.005, 0.995)
    highlight:SetBlendMode("ADD")
    tabFrame.Highlight = highlight
    
    -- Hider (Hides the frame border when active)
    local hider = tabFrame:CreateTexture(nil, "ARTWORK")
    hider:SetTexture("Interface\\PaperDollInfoFrame\\PaperDollSidebarTabs")
    hider:SetPoint("BOTTOMRIGHT", 1, 1)
    hider:SetSize(33, 35)
    hider:SetTexCoord(0.01562500, 0.53125000, 0.32421875, 0.59765625)
    hider:Hide()
    tabFrame.Hider = hider

    -- Custom SetChecked
    function tabFrame:SetChecked(checked)
        if checked then
            self.TabBg:Show()
            self.Hider:Show()
        else
            self.TabBg:Hide()
            self.Hider:Hide()
        end
    end
    
    -- Tooltip
    tabFrame.tooltip = "Gear Preferences"
    tabFrame:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetText(self.tooltip)
        GameTooltip:Show()
    end)
    tabFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)

    -- Anchor: To the right of the Equipment Manager (Tab 3)
    local equipTab = _G["PaperDollSidebarTab3"]
    if equipTab then
        tabFrame:SetPoint("LEFT", equipTab, "RIGHT", 4, 0)
    else
        -- Fallback if Equip Manager is missing
        tabFrame:SetPoint("BOTTOMRIGHT", CharacterFrameInsetRight, "TOPRIGHT", -4, -40)
    end
    
    -- Create Content Frame
    -- Anchor to CharacterFrameInsetRight (where Stats/Titles/Equip Manager live)
    contentFrame = CreateFrame("ScrollFrame", "ZipTrixCharStatsPane", CharacterFrameInsetRight, "UIPanelScrollFrameTemplate")
    contentFrame:SetPoint("TOPLEFT", 0, -5)
    contentFrame:SetPoint("BOTTOMRIGHT", -25, 5)
    contentFrame:Hide()
    contentFrame:SetFrameLevel(CharacterFrameInsetRight:GetFrameLevel() + 10) -- Ensure it sits above other panels

    -- Add Background to prevent transparency issues
    local bg = contentFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0.05, 0.05, 0.05, 0.9)
    
    local scrollChild = CreateFrame("Frame")
    scrollChild:SetSize(contentFrame:GetWidth(), 500)
    contentFrame:SetScrollChild(scrollChild)
    contentFrame.scrollChild = scrollChild

    contentFrame:SetScript("OnSizeChanged", function(self, width, height)
        if self.scrollChild then
            self.scrollChild:SetWidth(width)
        end
    end)

    -- Click Handler
    tabFrame:SetScript("OnClick", function(self)
        -- 0. Update Blizzard's state tracker immediately
        if PaperDollFrame then PaperDollFrame.currentSideBar = self:GetID() end

        -- 1. Reset standard tabs
        for i = 1, 3 do
            local tab = _G["PaperDollSidebarTab"..i]
            if tab then
                if tab.SetChecked then
                    tab:SetChecked(false)
                elseif tab.TabBg and tab.Hider then
                    tab.TabBg:Hide()
                    tab.Hider:Hide()
                end
            end
        end
        
        -- 2. Set self checked
        self:SetChecked(true)
        
        -- 3. Hide standard panes
        if CharacterStatsPane then CharacterStatsPane:Hide() end
        if PaperDollTitlesPane then PaperDollTitlesPane:Hide() end
        if PaperDollEquipmentManagerPane then PaperDollEquipmentManagerPane:Hide() end
        
        -- 4. Show our pane
        contentFrame:Show()

        UpdateContent()
    end)
    
    -- Hook Blizzard Sidebar Switch to reset us when other tabs are clicked
    if PaperDollFrame_SetSidebar then
        hooksecurefunc("PaperDollFrame_SetSidebar", function(self, index)
            if tabFrame and index ~= 4 then
                tabFrame:SetChecked(false)
                contentFrame:Hide()
            end
        end)
    end

    -- Hook Blizzard Sidebar Update to enforce our panel visibility when the UI refreshes
    if PaperDollFrame_UpdateSidebar then
        hooksecurefunc("PaperDollFrame_UpdateSidebar", function(self)
            if self.currentSideBar == 4 then
                if CharacterStatsPane then CharacterStatsPane:Hide() end
                if PaperDollTitlesPane then PaperDollTitlesPane:Hide() end
                if PaperDollEquipmentManagerPane then PaperDollEquipmentManagerPane:Hide() end
                if contentFrame then contentFrame:Show() end
                if tabFrame then tabFrame:SetChecked(true) end
            end
        end)
    end

    -- Hook Blizzard Character Stats to show Rating inline
    local function HookBlizzardStat(frame, ratingID)
        if not frame or not frame.Value then return end
        local rating = GetCombatRating(ratingID)
        local text = frame.Value:GetText()
        -- Prevent double appending by checking if rating is already present
        if rating > 0 and text then
            -- Wrap in pcall to avoid secret string value taint errors
            local ok, found = pcall(string.find, text, BreakUpLargeNumbers(rating), 1, true)
            if ok and not found then
                pcall(function() frame.Value:SetText(string.format("|cffffd100%s|r %s", BreakUpLargeNumbers(rating), text)) end)
            end
        end
    end

    if PaperDollFrame_SetCritChance then
        hooksecurefunc("PaperDollFrame_SetCritChance", function(statFrame) HookBlizzardStat(statFrame, CR_CRIT_MELEE) end)
        hooksecurefunc("PaperDollFrame_SetHaste", function(statFrame) HookBlizzardStat(statFrame, CR_HASTE_MELEE) end)
        hooksecurefunc("PaperDollFrame_SetVersatility", function(statFrame) HookBlizzardStat(statFrame, CR_VERSATILITY_DAMAGE_DONE) end)
        hooksecurefunc("PaperDollFrame_SetMastery", function(statFrame) HookBlizzardStat(statFrame, CR_MASTERY) end)
    end
end

-- 3. INITIALIZATION
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "PLAYER_LOGIN" then
        InitGearPrefsTab()
    elseif event == "ADDON_LOADED" and arg1 == "Blizzard_CharacterFrame" then
        InitGearPrefsTab()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        if contentFrame and contentFrame:IsVisible() then
            UpdateContent()
        end
    end
end)