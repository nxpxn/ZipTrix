local addonName, ns = ...

-- Local Locale stub since we aren't using AceLocale in ZipTrix
local L = {
	["teleportsWorldMapBinding"] = "Toggle World Map Teleport panel",
	["teleportOtherVariants"] = "%d other variants available",
	["DungeonCompendium"] = "Gateways",
	["teleportCompendiumHeadline"] = "Gateways",
	["teleportCompendiumNone"] = "None available",
}

-- Lightweight World Map side-panel for Dungeon Portals, with a small tab
-- that sits together with the default Map Legend / Quest tabs. The panel
-- lists all teleports from addon.MythicPlus.variables.portalCompendium,
-- honoring favorites and the main teleport options where reasonable.

local f = CreateFrame("Frame")
local DISPLAY_MODE = "zip_DungeonPortals"
local ICON_ACTIVE = 135744 -- Interface\Icons\Spell_Arcane_Teleport
local ICON_INACTIVE = 135744 -- Interface\Icons\Spell_Arcane_Teleport
local VIEW_GATEWAYS = 1
local VIEW_SECRETS = 2

_G["BINDING_NAME_zip_TOGGLE_WORLDMAP_TELEPORT"] = L["teleportsWorldMapBinding"] or "Toggle World Map Teleport panel"

-- Cache some frequently used API
local FirstOwnedItemID
do
	local GetItemCount = C_Item.GetItemCount
	function FirstOwnedItemID(itemID)
		if type(itemID) == "table" then
			for _, id in ipairs(itemID) do
				if GetItemCount(id) > 0 then return id end
			end
			return itemID[1]
		end
		return itemID
	end
end

local function IsToyUsable(id)
	if not id or not PlayerHasToy(id) then return false end
	if C_ToyBox and C_ToyBox.GetToyInfo then
		local _, _, _, _, _, _, isUsable = C_ToyBox.GetToyInfo(id)
		if isUsable ~= nil then return isUsable end
	end
	local tips = C_TooltipInfo.GetToyByItemID(id)
	if not tips or not tips.lines then return true end
	for _, line in pairs(tips.lines) do
		if line.type == 23 then -- requirement text; white = usable
			local c = line.leftColor
			if c and c.r == 1 and c.g == 1 and c.b == 1 then return true end
			return false
		end
	end
	return true
end

local function BuildSpellEntries()
	local dungeonTeleports = {
		-- Mists of Pandaria
		{ spellID = 131204, name = "Temple of the Jade Serpent" }, { spellID = 131205, name = "Stormstout Brewery" },
		{ spellID = 131206, name = "Shado-Pan Monastery" }, { spellID = 131222, name = "Mogu'shan Palace" },
		{ spellID = 131225, name = "Gate of the Setting Sun" }, { spellID = 131228, name = "Siege of Niuzao Temple" },
		{ spellID = 131229, name = "Scarlet Halls" }, { spellID = 131231, name = "Scarlet Monastery" },
		{ spellID = 131232, name = "Scholomance" },
		-- Warlords of Draenor
		{ spellID = 159895, name = "Bloodmaul Slag Mines" }, { spellID = 159896, name = "Iron Docks" },
		{ spellID = 159897, name = "Auchindoun" }, { spellID = 159898, name = "Skyreach" },
		{ spellID = 159899, name = "Shadowmoon Burial Grounds" }, { spellID = 159900, name = "Grimrail Depot" },
		{ spellID = 159901, name = "Everbloom" }, { spellID = 159902, name = "Upper Blackrock Spire" },
		-- Legion
		{ spellID = 410080, name = "Halls of Valor" }, { spellID = 393764, name = "Court of Stars" },
		{ spellID = 424163, name = "Darkheart Thicket" }, { spellID = 424153, name = "Black Rook Hold" },
		{ spellID = 410078, name = "Neltharion's Lair" }, { spellID = 424187, name = "Throne of the Tides" },
		-- Battle for Azeroth
		{ spellID = 410071, name = "Freehold" }, { spellID = 424167, name = "Waycrest Manor" },
		{ spellID = 424185, name = "Atal'Dazar" }, { spellID = 410074, name = "The Underrot" },
		{ spellID = 445424, name = "Siege of Boralus" },
		-- Shadowlands
		{ spellID = 354462, name = "De Other Side" }, { spellID = 354464, name = "Halls of Atonement" },
		{ spellID = 354463, name = "Mists of Tirna Scithe" }, { spellID = 354465, name = "Plaguefall" },
		{ spellID = 354466, name = "Sanguine Depths" }, { spellID = 354467, name = "Spires of Ascension" },
		{ spellID = 354468, name = "The Necrotic Wake" }, { spellID = 354469, name = "Theater of Pain" },
		{ spellID = 367416, name = "Tazavesh" },
		-- Dragonflight
		{ spellID = 393256, name = "Algeth'ar Academy" }, { spellID = 393262, name = "Ruby Life Pools" },
		{ spellID = 393279, name = "The Nokhud Offensive" }, { spellID = 393273, name = "Brackenhide Hollow" },
		{ spellID = 393222, name = "Uldaman: Legacy of Tyr" }, { spellID = 393267, name = "Neltharus" },
		{ spellID = 393276, name = "The Azure Vault" }, { spellID = 393283, name = "Halls of Infusion" },
		{ spellID = 424197, name = "Dawn of the Infinite" },
		-- The War Within
		{ spellID = 445269, name = "The Stonevault" }, { spellID = 445418, name = "The Dawnbreaker" },
		{ spellID = 445414, name = "Ara-Kara, City of Echoes" }, { spellID = 445416, name = "City of Threads" },
		{ spellID = 445417, name = "Cinderbrew Meadery" }, { spellID = 445440, name = "Darkflame Cleft" },
		{ spellID = 445441, name = "Priory of the Sacred Flame" }, { spellID = 445444, name = "The Rookery" },
		{ spellID = 464256, name = "Grim Batol" },
	}

	local items = {}
	for _, info in ipairs(dungeonTeleports) do
		if IsSpellKnown(info.spellID) then
			local spellInfo = C_Spell.GetSpellInfo(info.spellID)
			if spellInfo then
				table.insert(items, { text = spellInfo.name, spellID = info.spellID, iconID = spellInfo.iconID, isKnown = true, isItem = false, isToy = false })
			end
		end
	end
	if #items > 0 then table.sort(items, function(a,b) return a.text < b.text end); return { { title = "Dungeons", items = items } } end
	return {}
end

local function BuildSeasonSection()
	return nil
end

local function AddVariantTooltipLine(entry)
	if not entry or not entry.variantOtherCount or entry.variantOtherCount <= 0 then return end
	local fmt = L["teleportOtherVariants"] or "%d other variants available"
	GameTooltip:AddLine(string.format(fmt, entry.variantOtherCount), 0.7, 0.7, 0.7, true)
end

-- Open World Map to a mapID and create a user waypoint pin at x,y (0..1)
local function OpenMapAndCreatePin(mapID, x, y)
	if not mapID or not x or not y then return end
	if WorldMapFrame and WorldMapFrame.SetMapID then
		if not WorldMapFrame:IsShown() then
			if ToggleMap then
				ToggleMap()
			else
				ShowUIPanel(WorldMapFrame)
			end
		end
		WorldMapFrame:SetMapID(mapID)
	end
	if C_Map and C_Map.SetUserWaypoint and UiMapPoint and UiMapPoint.CreateFromCoordinates then
		local point = UiMapPoint.CreateFromCoordinates(mapID, x, y)
		if point then
			C_Map.SetUserWaypoint(point)
			if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then C_SuperTrack.SetSuperTrackedUserWaypoint(true) end
		end
	end
end

-- Cooldown helpers ---------------------------------------------------------
local function ApplyCooldownToButton(b)
	if not b or not b.cooldownFrame or not b.entry then return end
	local entry = b.entry
	local startTime, duration, modRate, enabled
	if entry.isToy and entry.toyID then
		local st, dur, en = C_Item.GetItemCooldown(entry.toyID)
		startTime, duration, modRate, enabled = st, dur, 1, en
	elseif entry.isItem and entry.itemID then
		local st, dur, en = C_Item.GetItemCooldown(entry.itemID)
		startTime, duration, modRate, enabled = st, dur, 1, en
	elseif entry.spellID then
		local cd = C_Spell.GetSpellCooldown(entry.spellID)
		if cd then
			startTime, duration, modRate, enabled = cd.startTime, cd.duration, cd.modRate, cd.isEnabled
		end
	end

	if issecretvalue and issecretvalue(enabled) then
		b.cooldownFrame:SetCooldown(startTime or 0, duration or 0, modRate or 1)
	elseif enabled and duration and duration > 0 then
		b.cooldownFrame:SetCooldown(startTime or 0, duration or 0, modRate or 1)
	else
		if b.cooldownFrame.Clear then
			b.cooldownFrame:Clear()
		else
			b.cooldownFrame:SetCooldown(0, 0, 0)
		end
	end
end

-- Panel creation -----------------------------------------------------------
local panel -- content frame
local scrollBox
local tabButton -- forward-declare for SafeSetVisible
-- Safe visibility toggles (avoid Show/Hide taint during combat)
local function SafeSetVisible(frame, visible)
	if not frame then return end
	-- Never directly Show/Hide the World Map content frame or its tab; rely on Blizzard
	-- display mode system to toggle visibility. Use alpha + deferred apply to avoid taint.
	if frame == panel or frame == tabButton then
		frame._zipPendingVisible = visible and true or false
		frame:SetAlpha(visible and 1 or 0)
		return
	end
	if InCombatLockdown and InCombatLockdown() then
		frame._zipPendingVisible = visible and true or false
		frame:SetAlpha(visible and 1 or 0)
		return
	end
	if visible then
		frame:Show()
	else
		if not InCombatLockdown() then frame:Hide() end
	end
end
local function SetCombatScrolling(enabled)
	if not panel or not panel.Scroll then return end
	local s = panel.Scroll
	if enabled then
		s:EnableMouse(true)
		s:EnableMouseWheel(true)
		if s.ScrollBar then
			s.ScrollBar.allowScroll = true
			if s.ScrollBar.Back then s.ScrollBar.Back:Enable() end
			if s.ScrollBar.Forward then s.ScrollBar.Forward:Enable() end
		end
	else
		-- In combat, suppress any scrolling to avoid protected SetVerticalScroll taint
		s:EnableMouse(false)
		s:EnableMouseWheel(false)
		if s.ScrollBar then
			s.ScrollBar.allowScroll = false
			if s.ScrollBar.Back then s.ScrollBar.Back:Disable() end
			if s.ScrollBar.Forward then s.ScrollBar.Forward:Disable() end
		end
	end
end

local function SetButtonsInteractable(enabled)
	if not panel or not panel._allButtons then return end
	for _, b in ipairs(panel._allButtons) do
		if b and b.EnableMouse then b:EnableMouse(enabled and true or false) end
	end
end
local function EnsurePanel(parent)
	local targetParent = QuestMapFrame or parent
	if panel and panel:GetParent() ~= targetParent then panel:SetParent(targetParent) end
	if panel then return panel end

	panel = CreateFrame("Frame", "zipWorldMapDungeonPortalsPanel", targetParent, "BackdropTemplate")
	if not InCombatLockdown() then panel:Hide() end

	local function anchorPanel()
		local host = panel:GetParent() or targetParent
		local ca = QuestMapFrame and QuestMapFrame.ContentsAnchor
		panel:ClearAllPoints()
		if ca and ca.GetWidth and ca:GetWidth() > 0 and ca:GetHeight() > 0 then
			-- Match Blizzard MapLegend anchoring to ContentsAnchor
			panel:SetPoint("TOPLEFT", ca, "TOPLEFT", 0, -29)
			panel:SetPoint("BOTTOMRIGHT", ca, "BOTTOMRIGHT", -22, 0)
		else
			panel:SetAllPoints(host)
		end
	end

	anchorPanel()
	-- In case layout isn't ready on first tick, re-anchor shortly after
	C_Timer.After(0, anchorPanel)
	C_Timer.After(0.1, anchorPanel)
	-- Ensure our panel is on top of Blizzard content frames
	if QuestMapFrame then
		panel:SetFrameStrata("HIGH")
		panel:SetFrameLevel((QuestMapFrame:GetFrameLevel() or 0) + 200)
	else
		panel:SetFrameStrata("HIGH")
	end
	panel:SetToplevel(true)
	panel:EnableMouse(true)
	panel:EnableMouseWheel(true)
	SafeSetVisible(panel, false)

	-- Border & Title are positioned after Scroll creation

	-- Scroll area
	local s = CreateFrame("ScrollFrame", "zipWorldMapDungeonPortalsScrollFrame", panel, "ScrollFrameTemplate")
	-- Fill interior; ScrollBar will sit in the right gutter via offsets
	s:ClearAllPoints()
	s:SetPoint("TOPLEFT")
	s:SetPoint("BOTTOMRIGHT")

	-- Background inside the scrollframe similar to MapLegend
	if not s.Background then
		local bg = s:CreateTexture(nil, "BACKGROUND")
		if bg.SetAtlas then bg:SetAtlas("QuestLog-main-background", true) end
		-- Inset background to reveal border artwork (similar to MapLegend)
		bg:ClearAllPoints()
		bg:SetPoint("TOPLEFT", s, "TOPLEFT", 3, -1)
		bg:SetPoint("BOTTOMRIGHT", s, "BOTTOMRIGHT", -3, 0)
		s.Background = bg
	else
		s.Background:ClearAllPoints()
		s.Background:SetPoint("TOPLEFT", s, "TOPLEFT", 3, -13)
		s.Background:SetPoint("BOTTOMRIGHT", s, "BOTTOMRIGHT", -3, 0)
	end

	-- Align scrollbar like MapLegend: x=+8, topY=+2, bottomY=-4
	if s.ScrollBar and not s._zipBarAnchored then
		s.ScrollBar:ClearAllPoints()
		s.ScrollBar:SetPoint("TOPLEFT", s, "TOPRIGHT", 8, 2)
		s.ScrollBar:SetPoint("BOTTOMLEFT", s, "BOTTOMRIGHT", 8, -4)
		s._zipBarAnchored = true
	end

	local content = CreateFrame("Frame", "zipWorldMapDungeonPortalsScrollChild", s)
	content:SetSize(1, 1)
	s:SetScrollChild(content)

	panel.Content = content
	panel.Scroll = s

	-- Combat click blocker overlay (prevents any interaction while in combat)
	if not panel.Blocker then
		local blocker = CreateFrame("Frame", nil, panel, "BackdropTemplate")
		blocker:SetAllPoints(s)
		blocker:EnableMouse(false)
		blocker:EnableMouseWheel(false)
		blocker:SetAlpha(0)
		panel.Blocker = blocker
	end

	-- Ensure our interactive content renders above any sibling art
	local baseLevel = panel:GetFrameLevel() or 1
	s:SetFrameLevel(baseLevel + 1)
	content:SetFrameLevel(baseLevel + 2)

	-- Respect combat lockdown: prevent scrolling interactions during combat
	if InCombatLockdown and InCombatLockdown() then
		SetCombatScrolling(false)
		if panel.Blocker then
			panel.Blocker:SetAlpha(0)
			panel.Blocker:EnableMouse(false)
			panel.Blocker:EnableMouseWheel(false)
		end
	end

	-- Now that Scroll exists, create/anchor the border precisely around it
	if not panel.BorderFrame then
		local bf = CreateFrame("Frame", nil, panel, "QuestLogBorderFrameTemplate")
		bf:ClearAllPoints()
		bf:SetPoint("TOPLEFT", s, "TOPLEFT", -3, 7)
		bf:SetPoint("BOTTOMRIGHT", s, "BOTTOMRIGHT", 3, -6)
		bf:SetFrameStrata(panel:GetFrameStrata())
		bf:SetFrameLevel((panel:GetFrameLevel() or 2) + 3)
		bf:EnableMouse(false) -- ensure border never blocks clicks to our content
		panel.BorderFrame = bf
	else
		local bf = panel.BorderFrame
		bf:ClearAllPoints()
		bf:SetPoint("TOPLEFT", s, "TOPLEFT", -3, 13)
		bf:SetPoint("BOTTOMRIGHT", s, "BOTTOMRIGHT", 3, 0)
		bf:SetFrameStrata(panel:GetFrameStrata())
		bf:SetFrameLevel((panel:GetFrameLevel() or 2) + 3)
		bf:EnableMouse(false)
	end

	-- Create or re-anchor the title relative to the border top
	if not panel.Title then
		local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
		title:SetPoint("BOTTOM", panel.BorderFrame, "TOP", -1, 3)
		title:SetText(L["DungeonCompendium"] or "Gateways")
		panel.Title = title
	else
		panel.Title:ClearAllPoints()
		panel.Title:SetPoint("BOTTOM", panel.BorderFrame, "TOP", -1, 3)
		panel.Title:SetText(L["DungeonCompendium"] or "Gateways")
	end

	if not panel.ConfigButton then
		local btn = CreateFrame("Button", nil, panel)
		btn:SetSize(16, 16)
		btn:SetPoint("BOTTOMRIGHT", panel.BorderFrame, "TOPRIGHT", -5, 3)

		btn:SetNormalTexture("Interface\\WorldMap\\Gear_64")
		btn:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)

		btn:SetHighlightTexture("Interface\\WorldMap\\Gear_64")
		btn:GetHighlightTexture():SetTexCoord(0.5, 1, 0, 0.5)

		btn:SetPushedTexture("Interface\\WorldMap\\Gear_64")
		btn:GetPushedTexture():SetTexCoord(0, 0.5, 0.5, 1)

		btn:SetScript("OnClick", function()
			if SlashCmdList["ZIPTRIX"] then SlashCmdList["ZIPTRIX"]("map") end
		end)
		btn:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText("Configure")
			GameTooltip:Show()
		end)
		btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
		panel.ConfigButton = btn
	end

	if not panel.viewMode then panel.viewMode = VIEW_GATEWAYS end

	if not panel.SecretsButton then
		local btn = CreateFrame("Button", nil, panel)
		btn:SetSize(16, 16)
		btn:SetPoint("RIGHT", panel.ConfigButton, "LEFT", -2, 0)

		btn:SetNormalTexture("Interface\\Icons\\INV_Misc_Spyglass_02")
		btn:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)

		btn:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight")
		btn:GetHighlightTexture():SetBlendMode("ADD")

		btn:SetScript("OnClick", function()
			panel.viewMode = (panel.viewMode == VIEW_SECRETS) and VIEW_GATEWAYS or VIEW_SECRETS
			f:RefreshPanel()
		end)
		btn:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(panel.viewMode == VIEW_SECRETS and "Show Gateways" or "Show Secrets")
			GameTooltip:Show()
		end)
		btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
		panel.SecretsButton = btn
	end

	scrollBox = content
	-- Integrate with QuestLog display system

	-- Keep content up-to-date if the scroll area changes size after layout
	if not s._zipSizeHook then
		s:HookScript("OnSizeChanged", function()
			if panel and panel:IsShown() then f:RefreshPanel() end
		end)
		s._zipSizeHook = true
	end
	panel.displayMode = DISPLAY_MODE
	return panel
end

local function ClearContent()
	if not scrollBox then return end
	for _, child in ipairs({ scrollBox:GetChildren() }) do
		child:Hide()
		child:SetParent(nil)
	end
end

local function CreateSecureSpellButton(parent, entry, size)
	local b = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
	b:SetSize(size or 28, size or 28)
	b.entry = entry

	-- Keep buttons above any background art
	if panel then
		b:SetFrameStrata(panel:GetFrameStrata())
		b:SetFrameLevel((panel:GetFrameLevel() or 1) + 10)
	end

	local tex = b:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints(b)
	if entry.iconID then
		tex:SetTexture(entry.iconID)
	else
		tex:SetTexture(136121)
	end
	b.Icon = tex

	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	b:GetHighlightTexture():SetBlendMode("ADD")
	b:SetPushedTexture("Interface\\Buttons\\UI-Quickslot-Depress")

	local cd = CreateFrame("Cooldown", nil, b, "CooldownFrameTemplate")
	cd:SetAllPoints(tex) -- restrict overlay strictly to the icon
	cd:SetSwipeColor(0, 0, 0, 0.35)
	cd:SetUseCircularEdge(true)
	cd:SetDrawEdge(false)
	cd:SetDrawBling(false) -- prevent golden flare from bleeding outside
	b.cooldownFrame = cd

	-- Casting setup (Left click) — mirror compendium logic
	if entry.macroText then
		b:SetAttribute("type1", "macro")
		b:SetAttribute("macrotext1", entry.macroText)
	elseif entry.isToy then
		if entry.isKnown then
			b:SetAttribute("type1", "macro")
			if entry.toyName then
				b:SetAttribute("macrotext1", "/cast " .. entry.toyName)
			else
				b:SetAttribute("macrotext1", "/use item:" .. entry.toyID)
			end
		end
	elseif entry.isItem then
		if entry.isKnown then
			b.itemID = entry.itemID
			b.equipSlot = entry.equipSlot
			b:SetAttribute("type1", "macro")
			b:SetAttribute("macrotext1", "/use item:" .. entry.itemID)
			if entry.equipSlot then
				b:SetScript("PreClick", function(self)
					local slot = self.equipSlot
					if not slot or not self.itemID then return end
					local equippedID = GetInventoryItemID("player", slot)
					if equippedID ~= self.itemID then
						self:SetAttribute("type1", "macro")
						self:SetAttribute("macrotext1", "/equip item:" .. self.itemID)
					else
						self:SetAttribute("type1", "macro")
						self:SetAttribute("macrotext1", "/use item:" .. self.itemID)
					end
				end)
			end
		end
	else
		b:SetAttribute("type1", "spell")
		if entry.spellID and entry.spellID > 0 then
			b:SetAttribute("spell1", entry.spellID)
		elseif entry.spellName then
			b:SetAttribute("spell1", entry.spellName)
		end
		b:SetAttribute("unit", "player")
		b:SetAttribute("checkselfcast", true)
	end

	-- Favorite toggle after secure click resolves
	b:RegisterForClicks("AnyDown", "AnyUp")
	b:SetScript("PostClick", function(self, btn)
		if btn == "RightButton" then
			if IsShiftKeyDown() then
				local favs = ZipTrixDB.teleportFavorites or {}
				if favs[self.entry.spellID] then
					favs[self.entry.spellID] = nil
				else
					favs[self.entry.spellID] = true
				end
				ZipTrixDB.teleportFavorites = favs
				f:RefreshPanel()
			else
				local entry = self.entry or {}
				local locID = entry.locID
				local x, y = entry.x, entry.y
				if locID and x and y then OpenMapAndCreatePin(locID, x, y) end
			end
		end
	end)

	b:SetScript("OnEnter", function(self)
		if not ZipTrixDB["portalShowTooltip"] then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		if entry.isToy then
			GameTooltip:SetToyByItemID(entry.toyID)
		elseif entry.isItem then
			GameTooltip:SetItemByID(entry.itemID)
		elseif entry.spellID and entry.spellID > 0 then
			GameTooltip:SetSpellByID(entry.spellID)
		else
			GameTooltip:SetText(entry.text or "")
		end
		AddVariantTooltipLine(entry)
		GameTooltip:Show()
	end)
	b:SetScript("OnLeave", function() GameTooltip:Hide() end)
	-- favorite star overlay
	local fav = b:CreateTexture(nil, "OVERLAY")
	fav:SetPoint("TOPRIGHT", 5, 5)
	fav:SetSize(14, 14)
	fav:SetAtlas("auctionhouse-icon-favorite")
	fav:SetShown(entry.isFavorite)
	b.FavOverlay = fav

	-- initial cooldown state
	ApplyCooldownToButton(b)

	return b
end

-- MapLegend-style row button: icon left, text right, full-row highlight
local function CreateLegendRowButton(parent, entry, width, height)
	local b = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate")
	b:SetSize(width, height)
	b.entry = entry

	-- icon
	local icon = b:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("LEFT", 4, 0)
	icon:SetSize(height - 6, height - 6)
	if entry.iconID == false then
		icon:SetTexture(nil)
		icon:Hide()
	else
		icon:SetTexture(entry.iconID or 136121)
		icon:Show()
	end
	b.Icon = icon

	-- cooldown overlay on icon only
	local cd = CreateFrame("Cooldown", nil, b, "CooldownFrameTemplate")
	cd:SetAllPoints(icon) -- overlay only the icon, not the label row
	cd:SetSwipeColor(0, 0, 0, 0.35)
	cd:SetUseCircularEdge(true)
	cd:SetDrawEdge(false)
	cd:SetDrawBling(false)
	b.cooldownFrame = cd

	-- favorite star overlay (on icon)
	local fav = b:CreateTexture(nil, "OVERLAY")
	fav:SetPoint("TOPRIGHT", icon, "TOPRIGHT", 4, 4)
	fav:SetSize(14, 14)
	fav:SetAtlas("auctionhouse-icon-favorite")
	fav:SetShown(entry.isFavorite)
	b.FavOverlay = fav

	-- label to the right of the icon
	local label = b:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	if entry.iconID == false then
		label:SetPoint("LEFT", b, "LEFT", 8, 0)
	else
		label:SetPoint("LEFT", icon, "RIGHT", 8, 0)
	end
	label:SetPoint("RIGHT", -6, 0)
	label:SetJustifyH("LEFT")
	label:SetWordWrap(false)
	label:SetText(entry.text or "")
	b.Label = label

	-- full-row highlight (lockable) using the same atlas as MapLegend
	local hl = b:CreateTexture(nil, "HIGHLIGHT")
	hl:SetAllPoints(b)
	if hl.SetAtlas then
		hl:SetAtlas("Options_List_Active", true)
		if hl.SetBlendMode then hl:SetBlendMode("ADD") end
	else
		hl:SetColorTexture(1, 1, 1, 0.08)
	end
	
	-- Determine interactivity
	local isInteractive = entry.url or entry.macroText or entry.script or (entry.isToy and entry.isKnown) or (entry.isItem and entry.isKnown) or entry.spellID
	if isInteractive then
		b:SetHighlightTexture(hl)
	else
		hl:SetTexture(nil)
	end

	-- Casting setup (Left click) — mirror compendium logic
	if entry.url then
		b:SetAttribute("type1", "macro") -- Dummy attribute to prevent errors
		b:SetScript("OnClick", function()
			StaticPopup_Show("ZIPTRIX_COPY_URL", nil, nil, entry.url)
		end)
	elseif entry.macroText then
		b:SetAttribute("type1", "macro")
		b:SetAttribute("macrotext1", entry.macroText)
	elseif entry.script then
		b:SetAttribute("type1", "macro")
		b:SetAttribute("macrotext1", entry.macroText)
	elseif entry.isToy then
		if entry.isKnown then
			b:SetAttribute("type1", "macro")
			if entry.toyName then
				b:SetAttribute("macrotext1", "/cast " .. entry.toyName)
			else
				b:SetAttribute("macrotext1", "/use item:" .. entry.toyID)
			end
		end
	elseif entry.isItem then
		if entry.isKnown then
			b.itemID = entry.itemID
			b.equipSlot = entry.equipSlot
			b:SetAttribute("type1", "macro")
			b:SetAttribute("macrotext1", "/use item:" .. entry.itemID)
			if entry.equipSlot then
				b:SetScript("PreClick", function(self)
					local slot = self.equipSlot
					if not slot or not self.itemID then return end
					local equippedID = GetInventoryItemID("player", slot)
					if equippedID ~= self.itemID then
						self:SetAttribute("type1", "macro")
						self:SetAttribute("macrotext1", "/equip item:" .. self.itemID)
					else
						self:SetAttribute("type1", "macro")
						self:SetAttribute("macrotext1", "/use item:" .. self.itemID)
					end
				end)
			end
		end
	else
		b:SetAttribute("type1", "spell")
		if entry.spellID and entry.spellID > 0 then
			b:SetAttribute("spell1", entry.spellID)
		elseif entry.spellName then
			b:SetAttribute("spell1", entry.spellName)
		end
		b:SetAttribute("unit", "player")
		b:SetAttribute("checkselfcast", true)
	end

	-- Right click: toggle favorite after secure click resolves
	b:RegisterForClicks("AnyDown", "AnyUp")
	b:SetScript("PostClick", function(self, btn)
		if btn == "RightButton" then
			if IsShiftKeyDown() then
				local favs = ZipTrixDB.teleportFavorites or {}
				if favs[self.entry.spellID] then
					favs[self.entry.spellID] = nil
				else
					favs[self.entry.spellID] = true
				end
				ZipTrixDB.teleportFavorites = favs
				f:RefreshPanel()
			else
				local entry = self.entry or {}
				local locID = entry.locID
				local x, y = entry.x, entry.y
				if locID and x and y then OpenMapAndCreatePin(locID, x, y) end
			end
		end
	end)

	-- Tooltip + highlight lock on hover (mirrors MapLegend feel)

	b:SetScript("OnEnter", function(self)
		if self.SetHighlightLocked then
			self:SetHighlightLocked(true)
		else
			self:LockHighlight()
		end
		if ZipTrixDB["portalShowTooltip"] then
			if entry.isToy and entry.toyID then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetToyByItemID(entry.toyID)
				AddVariantTooltipLine(entry)
				GameTooltip:Show()
			elseif entry.isItem and entry.itemID then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetItemByID(entry.itemID)
				AddVariantTooltipLine(entry)
				GameTooltip:Show()
			elseif entry.spellID and entry.spellID > 0 then
				GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
				GameTooltip:SetSpellByID(entry.spellID)
				AddVariantTooltipLine(entry)
				GameTooltip:Show()
			else
				if b.Label and b.Label:IsTruncated() then
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetText(entry.text or "")
					GameTooltip:Show()
				end
			end
		end
	end)
	b:SetScript("OnLeave", function(self)
		if self.SetHighlightLocked then
			self:SetHighlightLocked(false)
		else
			self:UnlockHighlight()
		end
		GameTooltip:Hide()
	end)
	-- Unknown visual state: keep hover for tooltip, but block casting
	if not entry.isKnown then
		if b.Icon then
			b.Icon:SetDesaturated(true)
			b.Icon:SetAlpha(0.5)
		end
		-- Make label clearly appear unavailable
		if b.Label and b.Label.SetTextColor then b.Label:SetTextColor(0.6, 0.6, 0.6) end
		-- Allow mouse for tooltip/right-click favorite, but prevent left-click actions
		b:EnableMouse(true)
		if not entry.url then b:SetAttribute("type1", nil) end
		b:SetAttribute("spell1", nil)
		b:SetAttribute("macrotext1", nil)
	else
		if b.Icon then
			b.Icon:SetDesaturated(false)
			b.Icon:SetAlpha(1)
			if entry.inBank then
				b.Icon:SetVertexColor(0.6, 1.0, 0.6) -- Green hue for bank items
			else
				b.Icon:SetVertexColor(1, 1, 1)
			end
		end
		-- Restore normal label color for known/owned teleports (gold-like)
		if b.Label and b.Label.SetTextColor then
			if entry.inBank then
				b.Label:SetTextColor(0.6, 1.0, 0.6)
			else
				b.Label:SetTextColor(1.0, 0.82, 0.0)
			end
		end
		if isInteractive then
			b:EnableMouse(true)
		else
			b:EnableMouse(true) -- Keep enabled for tooltips, but no click action
		end
	end

	-- Set frame strata above background art
	if panel then
		b:SetFrameStrata(panel:GetFrameStrata())
		b:SetFrameLevel((panel:GetFrameLevel() or 1) + 10)
	end

	-- initial cooldown state
	ApplyCooldownToButton(b)

	return b
end

local function CreateSecretRow(parent, entry, width)
	local f = CreateFrame("Button", nil, parent, "SecureActionButtonTemplate, BackdropTemplate")
	f:SetWidth(width)
	
	local height = 20
	
	if entry.type == "subheader" then
		local fs = f:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
		fs:SetPoint("TOPLEFT", 0, 0)
		fs:SetText(entry.text)
		height = fs:GetStringHeight() + 10
		f:SetHeight(height)
		f:EnableMouse(false)
	elseif entry.type == "url" then
		-- Pill style for URL
		f:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1})
		f:SetBackdropColor(0, 0.2, 0.4, 0.6)
		f:SetBackdropBorderColor(0.2, 0.6, 1, 1)
		
		local fs = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		fs:SetPoint("CENTER")
		fs:SetText("Link: " .. (entry.text:match("guides/(.+)") or "Website"))
		
		f:SetHeight(20)
		f:SetWidth(fs:GetStringWidth() + 20)
		
		f:SetScript("OnClick", function()
			StaticPopup_Show("ZIPTRIX_COPY_URL", nil, nil, entry.url)
		end)
		f:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(entry.url, 1, 1, 1, 1, true)
			GameTooltip:Show()
		end)
		f:SetScript("OnLeave", function() GameTooltip:Hide() end)
	elseif entry.type == "body" then
		local fs = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		fs:SetPoint("TOPLEFT", 0, 0)
		fs:SetWidth(width)
		fs:SetJustifyH("LEFT")
		fs:SetWordWrap(true)
		fs:SetText(entry.text)
		if entry.isBullet then
			fs:SetTextColor(1, 1, 1) -- White for bullets
		else
			fs:SetTextColor(0.9, 0.9, 0.9)
		end
		height = fs:GetStringHeight() + 5
		f:SetHeight(height)
		f:EnableMouse(false)
	elseif entry.type == "waypoint" then
		local icon = f:CreateTexture(nil, "ARTWORK")
		icon:SetSize(14, 14)
		icon:SetPoint("LEFT", 0, 0)
		icon:SetTexture(132059) -- Map Pin
		
		local fs = f:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
		fs:SetPoint("LEFT", icon, "RIGHT", 5, 0)
		fs:SetText(entry.text)
		
		f:SetHeight(18)
		f:SetAttribute("type", "macro")
		f:SetAttribute("macrotext", entry.macroText)
		f:RegisterForClicks("AnyUp")
		
		local hl = f:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints()
		hl:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
		hl:SetBlendMode("ADD")
	elseif entry.type == "tags_row" then
		-- Container for horizontal pills
		local x = 0
		for _, item in ipairs(entry.items) do
			local pill = CreateFrame("Button", nil, f, "SecureActionButtonTemplate, BackdropTemplate")
			pill:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8x8", edgeFile="Interface\\Buttons\\WHITE8x8", edgeSize=1})
			pill:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
			pill:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
			
			local fs = pill:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
			fs:SetPoint("CENTER")
			fs:SetText(item.text)
			local w = fs:GetStringWidth() + 12
			pill:SetSize(w, 18)
			pill:SetPoint("LEFT", x, 0)
			
			if item.type == "script" and item.script then
				pill:SetAttribute("type", "macro")
				pill:SetAttribute("macrotext", item.script)
				pill:RegisterForClicks("AnyUp")
				pill:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetText("Click to run script", 1, 1, 1)
					GameTooltip:Show()
				end)
				pill:SetScript("OnLeave", function() GameTooltip:Hide() end)
				-- Script pills get a slightly lighter border
				pill:SetBackdropBorderColor(0.6, 0.6, 0.6, 1)
			end
			
			x = x + w + 5
		end
		f:SetHeight(22)
	end
	
	return f
end

local function BuildExtraTeleports()
	local sections = {}
	local groups = {} -- [Destination] = { list of items }
	local quirkyItems = {}
	local quirkyTitle = "Dimensional Drifting" -- Quirky name for multi-dest items

	-- Geographic Constants
	local C_KALIMDOR = "Kalimdor"
	local C_EK = "Eastern Kingdoms"
	local C_OUTLAND = "Outland"
	local C_NORTHREND = "Northrend"
	local C_PANDARIA = "Pandaria"
	local C_DRAENOR = "Draenor"
	local C_LEGION = "Legion"
	local C_KULTIRAS = "Kul Tiras"
	local C_ZANDALAR = "Zandalar"
	local C_SHADOWLANDS = "Shadowlands"
	local C_DRAGONISLES = "Dragon Isles"
	local C_KHAZALGAR = "Khaz Algar"

	local function AddToGroup(dest, entry)
		if not dest then return end
		if not groups[dest] then groups[dest] = {} end
		table.insert(groups[dest], entry)
	end

	local className, playerClass = UnitClass("player")
	local raceName, playerRace = UnitRace("player")
	local faction = UnitFactionGroup("player")

	-- Class Skills
	local classSpells = {
		MAGE = {
			-- Alliance
			{ spellID=3561, dest=C_EK }, -- Teleport: Stormwind
			{ spellID=10059, dest=C_EK }, -- Portal: Stormwind
			{ spellID=3565, dest=C_KALIMDOR }, -- Teleport: Darnassus
			{ spellID=11419, dest=C_KALIMDOR }, -- Portal: Darnassus
			{ spellID=3563, dest=C_EK }, -- Teleport: Ironforge
			{ spellID=11416, dest=C_EK }, -- Portal: Ironforge
			{ spellID=32271, dest=C_KALIMDOR }, -- Teleport: Exodar
			{ spellID=32266, dest=C_KALIMDOR }, -- Portal: Exodar
			{ spellID=33690, dest=C_OUTLAND }, -- Teleport: Shattrath
			{ spellID=33691, dest=C_OUTLAND }, -- Portal: Shattrath
			{ spellID=49359, dest=C_KALIMDOR }, -- Teleport: Theramore
			{ spellID=49360, dest=C_KALIMDOR }, -- Portal: Theramore
			{ spellID=53140, dest=C_NORTHREND }, -- Teleport: Dalaran (Northrend)
			{ spellID=53142, dest=C_NORTHREND }, -- Portal: Dalaran (Northrend)
			{ spellID=88342, dest=C_EK }, -- Teleport: Tol Barad
			{ spellID=88345, dest=C_EK }, -- Portal: Tol Barad
			{ spellID=132621, dest=C_PANDARIA }, -- Teleport: Vale of Eternal Blossoms
			{ spellID=132620, dest=C_PANDARIA }, -- Portal: Vale of Eternal Blossoms
			{ spellID=120145, dest=C_LEGION }, -- Teleport: Dalaran (Broken Isles)
			{ spellID=120146, dest=C_LEGION }, -- Portal: Dalaran (Broken Isles)
			{ spellID=224869, dest=C_DRAENOR }, -- Teleport: Stormshield
			{ spellID=224872, dest=C_DRAENOR }, -- Portal: Stormshield
			{ spellID=281403, dest=C_KULTIRAS }, -- Teleport: Boralus
			{ spellID=281400, dest=C_KULTIRAS }, -- Portal: Boralus
			{ spellID=344587, dest=C_SHADOWLANDS }, -- Teleport: Oribos
			{ spellID=344597, dest=C_SHADOWLANDS }, -- Portal: Oribos
			-- Horde
			{ spellID=3562, dest=C_EK }, -- Teleport: Undercity
			{ spellID=11418, dest=C_EK }, -- Portal: Undercity
			{ spellID=3566, dest=C_KALIMDOR }, -- Teleport: Thunder Bluff
			{ spellID=11420, dest=C_KALIMDOR }, -- Portal: Thunder Bluff
			{ spellID=3567, dest=C_KALIMDOR }, -- Teleport: Orgrimmar
			{ spellID=11417, dest=C_KALIMDOR }, -- Portal: Orgrimmar
			{ spellID=32272, dest=C_EK }, -- Teleport: Silvermoon
			{ spellID=32267, dest=C_EK }, -- Portal: Silvermoon
			{ spellID=35715, dest=C_OUTLAND }, -- Teleport: Shattrath
			{ spellID=35717, dest=C_OUTLAND }, -- Portal: Shattrath
			{ spellID=49358, dest=C_EK }, -- Teleport: Stonard
			{ spellID=49361, dest=C_EK }, -- Portal: Stonard
			{ spellID=53138, dest=C_NORTHREND }, -- Teleport: Dalaran (Northrend)
			{ spellID=53139, dest=C_NORTHREND }, -- Portal: Dalaran (Northrend)
			{ spellID=88344, dest=C_EK }, -- Teleport: Tol Barad
			{ spellID=88346, dest=C_EK }, -- Portal: Tol Barad
			{ spellID=132627, dest=C_PANDARIA }, -- Teleport: Vale of Eternal Blossoms
			{ spellID=132626, dest=C_PANDARIA }, -- Portal: Vale of Eternal Blossoms
			{ spellID=224871, dest=C_DRAENOR }, -- Teleport: Warspear
			{ spellID=224873, dest=C_DRAENOR }, -- Portal: Warspear
			{ spellID=281404, dest=C_ZANDALAR }, -- Teleport: Dazar'alor
			{ spellID=281402, dest=C_ZANDALAR }, -- Portal: Dazar'alor
			-- Neutral / Both
			{ spellID=193759, dest=C_LEGION }, -- Teleport: Hall of the Guardian
			{ spellID=446540, dest=C_KHAZALGAR }, -- Teleport: Dornogal
			{ spellID=446534, dest=C_KHAZALGAR }, -- Portal: Dornogal
		}
	}

	if classSpells[playerClass] then
		for _, entry in ipairs(classSpells[playerClass]) do
			local spellID = entry
			local dest = nil
			if type(entry) == "table" then
				spellID = entry.spellID
				dest = entry.dest
			end

			if dest and IsSpellKnown(spellID) then
				local info = C_Spell.GetSpellInfo(spellID)
				if info then
					AddToGroup(dest, {
						text = info.name,
						spellID = spellID,
						iconID = info.iconID,
						destination = dest,
						isKnown = true,
						isItem = false,
						isToy = false,
					})
				end
			end
		end
	end

	-- Items & Toys
	local teleportItemsDB = {
		-- Guild Cloaks (Stormwind/Orgrimmar)
		{ id = 65360, dest = (faction == "Horde" and C_KALIMDOR or C_EK) }, 
		{ id = 65274, dest = (faction == "Horde" and C_KALIMDOR or C_EK) },
		{ id = 63206, dest = (faction == "Horde" and C_KALIMDOR or C_EK) }, 
		{ id = 63207, dest = (faction == "Horde" and C_KALIMDOR or C_EK) },
		{ id = 63352, dest = (faction == "Horde" and C_KALIMDOR or C_EK) }, 
		{ id = 63353, dest = (faction == "Horde" and C_KALIMDOR or C_EK) },
		-- Hearthstones & Misc
		{ id = 140192, dest = C_LEGION }, -- Dalaran Hearthstone
		{ id = 110560, dest = C_DRAENOR }, -- Garrison Hearthstone
		{ id = 128353, dest = C_DRAENOR }, -- Admiral's Compass
		{ id = 37863, dest = C_EK }, -- Direbrew's Remote
		-- Engineering Wormholes / Transporters
		{ id = 48933, dest = C_NORTHREND }, -- Wormhole: Northrend
		{ id = 87215, dest = C_PANDARIA }, -- Wormhole: Pandaria
		{ id = 112059, dest = C_DRAENOR }, -- Wormhole: Draenor
		{ id = 151652, dest = C_LEGION }, -- Wormhole: Argus
		{ id = 168807, dest = C_KULTIRAS }, -- Wormhole: Kul Tiras
		{ id = 172924, dest = C_SHADOWLANDS }, -- Wormhole: Shadowlands
		{ id = 198156, dest = C_DRAGONISLES }, -- Wyrmhole: Dragon Isles
		{ id = 18984, dest = C_KALIMDOR }, -- Ultrasafe Transporter: Gadgetzan
		{ id = 18986, dest = C_OUTLAND }, -- Ultrasafe Transporter: Toshley's Station
		{ id = 30542, dest = C_OUTLAND }, -- Dimensional Ripper: Area 52
		{ id = 30544, dest = C_KALIMDOR }, -- Dimensional Ripper: Everlook
		{ id = 243056, dest = C_KHAZALGAR }, -- Delver's Mana-Bound Ethergate
		{ id = 230850, dest = C_KHAZALGAR }, -- Delve-O-Bot 7001
		-- Scrolls / Artifacts
		{ id = 139590, dest = C_EK }, -- Scroll: Ravenholdt
		{ id = 151016, dest = C_OUTLAND }, -- Fractured Necrolyte Skull
		{ id = 103678, dest = C_PANDARIA }, -- Time-Lost Artifact
		{ id = 32757, dest = C_OUTLAND }, -- Blessed Medallion of Karabor
		{ id = 133755, dest = "Fishing Node", isMulti=true },
		{ id = 184503, dest = "Random Location", isMulti=true },
		{ id = 205255, dest = C_DRAGONISLES }, -- Niffen Diggin' Mitts
		-- Requested "Path of..." Items (Assuming TWW/Recent)
		{ id = 1254400, dest = C_KHAZALGAR },
		{ id = 1254559, dest = C_KHAZALGAR },
		{ id = 1253563, dest = C_KHAZALGAR },
		{ id = 1254572, dest = C_KHAZALGAR },
		{ id = 393273, dest = C_DRAGONISLES }, -- Draconic Diploma
		{ id = 1254551, dest = C_KHAZALGAR },
		{ id = 1254557, dest = C_KHAZALGAR },
		{ id = 129898, dest = C_KALIMDOR }, -- The Skies (Vortex Pinnacle)
		{ id = 1254555, dest = C_KHAZALGAR },
		{ id = 210456, dest = C_EK, race = "Worgen" }, -- Tess's Peacebloom
	}

	for _, entry in ipairs(teleportItemsDB) do
		local itemID = entry.id
		local isToy = PlayerHasToy(itemID)
		
		-- Bank Detection Logic
		local countBags = C_Item.GetItemCount(itemID) -- Bags + Equipped
		local countTotal = C_Item.GetItemCount(itemID, true) -- Includes Bank/Warband
		local inBank = (countTotal > 0 and countBags == 0)

		local raceMatch = true
		if entry.race then
			local _, playerRace = UnitRace("player")
			if entry.race ~= playerRace then raceMatch = false end
		end
		
		if raceMatch and (isToy or countTotal > 0) then
			local usable = true
			if isToy then
				usable = IsToyUsable(itemID)
			elseif not inBank then
				-- Only check usability if it's actually in bags
				usable = IsUsableItem(itemID)
			end

			-- Always show if in bank, otherwise check usability
			if usable or inBank then
				local name = C_Item.GetItemNameByID(itemID) or GetItemInfo(itemID)
				local icon = C_Item.GetItemIconByID(itemID)
				
				-- If name is missing, request load (it might show up next refresh)
				if not name then C_Item.RequestLoadItemDataByID(itemID) end

				if name then
					local itemEntry = {
						text = name,
						toyName = name,
						itemID = itemID,
						iconID = icon,
						destination = entry.dest,
						isKnown = true,
						isItem = not isToy,
						isToy = isToy,
						toyID = isToy and itemID or nil,
						inBank = inBank
					}
					if entry.isMulti then
						table.insert(quirkyItems, itemEntry)
					else
						AddToGroup(entry.dest, itemEntry)
					end
				end
			end
		end
	end

	-- Special Conditional Items
	-- Shadowguard Translocator: Only available if in inventory AND in Manaforge Omega Raid
	local shadowguardID = 0 -- FIXME: Replace with actual Shadowguard Translocator Item ID
	if C_Item.GetItemCount(shadowguardID) > 0 then
		local instanceName, instanceType = GetInstanceInfo()
		if instanceName == "Manaforge Omega" and instanceType == "raid" then
			local name = C_Item.GetItemNameByID(shadowguardID) or "Shadowguard Translocator"
			local icon = C_Item.GetItemIconByID(shadowguardID) or 136121
			AddToGroup(C_OUTLAND, {
				text = name,
				itemID = shadowguardID,
				iconID = icon,
				isKnown = true,
				isItem = true,
				isToy = false,
			})
		end
	end

	-- Underlight Angler: Undercurrent (Teleport to nearest fishing node)
	-- Only available if the artifact is equipped and trait is unlocked
	if IsSpellKnown(201947) then
		local info = C_Spell.GetSpellInfo(201947)
		if info then
			table.insert(quirkyItems, {
				text = info.name,
				spellID = 201947,
				iconID = info.iconID,
				isKnown = true,
				isItem = false,
				isToy = false,
			})
		end
	end

	-- Mobile Telemancy Beacon: Only available in Suramar
	local beaconID = 140324
	if PlayerHasToy(beaconID) then
		local mapID = C_Map.GetBestMapForUnit("player")
		if mapID == 680 then -- Suramar
			local name = C_Item.GetItemNameByID(beaconID) or "Mobile Telemancy Beacon"
			local icon = C_Item.GetItemIconByID(beaconID)
			AddToGroup(C_LEGION, {
				text = name,
				itemID = beaconID,
				iconID = icon,
				isKnown = true,
				isItem = false,
				isToy = true,
				toyID = beaconID
			})
		end
	end

	-- Vindicaar Beacon: Only available in Argus
	local vindicaarID = 152455
	if C_Item.GetItemCount(vindicaarID) > 0 then
		local mapID = C_Map.GetBestMapForUnit("player")
		-- Krokuun (830), Mac'Aree (882), Antoran Wastes (885)
		if mapID == 830 or mapID == 882 or mapID == 885 then
			local name = C_Item.GetItemNameByID(vindicaarID) or "Vindicaar Beacon"
			local icon = C_Item.GetItemIconByID(vindicaarID)
			AddToGroup(C_LEGION, {
				text = name,
				itemID = vindicaarID,
				iconID = icon,
				isKnown = true,
				isItem = true,
				isToy = false,
			})
		end
	end

	-- Kirin Tor / Sunreaver Beacon: Only available in Isle of Thunder
	local beaconKT, beaconSR = 95566, 95565
	if C_Item.GetItemCount(beaconKT) > 0 or C_Item.GetItemCount(beaconSR) > 0 then
		local mapID = C_Map.GetBestMapForUnit("player")
		if mapID == 504 then -- Isle of Thunder
			local function AddBeacon(id, defaultName)
				if C_Item.GetItemCount(id) > 0 then
					local name = C_Item.GetItemNameByID(id) or defaultName
					local icon = C_Item.GetItemIconByID(id)
					AddToGroup(C_PANDARIA, {
						text = name,
						itemID = id,
						iconID = icon,
						isKnown = true,
						isItem = true,
						isToy = false,
					})
				end
			end
			AddBeacon(beaconKT, "Kirin Tor Beacon")
			AddBeacon(beaconSR, "Sunreaver Beacon")
		end
	end

	-- Convert Groups to Sections
	local sortedDests = {}
	for dest in pairs(groups) do table.insert(sortedDests, dest) end
	table.sort(sortedDests)

	for _, dest in ipairs(sortedDests) do
		table.sort(groups[dest], function(a, b) return (a.text or "") < (b.text or "") end)
		table.insert(sections, { title = dest, items = groups[dest] })
	end

	-- Add Quirky Section
	if #quirkyItems > 0 then
		table.sort(quirkyItems, function(a, b) return (a.text or "") < (b.text or "") end)
		table.insert(sections, { title = quirkyTitle, items = quirkyItems })
	end

	return sections
end

local hearthstoneToys = {
	{ isToy = true, icon = 133469, id = 245970 }, -- P.O.S.T. Master's Express Hearthstone
	{ isToy = true, icon = 5852174, id = 246565 }, -- Cosmic Hearthstone
	{ isToy = true, icon = 4622300, id = 235016 }, -- Redeployment Module
	{ isToy = true, icon = 134414, id = 6948, isItem = true }, -- Default Hearthstone (Item)
	{ isToy = true, icon = 236222, id = 54452 }, -- Ethereal Portal
	{ isToy = true, icon = 458254, id = 64488 }, -- The Innkeeper's Daughter
	{ isToy = true, icon = 255348, id = 93672 }, -- Dark Portal
	{ isToy = true, icon = 2124576, id = 162973 }, -- Greatfather Winter's Hearthstone
	{ isToy = true, icon = 2124575, id = 163045 }, -- Headless Horseman's Hearthstone
	{ isToy = true, icon = 2491049, id = 165669 }, -- Lunar Elder's Hearthstone
	{ isToy = true, icon = 2491048, id = 165670 }, -- Peddlefeet's Lovely Hearthstone
	{ isToy = true, icon = 2491065, id = 165802 }, -- Noble Gardener's Hearthstone
	{ isToy = true, icon = 2491064, id = 166746 }, -- Fire Eater's Hearthstone
	{ isToy = true, icon = 2491063, id = 166747 }, -- Brewfest Reveler's Hearthstone
	{ isToy = true, icon = 2491049, id = 168907 }, -- Holographic Digitalization Hearthstone
	{ isToy = true, icon = 3084684, id = 172179 }, -- Eternal Traveler's Hearthstone
	{ isToy = true, icon = 3528303, id = 188952 }, -- Dominated Hearthstone
	{ isToy = true, icon = 3950360, id = 190196 }, -- Enlightened Hearthstone
	{ isToy = true, icon = 3954409, id = 190237 }, -- Broker Translocation Matrix
	{ isToy = true, icon = 4571434, id = 193588 }, -- Timewalker's Hearthstone
	{ isToy = true, icon = 4080564, id = 200630 }, -- Ohn'ir Windsage's Hearthstone
	{ isToy = true, icon = 1708140, id = 206195 }, -- Path of the Naaru
	{ isToy = true, icon = 5333528, id = 208704 }, -- Deepdweller's Earth Hearthstone
	{ isToy = true, icon = 2491064, id = 209035 }, -- Hearthstone of the Flame
	{ isToy = true, icon = 5524923, id = 212337 }, -- Stone of the Hearth
	{ isToy = true, icon = 5891370, id = 228940 }, -- Notorious Thread's Hearthstone
	{ isToy = true, icon = 6383489, id = 236687 }, -- Explosive Hearthstone
	{ isToy = true, icon = 1029741, id = 263489 }, -- Naaru's Enfold
	{ isToy = true, icon = 1686574, id = 210455, race = { "LightforgedDraenei", "Draenei" } }, -- Draenic Hologem
	{ isToy = true, icon = 3257748, id = 184353 }, -- Kyrian Hearthstone
	{ isToy = true, icon = 3514225, id = 183716 }, -- Venthyr Sinstone
	{ isToy = true, icon = 3489827, id = 180290 }, -- Night Fae Hearthstone
	{ isToy = true, icon = 3716927, id = 182773 }, -- Necrolord Hearthstone
}

local function BuildHomeSection()
	local available = {}
	local _, playerRace = UnitRace("player")
	for _, v in ipairs(hearthstoneToys) do
		local isKnown = (v.isItem and C_Item.GetItemCount(v.id) > 0) or (not v.isItem and PlayerHasToy(v.id))
		if isKnown then
			local usable = true
			if v.race then
				usable = false
				for _, r in ipairs(v.race) do if r == playerRace then usable = true break end end
			end
			if usable then
				local name = C_Item.GetItemNameByID(v.id)
				if not name then C_Item.RequestLoadItemDataByID(v.id) end
				table.insert(available, {
					text = "Hearthstone",
					toyName = name,
					iconID = v.icon or C_Item.GetItemIconByID(v.id),
					isKnown = true,
					isToy = not v.isItem,
					toyID = not v.isItem and v.id or nil,
					isItem = v.isItem,
					itemID = v.isItem and v.id or nil,
				})
			end
		end
	end

	local items = {}
	if #available > 0 then
		local pick = available[math.random(#available)]
		table.insert(items, pick)
	end

	-- Flight Master's Whistle (Top Priority)
	if C_Item.GetItemCount(141605) > 0 then
		table.insert(items, 1, {
			text = C_Item.GetItemNameByID(141605) or "Flight Master's Whistle",
			itemID = 141605,
			iconID = C_Item.GetItemIconByID(141605),
			isKnown = true,
			isItem = true,
			isToy = false,
		})
	end

	-- The Warping Wise
	if C_Item.GetItemCount(238379) > 0 and UnitLevel("player") >= 90 then
		local name = C_Item.GetItemNameByID(238379)
		if not name then C_Item.RequestLoadItemDataByID(238379) end
		table.insert(items, 1, {
			text = name or "The Warping Wise",
			itemID = 238379,
			iconID = C_Item.GetItemIconByID(238379),
			isKnown = true,
			isItem = true,
			isToy = false,
		})
	end

	-- Personal Key to the Arcantina
	local arcantinaID = 228926
	local isArcantinaToy = PlayerHasToy(arcantinaID)
	if isArcantinaToy or C_Item.GetItemCount(arcantinaID, true) > 0 then
		local name = C_Item.GetItemNameByID(arcantinaID)
		if not name then C_Item.RequestLoadItemDataByID(arcantinaID) end
		table.insert(items, 1, {
			text = name or "Personal Key to the Arcantina",
			toyName = name,
			iconID = C_Item.GetItemIconByID(arcantinaID),
			isKnown = true,
			isItem = not isArcantinaToy,
			isToy = isArcantinaToy,
			toyID = isArcantinaToy and arcantinaID or nil,
			itemID = not isArcantinaToy and arcantinaID or nil,
		})
	end

	-- Class & Racial Teleports
	local _, playerClass = UnitClass("player")
	local _, playerRace = UnitRace("player")

	if playerClass == "DRUID" then
		if IsSpellKnown(193753) then -- Dreamwalk
			local info = C_Spell.GetSpellInfo(193753)
			if info then table.insert(items, { text = info.name, spellID = 193753, iconID = info.iconID, isKnown = true }) end
		elseif IsSpellKnown(18960) then -- Moonglade
			local info = C_Spell.GetSpellInfo(18960)
			if info then table.insert(items, { text = info.name, spellID = 18960, iconID = info.iconID, isKnown = true }) end
		end
	elseif playerClass == "DEATHKNIGHT" and IsSpellKnown(50977) then -- Death Gate
		local info = C_Spell.GetSpellInfo(50977)
		if info then table.insert(items, { text = info.name, spellID = 50977, iconID = info.iconID, isKnown = true }) end
	elseif playerClass == "MONK" and IsSpellKnown(126892) then -- Zen Pilgrimage
		local info = C_Spell.GetSpellInfo(126892)
		if info then table.insert(items, { text = info.name, spellID = 126892, iconID = info.iconID, isKnown = true }) end
	elseif playerClass == "SHAMAN" and IsSpellKnown(556) then -- Astral Recall
		local info = C_Spell.GetSpellInfo(556)
		if info then table.insert(items, { text = info.name, spellID = 556, iconID = info.iconID, isKnown = true }) end
	end

	if playerRace == "DarkIronDwarf" and IsSpellKnown(265225) then -- Mole Machine
		local info = C_Spell.GetSpellInfo(265225)
		if info then table.insert(items, { text = info.name, spellID = 265225, iconID = info.iconID, isKnown = true }) end
	elseif playerRace == "Vulpera" and IsSpellKnown(312372) then -- Return to Camp
		local info = C_Spell.GetSpellInfo(312372)
		if info then table.insert(items, { text = info.name, spellID = 312372, iconID = info.iconID, isKnown = true }) end
	elseif playerRace == "Haronir" then
		-- Haronir Racial Teleport (Placeholder)
		-- if IsSpellKnown(000000) then ... end
	end

	-- Home Plot Teleport
	local homePlotSpellName = "Teleport to Plot"
	local homePlotSpellID = 0
	local homePlotIcon = 134414 -- Fallback icon

	local info = C_Spell.GetSpellInfo(homePlotSpellName)
	if info then
		homePlotSpellID = info.spellID
		homePlotIcon = info.iconID
	end
	
	local dashboardInfo = C_Spell.GetSpellInfo("Housing Dashboard")
	if dashboardInfo then
		homePlotIcon = dashboardInfo.iconID
	end

	-- Plumber Integration
	if C_AddOns.IsAddOnLoaded("Plumber") then
		local pText = "Teleport to Plot"
		local pMacro = "/click PLMR_HOME1"
		local pIcon = 7252953

		if C_HousingNeighborhood and C_HousingNeighborhood.CanReturnAfterVisitingHouse and C_HousingNeighborhood.CanReturnAfterVisitingHouse() then
			pText = "Leave Home"
			pMacro = "/click PLMR_HOME4"
			pIcon = 236350
		end

		table.insert(items, {
			text = pText,
			macroText = pMacro,
			iconID = pIcon,
			isKnown = true,
			isItem = false,
			isToy = false,
		})
	else
		-- Check if account has at least one plot available (Spell Known or C_Housing check)
		local hasPlot = (homePlotSpellID > 0 and IsSpellKnown(homePlotSpellID))
		if not hasPlot then
			local housingAPI = C_PlayerHousing or C_Housing
			if housingAPI then hasPlot = true end
		end

		if hasPlot then
			local entry = {
				text = homePlotSpellName,
				iconID = homePlotIcon,
				isKnown = true,
				isItem = false,
				isToy = false,
			}
			if homePlotSpellID > 0 then
				entry.spellID = homePlotSpellID
			else
				entry.macroText = "/cast " .. homePlotSpellName
			end
			table.insert(items, entry)
		end
	end

	if #items > 0 then return { title = "", items = items, isGrid = true } end
	return nil
end

local function PopulatePanel()
	if not panel then return end
	ClearContent()

	-- keep references for lightweight cooldown refresh
	panel._allButtons = {}

	if not (ZipTrixDB and ZipTrixDB.enableSecretsHelper) then
		panel.viewMode = VIEW_GATEWAYS
	end

	if panel.SecretsButton then
		panel.SecretsButton:SetShown(ZipTrixDB and ZipTrixDB.enableSecretsHelper)
	end

	local combined = {}

	if panel.viewMode == VIEW_SECRETS then
		if panel.Title then panel.Title:SetText("Everything Else") end
		if ns.GetEverythingElseEntries then
			local secrets = ns.GetEverythingElseEntries()
			for _, sec in ipairs(secrets) do
				table.insert(combined, sec)
			end
		end
	else
		if panel.Title then panel.Title:SetText(L["DungeonCompendium"] or "Gateways") end
		-- Combine sections with preferred order: Favorites, HOME, Season, then others
		local comp = BuildSpellEntries() or {}
		local favoritesSec, homeSec
		local others = {}
		for _, sec in ipairs(comp) do
			local t = sec and sec.title
			if t == FAVORITES then
				favoritesSec = sec
			elseif t == HOME then
				homeSec = sec
			else
				table.insert(others, sec)
			end
		end

		if not homeSec then
			homeSec = BuildHomeSection()
		end

		if favoritesSec then table.insert(combined, favoritesSec) end
		if homeSec then table.insert(combined, homeSec) end

		if ZipTrixDB and ZipTrixDB["teleportsWorldMapShowSeason"] then
			local seasonSec = BuildSeasonSection()
			if seasonSec and seasonSec.items and #seasonSec.items > 0 then table.insert(combined, seasonSec) end
		end

		local extra = BuildExtraTeleports()
		for _, sec in ipairs(extra) do
			table.insert(combined, sec)
		end

		for _, sec in ipairs(others) do
			table.insert(combined, sec)
		end
	end

	if not combined or #combined == 0 then
		local msg = (L["teleportCompendiumHeadline"] or "Teleports") .. ": None available"
		local label = scrollBox:CreateFontString(nil, "OVERLAY", "GameFontDisable")
		label:SetPoint("TOPLEFT", 10, -10)
		label:SetText(msg)
		scrollBox:SetHeight(40)
		return
	end

	-- Layout metrics similar to MapLegendScrollFrame
	local leftPadding = 12
	local topPadding = 10
	local categorySpacing = 10
	local buttonSpacingY = 5
	local stride = 2 -- 2 columns
	local rowHeight = 28
	
	if panel.viewMode == VIEW_SECRETS then
		stride = 1
	end

	-- compute available width per column
	local scrollW = panel.Scroll:GetWidth() or 330
	local scrollbarWidth = (panel.Scroll.ScrollBar and panel.Scroll.ScrollBar:GetWidth()) or 18
	local usableWidth = math.max(120, scrollW - scrollbarWidth - 20)
	local colWidth = math.floor((usableWidth - 0) / stride) -- no horizontal spacing requested

	local yOffset = -topPadding
	for _, section in ipairs(combined) do
		-- category container
		local category = CreateFrame("Frame", nil, scrollBox)
		category:SetPoint("TOPLEFT", leftPadding, yOffset)
		category:SetSize(usableWidth, 10) -- temporary height; will expand below

		-- title
		local titleFS = category:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		titleFS:SetText(section.title or "")

		local font = "Fonts\\FRIZQT__.TTF"
		if LibStub then
			local LSM = LibStub("LibSharedMedia-3.0", true)
			if LSM then font = LSM:Fetch("font", "Expressway") or font end
		end
		titleFS:SetFont(font, 13, "OUTLINE") -- Setzt die Schriftart, -größe und -stil (OUTLINE)

		if section.isCollapsible then
			if not f.collapsedState then f.collapsedState = {} end
			if f.collapsedState[section.title] == nil then f.collapsedState[section.title] = true end

			local btn = CreateFrame("Button", nil, category)
			btn:SetSize(usableWidth, 20)
			btn:SetPoint("TOPLEFT", 0, 2)

			local bg = btn:CreateTexture(nil, "BACKGROUND")
			bg:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitle-Background")
			bg:SetAllPoints()
			bg:SetVertexColor(1, 1, 1, 0.8)

			local hl = btn:CreateTexture(nil, "HIGHLIGHT")
			hl:SetAllPoints()
			hl:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
			hl:SetBlendMode("ADD")
			hl:SetAlpha(0.7)

			btn:SetScript("OnClick", function()
				f.collapsedState[section.title] = not f.collapsedState[section.title]
				f:RefreshPanel()
			end)

			-- Progress Tooltip on Header
			if panel.viewMode == VIEW_SECRETS and section.progressScript then
				btn:SetScript("OnEnter", function(self)
					GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
					GameTooltip:SetText("Progress", 1, 0.82, 0)
					if type(section.progressScript) == "function" then
						GameTooltip:AddLine(section.progressScript(), 1, 1, 1, true)
					else
						GameTooltip:AddLine("Click pills inside to check progress.", 1, 1, 1)
					end
					GameTooltip:Show()
				end)
				btn:SetScript("OnLeave", function() GameTooltip:Hide() end)
			end

			local arrow = btn:CreateTexture(nil, "ARTWORK")
			arrow:SetSize(14, 14)
			arrow:SetPoint("LEFT", 0, 0)
			if f.collapsedState[section.title] then
				arrow:SetAtlas("Options-List-Expand")
			else
				arrow:SetAtlas("Options-List-Collapse")
			end
			titleFS:SetPoint("LEFT", arrow, "RIGHT", 5, 0)
		else
			titleFS:SetPoint("TOPLEFT", 0, 0)
		end

		-- build buttons for this category
		local buttons = {}
		local totalHeight = 0
		local headerHeight = (titleFS:GetStringHeight() or 14) + 3
		if section.isCollapsible then headerHeight = 22 end

		if not (section.isCollapsible and f.collapsedState and f.collapsedState[section.title]) then
			for i, entry in ipairs(section.items or {}) do
				local b
				if panel.viewMode == VIEW_SECRETS then
					b = CreateSecretRow(category, entry, usableWidth)
					-- Manual layout for secrets to handle variable height
					b:SetPoint("TOPLEFT", 0, -(totalHeight + headerHeight))
					totalHeight = totalHeight + b:GetHeight() + 2
				elseif section.isGrid then
					b = CreateSecureSpellButton(category, entry, 40)
					table.insert(buttons, b)
					table.insert(panel._allButtons, b)
				else
					b = CreateLegendRowButton(category, entry, colWidth, rowHeight)
					table.insert(buttons, b)
					table.insert(panel._allButtons, b)
				end
			end
		end

		-- grid layout with 2 columns, xSpacing=0, ySpacing=5
		if #buttons > 0 and panel.viewMode ~= VIEW_SECRETS then
			local layout
			local anchor
			if section.isGrid then
				local iconSize = 40
				local spacing = 5
				local gridStride = math.floor(usableWidth / (iconSize + spacing))
				layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, gridStride, spacing, spacing)
				anchor = CreateAnchor("TOPLEFT", category, "TOPLEFT", 0, -5)
			else
				layout = AnchorUtil.CreateGridLayout(GridLayoutMixin.Direction.TopLeftToBottomRight, stride, 0, buttonSpacingY)
				anchor = CreateAnchor("TOPLEFT", category, "TOPLEFT", 0, -3 - (titleFS:GetStringHeight() or 14))
			end
			AnchorUtil.GridLayout(buttons, anchor, layout)

			-- adjust button widths to column width
			if not section.isGrid then
				for _, b in ipairs(buttons) do
					b:SetWidth(colWidth)
				end
			end
		end

		-- compute category height: title + rows*rowHeight + spacing
		local rows = math.ceil(#buttons / stride)
		local catHeight
		if panel.viewMode == VIEW_SECRETS then
			catHeight = headerHeight + totalHeight
		elseif section.isGrid then
			local iconSize = 40
			local spacing = 5
			local gridStride = math.floor(usableWidth / (iconSize + spacing))
			local gridRows = math.ceil(#buttons / gridStride)
			catHeight = (gridRows * (iconSize + spacing)) + 10
		else
			catHeight = (titleFS:GetStringHeight() or 14) + 3 + (rows > 0 and ((rows - 1) * (rowHeight + buttonSpacingY) + rowHeight) or 0)
		end
		category:SetHeight(catHeight)

		yOffset = yOffset - catHeight - categorySpacing
	end

	-- update scroll child extents
	scrollBox:SetHeight(math.abs(yOffset) + topPadding)
	if panel.Scroll and panel.Scroll.UpdateScrollChildRect then panel.Scroll:UpdateScrollChildRect() end

	-- Respect combat: disable all button interactions while in combat
end

-- Tab creation -------------------------------------------------------------
-- tabButton declared above for forward reference

-- Prefer anchoring below WorldQuestTab's custom tab if present
local function GetPreferredTabAnchor()
	local wqtTab = _G and _G["WQT_QuestMapTab"]
	if wqtTab and wqtTab.GetObjectType and wqtTab:GetObjectType() then return wqtTab end
	return QuestMapFrame and (QuestMapFrame.MapLegendTab or QuestMapFrame.QuestsTab or (QuestMapFrame.DetailsFrame and QuestMapFrame.DetailsFrame.BackFrame)) or nil
end

local function EnsureTab(parent, anchorTo)
	if tabButton and tabButton:GetParent() ~= parent then tabButton:SetParent(parent) end
	-- If the tab already exists, still allow re-anchoring when a better anchor shows up later
	if tabButton then
		if anchorTo then
			tabButton:ClearAllPoints()
			tabButton:SetPoint("TOP", anchorTo, "BOTTOM", 0, -15)
		end
		return tabButton
	end

	-- Use Blizzard QuestLog tab template for a perfect visual match
	tabButton = CreateFrame("Button", "zipWorldMapDungeonPortalsTab", parent, "QuestLogTabButtonTemplate")
	tabButton:SetSize(32, 32)
	if anchorTo then
		tabButton:SetPoint("TOP", anchorTo, "BOTTOM", 0, -15)
	else
		tabButton:SetPoint("TOPRIGHT", -6, -100)
	end

	-- Mirror hover/selected visuals via the template, but we'll supply our own icon
	tabButton.activeAtlas = "questlog-tab-icon-maplegend"
	tabButton.inactiveAtlas = "questlog-tab-icon-maplegend-inactive"
	tabButton.tooltipText = (L["DungeonCompendium"] or "Dungeon Portals")
	tabButton.displayMode = DISPLAY_MODE

	-- Hide template's atlas-driven icon and add our persistent custom icon
	if tabButton.Icon then tabButton.Icon:SetAlpha(0) end
	local customIcon = tabButton:CreateTexture(nil, "ARTWORK")
	customIcon:SetPoint("CENTER", -2, 0)
	customIcon:SetSize(20, 20)
	customIcon:SetTexture(ICON_INACTIVE)
	customIcon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	-- Apply sepia styling to match standard map tabs
	customIcon:SetDesaturated(true)
	customIcon:SetVertexColor(0.6, 0.5, 0.4)
	tabButton.CustomIcon = customIcon

	-- helper to flip icon depending on selection
	local function UpdateTabIconChecked(tb, checked)
		if not tb or not tb.CustomIcon then return end
		-- Keep desaturated to match the parchment style
		tb.CustomIcon:SetDesaturated(true)
		if checked then
			tb.CustomIcon:SetVertexColor(1.0, 0.9, 0.8, 1.0) -- Active: Bright parchment
		else
			tb.CustomIcon:SetVertexColor(0.5, 0.4, 0.3, 0.8) -- Inactive: Darker brown
		end
	end

	-- Guard against Blizzard re-showing the template icon
	if tabButton.Icon and not tabButton.Icon._zipHook then
		hooksecurefunc(tabButton.Icon, "Show", function(icon) icon:SetAlpha(0) end)
		hooksecurefunc(tabButton.Icon, "SetAtlas", function(icon) icon:SetAlpha(0) end)
		tabButton.Icon._zipHook = true
	end

	-- make sure we're not selected by default
	if tabButton.SetChecked then tabButton:SetChecked(false) end
	if tabButton.SelectedTexture then tabButton.SelectedTexture:SetAlpha(0) end
	SafeSetVisible(tabButton, true)
	tabButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	-- Keep custom icon clear on state changes
	if not tabButton._zipStateHooks then
		hooksecurefunc(tabButton, "SetChecked", function(self, checked)
			-- if self.CustomIcon then self.CustomIcon:SetDesaturated(false) end
			UpdateTabIconChecked(self, checked)
		end)
		hooksecurefunc(tabButton, "Disable", function(self)
			if self.CustomIcon then self.CustomIcon:SetDesaturated(true); self.CustomIcon:SetVertexColor(0.5, 0.5, 0.5) end
		end)
		hooksecurefunc(tabButton, "Enable", function(self)
			if self.CustomIcon then UpdateTabIconChecked(self, self:GetChecked()) end
		end)
		tabButton._zipStateHooks = true
	end

	-- Initialize checked state and icon based on QuestMapFrame displayMode
	local isActive = QuestMapFrame and QuestMapFrame.displayMode == DISPLAY_MODE
	if tabButton.SetChecked then tabButton:SetChecked(isActive) end
	-- Keep panel alpha in sync with current mode without Show/Hide
	if panel then SafeSetVisible(panel, isActive and true or false) end

	tabButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.tooltipText)
		GameTooltip:Show()
	end)
	tabButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

	tabButton:SetScript("OnMouseUp", function(self, button, upInside)
		if button ~= "LeftButton" or not upInside then return end
		if not panel then return end
		if QuestMapFrame and QuestMapFrame.SetDisplayMode then
			QuestMapFrame:SetDisplayMode(DISPLAY_MODE)
		end
	end)
	return tabButton
end

function f:TryInit()
	-- Only ensure injection when enabled
	if not QuestMapFrame then return end
	if not ZipTrixDB or not ZipTrixDB["teleportsWorldMapEnabled"] then
		if panel then SafeSetVisible(panel, false) end
		if tabButton then SafeSetVisible(tabButton, false) end
		return
	end

	local parent = QuestMapFrame
	EnsurePanel(parent)

	-- Re-anchor our panel whenever the map resizes or the content anchor becomes valid
	if not parent._zipSizeHook then
		parent:HookScript("OnSizeChanged", function()
			if panel and panel:GetParent() then
				panel:ClearAllPoints()
				local ca = QuestMapFrame and QuestMapFrame.ContentsAnchor
				if ca and ca.GetWidth and ca:GetWidth() > 0 and ca:GetHeight() > 0 then
					panel:SetPoint("TOPLEFT", ca, "TOPLEFT", 0, -29)
					panel:SetPoint("BOTTOMRIGHT", ca, "BOTTOMRIGHT", -22, 0)
				else
					panel:SetAllPoints(panel:GetParent())
				end
				f:RefreshPanel()
			end
		end)
		parent._zipSizeHook = true
	end
	if QuestMapFrame.ContentsAnchor and not QuestMapFrame.ContentsAnchor._zipSizeHook then
		QuestMapFrame.ContentsAnchor:HookScript("OnSizeChanged", function()
			if panel and panel:GetParent() then
				panel:ClearAllPoints()
				local ca = QuestMapFrame and QuestMapFrame.ContentsAnchor
				if ca and ca.GetWidth and ca:GetWidth() > 0 and ca:GetHeight() > 0 then
					panel:SetPoint("TOPLEFT", ca, "TOPLEFT", 0, -29)
					panel:SetPoint("BOTTOMRIGHT", ca, "BOTTOMRIGHT", -22, 0)
				else
					panel:SetAllPoints(panel:GetParent())
				end
				f:RefreshPanel()
			end
		end)
		QuestMapFrame.ContentsAnchor._zipSizeHook = true
	end

	-- Anchor the tab under the preferred tab (WorldQuestTab if present)
	local anchor = GetPreferredTabAnchor()
	EnsureTab(parent, anchor)

	-- If WorldQuestTab is enabled but its tab isn't created yet, try re-anchoring shortly after
	if C_AddOns and C_AddOns.GetAddOnEnableState and pcall(C_AddOns.GetAddOnEnableState, "WorldQuestTab") and C_AddOns.GetAddOnEnableState("WorldQuestTab") == 2 then
		C_Timer.After(0, function()
			local wqt = _G and _G["WQT_QuestMapTab"]
			if wqt then
				EnsureTab(parent, wqt)
				if QuestMapFrame and QuestMapFrame.ValidateTabs then QuestMapFrame:ValidateTabs() end
			end
		end)
		C_Timer.After(0.2, function()
			local wqt = _G and _G["WQT_QuestMapTab"]
			if wqt then
				EnsureTab(parent, wqt)
				if QuestMapFrame and QuestMapFrame.ValidateTabs then QuestMapFrame:ValidateTabs() end
			end
		end)
	end

	-- Inject our panel into ContentFrames so SetDisplayMode can manage visibility
	if QuestMapFrame.ContentFrames then
		local exists = false
		for _, frame in ipairs(QuestMapFrame.ContentFrames) do
			if frame == panel then
				exists = true
				break
			end
		end
		if not exists then table.insert(QuestMapFrame.ContentFrames, panel) end
	end

	-- Also register our tab as a managed tab for consistent checked state
	if QuestMapFrame.TabButtons then
		local present = false
		for _, b in ipairs(QuestMapFrame.TabButtons) do
			if b == tabButton then
				present = true
				break
			end
		end
		if not present then table.insert(QuestMapFrame.TabButtons, tabButton) end
	end

	-- Ensure tabs layout is recalculated so our tab appears immediately
	if QuestMapFrame and QuestMapFrame.ValidateTabs then QuestMapFrame:ValidateTabs() end

	-- Track display mode changes to update our tab state and refresh content
	if EventRegistry and not f._zipDisplayEvent then
		EventRegistry:RegisterCallback("QuestLog.SetDisplayMode", function(_, mode)
			if mode == DISPLAY_MODE then
				if tabButton and tabButton.SetChecked then tabButton:SetChecked(true) end
				if panel then SafeSetVisible(panel, true) end
				f:RefreshPanel()
			else
				if tabButton and tabButton.SetChecked then tabButton:SetChecked(false) end
				if panel then SafeSetVisible(panel, false) end
			end
		end, f)
		f._zipDisplayEvent = true
	end

	-- Also ensure visibility is synced when Blizzard flips display mode via the frame method
	if QuestMapFrame and QuestMapFrame.SetDisplayMode and not QuestMapFrame._zipSetDisplayHook then
		hooksecurefunc(QuestMapFrame, "SetDisplayMode", function(_, mode)
			if mode == DISPLAY_MODE then
				if panel then SafeSetVisible(panel, true) end
			else
				if panel then SafeSetVisible(panel, false) end
			end
		end)
		QuestMapFrame._zipSetDisplayHook = true
	end

	-- Proactively build content once; subsequent tab/display changes will refresh as needed
	C_Timer.After(0, function() f:RefreshPanel() end)
end

function f:RefreshPanel()
	if not InCombatLockdown() then
		if panel and panel.Blocker then
			panel.Blocker:SetAlpha(0)
			panel.Blocker:EnableMouse(false)
			panel.Blocker:EnableMouseWheel(false)
		end
		SetCombatScrolling(true)
		if not ZipTrixDB or not ZipTrixDB["teleportsWorldMapEnabled"] then
			if panel then SafeSetVisible(panel, false) end
			if tabButton then SafeSetVisible(tabButton, false) end
			return
		end
		if not panel then return end
		PopulatePanel()
	end
end

-- Only recompute and apply cooldowns for existing buttons
function f:UpdateCooldowns()
	if not panel or not panel:IsShown() then return end
	for _, b in ipairs(panel._allButtons or {}) do
		if b and b:IsVisible() and b.cooldownFrame and b.entry then ApplyCooldownToButton(b) end
	end
end

-- Events to build/refresh --------------------------------------------------
local function worldMapEventHandler(self, event, arg1)
	if event == "PLAYER_REGEN_DISABLED" then
		SetCombatScrolling(false)
		if panel and panel.Blocker then
			panel.Blocker:SetAlpha(0)
			panel.Blocker:EnableMouse(false)
			panel.Blocker:EnableMouseWheel(false)
		end
		-- Avoid Show/Hide while in combat
		return
	elseif event == "PLAYER_REGEN_ENABLED" then
		SetCombatScrolling(true)
		SetButtonsInteractable(true)
		if panel and panel.Blocker then
			panel.Blocker:SetAlpha(0)
			panel.Blocker:EnableMouse(false)
			panel.Blocker:EnableMouseWheel(false)
		end
		-- Apply any deferred visibility changes now that combat ended
		if panel and panel._zipPendingVisible ~= nil then
			SafeSetVisible(panel, panel._zipPendingVisible)
			panel._zipPendingVisible = nil
		end
		if tabButton and tabButton._zipPendingVisible ~= nil then
			SafeSetVisible(tabButton, tabButton._zipPendingVisible)
			tabButton._zipPendingVisible = nil
		end
		if f._pendingOpen then
			f._pendingOpen = nil
			if ns.OpenWorldMapTeleportPanel then ns.OpenWorldMapTeleportPanel(true) end
		end
		if WorldMapFrame and WorldMapFrame:IsShown() and ZipTrixDB and ZipTrixDB["teleportsWorldMapEnabled"] then 
            if not f._refreshTimer then
                f._refreshTimer = C_Timer.After(0.1, function() f._refreshTimer = nil; f:RefreshPanel() end)
            end
        end
		-- fall through to allow refresh if map is visible
	end
	if event == "ADDON_LOADED" and arg1 == "Blizzard_WorldMap" then
		-- Late-load: attach our OnShow hook once the World Map exists
		if WorldMapFrame and not WorldMapFrame._zipTeleportHook then
			WorldMapFrame:HookScript("OnShow", function()
				if ZipTrixDB and ZipTrixDB["teleportsWorldMapEnabled"] then
					f:TryInit()
					if QuestMapFrame and QuestMapFrame.ValidateTabs then QuestMapFrame:ValidateTabs() end
					if f._selectOnNextShow and QuestMapFrame and QuestMapFrame.SetDisplayMode then
						QuestMapFrame:SetDisplayMode(DISPLAY_MODE)
						f._selectOnNextShow = nil
					end
					if not f._refreshTimer then
                        f._refreshTimer = C_Timer.After(0.1, function() f._refreshTimer = nil; f:RefreshPanel() end)
                    end
				else
					if panel then SafeSetVisible(panel, false) end
					if tabButton then SafeSetVisible(tabButton, false) end
				end
			end)
			WorldMapFrame._zipTeleportHook = true
		end
		return
	elseif event == "ADDON_LOADED" and arg1 == "WorldQuestTab" then
		-- WorldQuestTab just loaded; if its map tab exists, re-anchor below it
		if QuestMapFrame and WorldMapFrame then
			local wqt = _G and _G["WQT_QuestMapTab"]
			if wqt then
				EnsureTab(QuestMapFrame, wqt)
				if QuestMapFrame and QuestMapFrame.ValidateTabs then QuestMapFrame:ValidateTabs() end
			end
		end
		-- Do not return here; allow further processing when map is shown
	end

	-- Only refresh when the map is actually visible; avoid work while hidden
	if not WorldMapFrame or not WorldMapFrame:IsShown() then return end
	if event == "SPELL_UPDATE_COOLDOWN" or event == "BAG_UPDATE_COOLDOWN" then
		f:UpdateCooldowns()
	elseif event == "SPELLS_CHANGED" or event == "BAG_UPDATE_DELAYED" or event == "TOYS_UPDATED" 
		or event == "HEARTHSTONE_BOUND" or event == "ZONE_CHANGED" or event == "ZONE_CHANGED_NEW_AREA" or event == "ZONE_CHANGED_INDOORS" or event == "GET_ITEM_INFO_RECEIVED" then
		if ZipTrixDB and ZipTrixDB["teleportsWorldMapEnabled"] and not f._refreshTimer then 
            f._refreshTimer = C_Timer.After(0.1, function() f._refreshTimer = nil; f:RefreshPanel() end)
        end
	end
end

function ns.InitWorldMapTeleportPanel()
	if not ZipTrixDB then return end

	f:SetScript("OnEvent", worldMapEventHandler)
	f:RegisterEvent("ADDON_LOADED")
	f:RegisterEvent("PLAYER_REGEN_DISABLED")
	f:RegisterEvent("PLAYER_REGEN_ENABLED")
	f:RegisterEvent("SPELLS_CHANGED")
	f:RegisterEvent("BAG_UPDATE_DELAYED")
	f:RegisterEvent("TOYS_UPDATED")
	f:RegisterEvent("SPELL_UPDATE_COOLDOWN")
	f:RegisterEvent("BAG_UPDATE_COOLDOWN")
	f:RegisterEvent("HEARTHSTONE_BOUND")
	f:RegisterEvent("ZONE_CHANGED")
	f:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	f:RegisterEvent("ZONE_CHANGED_INDOORS")
	f:RegisterEvent("GET_ITEM_INFO_RECEIVED")

	-- make sure we also initialize when the WorldMap opens
	if WorldMapFrame and not WorldMapFrame._zipTeleportHook then
		WorldMapFrame:HookScript("OnShow", function()
			if ZipTrixDB and ZipTrixDB["teleportsWorldMapEnabled"] then
				f:TryInit()
				if QuestMapFrame and QuestMapFrame.ValidateTabs then QuestMapFrame:ValidateTabs() end
				if f._selectOnNextShow and QuestMapFrame and QuestMapFrame.SetDisplayMode then
					QuestMapFrame:SetDisplayMode(DISPLAY_MODE)
					f._selectOnNextShow = nil
				end
				if not f._refreshTimer then
                    f._refreshTimer = C_Timer.After(0.1, function() f._refreshTimer = nil; f:RefreshPanel() end)
                end
			else
				if panel then SafeSetVisible(panel, false) end
				if tabButton then SafeSetVisible(tabButton, false) end
			end
		end)
		WorldMapFrame._zipTeleportHook = true
	end
end

-- Export a small helper so options code can trigger a live refresh
function ns.RefreshWorldMapTeleportPanel()
	if not ZipTrixDB then return end

	-- Proactively load the World Map addon so our hooks exist
	if not WorldMapFrame then pcall(UIParentLoadAddOn, "Blizzard_WorldMap") end

	if WorldMapFrame then
		-- Ensure our OnShow hook is installed even if we missed initial load timing
		if not WorldMapFrame._zipTeleportHook then
			WorldMapFrame:HookScript("OnShow", function()
				if ZipTrixDB and ZipTrixDB["teleportsWorldMapEnabled"] then
					f:TryInit()
					if QuestMapFrame and QuestMapFrame.ValidateTabs then QuestMapFrame:ValidateTabs() end
					if f._selectOnNextShow and QuestMapFrame and QuestMapFrame.SetDisplayMode then
						QuestMapFrame:SetDisplayMode(DISPLAY_MODE)
						f._selectOnNextShow = nil
					end
				if not f._refreshTimer then
                    f._refreshTimer = C_Timer.After(0.1, function() f._refreshTimer = nil; f:RefreshPanel() end)
                end
				else
					if panel then SafeSetVisible(panel, false) end
					if tabButton then SafeSetVisible(tabButton, false) end
				end
			end)
			WorldMapFrame._zipTeleportHook = true
		end

		-- Always ensure our UI is injected and tabs validated, even if hidden
		f:TryInit()
		if QuestMapFrame and QuestMapFrame.ValidateTabs then QuestMapFrame:ValidateTabs() end

		if not ZipTrixDB["teleportsWorldMapEnabled"] then
			if QuestMapFrame and QuestMapFrame.GetDisplayMode and QuestMapFrame:GetDisplayMode() == DISPLAY_MODE then
				if QuestMapFrame.MapLegendTab and QuestMapFrame.MapLegendTab.Click then
					QuestMapFrame.MapLegendTab:Click()
				elseif QuestMapFrame.QuestsTab and QuestMapFrame.QuestsTab.Click then
					QuestMapFrame.QuestsTab:Click()
				end
			end
			if panel then SafeSetVisible(panel, false) end
			if tabButton then SafeSetVisible(tabButton, false) end
			return
		end

		if WorldMapFrame:IsShown() then
			if tabButton then SafeSetVisible(tabButton, true) end
			if QuestMapFrame and QuestMapFrame.SetDisplayMode then QuestMapFrame:SetDisplayMode(DISPLAY_MODE) end
			f:RefreshPanel()
		else
			f._selectOnNextShow = true
		end
	end
end

function ns.OpenWorldMapTeleportPanel(force)
	if not ZipTrixDB or not ZipTrixDB["teleportsWorldMapEnabled"] then return end
	if not force and InCombatLockdown and InCombatLockdown() then
		f._pendingOpen = true
		return
	end

	if not WorldMapFrame then pcall(UIParentLoadAddOn, "Blizzard_WorldMap") end
	if f and f.TryInit then f:TryInit() end

	if not WorldMapFrame then return end

	if not WorldMapFrame:IsShown() then
		if ToggleMap then
			ToggleMap()
		else
			ShowUIPanel(WorldMapFrame)
		end
	end

	if QuestMapFrame and QuestMapFrame.SetDisplayMode then
		QuestMapFrame:SetDisplayMode(DISPLAY_MODE)
	elseif f then
		f._selectOnNextShow = true
	end

	if QuestMapFrame and QuestMapFrame.ValidateTabs then QuestMapFrame:ValidateTabs() end
	if f and f.RefreshPanel then f:RefreshPanel() end
end
