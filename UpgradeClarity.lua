local addonName, ns = ...

-- Internal Localization (English)
local localizations = {
    UPGRADE_TRACK_NAME_EXPLORER = "Explorer",
    UPGRADE_TRACK_NAME_ADVENTURER = "Adventurer",
    UPGRADE_TRACK_NAME_VETERAN = "Veteran",
    UPGRADE_TRACK_NAME_CHAMPION = "Champion",
    UPGRADE_TRACK_NAME_HERO = "Hero",
    UPGRADE_TRACK_NAME_MYTH = "Myth",
    CREST_NAME_EXPLORER = "Explorer's Dawncrest",
    CREST_NAME_ADVENTURER = "Adventurer's Dawncrest",
    CREST_NAME_VETERAN = "Veteran's Dawncrest",
    CREST_NAME_CHAMPION = "Champion's Dawncrest",
    CREST_NAME_HEROIC = "Hero Dawncrest",
    CREST_NAME_MYTHIC = "Myth Dawncrest",
    HEADER_CREST_CURRENT = "Upgrade Cost",
    HEADER_UPGRADE_CRESTS = "Upgrade Clarity",
    DEFAULT_CURRENCY_SOURCE = "Various Activities",
    SOURCE_AND_ABOVE = "and above",
}

-- Local References
local error, floor, ipairs, pairs, rawset, select, setmetatable,
        strlower, strmatch, tconcat, tinsert, tonumber, type =
      error, floor, ipairs, pairs, rawset, select, setmetatable,
        strlower, strmatch, table.concat, tinsert, tonumber, type

local API_AddTooltipPostCall = TooltipDataProcessor.AddTooltipPostCall
local API_CreateFrame = CreateFrame
local API_GameTooltip, API_GameTooltipTooltip, API_ItemRefTooltip, API_ShoppingTooltip1, API_ShoppingTooltip2 =
      GameTooltip, GameTooltipTooltip, ItemRefTooltip, ShoppingTooltip1, ShoppingTooltip2
local API_GetAchievementInfo = GetAchievementInfo
local API_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local API_GetDifficultyName = DifficultyUtil.GetDifficultyName
local API_GetDisplayedItem = TooltipUtil.GetDisplayedItem
local API_GetItemInfo = C_Item.GetItemInfo
local API_GetSpellDisplayVisualizationInfo = C_UIWidgetManager.GetSpellDisplayVisualizationInfo
local API_Item = Item

local DIFFICULTY_IDS = DifficultyUtil.ID
local DELVES, DUNGEONS, RAIDS, RITUAL_SITES = DELVES_LABEL, DUNGEONS, RAIDS, "Ritual Sites"
local GARRISON_TIER = GARRISON_TIER
local HEADER_COLON = HEADER_COLON
local ITEM_QUALITY_COLORS = ITEM_QUALITY_COLORS
local ITEM_UPGRADE_TOOLTIP_FORMAT_STRING = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
local TOOLTIP_TYPE_ITEM = Enum.TooltipDataType.Item

-- Upgrade Cost Information
local UPGRADE_COST_CRESTS_ALL = 20
local UPGRADE_ILEVEL_LOWER_LIMIT = 100 -- Updated for Twilight Highlands event gear (starts at 121)
local UPGRADE_SEASON_INFO = {
    [1] = { -- Explorer's Dawncrest
        currency_id = 4001, -- Placeholder ID
    },
    [2] = { -- Adventurer's Dawncrest
        currency_id = 4002, -- Placeholder ID
    },
    [3] = { -- Veteran's Dawncrest
        currency_id = 4003, -- Placeholder ID
    },
    [4] = { -- Champion's Dawncrest
        currency_id = 4004, -- Placeholder ID
    },
    [5] = { -- Heroic Dawncrest
        currency_id = 4005, -- Placeholder ID
    },
    [6] = { -- Mythic Dawncrest
        currency_id = 4006, -- Placeholder ID
    },
}

-- Upgrade Track Item Level Information
local BAND_COUNT = 4
local BAND_SPACING = 3
local BAND_ADJUSTMENT = 1

-- Data Structures
local item_refs = setmetatable({}, {
    __call = function(self, item_ids)
        for _, item_id in ipairs(item_ids) do
            local item = API_Item:CreateFromItemID(item_id)
            item:ContinueOnItemLoad(function()
                rawset(self, item_id, {
                    icon = item:GetItemIcon()
                })
            end)
        end
    end,
    __newindex = function()
        error("Assignment error: \"item_refs\" cannot be directly assigned attributes.")
    end,
})
-- item_refs({233071}) -- Delver's Bounty ID (Update if needed for TWW)

-- Table containing mappings of the localized names of dungeon and raid difficulties.
local difficulty_names = setmetatable({}, {
    __call = function(self, identifiers)
        for _, identifier in ipairs(identifiers) do
            local difficulty_type_dungeon = strmatch(identifier, "^Dungeon(.+)")
            local difficulty_type_raid = strmatch(identifier, "^PrimaryRaid(.+)")
            local location_type = difficulty_type_dungeon and "dungeon" or difficulty_type_raid and "raid"

            if not location_type then return end
            if not self[location_type] then
                rawset(self, location_type, setmetatable({}, {
                    __call = function(self, difficulty_type, difficulty_name)
                        rawset(self, difficulty_type, difficulty_name)
                    end,
                    __newindex = function()
                        error(
                            "Assignment error: \"difficulty_names."..location_type
                                .."\" cannot be directly assigned attributes."
                        )
                    end,
                }))
            end

            local difficulty_type = strlower(difficulty_type_dungeon or difficulty_type_raid)
            self[location_type](difficulty_type, API_GetDifficultyName(DIFFICULTY_IDS[identifier]))
        end
    end,
    __newindex = function()
        error("Assignment error: \"difficulty_names\" cannot be directly assigned attributes.")
    end,
})
difficulty_names({
    "DungeonHeroic",
    "DungeonMythic",
    "DungeonChallenge", -- Mythic+
    "PrimaryRaidLFR",
    "PrimaryRaidNormal",
    "PrimaryRaidHeroic",
    "PrimaryRaidMythic",
})

-- Table containing mappings of the localized upgrade track names to the relevant indices.
local upgrade_mapping = setmetatable({}, {
    __call = function(self, upgrade_tracks)
        for index, upgrade_track_name in ipairs(upgrade_tracks) do
            rawset(self, localizations[upgrade_track_name], index)
        end
    end,
    __newindex = function()
        error("Assignment error: \"upgrade_mapping\" assignments must be done through function call.")
    end,
})
upgrade_mapping({
    "UPGRADE_TRACK_NAME_EXPLORER",
    "UPGRADE_TRACK_NAME_ADVENTURER",
    "UPGRADE_TRACK_NAME_VETERAN",
    "UPGRADE_TRACK_NAME_CHAMPION",
    "UPGRADE_TRACK_NAME_HERO",
    "UPGRADE_TRACK_NAME_MYTH",
})

-- Table containing data regarding non-crafted upgrade tracks.
local upgrade_tracks = {
    [1] = { -- Explorer
        color = ITEM_QUALITY_COLORS[1].hex,
    },
    [2] = { -- Adventurer
        color = "|cffffff00",
    },
    [3] = { -- Veteran
        color = "|cff7eff00",
    },
    [4] = { -- Champion
        color = "|cff8b30ff",
    },
    [5] = { -- Hero
        color = "|cffff2eff",
    },
    [6] = { -- Myth
        color = "|cffff0026",
    },
}

local upgrade_crests = {
    [1] = { -- Explorer
        currency_id = UPGRADE_SEASON_INFO[1].currency_id,
        name = localizations.CREST_NAME_EXPLORER,
        sources = {
            delve = { levels = {1, 3} },
            dungeon = { type = difficulty_names.dungeon.normal },
            other = "Outdoor Activities",
        },
    },
    [2] = { -- Adventurer
        currency_id = UPGRADE_SEASON_INFO[2].currency_id,
        name = localizations.CREST_NAME_ADVENTURER,
        sources = {
            delve = { levels = {4, 7} },
            dungeon = { type = difficulty_names.dungeon.heroic },
            other = "Prey Hunts",
        },
    },
    [3] = { -- Veteran
        currency_id = UPGRADE_SEASON_INFO[3].currency_id,
        name = localizations.CREST_NAME_VETERAN,
        sources = {
            delve = { levels = {8, 11} },
            dungeon = { type = difficulty_names.dungeon.mythic },
            raid = difficulty_names.raid.lfr,
            other = "Nightmare Prey Hunts",
        },
    },
    [4] = { -- Champion
        currency_id = UPGRADE_SEASON_INFO[4].currency_id,
        name = localizations.CREST_NAME_CHAMPION,
        sources = {
            delve = { levels = {8, 11} },
            dungeon = { levels = {2, 6} },
            raid = difficulty_names.raid.normal,
            ritual = { levels = {1, 3} },
            other = "Bountiful Delves",
        },
    },
    [5] = { -- Heroic
        currency_id = UPGRADE_SEASON_INFO[5].currency_id,
        name = localizations.CREST_NAME_HEROIC,
        sources = {
            delve = { levels = {8, "+"} },
            dungeon = { levels = {7, 9} },
            raid = difficulty_names.raid.heroic,
            ritual = { levels = {4, 5} },
            other = "Nebulous Voidcores / Hidden Troves",
        },
    },
    [6] = { -- Mythic
        currency_id = UPGRADE_SEASON_INFO[6].currency_id,
        name = localizations.CREST_NAME_MYTHIC,
        sources = {
            dungeon = { levels = {10, "+"} },
            raid = difficulty_names.raid.mythic,
            other = "Ascendant Voidcores",
        },
    },
}

-- Helper function to actually build the crest sources section of the tooltip.
local function build_crest_sources(upgrade_crest, upgrade_track, heading, sub_headings_set)
    local upgrade_sources = {}
    local texture_sizing_string = ":12:12:0:0:64:64:4:60:4:60|t|T0:2|t"

    if not upgrade_crest then return upgrade_sources end

    local currency_id = upgrade_crest.currency_id
    local currency_info = API_GetCurrencyInfo(currency_id)

    local num_upgrades_available = ""
    if currency_info then
        local cost = UPGRADE_COST_CRESTS_ALL
        num_upgrades_available = " "..ITEM_QUALITY_COLORS[7].hex.."("
            ..floor(currency_info.quantity / cost)..")|r"
    end

    local icon = currency_info and currency_info.iconFileID or 133022
    local name = currency_info and currency_info.name or upgrade_crest.name
    tinsert(
        upgrade_sources,
        "|cFFFFFFFF"..heading..HEADER_COLON.."|r |T"..icon..texture_sizing_string
            ..upgrade_track.color..name..num_upgrades_available.."|r"
    )

    if ZipTrixDB and ZipTrixDB.upgradeClarityShowSources == false then return upgrade_sources end

    local crest_sources = upgrade_crest.sources
    if crest_sources.other then
        tinsert(upgrade_sources, crest_sources.other)
    end

    if crest_sources.dungeon then
        local crest_dungeon = crest_sources.dungeon
        local dungeon_string = ""

        if not sub_headings_set.dungeon then
            dungeon_string = "|cFFFFFFFF"..DUNGEONS..HEADER_COLON.."|r "
            sub_headings_set.dungeon = true
        end

        if crest_dungeon.levels then
            local dungeon_type = crest_dungeon.type
            if dungeon_type then
                dungeon_string = dungeon_string..dungeon_type..", "
            end

            local dungeon_levels = crest_dungeon.levels
            dungeon_string = dungeon_string..difficulty_names.dungeon.challenge.." "..dungeon_levels[1]

            if type(dungeon_levels[2]) == "number" then
                dungeon_string = dungeon_string.."-"..dungeon_levels[2]
            else
                dungeon_string = dungeon_string.." "..localizations.SOURCE_AND_ABOVE
            end
        else
            dungeon_string = dungeon_string..crest_dungeon.type
        end

        tinsert(upgrade_sources, dungeon_string)
    end

    if crest_sources.raid then
        local raid_string = ""

        if not sub_headings_set.raid then
            raid_string = "|cFFFFFFFF"..RAIDS..HEADER_COLON.."|r "
            sub_headings_set.raid = true
        end

        tinsert(upgrade_sources, raid_string..crest_sources.raid)
    end

    if crest_sources.delve then
        local crest_delve = crest_sources.delve
        local delve_string = ""

        if not sub_headings_set.delve then
            delve_string = "|cFFFFFFFF"..DELVES..HEADER_COLON.."|r "
            sub_headings_set.delve = true
        end

        if crest_delve.levels then
            local delve_levels = crest_delve.levels
            delve_string = delve_string..GARRISON_TIER.." "..delve_levels[1]

            if type(delve_levels[2]) == "number" then
                delve_string = delve_string.."-"..delve_levels[2]
            else
                delve_string = delve_string.." "..localizations.SOURCE_AND_ABOVE
            end
        end

        tinsert(upgrade_sources, delve_string)
    end

    if crest_sources.ritual then
        local crest_ritual = crest_sources.ritual
        local ritual_string = ""

        if not sub_headings_set.ritual then
            ritual_string = "|cFFFFFFFF"..RITUAL_SITES..HEADER_COLON.."|r "
            sub_headings_set.ritual = true
        end

        if crest_ritual.levels then
            local ritual_levels = crest_ritual.levels
            ritual_string = ritual_string..GARRISON_TIER.." "..ritual_levels[1]

            if type(ritual_levels[2]) == "number" then
                ritual_string = ritual_string.."-"..ritual_levels[2]
            else
                ritual_string = ritual_string.." "..localizations.SOURCE_AND_ABOVE
            end
        end

        tinsert(upgrade_sources, ritual_string)
    end

    return upgrade_sources
end

-- Helper function to generate the upgrade track gear item levels string for the tooltip or item link.
local function build_item_level_track(item_level, upgrade_track, upgrade_level, max_upgrade_level)
    local track_start_item_level = item_level
        - ((upgrade_level - 1) * BAND_SPACING)
        - (floor((upgrade_level - 1) / BAND_COUNT) * BAND_ADJUSTMENT)
    local color = upgrade_level == 1 and ITEM_QUALITY_COLORS[7].hex or ITEM_QUALITY_COLORS[0].hex

    local track_item_levels = {color..track_start_item_level.."|r"}
    for i = 1, max_upgrade_level - 1 do
        local band_adjustment = floor(i / BAND_COUNT) * BAND_ADJUSTMENT
        local band_spacing = (BAND_SPACING * i) + band_adjustment

        color = ITEM_QUALITY_COLORS[0].hex

        local offset_i = i + 1
        if upgrade_level < offset_i then
            color = upgrade_tracks[upgrade_track].color
        elseif upgrade_level == offset_i then
            color = ITEM_QUALITY_COLORS[7].hex
        end

        tinsert(track_item_levels, color..(track_start_item_level + band_spacing).."|r")
    end

    return tconcat(track_item_levels, " ")
end

-- Helper function to needily iterate over the tooltip or item link lines.
local function get_upgrade_information(tooltip_lines)
    local upgrade_track, upgrade_level, max_upgrade_level

    for i, tooltip_line in ipairs(tooltip_lines) do
        tooltip_line = tooltip_line.leftText

        if not upgrade_track or not upgrade_level or not max_upgrade_level then
            local upgrade_string_pattern = ITEM_UPGRADE_TOOLTIP_FORMAT_STRING:gsub("%%s", "(.+)"):gsub("%%d", "(%%d+)")
            upgrade_track, upgrade_level, max_upgrade_level = strmatch(tooltip_line, upgrade_string_pattern)
        end

        if upgrade_track and upgrade_level and max_upgrade_level then
            return upgrade_mapping[upgrade_track], tonumber(upgrade_level), tonumber(max_upgrade_level)
        end
    end
end

-- Add upgrade track information to the bottom of item tooltips and links.
local function tooltip_handler(tooltip, data)
    -- Check ZipTrixDB option
    if ZipTrixDB and not ZipTrixDB.upgradeClarityEnabled then return end

    local function eq_sequence(compare, sequence)
        for _, sequence_item in ipairs(sequence) do
            if compare == sequence_item then return true end
        end
        return false
    end

    if not eq_sequence(
        tooltip,
        {API_GameTooltip, API_GameTooltipTooltip, API_ItemRefTooltip, API_ShoppingTooltip1, API_ShoppingTooltip2}
    ) then return end

    local item_link = select(2, API_GetDisplayedItem(tooltip))
    if not item_link then return end

    local item_level = select(4, API_GetItemInfo(item_link))
    if not item_level
        or item_level < UPGRADE_ILEVEL_LOWER_LIMIT
        or strmatch(data.lines[2].leftText, "^|cFF808080") then return end

    local upgrade_track, upgrade_level, max_upgrade_level = get_upgrade_information(data.lines)
    if not upgrade_track
        or not upgrade_level
        or not max_upgrade_level
        or upgrade_level == max_upgrade_level then return end

    tooltip:AddLine("\n"..localizations.HEADER_UPGRADE_CRESTS..HEADER_COLON)
    tooltip:AddLine(build_item_level_track(item_level, upgrade_track, upgrade_level, max_upgrade_level))
    
    local sources = build_crest_sources(
        upgrade_crests[upgrade_track], 
        upgrade_tracks[upgrade_track], 
        localizations.HEADER_CREST_CURRENT, 
        {delve=false, dungeon=false, raid=false, ritual=false}
    )
    for _, line in ipairs(sources) do
        tooltip:AddLine(line)
    end

    tooltip:Show()
end

-- Event Handling
local UpgradeClarity = {
    events = {},
    frame = API_CreateFrame("Frame"),
}

function UpgradeClarity.events:PLAYER_LOGIN()
    API_AddTooltipPostCall(TOOLTIP_TYPE_ITEM, tooltip_handler)
end

for key in pairs(UpgradeClarity.events) do
    UpgradeClarity.frame:RegisterEvent(key)
end

UpgradeClarity.frame:SetScript("OnEvent", function(self, event, ...)
    UpgradeClarity.events[event](self, ...)
end)