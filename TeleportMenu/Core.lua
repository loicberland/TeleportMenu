-- TeleportMenu
-- Interface de teleportation GM compatible WoW 1.12, 2.4.3 et 3.3.5.
-- Le code evite volontairement les API d'interface ajoutees apres Vanilla.

TeleportMenu = TeleportMenu or {}
TeleportMenuDB = TeleportMenuDB or {}

local addon = TeleportMenu
local db = TeleportMenuDB
local data = TeleportMenuData or {}

local clientVersion = "1.12"
if GetBuildInfo then
	clientVersion = GetBuildInfo() or clientVersion
end

if string.find(clientVersion, "^1%.") then
	addon.clientLevel = 1
elseif string.find(clientVersion, "^2%.") then
	addon.clientLevel = 2
else
	addon.clientLevel = 3
end

local REGION_LABELS = {
	all = "Toutes les régions",
	eastern = "Royaumes de l'Est",
	kalimdor = "Kalimdor",
	outland = "Outreterre",
	northrend = "Norfendre",
}

local TYPE_LABELS = {
	all = "Tous",
	fly = "Fly (taxinode)",
	city = "Ville (.tele)",
}

local FACTION_LABELS = {
	all = "Toutes",
	player = "Ma faction",
	Alliance = "Alliance",
	Horde = "Horde",
	Commun = "Commun",
}

local TYPE_CHOICES = {
	{ value = "all", label = "Tous" },
	{ value = "fly", label = "Fly (taxinode)" },
	{ value = "city", label = "Ville (.tele)" },
}

local FACTION_CHOICES = {
	{ value = "all", label = "Toutes" },
	{ value = "player", label = "Ma faction" },
	{ value = "Alliance", label = "Alliance" },
	{ value = "Horde", label = "Horde" },
	{ value = "Commun", label = "Commun uniquement" },
}

local REGION_CHOICES = {
	{ value = "all", label = "Toutes les régions" },
	{ value = "eastern", label = "Royaumes de l'Est" },
	{ value = "kalimdor", label = "Kalimdor" },
}

if addon.clientLevel >= 2 then
	table.insert(REGION_CHOICES, { value = "outland", label = "Outreterre" })
end
if addon.clientLevel >= 3 then
	table.insert(REGION_CHOICES, { value = "northrend", label = "Norfendre" })
end

if not TYPE_LABELS[db.typeFilter] then db.typeFilter = "all" end
if not REGION_LABELS[db.regionFilter] then db.regionFilter = "all" end
if addon.clientLevel < 2 and db.regionFilter == "outland" then db.regionFilter = "all" end
if addon.clientLevel < 3 and db.regionFilter == "northrend" then db.regionFilter = "all" end
if not FACTION_LABELS[db.factionFilter] then db.factionFilter = "all" end
if db.resultsOpen == nil then db.resultsOpen = true end
if db.minimapAngle == nil then db.minimapAngle = 225 end

local state = {
	filtered = {},
	offset = 0,
	rowCount = 11,
	selected = nil,
	suspendInput = false,
	resultsOpen = db.resultsOpen,
	activeMenu = nil,
	updatingSlider = false,
}

local frame
local resultsPanel
local searchEdit
local typeButton
local regionButton
local factionButton
local listToggleButton
local scrollSlider
local resultCountText
local statusText
local rows = {}

local function Trim(value)
	value = value or ""
	value = string.gsub(value, "^%s+", "")
	value = string.gsub(value, "%s+$", "")
	return value
end

local accentReplacements = {
	{ "À", "a" }, { "Á", "a" }, { "Â", "a" }, { "Ã", "a" }, { "Ä", "a" }, { "Å", "a" },
	{ "à", "a" }, { "á", "a" }, { "â", "a" }, { "ã", "a" }, { "ä", "a" }, { "å", "a" },
	{ "Ç", "c" }, { "ç", "c" },
	{ "È", "e" }, { "É", "e" }, { "Ê", "e" }, { "Ë", "e" },
	{ "è", "e" }, { "é", "e" }, { "ê", "e" }, { "ë", "e" },
	{ "Ì", "i" }, { "Í", "i" }, { "Î", "i" }, { "Ï", "i" },
	{ "ì", "i" }, { "í", "i" }, { "î", "i" }, { "ï", "i" },
	{ "Ñ", "n" }, { "ñ", "n" },
	{ "Ò", "o" }, { "Ó", "o" }, { "Ô", "o" }, { "Õ", "o" }, { "Ö", "o" },
	{ "ò", "o" }, { "ó", "o" }, { "ô", "o" }, { "õ", "o" }, { "ö", "o" },
	{ "Ù", "u" }, { "Ú", "u" }, { "Û", "u" }, { "Ü", "u" },
	{ "ù", "u" }, { "ú", "u" }, { "û", "u" }, { "ü", "u" },
	{ "Ý", "y" }, { "Ÿ", "y" }, { "ý", "y" }, { "ÿ", "y" },
	{ "Œ", "oe" }, { "œ", "oe" },
}

local function Normalize(value)
	value = value or ""
	local i
	for i = 1, table.getn(accentReplacements) do
		value = string.gsub(value, accentReplacements[i][1], accentReplacements[i][2])
	end
	value = string.lower(value)
	value = string.gsub(value, "[%p%s]+", " ")
	return Trim(value)
end

local function CurrentPlayerFaction()
	if UnitFactionGroup then
		local faction = UnitFactionGroup("player")
		if faction == "Alliance" or faction == "Horde" then
			return faction
		end
	end
	return nil
end

local function EntryAvailable(entry)
	return (entry.minVersion or 1) <= addon.clientLevel
end

local function EntryMatchesFaction(entry)
	local filter = db.factionFilter
	if filter == "all" then
		return true
	elseif filter == "Commun" then
		return entry.faction == "Commun"
	elseif filter == "player" then
		local playerFaction = CurrentPlayerFaction()
		return entry.faction == "Commun" or entry.faction == playerFaction
	else
		return entry.faction == "Commun" or entry.faction == filter
	end
end

local function EntrySearchText(entry)
	local value = entry.name .. " " .. (REGION_LABELS[entry.region] or "") .. " " .. (entry.faction or "")
	if entry.kind == "fly" then
		value = value .. " " .. tostring(entry.id)
	else
		value = value .. " " .. (entry.command or "")
	end
	return Normalize(value)
end

local function SameEntry(first, second)
	if not first or not second or first.kind ~= second.kind then return false end
	if first.kind == "fly" then return first.id == second.id end
	return first.command == second.command
end

local function SaveSelected(entry)
	state.selected = entry
	if entry then
		db.selectedKind = entry.kind
		db.selectedName = entry.name
		db.selectedID = entry.id
		db.selectedCommand = entry.command
	else
		db.selectedKind = nil
		db.selectedName = nil
		db.selectedID = nil
		db.selectedCommand = nil
	end
end

local function RestoreSelected()
	if not db.selectedKind then return end
	local i, entry
	for i = 1, table.getn(data) do
		entry = data[i]
		if EntryAvailable(entry) and entry.kind == db.selectedKind then
			if (entry.kind == "fly" and entry.id == db.selectedID)
				or (entry.kind == "city" and entry.command == db.selectedCommand) then
				state.selected = entry
				return
			end
		end
	end
	SaveSelected(nil)
end

local function SetStatus(message, red, green, blue)
	if not statusText then return end
	statusText:SetText(message or "")
	statusText:SetTextColor(red or 0.75, green or 0.75, blue or 0.75)
end

local function FormatEntry(entry)
	local prefix
	if entry.kind == "fly" then
		prefix = "|cff58a6ff[Fly " .. tostring(entry.id) .. "]|r"
	else
		prefix = "|cffc084fc[Ville]|r"
	end
	return prefix .. "  " .. entry.name .. "  |cff8f9bb3— " .. (REGION_LABELS[entry.region] or "") .. " · " .. (entry.faction or "") .. "|r"
end

local function UpdateRows()
	if not resultsPanel then return end
	local count = table.getn(state.filtered)
	local maxOffset = count - state.rowCount
	if maxOffset < 0 then maxOffset = 0 end
	if state.offset > maxOffset then state.offset = maxOffset end
	if state.offset < 0 then state.offset = 0 end

	local i, index, row, entry
	for i = 1, state.rowCount do
		row = rows[i]
		index = state.offset + i
		entry = state.filtered[index]
		if entry then
			row.entry = entry
			row.text:SetText(FormatEntry(entry))
			if SameEntry(state.selected, entry) then
				row:LockHighlight()
			else
				row:UnlockHighlight()
			end
			row:Show()
		else
			row.entry = nil
			row:UnlockHighlight()
			row:Hide()
		end
	end

	if resultCountText then
		resultCountText:SetText(tostring(count) .. " destination" .. (count == 1 and "" or "s"))
	end

	if scrollSlider then
		state.updatingSlider = true
		scrollSlider:SetMinMaxValues(0, maxOffset)
		scrollSlider:SetValue(state.offset)
		state.updatingSlider = false
		if maxOffset > 0 then scrollSlider:Show() else scrollSlider:Hide() end
	end
end

local function RebuildFiltered()
	state.filtered = {}
	local query = ""
	if searchEdit then query = Normalize(searchEdit:GetText()) end
	local i, entry, matches
	for i = 1, table.getn(data) do
		entry = data[i]
		matches = EntryAvailable(entry)
		if matches and db.typeFilter ~= "all" then matches = entry.kind == db.typeFilter end
		if matches and db.regionFilter ~= "all" then matches = entry.region == db.regionFilter end
		if matches then matches = EntryMatchesFaction(entry) end
		if matches and query ~= "" then
			matches = string.find(EntrySearchText(entry), query, 1, true) ~= nil
		end
		if matches then table.insert(state.filtered, entry) end
	end

	table.sort(state.filtered, function(first, second)
		local firstName = Normalize(first.name)
		local secondName = Normalize(second.name)
		if firstName == secondName then
			if first.kind ~= second.kind then return first.kind == "city" end
			if first.kind == "fly" then return first.id < second.id end
			return (first.command or "") < (second.command or "")
		end
		return firstName < secondName
	end)
	state.offset = 0
	UpdateRows()
end

local function CloseActiveMenu()
	if state.activeMenu then
		state.activeMenu:Hide()
		state.activeMenu = nil
	end
end

local function RefreshFilterButtons()
	if typeButton then typeButton:SetText(TYPE_LABELS[db.typeFilter] .. "  ▼") end
	if regionButton then regionButton:SetText(REGION_LABELS[db.regionFilter] .. "  ▼") end
	if factionButton then factionButton:SetText(FACTION_LABELS[db.factionFilter] .. "  ▼") end
end

local function SetResultsOpen(open)
	state.resultsOpen = open and true or false
	db.resultsOpen = state.resultsOpen
	if not frame or not resultsPanel then return end
	if state.resultsOpen then
		frame:SetHeight(510)
		resultsPanel:Show()
		listToggleButton:SetText("▲")
	else
		frame:SetHeight(220)
		resultsPanel:Hide()
		listToggleButton:SetText("▼")
	end
end

local function SelectEntry(entry)
	if not entry then return end
	SaveSelected(entry)
	state.suspendInput = true
	searchEdit:SetText(entry.name)
	state.suspendInput = false
	db.query = entry.name
	UpdateRows()
	if entry.kind == "fly" then
		SetStatus("Sélection : .go taxinode " .. tostring(entry.id), 0.45, 0.78, 1)
	else
		SetStatus("Sélection : .tele " .. entry.command, 0.78, 0.60, 1)
	end
end

local function BuildCommand()
	local raw = Trim(searchEdit and searchEdit:GetText() or "")
	if raw == "" then
		return nil, "Renseigne un fly ou une ville."
	end

	if state.selected and raw == state.selected.name then
		if state.selected.kind == "fly" then
			return ".go taxinode " .. tostring(state.selected.id)
		end
		return ".tele " .. state.selected.command
	end

	local lowerRaw = string.lower(raw)
	if string.find(lowerRaw, "^%.tele%s+") then
		return raw
	end
	if string.find(lowerRaw, "^%.go%s+taxinode%s+") then
		return raw
	end
	if string.sub(raw, 1, 1) == "." then
		return nil, "Seules les commandes .tele et .go taxinode sont acceptées."
	end

	if db.typeFilter == "fly" then
		local id = tonumber(raw)
		if not id then return nil, "Pour un fly personnalisé, saisis un ID numérique." end
		return ".go taxinode " .. tostring(math.floor(id))
	elseif db.typeFilter == "city" then
		return ".tele " .. raw
	end

	local inferredID = tonumber(raw)
	if inferredID then
		return ".go taxinode " .. tostring(math.floor(inferredID))
	end
	return ".tele " .. raw
end

function TeleportMenu_Execute()
	local command, errorMessage = BuildCommand()
	if not command then
		SetStatus(errorMessage, 1, 0.35, 0.35)
		return
	end

	local success = true
	if SendChatMessage then
		success = pcall(SendChatMessage, command, "SAY")
	else
		success = false
	end

	if success then
		db.query = searchEdit:GetText()
		SetStatus("Commande envoyée : " .. command, 0.35, 1, 0.45)
	else
		SetStatus("Impossible d'envoyer la commande au serveur.", 1, 0.35, 0.35)
	end
end

local function SaveFramePosition()
	if not frame then return end
	local left = frame:GetLeft()
	local top = frame:GetTop()
	if left and top then
		db.left = left
		db.top = top
	end
end

local function CreateChoiceMenu(name, anchor, width, choices, callback)
	local menu = CreateFrame("Frame", name, frame)
	menu:SetWidth(width)
	menu:SetHeight(table.getn(choices) * 24 + 10)
	menu:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, -2)
	menu:SetFrameStrata("TOOLTIP")
	if menu.SetToplevel then menu:SetToplevel(true) end
	menu:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	menu:Hide()

	local i, choice, button, label
	for i = 1, table.getn(choices) do
		choice = choices[i]
		button = CreateFrame("Button", nil, menu)
		button:SetID(i)
		button:SetHeight(23)
		button:SetPoint("TOPLEFT", menu, "TOPLEFT", 5, -5 - ((i - 1) * 24))
		button:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -5, -5 - ((i - 1) * 24))
		button:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		label = button:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
		label:SetPoint("LEFT", button, "LEFT", 8, 0)
		label:SetPoint("RIGHT", button, "RIGHT", -5, 0)
		label:SetJustifyH("LEFT")
		label:SetText(choice.label)
		button:SetScript("OnClick", function(self)
			self = self or this
			local selectedChoice = choices[self:GetID()]
			callback(selectedChoice.value)
			CloseActiveMenu()
		end)
	end
	return menu
end

local function ToggleChoiceMenu(menu)
	if state.activeMenu == menu and menu:IsShown() then
		CloseActiveMenu()
		return
	end
	CloseActiveMenu()
	state.activeMenu = menu
	menu:Show()
end

local function CreateMainFrame()
	frame = CreateFrame("Frame", "TeleportMenuFrame", UIParent)
	frame:SetWidth(560)
	frame:SetHeight(510)
	frame:SetFrameStrata("FULLSCREEN_DIALOG")
	if frame.SetToplevel then frame:SetToplevel(true) end
	if frame.SetClampedToScreen then frame:SetClampedToScreen(true) end
	frame:SetMovable(true)
	frame:EnableMouse(true)
	frame:RegisterForDrag("LeftButton")
	frame:SetBackdrop({
		bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 32, edgeSize = 32,
		insets = { left = 10, right = 10, top = 10, bottom = 10 },
	})

	if db.left and db.top then
		frame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", db.left, db.top)
	else
		frame:SetPoint("TOP", UIParent, "TOP", 0, -100)
	end

	frame:SetScript("OnDragStart", function(self)
		self = self or this
		CloseActiveMenu()
		self:StartMoving()
	end)
	frame:SetScript("OnDragStop", function(self)
		self = self or this
		self:StopMovingOrSizing()
		SaveFramePosition()
	end)
	frame:SetScript("OnMouseDown", function(self)
		self = self or this
		if self.Raise then self:Raise() end
	end)
	frame:SetScript("OnShow", function(self)
		self = self or this
		if self.Raise then self:Raise() end
		RefreshFilterButtons()
		RebuildFiltered()
	end)
	frame:SetScript("OnHide", function()
		CloseActiveMenu()
		if searchEdit then db.query = searchEdit:GetText() end
		SaveFramePosition()
	end)

	local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("TOP", frame, "TOP", 0, -17)
	title:SetText("Téléportation GM")

	local versionText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	versionText:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -20)
	versionText:SetText("WoW " .. clientVersion)
	versionText:SetTextColor(0.55, 0.62, 0.72)

	local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -4, -4)
	closeButton:SetScript("OnClick", function() frame:Hide() end)

	local typeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	typeLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -50)
	typeLabel:SetText("Type")

	local regionLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	regionLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 169, -50)
	regionLabel:SetText("Région")

	local factionLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	factionLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 369, -50)
	factionLabel:SetText("Faction")

	typeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	typeButton:SetWidth(140)
	typeButton:SetHeight(24)
	typeButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -65)

	regionButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	regionButton:SetWidth(193)
	regionButton:SetHeight(24)
	regionButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 165, -65)

	factionButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	factionButton:SetWidth(176)
	factionButton:SetHeight(24)
	factionButton:SetPoint("TOPLEFT", frame, "TOPLEFT", 365, -65)

	local destinationLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	destinationLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -105)
	destinationLabel:SetText("Fly ou ville")

	searchEdit = CreateFrame("EditBox", "TeleportMenuSearchEdit", frame, "InputBoxTemplate")
	searchEdit:SetWidth(487)
	searchEdit:SetHeight(28)
	searchEdit:SetPoint("TOPLEFT", frame, "TOPLEFT", 22, -120)
	searchEdit:SetAutoFocus(false)
	searchEdit:SetMaxLetters(100)
	if searchEdit.SetTextInsets then searchEdit:SetTextInsets(7, 7, 0, 0) end
	searchEdit:SetScript("OnTextChanged", function(self)
		self = self or this
		if state.suspendInput then return end
		local value = self:GetText() or ""
		db.query = value
		if state.selected and value ~= state.selected.name then SaveSelected(nil) end
		RebuildFiltered()
		if not state.resultsOpen then SetResultsOpen(true) end
	end)
	searchEdit:SetScript("OnEscapePressed", function(self)
		self = self or this
		self:ClearFocus()
	end)
	searchEdit:SetScript("OnEnterPressed", function(self)
		self = self or this
		self:ClearFocus()
		TeleportMenu_Execute()
	end)
	searchEdit:SetScript("OnEditFocusGained", function()
		if not state.resultsOpen then SetResultsOpen(true) end
	end)

	listToggleButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	listToggleButton:SetWidth(28)
	listToggleButton:SetHeight(24)
	listToggleButton:SetPoint("LEFT", searchEdit, "RIGHT", 3, 0)
	listToggleButton:SetScript("OnClick", function()
		SetResultsOpen(not state.resultsOpen)
	end)

	resultsPanel = CreateFrame("Frame", nil, frame)
	resultsPanel:SetPoint("TOPLEFT", frame, "TOPLEFT", 18, -157)
	resultsPanel:SetWidth(523)
	resultsPanel:SetHeight(286)
	resultsPanel:SetBackdrop({
		bgFile = "Interface\\Buttons\\WHITE8X8",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = false, edgeSize = 14,
		insets = { left = 4, right = 4, top = 4, bottom = 4 },
	})
	resultsPanel:SetBackdropColor(0.025, 0.035, 0.055, 0.94)

	resultCountText = resultsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	resultCountText:SetPoint("TOPLEFT", resultsPanel, "TOPLEFT", 10, -8)
	resultCountText:SetTextColor(0.6, 0.68, 0.78)

	local hintText = resultsPanel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	hintText:SetPoint("TOPRIGHT", resultsPanel, "TOPRIGHT", -27, -8)
	hintText:SetText("Clique pour sélectionner")
	hintText:SetTextColor(0.5, 0.57, 0.66)

	local i, row
	for i = 1, state.rowCount do
		row = CreateFrame("Button", nil, resultsPanel)
		row:SetHeight(22)
		row:SetPoint("TOPLEFT", resultsPanel, "TOPLEFT", 7, -27 - ((i - 1) * 22))
		row:SetPoint("TOPRIGHT", resultsPanel, "TOPRIGHT", -24, -27 - ((i - 1) * 22))
		row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		row.text = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		row.text:SetPoint("LEFT", row, "LEFT", 5, 0)
		row.text:SetPoint("RIGHT", row, "RIGHT", -3, 0)
		row.text:SetJustifyH("LEFT")
		row:SetScript("OnClick", function(self)
			self = self or this
			SelectEntry(self.entry)
		end)
		row:SetScript("OnEnter", function(self)
			self = self or this
			if not self.entry then return end
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(self.entry.name, 1, 0.82, 0)
			if self.entry.kind == "fly" then
				GameTooltip:AddLine("Commande : .go taxinode " .. tostring(self.entry.id), 0.45, 0.78, 1)
			else
				GameTooltip:AddLine("Commande : .tele " .. self.entry.command, 0.78, 0.60, 1)
			end
			GameTooltip:AddLine((REGION_LABELS[self.entry.region] or "") .. " · " .. (self.entry.faction or ""), 0.75, 0.75, 0.75)
			GameTooltip:Show()
		end)
		row:SetScript("OnLeave", function() GameTooltip:Hide() end)
		rows[i] = row
	end

	scrollSlider = CreateFrame("Slider", nil, resultsPanel)
	scrollSlider:SetOrientation("VERTICAL")
	scrollSlider:SetWidth(16)
	scrollSlider:SetHeight(240)
	scrollSlider:SetPoint("TOPRIGHT", resultsPanel, "TOPRIGHT", -6, -30)
	scrollSlider:SetMinMaxValues(0, 0)
	scrollSlider:SetValueStep(1)
	scrollSlider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob")
	scrollSlider:SetBackdrop({
		bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
		edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
		tile = true, tileSize = 8, edgeSize = 8,
		insets = { left = 3, right = 3, top = 6, bottom = 6 },
	})
	scrollSlider:SetScript("OnValueChanged", function(self, value)
		if state.updatingSlider then return end
		value = value or arg1 or 0
		state.offset = math.floor(value + 0.5)
		UpdateRows()
	end)

	if resultsPanel.EnableMouseWheel then
		resultsPanel:EnableMouseWheel(true)
		resultsPanel:SetScript("OnMouseWheel", function(self, delta)
			delta = delta or arg1 or 0
			local newValue = state.offset - delta * 3
			local count = table.getn(state.filtered)
			local maxOffset = count - state.rowCount
			if maxOffset < 0 then maxOffset = 0 end
			if newValue < 0 then newValue = 0 end
			if newValue > maxOffset then newValue = maxOffset end
			scrollSlider:SetValue(newValue)
		end)
	end

	local executeButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
	executeButton:SetWidth(220)
	executeButton:SetHeight(28)
	executeButton:SetPoint("BOTTOM", frame, "BOTTOM", 0, 35)
	executeButton:SetText("Me téléporter")
	executeButton:SetScript("OnClick", TeleportMenu_Execute)

	statusText = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	statusText:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 18, 13)
	statusText:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -18, 13)
	statusText:SetJustifyH("CENTER")
	statusText:SetText("Sélectionne une destination ou saisis-en une manuellement.")
	statusText:SetTextColor(0.65, 0.70, 0.78)

	local typeMenu = CreateChoiceMenu("TeleportMenuTypeMenu", typeButton, 160, TYPE_CHOICES, function(value)
		db.typeFilter = value
		RefreshFilterButtons()
		RebuildFiltered()
	end)
	local regionMenu = CreateChoiceMenu("TeleportMenuRegionMenu", regionButton, 220, REGION_CHOICES, function(value)
		db.regionFilter = value
		RefreshFilterButtons()
		RebuildFiltered()
	end)
	local factionMenu = CreateChoiceMenu("TeleportMenuFactionMenu", factionButton, 185, FACTION_CHOICES, function(value)
		db.factionFilter = value
		RefreshFilterButtons()
		RebuildFiltered()
	end)

	typeButton:SetScript("OnClick", function() ToggleChoiceMenu(typeMenu) end)
	regionButton:SetScript("OnClick", function() ToggleChoiceMenu(regionMenu) end)
	factionButton:SetScript("OnClick", function() ToggleChoiceMenu(factionMenu) end)

	RestoreSelected()
	state.suspendInput = true
	if db.query and db.query ~= "" then
		searchEdit:SetText(db.query)
	elseif state.selected then
		searchEdit:SetText(state.selected.name)
	else
		searchEdit:SetText("")
	end
	state.suspendInput = false
	RefreshFilterButtons()
	SetResultsOpen(state.resultsOpen)
	RebuildFiltered()
	frame:Hide()

	if UISpecialFrames then table.insert(UISpecialFrames, "TeleportMenuFrame") end
end

local function SafeAtan2(y, x)
	if x > 0 then
		return math.atan(y / x)
	elseif x < 0 and y >= 0 then
		return math.atan(y / x) + math.pi
	elseif x < 0 and y < 0 then
		return math.atan(y / x) - math.pi
	elseif x == 0 and y > 0 then
		return math.pi / 2
	elseif x == 0 and y < 0 then
		return -math.pi / 2
	end
	return 0
end

local minimapButton
local minimapDragging = false
local minimapIgnoreClick = false

local function PlaceMinimapButton()
	if not minimapButton or not Minimap then return end
	local radians = math.rad(db.minimapAngle or 225)
	local radius = 80
	minimapButton:ClearAllPoints()
	minimapButton:SetPoint("CENTER", Minimap, "CENTER", math.cos(radians) * radius, math.sin(radians) * radius)
end

local function UpdateMinimapDrag()
	if not minimapDragging or not Minimap then return end
	local cursorX, cursorY = GetCursorPosition()
	local scale = UIParent:GetScale() or 1
	if scale == 0 then scale = 1 end
	cursorX = cursorX / scale
	cursorY = cursorY / scale
	local centerX, centerY = Minimap:GetCenter()
	if not centerX or not centerY then return end
	db.minimapAngle = math.deg(SafeAtan2(cursorY - centerY, cursorX - centerX))
	PlaceMinimapButton()
end

local function CreateMinimapButton()
	if not Minimap then return end
	minimapButton = CreateFrame("Button", "TeleportMenuMinimapButton", Minimap)
	minimapButton:SetWidth(32)
	minimapButton:SetHeight(32)
	minimapButton:SetFrameStrata("MEDIUM")
	minimapButton:SetMovable(true)
	minimapButton:RegisterForDrag("LeftButton")
	minimapButton:RegisterForClicks("LeftButtonUp", "RightButtonUp")

	local icon = minimapButton:CreateTexture(nil, "BACKGROUND")
	icon:SetWidth(20)
	icon:SetHeight(20)
	icon:SetPoint("CENTER", minimapButton, "CENTER", 0, 0)
	icon:SetTexture("Interface\\Icons\\Spell_Arcane_TeleportStormWind")
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	local border = minimapButton:CreateTexture(nil, "OVERLAY")
	border:SetWidth(52)
	border:SetHeight(52)
	-- Cette texture Blizzard contient deja sa marge interne. Elle doit etre
	-- ancree directement sur le bouton, sans decalage supplementaire.
	border:SetPoint("TOPLEFT", minimapButton, "TOPLEFT", 0, 0)
	border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")

	minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
	minimapButton:SetScript("OnClick", function()
		if minimapDragging or minimapIgnoreClick then
			minimapIgnoreClick = false
			return
		end
		TeleportMenu_Toggle()
	end)
	minimapButton:SetScript("OnDragStart", function(self)
		self = self or this
		minimapDragging = true
		minimapIgnoreClick = true
		self:SetScript("OnUpdate", UpdateMinimapDrag)
	end)
	minimapButton:SetScript("OnDragStop", function(self)
		self = self or this
		self:SetScript("OnUpdate", nil)
		UpdateMinimapDrag()
		minimapDragging = false
	end)
	minimapButton:SetScript("OnEnter", function(self)
		self = self or this
		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:SetText("Téléportation GM", 1, 0.82, 0)
		GameTooltip:AddLine("Clic : ouvrir ou fermer", 1, 1, 1)
		GameTooltip:AddLine("Glisser : déplacer le bouton", 0.75, 0.75, 0.75)
		GameTooltip:Show()
	end)
	minimapButton:SetScript("OnLeave", function() GameTooltip:Hide() end)
	PlaceMinimapButton()
end

function TeleportMenu_Toggle()
	if not frame then CreateMainFrame() end
	if frame:IsShown() then
		frame:Hide()
	else
		frame:Show()
		if frame.Raise then frame:Raise() end
	end
end

function TeleportMenu_Show()
	if not frame then CreateMainFrame() end
	frame:Show()
	if frame.Raise then frame:Raise() end
end

function TeleportMenu_GetFuBarTooltip(tooltip)
	if not tooltip then return end
	tooltip:AddLine("Téléportation GM")
	tooltip:AddLine("Clic : ouvrir ou fermer", 1, 1, 1)
end

BINDING_HEADER_TELEPORTMENU = "Téléportation GM"
BINDING_NAME_TELEPORTMENU_TOGGLE = "Ouvrir/fermer l'interface"

SLASH_TELEPORTMENU1 = "/tpui"
SLASH_TELEPORTMENU2 = "/teleportmenu"
SlashCmdList["TELEPORTMENU"] = function(message)
	message = Trim(message or "")
	if message == "" then
		TeleportMenu_Toggle()
		return
	end
	TeleportMenu_Show()
	SaveSelected(nil)
	state.suspendInput = true
	searchEdit:SetText(message)
	state.suspendInput = false
	db.query = message
	RebuildFiltered()
end

CreateMainFrame()
CreateMinimapButton()
