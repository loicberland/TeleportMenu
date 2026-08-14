-- Integration facultative a FuBar/Ace2.
-- Si FuBar n'est pas installe, ce fichier ne fait simplement rien.

if not AceLibrary or not AceLibrary.HasInstance then return end
if not AceLibrary:HasInstance("AceAddon-2.0") then return end
if not AceLibrary:HasInstance("FuBarPlugin-2.0") then return end

TeleportMenuFuBar = AceLibrary("AceAddon-2.0"):new("FuBarPlugin-2.0")

local plugin = TeleportMenuFuBar
plugin.name = "TeleportMenu"
plugin.title = "Téléportation GM"
plugin.hasIcon = true
plugin.hasText = true
plugin.defaultPosition = "RIGHT"
plugin.cannotDetachTooltip = true

function plugin:OnInitialize()
	self:SetIcon("Interface\\Icons\\Spell_Arcane_TeleportStormWind")
end

function plugin:OnTextUpdate()
	self:SetText("TP")
end

function plugin:OnClick()
	TeleportMenu_Toggle()
end

function plugin:OnTooltipUpdate()
	if not self.tooltip then return end
	local category = self.tooltip:AddCategory("columns", 1)
	category:AddLine("text", "Clic : ouvrir ou fermer")
end

