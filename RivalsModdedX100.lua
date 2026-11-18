local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local MarketplaceService = game:GetService("MarketplaceService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Debris = game:GetService("Debris")

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
			Duration = 6,
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

-- [[ ПАЛИТРА ИЗ НОВОГОДНЕГО МАКЕТА ]]
local PALETTE = {
	Window = Color3.fromRGB(19, 35, 58),       -- #13233A
	Border = Color3.fromRGB(42, 68, 103),      -- #2A4467
	Card = Color3.fromRGB(27, 47, 77),         -- #1B2F4D
	Btn = Color3.fromRGB(29, 51, 84),          -- #1D3354
	TrackOff = Color3.fromRGB(74, 98, 131),    -- #4A6283
	ToggleOn = Color3.fromRGB(47, 158, 107),   -- #2F9E6B
	Title = Color3.fromRGB(221, 241, 255),     -- #DDF1FF
	Text = Color3.fromRGB(234, 244, 255),      -- #EAF4FF
	SubText = Color3.fromRGB(169, 188, 211),   -- #A9BCD3
	TabText = Color3.fromRGB(199, 215, 234),   -- #C7D7EA
	Gold = Color3.fromRGB(244, 201, 93),       -- #F4C95D
	White = Color3.new(1, 1, 1),
	Green = Color3.fromRGB(47, 158, 107),
	Red = Color3.fromRGB(229, 72, 77),
	Blue = Color3.fromRGB(94, 184, 255),
}

local ACCENTS = {
	{ Name = "Red", Label = "Красный", Color = Color3.fromRGB(229, 72, 77), Button = Color3.fromRGB(200, 50, 58) },
	{ Name = "Green", Label = "Зелёный", Color = Color3.fromRGB(47, 158, 107), Button = Color3.fromRGB(38, 134, 90) },
	{ Name = "Gold", Label = "Золотой", Color = Color3.fromRGB(244, 201, 93), Button = Color3.fromRGB(198, 152, 42) },
	{ Name = "Blue", Label = "Голубой", Color = Color3.fromRGB(94, 184, 255), Button = Color3.fromRGB(46, 136, 214) },
}

local CONFIG = {
	Title = "SNOW HUB",
	Subtitle = "Rivals New Year",
	Version = "v9.0",
	ToggleKey = Enum.KeyCode.G,
	HideAllKey = Enum.KeyCode.P,
	Accent = "Red",
	Width = 880,
	Height = 560,
	Transparency = 0.08,
	MenuScale = 1.0,
	Blur = true,
	BlurSize = 10,
	Snowfall = true,
	Garland = true,
	ButtonSounds = true,
	SoundVolume = 0.6,
	CompactMode = false,
	Notifications = true,
}
local CONFIG_DEFAULTS = table.clone(CONFIG)

local currentAccent = ACCENTS[1]
local accentHooks = {}

local function onAccent(hook)
	table.insert(accentHooks, hook)
	hook(true)
end

local function setAccent(name)
	for _, a in ipairs(ACCENTS) do
		if a.Name == name then
			currentAccent = a
			CONFIG.Accent = name
			for _, hook in ipairs(accentHooks) do
				hook(false)
			end
			return true
		end
	end
	return false
end

local state = {
	onClose = {},
	connections = {},
	uiRefreshers = {},
	allHidden = false,
	saveAll = nil,
	resetAll = nil,
	setStealth = nil,
}

local function trackConn(conn)
	if conn then
		table.insert(state.connections, conn)
	end
	return conn
end

local function applyFont(inst, weight)
	local ok = pcall(function()
		local w = Enum.FontWeight.Medium
		if weight == "ExtraBold" then w = Enum.FontWeight.ExtraBold
		elseif weight == "Bold" then w = Enum.FontWeight.Bold
		elseif weight == "SemiBold" then w = Enum.FontWeight.SemiBold
		end
		inst.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", w, Enum.FontStyle.Normal)
	end)
	if not ok then
		inst.Font = (weight == "Bold" or weight == "ExtraBold") and Enum.Font.GothamBold or Enum.Font.GothamMedium
	end
end

local function create(className, props)
	local inst = Instance.new(className)
	if inst:IsA("GuiObject") then
		inst.BorderSizePixel = 0
	end
	local parent = props.Parent
	local weight = props._Weight
	props.Parent = nil
	props._Weight = nil
	for k, v in pairs(props) do
		inst[k] = v
	end
	if weight and (inst:IsA("TextLabel") or inst:IsA("TextButton") or inst:IsA("TextBox")) then
		applyFont(inst, weight)
	end
	inst.Parent = parent
	return inst
end

local function tween(obj, dur, goal, style, dir)
	local t = TweenService:Create(obj, TweenInfo.new(dur, style or Enum.EasingStyle.Quint, dir or Enum.EasingDirection.Out), goal)
	t:Play()
	return t
end

local function corner(parent, r)
	return create("UICorner", { CornerRadius = UDim.new(0, r or 12), Parent = parent })
end

local function round(parent)
	return create("UICorner", { CornerRadius = UDim.new(1, 0), Parent = parent })
end

local function stroke(parent, color, thickness, transparency)
	return create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Color = color or PALETTE.Border,
		Thickness = thickness or 1.5,
		Transparency = transparency or 0,
		Parent = parent,
	})
end

local function padding(parent, t, r, b, l)
	return create("UIPadding", {
		PaddingTop = UDim.new(0, t or 0),
		PaddingRight = UDim.new(0, r or 0),
		PaddingBottom = UDim.new(0, b or 0),
		PaddingLeft = UDim.new(0, l or 0),
		Parent = parent,
	})
end

local function label(props)
	props.BackgroundTransparency = 1
	props.TextColor3 = props.TextColor3 or PALETTE.Text
	props.TextSize = props.TextSize or 14
	props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
	props._Weight = props._Weight or "SemiBold"
	return create("TextLabel", props)
end

local function isPress(input)
	return input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch
end

local function isMove(input)
	return input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch
end

local GUI_NAME = "SnowHub_NewYear_v9"

local function getSafeGuiParent()
	local okHui, hui = pcall(function() return gethui and gethui() end)
	if okHui and hui then return hui end
	local okCg, cg = pcall(function() return game:GetService("CoreGui") end)
	if okCg and cg then return cg end
	return playerGui
end
local guiParent = getSafeGuiParent()

for _, oldName in ipairs({ GUI_NAME, "SnowHub_Unique_v8", "SnowHub_v7.1", "RivalsModded_Unique_v7", "AimHud", "AimESP" }) do
	local found = guiParent:FindFirstChild(oldName) or playerGui:FindFirstChild(oldName)
	if found then pcall(function() found:Destroy() end) end
	local oldBlur = Lighting:FindFirstChild(oldName .. "_Blur")
	if oldBlur then pcall(function() oldBlur:Destroy() end) end
end

local gui = create("ScreenGui", {
	Name = GUI_NAME,
	ResetOnSpawn = false,
	IgnoreGuiInset = true,
	ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
	DisplayOrder = 10000,
	Parent = guiParent,
})
pcall(function() gui.ScreenInsets = Enum.ScreenInsets.None end)

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

local function playClick()
	if not CONFIG.ButtonSounds or state.allHidden or CONFIG.SoundVolume <= 0 then return end
	pcall(function()
		local s = Instance.new("Sound")
		s.SoundId = "rbxassetid://6895079853"
		s.Volume = CONFIG.SoundVolume * 0.35
		s.PlaybackSpeed = 1.05
		s.Parent = gui
		s:Play()
		Debris:AddItem(s, 0.5)
	end)
end

-- [[ УВЕДОМЛЕНИЯ ]]
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
	if not CONFIG.Notifications or state.allHidden then return end
	duration = duration or 3
	toastCount += 1

	local wrap = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		BackgroundTransparency = 1,
		LayoutOrder = toastCount,
		Parent = toastHolder,
	})
	local toast = create("TextButton", {
		Position = UDim2.fromOffset(320, 0),
		Size = UDim2.new(1, 0, 0, 62),
		BackgroundColor3 = PALETTE.Window,
		BackgroundTransparency = 0.04,
		AutoButtonColor = false,
		Text = "",
		Parent = wrap,
	})
	corner(toast, 14)
	stroke(toast, currentAccent.Color, 1.8, 0.15)

	label({
		Position = UDim2.fromOffset(14, 9),
		Size = UDim2.new(1, -28, 0, 18),
		Text = "❄ " .. title,
		TextSize = 14,
		TextColor3 = PALETTE.Title,
		_Weight = "ExtraBold",
		Parent = toast,
	})
	label({
		Position = UDim2.fromOffset(14, 30),
		Size = UDim2.new(1, -28, 0, 16),
		Text = text,
		TextSize = 12,
		TextColor3 = PALETTE.SubText,
		Parent = toast,
	})

	tween(wrap, 0.28, { Size = UDim2.new(1, 0, 0, 62) })
	tween(toast, 0.4, { Position = UDim2.fromOffset(0, 0) }, Enum.EasingStyle.Back)

	local closed = false
	local function close()
		if closed then return end
		closed = true
		local anim = tween(toast, 0.3, { Position = UDim2.fromOffset(320, 0) }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		anim.Completed:Connect(function()
			if wrap.Parent then wrap:Destroy() end
		end)
	end
	toast.MouseButton1Click:Connect(close)
	task.delay(duration, close)
end

-- [[ ГЛАВНОЕ ОКНО (ДИЗАЙН ПО МАКЕТУ) ]]
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

local TOP_H = 88
local SIDEBAR_W = 192

local main = create("Frame", {
	Name = "Main",
	Size = UDim2.fromScale(1, 1),
	BackgroundColor3 = PALETTE.Window,
	BackgroundTransparency = CONFIG.Transparency,
	ClipsDescendants = true,
	Active = true,
	ZIndex = 2,
	Parent = window,
})
corner(main, 24)
stroke(main, PALETTE.Border, 2, 0)

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

-- [[ ПАДАЮЩИЙ СНЕГ В ОКНЕ ]]
local snowLayer = create("Frame", {
	Name = "SnowLayer",
	Size = UDim2.fromScale(1, 1),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	ZIndex = 2,
	Visible = CONFIG.Snowfall,
	Parent = main,
})

local snowflakes = {}
for _ = 1, 24 do
	local sz = math.random(4, 10)
	local flake = create("Frame", {
		Position = UDim2.fromScale(math.random(), math.random()),
		Size = UDim2.fromOffset(sz, sz),
		BackgroundColor3 = PALETTE.Title,
		BackgroundTransparency = math.random(45, 78) / 100,
		Parent = snowLayer,
	})
	round(flake)
	table.insert(snowflakes, {
		Inst = flake,
		X = flake.Position.X.Scale,
		Y = flake.Position.Y.Scale,
		SpeedY = math.random(4, 10) / 100,
		Drift = math.random(12, 34) / 1000,
		Phase = math.random() * 6.28,
	})
end

-- [[ ГИРЛЯНДА НА ОКНЕ ]]
local garlandFrame = create("Frame", {
	Name = "Garland",
	Position = UDim2.fromOffset(0, 0),
	Size = UDim2.new(1, 0, 0, 44),
	BackgroundTransparency = 1,
	ZIndex = 6,
	Visible = CONFIG.Garland,
	Parent = main,
})

local garlandBulbs = {}
do
	local arches = 8
	local archW = CONFIG.Width / arches
	local bulbColors = { PALETTE.Red, PALETTE.Gold, PALETTE.Blue }
	local segSteps = 7

	local function bezierY(t)
		-- P0=7, P1=33, P2=7
		return ((1 - t) ^ 2) * 7 + 2 * (1 - t) * t * 33 + (t ^ 2) * 7
	end

	for a = 0, arches - 1 do
		local xStart = a * archW
		for s = 0, segSteps - 1 do
			local t1 = s / segSteps
			local t2 = (s + 1) / segSteps
			local p1 = Vector2.new(xStart + t1 * archW, bezierY(t1))
			local p2 = Vector2.new(xStart + t2 * archW, bezierY(t2))
			local mid = (p1 + p2) * 0.5
			local diff = p2 - p1

			local seg = create("Frame", {
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(mid.X / CONFIG.Width, 0, 0, mid.Y),
				Size = UDim2.fromOffset(diff.Magnitude + 1.5, 3),
				Rotation = math.deg(math.atan2(diff.Y, diff.X)),
				BackgroundColor3 = PALETTE.Green,
				ZIndex = 6,
				Parent = garlandFrame,
			})
			round(seg)
		end

		local bx = (xStart + archW * 0.5) / CONFIG.Width
		local col = bulbColors[(a % #bulbColors) + 1]

		local halo = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(bx, 0, 0, 24),
			Size = UDim2.fromOffset(20, 20),
			BackgroundColor3 = col,
			BackgroundTransparency = 0.68,
			ZIndex = 6,
			Parent = garlandFrame,
		})
		round(halo)

		local bulb = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(bx, 0, 0, 24),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = col,
			ZIndex = 7,
			Parent = garlandFrame,
		})
		round(bulb)

		table.insert(garlandBulbs, { Halo = halo, Bulb = bulb, Phase = a * 0.9 })
	end
end

-- [[ ШАПКА ОКНА ]]
local topBar = create("Frame", {
	Name = "TopBar",
	Position = UDim2.fromOffset(0, 38),
	Size = UDim2.new(1, 0, 0, 50),
	BackgroundTransparency = 1,
	ZIndex = 5,
	Parent = main,
})

local titleRow = create("Frame", {
	Position = UDim2.fromOffset(24, 0),
	Size = UDim2.new(0, 460, 1, 0),
	BackgroundTransparency = 1,
	Parent = topBar,
})
create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 10),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = titleRow,
})

label({
	Size = UDim2.fromOffset(30, 30),
	Text = "❄",
	TextSize = 26,
	TextColor3 = PALETTE.Title,
	TextXAlignment = Enum.TextXAlignment.Center,
	_Weight = "ExtraBold",
	LayoutOrder = 1,
	Parent = titleRow,
})

label({
	Size = UDim2.fromOffset(0, 28),
	AutomaticSize = Enum.AutomaticSize.X,
	Text = CONFIG.Title,
	TextSize = 20,
	TextColor3 = PALETTE.Text,
	_Weight = "ExtraBold",
	LayoutOrder = 2,
	Parent = titleRow,
})

local verPill = create("Frame", {
	Size = UDim2.fromOffset(0, 22),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundColor3 = PALETTE.Btn,
	LayoutOrder = 3,
	Parent = titleRow,
})
round(verPill)
padding(verPill, 0, 10, 0, 10)
local verLbl = label({
	Size = UDim2.fromScale(0, 1),
	AutomaticSize = Enum.AutomaticSize.X,
	Text = CONFIG.Subtitle .. " " .. CONFIG.Version,
	TextSize = 11,
	TextColor3 = PALETTE.Gold,
	_Weight = "ExtraBold",
	Parent = verPill,
})

local statusPill = create("Frame", {
	Size = UDim2.fromOffset(0, 22),
	AutomaticSize = Enum.AutomaticSize.X,
	BackgroundColor3 = PALETTE.Btn,
	LayoutOrder = 4,
	Parent = titleRow,
})
round(statusPill)
padding(statusPill, 0, 10, 0, 10)
local statusLabel = label({
	Size = UDim2.fromScale(0, 1),
	AutomaticSize = Enum.AutomaticSize.X,
	Text = "● Активен",
	TextSize = 11,
	TextColor3 = PALETTE.Green,
	_Weight = "ExtraBold",
	Parent = statusPill,
})

local hoveringTopBtn = false
local function makeTopBtn(text, offsetRight)
	local b = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, offsetRight, 0.5, 0),
		Size = UDim2.fromOffset(38, 38),
		BackgroundColor3 = PALETTE.Btn,
		AutoButtonColor = false,
		Text = text,
		TextSize = 18,
		TextColor3 = PALETTE.Text,
		_Weight = "ExtraBold",
		Parent = topBar,
	})
	corner(b, 12)
	b.MouseEnter:Connect(function()
		hoveringTopBtn = true
		tween(b, 0.18, { BackgroundColor3 = PALETTE.Border })
	end)
	b.MouseLeave:Connect(function()
		hoveringTopBtn = false
		tween(b, 0.18, { BackgroundColor3 = PALETTE.Btn })
	end)
	return b
end

local closeButton = makeTopBtn("×", -24)
local minimizeButton = makeTopBtn("—", -70)

-- [[ ОСНОВНОЕ ТЕЛО ОКНА ]]
local body = create("Frame", {
	Name = "Body",
	Position = UDim2.fromOffset(0, TOP_H + 6),
	Size = UDim2.new(1, 0, 1, -(TOP_H + 6)),
	BackgroundTransparency = 1,
	ZIndex = 4,
	Parent = main,
})
padding(body, 0, 24, 18, 24)

-- Левый сайдбар с вкладками (как в макете)
local sidebar = create("Frame", {
	Name = "Sidebar",
	Size = UDim2.new(0, SIDEBAR_W, 1, 0),
	BackgroundTransparency = 1,
	Parent = body,
})
create("UIListLayout", {
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = sidebar,
})

-- Правая область: контент + нижний футер с цветами акцента и кнопками Сбросить/Сохранить
local rightArea = create("Frame", {
	Name = "RightArea",
	Position = UDim2.fromOffset(SIDEBAR_W + 18, 0),
	Size = UDim2.new(1, -(SIDEBAR_W + 18), 1, 0),
	BackgroundTransparency = 1,
	Parent = body,
})

local FOOTER_H = 48
local pagesHolder = create("Frame", {
	Name = "Pages",
	Size = UDim2.new(1, 0, 1, -(FOOTER_H + 12)),
	BackgroundTransparency = 1,
	ClipsDescendants = true,
	Parent = rightArea,
})

local footer = create("Frame", {
	Name = "Footer",
	AnchorPoint = Vector2.new(0, 1),
	Position = UDim2.fromScale(0, 1),
	Size = UDim2.new(1, 0, 0, FOOTER_H),
	BackgroundTransparency = 1,
	Parent = rightArea,
})

-- Цвета акцента слева в футере
local accentRow = create("Frame", {
	Size = UDim2.new(0, 320, 1, 0),
	BackgroundTransparency = 1,
	Parent = footer,
})
create("UIListLayout", {
	FillDirection = Enum.FillDirection.Horizontal,
	VerticalAlignment = Enum.VerticalAlignment.Center,
	Padding = UDim.new(0, 8),
	SortOrder = Enum.SortOrder.LayoutOrder,
	Parent = accentRow,
})

label({
	Size = UDim2.fromOffset(0, 20),
	AutomaticSize = Enum.AutomaticSize.X,
	Text = "Цвет акцента",
	TextSize = 13,
	TextColor3 = PALETTE.SubText,
	LayoutOrder = 1,
	Parent = accentRow,
})

local accentButtons = {}
for idx, acc in ipairs(ACCENTS) do
	local circleBtn = create("TextButton", {
		Size = UDim2.fromOffset(34, 34),
		BackgroundColor3 = acc.Color,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = idx + 1,
		Parent = accentRow,
	})
	round(circleBtn)
	local s = stroke(circleBtn, PALETTE.White, 2.5, acc.Name == CONFIG.Accent and 0 or 1)
	table.insert(accentButtons, { Name = acc.Name, Stroke = s })
	circleBtn.MouseButton1Click:Connect(function()
		playClick()
		setAccent(acc.Name)
		if state.saveAll then state.saveAll(true) end
	end)
end

onAccent(function(instant)
	for _, b in ipairs(accentButtons) do
		local active = b.Name == currentAccent.Name
		if instant then
			b.Stroke.Transparency = active and 0 or 1
		else
			tween(b.Stroke, 0.2, { Transparency = active and 0 or 1 })
		end
	end
end)

-- Кнопки "Сбросить" и "Сохранить" справа в футере
local saveBtn = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, 0, 0.5, 0),
	Size = UDim2.fromOffset(124, 42),
	BackgroundColor3 = currentAccent.Button,
	AutoButtonColor = false,
	Text = "Сохранить",
	TextSize = 14,
	TextColor3 = PALETTE.White,
	_Weight = "ExtraBold",
	Parent = footer,
})
corner(saveBtn, 14)
onAccent(function(instant)
	if instant then
		saveBtn.BackgroundColor3 = currentAccent.Button
	else
		tween(saveBtn, 0.25, { BackgroundColor3 = currentAccent.Button })
	end
end)

local resetBtn = create("TextButton", {
	AnchorPoint = Vector2.new(1, 0.5),
	Position = UDim2.new(1, -134, 0.5, 0),
	Size = UDim2.fromOffset(112, 42),
	BackgroundColor3 = PALETTE.Window,
	BackgroundTransparency = 1,
	AutoButtonColor = false,
	Text = "Сбросить",
	TextSize = 14,
	TextColor3 = PALETTE.Text,
	_Weight = "Bold",
	Parent = footer,
})
corner(resetBtn, 14)
stroke(resetBtn, PALETTE.TrackOff, 2, 0)

saveBtn.MouseButton1Click:Connect(function()
	playClick()
	if state.saveAll then
		state.saveAll(false)
	end
end)

resetBtn.MouseButton1Click:Connect(function()
	playClick()
	if state.resetAll then
		state.resetAll()
	end
end)

-- [[ КОНСТРУКТОР ВКЛАДОК, КАРТОЧЕК И ВИДЖЕТОВ ]]
local tabs = {}
local selectedTab = nil
local orderCounter = 0
local function nextOrder()
	orderCounter += 1
	return orderCounter
end

local function refreshTabs(dur)
	for _, tab in ipairs(tabs) do
		local active = (tab == selectedTab)
		tween(tab.Button, dur, {
			BackgroundTransparency = active and 0 or 1,
			BackgroundColor3 = currentAccent.Button,
		})
		tween(tab.Label, dur, { TextColor3 = active and PALETTE.White or PALETTE.TabText })
		tween(tab.Icon, dur, { TextColor3 = active and PALETTE.White or PALETTE.TabText })
	end
end
onAccent(function(instant)
	refreshTabs(instant and 0 or 0.25)
end)

local function selectTab(tab)
	if selectedTab == tab then return end
	selectedTab = tab
	for _, other in ipairs(tabs) do
		other.Page.Visible = (other == tab)
	end
	refreshTabs(0.22)
	tab.Page.CanvasPosition = Vector2.new(0, 0)
end

local function createTab(title, iconGlyph)
	local btn = create("TextButton", {
		Name = title,
		Size = UDim2.new(1, 0, 0, 46),
		BackgroundColor3 = currentAccent.Button,
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = nextOrder(),
		Parent = sidebar,
	})
	corner(btn, 14)

	local icon = label({
		Position = UDim2.fromOffset(14, 0),
		Size = UDim2.new(0, 24, 1, 0),
		Text = iconGlyph,
		TextSize = 17,
		TextColor3 = PALETTE.TabText,
		TextXAlignment = Enum.TextXAlignment.Center,
		_Weight = "Bold",
		Parent = btn,
	})
	local txt = label({
		Position = UDim2.fromOffset(44, 0),
		Size = UDim2.new(1, -54, 1, 0),
		Text = title,
		TextSize = 15,
		TextColor3 = PALETTE.TabText,
		_Weight = "Bold",
		Parent = btn,
	})

	local page = create("ScrollingFrame", {
		Name = title,
		Size = UDim2.fromScale(1, 1),
		BackgroundTransparency = 1,
		CanvasSize = UDim2.new(),
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
		ScrollingDirection = Enum.ScrollingDirection.Y,
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = PALETTE.TrackOff,
		VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
		Visible = false,
		Parent = pagesHolder,
	})
	create("UIListLayout", {
		Padding = UDim.new(0, 12),
		SortOrder = Enum.SortOrder.LayoutOrder,
		Parent = page,
	})
	padding(page, 2, 8, 8, 2)

	local tab = { Name = title, Button = btn, Icon = icon, Label = txt, Page = page }
	table.insert(tabs, tab)

	btn.MouseButton1Click:Connect(function()
		playClick()
		selectTab(tab)
	end)

	return page, tab
end

-- Двухколоночная строка карточек (как верхний блок макета)
local function createTwoCards(page, leftTitle, rightTitle)
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
		Parent = page,
	})

	local function buildCol(title, pos, anchor)
		local box = create("Frame", {
			AnchorPoint = anchor,
			Position = pos,
			Size = UDim2.new(0.5, -7, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = PALETTE.Card,
			Parent = row,
		})
		corner(box, 18)
		padding(box, 14, 16, 14, 16)
		create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = box })
		label({
			Size = UDim2.new(1, 0, 0, 22),
			Text = title,
			TextSize = 15,
			TextColor3 = PALETTE.Title,
			_Weight = "ExtraBold",
			LayoutOrder = nextOrder(),
			Parent = box,
		})
		return box
	end

	return buildCol(leftTitle, UDim2.fromScale(0, 0), Vector2.new(0, 0)),
		buildCol(rightTitle, UDim2.fromScale(1, 0), Vector2.new(1, 0))
end

-- Полноширинная карточка (как блок "Настройка окна" со слайдерами)
local function createFullCard(page, title)
	local box = create("Frame", {
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		BackgroundColor3 = PALETTE.Card,
		LayoutOrder = nextOrder(),
		Parent = page,
	})
	corner(box, 18)
	padding(box, 14, 16, 14, 16)
	create("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder, Parent = box })
	if title and title ~= "" then
		label({
			Size = UDim2.new(1, 0, 0, 22),
			Text = title,
			TextSize = 15,
			TextColor3 = PALETTE.Title,
			_Weight = "ExtraBold",
			LayoutOrder = nextOrder(),
			Parent = box,
		})
	end
	return box
end

local function addInfoText(cardBox, text, color)
	return label({
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Text = text,
		TextWrapped = true,
		TextSize = 13,
		TextColor3 = color or PALETTE.SubText,
		LayoutOrder = nextOrder(),
		Parent = cardBox,
	})
end

local function addToggle(cardBox, title, default, callback)
	local row = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = nextOrder(),
		Parent = cardBox,
	})
	label({
		Size = UDim2.new(1, -60, 1, 0),
		Text = title,
		TextSize = 14,
		TextColor3 = PALETTE.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})

	local track = create("Frame", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(48, 28),
		BackgroundColor3 = default and PALETTE.ToggleOn or PALETTE.TrackOff,
		Parent = row,
	})
	round(track)

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = default and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
		Size = UDim2.fromOffset(22, 22),
		BackgroundColor3 = PALETTE.White,
		Parent = track,
	})
	round(knob)

	local isOn = default == true
	local function render(dur)
		tween(track, dur, { BackgroundColor3 = isOn and PALETTE.ToggleOn or PALETTE.TrackOff })
		tween(knob, dur, { Position = isOn and UDim2.new(1, -25, 0.5, 0) or UDim2.new(0, 3, 0.5, 0) }, Enum.EasingStyle.Back)
	end

	local api = {}
	function api.Set(val)
		isOn = val == true
		render(0.22)
		if callback then task.spawn(callback, isOn) end
	end
	function api.Sync(val)
		val = val == true
		if val ~= isOn then
			isOn = val
			render(0.18)
		end
	end
	function api.Get() return isOn end

	row.MouseButton1Click:Connect(function()
		playClick()
		api.Set(not isOn)
	end)
	return api
end

local function addSlider(cardBox, title, minV, maxV, default, suffix, callback, formatter)
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 32),
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
		Parent = cardBox,
	})

	label({
		Size = UDim2.new(0, 175, 1, 0),
		Text = title,
		TextSize = 14,
		TextColor3 = PALETTE.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})

	local valLbl = label({
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.fromScale(1, 0),
		Size = UDim2.new(0, 58, 1, 0),
		Text = "",
		TextSize = 14,
		TextColor3 = PALETTE.Gold,
		TextXAlignment = Enum.TextXAlignment.Right,
		_Weight = "ExtraBold",
		Parent = row,
	})

	local hitbox = create("TextButton", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 182, 0.5, 0),
		Size = UDim2.new(1, -246, 0, 24),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		Parent = row,
	})

	local track = create("Frame", {
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.new(1, 0, 0, 6),
		BackgroundColor3 = PALETTE.TrackOff,
		Parent = hitbox,
	})
	round(track)

	local fill = create("Frame", {
		Size = UDim2.fromScale(0, 1),
		BackgroundColor3 = currentAccent.Color,
		Parent = track,
	})
	round(fill)

	local knob = create("Frame", {
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0, 0.5),
		Size = UDim2.fromOffset(16, 16),
		BackgroundColor3 = PALETTE.White,
		ZIndex = 2,
		Parent = track,
	})
	round(knob)
	local knobStroke = stroke(knob, currentAccent.Color, 2, 0)

	onAccent(function(instant)
		if instant then
			fill.BackgroundColor3 = currentAccent.Color
			knobStroke.Color = currentAccent.Color
		else
			tween(fill, 0.25, { BackgroundColor3 = currentAccent.Color })
			tween(knobStroke, 0.25, { Color = currentAccent.Color })
		end
	end)

	local value = math.clamp(default, minV, maxV)
	local function render(dur)
		local alpha = (value - minV) / math.max(maxV - minV, 1)
		tween(fill, dur, { Size = UDim2.fromScale(alpha, 1) })
		tween(knob, dur, { Position = UDim2.fromScale(alpha, 0.5) })
		valLbl.Text = formatter and formatter(value) or (value .. (suffix or ""))
	end
	render(0)

	local api = {}
	function api.Set(newV)
		newV = math.clamp(math.floor(newV + 0.5), minV, maxV)
		if newV == value then return end
		value = newV
		render(0.08)
		if callback then task.spawn(callback, value) end
	end
	function api.Sync(newV)
		newV = math.clamp(math.floor(newV + 0.5), minV, maxV)
		if newV ~= value then
			value = newV
			render(0.08)
		end
	end
	function api.Get() return value end

	local sliding = false
	local function slideTo(input)
		local a = math.clamp((input.Position.X - track.AbsolutePosition.X) / math.max(track.AbsoluteSize.X, 1), 0, 1)
		api.Set(minV + (maxV - minV) * a)
	end
	hitbox.InputBegan:Connect(function(input)
		if isPress(input) then
			sliding = true
			slideTo(input)
		end
	end)
	trackConn(UserInputService.InputChanged:Connect(function(input)
		if sliding and isMove(input) then slideTo(input) end
	end))
	trackConn(UserInputService.InputEnded:Connect(function(input)
		if sliding and isPress(input) then sliding = false end
	end))
	return api
end

local function addChoice(cardBox, title, options, getter, setter)
	local row = create("TextButton", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		AutoButtonColor = false,
		Text = "",
		LayoutOrder = nextOrder(),
		Parent = cardBox,
	})
	label({
		Size = UDim2.new(1, -110, 1, 0),
		Text = title,
		TextSize = 14,
		TextColor3 = PALETTE.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})
	local pill = create("TextLabel", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(102, 28),
		BackgroundColor3 = PALETTE.Btn,
		Text = "",
		TextSize = 12,
		TextColor3 = PALETTE.Gold,
		_Weight = "ExtraBold",
		Parent = row,
	})
	corner(pill, 9)

	local function sync()
		local cur = getter()
		for _, opt in ipairs(options) do
			if opt[1] == cur then
				pill.Text = opt[2] .. " ▾"
				return
			end
		end
	end
	row.MouseButton1Click:Connect(function()
		playClick()
		local cur = getter()
		local idx = 1
		for i, opt in ipairs(options) do
			if opt[1] == cur then idx = i end
		end
		setter(options[(idx % #options) + 1][1])
		sync()
	end)
	sync()
	return { Sync = sync }
end

local bindingKey = false
local function addKeybind(cardBox, title, configKey)
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 36),
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
		Parent = cardBox,
	})
	label({
		Size = UDim2.new(1, -110, 1, 0),
		Text = title,
		TextSize = 14,
		TextColor3 = PALETTE.Text,
		TextTruncate = Enum.TextTruncate.AtEnd,
		Parent = row,
	})
	local btn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.fromOffset(96, 28),
		BackgroundColor3 = PALETTE.Btn,
		AutoButtonColor = false,
		Text = CONFIG[configKey].Name,
		TextSize = 12,
		TextColor3 = PALETTE.Gold,
		_Weight = "ExtraBold",
		Parent = row,
	})
	corner(btn, 9)
	local bStroke = stroke(btn, PALETTE.Border, 1.5, 0.3)

	local waiting = false
	btn.MouseButton1Click:Connect(function()
		if waiting then return end
		playClick()
		waiting = true
		bindingKey = true
		btn.Text = "Жми..."
		tween(bStroke, 0.2, { Color = currentAccent.Color, Transparency = 0 })

		local conn
		conn = UserInputService.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
			conn:Disconnect()
			waiting = false
			local k = input.KeyCode
			if k ~= Enum.KeyCode.Escape and k ~= Enum.KeyCode.Unknown then
				CONFIG[configKey] = k
				notify("Бинд обновлён", title .. ": " .. k.Name, 2.5)
			end
			btn.Text = CONFIG[configKey].Name
			tween(bStroke, 0.2, { Color = PALETTE.Border, Transparency = 0.3 })
			task.delay(0.2, function() bindingKey = false end)
		end)
	end)
	return {
		Sync = function()
			btn.Text = CONFIG[configKey].Name
		end,
	}
end

-- [[ УПРАВЛЕНИЕ РАЗМЕРОМ, РАЗМЫТИЕМ И ОТКРЫТИЕМ ]]
local menuVisible = false
local minimized = false

local function updateBlur()
	local target = (CONFIG.Blur and menuVisible and not minimized and not state.allHidden) and CONFIG.BlurSize or 0
	tween(blur, 0.3, { Size = target })
end

local function fitToScreen()
	local vp = camera.ViewportSize
	local autoFit = math.min((vp.X - 36) / CONFIG.Width, (vp.Y - 36) / CONFIG.Height, 1)
	fitScale.Scale = math.clamp(autoFit * CONFIG.MenuScale, 0.45, 1.35)
end
fitToScreen()
trackConn(camera:GetPropertyChangedSignal("ViewportSize"):Connect(fitToScreen))

-- Плавающая круглая кнопка ❄ слева
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
	BackgroundColor3 = PALETTE.Window,
	BackgroundTransparency = 0.06,
	AutoButtonColor = false,
	Text = "❄",
	TextSize = 23,
	TextColor3 = PALETTE.Title,
	_Weight = "ExtraBold",
	Parent = openDock,
})
round(openButton)
local openStroke = stroke(openButton, currentAccent.Color, 2.2, 0)
onAccent(function(instant)
	if instant then openStroke.Color = currentAccent.Color
	else tween(openStroke, 0.25, { Color = currentAccent.Color }) end
end)

local function setMenuVisible(visible)
	if state.allHidden then visible = false end
	if menuVisible == visible then return end
	menuVisible = visible
	state.freeMouse.Visible = visible
	if visible then
		holder.Visible = true
		tween(popScale, 0.36, { Scale = 1 }, Enum.EasingStyle.Back)
	else
		local closing = tween(popScale, 0.22, { Scale = 0 }, Enum.EasingStyle.Back, Enum.EasingDirection.In)
		closing.Completed:Connect(function(ps)
			if ps == Enum.PlaybackState.Completed and not menuVisible then
				holder.Visible = false
			end
		end)
	end
	updateBlur()
end

-- [[ СОЗДАЁМ 6 ВКЛАДОК ]]
local homePage = createTab("Главная", "⌂")
local aimPage = createTab("Аимбот", "◎")
local espPage = createTab("Визуал", "◉")
local movePage = createTab("Движение", "⚡")
local setPage = createTab("Настройки", "⚙")
local profPage = createTab("Профиль", "●")

-- [[ 1. ВКЛАДКА ГЛАВНАЯ ]]
local homeSessionLbl
do
	local function newYearDays()
		local now = os.date("*t")
		local today = os.time({ year = now.year, month = now.month, day = now.day, hour = 0 })
		local target = os.time({ year = now.year + 1, month = 1, day = 1, hour = 0 })
		local d = math.max(0, math.floor((target - today) / 86400 + 0.5))
		return d == 0 and "Сегодня Новый год!" or ("До Нового года: " .. d .. " дн.")
	end

	local cLeft, cRight = createTwoCards(homePage, "С Новым годом, " .. player.DisplayName .. "!", "Управление")
	addInfoText(cLeft, "Новогоднее издание Snow Hub " .. CONFIG.Version .. " для Rivals.", PALETTE.Text)
	addInfoText(cLeft, newYearDays(), PALETTE.Gold)
	homeSessionLbl = addInfoText(cLeft, "В игре: 00:00", PALETTE.SubText)

	addInfoText(cRight, "• G или кнопка ❄ — открыть / закрыть меню", PALETTE.Text)
	addInfoText(cRight, "• P (англ.) — стелс-режим (скрывает всё, аим работает на ПКМ)", PALETTE.Text)
	addInfoText(cRight, "• F — вкл/выкл аим | V — автострел", PALETTE.SubText)
end

-- [[ 2–4. ЯДРО AIM, ESP, ДВИЖЕНИЯ И QUICK BAR ]]
local function setupCombatAndESP()
	local function detectMobile()
		if playerGui:FindFirstChild("TouchGui") ~= nil then return true end
		if UserInputService.KeyboardEnabled and UserInputService.MouseEnabled then return false end
		return UserInputService.TouchEnabled or UserInputService.AccelerometerEnabled or UserInputService.GyroscopeEnabled
	end

	-- На ПК аим сквозь стены изначально ВКЛ, на телефоне — ВЫКЛ
	local initialMobile = detectMobile()

	local AIM = {
		AimMode = "Override",
		DeviceMode = "Auto",
		AimPart = "Head",
		FOV = 160,
		Smoothness = 0.85,
		InstantSnap = true,
		Prediction = 0,
		StickyTarget = true,
		LockGrace = 0.2,
		HoldToAim = true,
		AimThroughWalls = not initialMobile,
		WallCheck = initialMobile,
		HoldThroughWalls = false,
		AutoShoot = "All",
		AutoShootAngle = 10,
		AutoShootDelay = 0,
		AutoShootKey = Enum.KeyCode.V,
		KnifeAuto = true,
		KnifeAutoRange = 7,
		KnifeAutoCooldown = 1.25,
		NoCameraShake = true,
		ShowQuickBar = true,
		BunnyHop = false,
		CrouchSpam = false,
		SmartESPColors = true,
		TeamCheck = true,
		TeamMode = "Auto",
		ShowFOV = true,
		ShowTargetInfo = true,
		HeadOnly = true,
		AimHeight = 0.2,
		FreezeMouse = true,
		TurnBody = true,
		BodyMaxSpeed = 540,
		BodyResponsiveness = 25,
		ESP = true,
		ESPHighlight = true,
		ESPNames = true,
		ESPShowWeapon = true,
		ESPDistance = true,
		ESPHealth = true,
		ESPTracers = false,
		ESPTeammates = true,
		ESPMaxDistance = 1500,
		ToggleKey = Enum.KeyCode.F,
		AimHoldButton = Enum.UserInputType.MouseButton2,
		SnapKey = Enum.KeyCode.X,
	}
	local AIM_DEFAULTS = table.clone(AIM)

	local enabled = true
	local holding = false
	local lockedPart, lockedTarget, aimLook = nil, nil, nil
	local releaseBody = function() end
	local freezeMouse = function() end

	local function isMobileDevice()
		if AIM.DeviceMode == "Mobile" then return true end
		if AIM.DeviceMode == "PC" then return false end
		return detectMobile()
	end

	local function isRmbDown()
		if holding then return true end
		local ok, pressed = pcall(UserInputService.IsMouseButtonPressed, UserInputService, Enum.UserInputType.MouseButton2)
		return ok and pressed or false
	end

	local hud = create("ScreenGui", {
		Name = "AimHud",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
		ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
		DisplayOrder = 5,
		Parent = guiParent,
	})
	local espFolder = create("Folder", { Name = "AimESP", Parent = guiParent })

	local circle = create("Frame", {
		Name = "FOVCircle",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.fromScale(0.5, 0.5),
		BackgroundTransparency = 1,
		Parent = hud,
	})
	round(circle)
	local circleStroke = stroke(circle, currentAccent.Color, 1.8, 0.25)
	onAccent(function() circleStroke.Color = currentAccent.Color end)

	local targetInfo = create("TextLabel", {
		Name = "TargetInfo",
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 14),
		Size = UDim2.fromOffset(0, 28),
		BackgroundColor3 = PALETTE.Window,
		BackgroundTransparency = 0.1,
		TextSize = 13,
		TextColor3 = PALETTE.Gold,
		Visible = false,
		AutomaticSize = Enum.AutomaticSize.X,
		_Weight = "ExtraBold",
		Parent = hud,
	})
	padding(targetInfo, 0, 14, 0, 14)
	corner(targetInfo, 14)
	local tiStroke = stroke(targetInfo, currentAccent.Color, 1.5, 0.2)
	onAccent(function() tiStroke.Color = currentAccent.Color end)

	-- [[ ПЛАВАЮЩАЯ ПАНЕЛЬ QUICK BAR В НОВОМ СТИЛЕ ]]
	local QB_FULL_H = 166
	local quickBar = create("Frame", {
		Name = "QuickBar",
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -18, 0, 56),
		Size = UDim2.fromOffset(200, QB_FULL_H),
		BackgroundColor3 = PALETTE.Window,
		BackgroundTransparency = 0.06,
		Active = true,
		Parent = hud,
	})
	corner(quickBar, 16)
	local qbStroke = stroke(quickBar, PALETTE.Border, 1.8, 0)
	onAccent(function() qbStroke.Color = currentAccent.Color end)

	local qbHeader = create("Frame", { Size = UDim2.new(1, 0, 0, 30), BackgroundTransparency = 1, Parent = quickBar })
	label({
		Position = UDim2.fromOffset(12, 0),
		Size = UDim2.new(1, -40, 1, 0),
		Text = "❄ QUICK BAR",
		TextSize = 12,
		TextColor3 = PALETTE.Title,
		_Weight = "ExtraBold",
		Parent = qbHeader,
	})

	local qbCollapsed = false
	local qbCollapseBtn = create("TextButton", {
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -8, 0.5, 0),
		Size = UDim2.fromOffset(20, 20),
		BackgroundColor3 = PALETTE.Btn,
		AutoButtonColor = false,
		Text = "−",
		TextSize = 13,
		TextColor3 = PALETTE.Text,
		_Weight = "ExtraBold",
		Parent = qbHeader,
	})
	round(qbCollapseBtn)

	local qbBody = create("Frame", {
		Position = UDim2.fromOffset(8, 30),
		Size = UDim2.new(1, -16, 1, -36),
		BackgroundTransparency = 1,
		ClipsDescendants = true,
		Parent = quickBar,
	})
	create("UIListLayout", { Padding = UDim.new(0, 5), SortOrder = Enum.SortOrder.LayoutOrder, Parent = qbBody })

	qbCollapseBtn.MouseButton1Click:Connect(function()
		playClick()
		qbCollapsed = not qbCollapsed
		qbCollapseBtn.Text = qbCollapsed and "+" or "−"
		qbBody.Visible = not qbCollapsed
		tween(quickBar, 0.22, { Size = qbCollapsed and UDim2.fromOffset(200, 30) or UDim2.fromOffset(200, QB_FULL_H) })
	end)

	do
		local draggingQB, dragStartQB, startPosQB = false, nil, nil
		qbHeader.InputBegan:Connect(function(input)
			if isPress(input) then
				draggingQB = true
				dragStartQB = input.Position
				startPosQB = quickBar.Position
			end
		end)
		trackConn(UserInputService.InputChanged:Connect(function(input)
			if draggingQB and isMove(input) then
				local d = input.Position - dragStartQB
				quickBar.Position = UDim2.new(startPosQB.X.Scale, startPosQB.X.Offset + d.X, startPosQB.Y.Scale, startPosQB.Y.Offset + d.Y)
			end
		end))
		trackConn(UserInputService.InputEnded:Connect(function(input)
			if isPress(input) then draggingQB = false end
		end))
	end

	local espObjects = {}
	local function destroyESP(char)
		local o = espObjects[char]
		if not o then return end
		pcall(function() o.highlight:Destroy() end)
		pcall(function() o.billboard:Destroy() end)
		pcall(function() o.tracer:Destroy() end)
		espObjects[char] = nil
	end

	local function updateAutoRotate()
		local myChar = player.Character
		local hum = myChar and myChar:FindFirstChildOfClass("Humanoid")
		if not hum then return end
		hum.AutoRotate = isMobileDevice() and (not enabled) or true
	end

	local refreshers = {}
	local function refreshAll()
		for _, f in ipairs(refreshers) do f() end
		for _, f in ipairs(state.uiRefreshers) do f() end
	end

	local saveConfig = function() end
	local function updateUI()
		local showHud = not state.allHidden
		gui.Enabled = showHud
		hud.Enabled = showHud
		openDock.Visible = showHud
		circle.Visible = showHud and AIM.ShowFOV and enabled
		quickBar.Visible = showHud and AIM.ShowQuickBar and not CONFIG.CompactMode
		if not showHud then targetInfo.Visible = false end
		statusLabel.Text = enabled and "● Активен" or "● Пауза"
		statusLabel.TextColor3 = enabled and PALETTE.Green or PALETTE.SubText
		refreshAll()
		saveConfig(true)
	end

	function state.setStealth(hide)
		state.allHidden = hide == true
		if state.allHidden then
			menuVisible = false
			holder.Visible = false
			popScale.Scale = 0
			state.freeMouse.Visible = false
			blur.Size = 0
			for char in pairs(espObjects) do destroyESP(char) end
		end
		updateUI()
		updateBlur()
	end

	local function applyConfig()
		circle.Size = UDim2.fromOffset(AIM.FOV * 2, AIM.FOV * 2)
		updateUI()
	end

	local function makeQuickRow(title, getter, toggler)
		local r = create("TextButton", {
			Size = UDim2.new(1, 0, 0, 27),
			BackgroundColor3 = PALETTE.Card,
			AutoButtonColor = false,
			Text = "",
			Parent = qbBody,
		})
		corner(r, 8)
		label({
			Position = UDim2.fromOffset(10, 0),
			Size = UDim2.new(1, -50, 1, 0),
			Text = title,
			TextSize = 12,
			TextColor3 = PALETTE.Text,
			Parent = r,
		})
		local pill = create("Frame", {
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, -6, 0.5, 0),
			Size = UDim2.fromOffset(32, 16),
			BackgroundColor3 = PALETTE.TrackOff,
			Parent = r,
		})
		round(pill)
		local dot = create("Frame", {
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 2, 0.5, 0),
			Size = UDim2.fromOffset(12, 12),
			BackgroundColor3 = PALETTE.White,
			Parent = pill,
		})
		round(dot)

		table.insert(refreshers, function()
			local on = getter()
			pill.BackgroundColor3 = on and PALETTE.ToggleOn or PALETTE.TrackOff
			dot.Position = on and UDim2.new(1, -14, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		end)
		r.MouseButton1Click:Connect(function()
			playClick()
			toggler()
		end)
	end

	makeQuickRow("Аимбот", function() return enabled end, function()
		enabled = not enabled
		updateAutoRotate()
		updateUI()
	end)
	makeQuickRow("Сквозь стены", function() return AIM.AimThroughWalls end, function()
		AIM.AimThroughWalls = not AIM.AimThroughWalls
		AIM.WallCheck = not AIM.AimThroughWalls
		applyConfig()
	end)
	makeQuickRow("Автострел", function() return AIM.AutoShoot ~= "Off" end, function()
		AIM.AutoShoot = (AIM.AutoShoot == "Off") and "All" or "Off"
		applyConfig()
	end)
	makeQuickRow("ESP", function() return AIM.ESP end, function()
		AIM.ESP = not AIM.ESP
		applyConfig()
	end)

	-- Удобные обёртки для виджетов AIM/ESP
	local function getVal(key)
		if key == "enabled" then return enabled end
		return AIM[key]
	end

	local function aimToggle(cardBox, title, key)
		local api = addToggle(cardBox, title, getVal(key), function(on)
			if key == "enabled" then
				enabled = on
				updateAutoRotate()
			elseif key == "AimThroughWalls" then
				AIM.AimThroughWalls = on
				AIM.WallCheck = not on
			elseif key == "WallCheck" then
				AIM.WallCheck = on
				AIM.AimThroughWalls = not on
			else
				AIM[key] = on
			end
			applyConfig()
		end)
		table.insert(refreshers, function() api.Sync(getVal(key)) end)
		return api
	end

	local function aimSlider(cardBox, title, key, minV, maxV, scale, suffix, formatter)
		local api = addSlider(cardBox, title, minV, maxV, math.floor(AIM[key] * scale + 0.5), suffix, function(v)
			AIM[key] = v / scale
			applyConfig()
		end, formatter)
		table.insert(refreshers, function() api.Sync(math.floor(AIM[key] * scale + 0.5)) end)
		return api
	end

	local function aimChoice(cardBox, title, key, options)
		local api = addChoice(cardBox, title, options, function() return AIM[key] end, function(v)
			AIM[key] = v
			applyConfig()
		end)
		table.insert(refreshers, api.Sync)
		return api
	end

	-- Блок быстрого доступа на Главной
	do
		local quickCard = createFullCard(homePage, "Быстрые переключатели")
		aimToggle(quickCard, "Аимбот (вкл/выкл)", "enabled")
		aimToggle(quickCard, "Аим сквозь стены (ПК: вкл / Тел: выкл)", "AimThroughWalls")
		aimToggle(quickCard, "Подсветка игроков (ESP)", "ESP")
	end

	-- [[ ВКЛАДКА АИМБОТ ]]
	do
		local cLeft, cRight = createTwoCards(aimPage, "Основное", "Автострел и проверки")
		aimToggle(cLeft, "Включить аимбот", "enabled")
		aimToggle(cLeft, "Аим сквозь стены", "AimThroughWalls")
		aimToggle(cLeft, "Только голова", "HeadOnly")
		aimToggle(cLeft, "ПК: по зажатию ПКМ", "HoldToAim")
		aimToggle(cLeft, "ПКМ сквозь стены", "HoldThroughWalls")
		aimToggle(cLeft, "Мгновенная наводка", "InstantSnap")
		aimChoice(cLeft, "Часть тела", "AimPart", {
			{ "Head", "Голова" },
			{ "UpperTorso", "Торс" },
			{ "HumanoidRootPart", "Центр" },
		})
		aimChoice(cLeft, "Режим камеры", "AimMode", {
			{ "Override", "Rivals" },
			{ "Classic", "Обычный" },
		})

		aimChoice(cRight, "Автострел", "AutoShoot", {
			{ "All", "Везде" },
			{ "Phone", "Телефон" },
			{ "Off", "Выкл" },
		})
		aimToggle(cRight, "KnifeAuto (Нож 150)", "KnifeAuto")
		aimToggle(cRight, "Не целиться в своих", "TeamCheck")
		aimToggle(cRight, "Проверка стен", "WallCheck")
		aimToggle(cRight, "Без тряски камеры", "NoCameraShake")
		aimToggle(cRight, "Показывать круг FOV", "ShowFOV")
		aimToggle(cRight, "Плашка цели сверху", "ShowTargetInfo")
		aimToggle(cRight, "Поворот тела (Моб.)", "TurnBody")

		local slidersCard = createFullCard(aimPage, "Точная настройка аимбота")
		aimSlider(slidersCard, "Скорость наводки", "Smoothness", 5, 100, 100, "%")
		aimSlider(slidersCard, "Радиус круга FOV", "FOV", 30, 400, 1, " px")
		aimSlider(slidersCard, "Упреждение (Предикт)", "Prediction", 0, 300, 1000, " ms")
		aimSlider(slidersCard, "Высота точки головы", "AimHeight", -100, 100, 100, "", function(v) return string.format("%+.2f", v / 100) end)
		aimSlider(slidersCard, "Угол автострела", "AutoShootAngle", 1, 30, 1, "°")
		aimSlider(slidersCard, "Задержка выстрела", "AutoShootDelay", 0, 500, 1000, " ms")
		aimSlider(slidersCard, "Дальность ножа", "KnifeAutoRange", 3, 20, 1, " st")
	end

	-- [[ ВКЛАДКА ВИЗУАЛ (ESP) ]]
	do
		local eLeft, eRight = createTwoCards(espPage, "Подсветка и цвета", "Информация об игроках")
		aimToggle(eLeft, "Включить ESP", "ESP")
		aimToggle(eLeft, "Контур (скин видно)", "ESPHighlight")
		aimToggle(eLeft, "Умные цвета за стеной", "SmartESPColors")
		aimToggle(eLeft, "Показывать тиммейтов", "ESPTeammates")

		aimToggle(eRight, "Ники игроков", "ESPNames")
		aimToggle(eRight, "Оружие в руках", "ESPShowWeapon")
		aimToggle(eRight, "Дистанция в метрах", "ESPDistance")
		aimToggle(eRight, "Полоска здоровья (HP)", "ESPHealth")
		aimToggle(eRight, "Линии (Tracers)", "ESPTracers")

		local distCard = createFullCard(espPage, "Дальность отрисовки")
		aimSlider(distCard, "Макс. дальность ESP", "ESPMaxDistance", 50, 3000, 1, " m")
	end

	-- [[ ВКЛАДКА ДВИЖЕНИЕ ]]
	do
		local mLeft, mRight = createTwoCards(movePage, "Движение в бою", "Панель и камера")
		aimToggle(mLeft, "BunnyHop (Авто-прыжки)", "BunnyHop")
		aimToggle(mLeft, "Crouch Spam (Присед)", "CrouchSpam")
		aimToggle(mLeft, "Удерживать цель", "StickyTarget")

		aimToggle(mRight, "Показывать Quick Bar", "ShowQuickBar")
		aimToggle(mRight, "Фиксировать мышь", "FreezeMouse")
		aimChoice(mRight, "Устройство", "DeviceMode", {
			{ "Auto", "Авто" },
			{ "PC", "ПК" },
			{ "Mobile", "Телефон" },
		})
	end

	-- [[ СОХРАНЕНИЕ И СБРОС КОНФИГА ]]
	local SAVE_KEYS = {}
	for k, v in pairs(AIM_DEFAULTS) do
		local t = typeof(v)
		if t == "boolean" or t == "number" or t == "string" then
			table.insert(SAVE_KEYS, k)
		end
	end
	table.sort(SAVE_KEYS)

	local CONFIG_FILE = "SnowHub_v9_NY.cfg"
	local function exportConfig()
		local parts = {
			"enabled=" .. (enabled and "1" or "0"),
			"ui_Accent=" .. CONFIG.Accent,
			"ui_Transparency=" .. string.format("%g", CONFIG.Transparency),
			"ui_MenuScale=" .. string.format("%g", CONFIG.MenuScale),
			"ui_Blur=" .. (CONFIG.Blur and "1" or "0"),
			"ui_BlurSize=" .. tostring(CONFIG.BlurSize),
			"ui_Snowfall=" .. (CONFIG.Snowfall and "1" or "0"),
			"ui_Garland=" .. (CONFIG.Garland and "1" or "0"),
			"ui_ButtonSounds=" .. (CONFIG.ButtonSounds and "1" or "0"),
			"ui_SoundVolume=" .. string.format("%g", CONFIG.SoundVolume),
			"ui_CompactMode=" .. (CONFIG.CompactMode and "1" or "0"),
			"ui_Notifications=" .. (CONFIG.Notifications and "1" or "0"),
		}
		for _, k in ipairs(SAVE_KEYS) do
			local v = AIM[k]
			if type(v) == "boolean" then v = v and "1" or "0"
			elseif type(v) == "number" then v = string.format("%g", v)
			end
			table.insert(parts, k .. "=" .. tostring(v))
		end
		return table.concat(parts, ";")
	end

	local function importConfig(raw)
		if type(raw) ~= "string" then return end
		local hasWallAim, hasWallCheck = false, false
		for pair in string.gmatch(raw, "[^;]+") do
			local k, v = string.match(pair, "^%s*([%w_]+)%s*=%s*(.-)%s*$")
			if k == "enabled" then
				enabled = (v == "1")
			elseif k == "ui_Accent" then
				setAccent(v)
			elseif k == "ui_Transparency" and tonumber(v) then
				CONFIG.Transparency = math.clamp(tonumber(v), 0, 0.8)
				main.BackgroundTransparency = CONFIG.Transparency
			elseif k == "ui_MenuScale" and tonumber(v) then
				CONFIG.MenuScale = math.clamp(tonumber(v), 0.6, 1.3)
				fitToScreen()
			elseif k == "ui_Blur" then
				CONFIG.Blur = (v == "1")
			elseif k == "ui_BlurSize" and tonumber(v) then
				CONFIG.BlurSize = math.clamp(tonumber(v), 0, 25)
			elseif k == "ui_Snowfall" then
				CONFIG.Snowfall = (v == "1")
				snowLayer.Visible = CONFIG.Snowfall
			elseif k == "ui_Garland" then
				CONFIG.Garland = (v == "1")
				garlandFrame.Visible = CONFIG.Garland
			elseif k == "ui_ButtonSounds" then
				CONFIG.ButtonSounds = (v == "1")
			elseif k == "ui_SoundVolume" and tonumber(v) then
				CONFIG.SoundVolume = math.clamp(tonumber(v), 0, 1)
			elseif k == "ui_CompactMode" then
				CONFIG.CompactMode = (v == "1")
			elseif k == "ui_Notifications" then
				CONFIG.Notifications = (v == "1")
			elseif k and AIM_DEFAULTS[k] ~= nil then
				local def = AIM_DEFAULTS[k]
				if type(def) == "boolean" then
					AIM[k] = (v == "1" or v == "true")
					if k == "AimThroughWalls" then hasWallAim = true end
					if k == "WallCheck" then hasWallCheck = true end
				elseif type(def) == "number" and tonumber(v) then
					AIM[k] = tonumber(v)
				elseif type(def) == "string" then
					AIM[k] = v
				end
			end
		end
		if hasWallAim then
			AIM.WallCheck = not AIM.AimThroughWalls
		elseif hasWallCheck then
			AIM.AimThroughWalls = not AIM.WallCheck
		end
	end

	saveConfig = function(silent)
		pcall(function()
			if writefile then
				writefile(CONFIG_FILE, exportConfig())
			end
		end)
		if not silent then
			notify("Сохранено", "Настройки Snow Hub записаны!", 2.5)
		end
	end
	state.saveAll = saveConfig

	state.resetAll = function()
		for k, v in pairs(AIM_DEFAULTS) do
			AIM[k] = v
		end
		enabled = true
		for k, v in pairs(CONFIG_DEFAULTS) do
			CONFIG[k] = v
		end
		main.BackgroundTransparency = CONFIG.Transparency
		snowLayer.Visible = CONFIG.Snowfall
		garlandFrame.Visible = CONFIG.Garland
		setAccent(CONFIG.Accent)
		fitToScreen()
		updateBlur()
		applyConfig()
		notify("Сброс", "Настройки возвращены по умолчанию", 2.5)
	end

	pcall(function()
		if isfile and readfile and isfile(CONFIG_FILE) then
			importConfig(readfile(CONFIG_FILE))
		end
	end)
	applyConfig()

	-- [[ ОБРАБОТКА ВВОДА ]]
	trackConn(UserInputService.InputBegan:Connect(function(input, processed)
		if input.UserInputType == AIM.AimHoldButton and not menuVisible then
			holding = true
			return
		end
		if bindingKey or UserInputService:GetFocusedTextBox() then return end

		local key = input.KeyCode
		if key == CONFIG.HideAllKey then
			state.setStealth(not state.allHidden)
			return
		end
		if processed or state.allHidden then return end

		if key == AIM.ToggleKey then
			enabled = not enabled
			updateAutoRotate()
			updateUI()
		elseif key == AIM.AutoShootKey then
			AIM.AutoShoot = (AIM.AutoShoot == "Off") and "All" or "Off"
			notify("Автострел", AIM.AutoShoot == "Off" and "Выключен" or "Включён", 2)
			applyConfig()
		elseif key == AIM.SnapKey then
			AIM.InstantSnap = not AIM.InstantSnap
			applyConfig()
		end
	end))

	trackConn(UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == AIM.AimHoldButton then
			holding = false
			lockedPart, lockedTarget, aimLook = nil, nil, nil
			releaseBody()
			freezeMouse(false)
		end
	end))

	trackConn(UserInputService.WindowFocusReleased:Connect(function()
		holding = false
		lockedPart, lockedTarget, aimLook = nil, nil, nil
		releaseBody()
		freezeMouse(false)
	end))

	-- [[ КОМАНДЫ И ОРУЖИЕ ]]
	local TEAM_FIELDS = { "Team", "TeamName", "TeamId", "TeamID", "TeamColor", "Side", "Squad" }
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
		teamCache.keys, teamCache.mine, teamCache.ffa = keys, mine, (all >= 2 and same == all)
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

	local MELEE_KW = {
		knife = true, blade = true, katana = true, sword = true, dagger = true,
		scythe = true, axe = true, machete = true, karambit = true, butterfly = true,
		bat = true, crowbar = true, hammer = true, fists = true, melee = true, balisong = true,
	}
	local function isNameMelee(name)
		local lower = string.lower(tostring(name or ""))
		for kw in pairs(MELEE_KW) do
			if string.find(lower, kw, 1, true) then return true end
		end
		return false
	end

	local function getHeldItem(char)
		if not char then return nil end
		local tool = char:FindFirstChildOfClass("Tool")
		if tool then
			local melee = tool:GetAttribute("Melee") == true
				or tool:GetAttribute("IsMelee") == true
				or tool:GetAttribute("WeaponType") == "Melee"
				or isNameMelee(tool.Name)
			return { Tool = tool, Name = tool.Name, IsMelee = melee }
		end
		local attrName = char:GetAttribute("EquippedWeapon") or char:GetAttribute("CurrentWeapon") or char:GetAttribute("Weapon")
		if attrName then
			return { Tool = nil, Name = tostring(attrName), IsMelee = isNameMelee(attrName) }
		end
		return nil
	end

	local lastKnifeHeavy = 0
	local function tryKnifeHeavy(myRoot, enemyRoot, tool)
		if not (myRoot and enemyRoot and tool) then return false end
		local toMe = myRoot.Position - enemyRoot.Position
		if toMe.Magnitude < 0.01 or toMe.Magnitude > (AIM.KnifeAutoRange or 7) then return false end
		if enemyRoot.CFrame.LookVector:Dot(toMe.Unit) >= -0.35 then return false end

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
		local evt = tool:FindFirstChild("Heavy") or tool:FindFirstChild("Secondary") or tool:FindFirstChild("HeavyAttack")
		if evt and evt:IsA("RemoteEvent") then
			pcall(function() evt:FireServer("Heavy") end)
		end
		return true
	end

	-- [[ РЕЙКАСТ И ПРОВЕРКА СТЕН ]]
	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	rayParams.IgnoreWater = true

	local PART_NAMES = {
		Head = { "Head" },
		UpperTorso = { "UpperTorso", "Torso" },
		HumanoidRootPart = { "HumanoidRootPart", "Torso" },
	}
	local function getAimPart(char)
		local pName = AIM.HeadOnly and "Head" or AIM.AimPart
		for _, n in ipairs(PART_NAMES[pName] or { pName }) do
			local p = char:FindFirstChild(n)
			if p and p:IsA("BasePart") then return p end
		end
		return char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart")
	end

	local function isLineClear(cam, part, targetChar)
		if not (cam and part and targetChar) then return false end
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
			elseif hit.Transparency >= 0.7 or not hit.CanCollide then
				table.insert(ignore, hit)
			else
				return false
			end
		end
		return false
	end

	local function isVisibleForAim(cam, part, targetChar)
		if AIM.AimThroughWalls or not AIM.WallCheck then return true end
		if (isRmbDown() or isMobileDevice()) and AIM.HoldThroughWalls then return true end
		return isLineClear(cam, part, targetChar)
	end

	-- [[ ESP ]]
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

		local function mkLbl(y, h, sz)
			return create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.fromOffset(0, y),
				Size = UDim2.new(1, 0, 0, h),
				TextSize = sz,
				TextStrokeTransparency = 0.25,
				TextColor3 = PALETTE.White,
				_Weight = "Bold",
				Parent = bb,
			})
		end
		o.name = mkLbl(0, 18, 14)
		o.info = mkLbl(17, 15, 12)

		local hpBack = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0),
			Position = UDim2.new(0.5, 0, 0, 35),
			Size = UDim2.fromOffset(68, 5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 25),
			Parent = bb,
		})
		corner(hpBack, 3)

		local hpFill = create("Frame", { Parent = hpBack })
		corner(hpFill, 3)
		o.hpBack, o.hpFill = hpBack, hpFill

		o.tracer = create("Frame", {
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 0.2,
			Visible = false,
			Parent = hud,
		})

		espObjects[char] = o
		return o
	end

	local espLastUpdate = 0
	local espRayCache = setmetatable({}, { __mode = "k" })

	local function updateESP(cam, targets)
		if state.allHidden then
			for char in pairs(espObjects) do destroyESP(char) end
			return
		end
		if os.clock() - espLastUpdate < 0.033 then return end
		espLastUpdate = os.clock()
		local seen = {}

		if AIM.ESP then
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
						local cached = espRayCache[char]
						if cached and now - cached.t < 0.1 then
							visible = cached.v
						else
							visible = isLineClear(cam, getAimPart(char) or root, char)
							espRayCache[char] = { v = visible, t = now }
						end

						local fillCol, outCol, fillTr
						if mate then
							if AIM.SmartESPColors and not visible then
								fillCol, outCol, fillTr = Color3.fromRGB(170, 255, 195), Color3.fromRGB(235, 255, 240), 0.78
							else
								fillCol, outCol, fillTr = Color3.fromRGB(45, 255, 100), Color3.fromRGB(130, 255, 160), 0.85
							end
						else
							if AIM.SmartESPColors and not visible then
								fillCol, outCol, fillTr = Color3.fromRGB(255, 165, 165), Color3.fromRGB(255, 235, 235), 0.78
							else
								fillCol, outCol, fillTr = Color3.fromRGB(255, 45, 45), Color3.fromRGB(255, 120, 120), 0.85
							end
						end

						o.highlight.Enabled = AIM.ESPHighlight
						o.highlight.FillColor = fillCol
						o.highlight.OutlineColor = outCol
						o.highlight.FillTransparency = fillTr
						o.highlight.OutlineTransparency = 0.05

						o.billboard.Adornee = char:FindFirstChild("Head") or root
						o.billboard.Enabled = AIM.ESPNames or AIM.ESPDistance or AIM.ESPHealth

						o.name.Visible = AIM.ESPNames
						local held = AIM.ESPShowWeapon and getHeldItem(char)
						o.name.Text = t.name .. (held and (" [" .. held.Name .. "]") or "")
						o.name.TextColor3 = fillCol

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
								o.tracer.BackgroundColor3 = fillCol
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

	-- [[ ЦЕЛЕУКАЗАНИЕ И КАМЕРА ]]
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

		if not isVisibleForAim(cam, part, char) then
			if AIM.HeadOnly then return nil end
			local alt = nil
			for _, n in ipairs(VISIBLE_PARTS) do
				local p = char:FindFirstChild(n)
				if p and p ~= part and p:IsA("BasePart") and isVisibleForAim(cam, p, char) then
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
				if p and isVisibleForAim(cam, p, current.char) then return p, current end
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

	local mouseFrozen, savedSens = false, nil
	freezeMouse = function(frozen)
		if frozen == mouseFrozen then return end
		pcall(function()
			if frozen then
				if savedSens == nil then savedSens = UserInputService.MouseDeltaSensitivity end
				UserInputService.MouseDeltaSensitivity = 0
			elseif savedSens ~= nil then
				UserInputService.MouseDeltaSensitivity = savedSens
				savedSens = nil
			end
		end)
		mouseFrozen = frozen
	end

	local BodyTurn = { Align = nil, Active = false, Hum = nil, SavedAuto = nil }
	releaseBody = function()
		if not BodyTurn.Active then return end
		BodyTurn.Active = false
		if BodyTurn.Align and BodyTurn.Align.Parent then BodyTurn.Align.Enabled = false end
		if BodyTurn.Hum and BodyTurn.Hum.Parent and BodyTurn.SavedAuto ~= nil then
			BodyTurn.Hum.AutoRotate = BodyTurn.SavedAuto
		end
		BodyTurn.SavedAuto = nil
	end

	local function turnBodyTo(look)
		if not AIM.TurnBody then releaseBody(); return end
		local flat = Vector3.new(look.X, 0, look.Z)
		if flat.Magnitude < 0.05 then return end
		local char = player.Character
		local hrp = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if not hrp or not hum then return end
		if not (BodyTurn.Align and BodyTurn.Align.Parent == hrp) then
			local att = hrp:FindFirstChild("AimRootAttachment") or Instance.new("Attachment", hrp)
			att.Name = "AimRootAttachment"
			local align = hrp:FindFirstChild("AimAlign") or Instance.new("AlignOrientation", hrp)
			align.Name = "AimAlign"
			align.Mode = Enum.OrientationAlignmentMode.OneAttachment
			align.Attachment0 = att
			align.MaxTorque = 60000
			align.RigidityEnabled = false
			align.Enabled = false
			BodyTurn.Align, BodyTurn.Hum = align, hum
		end
		if not BodyTurn.Active then
			BodyTurn.Active = true
			BodyTurn.SavedAuto = BodyTurn.Hum.AutoRotate
			BodyTurn.Hum.AutoRotate = false
		end
		BodyTurn.Align.MaxAngularVelocity = math.rad(AIM.BodyMaxSpeed or 540)
		BodyTurn.Align.Responsiveness = AIM.BodyResponsiveness or 25
		BodyTurn.Align.CFrame = CFrame.lookAt(Vector3.zero, flat.Unit)
		BodyTurn.Align.Enabled = true
	end

	RunService:BindToRenderStep("AimMain", Enum.RenderPriority.Camera.Value - 1, function(dt)
		local cam = workspace.CurrentCamera
		if not cam then return end

		if AIM.NoCameraShake then
			local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
			if hum and hum.CameraOffset.Magnitude > 0.8 then
				hum.CameraOffset = hum.CameraOffset.Unit * 0.8
			end
		end

		local targets = getTargets()
		updateESP(cam, targets)

		local wantAim
		if state.allHidden then
			wantAim = aliveHumanoid(player.Character) ~= nil and isRmbDown()
		elseif isMobileDevice() then
			wantAim = enabled and not menuVisible and aliveHumanoid(player.Character) ~= nil
		else
			local held = getHeldItem(player.Character)
			wantAim = enabled and not menuVisible and aliveHumanoid(player.Character) ~= nil and (not AIM.HoldToAim or isRmbDown() or (held and held.IsMelee))
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
		local nl = (aimLook or cam.CFrame.LookVector):Lerp(want, smoothAlpha(dt))
		aimLook = nl.Magnitude < 1e-3 and want or nl.Unit
		cam.CFrame = lookCFrame(cam.CFrame.Position, aimLook)

		if isMobileDevice() and isVisibleForAim(cam, lockedPart, lockedTarget.char) then
			turnBodyTo(aimLook)
		else
			releaseBody()
		end

		freezeMouse(AIM.FreezeMouse)

		if AIM.ShowTargetInfo and not state.allHidden then
			local myRoot = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			local d = myRoot and math.floor((lockedPart.Position - myRoot.Position).Magnitude + 0.5) or 0
			local ew = getHeldItem(lockedTarget.char)
			targetInfo.Text = string.format("🎯 %s%s  •  %d м", lockedTarget.name, ew and (" [" .. ew.Name .. "]") or "", d)
			targetInfo.Visible = true
		else
			targetInfo.Visible = false
		end
	end)

	RunService:BindToRenderStep("AimCameraOverride", Enum.RenderPriority.Last.Value, function()
		if AIM.AimMode ~= "Override" or not lockedPart or not aimLook then return end
		local cam = workspace.CurrentCamera
		if cam then cam.CFrame = lookCFrame(cam.CFrame.Position, aimLook) end
	end)

	local firing, lastShot = false, 0
	local function setTrigger(down)
		local tool = player.Character and player.Character:FindFirstChildOfClass("Tool")
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
		local held = getHeldItem(myChar)
		local targets = getTargets()

		if AIM.KnifeAuto and held and held.IsMelee and myRoot then
			local now = os.clock()
			if now - lastKnifeHeavy >= AIM.KnifeAutoCooldown then
				for _, t in ipairs(targets) do
					local ec = t.char
					local er = ec and (ec:FindFirstChild("HumanoidRootPart") or ec.PrimaryPart)
					if er and aliveHumanoid(ec) and not ec:FindFirstChildOfClass("ForceField") and not (AIM.TeamCheck and isTeammate(t.plr)) then
						if tryKnifeHeavy(myRoot, er, held.Tool) then
							lastKnifeHeavy = now
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
		local candidates = {}

		if lockedPart and lockedTarget and isLineClear(cam, lockedPart, lockedTarget.char) then
			table.insert(candidates, lockedPart)
		elseif not lockedPart and not state.allHidden then
			for _, t in ipairs(targets) do
				local char = t.char
				if char and aliveHumanoid(char) and not char:FindFirstChildOfClass("ForceField") and not (AIM.TeamCheck and isTeammate(t.plr)) then
					local p = getAimPart(char)
					if p and isLineClear(cam, p, char) then table.insert(candidates, p) end
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

	local lastCrouch, crouchDown = 0, false
	trackConn(RunService.Heartbeat:Connect(function()
		local hum = player.Character and aliveHumanoid(player.Character)
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

		local shooting = firing or UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1)
		if AIM.CrouchSpam and shooting then
			local now = os.clock()
			if now - lastCrouch >= 0.18 then
				lastCrouch = now
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
pcall(setupCombatAndESP)

-- [[ 5. ВКЛАДКА НАСТРОЙКИ (КАК В ТВОЁМ HTML-МАКЕТЕ) ]]
do
	local sLeft, sRight = createTwoCards(setPage, "Оформление", "Интерфейс")

	local tSnow = addToggle(sLeft, "Падающий снег", CONFIG.Snowfall, function(on)
		CONFIG.Snowfall = on
		snowLayer.Visible = on
	end)
	local tGarland = addToggle(sLeft, "Гирлянда на окне", CONFIG.Garland, function(on)
		CONFIG.Garland = on
		garlandFrame.Visible = on
	end)
	local tBlur = addToggle(sLeft, "Размытие фона", CONFIG.Blur, function(on)
		CONFIG.Blur = on
		updateBlur()
	end)

	local tCompact = addToggle(sRight, "Компактный режим", CONFIG.CompactMode, function(on)
		CONFIG.CompactMode = on
		if state.saveAll then state.saveAll(true) end
	end)
	local tSounds = addToggle(sRight, "Звуки кнопок", CONFIG.ButtonSounds, function(on)
		CONFIG.ButtonSounds = on
	end)
	local tNotif = addToggle(sRight, "Уведомления", CONFIG.Notifications, function(on)
		CONFIG.Notifications = on
	end)

	local winCard = createFullCard(setPage, "Настройка окна")
	local slTrans = addSlider(winCard, "Прозрачность", 0, 80, math.floor(CONFIG.Transparency * 100 + 0.5), "%", function(v)
		CONFIG.Transparency = v / 100
		main.BackgroundTransparency = CONFIG.Transparency
	end)
	local slScale = addSlider(winCard, "Масштаб меню", 60, 130, math.floor(CONFIG.MenuScale * 100 + 0.5), "%", function(v)
		CONFIG.MenuScale = v / 100
		fitToScreen()
	end)
	local slBlur = addSlider(winCard, "Сила размытия", 0, 25, CONFIG.BlurSize, "", function(v)
		CONFIG.BlurSize = v
		updateBlur()
	end)
	local slVol = addSlider(winCard, "Громкость звуков", 0, 100, math.floor(CONFIG.SoundVolume * 100 + 0.5), "%", function(v)
		CONFIG.SoundVolume = v / 100
	end)

	local keysCard = createFullCard(setPage, "Горячие клавиши")
	local kbMenu = addKeybind(keysCard, "Открыть / закрыть меню", "ToggleKey")
	local kbStealth = addKeybind(keysCard, "Скрыть ВСЁ (Стелс)", "HideAllKey")

	table.insert(state.uiRefreshers, function()
		tSnow.Sync(CONFIG.Snowfall)
		tGarland.Sync(CONFIG.Garland)
		tBlur.Sync(CONFIG.Blur)
		tCompact.Sync(CONFIG.CompactMode)
		tSounds.Sync(CONFIG.ButtonSounds)
		tNotif.Sync(CONFIG.Notifications)
		slTrans.Sync(math.floor(CONFIG.Transparency * 100 + 0.5))
		slScale.Sync(math.floor(CONFIG.MenuScale * 100 + 0.5))
		slBlur.Sync(CONFIG.BlurSize)
		slVol.Sync(math.floor(CONFIG.SoundVolume * 100 + 0.5))
		kbMenu.Sync()
		kbStealth.Sync()
	end)
end

-- [[ 6. ВКЛАДКА ПРОФИЛЬ ]]
local profSessionLbl
do
	local pCard = createFullCard(profPage, "Аккаунт Roblox")
	local row = create("Frame", {
		Size = UDim2.new(1, 0, 0, 74),
		BackgroundTransparency = 1,
		LayoutOrder = nextOrder(),
		Parent = pCard,
	})
	local av = create("ImageLabel", {
		Size = UDim2.fromOffset(68, 68),
		BackgroundColor3 = PALETTE.Btn,
		Image = ("rbxthumb://type=AvatarHeadShot&id=%d&w=150&h=150"):format(player.UserId),
		Parent = row,
	})
	round(av)
	stroke(av, PALETTE.Gold, 2, 0.1)

	label({
		Position = UDim2.fromOffset(84, 8),
		Size = UDim2.new(1, -90, 0, 24),
		Text = player.DisplayName,
		TextSize = 18,
		TextColor3 = PALETTE.Text,
		_Weight = "ExtraBold",
		Parent = row,
	})
	label({
		Position = UDim2.fromOffset(84, 34),
		Size = UDim2.new(1, -90, 0, 18),
		Text = "@" .. player.Name .. "  •  ID: " .. player.UserId,
		TextSize = 13,
		TextColor3 = PALETTE.SubText,
		Parent = row,
	})

	local sLeft, sRight = createTwoCards(profPage, "Статистика", "Сессия Snow Hub")
	addInfoText(sLeft, "Возраст аккаунта: " .. player.AccountAge .. " дн.", PALETTE.Text)
	addInfoText(sLeft, "Версия скрипта: " .. CONFIG.Version, PALETTE.Gold)
	profSessionLbl = addInfoText(sRight, "Время в сессии: 00:00", PALETTE.Text)
	addInfoText(sRight, "Режим: Rivals New Year Edition", PALETTE.SubText)
end

selectTab(tabs[1])

-- [[ КНОПКИ ОКНА, ПЕРЕТАСКИВАНИЕ И АНИМАЦИИ ]]
minimizeButton.MouseButton1Click:Connect(function()
	playClick()
	minimized = not minimized
	body.Visible = not minimized
	tween(main, 0.28, { Size = minimized and UDim2.new(1, 0, 0, TOP_H + 6) or UDim2.fromScale(1, 1) })
	updateBlur()
end)

closeButton.MouseButton1Click:Connect(function()
	playClick()
	setMenuVisible(false)
end)

do
	local pressing, moved, pressStart, dockStart = false, false, nil, nil
	openButton.InputBegan:Connect(function(input)
		if isPress(input) then
			pressing, moved = true, false
			pressStart = Vector2.new(input.Position.X, input.Position.Y)
			local vp = camera.ViewportSize
			dockStart = Vector2.new(
				openDock.Position.X.Scale * vp.X + openDock.Position.X.Offset,
				openDock.Position.Y.Scale * vp.Y + openDock.Position.Y.Offset
			)
		end
	end)
	trackConn(UserInputService.InputChanged:Connect(function(input)
		if pressing and isMove(input) then
			local d = Vector2.new(input.Position.X, input.Position.Y) - pressStart
			if d.Magnitude >= 6 then moved = true end
			if moved then openDock.Position = UDim2.fromOffset(dockStart.X + d.X, dockStart.Y + d.Y) end
		end
	end))
	trackConn(UserInputService.InputEnded:Connect(function(input)
		if pressing and isPress(input) then pressing = false end
	end))
	openButton.MouseButton1Click:Connect(function()
		if moved then moved = false; return end
		playClick()
		setMenuVisible(not menuVisible)
	end)
end

do
	local dragging, dragStart, startPos = false, nil, nil
	topBar.InputBegan:Connect(function(input)
		if isPress(input) and not hoveringTopBtn then
			dragging = true
			dragStart = input.Position
			startPos = holder.Position
		end
	end)
	trackConn(UserInputService.InputChanged:Connect(function(input)
		if dragging and isMove(input) then
			local d = input.Position - dragStart
			holder.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
		end
	end))
	trackConn(UserInputService.InputEnded:Connect(function(input)
		if isPress(input) then dragging = false end
	end))
end

trackConn(UserInputService.InputBegan:Connect(function(input, gp)
	if gp or bindingKey or state.allHidden then return end
	if input.KeyCode == CONFIG.ToggleKey then
		playClick()
		setMenuVisible(not menuVisible)
	end
end))

local clock = 0
trackConn(RunService.RenderStepped:Connect(function(dt)
	if not menuVisible or state.allHidden then return end
	clock += dt

	if CONFIG.Garland then
		for _, b in ipairs(garlandBulbs) do
			local glow = 0.5 + 0.5 * math.sin(clock * 2.6 + b.Phase)
			b.Halo.BackgroundTransparency = 0.42 + (1 - glow) * 0.42
		end
	end

	if CONFIG.Snowfall then
		for _, f in ipairs(snowflakes) do
			f.Y += f.SpeedY * dt
			if f.Y > 1.05 then
				f.Y = -0.05
				f.X = math.random()
			end
			local sway = math.sin(clock * 1.6 + f.Phase) * f.Drift
			f.Inst.Position = UDim2.fromScale(f.X + sway, f.Y)
		end
	end
end))

task.spawn(function()
	local sec = 0
	while gui.Parent do
		local t = string.format("%02d:%02d", math.floor(sec / 60), math.floor(sec % 60))
		if homeSessionLbl then homeSessionLbl.Text = "В игре: " .. t end
		if profSessionLbl then profSessionLbl.Text = "Время в сессии: " .. t end
		sec += task.wait(1)
	end
end)

setMenuVisible(false)
