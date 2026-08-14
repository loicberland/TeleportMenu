-- Donnees partagees par les clients 1.12, 2.4.3 et 3.3.5.
-- Les noms sont affiches en francais. Les valeurs "command" des villes
-- restent les cles anglaises utilisees par la table game_tele du serveur.

TeleportMenuData = TeleportMenuData or {}

local data = TeleportMenuData

local function AddFly(minVersion, region, faction, id, name)
	table.insert(data, {
		kind = "fly",
		minVersion = minVersion,
		region = region,
		faction = faction,
		id = id,
		name = name,
	})
end

local function AddCity(minVersion, region, faction, command, name)
	table.insert(data, {
		kind = "city",
		minVersion = minVersion,
		region = region,
		faction = faction,
		command = command,
		name = name,
	})
end

-- ---------------------------------------------------------------------------
-- Vanilla / Azeroth (1.12 et versions suivantes)
-- ---------------------------------------------------------------------------

-- Royaumes de l'Est - Alliance
AddFly(1, "eastern", "Alliance", 2, "Hurlevent")
AddFly(1, "eastern", "Alliance", 4, "Colline des Sentinelles, Marche de l'Ouest")
AddFly(1, "eastern", "Alliance", 5, "Comté-du-Lac, Les Carmines")
AddFly(1, "eastern", "Alliance", 6, "Forgefer, Dun Morogh")
AddFly(1, "eastern", "Alliance", 7, "Port de Menethil, Les Paluns")
AddFly(1, "eastern", "Alliance", 8, "Thelsamar, Loch Modan")
AddFly(1, "eastern", "Alliance", 12, "Sombre-comté, Bois de la Pénombre")
AddFly(1, "eastern", "Alliance", 14, "Austrivage, Contreforts de Hautebrande")
AddFly(1, "eastern", "Alliance", 16, "Refuge de l'Ornière, Hautes-terres d'Arathi")
AddFly(1, "eastern", "Alliance", 19, "Baie-du-Butin, Vallée de Strangleronce")
AddFly(1, "eastern", "Alliance", 43, "Nid-de-l'Aigle, Les Hinterlands")
AddFly(1, "eastern", "Alliance", 45, "Rempart-du-Néant, Terres foudroyées")
AddFly(1, "eastern", "Alliance", 66, "Camp du Noroît, Maleterres de l'Ouest")
AddFly(1, "eastern", "Alliance", 67, "Chapelle de l'Espoir de Lumière, Maleterres de l'Est")
AddFly(1, "eastern", "Alliance", 71, "Veille de Morgan, Steppes ardentes")
AddFly(1, "eastern", "Alliance", 74, "Halte du Thorium, Gorge des Vents brûlants")
AddFly(1, "eastern", "Alliance", 195, "Camp rebelle, Vallée de Strangleronce")

-- Royaumes de l'Est - Horde
AddFly(1, "eastern", "Horde", 10, "Le Sépulcre, Forêt des Pins-Argentés")
AddFly(1, "eastern", "Horde", 11, "Fossoyeuse")
AddFly(1, "eastern", "Horde", 13, "Moulin-de-Tarren, Contreforts de Hautebrande")
AddFly(1, "eastern", "Horde", 17, "Trépas-d'Orgrim, Hautes-terres d'Arathi")
AddFly(1, "eastern", "Horde", 18, "Baie-du-Butin, Vallée de Strangleronce")
AddFly(1, "eastern", "Horde", 20, "Grom'gol, Vallée de Strangleronce")
AddFly(1, "eastern", "Horde", 21, "Kargath, Terres ingrates")
AddFly(1, "eastern", "Horde", 56, "Pierrêche, Marais des Chagrins")
AddFly(1, "eastern", "Horde", 68, "Chapelle de l'Espoir de Lumière, Maleterres de l'Est")
AddFly(1, "eastern", "Horde", 70, "Corniche des Flammes, Steppes ardentes")
AddFly(1, "eastern", "Horde", 75, "Halte du Thorium, Gorge des Vents brûlants")
AddFly(1, "eastern", "Horde", 76, "Village des Vengebroches, Les Hinterlands")

-- Kalimdor - Commun
AddFly(1, "kalimdor", "Commun", 79, "Refuge des Marshal, Cratère d'Un'Goro")
AddFly(1, "kalimdor", "Commun", 80, "Cabestan, Les Tarides")
AddFly(1, "kalimdor", "Commun", 166, "Sanctuaire d'Émeraude, Gangrebois")
AddFly(1, "kalimdor", "Commun", 179, "Bourbe-à-brac, Marécage d'Âprefange")

-- Kalimdor - Alliance
AddFly(1, "kalimdor", "Alliance", 26, "Auberdine, Sombrivage")
AddFly(1, "kalimdor", "Alliance", 27, "Village de Rut'theran, Teldrassil")
AddFly(1, "kalimdor", "Alliance", 28, "Astranaar, Orneval")
AddFly(1, "kalimdor", "Alliance", 31, "Thalanaar, Féralas")
AddFly(1, "kalimdor", "Alliance", 32, "Île de Theramore, Marécage d'Âprefange")
AddFly(1, "kalimdor", "Alliance", 33, "Pic des Serres-Rocheuses, Serres-Rocheuses")
AddFly(1, "kalimdor", "Alliance", 37, "Combe de Nijel, Désolace")
AddFly(1, "kalimdor", "Alliance", 39, "Gadgetzan, Tanaris")
AddFly(1, "kalimdor", "Alliance", 41, "Bastion de Pennelune, Féralas")
AddFly(1, "kalimdor", "Alliance", 49, "Reflet-de-Lune")
AddFly(1, "kalimdor", "Alliance", 52, "Long-guet, Berceau-de-l'Hiver")
AddFly(1, "kalimdor", "Alliance", 62, "Havrenuit, Reflet-de-Lune")
AddFly(1, "kalimdor", "Alliance", 64, "Halte de Talrendis, Azshara")
AddFly(1, "kalimdor", "Alliance", 65, "Clairière de Griffebranche, Gangrebois")
AddFly(1, "kalimdor", "Alliance", 73, "Fort cénarien, Silithus")
AddFly(1, "kalimdor", "Alliance", 93, "Guet du Sang, Île de Brume-Sang")
AddFly(1, "kalimdor", "Alliance", 94, "L'Exodar")
AddFly(1, "kalimdor", "Alliance", 167, "Chant des forêts, Orneval")

-- Kalimdor - Horde
AddFly(1, "kalimdor", "Horde", 22, "Les Pitons-du-Tonnerre")
AddFly(1, "kalimdor", "Horde", 23, "Orgrimmar")
AddFly(1, "kalimdor", "Horde", 25, "La Croisée, Les Tarides")
AddFly(1, "kalimdor", "Horde", 29, "Retraite de Roche-Soleil, Serres-Rocheuses")
AddFly(1, "kalimdor", "Horde", 30, "Poste de Librevent, Mille pointes")
AddFly(1, "kalimdor", "Horde", 38, "Proie-de-l'Ombre, Désolace")
AddFly(1, "kalimdor", "Horde", 40, "Gadgetzan, Tanaris")
AddFly(1, "kalimdor", "Horde", 42, "Camp Mojache, Féralas")
AddFly(1, "kalimdor", "Horde", 44, "Valormok, Azshara")
AddFly(1, "kalimdor", "Horde", 48, "Poste de la Vénéneuse, Gangrebois")
AddFly(1, "kalimdor", "Horde", 53, "Long-guet, Berceau-de-l'Hiver")
AddFly(1, "kalimdor", "Horde", 55, "Mur-de-Fougères, Marécage d'Âprefange")
AddFly(1, "kalimdor", "Horde", 58, "Avant-poste de Zoram'gar, Orneval")
AddFly(1, "kalimdor", "Horde", 61, "Poste de Bois-brisé, Orneval")
AddFly(1, "kalimdor", "Horde", 63, "Havrenuit, Reflet-de-Lune")
AddFly(1, "kalimdor", "Horde", 69, "Reflet-de-Lune")
AddFly(1, "kalimdor", "Horde", 72, "Fort cénarien, Silithus")
AddFly(1, "kalimdor", "Horde", 77, "Camp Taurajo, Les Tarides")

-- ---------------------------------------------------------------------------
-- The Burning Crusade (2.4.3 et 3.3.5)
-- ---------------------------------------------------------------------------

-- Nouveaux trajets dans les Royaumes de l'Est
AddFly(2, "eastern", "Commun", 205, "Collines de la Cognée, Terres fantômes")
AddFly(2, "eastern", "Commun", 383, "Rivière Thondroril, Maleterres de l'Ouest")
AddFly(2, "eastern", "Horde", 82, "Lune-d'Argent")
AddFly(2, "eastern", "Horde", 83, "Tranquillien, Terres fantômes")
AddFly(2, "eastern", "Horde", 384, "La Barricade, Clairières de Tirisfal")

-- Outreterre - Commun
AddFly(2, "outland", "Commun", 122, "Zone 52, Raz-de-Néant")
AddFly(2, "outland", "Commun", 128, "Shattrath")
AddFly(2, "outland", "Commun", 139, "Foudreflèche, Raz-de-Néant")
AddFly(2, "outland", "Commun", 140, "Autel de Sha'tar, Vallée d'Ombrelune")
AddFly(2, "outland", "Commun", 150, "Cosmovrille, Raz-de-Néant")
AddFly(2, "outland", "Commun", 159, "Sanctum des étoiles, Vallée d'Ombrelune")
AddFly(2, "outland", "Commun", 160, "Bosquet éternel, Les Tranchantes")
AddFly(2, "outland", "Commun", 213, "Port des Confins du soleil, Île de Quel'Danas")

-- Outreterre - Alliance
AddFly(2, "outland", "Alliance", 100, "Bastion de l'Honneur, Péninsule des Flammes infernales")
AddFly(2, "outland", "Alliance", 101, "Temple de Telhamat, Péninsule des Flammes infernales")
AddFly(2, "outland", "Alliance", 117, "Telredor, Marécage de Zangar")
AddFly(2, "outland", "Alliance", 119, "Telaar, Nagrand")
AddFly(2, "outland", "Alliance", 124, "Bastion des Marteaux-Hardis, Vallée d'Ombrelune")
AddFly(2, "outland", "Alliance", 125, "Sylvanaar, Les Tranchantes")
AddFly(2, "outland", "Alliance", 129, "La Porte des ténèbres, Péninsule des Flammes infernales")
AddFly(2, "outland", "Alliance", 149, "Halte du Fracas, Péninsule des Flammes infernales")
AddFly(2, "outland", "Alliance", 156, "Poste de Toshley, Les Tranchantes")
AddFly(2, "outland", "Alliance", 164, "Havre d'Orebor, Marécage de Zangar")

-- Outreterre - Horde
AddFly(2, "outland", "Horde", 99, "Thrallmar, Péninsule des Flammes infernales")
AddFly(2, "outland", "Horde", 102, "Guet de l'Épervier, Péninsule des Flammes infernales")
AddFly(2, "outland", "Horde", 118, "Zabra'jin, Marécage de Zangar")
AddFly(2, "outland", "Horde", 120, "Garadar, Nagrand")
AddFly(2, "outland", "Horde", 123, "Village d'Ombrelune, Vallée d'Ombrelune")
AddFly(2, "outland", "Horde", 126, "Bastion des Sire-tonnerre, Les Tranchantes")
AddFly(2, "outland", "Horde", 127, "Fort des Brise-Pierres, Forêt de Terokkar")
AddFly(2, "outland", "Horde", 130, "La Porte des ténèbres, Péninsule des Flammes infernales")
AddFly(2, "outland", "Horde", 141, "Crête Brise-échine, Péninsule des Flammes infernales")
AddFly(2, "outland", "Horde", 142, "Trépas du saccageur, Péninsule des Flammes infernales")
AddFly(2, "outland", "Horde", 151, "Poste du Rat des marais, Marécage de Zangar")
AddFly(2, "outland", "Horde", 163, "Mok'Nathal, Les Tranchantes")

-- ---------------------------------------------------------------------------
-- Wrath of the Lich King (3.3.5 uniquement)
-- ---------------------------------------------------------------------------

-- Norfendre - Commun
AddFly(3, "northrend", "Commun", 226, "Bouclier Transitus, Frimarra")
AddFly(3, "northrend", "Commun", 252, "Temple du Repos du ver, Désolation des dragons")
AddFly(3, "northrend", "Commun", 289, "Escarpement d'Ambre, Toundra Boréenne")
AddFly(3, "northrend", "Commun", 294, "Moa'ki, Désolation des dragons")
AddFly(3, "northrend", "Commun", 295, "Kamagua, Fjord Hurlant")
AddFly(3, "northrend", "Commun", 296, "Unu'pe, Toundra Boréenne")
AddFly(3, "northrend", "Commun", 304, "Séjour d'Argent, Zul'Drak")
AddFly(3, "northrend", "Commun", 305, "Guet d'Ébène, Zul'Drak")
AddFly(3, "northrend", "Commun", 306, "La Brèche de Lumière, Zul'Drak")
AddFly(3, "northrend", "Commun", 307, "Zim'Torga, Zul'Drak")
AddFly(3, "northrend", "Commun", 308, "Le Cœur du fleuve, Bassin de Sholazar")
AddFly(3, "northrend", "Commun", 309, "Camp de base de Nesingwary, Bassin de Sholazar")
AddFly(3, "northrend", "Commun", 310, "Dalaran")
AddFly(3, "northrend", "Commun", 320, "K3, Les pics Foudroyés")
AddFly(3, "northrend", "Commun", 325, "Cime de la Mort, La Couronne de glace")
AddFly(3, "northrend", "Commun", 326, "Ulduar, Les pics Foudroyés")
AddFly(3, "northrend", "Commun", 327, "Refuge de Rochecombe, Les pics Foudroyés")
AddFly(3, "northrend", "Commun", 331, "Dubra'Jin, Zul'Drak")
AddFly(3, "northrend", "Commun", 334, "L'avant-garde d'Argent, La Couronne de glace")
AddFly(3, "northrend", "Commun", 340, "Enceinte du tournoi d'Argent, La Couronne de glace")

-- Norfendre - Alliance
AddFly(3, "northrend", "Alliance", 183, "Port-Valgarde, Fjord Hurlant")
AddFly(3, "northrend", "Alliance", 184, "Fort Hardivar, Fjord Hurlant")
AddFly(3, "northrend", "Alliance", 185, "Donjon de la Garde de l'Ouest, Fjord Hurlant")
AddFly(3, "northrend", "Alliance", 244, "Donjon de Garde-hiver, Désolation des dragons")
AddFly(3, "northrend", "Alliance", 245, "Donjon de la Bravoure, Toundra Boréenne")
AddFly(3, "northrend", "Alliance", 246, "Piste d'atterrissage de Spumelevier, Toundra Boréenne")
AddFly(3, "northrend", "Alliance", 247, "Repos des étoiles, Désolation des dragons")
AddFly(3, "northrend", "Alliance", 251, "Bastion Fordragon, Désolation des dragons")
AddFly(3, "northrend", "Alliance", 253, "Gîte Ambrepin, Les Grisonnes")
AddFly(3, "northrend", "Alliance", 255, "Brigade de la Marche de l'Ouest, Les Grisonnes")
AddFly(3, "northrend", "Alliance", 321, "Fort du Givre, Les pics Foudroyés")
AddFly(3, "northrend", "Alliance", 336, "Surplomb de Coursevent, Forêt du Chant de cristal")

-- Norfendre - Horde
AddFly(3, "northrend", "Horde", 190, "Nouvelle-Agamand, Fjord Hurlant")
AddFly(3, "northrend", "Horde", 191, "Accostage de la Vengeance, Fjord Hurlant")
AddFly(3, "northrend", "Horde", 192, "Camp Sabot-d'Hiver, Fjord Hurlant")
AddFly(3, "northrend", "Horde", 248, "Camp des Apothicaires, Fjord Hurlant")
AddFly(3, "northrend", "Horde", 249, "Camp Oneqwah, Les Grisonnes")
AddFly(3, "northrend", "Horde", 250, "Bastion de la Conquête, Les Grisonnes")
AddFly(3, "northrend", "Horde", 254, "Vexevenin, Désolation des dragons")
AddFly(3, "northrend", "Horde", 256, "Marteau d'Agmar, Désolation des dragons")
AddFly(3, "northrend", "Horde", 257, "Bastion Chanteguerre, Toundra Boréenne")
AddFly(3, "northrend", "Horde", 258, "Taunka'le, Toundra Boréenne")
AddFly(3, "northrend", "Horde", 259, "Avant-poste Bor'gorok, Toundra Boréenne")
AddFly(3, "northrend", "Horde", 260, "Avant-garde kor'kron, Désolation des dragons")
AddFly(3, "northrend", "Horde", 323, "Site d'accident de Grom'arsh, Les pics Foudroyés")
AddFly(3, "northrend", "Horde", 324, "Camp Tunka'lo, Les pics Foudroyés")
AddFly(3, "northrend", "Horde", 337, "Quartier général de Saccage-soleil, Forêt du Chant de cristal")

-- ---------------------------------------------------------------------------
-- Destinations .tele connues et couramment presentes dans game_tele.
-- Une base personnalisee peut utiliser d'autres cles : la saisie libre reste
-- disponible dans l'interface.
-- ---------------------------------------------------------------------------

AddCity(1, "eastern", "Alliance", "Stormwind", "Hurlevent")
AddCity(1, "eastern", "Alliance", "Ironforge", "Forgefer")
AddCity(1, "kalimdor", "Alliance", "Darnassus", "Darnassus")
AddCity(1, "kalimdor", "Horde", "Orgrimmar", "Orgrimmar")
AddCity(1, "kalimdor", "Horde", "ThunderBluff", "Les Pitons-du-Tonnerre")
AddCity(1, "eastern", "Horde", "Undercity", "Fossoyeuse")
AddCity(1, "eastern", "Commun", "BootyBay", "Baie-du-Butin")
AddCity(1, "kalimdor", "Commun", "Ratchet", "Cabestan")
AddCity(1, "kalimdor", "Commun", "Gadgetzan", "Gadgetzan")
AddCity(1, "kalimdor", "Commun", "Everlook", "Long-guet")
AddCity(1, "kalimdor", "Commun", "Moonglade", "Reflet-de-Lune")
AddCity(2, "kalimdor", "Alliance", "Exodar", "L'Exodar")
AddCity(2, "eastern", "Horde", "Silvermoon", "Lune-d'Argent")
AddCity(2, "outland", "Commun", "Shattrath", "Shattrath")
AddCity(3, "northrend", "Commun", "Dalaran", "Dalaran")

