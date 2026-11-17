local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")

-- [[ ПРОВЕРКА ИГРЫ: ТОЛЬКО ДЛЯ RIVALS ]]
local function isRivalsGame()
	if game.GameId == 6035872082 or game.PlaceId == 17625359962 then
		return true
	end
	local ok, info = pcall(function()
		return MarketplaceService:GetProductInfo(game.PlaceId)
	end)
	if ok and info and type(info.Name) == "string" and string.find(string.upper(info.Name), "RIVALS", 1, true) then
		return true
	end
	return false
end

if not isRivalsGame() then
	warn("[SNOW HUB] Скрипт предназначен только для игры RIVALS!")
	pcall(function()
		game:GetService("StarterGui"):SetCore("SendNotification", {
			Title = "SNOW HUB",
			Text = "Этот скрипт работает только в RIVALS!",
			Duration = 6
		})
	end)
	return
end

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

while not workspace.CurrentCamera do
	task.wait()
end
local camera = workspace.CurrentCamera

-- [[ ИКОНКИ И КАРТИНКИ ROBLOX (ASSET IDS) ]]
local ASSETS = {
	Snowflake = "rbxassetid://6031302931",
	Aim = "rbxassetid://6031280882",
	ESP = "rbxassetid://6031075931",
	Movement = "rbxassetid://6034754445",
	Themes = "rbxassetid://6031265976",
	Settings = "rbxassetid://6031280882",
	Home = "rbxassetid://6026568198",
	Search = "rbxassetid://6031154871",
	Glow = "rbxassetid://5028857084",
}

local CONFIG = {
	Title = "SNOW HUB",
	Subtitle = "Rivals Edition",
	Logo = "❄",
	Author = "by " .. player.Name,
	Version = "v8.0",
	ToggleKey = Enum.KeyCode.G,
	Theme = "Frostbite",
	AutoThemeDelay = 6,
	Width = 760,
	Height = 500,
	Transparency = 0.10,
	ScreenMargin = 16,
	Blur = true,
	BlurSize = 10,
	AnimatedBorder = true,
	Snowfall = true,
}

local THEMES = {
	{
		Name = "Frostbite",
		Accent = Color3.fromRGB(92, 225, 255),
		Accent2 = Color3.fromRGB(210, 248, 255),
		Window = Color3.fromRGB(13, 19, 29),
		Card = Color3.fromRGB(20, 29, 44),
		Field = Color3.fromRGB(27, 39, 58),
		TrackOff = Color3.fromRGB(45, 63, 90),
		IconTint = Color3.fromRGB(145, 205, 240),
	},
	{
		Name = "New Year",
		Accent = Color3.fromRGB(255, 75, 85),
		Accent2 = Color3.fromRGB(255, 215, 100),
		Window = Color3.fromRGB(18, 15, 24),
		Card = Color3.fromRGB(28, 23, 36),
		Field = Color3.fromRGB(38, 31, 49),
		TrackOff = Color3.fromRGB(70, 50, 68),
		IconTint = Color3.fromRGB(245, 185, 130),
	},
	{
		Name = "Pine Tree",
		Accent = Color3.fromRGB(72, 235, 155),
		Accent2 = Color3.fromRGB(190, 255, 140),
		Window = Color3.fromRGB(12, 22, 18),
		Card = Color3.fromRGB(19, 34, 28),
		Field = Color3.fromRGB(26, 46, 38),
		TrackOff = Color3.fromRGB(44, 76, 62),
		IconTint = Color3.fromRGB(130, 220, 175),
	},
	{
		Name = "Aurora",
		Accent = Color3.fromRGB(165, 105, 255),
		Accent2 = Color3.fromRGB(80, 245, 215),
		Window = Color3.fromRGB(15, 14, 28),
		Card = Color3.fromRGB(25, 23, 45),
		Field = Color3.fromRGB(34, 32, 60),
		TrackOff = Color3.fromRGB(58, 52, 96),
		IconTint = Color3.fromRGB(180, 160, 245),
	},
	{
		Name = "Candy Cane",
		Accent = Color3.fromRGB(255, 105, 155),
		Accent2 = Color3.fromRGB(255, 230, 240),
		Window = Color3.fromRGB(24, 14, 20),
		Card = Color3.fromRGB(38, 22, 32),
		Field = Color3.fromRGB(50, 29, 42),
		TrackOff = Color3.fromRGB(86, 46, 68),
		IconTint = Color3.fromRGB(245, 165, 195),
	},
	{
		Name = "Midnight",
		Accent = Color3.fromRGB(110, 145, 255),
		Accent2 = Color3.fromRGB(175, 225, 255),
		Window = Color3.fromRGB(12, 14, 22),
		Card = Color3.fromRGB(20, 23, 36),
		Field = Color3.fromRGB(28, 32, 50),
		TrackOff = Color3.fromRGB(48, 55, 86),
		IconTint = Color3.fromRGB(150, 175, 235),
	},
}

local COMMON = {
	Text = Color3.fromRGB(244, 248, 255),
	SubText = Color3.fromRGB(158, 172, 192),
	TabText = Color3.fromRGB(205, 218, 235),
	White = Color3.new(1, 1, 1),
	Black = Color3.new(0, 0, 0),
	Green = Color3.fromRGB(70, 235, 135),
	Close = Color3.fromRGB(240, 75, 75),
}

local THEME = {}
local currentTheme = THEMES[1]

local function loadTheme(name)
	for _, theme in ipairs(THEMES) do
		if theme.Name == name then
			currentTheme = theme
		end
	end
	for key, value in pairs(COMMON) do
		THEME[key] = value
	end
	for key, value in pairs(currentTheme) do
		THEME[key] = value
	end
end
loadTheme(CONFIG.Theme)

local FONT_BOLD = Enum.Font.GothamBold
local FONT_MEDIUM = Enum.Font.GothamMedium
local FONT_REGULAR = Enum.Font.Gotham

local state = {
	onClose = {},
	connections = {},
	notificationsEnabled = true,
	autoThemeEnabled = false,
}

local function trackConn(conn)
	if conn then
		table.insert(state.connections, conn)
	end
	return conn
end

local LANGUAGES = {
	{ "en", "English" },
	{ "ru", "Русский" },
	{ "gd", "Gàidhlig" },
	{ "fr", "Français" },
}

local TEXTS = {
	["Search..."] = { ru = "Поиск...", gd = "Lorg...", fr = "Rechercher..." },
	["Today!"] = { ru = "Сегодня!", gd = "An-diugh!", fr = "Aujourd'hui !" },
	["%d days"] = { ru = "%d дн.", gd = "%d latha", fr = "%d jours" },
	["Press a key..."] = { ru = "Нажми клавишу...", gd = "Brùth iuchair...", fr = "Appuie sur une touche..." },
	["Hello, %s!"] = { ru = "С Новым годом, %s!", gd = "Bliadhna Mhath Ùr, %s!", fr = "Bonne année, %s !" },
	["Home"] = { ru = "Главная", gd = "Dachaigh", fr = "Accueil" },
	["Welcome!"] = { ru = "Новогоднее издание Snow Hub", gd = "Fàilte gu Snow Hub!", fr = "Édition du Nouvel An" },
	["until New Year"] = { ru = "до Нового года", gd = "gus a' Bhliadhna Ùr", fr = "avant le Nouvel An" },
	["toggle menu"] = { ru = "клавиша меню", gd = "clàr-taice", fr = "touche menu" },
	["Active theme"] = { ru = "активная тема", gd = "ùrlar", fr = "thème actif" },
	["Quick start"] = { ru = "Быстрый старт", gd = "Tòiseachadh luath", fr = "Démarrage rapide" },
	["How to use"] = { ru = "Управление", gd = "Smachdan", fr = "Commandes" },
	["Aim"] = { ru = "Аим", gd = "Amas", fr = "Visée" },
	["Aim assist and auto-shoot"] = { ru = "Наводка, автострел и нож", gd = "Taic amais is fèin-losgadh", fr = "Aide à la visée et tir auto" },
	["Main"] = { ru = "Основное", gd = "Prìomh", fr = "Principal" },
	["Camera Mode"] = { ru = "Режим камеры", gd = "Modh a' chamara", fr = "Mode caméra" },
	["Aim At"] = { ru = "Часть тела", gd = "Amais air", fr = "Partie visée" },
	["Head"] = { ru = "Голова", gd = "Ceann", fr = "Tête" },
	["Body"] = { ru = "Торс", gd = "Bodhaig", fr = "Torse" },
	["Center"] = { ru = "Центр", gd = "Meadhan", fr = "Centre" },
	["Head Only"] = { ru = "Только голова", gd = "An ceann a-mhàin", fr = "Tête uniquement" },
	["Hold Right Mouse"] = { ru = "Аим по зажатию ПКМ", gd = "Cùm am putan deas", fr = "Maintenir clic droit" },
	["Right Mouse Through Walls"] = { ru = "ПКМ сквозь стены", gd = "Putan deas tro bhallachan", fr = "Clic droit à travers murs" },
	["Aim Speed"] = { ru = "Скорость наводки", gd = "Luaths amais", fr = "Vitesse de visée" },
	["Speed"] = { ru = "Плавность / Скорость", gd = "Luaths", fr = "Vitesse" },
	["Instant Aim"] = { ru = "Мгновенная наводка", gd = "Amas sa bhad", fr = "Visée instantanée" },
	["Lock"] = { ru = "Захват и камера", gd = "Glasadh", fr = "Verrouillage" },
	["Aim Height"] = { ru = "Высота точки головы", gd = "Àirde an amais", fr = "Hauteur de visée" },
	["FOV Radius"] = { ru = "Радиус круга FOV", gd = "Rèideas FOV", fr = "Rayon du FOV" },
	["Prediction"] = { ru = "Упреждение (Предикт)", gd = "Ro-innse", fr = "Anticipation" },
	["Keep Target"] = { ru = "Удерживать цель", gd = "Cùm an targaid", fr = "Garder la cible" },
	["Hold Mouse On Target"] = { ru = "Фиксировать мышь", gd = "Reòth an luchag", fr = "Bloquer la souris" },
	["Turn Body To Target"] = { ru = "Поворот тела (Телефон)", gd = "Tionndaidh am bodhaig", fr = "Tourner le corps" },
	["Keep After Cover"] = { ru = "Держать за укрытием", gd = "Cùm às dèidh fasgaidh", fr = "Garder après abri" },
	["Auto-Shoot"] = { ru = "Автострел", gd = "Fèin-losgadh", fr = "Tir auto" },
	["Phone"] = { ru = "Телефон", gd = "Fòn", fr = "Téléphone" },
	["Everywhere"] = { ru = "Везде", gd = "Anns gach àite", fr = "Partout" },
	["Off"] = { ru = "Выкл", gd = "Dheth", fr = "Désactivé" },
	["Accuracy"] = { ru = "Угол срабатывания", gd = "Cruinneas", fr = "Précision" },
	["Pause Between Shots"] = { ru = "Задержка выстрела", gd = "Stad eadar losgaidhean", fr = "Pause entre tirs" },
	["PC: Auto-Shoot Key"] = { ru = "ПК: Бинд автострела", gd = "PC: Iuchair fèin-losgaidh", fr = "PC : Touche tir auto" },
	["Movement & Evasion"] = { ru = "Движение и уклонение", gd = "Gluasad", fr = "Mouvement" },
	["BunnyHop"] = { ru = "BunnyHop (Авто-прыжки)", gd = "BunnyHop", fr = "BunnyHop" },
	["Crouch Spam"] = { ru = "Crouch Spam (Присед в бою)", gd = "Crouch Spam", fr = "Crouch Spam" },
	["KnifeAuto (150 DMG)"] = { ru = "KnifeAuto (Нож 150 урона)", gd = "KnifeAuto", fr = "KnifeAuto (150 dégâts)" },
	["KnifeAuto Range"] = { ru = "Дальность удара ножом", gd = "Raon KnifeAuto", fr = "Portée du couteau" },
	["Checks"] = { ru = "Проверки и фильтры", gd = "Sgrùdaidhean", fr = "Vérifications" },
	["Team Check"] = { ru = "Не целиться в своих", gd = "Sgrùdadh sgioba", fr = "Ignorer alliés" },
	["Teams"] = { ru = "Режим команд", gd = "Sgiobaidhean", fr = "Mode équipes" },
	["Wall Check"] = { ru = "Проверка стен", gd = "Sgrùdadh bhallachan", fr = "Vérif. des murs" },
	["Target Bots"] = { ru = "Целиться в NPC/Ботов", gd = "Amais air botaichean", fr = "Viser les bots" },
	["No Camera Shake"] = { ru = "Убрать тряску камеры", gd = "Gun chrith camara", fr = "Sans tremblement" },
	["Show FOV Circle"] = { ru = "Показывать круг FOV", gd = "Seall cearcall FOV", fr = "Afficher cercle FOV" },
	["Show Target"] = { ru = "Плашка цели сверху", gd = "Seall an targaid", fr = "Afficher la cible" },
	["Reset Aim and ESP Settings"] = { ru = "Сбросить все настройки", gd = "Ath-shuidhich", fr = "Réinitialiser tout" },
	["See where players are"] = { ru = "Настройка подсветки, скинов и информации", gd = "Faic càite a bheil cluicheadairean", fr = "Voir les joueurs à travers les murs" },
	["Smart ESP Colors"] = { ru = "Умные цвета (За стеной светлее)", gd = "Dathan ESP snasail", fr = "Couleurs intelligentes" },
	["Show Weapon in ESP"] = { ru = "Показывать оружие в руках", gd = "Seall arm ann an ESP", fr = "Afficher l'arme" },
	["Highlight"] = { ru = "Контур и заливка (Скин видно)", gd = "Soillseachadh", fr = "Surbrillance" },
	["Names"] = { ru = "Ники игроков", gd = "Ainmean", fr = "Noms" },
	["Distance"] = { ru = "Дистанция в метрах", gd = "Astar", fr = "Distance" },
	["Health Bar"] = { ru = "Полоска здоровья (HP)", gd = "Bàr slàinte", fr = "Barre de vie" },
	["Tracers"] = { ru = "Линии до игроков (Tracers)", gd = "Loidhnichean", fr = "Traceurs" },
	["Show Teammates"] = { ru = "Показывать тиммейтов (Зелёным)", gd = "Seall do sgioba", fr = "Afficher alliés (Vert)" },
	["Max Distance"] = { ru = "Макс. дальность ESP", gd = "An t-astar as motha", fr = "Distance max" },
	["Themes"] = { ru = "Темы", gd = "Ùrlaran", fr = "Thèmes" },
	["Change the look of the menu"] = { ru = "Зимние и праздничные цветовые палитры", gd = "Atharraich coltas a' chlàir", fr = "Palettes de couleurs d'hiver" },
	["Choose a theme"] = { ru = "Выбери тему оформления", gd = "Tagh ùrlar", fr = "Choisis un thème" },
	["Auto Theme"] = { ru = "Автосмена темы", gd = "Ùrlar fèin-ghluasadach", fr = "Thème auto" },
	["Settings"] = { ru = "Настройки", gd = "Roghainnean", fr = "Paramètres" },
	["Menu look and keys"] = { ru = "Язык, снег, размытие и горячие клавиши", gd = "Cànan is iuchraichean", fr = "Langue, effets et touches" },
	["Language"] = { ru = "Язык интерфейса", gd = "Cànan", fr = "Langue" },
	["Blur"] = { ru = "Размытие фона", gd = "Sgleò", fr = "Flou d'arrière-plan" },
	["Blur Strength"] = { ru = "Сила размытия", gd = "Neart an sgleò", fr = "Intensité du flou" },
	["Window Transparency"] = { ru = "Прозрачность окна", gd = "Trìd-shoilleireachd", fr = "Transparence" },
	["Animated Border"] = { ru = "Переливающаяся рамка", gd = "Iomall beòthail", fr = "Bordure animée" },
	["Snowfall Effect"] = { ru = "Падающий снег в меню", gd = "Sneachda", fr = "Effet de neige" },
	["Show Quick Bar"] = { ru = "Показывать мини-панель (Quick Bar)", gd = "Seall Quick Bar", fr = "Afficher Quick Bar" },
	["Notifications"] = { ru = "Уведомления в углу", gd = "Brathan", fr = "Notifications" },
	["Show / Hide Menu"] = { ru = "Открыть / Спрятать меню", gd = "Seall / Falaich", fr = "Afficher / Cacher menu" },
	["Profile"] = { ru = "Профиль", gd = "Pròifil", fr = "Profil" },
	["Your account"] = { ru = "Статистика аккаунта и сессии", gd = "An cunntas agad", fr = "Ton compte" },
}

local DICT, REVERSE = {}, {}
for _, language in ipairs(LANGUAGES) do
	DICT[language[1]] = {}
	REVERSE[language[1]] = {}
end
for english, row in pairs(TEXTS) do
	for code, text in pairs(row) do
		DICT[code][english] = text
		if REVERSE[code][text] == nil then
			REVERSE[code][text] = english
		end
	end
end

local currentLanguage = "ru"
pcall(function()
	local locale = string.lower(game:GetService("LocalizationService").RobloxLocaleId)
	local code = string.sub(locale, 1, 2)
	if DICT[code] then
		currentLanguage = code
	end
end)

local function tr(text)
	return DICT[currentLanguage] and DICT[currentLanguage][text] or text
end

local function trf(template, ...)
	local ok, res = pcall(string.format, tr(template), ...)
	return ok and res or tr(template)
end

local textSources = setmetatable({}, { __mode = "k" })
local placeholderSources = setmetatable({}, { __mode = "k" })
local languageHooks = {}

local function watchText(instance)
	if instance:IsA("TextBox") then
		placeholderSources[instance] = instance.PlaceholderText
		instance.PlaceholderText = tr(instance.PlaceholderText)
		return
	end
	local function update()
		local text = instance.Text
		local source = (REVERSE[currentLanguage] and REVERSE[currentLanguage][text]) or text
		textSources[instance] = source
		local shown = tr(source)
		if shown ~= text then
			instance.Text = shown
		end
	end
	update()
	instance:GetPropertyChangedSignal("Text"):Connect(update)
end

local function onLanguage(hook)
	table.insert(languageHooks, hook)
	hook()
end

local function setLanguage(code)
	if not DICT[code] or code == currentLanguage then
		return false
	end
	currentLanguage = code
	for instance, source in pairs(textSources) do
		local shown = tr(source)
		if instance.Text ~= shown then
			instance.Text = shown
		end
	end
	for instance, source in pairs(placeholderSources) do
		instance.PlaceholderText = tr(source)
	end
	for _, hook in ipairs(languageHooks) do
		task.spawn(hook)
	end
	return true
end

local function create(className, props)
	local instance = Instance.new(className)
	if instance:IsA("GuiObject") then
		instance.BorderSizePixel = 0
	end
	local parent = props.Parent
	props.Parent = nil
	for key, value in pairs(props) do
		instance[key] = value
	end
	if className == "TextLabel" or className == "TextButton" or className == "TextBox" then
		watchText(instance)
	end
	instance.Parent = parent
	return instance
end

local function tween(object, duration, goal, style, direction)
	local info = TweenInfo.new(duration, style or Enum.EasingStyle.Quint, direction or Enum.EasingDirection.Out)
	local animation = TweenService:Create(object, info, goal)
	animation:Play()
	return animation
end

local function corner(parent, radius)
	return create("UICorner", { CornerRadius = UDim.new(0, radius or 8), Parent = parent })
end

local function round(parent)
	return create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = parent })
end

local function stroke(parent, transparency, thickness, color)
	return create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color or COMMON.White,
		Transparency = transparency or 0.88,
		Thickness = thickness or 1,
		Parent = parent,
	})
end

local function padding(parent, top, right, bottom, left)
	return create("UIPadding", {
		PaddingTop = UDim.new(0, top or 0),
		PaddingRight = UDim.new(0, right or 0),
		PaddingBottom = UDim.new(0, bottom or 0),
		PaddingLeft = UDim.new(0, left or 0),
		Parent = parent,
	})
end

local function label(props)
	props.BackgroundTransparency = 1
	props.Font = props.Font or FONT_MEDIUM
	props.TextSize = props.TextSize or 14
	props.TextColor3 = props.TextColor3 or COMMON.Text
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	return create("TextLabel", props)
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1
		or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement
		or input.UserInputType == Enum.UserInputType.Touch
end

local themeHooks = {}
local function onTheme(hook)
	table.insert(themeHooks, hook)
	hook(true)
end

local function setTheme(name)
	if currentTheme.Name == name then
		return false
	end
	loadTheme(name)
	CONFIG.Theme = name
	for _, hook in ipairs(themeHooks) do
		hook(false)
	end
	return true
end

local function paint(object, property, key)
	onTheme(function(instant)
		if instant then
			object[property] = THEME[key]
		else
			tween(object, 0.35, { [property] = THEME[key] })
		end
	end)
	return object
end

local spinningGradients = {}
local function accent(parent, rotation, spinning)
	local gradient = create("UIGradient", { Rotation = rotation or 0, Parent = parent })
	onTheme(function()
		gradient.Color = ColorSequence.new(THEME.Accent, THEME.Accent2)
	end)
	if spinning then
		table.insert(spinningGradients, gradient)
	end
	return gradient
end

local GUI_NAME = "SnowHub_Unique_v8"

local function getSafeGuiParent()
	local okHui, hui = pcall(function() return gethui and gethui() end)
	if okHui and hui then return hui end
	local okCg, cg = pcall(function() return game:GetService("CoreGui") end)
	if okCg and cg then return cg end
	return playerGui
end
local guiParent = getSafeGuiParent()

for _, oldName in ipairs({ GUI_NAME, "SnowHub_v7.1", "RivalsModded_Unique_v7", "AimHud", "AimESP" }) do
	local found = guiParent:FindFirstChild(oldName) or playerGui:FindFirstChild(oldName)
	if found then
		pcall(function() found:Destroy() end)
	end
	local oldBlur = Lighting:FindFirstChild(oldName .. "_Blur")
	if oldBlur then
		pcall(function() oldBlur:Destroy() end)
	end
end

local gui = create("ScreenGui", {
	Name = GUI_NAME,
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 10000,
	Parent = guiParent,
})
pcall(function()
	gui.ScreenInsets = Enum.ScreenInsets.None
end)

local blur = create("BlurEffect", { Name = GUI_NAME .. "_Blur", Size = 0, Parent = Lighting })
gui.Destroying:Connect(function()
	pcall(function() blur:Destroy() end)
	for _, conn in ipairs(state.connections) do
		pcall(function() conn:Disconnect() end)
	end
	for _, cleanup in ipairs(state.onClose) do
		pcall(cleanup)
	end
end)

-- [[ СИСТЕМА УВЕДОМЛЕНИЙ ]]
local toastHolder = create("Frame", {
	Name = "Notifications",
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, -20, 1, -20),
	Size = UDim2.new(0, 290, 1, -40),
	BackgroundTransparency = 1,
	ZIndex = 30,
	Parent = gui,
})
create("UIListLayout", {
	VerticalAlignment = Enum.VerticalAlignment.Bottom,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = toastHolder,
})

local toastCount = 0
local function notify(title, text, duration)
	if not state.notificationsEnabled then return end
	duration = duration or 3.5
	toastCount += 1

	local wrapper = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		LayoutOrder = toastCount,
		Parent = toastHolder,
	})
	local toast = create("TextButton", {
		Position = UDim2.fromOffset(320, 0),
		Size = UDim2.new(1, 0, 0, 64),
		BackgroundColor3 = THEME.Window,
		BackgroundTransparency = 0.05,
		AutoButtonColor = false,
		Text = "",
		Parent = wrapper,
	})
	corner(toast, 12)
	accent(stroke(toast, 0.25, 1.5), 45, false)

	label({
		Position = UDim2.fromOffset(14, 10),
		Size = UDim2.new(1, -28, 0, 18),
		Text = "❄ " .. tr(title),
		Font = FONT_BOLD,
		TextSize = 14,
		Parent = toast,
	})
	label({
		Position = UDim2.fromOffset(14, 30),
		Size = UDim2.new(1, -28, 0, 16),
		Text = tr(text),
		Font = FONT_REGULAR,
		TextSize = 12,
		TextColor3 = COMMON.SubText,
		Parent = toast,
	})

	tween(wrapper, 0.3, { Size = UDim2.new(1, 0, 0, 64) })
	tween(toast, 0.45, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)

	local closed = false
	local function close()
		if closed then return end
		closed = true
		local slide = tween(toast, 0.35, { Position = UDim2.fromOffset(320, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		slide.Completed:Connect(function()
			wrapper:Destroy()
		end)
	end
	toast.MouseButton1Click:Connect(close)
	task.delay(duration, close)
end

-- [[ ГЛАВНОЕ ОКНО SNOW HUB (В СТИЛЕ VENYX ИЗ СКРИНШОТА) ]]
local holder = create("Frame", {
	Name = "Holder",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(CONFIG.Width, CONFIG.Height),
	BackgroundTransparency = 1,
	Visible = false,
	Parent = gui,
})
local fitScale = create("UIScale", { Parent = holder })

local window = create("Frame", {
	Name = "Window",
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Parent = holder,
})
local popScale = create("UIScale", { Scale = 0, Parent = window })

local TOP = 54
local SIDEBAR_W = 62

local main = create("Frame", {
	Name = "Main",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = THEME.Window,
	BackgroundTransparency = CONFIG.Transparency,
	ClipsDescendants = true,
	Active = true,
	ZIndex = 2,
	Parent = window,
})
paint(main, "BackgroundColor3", "Window")
corner(main, 14)
accent(stroke(main, 0.15, 1.5), 45, true)

-- Фоновая водяная марка снежинки (ImageLabel)
local bgWatermark = create("ImageLabel", {
	AnchorPoint = Vector2.new(1, 1),
	Position = UDim2.new(1, 40, 1, 40),
	Size = UDim2.fromOffset(260, 260),
	BackgroundTransparency = 1,
	Image = ASSETS.Snowflake,
	ImageTransparency = 0.94,
	ZIndex = 2,
	Parent = main,
})
paint(bgWatermark, "ImageColor3", "Accent")

-- Анимация новогоднего снегопада на фоне меню
local snowLayer = create("Frame", {
	Name = "SnowLayer",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	ZIndex = 2,
	Parent = main,
})

local snowflakes = {}
for i = 1, 22 do
	local size = math.random(3, 7)
	local flake = create("Frame", {
		Position = UDim2.fromScale(math.random(), math.random()),
		Size = UDim2.fromOffset(size, size),
		BackgroundColor3 = COMMON.White,
		BackgroundTransparency = math.random(45, 78) / 100,
		Parent = snowLayer,
	})
	round(flake)
	table.insert(snowflakes, {
		Inst = flake,
		X = flake.Position.X.Scale,
		Y = flake.Position.Y.Scale,
		SpeedY = math.random(4, 10) / 100,
		Drift = math.random(15, 40) / 1000,
		Phase = math.random() * 6.28,
	})
end

state.freeMouse = create("TextButton", {
	Name = "FreeMouse",
	Modal = true,
	Visible = false,
	Size = UDim2.fromOffset(1, 1),
	BackgroundTransparency = 1,
	Text = "",
	AutoButtonColor = false,
	Parent = main,
})

-- [[ ВЕРХНЯЯ ПАНЕЛЬ (ШАПКА В СТИЛЕ VENYX: ЛОГО / СТАТУС / ПОИСК / СВЕРНУТЬ) ]]
local topBar = create("Frame", {
	Name = "TopBar",
	Size = UDim2.new(1, 0, 0, TOP),
	BackgroundTransparency = 1,
	ZIndex = 4,
	Parent = main,
})

local logoBadge = create("Frame", {
	Position = UDim2.fromOffset(14, 10),
	Size = UDim2.fromOffset(34, 34),
	BackgroundColor3 = THEME.Field,
	Parent = topBar,
})
paint(logoBadge, "BackgroundColor3", "Field")
corner(logoBadge, 10)
accent(stroke(logoBadge, 0.1, 1.5), 0, true)

local logoImg = create("ImageLabel", {
	AnchorPoint = Vector2.new(0.5, 0.5),
	Position = UDim2.fromScale(0.5, 0.5),
	Size = UDim2.fromOffset(20, 20),
	BackgroundTransparency = 1,
	Image = ASSETS.Snowflake,
	Parent = logoBadge,
})
paint(logoImg, "ImageColor3", "Accent")

local headerRow = create("Frame", {
	Position = UDim2.fromOffset(58, 0),
	Size = UDim2.new(0, 340, 1, 0),
	BackgroundTransparency = 1,
	Parent = topBar,
})
create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = headerRow,
})

label({
	Size = UDim2.fromOffset(0, 24),
	AutomaticSize = Enum.AutomaticSize.X,
	Text = CONFIG.Title,
	Font = FONT_BOLD,
	TextSize = 16,
	TextColor3 = COMMON.White,
	LayoutOrder = 1,
	Parent = headerRow,
})

label({
	Size = UDim2.fromOffset(0, 24),
	AutomaticSize = Enum.AutomaticSize.X,
	Text = "/  " .. CONFIG.Subtitle,
	Font = FONT_MEDIUM,
	TextSize = 13,
	TextColor3 = COMMON.SubText,
	LayoutOrder = 2,
	Parent = headerRow,
})

local verBadge = create("Frame", {
	Size = UDim2.fromOffset(0, 20),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundColor3 = THEME.Field,
	LayoutOrder = 3,
	Parent = headerRow,
})
paint(verBadge, "BackgroundColor3", "Field")
round(verBadge)
padding(verBadge, 0, 8, 0, 8)
label({
	Size = UDim2.fromScale(0, 1),
	AutomaticSize = Enum.AutomaticSize.X,
	Text = CONFIG.Version,
	Font = FONT_BOLD,
	TextSize = 11,
	TextColor3 = THEME.Accent,
	Parent = verBadge,
})

local statusPill = create("Frame", {
	Size = UDim2.fromOffset(0, 20),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundColor3 = THEME.Field,
	LayoutOrder = 4,
	Parent = headerRow,
})
paint(statusPill, "BackgroundColor3", "Field")
round(statusPill)
padding(statusPill, 0, 9, 0, 9)
local statusLabel = label({
	Size = UDim2.fromScale(0, 1),
	AutomaticSize = Enum.AutomaticSize.X,
	Text = "● Idle",
	Font = FONT_BOLD,
	TextSize = 11,
	TextColor3 = COMMON.Green,
	Parent = statusPill,
})

-- Поле поиска прямо в верхней шапке (как на скриншоте Venyx)
local searchFrame = create("Frame", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -92, 0.5, 0),
	Size = UDim2.fromOffset(175, 32),
	BackgroundColor3 = THEME.Field,
	BackgroundTransparency = 0.15,
	Parent = topBar,
})
paint(searchFrame, "BackgroundColor3", "Field")
corner(searchFrame, 9)
local searchStroke = stroke(searchFrame, 0.85, 1)

create("ImageLabel", {
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 9, 0.5, 0),
	Size = UDim2.fromOffset(14, 14),
	BackgroundTransparency = 1,
	Image = ASSETS.Search,
	ImageColor3 = COMMON.SubText,
	Parent = searchFrame,
})

local searchBox = create("TextBox", {
	Position = UDim2.fromOffset(28, 0),
	Size = UDim2.new(1, -52, 1, 0),
	BackgroundTransparency = 1,
	ClearTextOnFocus = false,
	Text = "",
	PlaceholderText = "Search...",
	PlaceholderColor3 = COMMON.SubText,
	TextColor3 = COMMON.Text,
	Font = FONT_MEDIUM,
	TextSize = 13,
	TextXAlignment = Enum.TextXAlignment.Left,
	Parent = searchFrame,
})

local clearButton = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -6, 0.5, 0),
	Size = UDim2.fromOffset(18, 18),
	BackgroundColor3 = COMMON.White,
	BackgroundTransparency = 0.88,
	AutoButtonColor = false,
	Text = "×",
	Font = FONT_BOLD,
	TextSize = 14,
	TextColor3 = COMMON.Text,
	Visible = false,
	Parent = searchFrame,
})
round(clearButton)

local hoveringWindowButton = false
local function topWindowBtn(symbol, offsetRight, isClose)
	local b = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, offsetRight, 0.5, 0),
		Size = UDim2.fromOffset(30, 30),
		BackgroundColor3 = isClose and COMMON.Close or THEME.Field,
		BackgroundTransparency = 0.25,
		AutoButtonColor = false,
		Text = symbol,
		Font = FONT_BOLD,
		TextSize = 15,
		TextColor3 = COMMON.Text,
		Parent = topBar,
	})
	if not isClose then
		paint(b, "BackgroundColor3", "Field")
	end
	corner(b, 8)
	b.MouseEnter:Connect(function()
		hoveringWindowButton = true
		tween(b, 0.2, { BackgroundTransparency = 0 })
	end)
	b.MouseLeave:Connect(function()
		hoveringWindowButton = false
		tween(b, 0.2, { BackgroundTransparency = 0.25 })
	end)
	return b
end

local closeButton = topWindowBtn("×", -14, true)
local minimizeButton = topWindowBtn("—", -50, false)

create("Frame", {
	Position = UDim2.new(0, 0, 0, TOP - 1),
	Size = UDim2.new(1, 0, 0, 1),
	BackgroundColor3 = COMMON.White,
	BackgroundTransparency = 0.9,
	ZIndex = 4,
	Parent = main,
})

-- [[ ОСНОВНОЙ КОНТЕЙНЕР: УЗКАЯ ПАНЕЛЬ ИКОНОК СЛЕВА + ДВУХКОЛОНОЧНЫЙ КОНТЕНТ ]]
local body = create("Frame", {
	Name = "Body",
	Position = UDim2.fromOffset(0, TOP),
	Size = UDim2.new(1, 0, 1, -TOP),
	BackgroundTransparency = 1,
	ZIndex = 3,
	Parent = main,
})

local sidebar = create("Frame", {
	Name = "Sidebar",
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.new(0, SIDEBAR_W, 1, 0),
	BackgroundColor3 = THEME.Card,
	BackgroundTransparency = 0.55,
	Parent = body,
})
paint(sidebar, "BackgroundColor3", "Card")

create("Frame", {
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.fromScale(1, 0),
	Size = UDim2.new(0, 1, 1, 0),
	BackgroundColor3 = COMMON.White,
	BackgroundTransparency = 0.9,
	Parent = sidebar,
})

local tabButtons = create("Frame", {
	Position = UDim2.fromOffset(0, 12),
	Size = UDim2.new(1, 0, 1, -76),
	BackgroundTransparency = 1,
	Parent = sidebar,
})
create("UIListLayout", {
	HorizontalAlignment = Enum.HorizontalAlignment.Center,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = tabButtons,
})

-- Круглая аватарка игрока в самом низу сайдбара (как в Venyx)
local profileQuickBtn = create("TextButton", {
	AnchorPoint = Vector2.new(0.5, 1),
	Position = UDim2.new(0.5, 0, 1, -12),
	Size = UDim2.fromOffset(38, 38),
	BackgroundColor3 = THEME.Field,
	AutoButtonColor = false,
	Text = "",
	Parent = sidebar,
})
paint(profileQuickBtn, "BackgroundColor3", "Field")
round(profileQuickBtn)
accent(stroke(profileQuickBtn, 0.1, 1.5), 0, true)

local miniAvatar = create("ImageLabel", {
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(player.UserId),
	Parent = profileQuickBtn,
})
round(miniAvatar)

local content = create("Frame", {
	Name = "Content",
	Position = UDim2.fromOffset(SIDEBAR_W + 14, 10),
	Size = UDim2.new(1, -SIDEBAR_W - 24, 1, -18),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	Parent = body,
})

local tabs = {}
local searchableCards = {}
local selectedTab = nil
local layoutOrder = 0
local function nextOrder()
	layoutOrder += 1
	return layoutOrder
end

local function refreshTabs(duration)
	for _, tab in ipairs(tabs) do
		local active = tab == selectedTab
		tween(tab.Button, duration, {
			BackgroundTransparency = active and 0.1 or 1,
			BackgroundColor3 = active and THEME.Field or THEME.Card,
		})
		tween(tab.Stroke, duration, { Transparency = active and 0.15 or 1 })
		tween(tab.Indicator, duration, { Size = active and UDim2.fromOffset(3, 20) or UDim2.fromOffset(3, 0) })
		if tab.Image then
			tween(tab.Image, duration, { ImageColor3 = active and THEME.Accent or COMMON.SubText })
		end
		tween(tab.Emoji, duration, { TextColor3 = active and THEME.Accent or COMMON.SubText })
	end
end
onTheme(function(instant)
	refreshTabs(instant and 0 or 0.3)
end)

local function selectTab(tab)
	if selectedTab == tab then return end
	selectedTab = tab
	for _, other in ipairs(tabs) do
		other.Page.Visible = (other == tab)
	end
	refreshTabs(0.25)
	tab.Page.CanvasPosition = Vector2.new(0, 0)
end

-- Создание вкладки с поддержкой двух колонок (LeftCol / RightCol)
local function createTab(name, iconEmoji, assetId, subtitle)
	local button = create("TextButton", {
		Name = name,
		Size = UDim2.fromOffset(42, 42),
		BackgroundColor3 = THEME.Field,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = nextOrder(),
		Parent = tabButtons,
	})
	corner(button, 11)
	local btnStroke = stroke(button, 1, 1.2, THEME.Accent)
	onTheme(function() btnStroke.Color = THEME.Accent end)

	local indicator = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, -6, 0.5, 0),
		Size = UDim2.fromOffset(3, 0),
		BackgroundColor3 = THEME.Accent,
		Parent = button,
	})
	paint(indicator, "BackgroundColor3", "Accent")
	round(indicator)

	local emojiLbl = label({
		Size = UDim2.fromScale(1, 1),
		Text = iconEmoji,
		Font = FONT_BOLD,
		TextSize = 18,
		TextColor3 = COMMON.SubText,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = button,
	})

	local page = create("ScrollingFrame", {
		Name = name,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = COMMON.SubText,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		Visible = false,
		Parent = content,
	})
	create("UIListLayout", { Padding = UDim.new(0, 10), SortOrder = Enum.SortOrder.LayoutOrder, Parent = page })
	padding(page, 2, 8, 14, 2)

	-- Шапка вкладки
	local header = create("Frame", {
		Size = UDim2.new(1, 0, 0, 44),
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
		Parent = page,
	})
	label({
		Size = UDim2.new(1, 0, 0, 24),
		Text = name,
		Font = FONT_BOLD,
		TextSize = 21,
		Parent = header,
	})
	label({
		Position = UDim2.fromOffset(0, 25),
		Size = UDim2.new(1, 0, 0, 16),
		Text = subtitle or "",
		Font = FONT_REGULAR,
		TextSize = 12,
		TextColor3 = COMMON.SubText,
		Parent = header,
	})

	-- Двухколоночная сетка в стиле Venyx
	local columnsFrame = create("Frame", {
		Name = "Columns",
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
		Parent = page,
	})

	local leftCol = create("Frame", {
		Name = "LeftColumn",
		Position = UDim2.fromScale(0, 0),
		Size = UDim2.new(0.5, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = columnsFrame,
	})
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = leftCol })

	local rightCol = create("Frame", {
		Name = "RightColumn",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0.5, -6, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		Parent = columnsFrame,
	})
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = rightCol })

	local tab = {
		Name = name,
		Button = button,
		Stroke = btnStroke,
		Indicator = indicator,
		Emoji = emojiLbl,
		Page = page,
		Left = leftCol,
		Right = rightCol,
	}
	table.insert(tabs, tab)

	button.MouseButton1Click:Connect(function()
		selectTab(tab)
	end)

	return page, tab, leftCol, rightCol
end

-- Групповой заголовок внутри колонки (как AUTO STEAL / FILTER на скрине)
local function section(parentCol, title)
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
		Parent = parentCol,
	})
	local dot = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 4, 0.5, 2),
		Size = UDim2.fromOffset(7, 7),
		BackgroundColor3 = THEME.Accent,
		Parent = row,
	})
	paint(dot, "BackgroundColor3", "Accent")
	round(dot)

	label({
		Position = UDim2.fromOffset(17, 4),
		Size = UDim2.new(1, -20, 0, 20),
		Text = title,
		Font = FONT_BOLD,
		TextSize = 13,
		TextColor3 = THEME.Accent2,
		Parent = row,
	})
	return row
end

local function card(parentCol, height, className, searchTag)
	local frame = create(className or "Frame", {
		Size = UDim2.new(1, 0, 0, height),
		BackgroundColor3 = THEME.Card,
		BackgroundTransparency = 0.2,
		LayoutOrder = nextOrder(),
		Parent = parentCol,
	})
	if className == "TextButton" then
		frame.AutoButtonColor = false
		frame.Text = ""
	end
	paint(frame, "BackgroundColor3", "Card")
	corner(frame, 10)
	local cardStroke = stroke(frame, 0.9, 1)
	frame.MouseEnter:Connect(function()
		tween(cardStroke, 0.2, { Transparency = 0.65, Color = THEME.Accent })
	end)
	frame.MouseLeave:Connect(function()
		tween(cardStroke, 0.2, { Transparency = 0.9, Color = COMMON.White })
	end)
	if searchTag then
		table.insert(searchableCards, { Frame = frame, Tag = searchTag })
	end
	return frame
end

local function paragraph(parentCol, title, text)
	local frame = card(parentCol, 0, "Frame", title)
	frame.AutomaticSize = Enum.AutomaticSize.Y
	padding(frame, 10, 12, 10, 12)
	create("UIListLayout", { Padding = UDim.new(0, 4), SortOrder = Enum.SortOrder.LayoutOrder, Parent = frame })
	label({
		Size = UDim2.new(1, 0, 0, 18),
		Text = title,
		Font = FONT_BOLD,
		TextSize = 13,
		LayoutOrder = 1,
		Parent = frame,
	})
	local textLabel = label({
		Size = UDim2.fromScale(1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = text,
		TextWrapped = true,
		Font = FONT_REGULAR,
		TextSize = 12,
		TextColor3 = COMMON.SubText,
		LayoutOrder = 2,
		Parent = frame,
	})
	return frame, textLabel
end

local function toggle(parentCol, icon, title, description, default, callback)
	local frame = card(parentCol, 52, "TextButton", title)

	label({
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -70, 0, 18),
		Text = title,
		Font = FONT_BOLD,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	})
	local descriptionLabel = label({
		Position = UDim2.fromOffset(12, 27),
		Size = UDim2.new(1, -70, 0, 15),
		Text = description or "",
		Font = FONT_REGULAR,
		TextSize = 11,
		TextColor3 = COMMON.SubText,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	})

	local track = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(42, 22),
		BackgroundColor3 = THEME.TrackOff,
		Parent = frame,
	})
	paint(track, "BackgroundColor3", "TrackOff")
	round(track)

	local fill = create("Frame", {
		Size = UDim2.fromScale(1, 1),
		BackgroundColor3 = COMMON.White,
		BackgroundTransparency = 1,
		Parent = track,
	})
	round(fill)
	accent(fill, 0, false)

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = COMMON.White,
		ZIndex = 2,
		Parent = track,
	})
	round(knob)

	local isOn = default == true
	local function render(duration)
		tween(fill, duration, { BackgroundTransparency = isOn and 0 or 1 })
		tween(knob, duration, {
			Position = isOn and UDim2.new(1, -19, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		}, Enum.EasingStyle.Back)
	end
	render(0)

	local api = {}
	function api.Set(value)
		isOn = value == true
		render(0.25)
		if callback then
			task.spawn(callback, isOn)
		end
	end
	function api.Get()
		return isOn
	end
	function api.SetDescription(text)
		descriptionLabel.Text = text
	end
	function api.Sync(value)
		value = value == true
		if value ~= isOn then
			isOn = value
			render(0.2)
		end
	end

	frame.MouseButton1Click:Connect(function()
		api.Set(not isOn)
	end)
	return api
end

local function slider(parentCol, title, minimum, maximum, default, suffix, callback, formatter)
	local frame = card(parentCol, 58, "Frame", title)
	label({
		Position = UDim2.fromOffset(12, 8),
		Size = UDim2.new(1, -90, 0, 18),
		Text = title,
		Font = FONT_BOLD,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	})

	local valueBadge = create("Frame", {
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -12, 0, 7),
		Size = UDim2.fromOffset(0, 20),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = THEME.Field,
		Parent = frame,
	})
	paint(valueBadge, "BackgroundColor3", "Field")
	corner(valueBadge, 6)
	padding(valueBadge, 0, 7, 0, 7)

	local valueLabel = label({
		Size = UDim2.fromScale(0, 1),
		AutomaticSize = Enum.AutomaticSize.X,
		Text = "",
		Font = FONT_BOLD,
		TextSize = 11,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = valueBadge,
	})
	paint(valueLabel, "TextColor3", "Accent2")

	local hitbox = create("TextButton", {
		Position = UDim2.new(0, 12, 0, 32),
		Size = UDim2.new(1, -24, 0, 20),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = frame,
	})
	local bar = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 5),
		BackgroundColor3 = THEME.TrackOff,
		Parent = hitbox,
	})
	paint(bar, "BackgroundColor3", "TrackOff")
	round(bar)

	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = COMMON.White,
		Parent = bar,
	})
	round(fill)
	accent(fill, 0, false)

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(13, 13),
		BackgroundColor3 = COMMON.White,
		ZIndex = 2,
		Parent = bar,
	})
	round(knob)

	local value = math.clamp(default, minimum, maximum)
	local function render(duration)
		local alpha = (value - minimum) / math.max(maximum - minimum, 1)
		tween(fill, duration, { Size = UDim2.fromScale(alpha, 1) })
		tween(knob, duration, { Position = UDim2.fromScale(alpha, 0.5) })
		valueLabel.Text = formatter and formatter(value) or (value .. (suffix or ""))
	end
	render(0)

	local api = {}
	function api.Set(newValue)
		newValue = math.clamp(math.floor(newValue + 0.5), minimum, maximum)
		if newValue == value then return end
		value = newValue
		render(0.1)
		if callback then
			task.spawn(callback, value)
		end
	end
	function api.Get() return value end
	function api.Sync(newValue)
		newValue = math.clamp(math.floor(newValue + 0.5), minimum, maximum)
		if newValue ~= value then
			value = newValue
			render(0.1)
		end
	end

	local sliding = false
	local function slideTo(input)
		local alpha = math.clamp((input.Position.X - bar.AbsolutePosition.X) / math.max(bar.AbsoluteSize.X, 1), 0, 1)
		api.Set(minimum + (maximum - minimum) * alpha)
	end
	hitbox.InputBegan:Connect(function(input)
		if isPress(input) then
			sliding = true
			slideTo(input)
		end
	end)
	trackConn(UserInputService.InputChanged:Connect(function(input)
		if sliding and isMove(input) then
			slideTo(input)
		end
	end))
	trackConn(UserInputService.InputEnded:Connect(function(input)
		if sliding and isPress(input) then
			sliding = false
		end
	end))
	return api
end

local bindingKey = false
local function keybind(parentCol, title, configKey, onChanged)
	local frame = card(parentCol, 48, "Frame", title)
	label({
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -120, 1, 0),
		Text = title,
		Font = FONT_BOLD,
		TextSize = 13,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = frame,
	})
	local button = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -12, 0.5, 0),
		Size = UDim2.fromOffset(0, 28),
		AutomaticSize = Enum.AutomaticSize.X,
		BackgroundColor3 = THEME.Field,
		AutoButtonColor = false,
		Text = CONFIG[configKey].Name,
		Font = FONT_BOLD,
		TextSize = 12,
		TextColor3 = COMMON.Text,
		Parent = frame,
	})
	paint(button, "BackgroundColor3", "Field")
	corner(button, 7)
	padding(button, 0, 10, 0, 10)
	local buttonStroke = stroke(button, 0.85, 1)

	local waiting = false
	button.MouseButton1Click:Connect(function()
		if waiting then return end
		waiting = true
		bindingKey = true
		button.Text = "Press a key..."
		tween(buttonStroke, 0.2, { Color = THEME.Accent, Transparency = 0 })

		local connection
		connection = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
			connection:Disconnect()
			waiting = false
			local key = input.KeyCode
			if key ~= Enum.KeyCode.Escape and key ~= Enum.KeyCode.Unknown then
				CONFIG[configKey] = key
				if onChanged then onChanged(key) end
			end
			button.Text = CONFIG[configKey].Name
			tween(buttonStroke, 0.2, { Color = COMMON.White, Transparency = 0.85 })
			task.delay(0.2, function() bindingKey = false end)
		end)
	end)
end

-- Поиск по карточкам внутри вкладок
local function applySearch()
	local q = string.lower(searchBox.Text)
	clearButton.Visible = q ~= ""
	for _, item in ipairs(searchableCards) do
		local match = q == ""
			or string.find(string.lower(item.Tag), q, 1, true) ~= nil
			or string.find(string.lower(tr(item.Tag)), q, 1, true) ~= nil
		item.Frame.Visible = match
	end
end
searchBox:GetPropertyChangedSignal("Text"):Connect(applySearch)
clearButton.MouseButton1Click:Connect(function()
	searchBox.Text = ""
end)

local menuVisible = false
local minimized = false

local function updateBlur()
	local target = (CONFIG.Blur and menuVisible and not minimized) and CONFIG.BlurSize or 0
	tween(blur, 0.35, { Size = target })
end

local function fitToScreen()
	local viewport = camera.ViewportSize
	local base = math.min((viewport.X - 40) / CONFIG.Width, (viewport.Y - 40) / CONFIG.Height, 1)
	fitScale.Scale = math.max(base, 0.48)
end
fitToScreen()
trackConn(camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitToScreen))

-- Кнопка открытия меню слева (❄)
local openDock = create("Frame", {
	Name = "OpenButton",
	AnchorPoint = Vector2.new(0, 0.5),
	Position = UDim2.new(0, 16, 0.5, 0),
	Size = UDim2.fromOffset(48, 48),
	BackgroundTransparency = 1,
	ZIndex = 10,
	Parent = gui,
})
local openButton = create("TextButton", {
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = THEME.Window,
	BackgroundTransparency = 0.08,
	AutoButtonColor = false,
	Text = CONFIG.Logo,
	Font = FONT_BOLD,
	TextSize = 22,
	TextColor3 = THEME.Accent,
	Parent = openDock,
})
paint(openButton, "BackgroundColor3", "Window")
paint(openButton, "TextColor3", "Accent")
round(openButton)
accent(stroke(openButton, 0, 2), 0, true)

local function setMenuVisible(visible)
	if menuVisible == visible then return end
	menuVisible = visible
	state.freeMouse.Visible = visible
	if not visible and state.onMenuClosed then
		task.spawn(state.onMenuClosed)
	end
	if visible then
		holder.Visible = true
		tween(popScale, 0.4, { Scale = 1 }, Enum.EasingStyle.Back)
	else
		local closing = tween(popScale, 0.25, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		closing.Completed:Connect(function(playbackState)
			if playbackState == Enum.PlaybackState.Completed and not menuVisible then
				holder.Visible = false
			end
		end)
	end
	updateBlur()
end

-- [[ 1. ВКЛАДКА HOME (ГЛАВНАЯ) ]]
local homePage, _, homeLeft, homeRight = createTab("Home", "❄", ASSETS.Home, "Welcome!")

local function newYearCountdown()
	local now = os.date("*t")
	local today = os.time({ year = now.year, month = now.month, day = now.day, hour = 0 })
	local target = os.time({ year = now.year + 1, month = 1, day = 1, hour = 0 })
	local days = math.max(0, math.floor((target - today) / 86400 + 0.5))
	return days == 0 and tr("Today!") or trf("%d days", days)
end

section(homeLeft, "SNOW HUB WINTER")
paragraph(homeLeft, trf("Hello, %s!", player.Name), "Добро пожаловать в новогодний Snow Hub v8.0! Меню переработано в удобный двухколоночный интерфейс с плавающим виджетом Quick Bar.")
paragraph(homeLeft, "How to use", "Нажми G или кнопку ❄ слева для открытия меню. Справа сверху расположена панель быстрого доступа Quick Bar — её можно двигать пальцем или мышкой.")

section(homeRight, "STATUS")
paragraph(homeRight, "until New Year", newYearCountdown())
local _, themeStatLabel = paragraph(homeRight, "Active theme", THEME.Name)
onTheme(function()
	themeStatLabel.Text = THEME.Name
end)

-- [[ 2. МОДУЛЬ AIM, ESP И ПЛАВАЮЩИЙ QUICK BAR (КАК НА СКРИНШОТЕ VENYX) ]]
local function setupAim()
	local AIM = {
		GamePassId = 0,
		AimMode = "Override",
		DeviceMode = "Auto",
		AimPart = "Head",
		FOV = 160,
		Smoothness = 0.85,
		InstantSnap = true,
		SpeedStep = 0.05,
		Prediction = 0,
		StickyTarget = true,
		LockGrace = 0,
		HoldToAim = true,
		HoldThroughWalls = false,
		AutoShoot = "All",
		AutoShootAngle = 10,
		AutoShootDelay = 0,
		AutoShootKey = Enum.KeyCode.V,
		KnifeAuto = true,
		KnifeAutoRange = 7,
		KnifeAutoCooldown = 1.25,
		ESPShowWeapon = true,
		NoCameraShake = true,
		ShowQuickBar = true,
		BunnyHop = false,
		CrouchSpam = false,
		SmartESPColors = true,
		TeamCheck = true,
		TeamMode = "Auto",
		TeamAttribute = "Team",
		WallCheck = true,
		TargetNPC = false,
		ShowFOV = true,
		ShowTargetInfo = true,
		Language = currentLanguage,
		HeadOnly = true,
		AimHeight = 0.2,
		FreezeMouse = true,
		TurnBody = true,
		AntiSpectate = true,
		BodyMaxSpeed = 540,
		BodyResponsiveness = 25,
		BodyOnlyWhenVisible = true,
		ESP = true,
		ESPHighlight = true,
		ESPNames = true,
		ESPDistance = true,
		ESPHealth = true,
		ESPTracers = false,
		ESPTeammates = true,
		ESPMaxDistance = 1500,
		ToggleKey = Enum.KeyCode.F,
		AimHoldButton = Enum.UserInputType.MouseButton2,
		SpeedUpKey = Enum.KeyCode.Equals,
		SpeedDownKey = Enum.KeyCode.Minus,
		SnapKey = Enum.KeyCode.X,
	}
	local DEFAULTS = table.clone(AIM)

	-- ИСПРАВЛЕНИЕ БАГА #1: Объявляем локальные переменные прицела ДО обработчиков ввода!
	local lockedPart, lockedTarget = nil, nil
	local aimLook = nil
	local prevWant, prevChar = nil, nil
	local releaseBody = function() end
	local freezeMouse = function() end
	local enabled = false
	local holding = false
	local hasPass = true

	local isMobile = UserInputService.TouchEnabled
		or UserInputService.AccelerometerEnabled
		or UserInputService.GyroscopeEnabled
		or (playerGui:FindFirstChild("TouchGui") ~= nil)

	local function isMobileDevice()
		if AIM.DeviceMode == "Mobile" then return true end
		if AIM.DeviceMode == "PC" then return false end
		if UserInputService.MouseEnabled and not UserInputService.TouchEnabled then return false end
		return isMobile or (playerGui:FindFirstChild("TouchGui") ~= nil)
	end

	-- Поверхность HUD и папка ESP внутри основного контроля очистки
	local hud = create("ScreenGui", {
		Name = "AimHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 5,
		Parent = guiParent,
	})
	local espFolder = create("Folder", {
		Name = "AimESP",
		Parent = guiParent,
	})

	local circle = create("Frame", {
		Name = "FOVCircle",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = hud,
	})
	round(circle)
	local circleStroke = stroke(circle, 0.25, 1.8, THEME.Accent)
	onTheme(function() circleStroke.Color = THEME.Accent end)

	local targetInfo = create("TextLabel", {
		Name = "TargetInfo",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 14),
		Size = UDim2.fromOffset(0, 26),
		BackgroundColor3 = THEME.Window,
		BackgroundTransparency = 0.15,
		Font = FONT_BOLD,
		TextSize = 13,
		TextColor3 = Color3.fromRGB(255, 85, 85),
		Visible = false,
		AutomaticSize = Enum.AutomaticSize.X,
		Parent = hud,
	})
	padding(targetInfo, 0, 12, 0, 12)
	corner(targetInfo, 13)
	stroke(targetInfo, 0.3, 1, THEME.Accent)

	-- [[ ПЛАВАЮЩАЯ ПАНЕЛЬ QUICK BAR (КАК В ПРАВОМ ВЕРХНЕМ УГЛУ НА СКРИНШОТЕ VENYX) ]]
	local quickBar = create("Frame", {
		Name = "QuickBar",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 56),
		Size = UDim2.fromOffset(195, 132),
		BackgroundColor3 = THEME.Window,
		BackgroundTransparency = 0.08,
		Active = true,
		Parent = hud,
	})
	paint(quickBar, "BackgroundColor3", "Window")
	corner(quickBar, 12)
	accent(stroke(quickBar, 0.2, 1.5), 45, true)

	local qbHeader = create("Frame", {
		Size = UDim2.new(1, 0, 0, 28),
		BackgroundTransparency = 1,
		Parent = quickBar,
	})
	label({
		Position = UDim2.fromOffset(10, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Text = "❄ QUICK BAR",
		Font = FONT_BOLD,
		TextSize = 11,
		TextColor3 = THEME.Accent2,
		Parent = qbHeader,
	})

	local qbCollapsed = false
	local qbCollapseBtn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = THEME.Field,
		AutoButtonColor = false,
		Text = "−",
		Font = FONT_BOLD,
		TextSize = 13,
		TextColor3 = COMMON.Text,
		Parent = qbHeader,
	})
	paint(qbCollapseBtn, "BackgroundColor3", "Field")
	round(qbCollapseBtn)

	local qbBody = create("Frame", {
		Position = UDim2.fromOffset(8, 28),
		Size = UDim2.new(1, -16, 1, -34),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = quickBar,
	})
	create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = qbBody })

	qbCollapseBtn.MouseButton1Click:Connect(function()
		qbCollapsed = not qbCollapsed
		qbCollapseBtn.Text = qbCollapsed and "+" or "−"
		qbBody.Visible = not qbCollapsed
		tween(quickBar, 0.25, { Size = qbCollapsed and UDim2.fromOffset(195, 28) or UDim2.fromOffset(195, 132) })
	end)

	-- Перетаскивание Quick Bar пальцем или мышью
	do
		local draggingQB = false
		local dragStartQB, startPosQB
		qbHeader.InputBegan:Connect(function(input)
			if isPress(input) then
				draggingQB = true
				dragStartQB = input.Position
				startPosQB = quickBar.Position
			end
		end)
		trackConn(UserInputService.InputChanged:Connect(function(input)
			if draggingQB and isMove(input) then
				local delta = input.Position - dragStartQB
				quickBar.Position = UDim2.new(
					startPosQB.X.Scale,
					startPosQB.X.Offset + delta.X,
					startPosQB.Y.Scale,
					startPosQB.Y.Offset + delta.Y
				)
			end
		end))
		trackConn(UserInputService.InputEnded:Connect(function(input)
			if isPress(input) then draggingQB = false end
		end))
	end

	local refreshers = {}
	local function refreshAll()
		for _, f in ipairs(refreshers) do
			f()
		end
	end

	local onSettingsChanged = function() end

	local function updateAutoRotate()
		local myChar = player.Character
		local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		if isMobileDevice() then
			hum.AutoRotate = not enabled
		else
			hum.AutoRotate = true
		end
	end

	local function updateUI()
		circle.Visible = AIM.ShowFOV and hasPass and enabled
		quickBar.Visible = AIM.ShowQuickBar
		statusLabel.Text = enabled and "● Active" or "● Idle"
		statusLabel.TextColor3 = enabled and COMMON.Green or COMMON.SubText
		refreshAll()
		onSettingsChanged()
	end

	local function applyConfig()
		circle.Size = UDim2.fromOffset(AIM.FOV * 2, AIM.FOV * 2)
		updateUI()
	end

	local function makeQuickRow(title, getter, toggler)
		local r = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 26),
			BackgroundColor3 = THEME.Card,
			BackgroundTransparency = 0.25,
			AutoButtonColor = false,
			Text = "",
			Parent = qbBody,
		})
		paint(r, "BackgroundColor3", "Card")
		corner(r, 7)
		label({
			Position = UDim2.fromOffset(8, 0),
			Size = UDim2.new(1, -50, 1, 0),
			Text = title,
			Font = FONT_MEDIUM,
			TextSize = 12,
			Parent = r,
		})
		local pill = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(32, 16),
			BackgroundColor3 = THEME.TrackOff,
			Parent = r,
		})
		round(pill)
		local dot = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = COMMON.White,
			Parent = pill,
		})
		round(dot)

		table.insert(refreshers, function()
			local on = getter()
			pill.BackgroundColor3 = on and THEME.Accent or THEME.TrackOff
			dot.Position = on and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		end)
		r.MouseButton1Click:Connect(toggler)
	end

	makeQuickRow("Aim Assist", function() return enabled end, function()
		enabled = not enabled
		updateAutoRotate()
		updateUI()
	end)
	makeQuickRow("Auto-Shoot", function() return AIM.AutoShoot ~= "Off" end, function()
		AIM.AutoShoot = (AIM.AutoShoot == "Off") and "All" or "Off"
		applyConfig()
	end)
	makeQuickRow("Wall ESP", function() return AIM.ESP end, function()
		AIM.ESP = not AIM.ESP
		applyConfig()
	end)

	-- Хелперы для привязки контролов к двухколоночным вкладкам
	local function getValue(key)
		if key == "enabled" then return enabled end
		return AIM[key]
	end

	local function aimToggle(col, title, description, key)
		local api
		api = toggle(col, nil, title, description, getValue(key), function(on)
			if key == "enabled" then
				enabled = on
				updateAutoRotate()
			else
				AIM[key] = on
			end
			applyConfig()
		end)
		table.insert(refreshers, function()
			api.Sync(getValue(key))
		end)
	end

	local function aimSlider(col, title, key, minimum, maximum, scale, formatter)
		local api
		api = slider(col, title, minimum, maximum, math.floor(AIM[key] * scale + 0.5), "", function(v)
			AIM[key] = v / scale
			applyConfig()
		end, formatter)
		table.insert(refreshers, function()
			api.Sync(math.floor(AIM[key] * scale + 0.5))
		end)
	end

	local function aimChoice(col, title, description, key, options)
		local frame = card(col, 50, "TextButton", title)
		label({
			Position = UDim2.fromOffset(12, 8),
			Size = UDim2.new(1, -115, 0, 18),
			Text = title,
			Font = FONT_BOLD,
			TextSize = 13,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = frame,
		})
		label({
			Position = UDim2.fromOffset(12, 26),
			Size = UDim2.new(1, -115, 0, 15),
			Text = description or "",
			Font = FONT_REGULAR,
			TextSize = 11,
			TextColor3 = COMMON.SubText,
			TextTruncate = Enum.TextTruncate.AtEnd,
			Parent = frame,
		})
		local pill = create("TextLabel", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -10, 0.5, 0),
			Size = UDim2.fromOffset(96, 26),
			BackgroundColor3 = THEME.Field,
			Font = FONT_BOLD,
			TextSize = 11,
			TextColor3 = THEME.Accent2,
			Text = "",
			Parent = frame,
		})
		paint(pill, "BackgroundColor3", "Field")
		paint(pill, "TextColor3", "Accent2")
		corner(pill, 7)

		local function sync()
			for _, opt in ipairs(options) do
				if opt[1] == AIM[key] then
					pill.Text = tr(opt[2]) .. " ▾"
				end
			end
		end
		frame.MouseButton1Click:Connect(function()
			local idx = 1
			for i, opt in ipairs(options) do
				if opt[1] == AIM[key] then idx = i end
			end
			AIM[key] = options[idx % #options + 1][1]
			applyConfig()
		end)
		table.insert(refreshers, sync)
		sync()
	end

	-- [[ 2. ВКЛАДКА AIM (ДВЕ КОЛОНКИ КАК НА СКРИНШОТЕ VENYX) ]]
	local _, _, aimLeft, aimRight = createTab("Aim", "◎", ASSETS.Aim, "Aim assist and auto-shoot")

	section(aimLeft, "Main")
	aimToggle(aimLeft, "Aim", "Включить автонаводку (Клавиша F)", "enabled")
	aimChoice(aimLeft, "Camera Mode", "Режим управления камерой", "AimMode", {
		{ "Override", "Rivals" },
		{ "Classic", "Normal" },
	})
	aimChoice(aimLeft, "Aim At", "Приоритетная часть тела", "AimPart", {
		{ "Head", "Head" },
		{ "UpperTorso", "Body" },
		{ "HumanoidRootPart", "Center" },
	})
	aimToggle(aimLeft, "Head Only", "Всегда только в голову", "HeadOnly")
	aimToggle(aimLeft, "Hold Right Mouse", "ПК: только при зажатой ПКМ", "HoldToAim")
	aimToggle(aimLeft, "Right Mouse Through Walls", "Цель сквозь стены при зажатии", "HoldThroughWalls")

	section(aimLeft, "Aim Speed")
	aimSlider(aimLeft, "Speed", "Smoothness", 5, 100, 100, function(v) return v .. "%" end)
	aimToggle(aimLeft, "Instant Aim", "Мгновенная доводка без плавности", "InstantSnap")
	aimSlider(aimLeft, "FOV Radius", "FOV", 30, 400, 1, function(v) return v .. " px" end)
	aimSlider(aimLeft, "Prediction", "Prediction", 0, 300, 1000, function(v) return v .. " ms" end)
	aimSlider(aimLeft, "Aim Height", "AimHeight", -100, 100, 100, function(v) return string.format("%+.2f", v / 100) end)

	section(aimRight, "Auto-Shoot")
	aimChoice(aimRight, "Auto-Shoot", "Автоматический выстрел по цели", "AutoShoot", {
		{ "All", "Everywhere" },
		{ "Phone", "Phone" },
		{ "Off", "Off" },
	})
	aimSlider(aimRight, "Accuracy", "AutoShootAngle", 1, 30, 1, function(v) return v .. "°" end)
	aimSlider(aimRight, "Pause Between Shots", "AutoShootDelay", 0, 500, 1000, function(v) return v .. " ms" end)

	section(aimRight, "KnifeAuto (150 DMG)")
	aimToggle(aimRight, "KnifeAuto (150 DMG)", "Авто-удар ножом в спину на 150 урона", "KnifeAuto")
	aimSlider(aimRight, "KnifeAuto Range", "KnifeAutoRange", 3, 20, 1, function(v) return v .. " st" end)

	section(aimRight, "Movement & Evasion")
	aimToggle(aimRight, "BunnyHop", "Авто-прыжки в движении", "BunnyHop")
	aimToggle(aimRight, "Crouch Spam", "Быстрые приседания при стрельбе", "CrouchSpam")

	section(aimRight, "Checks")
	aimToggle(aimRight, "Team Check", "Игнорировать тиммейтов", "TeamCheck")
	aimToggle(aimRight, "Wall Check", "Не наводиться сквозь стены", "WallCheck")
	aimToggle(aimRight, "Turn Body To Target", "Поворачивать перса к врагу (Моб.)", "TurnBody")
	aimToggle(aimRight, "No Camera Shake", "Убрать отдачу и тряску экрана", "NoCameraShake")
	aimToggle(aimRight, "Show FOV Circle", "Показывать круг радиуса FOV", "ShowFOV")
	aimToggle(aimRight, "Show Target", "Плашка цели вверху экрана", "ShowTargetInfo")

	-- [[ 3. ВКЛАДКА ESP (ДВЕ КОЛОНКИ: ВИЗУАЛ СКИНОВ И ИНФОРМАЦИЯ) ]]
	local _, _, espLeft, espRight = createTab("ESP", "◇", ASSETS.ESP, "See where players are")

	section(espLeft, "HIGHLIGHT & COLORS")
	aimToggle(espLeft, "ESP", "Включить показ игроков сквозь стены", "ESP")
	aimToggle(espLeft, "Highlight", "Мягкая обводка (скин отлично видно)", "ESPHighlight")
	aimToggle(espLeft, "Smart ESP Colors", "Враг красный, за стеной светлее", "SmartESPColors")
	aimToggle(espLeft, "Show Teammates", "Тиммейты подсвечиваются зелёным", "ESPTeammates")

	section(espRight, "PLAYER INFO & FILTER")
	aimToggle(espRight, "Names", "Показывать ники над головой", "ESPNames")
	aimToggle(espRight, "Show Weapon in ESP", "Показывать оружие в руках", "ESPShowWeapon")
	aimToggle(espRight, "Distance", "Показывать расстояние в метрах", "ESPDistance")
	aimToggle(espRight, "Health Bar", "Полоска здоровья под ником", "ESPHealth")
	aimToggle(espRight, "Tracers", "Линии от низа экрана к игрокам", "ESPTracers")
	aimSlider(espRight, "Max Distance", "ESPMaxDistance", 50, 3000, 1, function(v) return v .. " m" end)

	-- [[ СОХРАНЕНИЕ КОНФИГА ]]
	local SAVE_KEYS = {}
	for k, v in pairs(DEFAULTS) do
		local t = typeof(v)
		if (t == "boolean" or t == "number" or t == "string") and k ~= "GamePassId" and k ~= "TeamAttribute" then
			table.insert(SAVE_KEYS, k)
		end
	end
	table.sort(SAVE_KEYS)

	local CONFIG_FILE = "SnowHub_v8.cfg"
	local function exportCode()
		local parts = { "enabled=" .. (enabled and "1" or "0") }
		for _, k in ipairs(SAVE_KEYS) do
			local v = AIM[k]
			if type(v) == "boolean" then v = v and "1" or "0"
			elseif type(v) == "number" then v = string.format("%g", v)
			end
			table.insert(parts, k .. "=" .. tostring(v))
		end
		return table.concat(parts, ";")
	end

	local function importCode(code)
		if type(code) ~= "string" then return end
		for pair in string.gmatch(code, "[^;]+") do
			local k, v = string.match(pair, "^%s*([%w_]+)%s*=%s*(.-)%s*$")
			if k == "enabled" then
				enabled = (v == "1")
			elseif k and DEFAULTS[k] ~= nil then
				local def = DEFAULTS[k]
				if type(def) == "boolean" then
					AIM[k] = (v == "1" or v == "true")
				elseif type(def) == "number" and tonumber(v) then
					AIM[k] = tonumber(v)
				elseif type(def) == "string" then
					AIM[k] = v
				end
			end
		end
	end

	pcall(function()
		if isfile and readfile and isfile(CONFIG_FILE) then
			importCode(readfile(CONFIG_FILE))
		end
	end)

	onSettingsChanged = function()
		pcall(function()
			if writefile then
				writefile(CONFIG_FILE, exportCode())
			end
		end)
	end

	applyConfig()

	-- [[ ОБРАБОТКА ВВОДА (С ПРАВИЛЬНЫМ СБРОСОМ ЗАХВАТА) ]]
	trackConn(UserInputService.InputBegan:Connect(function(input, processed)
		if input.UserInputType == AIM.AimHoldButton and not menuVisible then
			holding = true
			return
		end
		if processed or bindingKey then return end
		local key = input.KeyCode
		if key == AIM.ToggleKey then
			enabled = not enabled
			updateAutoRotate()
			updateUI()
		elseif key == AIM.AutoShootKey then
			AIM.AutoShoot = (AIM.AutoShoot == "Off") and "All" or "Off"
			notify("Auto-Shoot", AIM.AutoShoot == "Off" and "Автострел: ВЫКЛ" or "Автострел: ВКЛ", 2)
			applyConfig()
		elseif key == AIM.SnapKey then
			AIM.InstantSnap = not AIM.InstantSnap
			applyConfig()
		end
	end))

	trackConn(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == AIM.AimHoldButton then
			holding = false
			lockedPart, lockedTarget = nil, nil
			aimLook = nil
			prevWant, prevChar = nil, nil
			releaseBody()
			freezeMouse(false)
		end
	end))

	trackConn(UserInputService.WindowFocusReleased:Connect(function()
		holding = false
		lockedPart, lockedTarget = nil, nil
		aimLook = nil
		prevWant, prevChar = nil, nil
		releaseBody()
		freezeMouse(false)
	end))

	-- [[ ОПРЕДЕЛЕНИЕ КОМАНДЫ ]]
	local TEAM_FIELDS = { AIM.TeamAttribute, "Team", "TeamName", "TeamId", "TeamID", "TeamColor", "Side", "Squad" }
	local function readTeam(inst)
		if not inst then return nil end
		for _, field in ipairs(TEAM_FIELDS) do
			local ok, attr = pcall(inst.GetAttribute, inst, field)
			if ok and attr ~= nil and attr ~= "" then return tostring(attr) end
			local v = inst:FindFirstChild(field)
			if v and v:IsA("ValueBase") and v.Value ~= nil and v.Value ~= "" then
				return typeof(v.Value) == "Instance" and v.Value.Name or tostring(v.Value)
			end
		end
		return nil
	end

	local function teamOf(plr)
		if not plr then return nil end
		local k = readTeam(plr) or readTeam(plr.Character) or readTeam(plr:FindFirstChild("leaderstats"))
		if k then return "a:" .. k end
		if plr.Team then return "t:" .. plr.Team.Name end
		if not plr.Neutral then return "c:" .. plr.TeamColor.Name end
		return nil
	end

	local teamCache = { at = -1, keys = {}, mine = nil, ffa = false }
	local function updateTeamCache()
		if os.clock() - teamCache.at < 0.25 then return end
		teamCache.at = os.clock()
		local keys = {}
		local mine = teamOf(player)
		local all, same = 0, 0
		for _, plr in ipairs(Players:GetPlayers()) do
			local k = teamOf(plr)
			keys[plr] = k or false
			all += 1
			if k ~= nil and k == mine then same += 1 end
		end
		teamCache.keys = keys
		teamCache.mine = mine
		teamCache.ffa = (all >= 2 and same == all)
	end

	local function isTeammate(plr)
		if not plr or plr == player or AIM.TeamMode == "Off" then return false end
		updateTeamCache()
		if teamCache.ffa or not teamCache.mine then return false end
		local theirs = teamCache.keys[plr]
		if theirs == nil then theirs = teamOf(plr) or false end
		return theirs ~= false and theirs == teamCache.mine
	end

	local function aliveHumanoid(char)
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		return (hum and hum.Health > 0) and hum or nil
	end

	local function getTargets()
		local list = {}
		for _, plr in ipairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				table.insert(list, { char = plr.Character, plr = plr, name = plr.DisplayName })
			end
		end
		return list
	end

	-- [[ ОПРЕДЕЛЕНИЕ ОРУЖИЯ И НОЖА ]]
	local WeaponDetector = {}
	local MELEE_KEYWORDS = {
		knife = true, blade = true, katana = true, sword = true, dagger = true,
		scythe = true, axe = true, machete = true, karambit = true, butterfly = true,
		bat = true, crowbar = true, hammer = true, fists = true, melee = true,
		balisong = true, pocket = true,
	}
	local function isNameMelee(name)
		local lower = string.lower(tostring(name or ""))
		for kw in pairs(MELEE_KEYWORDS) do
			if string.find(lower, kw, 1, true) then return true end
		end
		return false
	end

	function WeaponDetector.GetHeldItem(char)
		if not char then return nil end
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then
			local isMelee = tool:GetAttribute("Melee") == true
				or tool:GetAttribute("IsMelee") == true
				or tool:GetAttribute("WeaponType") == "Melee"
				or isNameMelee(tool.Name)
			return { Tool = tool, Name = tool.Name, IsMelee = isMelee }
		end
		local attrName = char:GetAttribute("EquippedWeapon") or char:GetAttribute("CurrentWeapon") or char:GetAttribute("Weapon")
		if attrName then
			return { Tool = nil, Name = tostring(attrName), IsMelee = isNameMelee(attrName) }
		end
		return nil
	end

	-- ИСПРАВЛЕНИЕ БАГА #2: KnifeAutoModule использует динамический AIM.KnifeAutoRange
	local KnifeAutoModule = { LastHeavy = 0 }
	local function isBehindTarget(myRoot, enemyRoot)
		if not (myRoot and enemyRoot) then return false end
		local toMe = (myRoot.Position - enemyRoot.Position)
		if toMe.Magnitude < 0.01 then return false end
		return enemyRoot.CFrame.LookVector:Dot(toMe.Unit) < -0.35
	end

	function KnifeAutoModule.IsHeavyTiming(myRoot, enemyRoot)
		if not (myRoot and enemyRoot) then return false end
		local dist = (enemyRoot.Position - myRoot.Position).Magnitude
		if dist > (AIM.KnifeAutoRange or 7) then return false end
		return isBehindTarget(myRoot, enemyRoot)
	end

	function KnifeAutoModule.ExecuteHeavy(tool)
		if not tool then return end
		pcall(function() tool:Activate() end)
		task.spawn(function()
			pcall(function()
				if mouse2click then mouse2click()
				elseif mouse2press and mouse2release then
					mouse2press()
					task.wait(0.03)
					mouse2release()
				end
			end)
		end)
		local heavyEvt = tool:FindFirstChild("Heavy") or tool:FindFirstChild("Secondary") or tool:FindFirstChild("HeavyAttack")
		if heavyEvt and heavyEvt:IsA("RemoteEvent") then
			pcall(function() heavyEvt:FireServer("Heavy") end)
		end
	end

	-- [[ ESP СИСТЕМА (ПРОЗРАЧНАЯ ЗАЛИВКА ДЛЯ СКИНА + БЕЛЕЕ ЗА СТЕНАМИ) ]]
	local espObjects = {}
	local function createESP(char)
		local o = {}
		local hl = Instance.new("Highlight")
		hl.Name = "SnowHubHighlight"
		hl.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
		hl.FillTransparency = 0.85
		hl.OutlineTransparency = 0.05
		hl.Adornee = char
		hl.Parent = char
		o.highlight = hl

		local bb = Instance.new("BillboardGui")
		bb.Name = "ESP_" .. char.Name
		bb.AlwaysOnTop = true
		bb.Size = UDim2.fromOffset(200, 46)
		bb.StudsOffset = Vector3.new(0, 2.6, 0)
		bb.LightInfluence = 0
		bb.Parent = espFolder
		o.billboard = bb

		local function textLbl(y, h, size)
			local l = Instance.new("TextLabel")
			l.BackgroundTransparency = 1
			l.Position = UDim2.fromOffset(0, y)
			l.Size = UDim2.new(1, 0, 0, h)
			l.Font = FONT_BOLD
			l.TextSize = size
			l.TextStrokeTransparency = 0.25
			l.TextColor3 = Color3.new(1, 1, 1)
			l.Parent = bb
			return l
		end
		o.name = textLbl(0, 18, 14)
		o.info = textLbl(17, 15, 12)

		local hpBack = Instance.new("Frame")
		hpBack.AnchorPoint = Vector2.new(0.5, 0)
		hpBack.Position = UDim2.new(0.5, 0, 0, 35)
		hpBack.Size = UDim2.fromOffset(68, 5)
		hpBack.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
		hpBack.BorderSizePixel = 0
		hpBack.Parent = bb
		corner(hpBack, 3)

		local hpFill = Instance.new("Frame")
		hpFill.BorderSizePixel = 0
		hpFill.Parent = hpBack
		corner(hpFill, 3)
		o.hpBack, o.hpFill = hpBack, hpFill

		local tracer = Instance.new("Frame")
		tracer.AnchorPoint = Vector2.new(0.5, 0.5)
		tracer.BorderSizePixel = 0
		tracer.BackgroundTransparency = 0.2
		tracer.Visible = false
		tracer.Parent = hud
		o.tracer = tracer

		espObjects[char] = o
		return o
	end

	local function destroyESP(char)
		local o = espObjects[char]
		if not o then return end
		pcall(function() o.highlight:Destroy() end)
		pcall(function() o.billboard:Destroy() end)
		pcall(function() o.tracer:Destroy() end)
		espObjects[char] = nil
	end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local PART_NAMES = {
		Head = { "Head" },
		UpperTorso = { "UpperTorso", "Torso" },
		HumanoidRootPart = { "HumanoidRootPart", "Torso" },
	}
	local function getAimPart(char)
		local partName = AIM.HeadOnly and "Head" or AIM.AimPart
		for _, name in ipairs(PART_NAMES[partName] or { partName }) do
			local p = char:FindFirstChild(name)
			if p and p:IsA("BasePart") then return p end
		end
		return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	end

	local function isVisible(cam, part, targetChar)
		if not AIM.WallCheck then return true end
		if (holding or isMobileDevice()) and AIM.HoldThroughWalls then return true end
		local origin = cam.CFrame.Position
		local dir = part.Position - origin
		local ignore = { cam }
		if player.Character then table.insert(ignore, player.Character) end

		for _, child in ipairs(workspace:GetChildren()) do
			if child:IsA("Model") and (string.find(string.lower(child.Name), "view") or string.find(string.lower(child.Name), "arm")) then
				table.insert(ignore, child)
			end
		end

		for _ = 1, 5 do
			rayParams.FilterDescendantsInstances = ignore
			local result = workspace:Raycast(origin, dir, rayParams)
			if not result then return true end
			local hit = result.Instance
			if hit:IsDescendantOf(targetChar) then return true end
			local model = hit:FindFirstAncestorOfClass("Model")
			if model and model:FindFirstChildOfClass("Humanoid") then
				table.insert(ignore, model)
			elseif hit.Transparency > 0.75 then
				table.insert(ignore, hit)
			else
				return false
			end
		end
		return false
	end

	local espLastUpdate = 0
	local espRayCache = {}

	local function updateESP(cam, targets)
		if os.clock() - espLastUpdate < 0.033 then return end
		espLastUpdate = os.clock()
		local seen = {}

		if hasPass and AIM.ESP then
			local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local origin = myRoot and myRoot.Position or cam.CFrame.Position
			local vs = cam.ViewportSize

			for _, t in ipairs(targets) do
				local char = t.char
				local hum = aliveHumanoid(char)
				local root = char:FindFirstChild("HumanoidRootPart") or char.PrimaryPart
				if hum and root then
					local mate = isTeammate(t.plr)
					local dist = (root.Position - origin).Magnitude
					if (AIM.ESPTeammates or not mate) and dist <= AIM.ESPMaxDistance then
						seen[char] = true
						local o = espObjects[char] or createESP(char)
						local now = os.clock()
						local visible
						if espRayCache[char] and now - espRayCache[char].t < 0.1 then
							visible = espRayCache[char].v
						else
							visible = isVisible(cam, getAimPart(char) or root, char)
							espRayCache[char] = { v = visible, t = now }
						end

						local fillColor, outlineColor, fillTrans
						if mate then
							if AIM.SmartESPColors and not visible then
								fillColor = Color3.fromRGB(170, 255, 195)
								outlineColor = Color3.fromRGB(235, 255, 240)
								fillTrans = 0.78
							else
								fillColor = Color3.fromRGB(45, 255, 100)
								outlineColor = Color3.fromRGB(130, 255, 160)
								fillTrans = 0.85
							end
						else
							if AIM.SmartESPColors and not visible then
								fillColor = Color3.fromRGB(255, 165, 165)
								outlineColor = Color3.fromRGB(255, 235, 235)
								fillTrans = 0.78
							else
								fillColor = Color3.fromRGB(255, 45, 45)
								outlineColor = Color3.fromRGB(255, 120, 120)
								fillTrans = 0.85
							end
						end

						o.highlight.Enabled = AIM.ESPHighlight
						o.highlight.FillColor = fillColor
						o.highlight.OutlineColor = outlineColor
						o.highlight.FillTransparency = fillTrans
						o.highlight.OutlineTransparency = 0.05

						o.billboard.Adornee = char:FindFirstChild("Head") or root
						o.billboard.Enabled = AIM.ESPNames or AIM.ESPDistance or AIM.ESPHealth

						o.name.Visible = AIM.ESPNames
						local held = AIM.ESPShowWeapon and WeaponDetector.GetHeldItem(char)
						local weaponTag = held and (" [" .. held.Name .. "]") or ""
						o.name.Text = t.name .. weaponTag
						o.name.TextColor3 = fillColor

						o.info.Visible = AIM.ESPDistance
						o.info.Text = math.floor(dist + 0.5) .. " m"

						o.hpBack.Visible = AIM.ESPHealth
						local hp = math.clamp(hum.Health / math.max(hum.MaxHealth, 1), 0, 1)
						o.hpFill.Size = UDim2.fromScale(hp, 1)
						o.hpFill.BackgroundColor3 = Color3.fromHSV(hp * 0.33, 0.9, 0.95)

						if AIM.ESPTracers then
							local sp = cam:WorldToViewportPoint(root.Position)
							if sp.Z > 0 then
								local a = Vector2.new(vs.X / 2, vs.Y)
								local b = Vector2.new(sp.X, sp.Y)
								local d = b - a
								o.tracer.BackgroundColor3 = fillColor
								o.tracer.Position = UDim2.fromOffset((a.X + b.X) / 2, (a.Y + b.Y) / 2)
								o.tracer.Size = UDim2.fromOffset(d.Magnitude, 1.5)
								o.tracer.Rotation = math.deg(math.atan2(d.Y, d.X))
								o.tracer.Visible = true
							else
								o.tracer.Visible = false
							end
						else
							o.tracer.Visible = false
						end
					end
				end
			end
		end

		for char in pairs(espObjects) do
			if not seen[char] then destroyESP(char) end
		end
	end

	-- [[ МАТЕМАТИКА НАВОДКИ ]]
	local VISIBLE_PARTS = { "Head", "UpperTorso", "Torso", "HumanoidRootPart" }
	local lockSeenAt = 0

	local function checkTarget(cam, t, center, maxDist)
		local char = t.char
		if not char.Parent or not aliveHumanoid(char) then return nil end
		if AIM.TeamCheck and isTeammate(t.plr) then return nil end
		local part = getAimPart(char)
		if not part then return nil end

		local sp, onScreen = cam:WorldToViewportPoint(part.Position)
		if not onScreen then return nil end
		local dist = (Vector2.new(sp.X, sp.Y) - center).Magnitude
		if dist >= maxDist then return nil end

		if not isVisible(cam, part, char) then
			if AIM.HeadOnly then return nil end
			local alt = nil
			for _, n in ipairs(VISIBLE_PARTS) do
				local p = char:FindFirstChild(n)
				if p and p ~= part and p:IsA("BasePart") and isVisible(cam, p, char) then
					alt = p
					break
				end
			end
			if not alt then return nil end
			part = alt
		end
		return part, dist
	end

	local function getClosestTarget(cam, targets, current)
		local vs = cam.ViewportSize
		local center = Vector2.new(vs.X / 2, vs.Y / 2)
		local maxFov = AIM.FOV

		if current and AIM.StickyTarget then
			local part = checkTarget(cam, current, center, maxFov * 1.5)
			if part then
				lockSeenAt = os.clock()
				return part, current
			end
			if os.clock() - lockSeenAt < math.max(AIM.LockGrace, 0.2)
				and current.char.Parent and aliveHumanoid(current.char)
				and not (AIM.TeamCheck and isTeammate(current.plr)) then
				local p = getAimPart(current.char)
				if p then return p, current end
			end
		end

		local bestPart, bestTarget, bestDist = nil, nil, maxFov
		for _, t in ipairs(targets) do
			local part, dist = checkTarget(cam, t, center, bestDist)
			if part then bestPart, bestTarget, bestDist = part, t, dist end
		end
		if bestTarget then lockSeenAt = os.clock() end
		return bestPart, bestTarget
	end

	local function aimPosition(part)
		local pos = part.Position
		if part.Name == "Head" then pos += Vector3.new(0, AIM.AimHeight, 0) end
		if AIM.Prediction > 0 then
			local root = part.Parent and part.Parent:FindFirstChild("HumanoidRootPart")
			pos += (root or part).AssemblyLinearVelocity * AIM.Prediction
		end
		return pos
	end

	local function smoothAlpha(dt)
		if AIM.InstantSnap or AIM.Smoothness >= 0.95 then return 1 end
		return 1 - (1 - math.clamp(AIM.Smoothness, 0.01, 1)) ^ (dt * 60)
	end

	local function lookCFrame(pos, look)
		if math.abs(look.Y) > 0.999 then
			look = Vector3.new(look.X + 0.001, math.sign(look.Y) * 0.999, look.Z).Unit
		end
		return CFrame.lookAt(pos, pos + look)
	end

	local function trackLook(current, want, dt)
		local newLook = current:Lerp(want, smoothAlpha(dt))
		if newLook.Magnitude < 1e-3 then return want end
		return newLook.Unit
	end

	local mouseFrozen = false
	local savedSensitivity = nil
	freezeMouse = function(frozen)
		if frozen == mouseFrozen then return end
		pcall(function()
			if frozen then
				if savedSensitivity == nil then savedSensitivity = UserInputService.MouseDeltaSensitivity end
				UserInputService.MouseDeltaSensitivity = 0
			elseif savedSensitivity ~= nil then
				UserInputService.MouseDeltaSensitivity = savedSensitivity
				savedSensitivity = nil
			end
		end)
		mouseFrozen = frozen
	end

	local BodyTurn = { Align = nil, Active = false, Hum = nil, SavedAutoRotate = nil }
	local function ensureBodyAlign()
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return nil end
		if BodyTurn.Align and BodyTurn.Align.Parent == hrp then return BodyTurn.Align end

		local attach = hrp:FindFirstChild("AimRootAttachment") or Instance.new("Attachment", hrp)
		attach.Name = "AimRootAttachment"
		local align = hrp:FindFirstChild("AimAlign") or Instance.new("AlignOrientation", hrp)
		align.Name = "AimAlign"
		align.Mode = Enum.OrientationAlignmentMode.OneAttachment
		align.Attachment0 = attach
		align.MaxTorque = 60000
		align.RigidityEnabled = false
		align.Enabled = false
		BodyTurn.Align = align
		BodyTurn.Hum = hum
		return align
	end

	releaseBody = function()
		if not BodyTurn.Active then return end
		BodyTurn.Active = false
		if BodyTurn.Align and BodyTurn.Align.Parent then BodyTurn.Align.Enabled = false end
		if BodyTurn.Hum and BodyTurn.Hum.Parent and BodyTurn.SavedAutoRotate ~= nil then
			BodyTurn.Hum.AutoRotate = BodyTurn.SavedAutoRotate
		end
		BodyTurn.SavedAutoRotate = nil
	end

	local function turnBodyTo(look)
		if not AIM.TurnBody then releaseBody(); return end
		local flat = Vector3.new(look.X, 0, look.Z)
		if flat.Magnitude < 0.05 then return end
		local align = ensureBodyAlign()
		if not align then return end
		if not BodyTurn.Active then
			BodyTurn.Active = true
			BodyTurn.SavedAutoRotate = BodyTurn.Hum.AutoRotate
			BodyTurn.Hum.AutoRotate = false
		end
		align.MaxAngularVelocity = math.rad(AIM.BodyMaxSpeed or 540)
		align.Responsiveness = AIM.BodyResponsiveness or 25
		align.CFrame = CFrame.lookAt(Vector3.zero, flat.Unit)
		align.Enabled = true
	end

	local function isRmbDown()
		if holding then return true end
		local ok, pressed = pcall(UserInputService.IsMouseButtonPressed, UserInputService, Enum.UserInputType.MouseButton2)
		return ok and pressed or false
	end

	RunService:BindToRenderStep("AimMain", Enum.RenderPriority.Camera.Value - 1, function(dt)
		local cam = workspace.CurrentCamera
		if not cam then return end

		if AIM.NoCameraShake then
			local myChar = player.Character
			local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
			if hum and hum.CameraOffset.Magnitude > 0.8 then
				hum.CameraOffset = hum.CameraOffset.Unit * 0.8
			end
		end

		local targets = getTargets()
		updateESP(cam, targets)

		local wantAim
		if isMobileDevice() then
			wantAim = hasPass and enabled and not menuVisible and aliveHumanoid(player.Character) ~= nil
		else
			local myHeld = WeaponDetector.GetHeldItem(player.Character)
			local isMelee = myHeld and myHeld.IsMelee
			wantAim = hasPass and enabled and not menuVisible and aliveHumanoid(player.Character) ~= nil and (not AIM.HoldToAim or isRmbDown() or isMelee)
		end

		local newPart, newTarget = nil, nil
		if wantAim then newPart, newTarget = getClosestTarget(cam, targets, lockedTarget) end
		lockedPart, lockedTarget = newPart, newTarget

		if not lockedPart then
			aimLook = nil
			freezeMouse(false)
			releaseBody()
			targetInfo.Visible = false
			return
		end

		local want = (aimPosition(lockedPart) - cam.CFrame.Position).Unit
		aimLook = trackLook(aimLook or cam.CFrame.LookVector, want, dt)
		cam.CFrame = lookCFrame(cam.CFrame.Position, aimLook)

		if isMobileDevice() and isVisible(cam, lockedPart, lockedTarget.char) then
			turnBodyTo(aimLook)
		else
			releaseBody()
		end

		freezeMouse(AIM.FreezeMouse)

		if AIM.ShowTargetInfo then
			local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local d = myRoot and math.floor((lockedPart.Position - myRoot.Position).Magnitude + 0.5) or 0
			local enemyWeapon = WeaponDetector.GetHeldItem(lockedTarget.char)
			local weaponInfo = enemyWeapon and (" [" .. enemyWeapon.Name .. "]") or ""
			targetInfo.Text = string.format("🎯 %s%s  •  %d m", lockedTarget.name, weaponInfo, d)
			targetInfo.Visible = true
		else
			targetInfo.Visible = false
		end
	end)

	RunService:BindToRenderStep("AimCameraOverride", Enum.RenderPriority.Last.Value, function()
		if AIM.AimMode ~= "Override" or not lockedPart or not aimLook then return end
		local cam = workspace.CurrentCamera
		if cam then
			cam.CFrame = lookCFrame(cam.CFrame.Position, aimLook)
		end
	end)

	local firing, lastShot = false, 0
	local function setTrigger(down)
		local char = player.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		if tool then
			if down then tool:Activate() else tool:Deactivate() end
		end
	end

	RunService:BindToRenderStep("AimAutoShoot", Enum.RenderPriority.Last.Value + 1, function()
		local cam = workspace.CurrentCamera
		local myChar = player.Character
		if not cam or not (myChar and aliveHumanoid(myChar)) or menuVisible then
			if firing then setTrigger(false); firing = false end
			return
		end

		local myRoot = myChar:FindFirstChild("HumanoidRootPart")
		local held = WeaponDetector.GetHeldItem(myChar)
		local targets = getTargets()

		if AIM.KnifeAuto and held and held.IsMelee and myRoot then
			local now = os.clock()
			if now - KnifeAutoModule.LastHeavy >= AIM.KnifeAutoCooldown then
				for _, t in ipairs(targets) do
					local enemyChar = t.char
					local enemyRoot = enemyChar and (enemyChar:FindFirstChild("HumanoidRootPart") or enemyChar.PrimaryPart)
					if enemyRoot and aliveHumanoid(enemyChar) and not enemyChar:FindFirstChildOfClass("ForceField") and not (AIM.TeamCheck and isTeammate(t.plr)) then
						if KnifeAutoModule.IsHeavyTiming(myRoot, enemyRoot) then
							KnifeAutoModule.ExecuteHeavy(held.Tool)
							KnifeAutoModule.LastHeavy = now
							break
						end
					end
				end
			end
		end

		local allowed = (AIM.AutoShoot == "All") or (AIM.AutoShoot == "Phone" and isMobileDevice())
		if not allowed then
			if firing then setTrigger(false); firing = false end
			return
		end

		local shouldFire = false
		local aimDir = cam.CFrame.LookVector
		local candidates = lockedPart and { lockedPart } or {}
		if not lockedPart then
			for _, t in ipairs(targets) do
				local char = t.char
				if char and aliveHumanoid(char) and not char:FindFirstChildOfClass("ForceField") and not (AIM.TeamCheck and isTeammate(t.plr)) then
					local p = getAimPart(char)
					if p and isVisible(cam, p, char) then table.insert(candidates, p) end
				end
			end
		end

		for _, part in ipairs(candidates) do
			local dir = (aimPosition(part) - cam.CFrame.Position).Unit
			local dot = math.clamp(aimDir:Dot(dir), -1, 1)
			if math.deg(math.acos(dot)) <= (AIM.AutoShootAngle or 10) then
				shouldFire = true
				break
			end
		end

		if shouldFire then
			local now = os.clock()
			if (AIM.AutoShootDelay or 0) <= 0 or (now - lastShot >= AIM.AutoShootDelay) then
				if firing then setTrigger(false) end
				setTrigger(true)
				firing = true
				lastShot = now
			end
		elseif firing then
			setTrigger(false)
			firing = false
		end
	end)

	-- ИСПРАВЛЕНИЕ БАГА #3: CrouchSpam не срабатывает при кликах внутри открытого меню
	local lastCrouchToggle, crouchDown = 0, false
	trackConn(RunService.Heartbeat:Connect(function()
		local myChar = player.Character
		local hum = myChar and aliveHumanoid(myChar)
		if not hum or menuVisible then
			if crouchDown then
				crouchDown = false
				pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game) end)
			end
			return
		end

		if AIM.BunnyHop and hum.MoveDirection.Magnitude > 0.05 and hum.FloorMaterial ~= Enum.Material.Air then
			hum.Jump = true
		end

		local isShooting = firing or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		if AIM.CrouchSpam and isShooting then
			local now = os.clock()
			if now - lastCrouchToggle >= 0.18 then
				lastCrouchToggle = now
				crouchDown = not crouchDown
				pcall(function() VirtualInputManager:SendKeyEvent(crouchDown, Enum.KeyCode.C, false, game) end)
			end
		elseif crouchDown then
			crouchDown = false
			pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.C, false, game) end)
		end
	end))

	table.insert(state.onClose, function()
		pcall(function() RunService:UnbindFromRenderStep("AimMain") end)
		pcall(function() RunService:UnbindFromRenderStep("AimCameraOverride") end)
		pcall(function() RunService:UnbindFromRenderStep("AimAutoShoot") end)
		releaseBody()
		freezeMouse(false)
		pcall(function() hud:Destroy() end)
		pcall(function() espFolder:Destroy() end)
	end)
end
pcall(setupAim)

-- [[ 4. ВКЛАДКА THEMES (НОВОГОДНИЕ ТЕМЫ) ]]
local _, _, themesLeft, themesRight = createTab("Themes", "◆", ASSETS.Themes, "Change the look of the menu")
section(themesLeft, "Choose a theme")
section(themesRight, "Extra")

local themeCards = {}
for index, theme in ipairs(THEMES) do
	local targetCol = (index % 2 == 1) and themesLeft or themesRight
	local button = card(targetCol, 56, "TextButton", theme.Name)

	local swatch = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 12, 0.5, 0),
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = COMMON.White,
		Parent = button,
	})
	corner(swatch, 8)
	create("UIGradient", { Color = ColorSequence.new(theme.Accent, theme.Accent2), Parent = swatch })

	label({
		Position = UDim2.fromOffset(56, 10),
		Size = UDim2.new(1, -70, 0, 18),
		Text = theme.Name,
		Font = FONT_BOLD,
		TextSize = 14,
		Parent = button,
	})
	label({
		Position = UDim2.fromOffset(56, 28),
		Size = UDim2.new(1, -70, 0, 14),
		Text = "Нажми для применения",
		Font = FONT_REGULAR,
		TextSize = 11,
		TextColor3 = theme.IconTint,
		Parent = button,
	})

	button.MouseButton1Click:Connect(function()
		if setTheme(theme.Name) then
			notify("Theme changed", theme.Name, 2.5)
		end
	end)
	table.insert(themeCards, button)
end

toggle(themesRight, nil, "Auto Theme", "Плавная смена цветов каждые 6 сек", false, function(on)
	state.autoThemeEnabled = on
end)

task.spawn(function()
	while gui.Parent do
		task.wait(CONFIG.AutoThemeDelay)
		if state.autoThemeEnabled then
			local nextIndex = (table.find(THEMES, currentTheme) or 0) % #THEMES + 1
			setTheme(THEMES[nextIndex].Name)
		end
	end
end)

-- [[ 5. ВКЛАДКА SETTINGS (НАСТРОЙКИ) ]]
local _, _, setLeft, setRight = createTab("Settings", "⚙", ASSETS.Settings, "Menu look and keys")

section(setLeft, "Menu")
toggle(setLeft, nil, "Snowfall Effect", "Анимация падающего снега в меню", CONFIG.Snowfall, function(on)
	CONFIG.Snowfall = on
	snowLayer.Visible = on
end)
toggle(setLeft, nil, "Blur", "Размытие игры за окном меню", CONFIG.Blur, function(on)
	CONFIG.Blur = on
	updateBlur()
end)
slider(setLeft, "Blur Strength", 1, 30, CONFIG.BlurSize, "", function(val)
	CONFIG.BlurSize = val
	updateBlur()
end)
slider(setLeft, "Window Transparency", 0, 80, math.floor(CONFIG.Transparency * 100 + 0.5), "%", function(val)
	CONFIG.Transparency = val / 100
	main.BackgroundTransparency = CONFIG.Transparency
end)

section(setRight, "Language")
for _, lang in ipairs(LANGUAGES) do
	local b = card(setRight, 38, "TextButton", lang[2])
	label({
		Size = UDim2.fromScale(1, 1),
		Text = lang[2],
		Font = FONT_BOLD,
		TextSize = 13,
		TextXAlignment = Enum.TextXAlignment.Center,
		Parent = b,
	})
	b.MouseButton1Click:Connect(function()
		setLanguage(lang[1])
	end)
end

section(setRight, "Keybinds")
keybind(setRight, "Show / Hide Menu", "ToggleKey", function(k)
	notify("Key changed", k.Name, 2.5)
end)

-- [[ 6. ВКЛАДКА PROFILE (ПРОФИЛЬ) ]]
local _, profileTab, profLeft, profRight = createTab("Profile", "●", ASSETS.Home, "Your account")
section(profLeft, "USER")
paragraph(profLeft, player.DisplayName, "@" .. player.Name .. "  •  ID: " .. player.UserId)
paragraph(profLeft, "Account Age", trf("%d days", player.AccountAge))

section(profRight, "SESSION")
local _, sessionClockLabel = paragraph(profRight, "Time in Snow Hub", "00:00")

profileQuickBtn.MouseButton1Click:Connect(function()
	selectTab(profileTab)
end)

selectTab(tabs[2]) -- Сразу открываем вкладку Aim для удобства

minimizeButton.MouseButton1Click:Connect(function()
	minimized = not minimized
	body.Visible = not minimized
	tween(main, 0.3, { Size = minimized and UDim2.new(1, 0, 0, TOP) or UDim2.fromScale(1, 1) })
	updateBlur()
end)

closeButton.MouseButton1Click:Connect(function()
	setMenuVisible(false)
end)

-- Перетаскивание круглой кнопки ❄
do
	local pressing, moved = false, false
	local pressStart, dockStart
	openButton.InputBegan:Connect(function(input)
		if isPress(input) then
			pressing = true
			moved = false
			pressStart = Vector2.new(input.Position.X, input.Position.Y)
			local vp = camera.ViewportSize
			dockStart = Vector2.new(openDock.Position.X.Scale * vp.X + openDock.Position.X.Offset, openDock.Position.Y.Scale * vp.Y + openDock.Position.Y.Offset)
		end
	end)
	trackConn(UserInputService.InputChanged:Connect(function(input)
		if pressing and isMove(input) then
			local delta = Vector2.new(input.Position.X, input.Position.Y) - pressStart
			if delta.Magnitude >= 6 then moved = true end
			if moved then
				openDock.Position = UDim2.fromOffset(dockStart.X + delta.X, dockStart.Y + delta.Y)
			end
		end
	end))
	trackConn(UserInputService.InputEnded:Connect(function(input)
		if pressing and isPress(input) then pressing = false end
	end))
	openButton.MouseButton1Click:Connect(function()
		if moved then moved = false; return end
		setMenuVisible(not menuVisible)
	end)
end

-- Перетаскивание главного окна за верхнюю панель
do
	local dragging = false
	local dragStart, startPos
	topBar.InputBegan:Connect(function(input)
		if isPress(input) and not hoveringWindowButton then
			dragging = true
			dragStart = input.Position
			startPos = holder.Position
		end
	end)
	trackConn(UserInputService.InputChanged:Connect(function(input)
		if dragging and isMove(input) then
			local delta = input.Position - dragStart
			holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end))
	trackConn(UserInputService.InputEnded:Connect(function(input)
		if isPress(input) then dragging = false end
	end))
end

trackConn(UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed or bindingKey then return end
	if input.KeyCode == CONFIG.ToggleKey then
		setMenuVisible(not menuVisible)
	end
end))

-- Анимация рамки и падающего снега внутри меню
local clock = 0
trackConn(RunService.RenderStepped:Connect(function(dt)
	if not menuVisible then return end
	clock += dt
	if CONFIG.AnimatedBorder then
		for _, gradient in ipairs(spinningGradients) do
			gradient.Rotation = (gradient.Rotation + dt * 70) % 360
		end
	end
	if CONFIG.Snowfall then
		for _, f in ipairs(snowflakes) do
			f.Y += f.SpeedY * dt
			if f.Y > 1.05 then
				f.Y = -0.05
				f.X = math.random()
			end
			local sway = math.sin(clock * 1.8 + f.Phase) * f.Drift
			f.Inst.Position = UDim2.fromScale(f.X + sway, f.Y)
		end
	end
end))

task.spawn(function()
	local seconds = 0
	while gui.Parent do
		sessionClockLabel.Text = string.format("%02d:%02d", math.floor(seconds / 60), math.floor(seconds % 60))
		seconds += task.wait(1)
	end
end)

setMenuVisible(false)
