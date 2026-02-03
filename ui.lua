-- Pulse UI V1 - lightweight Roblox UI library
-- Note: This is UI-only (no game logic). Works with mouse + touch.

local UIS = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local MarketplaceService = game:GetService("MarketplaceService")
local LocalizationService = game:GetService("LocalizationService")

-- Executor/engine compatibility shims
local taskSpawn = (task and task.spawn) or function(fn, ...)
	local args = { ... }
	spawn(function()
		fn(table.unpack(args))
	end)
end
local taskWait = (task and task.wait) or wait
local taskDelay = (task and task.delay) or function(seconds, fn, ...)
	local args = { ... }
	spawn(function()
		wait(tonumber(seconds) or 0)
		fn(table.unpack(args))
	end)
end

local PulseUI = {}

PulseUI.Themes = {
	Default = {
		bg = Color3.fromRGB(10, 10, 10),
		panel = Color3.fromRGB(16, 16, 16),
		panel2 = Color3.fromRGB(20, 20, 20),
		stroke = Color3.fromRGB(60, 60, 60),
		strokeSoft = Color3.fromRGB(42, 42, 42),
		label = Color3.fromRGB(170, 170, 170),
		muted = Color3.fromRGB(140, 140, 140),
		text = Color3.fromRGB(255, 255, 255),
		value = Color3.fromRGB(215, 215, 215),
		accent = Color3.fromRGB(171, 145, 255),
		accent2 = Color3.fromRGB(108, 94, 186),
	},
	Starlight = {
		bg = Color3.fromRGB(11, 12, 16),
		panel = Color3.fromRGB(18, 19, 25),
		panel2 = Color3.fromRGB(22, 24, 32),
		stroke = Color3.fromRGB(68, 74, 88),
		strokeSoft = Color3.fromRGB(42, 46, 58),
		label = Color3.fromRGB(190, 196, 210),
		muted = Color3.fromRGB(150, 156, 170),
		text = Color3.fromRGB(245, 246, 250),
		value = Color3.fromRGB(226, 230, 240),
		accent = Color3.fromRGB(171, 145, 255),
		accent2 = Color3.fromRGB(108, 94, 186),
	},
	Ocean = {
		bg = Color3.fromRGB(9, 10, 12),
		panel = Color3.fromRGB(15, 17, 20),
		panel2 = Color3.fromRGB(20, 22, 26),
		stroke = Color3.fromRGB(70, 80, 90),
		strokeSoft = Color3.fromRGB(40, 48, 56),
		label = Color3.fromRGB(170, 180, 190),
		muted = Color3.fromRGB(140, 150, 160),
		text = Color3.fromRGB(235, 240, 245),
		value = Color3.fromRGB(215, 225, 235),
		accent = Color3.fromRGB(70, 140, 255),
		accent2 = Color3.fromRGB(40, 90, 170),
	},
	Violet = {
		bg = Color3.fromRGB(10, 9, 12),
		panel = Color3.fromRGB(16, 15, 20),
		panel2 = Color3.fromRGB(20, 18, 26),
		stroke = Color3.fromRGB(80, 70, 95),
		strokeSoft = Color3.fromRGB(44, 40, 56),
		label = Color3.fromRGB(175, 170, 190),
		muted = Color3.fromRGB(145, 140, 160),
		text = Color3.fromRGB(238, 236, 245),
		value = Color3.fromRGB(220, 215, 235),
		accent = Color3.fromRGB(160, 90, 255),
		accent2 = Color3.fromRGB(110, 50, 170),
	},
	Emerald = {
		bg = Color3.fromRGB(9, 11, 10),
		panel = Color3.fromRGB(15, 18, 16),
		panel2 = Color3.fromRGB(19, 23, 20),
		stroke = Color3.fromRGB(75, 90, 80),
		strokeSoft = Color3.fromRGB(40, 54, 46),
		label = Color3.fromRGB(175, 190, 180),
		muted = Color3.fromRGB(140, 160, 150),
		text = Color3.fromRGB(238, 245, 241),
		value = Color3.fromRGB(220, 235, 228),
		accent = Color3.fromRGB(50, 200, 140),
		accent2 = Color3.fromRGB(30, 120, 85),
	},
	Mono = {
		bg = Color3.fromRGB(10, 10, 10),
		panel = Color3.fromRGB(17, 17, 17),
		panel2 = Color3.fromRGB(22, 22, 22),
		stroke = Color3.fromRGB(75, 75, 75),
		strokeSoft = Color3.fromRGB(45, 45, 45),
		label = Color3.fromRGB(185, 185, 185),
		muted = Color3.fromRGB(150, 150, 150),
		text = Color3.fromRGB(240, 240, 240),
		value = Color3.fromRGB(230, 230, 230),
		accent = Color3.fromRGB(200, 200, 200),
		accent2 = Color3.fromRGB(130, 130, 130),
	},
}

local THEME = {
	bg = PulseUI.Themes.Default.bg,
	panel = PulseUI.Themes.Default.panel,
	panel2 = PulseUI.Themes.Default.panel2,
	stroke = PulseUI.Themes.Default.stroke,
	strokeSoft = PulseUI.Themes.Default.strokeSoft,
	label = PulseUI.Themes.Default.label,
	muted = PulseUI.Themes.Default.muted,
	text = PulseUI.Themes.Default.text,
	value = PulseUI.Themes.Default.value,
	accent = PulseUI.Themes.Default.accent,
	accent2 = PulseUI.Themes.Default.accent2,
}

local function applyTheme(theme)
	for k, v in pairs(theme) do
		THEME[k] = v
	end
end

local function themeNames()
	local names = {}
	for k in pairs(PulseUI.Themes) do
		table.insert(names, k)
	end
	table.sort(names)
	return names
end

local function create(className, props)
	local inst = Instance.new(className)
	for k, v in pairs(props or {}) do
		inst[k] = v
	end
	return inst
end

local function addCorner(parent, radius)
	local c = create("UICorner", { CornerRadius = UDim.new(0, radius or 6) })
	c.Parent = parent
	return c
end

local function addStroke(parent, thickness, color, transparency)
	local s = create("UIStroke", {
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		Thickness = thickness or 1,
		Color = color or THEME.stroke,
		Transparency = transparency or 0,
	})
	s.Parent = parent
	return s
end

local function addPadding(parent, pad)
	local p = create("UIPadding", {
		PaddingTop = UDim.new(0, pad),
		PaddingBottom = UDim.new(0, pad),
		PaddingLeft = UDim.new(0, pad),
		PaddingRight = UDim.new(0, pad),
	})
	p.Parent = parent
	return p
end

local function makeLabel(parent, text, size, color, alignment)
	local lbl = create("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Text = text or "",
		Font = Enum.Font.Gotham,
		TextSize = size or 12,
		TextColor3 = color or THEME.text,
		TextXAlignment = alignment or Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Center,
		RichText = false,
	})
	lbl.Parent = parent
	return lbl
end

local function tween(inst, t, props)
	local tw = TweenService:Create(inst, TweenInfo.new(t or 0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), props)
	tw:Play()
	return tw
end

local function safeCall(fn, ...)
	local ok, res = pcall(fn, ...)
	if ok then return true, res end
	return false, res
end

local function encodeUDim2(u)
	return {
		s = { x = u.X.Scale, xo = u.X.Offset, y = u.Y.Scale, yo = u.Y.Offset },
	}
end

local function decodeUDim2(t)
	local s = t and t.s
	if type(s) ~= "table" then return UDim2.new() end
	return UDim2.new(tonumber(s.x) or 0, tonumber(s.xo) or 0, tonumber(s.y) or 0, tonumber(s.yo) or 0)
end

local function encodeValue(v)
	local tv = typeof(v)
	if tv == "Color3" then
		return { __t = "Color3", r = v.R, g = v.G, b = v.B }
	elseif tv == "EnumItem" then
		local enumName = ""
		pcall(function()
			enumName = tostring(v.EnumType.Name)
		end)
		if enumName == "" then
			-- Fallback (often yields "Enum.KeyCode")
			enumName = tostring(v.EnumType)
		end
		return { __t = "Enum", enum = enumName, name = v.Name }
	elseif tv == "UDim2" then
		return { __t = "UDim2", s = encodeUDim2(v).s }
	elseif tv == "Vector2" then
		return { __t = "Vector2", x = v.X, y = v.Y }
	elseif type(v) == "table" then
		local out = { __t = "Table" }
		for k, vv in pairs(v) do
			local ok, enc = pcall(encodeValue, vv)
			if ok then
				out[tostring(k)] = enc
			end
		end
		return out
	elseif tv == "Instance" or tv == "RBXScriptConnection" or type(v) == "function" or type(v) == "userdata" or type(v) == "thread" then
		-- Not JSON-serializable; omit.
		return nil
	else
		return v
	end
end

local function decodeValue(v)
	if type(v) ~= "table" or type(v.__t) ~= "string" then
		return v
	end
	if v.__t == "Color3" then
		return Color3.new(tonumber(v.r) or 1, tonumber(v.g) or 1, tonumber(v.b) or 1)
	elseif v.__t == "Enum" then
		local enumName = tostring(v.enum or "")
		-- Accept both "KeyCode" and "Enum.KeyCode".
		if enumName:sub(1, 5) == "Enum." then
			enumName = enumName:sub(6)
		end
		local itemName = tostring(v.name or "")
		local enumType = Enum[enumName]
		if enumType and enumType[itemName] then
			return enumType[itemName]
		end
		return nil
	elseif v.__t == "UDim2" then
		return decodeUDim2(v)
	elseif v.__t == "Vector2" then
		return Vector2.new(tonumber(v.x) or 0, tonumber(v.y) or 0)
	elseif v.__t == "Table" then
		local out = {}
		for k, vv in pairs(v) do
			if k ~= "__t" then
				out[k] = decodeValue(vv)
			end
		end
		return out
	end
	return v
end

local TAP_SLOP = 10

local function toV2(pos)
	if typeof(pos) == "Vector2" then return pos end
	if typeof(pos) == "Vector3" then return Vector2.new(pos.X, pos.Y) end
	return Vector2.new(0, 0)
end

local function connectTap(button, onTap)
	-- Prefer Roblox's unified activation signal when available.
	-- This is more reliable across mouse/touch and some executor input edge-cases.
	if button and typeof(button) == "Instance" and button:IsA("GuiButton") and button.Activated then
		button.Activated:Connect(function()
			onTap()
		end)
		return
	end

	local startPos
	local tracking = false
	local inputRef
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			tracking = true
			startPos = toV2(input.Position)
			inputRef = input
		end
	end)
	button.InputEnded:Connect(function(input)
		if not tracking then return end
		if inputRef and input ~= inputRef and input.UserInputType == Enum.UserInputType.Touch then return end
		tracking = false
		local delta = (toV2(input.Position) - startPos)
		if math.abs(delta.X) <= TAP_SLOP and math.abs(delta.Y) <= TAP_SLOP then
			onTap()
		end
	end)
end

local function cloneTable(t)
	if type(table.clone) == "function" then
		return table.clone(t)
	end
	local out = {}
	for k, v in pairs(t or {}) do
		out[k] = v
	end
	return out
end

local function isPhoneViewport(vp)
	-- Simple heuristic: phones are typically narrow.
	return vp.X <= 650
end

local function applyPopupIn(frame)
	local delayTime = 0.06
	frame.Visible = true
	frame.BackgroundTransparency = frame.BackgroundTransparency
	frame.ClipsDescendants = true
	frame.AnchorPoint = frame.AnchorPoint
	frame.Position = frame.Position
	frame.Size = frame.Size
	local s = frame:FindFirstChild("PopupScale")
	if not s then
		s = create("UIScale", { Name = "PopupScale", Scale = 1 })
		s.Parent = frame
	end
	s.Scale = 0.96
	frame.Visible = true
	taskDelay(delayTime, function()
		if s.Parent then
			tween(s, 0.14, { Scale = 1 })
		end
	end)
end

local function clamp01(x)
	if x < 0 then return 0 end
	if x > 1 then return 1 end
	return x
end

local function formatNumber(n)
	if type(n) ~= "number" then return tostring(n) end
	if math.abs(n) >= 100 then return tostring(math.floor(n + 0.5)) end
	local s = string.format("%.2f", n)
	s = s:gsub("0+$", ""):gsub("%.$", "")
	return s
end

local function hsvToColor3(h, s, v)
	return Color3.fromHSV(math.clamp(h, 0, 1), math.clamp(s, 0, 1), math.clamp(v, 0, 1))
end

local function color3ToHsv(c)
	local h, s, v = c:ToHSV()
	return h, s, v
end

-- Drag helper (mouse + touch)
local function makeDraggable(dragHandle, dragTarget)
	local dragging = false
	local dragStart, startPos
	local dragInput

	local function update(input)
		local delta = input.Position - dragStart
		dragTarget.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	dragHandle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = dragTarget.Position
			dragInput = input

			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)
end

-- Window object
local Window = {}
Window.__index = Window

-- Tab object
local Tab = {}
Tab.__index = Tab

-- Group object
local Group = {}
Group.__index = Group

local function ensureFolder(path)
	if type(makefolder) == "function" and type(isfolder) == "function" then
		if not isfolder(path) then
			safeCall(makefolder, path)
		end
	end
end

local function listConfigFiles(path)
	if type(listfiles) ~= "function" then return {} end
	local ok, files = safeCall(listfiles, path)
	if not ok or type(files) ~= "table" then return {} end
	local out = {}
	for _, f in ipairs(files) do
		if tostring(f):sub(-5) == ".json" then
			local name = tostring(f):match("([^/\\]+)%.json$")
			if name then table.insert(out, name) end
		end
	end
	table.sort(out)
	return out
end

function PulseUI:CreateWindow(opts)
	opts = opts or {}
	local title = opts.Title or "Pulse"
	local footerText = opts.FooterText or "Pulse V1 by Specter"
	local parent = opts.Parent
		or (type(gethui) == "function" and gethui())
		or game:GetService("CoreGui")
		or game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")

	local gui = create("ScreenGui", {
		Name = "PulseUI_V1",
		ResetOnSpawn = false,
		IgnoreGuiInset = true,
	})
	gui.Parent = parent

	local root = create("Frame", {
		Name = "Root",
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 820, 0, 430),
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
	})
	root.Parent = gui
	addCorner(root, 4)
	addStroke(root, 1, THEME.stroke, 0)
	addStroke(root, 4, THEME.accent, 0.72) -- thicker neon-ish glow outline

	local topLine = create("Frame", {
		Name = "TopLine",
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 0, 2),
	})
	topLine.Parent = root
	create("UIGradient", {
		Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, THEME.accent),
			ColorSequenceKeypoint.new(1, THEME.accent2),
		}),
		Rotation = 0,
	}).Parent = topLine

	local scale = create("UIScale", { Scale = 1 })
	scale.Parent = root

	local function updateScale()
		local cam = workspace.CurrentCamera
		local vp = cam and cam.ViewportSize or Vector2.new(1280, 720)
		local baseX, baseY = 900, 520
		local s = math.min(vp.X / baseX, vp.Y / baseY)
		if isPhoneViewport(vp) then
			s = math.clamp(s, 0.55, 0.92)
		else
			s = math.clamp(s, 0.78, 1.05)
		end
		scale.Scale = s
	end
	updateScale()
	if workspace.CurrentCamera then
		workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
	end

	local topBar = create("Frame", {
		Name = "TopBar",
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 24),
	})
	topBar.Parent = root
	topBar.BackgroundTransparency = 1

	local titleLabel = makeLabel(topBar, title, 12, Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Left)
	titleLabel.Position = UDim2.new(0, 10, 0, 2)
	titleLabel.Size = UDim2.new(1, -20, 1, -4)
	titleLabel.TextTransparency = 0.12

	local body = create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 24),
		Size = UDim2.new(1, 0, 1, -24),
	})
	body.Parent = root

	local bottomBar = create("Frame", {
		Name = "BottomBar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, 0),
		Size = UDim2.new(1, 0, 0, 22),
		ZIndex = 2,
	})
	bottomBar.Parent = root

	local footerLbl = makeLabel(bottomBar, footerText, 11, Color3.fromRGB(255, 255, 255), Enum.TextXAlignment.Center)
	footerLbl.Position = UDim2.new(0.5, 0, 0, 0)
	footerLbl.AnchorPoint = Vector2.new(0.5, 0)
	footerLbl.Size = UDim2.new(0.7, 0, 1, 0)
	footerLbl.TextTransparency = 0.18
	footerLbl.ZIndex = 3

	local sidebar = create("Frame", {
		Name = "Sidebar",
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 175, 1, 0),
	})
	sidebar.Parent = body
	addStroke(sidebar, 1, THEME.strokeSoft, 0)

	local sidePad = addPadding(sidebar, 10)
	sidePad.PaddingTop = UDim.new(0, 12)
	sidePad.PaddingBottom = UDim.new(0, 10)

	local playerCard = create("Frame", {
		Name = "PlayerCard",
		BackgroundColor3 = THEME.panel,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0, 1),
		Position = UDim2.new(0, 0, 1, -6),
		Size = UDim2.new(1, 0, 0, 44),
	})
	playerCard.Parent = sidebar
	addCorner(playerCard, 3)
	playerCard.ZIndex = 2
	addPadding(playerCard, 8)

	local avatar = create("ImageLabel", {
		Name = "Avatar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 28, 0, 28),
		Position = UDim2.new(0, 0, 0.5, -14),
		Image = "",
		ZIndex = 3,
	})
	avatar.Parent = playerCard
	addCorner(avatar, 999)

	local display = makeLabel(playerCard, "Player", 12, THEME.text, Enum.TextXAlignment.Left)
	display.Position = UDim2.new(0, 36, 0, 6)
	display.Size = UDim2.new(1, -36, 0, 14)
	display.ZIndex = 3

	local user = makeLabel(playerCard, "@username", 11, THEME.muted, Enum.TextXAlignment.Left)
	user.Position = UDim2.new(0, 36, 0, 22)
	user.Size = UDim2.new(1, -36, 0, 14)
	user.TextTransparency = 0.3
	user.ZIndex = 3

	local lp = Players.LocalPlayer
	if lp then
		display.Text = lp.DisplayName
		user.Text = "@" .. lp.Name
		safeCall(function()
			local content, _ = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
			avatar.Image = content
		end)
	end

	local tabsScroll = create("ScrollingFrame", {
		Name = "TabsScroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, -58),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollBarThickness = 3,
		ScrollBarImageColor3 = THEME.accent2,
		AutomaticCanvasSize = Enum.AutomaticSize.Y,
	})
	tabsScroll.Parent = sidebar

	local tabsHolder = create("Frame", {
		Name = "Tabs",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	tabsHolder.Parent = tabsScroll

	local sideList = create("UIListLayout", {
		Padding = UDim.new(0, 8),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Left,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	sideList.Parent = tabsHolder

	local content = create("Frame", {
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 175, 0, 0),
		Size = UDim2.new(1, -175, 1, 0),
	})
	content.Parent = body

	local pages = create("Frame", {
		Name = "Pages",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(1, 0, 1, 0),
	})
	pages.Parent = content
	addPadding(pages, 14)

	local overlay = create("Frame", {
		Name = "Overlay",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 50,
	})
	overlay.Parent = gui

	-- Detect if mobile
	local isMobile = UIS.TouchEnabled and not UIS.KeyboardEnabled
	
	-- Open/Close button (only for mobile, all black box)
	local openCloseBtn = create("TextButton", {
		Name = "OpenCloseButton",
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),  -- All black
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 1),
		Position = UDim2.new(1, -20, 1, -20),
		Size = UDim2.new(0, 50, 0, 50),
		AutoButtonColor = false,
		Text = "",  -- No text
		Visible = isMobile,  -- Only visible on mobile
		ZIndex = 95,
	})
	openCloseBtn.Parent = gui
	addCorner(openCloseBtn, 8)
	addStroke(openCloseBtn, 2, Color3.fromRGB(30, 30, 30), 0)  -- Dark stroke
	
	-- No icon label needed
	local iconLabel = nil
	
	-- Make draggable
	makeDraggable(openCloseBtn, openCloseBtn)
	
	-- Legacy open button for compatibility
	local openBtn = openCloseBtn

	-- top-right small circle buttons
	local circles = create("Frame", {
		Name = "TopRightButtons",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, -8, 0, 6),
		Size = UDim2.new(0, 72, 0, 12),
		ZIndex = 5,
	})
	circles.Parent = root

	local function circleButton(order)
		local b = create("TextButton", {
			BackgroundColor3 = THEME.strokeSoft,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 10, 0, 10),
			Position = UDim2.new(1, -(order * 14), 0, 1),
			AnchorPoint = Vector2.new(1, 0),
			AutoButtonColor = false,
			Text = "",
			ZIndex = 6,
		})
		b.Parent = circles
		addCorner(b, 999)
		return b
	end

	local btnFull = circleButton(3)
	local btnMin = circleButton(2)
	local btnClose = circleButton(1)

	makeDraggable(topBar, root)
	applyPopupIn(root)

	local self = setmetatable({
		Gui = gui,
		Root = root,
		Sidebar = sidebar,
		SidebarList = tabsHolder,
		Pages = pages,
		Overlay = overlay,
		BottomBar = bottomBar,
		FooterLabel = footerLbl,
		PlayerCard = playerCard,
		_Minimized = false,
		_ToggleKey = Enum.KeyCode.RightShift,
		_ThemeName = "Default",
		Flags = {},
		_Registry = {},
		_ConfigMemory = {},
		_Tabs = {},
		_Selected = nil,
		_OpenButton = openBtn,
		_TabDividers = {},
		_TabDividerCounts = {},
		_AutoDividerOrder = -1000001,
		_TabDividerMeta = {},
		_NextTabIndex = 0,
	}, Window)

	-- Bottom-right resize handle (desktop only)
	if not isMobile then
		local resizeBtn = create("TextButton", {
			Name = "ResizeHandle",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -6, 1, -6),
			Size = UDim2.new(0, 18, 0, 18),
			AutoButtonColor = false,
			Text = "",
			ZIndex = 6,
		})
		resizeBtn.Parent = root

		local icon = create("Frame", {
			Name = "Icon",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 7,
		})
		icon.Parent = resizeBtn
		for i = 1, 3 do
			local line = create("Frame", {
				BackgroundColor3 = THEME.stroke,
				BorderSizePixel = 0,
				AnchorPoint = Vector2.new(1, 1),
				Position = UDim2.new(1, -2, 1, -(2 + (i - 1) * 4)),
				Size = UDim2.new(0, 10 - (i - 1) * 2, 0, 1),
				ZIndex = 7,
			})
			line.Rotation = 45
			line.Parent = icon
		end

		local resizing = false
		local startPos
		local startSize
		local minW, minH = 560, 320
		local maxW, maxH = 1100, 720

		resizeBtn.InputBegan:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			if self._Fullscreen then
				return
			end
			resizing = true
			startPos = toV2(input.Position)
			local sz = self.Root and self.Root.AbsoluteSize
			startSize = sz and Vector2.new(sz.X, sz.Y) or Vector2.new(820, 430)
		end)

		resizeBtn.InputEnded:Connect(function(input)
			if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			resizing = false
		end)

		UIS.InputChanged:Connect(function(input)
			if not resizing then return end
			if input.UserInputType ~= Enum.UserInputType.MouseMovement and input.UserInputType ~= Enum.UserInputType.Touch then
				return
			end
			if not self.Root then return end
			local delta = toV2(input.Position) - (startPos or Vector2.new())
			local w = math.clamp((startSize.X + delta.X), minW, maxW)
			local h = math.clamp((startSize.Y + delta.Y), minH, maxH)
			self.Root.Size = UDim2.new(0, math.floor(w + 0.5), 0, math.floor(h + 0.5))
			self._PrevSize = self.Root.Size
		end)

		self._ResizeHandle = resizeBtn
	end

	local function setHidden(hidden)
		if not self.Root or not self.Root.Parent then return end
		self.Root.Visible = not hidden
		if isMobile and openCloseBtn and openCloseBtn.Parent then
			openCloseBtn.Visible = true  -- Always visible on mobile
		end
		if not hidden then
			self._Minimized = false
			body.Visible = true
			applyPopupIn(self.Root)
		end
	end

	if isMobile then
		connectTap(openCloseBtn, function()
			if self.Root and self.Root.Parent then
				local isVisible = self.Root.Visible
				setHidden(isVisible)
			else
				-- UI was destroyed, hide the button
				if openCloseBtn and openCloseBtn.Parent then
					openCloseBtn:Destroy()
				end
			end
		end)
	end

	connectTap(btnClose, function()
		-- Close UI = destroy it completely
		if self.Gui then
			self.Gui:Destroy()
			self.Gui = nil
			self.Root = nil
		end
	end)

	connectTap(btnMin, function()
		-- Minimize = same as close button, just hide
		setHidden(true)
	end)

	connectTap(btnFull, function()
		self:SetFullscreen(not self._Fullscreen)
	end)

	-- Keybind support (for PC users)
	UIS.InputBegan:Connect(function(input, gp)
		if gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == self._ToggleKey then
			setHidden(self.Root.Visible)
		end
	end)

	-- Startup loading pulse animation (3 pulses, then show UI)
	self.Root.Visible = false
	local loadBox = create("Frame", {
		Name = "LoadBox",
		BackgroundColor3 = THEME.panel,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 280, 0, 170),
		ZIndex = 95,
	})
	loadBox.Parent = gui
	addCorner(loadBox, 8)
	addStroke(loadBox, 1, THEME.stroke, 0.25)
	local lp = Players.LocalPlayer
	local avatarImg = create("ImageLabel", {
		Name = "LoadAvatar",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0),
		Position = UDim2.new(0.5, 0, 0, 16),
		Size = UDim2.new(0, 88, 0, 88),
		Image = (lp and ("rbxthumb://type=AvatarHeadShot&id=" .. tostring(lp.UserId) .. "&w=180&h=180")) or "",
		ZIndex = 96,
	})
	avatarImg.Parent = loadBox
	addCorner(avatarImg, 999)
	local userText = makeLabel(loadBox, lp and ("@" .. lp.Name) or "@Player", 13, THEME.value, Enum.TextXAlignment.Center)
	userText.AnchorPoint = Vector2.new(0.5, 0)
	userText.Position = UDim2.new(0.5, 0, 0, 112)
	userText.Size = UDim2.new(1, -20, 0, 18)
	userText.ZIndex = 96
	local loadText = makeLabel(loadBox, "Loading Pulse...", 12, THEME.muted, Enum.TextXAlignment.Center)
	loadText.AnchorPoint = Vector2.new(0.5, 0)
	loadText.Position = UDim2.new(0.5, 0, 0, 134)
	loadText.Size = UDim2.new(1, -20, 0, 18)
	loadText.ZIndex = 96
	local lbScale = create("UIScale", { Name = "PopupScale", Scale = 1 })
	lbScale.Parent = loadBox

	taskSpawn(function()
		lbScale.Scale = 0.86
		loadBox.Visible = true
		for _ = 1, 3 do
			tween(lbScale, 0.14, { Scale = 1.06 })
			taskWait(0.18)
			tween(lbScale, 0.14, { Scale = 0.90 })
			taskWait(0.18)
		end
		taskWait(0.20)
		if loadBox.Parent then
			loadBox:Destroy()
		end
		if self.Gui and self.Root then
			setHidden(false)
		end
	end)

	-- built-in Settings tab
	local settingsTab = self:CreateTab("Settings")
	self.SettingsTab = settingsTab
	-- Do not force Settings selected by default.
	settingsTab.Page.Visible = false
	settingsTab.Accent.Visible = false
	settingsTab.Button.BackgroundTransparency = 1
	settingsTab.ButtonText.TextColor3 = THEME.muted
	self._Selected = nil

	-- Home tab: created by default (can be disabled with HomeTab = false)
	-- Passing a table customizes the Home dashboard.
	if opts.HomeTab ~= false then
		local homeOpts = (type(opts.HomeTab) == "table") and opts.HomeTab or {}
		local ok, err = pcall(function()
			self:CreateHomeTab(homeOpts)
		end)
		if not ok then
			warn("[Pulse] CreateHomeTab failed:", err)
		end
	end

	-- Settings background image (subtle game icon)
	local bg = create("ImageLabel", {
		Name = "SettingsBackground",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Image = "rbxthumb://type=GameIcon&id=" .. tostring(game.PlaceId) .. "&w=150&h=150",
		ImageTransparency = 0.92,
		ScaleType = Enum.ScaleType.Fit,
		ZIndex = 0,
	})
	bg.Parent = settingsTab.Page
	local uiGroup = settingsTab:CreateGroup("UI", "left")
	local cfgGroup = settingsTab:CreateGroup("Config", "right")
	local streamerGroup = settingsTab:CreateGroup("Streamer Mode", "left")
	local infoGroup = settingsTab:CreateGroup("Info", "right")
	
	-- Store references to player card elements
	self._PlayerCardDisplay = display
	self._PlayerCardUsername = user
	self._OriginalDisplayName = lp and lp.DisplayName or "Player"
	self._OriginalUsername = lp and lp.Name or "username"

	uiGroup:AddKeybind("Toggle Key", self._ToggleKey, function(kc)
		self:SetToggleKey(kc)
	end, "ui.toggleKey")

	uiGroup:AddDropdown("Theme", themeNames(), self._ThemeName, function(name)
		self:SetTheme(name)
	end, "ui.theme")

	local cfgName = "default"
	local cfgNameBox = cfgGroup:AddTextBox("Config Name", cfgName, function(txt)
		cfgName = txt
	end)

	local cfgList = self:ListConfigs()
	local selectedCfg = cfgList[1] or "default"
	local cfgDropdown = cfgGroup:AddDropdown("Configs", cfgList, selectedCfg, function(v)
		selectedCfg = v
	end)

	cfgGroup:AddButton("Save", function()
		local name = cfgName
		if cfgNameBox and cfgNameBox.Get then
			name = cfgNameBox.Get()
		end
		name = tostring(name or "")
		if name == "" then
			name = tostring(selectedCfg or "default")
		end
		local ok, err = self:SaveConfig(name)
		cfgDropdown.SetOptions(self:ListConfigs(), name)
		selectedCfg = cfgDropdown.Get()
		if cfgNameBox and cfgNameBox.Set then
			cfgNameBox.Set(selectedCfg)
		end
		if ok then
			self:Notify({ Title = "Config", Text = "Saved: " .. tostring(selectedCfg), Duration = 2 })
		else
			self:Notify({ Title = "Config", Text = "Save failed: " .. tostring(err or "unknown"), Duration = 3 })
		end
	end)
	cfgGroup:AddButton("Load", function()
		local ok, err = self:LoadConfig(selectedCfg)
		if ok then
			self:Notify({ Title = "Config", Text = "Loaded: " .. tostring(selectedCfg), Duration = 2 })
		else
			self:Notify({ Title = "Config", Text = "Load failed: " .. tostring(err or "unknown"), Duration = 3 })
		end
	end)
	cfgGroup:AddButton("Delete", function()
		local target = tostring(selectedCfg or "")
		if target == "" then
			self:Notify({ Title = "Config", Text = "Nothing selected", Duration = 2 })
			return
		end
		local ok, err = self:DeleteConfig(target)
		-- Keep 'default' always selectable; after delete, fall back to default.
		cfgDropdown.SetOptions(self:ListConfigs(), "default")
		selectedCfg = cfgDropdown.Get()
		if cfgNameBox and cfgNameBox.Set then
			cfgNameBox.Set(selectedCfg)
		end
		if ok then
			local msg = (target == "default") and "Cleared: default" or ("Deleted: " .. target)
			self:Notify({ Title = "Config", Text = msg, Duration = 2 })
		else
			self:Notify({ Title = "Config", Text = "Delete failed: " .. tostring(err or "unknown"), Duration = 3 })
		end
	end)
	
	-- Streamer Mode Section
	self._HideUsername = false
	self._HideDisplayName = false
	self._CustomUsername = ""
	self._CustomDisplayName = ""
	
	streamerGroup:AddToggle("Hide Username", false, function(v)
		self._HideUsername = v
		self:_applyStreamerMode()
	end, "streamer.hideUsername")
	
	streamerGroup:AddToggle("Hide Display Name", false, function(v)
		self._HideDisplayName = v
		self:_applyStreamerMode()
	end, "streamer.hideDisplayName")
	
	streamerGroup:AddTextBox("Custom Username", "", function(v)
		self._CustomUsername = v
		self:_applyStreamerMode()
	end, "streamer.customUsername")
	
	streamerGroup:AddTextBox("Custom Display Name", "", function(v)
		self._CustomDisplayName = v
		self:_applyStreamerMode()
	end, "streamer.customDisplayName")
	
	streamerGroup:AddButton("Reset to Original", function()
		self._HideUsername = false
		self._HideDisplayName = false
		self._CustomUsername = ""
		self._CustomDisplayName = ""
		self:SetFlag("streamer.hideUsername", false)
		self:SetFlag("streamer.hideDisplayName", false)
		self:SetFlag("streamer.customUsername", "")
		self:SetFlag("streamer.customDisplayName", "")
		self:_applyStreamerMode()
	end)

	local lp2 = Players.LocalPlayer
	infoGroup:AddLabel("User")
	infoGroup:AddLabel(lp2 and (lp2.DisplayName .. " (@" .. lp2.Name .. ")") or "Unknown")
	infoGroup:AddLabel("Game")
	infoGroup:AddLabel("PlaceId: " .. tostring(game.PlaceId))
	infoGroup:AddLabel("JobId: " .. tostring(game.JobId):sub(1, 20) .. "...")
	infoGroup:AddButton("Copy Discord", function()
		if self._CopyDiscordHandler then
			self._CopyDiscordHandler()
			return
		end
		if type(setclipboard) == "function" then
			setclipboard("")
		end
	end)

	return self
end

function Window:SetToggleKey(keyCode)
	self._ToggleKey = keyCode
end

function Window:_applyStreamerMode()
	if not self._PlayerCardDisplay or not self._PlayerCardUsername then return end
	
	local displayText = self._OriginalDisplayName or "Player"
	local usernameText = "@" .. (self._OriginalUsername or "username")
	
	-- Apply custom names if provided
	if self._CustomDisplayName and self._CustomDisplayName ~= "" then
		displayText = self._CustomDisplayName
	elseif self._HideDisplayName then
		displayText = string.rep("*", #displayText)
	end
	
	if self._CustomUsername and self._CustomUsername ~= "" then
		usernameText = "@" .. self._CustomUsername
	elseif self._HideUsername then
		local nameOnly = usernameText:sub(2) -- Remove @ symbol
		usernameText = "@" .. string.rep("*", #nameOnly)
	end
	
	self._PlayerCardDisplay.Text = displayText
	self._PlayerCardUsername.Text = usernameText
end

function Window:SetFullscreen(enabled)
	enabled = enabled and true or false
	self._Fullscreen = enabled
	if not self.Root then return end
	if enabled then
		self._PrevPos = self._PrevPos or self.Root.Position
		self._PrevSize = self._PrevSize or self.Root.Size
		self._PrevAnchor = self._PrevAnchor or self.Root.AnchorPoint
		self.Root.AnchorPoint = Vector2.new(0.5, 0.5)
		self.Root.Position = UDim2.new(0.5, 0, 0.5, 0)
		self.Root.Size = UDim2.new(1, -20, 1, -20)
	else
		if self._PrevAnchor then self.Root.AnchorPoint = self._PrevAnchor end
		if self._PrevPos then self.Root.Position = self._PrevPos end
		if self._PrevSize then self.Root.Size = self._PrevSize end
		self._PrevAnchor, self._PrevPos, self._PrevSize = nil, nil, nil
	end
end

function Window:SetFooterText(text)
	if self.FooterLabel then
		self.FooterLabel.Text = tostring(text or "")
	end
end

function Window:Destroy()
	if self.Gui then
		self.Gui:Destroy()
		self.Gui = nil
	end
	if self.Root then
		self.Root = nil
	end
end

function Window:Notify(options)
	options = options or {}
	local title = tostring(options.Title or "Notification")
	local content = tostring(options.Content or options.Text or "")
	local duration = tonumber(options.Duration)
	local icon = options.Icon

	if not self.Gui then return end

	local function autoDuration(text)
		local d = (utf8.len(text) or #text) * 0.06 + 2.5
		return math.clamp(d, 3, 10)
	end
	if duration == nil then
		duration = autoDuration(content)
	end

	local function formatElapsed(elapsed)
		if elapsed <= 4 then
			return "now"
		elseif elapsed < 60 then
			return tostring(math.floor(elapsed)) .. "s ago"
		elseif elapsed < 3600 then
			return tostring(math.floor(elapsed / 60)) .. "m ago"
		else
			return tostring(math.floor(elapsed / 3600)) .. "h ago"
		end
	end

	-- Create notification container if it doesn't exist
	if not self._NotifyContainer then
		self._NotifyContainer = create("Frame", {
			Name = "NotifyContainer",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 1),
			Position = UDim2.new(1, -18, 1, -18),
			Size = UDim2.new(0, 310, 1, -36),
			ZIndex = 200,
		})
		self._NotifyContainer.Parent = self.Gui

		local list = create("UIListLayout", {
			Padding = UDim.new(0, 10),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			VerticalAlignment = Enum.VerticalAlignment.Bottom,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		list.Parent = self._NotifyContainer
	end

	local notif = create("Frame", {
		Name = "Notification",
		BackgroundColor3 = THEME.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, -8, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		ZIndex = 201,
		BackgroundTransparency = 1,
	})
	notif.Parent = self._NotifyContainer
	addCorner(notif, 8)
	addPadding(notif, 12)
	addStroke(notif, 1, THEME.strokeSoft, 0.2)
	addStroke(notif, 2, THEME.accent, 0.88) -- subtle glow outline

	local top = create("Frame", {
		Name = "Top",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 20),
		ZIndex = 202,
	})
	top.Parent = notif

	local iconImg = create("ImageLabel", {
		Name = "Icon",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 18, 0, 18),
		ZIndex = 203,
		ImageTransparency = 0,
		ImageColor3 = THEME.value,
		Image = "",
	})
	iconImg.Parent = top
	if type(icon) == "number" then
		iconImg.Image = "rbxassetid://" .. tostring(icon)
	elseif type(icon) == "string" then
		iconImg.Image = icon
	else
		-- fallback: small dot
		iconImg.Image = ""
		iconImg.BackgroundTransparency = 0
		iconImg.BackgroundColor3 = THEME.accent
		addCorner(iconImg, 999)
	end

	local titleLabel = makeLabel(top, title, 13, THEME.text, Enum.TextXAlignment.Left)
	titleLabel.Name = "Title"
	titleLabel.Position = UDim2.new(0, 26, 0, 0)
	titleLabel.Size = UDim2.new(1, -90, 1, 0)
	titleLabel.ZIndex = 203

	local timeLabel = makeLabel(top, "now", 11, THEME.muted, Enum.TextXAlignment.Right)
	timeLabel.Name = "Time"
	timeLabel.AnchorPoint = Vector2.new(1, 0)
	timeLabel.Position = UDim2.new(1, 0, 0, 1)
	timeLabel.Size = UDim2.new(0, 70, 1, 0)
	timeLabel.ZIndex = 203
	timeLabel.TextTransparency = 0.25

	local body = create("TextLabel", {
		Name = "Content",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 26, 0, 22),
		Size = UDim2.new(1, -26, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = THEME.value,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
		TextWrapped = true,
		Text = content,
		ZIndex = 202,
	})
	body.Parent = notif
	body.TextTransparency = 1

	-- slide + fade in
	local startPos = notif.Position
	notif.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + 30, startPos.Y.Scale, startPos.Y.Offset)
	taskWait()
	tween(notif, 0.35, { BackgroundTransparency = 0, Position = startPos })
	tween(body, 0.35, { TextTransparency = 0.20 })

	local createdAt = os.clock()
	self._NotifyConns = self._NotifyConns or {}
	local conn
	conn = RunService.Heartbeat:Connect(function()
		if not notif or not notif.Parent then
			if conn then conn:Disconnect() end
			return
		end
		local elapsed = os.clock() - createdAt
		timeLabel.Text = formatElapsed(elapsed)
	end)
	table.insert(self._NotifyConns, conn)

	connectTap(notif, function()
		if notif and notif.Parent then
			notif:Destroy()
		end
	end)

	taskDelay(duration, function()
		if notif and notif.Parent then
			tween(notif, 0.25, { BackgroundTransparency = 1, Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + 60, startPos.Y.Scale, startPos.Y.Offset) })
			tween(body, 0.2, { TextTransparency = 1 })
			taskDelay(0.28, function()
				if notif and notif.Parent then
					notif:Destroy()
				end
			end)
		end
	end)
end

function Window:SetCopyDiscordHandler(fn)
	self._CopyDiscordHandler = fn
end

function Window:SetFlag(flag, value)
	if type(flag) ~= "string" then return end
	self.Flags = self.Flags or {}
	self.Flags[flag] = value
	local reg = self._Registry and self._Registry[flag]
	if reg and reg.Set then
		reg.Set(value)
	end
end

function Window:GetFlag(flag)
	self.Flags = self.Flags or {}
	return self.Flags[flag]
end

function Window:_registerFlag(flag, getters)
	if type(flag) ~= "string" then return end
	self._Registry = self._Registry or {}
	self.Flags = self.Flags or {}
	self._Registry[flag] = getters
	-- If a value already exists (e.g. config loaded before UI element exists), apply it.
	-- Otherwise seed the flag from the element's current state.
	if self.Flags[flag] ~= nil and getters and getters.Set then
		local existing = self.Flags[flag]
		taskSpawn(function()
			getters.Set(existing)
		end)
	elseif getters and getters.Get then
		self.Flags[flag] = getters.Get()
	end
end

-- Home tab (Buster-style dashboard with cards and avatar)
function Window:CreateHomeTab(opts)
	opts = opts or {}
	if self._HomeCreated then return end
	self._HomeCreated = true

	local supportedExecutors = opts.SupportedExecutors or {}
	local unsupportedExecutors = opts.UnsupportedExecutors or {}
	table.insert(unsupportedExecutors, "Roblox Studio")
	local discordInvite = tostring(opts.DiscordInvite or "")
	local changelog = opts.Changelog or {}
	
	local tab = self:CreateTab("Home")
	local content = tab.Page
	
	-- Get the columns frame that was created by CreateTab
	local columns = content:FindFirstChild("Columns")
	if not columns then return tab end
	
	local leftCol = columns:FindFirstChild("Left")
	local rightCol = columns:FindFirstChild("Right")
	if not leftCol or not rightCol then return tab end
	
	-- Hide the default scrolling frames inside columns since we'll create our own layout
	for _, col in ipairs({leftCol, rightCol}) do
		local scroll = col:FindFirstChild("Scroll")
		if scroll then
			scroll.Visible = false
		end
	end
	
	-- Helper: create card with header and body
	local function createCard(parent, titleText, subtitleText, height)
		local card = create("Frame", {
			Name = "HomeCard",
			BackgroundColor3 = THEME.panel,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, height),
		})
		addCorner(card, 12)
		addStroke(card, 1, THEME.strokeSoft, 0.55)
		card.Parent = parent
		
		local cardPad = create("UIPadding", {
			PaddingTop = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 10),
		})
		cardPad.Parent = card
		
		local headerRow = create("Frame", {
			Name = "HomeHeader",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 22),
		})
		headerRow.Parent = card
		
		local title = create("TextLabel", {
			Name = "HomeTitle",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Text = titleText or "",
			TextColor3 = THEME.text,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		title.Parent = headerRow
		
		local subtitle = nil
		if subtitleText and subtitleText ~= "" then
			subtitle = create("TextLabel", {
				Name = "HomeSubtitle",
				BackgroundTransparency = 1,
				Size = UDim2.new(1, 0, 0, 16),
				Position = UDim2.new(0, 0, 0, 26),
				Text = subtitleText,
				TextColor3 = THEME.label,
				TextSize = 11,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
			})
			subtitle.Parent = card
		end
		
		local body = create("Frame", {
			Name = "HomeBody",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, subtitle and 46 or 28),
			Size = UDim2.new(1, 0, 1, -(subtitle and 46 or 28)),
		})
		body.Parent = card
		
		return card, body
	end
	
	-- Welcome banner with backdrop (placed on columns frame, above left/right columns)
	local welcomeHeight = 110
	local topGap = 12
	
	local welcome = create("Frame", {
		Name = "HomeWelcome",
		BackgroundColor3 = THEME.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, welcomeHeight),
		Position = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
	})
	addCorner(welcome, 12)
	addStroke(welcome, 1, THEME.strokeSoft, 0.55)
	welcome.Parent = columns
	
	local backdrop = create("ImageLabel", {
		Name = "HomeBackdrop",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ScaleType = Enum.ScaleType.Crop,
		ImageTransparency = 0.55,
		Image = "",
		ZIndex = 3,
	})
	addCorner(backdrop, 12)
	backdrop.Parent = welcome
	
	if opts.Backdrop ~= nil then
		if opts.Backdrop == 0 then
			backdrop.Image = "https://www.roblox.com/asset-thumbnail/image?assetId=" .. game.PlaceId .. "&width=768&height=432&format=png"
		else
			backdrop.Image = "rbxassetid://" .. tostring(opts.Backdrop)
		end
	end
	
	local backdropFade = create("Frame", {
		Name = "HomeBackdropFade",
		BackgroundColor3 = THEME.panel,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 4,
	})
	addCorner(backdropFade, 12)
	backdropFade.Parent = welcome
	
	local welcomePad = create("UIPadding", {
		PaddingTop = UDim.new(0, 12),
		PaddingLeft = UDim.new(0, 12),
		PaddingRight = UDim.new(0, 12),
		PaddingBottom = UDim.new(0, 12),
	})
	welcomePad.Parent = welcome
	
	local welcomeContent = create("Frame", {
		Name = "HomeWelcomeContent",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ZIndex = 5,
	})
	welcomeContent.Parent = welcome
	
	-- Avatar
	local avatarWrap = create("Frame", {
		Name = "HomeAvatarWrap",
		BackgroundColor3 = THEME.panel2,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 54, 0, 54),
		Position = UDim2.new(0, 0, 0.5, -27),
		ZIndex = 6,
	})
	addCorner(avatarWrap, 27)
	addStroke(avatarWrap, 1, THEME.strokeSoft, 0.65)
	avatarWrap.Parent = welcomeContent
	
	local avatarImg = create("ImageLabel", {
		Name = "HomeAvatar",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		ScaleType = Enum.ScaleType.Crop,
		ZIndex = 7,
	})
	addCorner(avatarImg, 27)
	avatarImg.Parent = avatarWrap
	
	-- Load avatar async
	task.spawn(function()
		pcall(function()
			local lp = Players.LocalPlayer
			if lp and lp.UserId then
				local thumb = Players:GetUserThumbnailAsync(lp.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
				if avatarImg and avatarImg.Parent then
					avatarImg.Image = thumb
				end
			end
		end)
	end)
	
	-- Welcome text
	local welcomeTitle = create("TextLabel", {
		Name = "HomeWelcomeTitle",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 66, 0, 18),
		Size = UDim2.new(1, -220, 0, 22),
		Text = "Welcome, " .. tostring((Players.LocalPlayer and Players.LocalPlayer.DisplayName) or "User"),
		TextColor3 = THEME.text,
		TextSize = 18,
		Font = Enum.Font.GothamBold,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
	})
	welcomeTitle.Parent = welcomeContent
	
	local welcomeSub = create("TextLabel", {
		Name = "HomeWelcomeSub",
		BackgroundTransparency = 1,
		Position = UDim2.new(0, 66, 0, 42),
		Size = UDim2.new(1, -220, 0, 18),
		Text = "",
		TextColor3 = THEME.label,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		ZIndex = 6,
	})
	welcomeSub.Parent = welcomeContent
	
	local timeLabel = create("TextLabel", {
		Name = "HomeTime",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -8, 0, 20),
		Size = UDim2.new(0, 200, 0, 18),
		Text = "",
		TextColor3 = THEME.label,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 6,
	})
	timeLabel.Parent = welcomeContent
	
	local dateLabel = create("TextLabel", {
		Name = "HomeDate",
		BackgroundTransparency = 1,
		Position = UDim2.new(1, -8, 0, 42),
		Size = UDim2.new(0, 200, 0, 18),
		Text = "",
		TextColor3 = THEME.label,
		TextSize = 12,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Right,
		ZIndex = 6,
	})
	dateLabel.Parent = welcomeContent
	
	-- Greeting helper
	local function getGreetingString(hour)
		if hour >= 4 and hour < 12 then
			return "Good Morning!"
		end
		if hour >= 12 and hour < 19 then
			return "How's Your Day Going?"
		end
		if hour >= 19 and hour <= 23 then
			return "Sweet Dreams."
		end
		return "Jeez you should be asleep..."
	end
	
	-- Clock update loop
	task.spawn(function()
		while welcome and welcome.Parent do
			local t = os.date("*t")
			local formattedTime = string.format("%02d : %02d : %02d", t.hour, t.min, t.sec)
			timeLabel.Text = formattedTime
			dateLabel.Text = string.format("%02d / %02d / %02d", t.day, t.month, t.year % 100)
			local lp = Players.LocalPlayer
			local lpName = (lp and lp.Name) or "User"
			welcomeSub.Text = getGreetingString(t.hour) .. " | " .. tostring(lpName)
			task.wait(1)
		end
	end)
	
	-- Reposition the left and right columns below the welcome banner
	leftCol.Size = UDim2.new(0.58, -8, 1, -(welcomeHeight + topGap))
	leftCol.Position = UDim2.new(0, 0, 0, welcomeHeight + topGap)
	
	rightCol.Size = UDim2.new(0.42, -8, 1, -(welcomeHeight + topGap))
	rightCol.Position = UDim2.new(0.58, 16, 0, welcomeHeight + topGap)
	
	-- Create scrolling frames for cards
	local leftScroll = create("ScrollingFrame", {
		Name = "HomeLeftScroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
	})
	leftScroll.Parent = leftCol
	
	local leftLayout = create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 12),
	})
	leftLayout.Parent = leftScroll
	leftLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		leftScroll.CanvasSize = UDim2.new(0, 0, 0, leftLayout.AbsoluteContentSize.Y + 12)
	end)
	
	local rightScroll = create("ScrollingFrame", {
		Name = "HomeRightScroll",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		Size = UDim2.new(1, 0, 1, 0),
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ZIndex = 2,
	})
	rightScroll.Parent = rightCol
	
	local rightLayout = create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(0, 12),
	})
	rightLayout.Parent = rightScroll
	rightLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		rightScroll.CanvasSize = UDim2.new(0, 0, 0, rightLayout.AbsoluteContentSize.Y + 12)
	end)
	
	-- Discord card
	local discordCard = createCard(leftScroll, "Discord", "Tap to join the discord of\nyour script.", 88)
	local discordInteract = create("TextButton", {
		Name = "HomeDiscordInteract",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, 0, 1, 0),
	})
	discordInteract.Parent = discordCard
	discordInteract.MouseEnter:Connect(function()
		TweenService:Create(discordCard, TweenInfo.new(0.12), {BackgroundColor3 = THEME.panel2}):Play()
	end)
	discordInteract.MouseLeave:Connect(function()
		TweenService:Create(discordCard, TweenInfo.new(0.12), {BackgroundColor3 = THEME.panel}):Play()
	end)
	discordInteract.MouseButton1Click:Connect(function()
		if self._CopyDiscordHandler then
			local ok = pcall(function()
				self._CopyDiscordHandler()
			end)
			if ok then
				self:Notify({ Title = "Discord", Text = "Copied", Duration = 2 })
			else
				self:Notify({ Title = "Discord", Text = "Copy failed", Duration = 2 })
			end
			return
		end
		if discordInvite == "" then
			self:Notify({ Title = "Discord", Text = "No invite set", Duration = 2 })
			return
		end
		local link = tostring(discordInvite)
		if not link:find("discord", 1, true) then
			link = "https://discord.gg/" .. link
		end
		pcall(function()
			if type(setclipboard) == "function" then
				setclipboard(link)
			end
		end)
		self:Notify({ Title = "Discord", Text = "Invite copied", Duration = 2 })
	end)
	
	-- Server card with stats
	local gameName = "Unknown"
	pcall(function()
		gameName = MarketplaceService:GetProductInfo(game.PlaceId).Name
	end)
	local truncateName = gameName
	if #gameName > 26 then
		truncateName = string.sub(gameName, 1, 23) .. "***"
	end
	
	local serverCard, serverBody = createCard(leftScroll, "Server", "Currently Playing " .. truncateName .. "...", 250)
	
	local grid = create("Frame", {
		Name = "HomeServerGrid",
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
	})
	grid.Parent = serverBody
	
	local gridLayout = create("UIGridLayout", {
		CellPadding = UDim2.new(0, 10, 0, 10),
		CellSize = UDim2.new(0.5, -5, 0, 56),
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	gridLayout.Parent = grid
	
	-- Helper for stat tiles
	local function statTile(titleText)
		local tile = create("Frame", {
			Name = "HomeStatTile",
			BackgroundColor3 = THEME.panel2,
			BorderSizePixel = 0,
		})
		addCorner(tile, 10)
		addStroke(tile, 1, THEME.strokeSoft, 0.7)
		tile.Parent = grid
		
		local p = create("UIPadding", {
			PaddingTop = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 10),
			PaddingRight = UDim.new(0, 10),
			PaddingBottom = UDim.new(0, 8),
		})
		p.Parent = tile
		
		local title = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 16),
			Text = titleText,
			TextColor3 = THEME.text,
			TextSize = 11,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		title.Parent = tile
		
		local value = create("TextLabel", {
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 18),
			Size = UDim2.new(1, 0, 0, 30),
			Text = "",
			TextColor3 = THEME.label,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
		value.Parent = tile
		
		return tile, value
	end
	
	local tilePlayers, valPlayers = statTile("Players")
	local tileCapacity, valCapacity = statTile("Capacity")
	local tileLatency, valLatency = statTile("Latency")
	local tileJoin, valJoin = statTile("Join Script")
	local tileTime, valTime = statTile("Time")
	local tileRegion, valRegion = statTile("Region")
	
	valJoin.Text = "Click to copy"
	local joinInteract = create("TextButton", {
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		Text = "",
		Size = UDim2.new(1, 0, 1, 0),
	})
	joinInteract.Parent = tileJoin
	joinInteract.MouseButton1Click:Connect(function()
		local scriptText = string.format(
			'game:GetService("TeleportService"):TeleportToPlaceInstance(%d, "%s", game:GetService("Players").LocalPlayer)',
			game.PlaceId,
			tostring(game.JobId)
		)
		pcall(function()
			setclipboard(scriptText)
		end)
		self:Notify({ Title = "Server", Text = "Join script copied", Duration = 2 })
	end)
	
	local function updateCounts()
		valPlayers.Text = tostring(#Players:GetPlayers()) .. " Players\nIn This Server"
		valCapacity.Text = tostring(Players.MaxPlayers) .. " Players\nCan Join"
	end
	updateCounts()
	Players.PlayerAdded:Connect(updateCounts)
	Players.PlayerRemoving:Connect(updateCounts)
	
	task.spawn(function()
		pcall(function()
			local region = LocalizationService:GetCountryRegionForPlayerAsync(Players.LocalPlayer)
			if valRegion and valRegion.Parent then
				valRegion.Text = tostring(region)
			end
		end)
	end)
	
	local startTick = tick()
	local function formatElapsed(sec)
		sec = math.max(0, math.floor(sec))
		if sec < 60 then
			return tostring(sec) .. "s"
		end
		if sec < 3600 then
			return tostring(math.floor(sec / 60)) .. "m"
		end
		return tostring(math.floor(sec / 3600)) .. "h"
	end
	
	local fpsCounter = 0
	local lastFpsUpdate = tick()
	
	RunService.Heartbeat:Connect(function()
		fpsCounter += 1
		local now = tick()
		if now - lastFpsUpdate >= 1 then
			local pingMs = 0
			pcall(function()
				pingMs = math.round(Players.LocalPlayer:GetNetworkPing() * 1000)
			end)
			valLatency.Text = tostring(fpsCounter) .. " FPS\n" .. tostring(pingMs) .. "ms"
			valTime.Text = formatElapsed(now - startTick)
			fpsCounter = 0
			lastFpsUpdate = now
		end
	end)
	
	-- Changelog card
	local changelogCard, changelogBody = createCard(leftScroll, "Changelog", "", 250)
	
	if changelog[1] then
		local latest = changelog[1]
		local title = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 0, 18),
			Text = tostring(latest.Title or "Latest"),
			TextColor3 = THEME.text,
			TextSize = 13,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
		})
		title.Parent = changelogBody
		
		if latest.Date then
			local date = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 20),
				Size = UDim2.new(1, 0, 0, 16),
				Text = tostring(latest.Date),
				TextColor3 = THEME.label,
				TextSize = 11,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
			})
			date.Parent = changelogBody
		end
		
		if latest.Description then
			local desc = create("TextLabel", {
				BackgroundTransparency = 1,
				Position = UDim2.new(0, 0, 0, 40),
				Size = UDim2.new(1, 0, 1, -40),
				Text = tostring(latest.Description),
				TextColor3 = THEME.label,
				TextSize = 11,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				TextYAlignment = Enum.TextYAlignment.Top,
			})
			desc.Parent = changelogBody
		end
	else
		local empty = create("TextLabel", {
			BackgroundTransparency = 1,
			Size = UDim2.new(1, 0, 1, 0),
			Text = "No updates yet.",
			TextColor3 = THEME.label,
			TextSize = 11,
			Font = Enum.Font.Gotham,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		})
		empty.Parent = changelogBody
	end
	
	-- Account card (right column)
	local accountCard = createCard(rightScroll, "Account", "Coming Soon.", 88)
	
	-- Executor card
	local executorName = (identifyexecutor and identifyexecutor())
		or (getexecutorname and getexecutorname())
		or "Roblox Studio"
	
	local execCard, execBody = createCard(rightScroll, tostring(executorName), "", 88)
	
	local execText = "Your Executor Seems To Be\nSupported By This Script."
	if table.find(unsupportedExecutors, executorName) then
		execText = "Your Executor Is Unsupported\nBy This Script."
	elseif #supportedExecutors > 0 and not table.find(supportedExecutors, executorName) then
		execText = "Your Executor Is Unsupported\nBy This Script."
	end
	local execLabel = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = execText,
		TextColor3 = THEME.label,
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextWrapped = true,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
	execLabel.Parent = execBody
	
	-- Friends card placeholder
	local friendsCard, friendsBody = createCard(rightScroll, "Friends", "", 250)
	local friendsPlaceholder = create("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 1, 0),
		Text = "Coming Soon.",
		TextColor3 = THEME.label,
		TextSize = 11,
		Font = Enum.Font.Gotham,
		TextXAlignment = Enum.TextXAlignment.Left,
		TextYAlignment = Enum.TextYAlignment.Top,
	})
	friendsPlaceholder.Parent = friendsBody
	
	-- Select Home by default
	self:SelectTab(tab)
	
	return tab
end

function Window:SetTheme(nameOrTheme)
	local theme = nameOrTheme
	if type(nameOrTheme) == "string" then
		theme = PulseUI.Themes[nameOrTheme]
		self._ThemeName = nameOrTheme
	end
	if type(theme) ~= "table" then return end
	-- remap colors so existing instances update without heavy bookkeeping
	self._ThemeColors = self._ThemeColors or cloneTable(PulseUI.Themes.Default)
	local old = self._ThemeColors
	applyTheme(theme)
	local new = theme
	self._ThemeColors = cloneTable(new)

	local function remapColor(c)
		for k, oldC in pairs(old) do
			if typeof(oldC) == "Color3" and c == oldC then
				return new[k] or c
			end
		end
		return c
	end

	if self.Gui then
		for _, inst in ipairs(self.Gui:GetDescendants()) do
			if inst:IsA("Frame") or inst:IsA("TextButton") or inst:IsA("TextBox") or inst:IsA("ImageLabel") or inst:IsA("ImageButton") or inst:IsA("ScrollingFrame") then
				if inst.BackgroundTransparency < 1 then
					inst.BackgroundColor3 = remapColor(inst.BackgroundColor3)
				end
				if inst:IsA("TextButton") or inst:IsA("TextBox") then
					inst.TextColor3 = remapColor(inst.TextColor3)
				elseif inst:IsA("TextLabel") then
					inst.TextColor3 = remapColor(inst.TextColor3)
				end
				if inst:IsA("ScrollingFrame") then
					inst.ScrollBarImageColor3 = remapColor(inst.ScrollBarImageColor3)
				end
				if inst:IsA("ImageLabel") or inst:IsA("ImageButton") then
					inst.ImageColor3 = remapColor(inst.ImageColor3)
				end
			end
			if inst:IsA("TextLabel") then
				inst.TextColor3 = remapColor(inst.TextColor3)
			end
			if inst:IsA("UIStroke") then
				inst.Color = remapColor(inst.Color)
			end
		end
	end
end

function Window:_configPath(name)
	name = tostring(name or "")
	local supportsFolders = (type(makefolder) == "function" and type(isfolder) == "function")
	if supportsFolders then
		return "PulseConfigs/" .. name .. ".json"
	end
	return "PulseConfigs_" .. name .. ".json"
end

function Window:ListConfigs()
	local supportsFolders = (type(makefolder) == "function" and type(isfolder) == "function")
	local names = {}
	local seen = {}

	local function add(name)
		name = tostring(name or "")
		if name == "" then return end
		if not seen[name] then
			seen[name] = true
			table.insert(names, name)
		end
	end

	-- Always provide a sane default choice
	add("default")

	-- Pull from filesystem
	if supportsFolders then
		ensureFolder("PulseConfigs")
		for _, n in ipairs(listConfigFiles("PulseConfigs")) do
			add(n)
		end
	elseif type(listfiles) == "function" then
		local ok, files = safeCall(listfiles, "")
		if ok and type(files) == "table" then
			for _, f in ipairs(files) do
				local n = tostring(f):match("PulseConfigs_([^/\\]+)%.json$")
				if n then add(n) end
			end
		end
	end

	-- Pull from in-memory configs (always available)
	self._ConfigMemory = self._ConfigMemory or {}
	for k in pairs(self._ConfigMemory) do
		add(k)
	end

	table.sort(names)
	return names
end

function Window:SaveConfig(name)
	name = tostring(name or "")
	if name == "" then return false, "missing name" end
	
	-- Collect all flag values
	local flags = {}
	for k, v in pairs(self.Flags or {}) do
		local ok, enc = pcall(encodeValue, v)
		if ok then
			-- Skip nil/unsupported values rather than crashing the entire save.
			if enc ~= nil then
				flags[k] = enc
			end
		else
			warn("[Pulse] Failed to encode flag:", tostring(k))
		end
	end

	local toggleKeyName = "RightShift"
	if typeof(self._ToggleKey) == "EnumItem" and self._ToggleKey.EnumType == Enum.KeyCode then
		toggleKeyName = self._ToggleKey.Name
	elseif type(self._ToggleKey) == "string" and self._ToggleKey ~= "" then
		toggleKeyName = self._ToggleKey
	end
	
	-- Build config data
	local data = {
		flags = flags,
		theme = self._ThemeName or "Default",
		toggleKey = toggleKeyName,
		ui = {
			pos = encodeValue((self._PrevPos) or (self.Root and self.Root.Position) or UDim2.new(0.5, 0, 0.5, 0)),
			size = encodeValue((self._PrevSize) or (self.Root and self.Root.Size) or UDim2.new(0, 820, 0, 430)),
			anchor = encodeValue((self._PrevAnchor) or (self.Root and self.Root.AnchorPoint) or Vector2.new(0.5, 0.5)),
			visible = self.Root and self.Root.Visible or true,
			min = self._Minimized or false,
			full = self._Fullscreen or false,
			selected = self._Selected and self._Selected.Name or "",
			openBtnPos = self._OpenButton and encodeValue(self._OpenButton.Position) or nil,
		},
		streamerMode = {
			hideUsername = self._HideUsername or false,
			hideDisplayName = self._HideDisplayName or false,
			customUsername = self._CustomUsername or "",
			customDisplayName = self._CustomDisplayName or "",
		},
		version = "1.0",
	}
	
	local payload = HttpService:JSONEncode(data)
	
	-- Always save to memory first
	self._ConfigMemory = self._ConfigMemory or {}
	self._ConfigMemory[name] = payload
	
	-- Try to save to file system
	local supportsFolders = (type(makefolder) == "function" and type(isfolder) == "function")
	if supportsFolders then
		ensureFolder("PulseConfigs")
	end
	
	if type(writefile) == "function" then
		local path = self:_configPath(name)
		local ok, err = safeCall(writefile, path, payload)
		if ok then
			print("[Pulse] Config saved to file:", path)
			return true
		else
			warn("[Pulse] Failed to save config to file:", err)
		end
	end
	
	-- Fallback: already saved to memory
	print("[Pulse] Config saved to memory:", name)
	return true
end

function Window:LoadConfig(name)
	name = tostring(name or "")
	if name == "" then return false, "missing name" end
	
	local payload
	
	-- Try to load from file first
	local path = self:_configPath(name)
	if type(readfile) == "function" and type(isfile) == "function" then
		local exists, _ = safeCall(isfile, path)
		if exists then
			local ok, content = safeCall(readfile, path)
			if ok and type(content) == "string" then
				payload = content
				print("[Pulse] Config loaded from file:", path)
			end
		end
	end
	
	-- Fallback to memory
	if not payload then
		self._ConfigMemory = self._ConfigMemory or {}
		payload = self._ConfigMemory[name]
		if payload then
			print("[Pulse] Config loaded from memory:", name)
		end
	end
	
	if type(payload) ~= "string" then 
		warn("[Pulse] Config not found:", name)
		return false, "not found" 
	end
	
	-- Decode JSON
	local ok, decoded = safeCall(function()
		return HttpService:JSONDecode(payload)
	end)
	
	if not ok or type(decoded) ~= "table" then 
		warn("[Pulse] Failed to decode config:", name)
		return false, "bad json" 
	end
	
	-- Apply theme
	if type(decoded.theme) == "string" then
		self:SetTheme(decoded.theme)
	end
	
	-- Apply toggle key
	if decoded.toggleKey ~= nil then
		local tk = decoded.toggleKey
		if type(tk) == "table" then
			tk = decodeValue(tk)
		end
		if typeof(tk) == "EnumItem" and tk.EnumType == Enum.KeyCode then
			self:SetToggleKey(tk)
		elseif type(tk) == "string" then
			local kc = Enum.KeyCode[tk]
			if kc then self:SetToggleKey(kc) end
		end
	end
	
	-- Apply all flags
	if type(decoded.flags) == "table" then
		for flag, raw in pairs(decoded.flags) do
			local value = decodeValue(raw)
			self.Flags = self.Flags or {}
			self.Flags[flag] = value
			local reg = self._Registry and self._Registry[flag]
			if reg and reg.Set then
				taskSpawn(function()
					reg.Set(value)
				end)
			end
		end
	end
	
	-- Apply UI state
	if type(decoded.ui) == "table" and self.Root then
		local ui = decoded.ui
		local anchor = decodeValue(ui.anchor)
		if typeof(anchor) == "Vector2" then
			self.Root.AnchorPoint = anchor
		end
		local size = decodeValue(ui.size)
		if typeof(size) == "UDim2" then
			self.Root.Size = size
		end
		local pos = decodeValue(ui.pos)
		if typeof(pos) == "UDim2" then
			self.Root.Position = pos
		end
		if type(ui.visible) == "boolean" then
			self.Root.Visible = ui.visible
		end
		if type(ui.min) == "boolean" then
			self._Minimized = ui.min
			if self._Minimized then
				self.Root.Visible = false
				if self._OpenButton then self._OpenButton.Visible = true end
			else
				self.Root.Visible = true
				if self._OpenButton then self._OpenButton.Visible = false end
				local body = self.Root:FindFirstChild("Body")
				if body then body.Visible = true end
			end
		end
		if type(ui.full) == "boolean" then
			self:SetFullscreen(ui.full)
		end
		if type(ui.selected) == "string" and ui.selected ~= "" then
			local want = tostring(ui.selected):lower()
			for _, t in ipairs(self._Tabs) do
				if tostring(t.Name):lower() == want then
					self:SelectTab(t)
					break
				end
			end
		end
		-- Restore open button position
		if ui.openBtnPos and self._OpenButton then
			local btnPos = decodeValue(ui.openBtnPos)
			if typeof(btnPos) == "UDim2" then
				self._OpenButton.Position = btnPos
			end
		end
	end
	
	-- Apply Streamer Mode settings
	if type(decoded.streamerMode) == "table" then
		local sm = decoded.streamerMode
		if type(sm.hideUsername) == "boolean" then
			self._HideUsername = sm.hideUsername
		end
		if type(sm.hideDisplayName) == "boolean" then
			self._HideDisplayName = sm.hideDisplayName
		end
		if type(sm.customUsername) == "string" then
			self._CustomUsername = sm.customUsername
		end
		if type(sm.customDisplayName) == "string" then
			self._CustomDisplayName = sm.customDisplayName
		end
		-- Apply streamer mode
		self:_applyStreamerMode()
	end
	
	print("[Pulse] Config loaded successfully:", name)
	return true
end

function Window:DeleteConfig(name)
	name = tostring(name or "")
	if name == "" then return false, "missing name" end
	
	-- Delete from file system
	local path = self:_configPath(name)
	if type(delfile) == "function" and type(isfile) == "function" then
		local exists, _ = safeCall(isfile, path)
		if exists then
			local ok, err = safeCall(delfile, path)
			if ok then
				print("[Pulse] Config deleted from file:", path)
			else
				warn("[Pulse] Failed to delete config file:", err)
			end
		end
	end
	
	-- Delete from memory
	self._ConfigMemory = self._ConfigMemory or {}
	self._ConfigMemory[name] = nil
	
	print("[Pulse] Config deleted:", name)
	return true
end

function Window:SelectTab(tab)
	if self._Selected == tab then return end
	self._Selected = tab
	for _, t in ipairs(self._Tabs) do
		if t == tab then
			t.Page.Visible = true
			t.Accent.Visible = true
			t.Button.BackgroundTransparency = 0
			tween(t.Button, 0.12, { BackgroundColor3 = THEME.panel2 })
			t.ButtonText.TextColor3 = THEME.text
			if t.Icon then
				t.Icon.ImageColor3 = THEME.text
			end
		else
			t.Page.Visible = false
			t.Accent.Visible = false
			t.Button.BackgroundTransparency = 1
			t.ButtonText.TextColor3 = THEME.muted
			if t.Icon then
				t.Icon.ImageColor3 = THEME.muted
			end
		end
	end
end

function Window:AddTabDivider(text, layoutOrder, _internal)
	text = tostring(text or "")
	if text == "" then return nil end

	-- User-friendly behavior:
	-- If called right after creating a tab that already has a divider key,
	-- treat `text` as the DISPLAY title for that divider (prevents "extra" empty dividers).
	if not _internal then
		local lastTab = self._LastCreatedTab
		if lastTab then
			-- Case 1: Tab already has a divider key -> rename that divider's display text
			if lastTab._DividerName and lastTab._DividerName ~= "" then
				local key = tostring(lastTab._DividerName)
				local lbl = self._TabDividers and self._TabDividers[key]
				if not (lbl and lbl.Parent) then
					self:AddTabDivider(key, layoutOrder, true)
					lbl = self._TabDividers and self._TabDividers[key]
				end
				if lbl and lbl.Parent then
					lbl.Text = text
					local meta = self._TabDividerMeta[key] or {}
					meta.AutoCreated = false
					if type(layoutOrder) == "number" then
						lbl.LayoutOrder = layoutOrder
						meta.BaseOrder = layoutOrder
					end
					self._TabDividerMeta[key] = meta
					if type(self._ReflowSidebar) == "function" then
						self:_ReflowSidebar()
					end
					return lbl
				end
			else
				-- Case 2: Tab has no divider key -> attach this divider to the tab
				local key = text
				lastTab._DividerName = key
				self:AddTabDivider(key, layoutOrder, true)
				local lbl = self._TabDividers and self._TabDividers[key]
				if lbl and lbl.Parent then
					lbl.Text = text
					local meta = self._TabDividerMeta[key] or {}
					meta.AutoCreated = false
					if type(layoutOrder) == "number" then
						lbl.LayoutOrder = layoutOrder
						meta.BaseOrder = layoutOrder
					end
					self._TabDividerMeta[key] = meta
				end
				if type(self._ReflowSidebar) == "function" then
					self:_ReflowSidebar()
				end
				return lbl
			end
		end
	end

	self._TabDividers = self._TabDividers or {}
	self._TabDividerMeta = self._TabDividerMeta or {}
	local existing = self._TabDividers[text]
	if existing and existing.Parent then
		if type(layoutOrder) == "number" then
			existing.LayoutOrder = layoutOrder
			local meta = self._TabDividerMeta[text] or {}
			meta.BaseOrder = layoutOrder
			if meta.AutoCreated == nil then
				meta.AutoCreated = _internal and true or false
			end
			self._TabDividerMeta[text] = meta
		end
		if type(self._ReflowSidebar) == "function" then
			self:_ReflowSidebar()
		end

		if not _internal and self._LastCreatedTab and self._LastCreatedTab._DividerName ~= text then
			local lastTab = self._LastCreatedTab
			local old = lastTab._DividerName
			lastTab._DividerName = text
			if type(self._ReflowSidebar) == "function" then
				self:_ReflowSidebar()
			end
			if old and old ~= text and type(self._CleanupAutoDivider) == "function" then
				self:_CleanupAutoDivider(old)
			end
		end
		return existing
	end

	if type(layoutOrder) ~= "number" then
		self._AutoDividerOrder = (self._AutoDividerOrder or -1000001) + 1000
		layoutOrder = self._AutoDividerOrder
	end

	local lbl = makeLabel(self.SidebarList or self.Sidebar, text, 12, THEME.muted, Enum.TextXAlignment.Left)
	lbl.Name = "TabDivider_" .. text
	lbl.Size = UDim2.new(1, 0, 0, 18)
	lbl.TextTransparency = 0.35
	lbl.LayoutOrder = layoutOrder

	self._TabDividers[text] = lbl
	self._TabDividerMeta[text] = { BaseOrder = layoutOrder, AutoCreated = _internal and true or false }
	if type(self._ReflowSidebar) == "function" then
		self:_ReflowSidebar()
	end

	if not _internal and self._LastCreatedTab and self._LastCreatedTab._DividerName ~= text then
		local lastTab = self._LastCreatedTab
		local old = lastTab._DividerName
		lastTab._DividerName = text
		if type(self._ReflowSidebar) == "function" then
			self:_ReflowSidebar()
		end
		if old and old ~= text and type(self._CleanupAutoDivider) == "function" then
			self:_CleanupAutoDivider(old)
		end
	end
	return lbl
end

function Window:_CleanupAutoDivider(name)
	name = tostring(name or "")
	if name == "" then return end
	if not (self._TabDividerMeta and self._TabDividerMeta[name] and self._TabDividerMeta[name].AutoCreated) then
		return
	end

	for _, t in ipairs(self._Tabs or {}) do
		if t and t._DividerName == name then
			return
		end
	end

	local lbl = self._TabDividers and self._TabDividers[name]
	if lbl and lbl.Parent then
		lbl:Destroy()
	end
	if self._TabDividers then
		self._TabDividers[name] = nil
	end
	if self._TabDividerMeta then
		self._TabDividerMeta[name] = nil
	end
end

function Window:_ReflowSidebar()
	local dividers = {}
	for name, lbl in pairs(self._TabDividers or {}) do
		if lbl and lbl.Parent then
			local meta = (self._TabDividerMeta and self._TabDividerMeta[name]) or {}
			table.insert(dividers, {
				Name = name,
				Label = lbl,
				Base = meta.BaseOrder,
			})
		end
	end

	table.sort(dividers, function(a, b)
		local ba = a.Base
		local bb = b.Base
		if type(ba) == "number" and type(bb) == "number" and ba ~= bb then
			return ba < bb
		end
		if type(ba) == "number" and type(bb) ~= "number" then
			return true
		end
		if type(ba) ~= "number" and type(bb) == "number" then
			return false
		end
		return tostring(a.Name) < tostring(b.Name)
	end)

	local tabsByDivider = {}
	local looseTabs = {}
	for _, t in ipairs(self._Tabs or {}) do
		if t and t.Button and t.Button.Parent and not t._PinnedOrder then
			local d = t._DividerName
			local dividerExists = d and (self._TabDividers and self._TabDividers[d] and self._TabDividers[d].Parent)
			if dividerExists then
				tabsByDivider[d] = tabsByDivider[d] or {}
				table.insert(tabsByDivider[d], t)
			else
				table.insert(looseTabs, t)
			end
		end
	end

	local function sortTabs(list)
		table.sort(list, function(x, y)
			return (x._CreatedIndex or 0) < (y._CreatedIndex or 0)
		end)
	end

	for _, list in pairs(tabsByDivider) do
		sortTabs(list)
	end
	sortTabs(looseTabs)

	local lastOrder = -math.huge
	for _, d in ipairs(dividers) do
		local base = d.Base
		if type(base) ~= "number" then
			base = (lastOrder == -math.huge) and -1000001 or (lastOrder + 1000)
			if self._TabDividerMeta then
				local meta = self._TabDividerMeta[d.Name] or {}
				meta.BaseOrder = base
				self._TabDividerMeta[d.Name] = meta
			end
		end
		if base <= lastOrder then
			base = lastOrder + 1000
			if self._TabDividerMeta then
				local meta = self._TabDividerMeta[d.Name] or {}
				meta.BaseOrder = base
				self._TabDividerMeta[d.Name] = meta
			end
		end

		d.Label.LayoutOrder = base
		lastOrder = base

		local list = tabsByDivider[d.Name]
		if list then
			for i, t in ipairs(list) do
				t.Button.LayoutOrder = base + i
				lastOrder = t.Button.LayoutOrder
			end
		end
	end

	for _, t in ipairs(looseTabs) do
		lastOrder = (lastOrder == -math.huge) and 0 or (lastOrder + 1000)
		t.Button.LayoutOrder = lastOrder
	end
end

function Window:CreateTab(name, options)
	if type(name) == "table" and options == nil then
		options = name
		name = (options and (options.Name or options.Title)) or "Tab"
	end
	options = options or {}
	name = name or "Tab"
	local lname = tostring(name):lower()
	local section = options.Divider or options.Section or options.Category

	local btn = create("TextButton", {
		Name = "TabButton_" .. name,
		Size = UDim2.new(1, 0, 0, 26),
		BackgroundColor3 = THEME.panel2,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
	})
	btn.Parent = self.SidebarList or self.Sidebar
	btn.BackgroundTransparency = 1
	addCorner(btn, 6)
	btn.LayoutOrder = 0
	if type(options.LayoutOrder) == "number" then
		btn.LayoutOrder = options.LayoutOrder
		btn.BackgroundTransparency = 1
	elseif section then
		btn.LayoutOrder = 0
	elseif lname == "home" or lname == "dashboard" then
		btn.LayoutOrder = -1000000
	elseif lname == "settings" then
		btn.LayoutOrder = 1000000
	end

	local accentBar = create("Frame", {
		Name = "Accent",
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 0),
		Size = UDim2.new(0, 2, 1, 0),
		Visible = false,
	})
	accentBar.Parent = btn
	addCorner(accentBar, 2)

	local iconLabel = nil
	if type(options.Icon) == "string" and options.Icon ~= "" then
		iconLabel = create("ImageLabel", {
			Name = "Icon",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 8, 0.5, -8),
			Size = UDim2.new(0, 16, 0, 16),
			Image = options.Icon,
			ImageColor3 = THEME.muted,
		})
		iconLabel.Parent = btn
	end

	local text = makeLabel(btn, name, 12, THEME.muted, Enum.TextXAlignment.Left)
	text.Name = "Label"
	text.Position = UDim2.new(0, iconLabel and 30 or 10, 0, 0)
	text.Size = UDim2.new(1, -(iconLabel and 40 or 20), 1, 0)

	local page = create("Frame", {
		Name = "Page_" .. name,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		Visible = false,
	})
	page.Parent = self.Pages

	local columns = create("Frame", {
		Name = "Columns",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
	})
	columns.Parent = page

	local leftCol = create("Frame", {
		Name = "Left",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(0.5, -6, 1, 0),
	})
	leftCol.Parent = columns

	local rightCol = create("Frame", {
		Name = "Right",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0.5, 6, 0, 0),
		Size = UDim2.new(0.5, -6, 1, 0),
	})
	rightCol.Parent = columns

	for _, col in ipairs({ leftCol, rightCol }) do
		local scroll = create("ScrollingFrame", {
			Name = "Scroll",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			CanvasSize = UDim2.new(0, 0, 0, 0),
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = THEME.accent2,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
		})
		scroll.Parent = col
		addPadding(scroll, 0)

		local list = create("UIListLayout", {
			Padding = UDim.new(0, 10),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		list.Parent = scroll
	end

	local tab = setmetatable({
		Window = self,
		Name = name,
		Button = btn,
		ButtonText = text,
		Icon = iconLabel,
		Accent = accentBar,
		Page = page,
		Left = leftCol.Scroll,
		Right = rightCol.Scroll,
	}, Tab)

	self._NextTabIndex = (self._NextTabIndex or 0) + 1
	tab._CreatedIndex = self._NextTabIndex
	tab._DividerName = section
	tab._PinnedOrder = type(options.LayoutOrder) == "number"
	self._LastCreatedTab = tab

	if section then
		local dividerOrder = options.DividerOrder or options.SectionOrder or options.CategoryOrder
		self:AddTabDivider(section, dividerOrder, true)
	end

	local function isSelected()
		return self._Selected == tab
	end

	btn.MouseEnter:Connect(function()
		if isSelected() then return end
		btn.BackgroundTransparency = 0
		tween(btn, 0.12, { BackgroundColor3 = THEME.panel2 })
		text.TextColor3 = THEME.text
		if iconLabel then
			iconLabel.ImageColor3 = THEME.text
		end
	end)
	btn.MouseLeave:Connect(function()
		if isSelected() then return end
		btn.BackgroundTransparency = 1
		text.TextColor3 = THEME.muted
		if iconLabel then
			iconLabel.ImageColor3 = THEME.muted
		end
	end)

	connectTap(btn, function()
		self:SelectTab(tab)
	end)

	table.insert(self._Tabs, tab)
	if not self._Selected then
		self:SelectTab(tab)
	end
	if type(self._ReflowSidebar) == "function" then
		self:_ReflowSidebar()
	end

	return tab
end

function Window:GetSettingsTab()
	return self.SettingsTab
end

function Tab:CreateGroup(title, side)
	title = title or "Group"
	side = (side or "left"):lower()
	local parent = (side == "right") and self.Right or self.Left

	local group = create("Frame", {
		Name = "Group_" .. title,
		BackgroundColor3 = THEME.panel,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	group.Parent = parent
	addCorner(group, 3)
	addStroke(group, 1, THEME.strokeSoft, 0)

	local headerText = makeLabel(group, title, 12, THEME.text, Enum.TextXAlignment.Left)
	headerText.Position = UDim2.new(0, 10, 0, 8)
	headerText.Size = UDim2.new(1, -20, 0, 16)

	local sep = create("Frame", {
		Name = "Separator",
		BackgroundColor3 = THEME.strokeSoft,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 8, 0, 28),
		Size = UDim2.new(1, -16, 0, 1),
	})
	sep.Parent = group

	local body = create("Frame", {
		Name = "Body",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 32),
		Size = UDim2.new(1, 0, 0, 0),
		AutomaticSize = Enum.AutomaticSize.Y,
	})
	body.Parent = group
	local pad = addPadding(body, 10)
	pad.PaddingTop = UDim.new(0, 8)
	pad.PaddingBottom = UDim.new(0, 10)

	local list = create("UIListLayout", {
		Padding = UDim.new(0, 10),
		FillDirection = Enum.FillDirection.Vertical,
		HorizontalAlignment = Enum.HorizontalAlignment.Center,
		SortOrder = Enum.SortOrder.LayoutOrder,
	})
	list.Parent = body

	local g = setmetatable({
		Tab = self,
		Frame = group,
		Body = body,
	}, Group)

	return g
end

function Tab:CreateSection(title, side)
	return self:CreateGroup(title, side)
end

local function makeRow(parent)
	local row = create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 22),
	})
	row.Parent = parent
	return row
end

local function normalizeCallbackAndFlag(callback, flag)
	if type(callback) == "string" and flag == nil then
		return nil, callback
	end
	return callback, flag
end

local function makeField(parent)
	local field = create("Frame", {
		BackgroundColor3 = THEME.panel2,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 170, 0, 26),
	})
	field.Parent = parent
	addCorner(field, 6)
	addStroke(field, 1, THEME.stroke, 0.25)
	return field
end

function Group:AddToggle(label, default, callback, flag)
	callback, flag = normalizeCallbackAndFlag(callback, flag)
	local window = self.Tab and self.Tab.Window
	local row = makeRow(self.Body)
	local lbl = makeLabel(row, label or "Toggle", 12, THEME.label, Enum.TextXAlignment.Left)
	lbl.Position = UDim2.new(0, 0, 0, 0)
	lbl.Size = UDim2.new(1, -190, 1, 0)

	local box = create("TextButton", {
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 22, 0, 22),
		AutoButtonColor = false,
		Text = "",
	})
	box.Parent = row
	addCorner(box, 4)
	addStroke(box, 1, THEME.strokeSoft, 0)

	local mark = create("Frame", {
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(1, -4, 1, -4),
		Visible = false,
	})
	mark.Parent = box
	addCorner(mark, 3)

	local state = default and true or false
	local function render()
		mark.Visible = state
		if state then
			box.BackgroundColor3 = THEME.accent
		else
			box.BackgroundColor3 = THEME.bg
		end
		if window and flag then
			window.Flags = window.Flags or {}
			window.Flags[flag] = state
		end
	end

	render()

	connectTap(box, function()
		state = not state
		render()
		if callback then
			taskSpawn(callback, state)
		end
	end)

	local api = {
		Get = function() return state end,
		Set = function(v)
			state = (v and true or false)
			render()
			if callback then taskSpawn(callback, state) end
		end,
	}

	if window and flag then
		window:_registerFlag(flag, {
			Get = api.Get,
			Set = api.Set,
		})
	end

	return api
end

-- Toggle with an attached color picker (toggle row + swatch)
function Group:AddToggleColor(label, defaultState, defaultColor, callback, flagToggle, flagColor)
	callback, flagToggle = normalizeCallbackAndFlag(callback, flagToggle)
	local window = self.Tab and self.Tab.Window
	local row = makeRow(self.Body)
	local lbl = makeLabel(row, label or "Toggle", 12, THEME.label, Enum.TextXAlignment.Left)
	lbl.Position = UDim2.new(0, 0, 0, 0)
	lbl.Size = UDim2.new(1, -230, 1, 0)

	local box = create("TextButton", {
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, -52, 0.5, 0),
		Size = UDim2.new(0, 18, 0, 18),
		AutoButtonColor = false,
		Text = "",
	})
	box.Parent = row
	addCorner(box, 3)
	addStroke(box, 1, THEME.strokeSoft, 0)

	local mark = create("Frame", {
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 12, 0, 12),
		Visible = false,
	})
	mark.Parent = box
	addCorner(mark, 3)

	local swatchBtn = create("TextButton", {
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 42, 0, 16),
		AutoButtonColor = false,
		Text = "",
	})
	swatchBtn.Parent = row
	addCorner(swatchBtn, 2)
	addStroke(swatchBtn, 1, THEME.strokeSoft, 0)

	local color = defaultColor or THEME.accent
	local preview = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
	})
	preview.Parent = swatchBtn
	addCorner(preview, 2)

	local state = defaultState and true or false
	local function setState(v, fire)
		state = (v and true or false)
		mark.Visible = state
		if window and flagToggle then
			window.Flags = window.Flags or {}
			window.Flags[flagToggle] = state
		end
		if fire and callback then taskSpawn(callback, state, color) end
	end
	local function setColor(c, fire)
		if typeof(c) ~= "Color3" then return end
		color = c
		preview.BackgroundColor3 = color
		if window and flagColor then
			window.Flags = window.Flags or {}
			window.Flags[flagColor] = color
		end
		if fire and callback then taskSpawn(callback, state, color) end
	end
	setState(state, false)
	setColor(color, false)

	local function openColorPopup()
		local window = self.Tab and self.Tab.Window
		if not window or not window.Overlay then return end
		if window.Overlay:FindFirstChild("ColorPickerPopup") then
			window.Overlay.ColorPickerPopup:Destroy()
		end
		local existingBlocker = window.Overlay:FindFirstChild("Blocker")
		if existingBlocker then existingBlocker:Destroy() end

		local popup = create("Frame", {
			Name = "ColorPickerPopup",
			BackgroundColor3 = THEME.panel,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 250, 0, 190),
			ZIndex = 60,
		})
		popup.Parent = window.Overlay
		addCorner(popup, 3)
		addStroke(popup, 1, THEME.strokeSoft, 0)

		local abs = swatchBtn.AbsolutePosition
		local size = swatchBtn.AbsoluteSize
		popup.Position = UDim2.fromOffset(abs.X + size.X - 250, abs.Y + size.Y + 6)

		local title = makeLabel(popup, label or "Color", 12, THEME.text, Enum.TextXAlignment.Left)
		title.Position = UDim2.new(0, 10, 0, 8)
		title.Size = UDim2.new(1, -20, 0, 14)
		title.ZIndex = 61

		local sep = create("Frame", {
			BackgroundColor3 = THEME.strokeSoft,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 8, 0, 28),
			Size = UDim2.new(1, -16, 0, 1),
			ZIndex = 61,
		})
		sep.Parent = popup

		local h, s, v = color3ToHsv(color)
		local sv = create("ImageButton", {
			Name = "SV",
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromHSV(h, 1, 1),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 10, 0, 38),
			Size = UDim2.new(0, 150, 0, 110),
			ZIndex = 61,
		})
		sv.Parent = popup
		addCorner(sv, 2)
		addStroke(sv, 1, THEME.strokeSoft, 0)

		local gradWhite = create("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 62,
		})
		gradWhite.Parent = sv
		addCorner(gradWhite, 2)
		create("UIGradient", {
			Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Rotation = 0,
		}).Parent = gradWhite

		local gradBlack = create("Frame", {
			BackgroundColor3 = Color3.new(0, 0, 0),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 63,
		})
		gradBlack.Parent = sv
		addCorner(gradBlack, 2)
		create("UIGradient", {
			Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			}),
			Rotation = 90,
		}).Parent = gradBlack

		local svKnob = create("Frame", {
			BackgroundColor3 = THEME.text,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 10, 0, 10),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 64,
		})
		svKnob.Parent = sv
		addCorner(svKnob, 999)
		addStroke(svKnob, 2, THEME.bg, 0)

		local hue = create("ImageButton", {
			Name = "Hue",
			AutoButtonColor = false,
			BackgroundColor3 = THEME.bg,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 168, 0, 38),
			Size = UDim2.new(0, 12, 0, 110),
			ZIndex = 61,
		})
		hue.Parent = popup
		addCorner(hue, 2)
		addStroke(hue, 1, THEME.strokeSoft, 0)
		create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
			}),
			Rotation = 90,
		}).Parent = hue

		local hueKnob = create("Frame", {
			BackgroundColor3 = THEME.text,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 4, 0, 2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 0),
			ZIndex = 64,
		})
		hueKnob.Parent = hue
		addCorner(hueKnob, 999)

		local outPreview = create("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 190, 0, 38),
			Size = UDim2.new(0, 50, 0, 24),
			ZIndex = 61,
		})
		outPreview.Parent = popup
		addCorner(outPreview, 2)
		addStroke(outPreview, 1, THEME.strokeSoft, 0)

		local rgbLbl = makeLabel(popup, "", 11, THEME.muted, Enum.TextXAlignment.Left)
		rgbLbl.Position = UDim2.new(0, 190, 0, 66)
		rgbLbl.Size = UDim2.new(0, 60, 0, 14)
		rgbLbl.ZIndex = 61
		rgbLbl.TextTransparency = 0.25

		local hexBox = create("TextBox", {
			BackgroundColor3 = THEME.bg,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 190, 0, 84),
			Size = UDim2.new(0, 50, 0, 18),
			ClearTextOnFocus = false,
			Text = "#FFFFFF",
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = THEME.value,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 61,
		})
		hexBox.Parent = popup
		addCorner(hexBox, 2)
		addStroke(hexBox, 1, THEME.strokeSoft, 0)

		local closeBtn = create("TextButton", {
			BackgroundColor3 = THEME.bg,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 190, 0, 148),
			Size = UDim2.new(0, 50, 0, 20),
			AutoButtonColor = false,
			Text = "OK",
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = THEME.value,
			ZIndex = 61,
		})
		closeBtn.Parent = popup
		addCorner(closeBtn, 2)
		addStroke(closeBtn, 1, THEME.strokeSoft, 0)

		local function toHex(c)
			return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
		end
		local function fromHex(s)
			s = tostring(s or ""):gsub("%s+", "")
			s = s:gsub("^#", "")
			if #s == 3 then
				s = s:sub(1, 1) .. s:sub(1, 1) .. s:sub(2, 2) .. s:sub(2, 2) .. s:sub(3, 3) .. s:sub(3, 3)
			end
			if #s ~= 6 then return nil end
			local r = tonumber(s:sub(1, 2), 16)
			local g = tonumber(s:sub(3, 4), 16)
			local b = tonumber(s:sub(5, 6), 16)
			if not r or not g or not b then return nil end
			return Color3.fromRGB(r, g, b)
		end

		local function updateUI(fire)
			sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			local c = hsvToColor3(h, s, v)
			outPreview.BackgroundColor3 = c
			rgbLbl.Text = string.format("%d,%d,%d", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
			hexBox.Text = toHex(c)
			svKnob.Position = UDim2.new(s, 0, 1 - v, 0)
			hueKnob.Position = UDim2.new(0.5, 0, 1 - h, 0)
			setColor(c, fire)
		end
		updateUI(false)

		local draggingSV = false
		local draggingHue = false
		local dragInput
		local function setSVFromPos(pos)
			pos = toV2(pos)
			local rel = (pos - sv.AbsolutePosition)
			local sx = clamp01(rel.X / math.max(1, sv.AbsoluteSize.X))
			local vy = clamp01(rel.Y / math.max(1, sv.AbsoluteSize.Y))
			s = sx
			v = 1 - vy
			updateUI(true)
		end
		local function setHFromPos(pos)
			pos = toV2(pos)
			local rel = (pos - hue.AbsolutePosition)
			local hy = clamp01(rel.Y / math.max(1, hue.AbsoluteSize.Y))
			h = 1 - hy
			updateUI(true)
		end

		sv.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSV = true
				dragInput = input
				setSVFromPos(input.Position)
			end
		end)
		sv.InputEnded:Connect(function(input)
			if input == dragInput then draggingSV = false end
		end)
		hue.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingHue = true
				dragInput = input
				setHFromPos(input.Position)
			end
		end)
		hue.InputEnded:Connect(function(input)
			if input == dragInput then draggingHue = false end
		end)
		UIS.InputChanged:Connect(function(input)
			if dragInput and input.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then return end
			if (draggingSV or draggingHue) and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				if draggingSV then
					setSVFromPos(input.Position)
				elseif draggingHue then
					setHFromPos(input.Position)
				end
			end
		end)

		hexBox.FocusLost:Connect(function()
			local c = fromHex(hexBox.Text)
			if c then
				h, s, v = color3ToHsv(c)
				updateUI(true)
			else
				hexBox.Text = toHex(color)
			end
		end)

		local blocker = create("TextButton", {
			Name = "Blocker",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 59,
		})
		blocker.Parent = window.Overlay
		blocker.LayoutOrder = -1
		connectTap(blocker, function()
			if popup.Parent then popup:Destroy() end
			if blocker.Parent then blocker:Destroy() end
		end)
		connectTap(closeBtn, function()
			if popup.Parent then popup:Destroy() end
			if blocker.Parent then blocker:Destroy() end
		end)

		applyPopupIn(popup)
	end

	connectTap(box, function()
		setState(not state, true)
	end)
	connectTap(swatchBtn, function()
		openColorPopup()
	end)

	local api = {
		Get = function() return state, color end,
		GetState = function() return state end,
		GetColor = function() return color end,
		Set = function(v, c)
			if v ~= nil then setState(v, true) end
			if c ~= nil then setColor(c, true) end
		end,
		SetState = function(v) setState(v, true) end,
		SetColor = function(c) setColor(c, true) end,
	}

	if window and flagToggle then
		window:_registerFlag(flagToggle, { Get = api.GetState, Set = api.SetState })
	end
	if window and flagColor then
		window:_registerFlag(flagColor, { Get = api.GetColor, Set = api.SetColor })
	end

	return api
end

function Group:AddCheckbox(label, default, callback, flag)
	callback, flag = normalizeCallbackAndFlag(callback, flag)
	local window = self.Tab and self.Tab.Window
	local row = makeRow(self.Body)
	local lbl = makeLabel(row, label or "Checkbox", 12, THEME.label, Enum.TextXAlignment.Left)
	lbl.Position = UDim2.new(0, 0, 0, 0)
	lbl.Size = UDim2.new(1, -190, 1, 0)

	local box = create("TextButton", {
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 16, 0, 16),
		AutoButtonColor = false,
		Text = "",
	})
	box.Parent = row
	addCorner(box, 2)
	addStroke(box, 1, THEME.strokeSoft, 0)

	local mark = create("Frame", {
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Position = UDim2.new(0.5, 0, 0.5, 0),
		Size = UDim2.new(0, 10, 0, 10),
		Visible = false,
	})
	mark.Parent = box
	addCorner(mark, 2)

	local state = default and true or false
	local function render()
		mark.Visible = state
		box.BackgroundColor3 = THEME.bg
		if window and flag then
			window.Flags = window.Flags or {}
			window.Flags[flag] = state
		end
	end
	render()

	connectTap(box, function()
		state = not state
		render()
		if callback then taskSpawn(callback, state) end
	end)

	local api = {
		Get = function() return state end,
		Set = function(v)
			state = (v and true or false)
			render()
			if callback then taskSpawn(callback, state) end
		end,
	}

	if window and flag then
		window:_registerFlag(flag, {
			Get = api.Get,
			Set = api.Set,
		})
	end

	return api
end

function Group:AddDropdown(label, options, default, callback, flag)
	callback, flag = normalizeCallbackAndFlag(callback, flag)
	options = options or {}
	local window = self.Tab and self.Tab.Window
	local row = makeRow(self.Body)
	row.Size = UDim2.new(1, 0, 0, 44)

	local lbl = makeLabel(row, label or "Dropdown", 12, THEME.label, Enum.TextXAlignment.Left)
	lbl.Position = UDim2.new(0, 0, 0, 0)
	lbl.Size = UDim2.new(1, 0, 0, 16)

	local fieldBtn = create("TextButton", {
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 18),
		Size = UDim2.new(1, 0, 0, 26),
		AutoButtonColor = false,
		Text = "",
	})
	fieldBtn.Parent = row
	addCorner(fieldBtn, 6)
	addStroke(fieldBtn, 1, THEME.stroke, 0.25)

	local valueLabel = makeLabel(fieldBtn, "", 12, THEME.value, Enum.TextXAlignment.Left)
	valueLabel.Position = UDim2.new(0, 8, 0, 0)
	valueLabel.Size = UDim2.new(1, -22, 1, 0)

	local arrow = makeLabel(fieldBtn, "▼", 10, THEME.muted, Enum.TextXAlignment.Right)
	arrow.Position = UDim2.new(1, -6, 0, 0)
	arrow.AnchorPoint = Vector2.new(1, 0)
	arrow.Size = UDim2.new(0, 16, 1, 0)

	local selected = default or options[1]
	if selected == nil then selected = "None" end
	valueLabel.Text = tostring(selected)

	local function syncFlag()
		if window and flag then
			window.Flags = window.Flags or {}
			window.Flags[flag] = selected
		end
	end
	local open = false
	local popup, blocker
	local scrollConn
	local rebuildPopup
	local function normalizeOptions(list)
		local out = {}
		if type(list) == "table" then
			for _, v in ipairs(list) do
				table.insert(out, v)
			end
		end
		return out
	end
	local function selectionExists(val)
		for _, opt in ipairs(options) do
			if opt == val then
				return true
			end
		end
		return false
	end
	local function setSelected(v, fire)
		if v == nil then
			if #options > 0 then
				selected = options[1]
			else
				selected = "None"
			end
		else
			selected = v
		end
		valueLabel.Text = tostring(selected)
		syncFlag()
		if fire and callback then taskSpawn(callback, selected) end
	end

	local function close()
		open = false
		if scrollConn then scrollConn:Disconnect() scrollConn = nil end
		if popup then popup:Destroy() popup = nil end
		if blocker then blocker:Destroy() blocker = nil end
		rebuildPopup = nil
	end

	local function openOverlay()
		if not window or not window.Overlay then return end
		-- close any other dropdown
		for _, child in ipairs(window.Overlay:GetChildren()) do
			if child.Name == "DropdownPopup" or child.Name == "DropdownBlocker" then
				child:Destroy()
			end
		end

		blocker = create("TextButton", {
			Name = "DropdownBlocker",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 58,
		})
		blocker.Parent = window.Overlay
		connectTap(blocker, function()
			close()
		end)

		popup = create("ScrollingFrame", {
			Name = "DropdownPopup",
			BackgroundColor3 = THEME.bg,
			BorderSizePixel = 0,
			Size = UDim2.new(0, fieldBtn.AbsoluteSize.X, 0, 0),
			ClipsDescendants = true,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 3,
			ScrollBarImageColor3 = THEME.accent2,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ZIndex = 60,
		})
		popup.Parent = window.Overlay
		addCorner(popup, 2)
		addStroke(popup, 1, THEME.strokeSoft, 0)
		addPadding(popup, 6)

		local list = create("UIListLayout", {
			Padding = UDim.new(0, 6),
			FillDirection = Enum.FillDirection.Vertical,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
		})
		list.Parent = popup

		rebuildPopup = function()
			for _, c in ipairs(popup:GetChildren()) do
				if c:IsA("TextButton") then c:Destroy() end
			end
			for _, opt in ipairs(options) do
				local optBtn = create("TextButton", {
					BackgroundColor3 = THEME.panel2,
					BorderSizePixel = 0,
					Size = UDim2.new(1, -4, 0, 22),
					AutoButtonColor = false,
					Text = "",
					ZIndex = 61,
				})
				optBtn.Parent = popup
				addCorner(optBtn, 2)
				local optLbl = makeLabel(optBtn, tostring(opt), 12, THEME.value, Enum.TextXAlignment.Left)
				optLbl.Position = UDim2.new(0, 8, 0, 0)
				optLbl.Size = UDim2.new(1, -16, 1, 0)
				optLbl.ZIndex = 62
				connectTap(optBtn, function()
					setSelected(opt, true)
					close()
				end)
			end
		end

		rebuildPopup()

		local abs = fieldBtn.AbsolutePosition
		local size = fieldBtn.AbsoluteSize
		local popupX = abs.X
		local popupY = abs.Y + size.Y + 4
		popup.Position = UDim2.fromOffset(popupX, popupY)

		local desired = (#options * 28) + 12
		local maxHeight = 180
		local overlaySize = window.Overlay.AbsoluteSize
		local availableBelow = math.max(24, overlaySize.Y - popupY - 10)
		local height = math.min(maxHeight, math.min(desired, availableBelow))
		popup.Size = UDim2.new(0, size.X, 0, height)
		applyPopupIn(popup)

		local scroll = fieldBtn:FindFirstAncestorWhichIsA("ScrollingFrame")
		if scroll then
			scrollConn = scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				close()
			end)
		end
	end

	connectTap(fieldBtn, function()
		open = not open
		if open then
			openOverlay()
		else
			close()
		end
	end)

	local api = {
		Get = function() return selected end,
		Set = function(v)
			if v ~= nil and selectionExists(v) then
				setSelected(v, true)
			else
				-- if value is not in options, keep it (useful for dynamic lists), but still show it.
				setSelected(v, true)
			end
			if open and rebuildPopup then
				rebuildPopup()
			end
		end,
		SetOptions = function(newOptions, preferredSelection)
			options = normalizeOptions(newOptions)
			if preferredSelection ~= nil then
				setSelected(preferredSelection, false)
			elseif not selectionExists(selected) then
				setSelected(nil, false)
			end
			if open then
				if rebuildPopup then
					rebuildPopup()
				else
					-- overlay was closed externally
					open = false
				end
			else
				close()
			end
		end,
		UpdateList = function(self, newOptions)
			if type(newOptions) == "table" then
				options = normalizeOptions(newOptions)
				if not selectionExists(selected) then
					setSelected(nil, false)
				end
				if open and rebuildPopup then
					rebuildPopup()
				end
			end
			return self
		end,
		Close = close,
	}

	if window and flag then
		window:_registerFlag(flag, {
			Get = api.Get,
			Set = api.Set,
		})
	end

	return api
end

function Group:AddSlider(label, min, max, default, callback, flag)
	callback, flag = normalizeCallbackAndFlag(callback, flag)
	local window = self.Tab and self.Tab.Window
	min = tonumber(min) or 0
	max = tonumber(max) or 100
	local value = tonumber(default)
	if value == nil then value = min end
	value = math.clamp(value, min, max)

	local row = makeRow(self.Body)
	row.Size = UDim2.new(1, 0, 0, 36)

	local lbl = makeLabel(row, label or "Slider", 12, THEME.label, Enum.TextXAlignment.Left)
	lbl.Position = UDim2.new(0, 0, 0, 0)
	lbl.Size = UDim2.new(1, -190, 0, 16)

	local valLbl = makeLabel(row, "", 12, THEME.value, Enum.TextXAlignment.Right)
	valLbl.Position = UDim2.new(1, 0, 0, 0)
	valLbl.AnchorPoint = Vector2.new(1, 0)
	valLbl.Size = UDim2.new(0, 170, 0, 16)

	local track = create("Frame", {
		BackgroundColor3 = THEME.strokeSoft,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 20),
		Size = UDim2.new(1, 0, 0, 6),
	})
	track.Parent = row
	track.Active = true
	addCorner(track, 2)

	local fill = create("Frame", {
		BackgroundColor3 = THEME.accent,
		BorderSizePixel = 0,
		Size = UDim2.new(0, 0, 1, 0),
	})
	fill.Parent = track
	addCorner(fill, 2)

	local handle = create("Frame", {
		BackgroundColor3 = THEME.text,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(0.5, 0.5),
		Size = UDim2.new(0, 10, 0, 10),
		Position = UDim2.new(0, 0, 0.5, 0),
	})
	handle.Parent = track
	handle.Active = true
	handle.BackgroundTransparency = 0.25
	addCorner(handle, 999)

	-- Hitbox overlay to ensure taps/drags always register
	local hit = create("TextButton", {
		Name = "Hitbox",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		AutoButtonColor = false,
		Text = "",
		AnchorPoint = Vector2.new(0, 0.5),
		Position = UDim2.new(0, 0, 0.5, 0),
		Size = UDim2.new(1, 0, 0, 18),
		ZIndex = 10,
	})
	hit.Parent = track

	local dragging = false
	
	local function setValue(v, fire)
		value = math.clamp(v, min, max)
		local alpha = (value - min) / math.max(1e-9, (max - min))
		alpha = clamp01(alpha)
		
		-- Instant update during drag for smoothness
		if dragging then
			fill.Size = UDim2.new(alpha, 0, 1, 0)
			handle.Position = UDim2.new(alpha, 0, 0.5, 0)
		else
			-- Only tween when not dragging
			TweenService:Create(fill, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(alpha, 0, 1, 0)}):Play()
			TweenService:Create(handle, TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = UDim2.new(alpha, 0, 0.5, 0)}):Play()
		end
		
		valLbl.Text = formatNumber(value) .. "/" .. formatNumber(max)
		if window and flag then
			window.Flags = window.Flags or {}
			window.Flags[flag] = value
		end
		if fire and callback then taskSpawn(callback, value) end
	end

	setValue(value, false)

	local dragInput
	local moveConn
	local endConn
	local function updateFromInput(input)
		local x = input.Position.X
		local absPos = track.AbsolutePosition.X
		local absSize = track.AbsoluteSize.X
		local alpha = (x - absPos) / math.max(1, absSize)
		alpha = clamp01(alpha)
		local v = min + (max - min) * alpha
		setValue(v, true)
	end

	local function stopDragging()
		dragging = false
		dragInput = nil
		if moveConn then moveConn:Disconnect() moveConn = nil end
		if endConn then endConn:Disconnect() endConn = nil end
	end

	local function startDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragInput = input
			updateFromInput(input)

			-- Track movement globally until release (prevents "stuck" drags)
			if moveConn then moveConn:Disconnect() end
			moveConn = UIS.InputChanged:Connect(function(changed)
				if not dragging then return end
				if dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and changed ~= dragInput and changed.UserInputType == Enum.UserInputType.Touch then
					return
				end
				if changed.UserInputType == Enum.UserInputType.MouseMovement or changed.UserInputType == Enum.UserInputType.Touch or changed == dragInput then
					updateFromInput(changed)
				end
			end)

			if endConn then endConn:Disconnect() end
			endConn = UIS.InputEnded:Connect(function(ended)
				if not dragging then return end
				if ended.UserInputType == Enum.UserInputType.MouseButton1 then
					stopDragging()
					return
				end
				if dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and ended == dragInput then
					stopDragging()
					return
				end
			end)
		end
	end

	local function endDrag(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			stopDragging()
			return
		end
		if dragInput and dragInput.UserInputType == Enum.UserInputType.Touch and input == dragInput then
			stopDragging()
			return
		end
	end
	
	hit.InputBegan:Connect(startDrag)
	track.InputBegan:Connect(startDrag)
	handle.InputBegan:Connect(startDrag)
	
	hit.InputEnded:Connect(endDrag)
	track.InputEnded:Connect(endDrag)
	handle.InputEnded:Connect(endDrag)

	-- (InputChanged/InputEnded handled per-drag in startDrag)

	local api = {
		Get = function() return value end,
		Set = function(v) setValue(tonumber(v) or min, true) end,
	}

	if window and flag then
		window:_registerFlag(flag, {
			Get = api.Get,
			Set = api.Set,
		})
	end

	return api
end

function Group:AddColorSwatch(label, defaultColor, callback)
	-- Backward compatible name; now a real picker.
	return self:AddColorPicker(label, defaultColor, callback)
end

function Group:AddColorPicker(label, defaultColor, callback, flag)
	callback, flag = normalizeCallbackAndFlag(callback, flag)
	local window = self.Tab and self.Tab.Window
	local row = makeRow(self.Body)
	local lbl = makeLabel(row, label or "Color", 12, THEME.label, Enum.TextXAlignment.Left)
	lbl.Position = UDim2.new(0, 0, 0, 0)
	lbl.Size = UDim2.new(1, -190, 1, 0)

	local color = defaultColor or THEME.accent
	local fieldBtn = create("TextButton", {
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 42, 0, 16),
		AutoButtonColor = false,
		Text = "",
	})
	fieldBtn.Parent = row
	addCorner(fieldBtn, 2)
	addStroke(fieldBtn, 1, THEME.strokeSoft, 0)

	local preview = create("Frame", {
		BackgroundColor3 = color,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 2, 0, 2),
		Size = UDim2.new(1, -4, 1, -4),
	})
	preview.Parent = fieldBtn
	addCorner(preview, 2)

	local openPopup
	local closePopup
	local scrollConn

	local function setColor(c, fire)
		color = c
		preview.BackgroundColor3 = color
		if window and flag then
			window.Flags = window.Flags or {}
			window.Flags[flag] = color
		end
		if fire and callback then taskSpawn(callback, color) end
	end
	setColor(color, false)

	function openPopup()
		local window = self.Tab and self.Tab.Window
		if not window or not window.Overlay then return end
		if window.Overlay:FindFirstChild("ColorPickerPopup") then
			window.Overlay.ColorPickerPopup:Destroy()
		end
		local existingBlocker = window.Overlay:FindFirstChild("Blocker")
		if existingBlocker then existingBlocker:Destroy() end

		local popup = create("Frame", {
			Name = "ColorPickerPopup",
			BackgroundColor3 = THEME.panel,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 250, 0, 190),
			ZIndex = 60,
		})
		popup.Parent = window.Overlay
		addCorner(popup, 3)
		addStroke(popup, 1, THEME.strokeSoft, 0)

		local abs = fieldBtn.AbsolutePosition
		local size = fieldBtn.AbsoluteSize
		popup.Position = UDim2.fromOffset(abs.X + size.X - 250, abs.Y + size.Y + 6)

		local title = makeLabel(popup, label or "Color", 12, THEME.text, Enum.TextXAlignment.Left)
		title.Position = UDim2.new(0, 10, 0, 8)
		title.Size = UDim2.new(1, -20, 0, 14)
		title.ZIndex = 61

		local sep = create("Frame", {
			BackgroundColor3 = THEME.strokeSoft,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 8, 0, 28),
			Size = UDim2.new(1, -16, 0, 1),
			ZIndex = 61,
		})
		sep.Parent = popup

		local h, s, v = color3ToHsv(color)

		local sv = create("ImageButton", {
			Name = "SV",
			AutoButtonColor = false,
			BackgroundColor3 = Color3.fromHSV(h, 1, 1),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 10, 0, 38),
			Size = UDim2.new(0, 150, 0, 110),
			ZIndex = 61,
		})
		sv.Parent = popup
		addCorner(sv, 2)
		addStroke(sv, 1, THEME.strokeSoft, 0)

		-- overlays: white->transparent left to right, black->transparent bottom to top
		local gradWhite = create("Frame", {
			BackgroundColor3 = Color3.new(1, 1, 1),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 62,
		})
		gradWhite.Parent = sv
		addCorner(gradWhite, 2)
		create("UIGradient", {
			Color = ColorSequence.new(Color3.new(1, 1, 1), Color3.new(1, 1, 1)),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1),
			}),
			Rotation = 0,
		}).Parent = gradWhite

		local gradBlack = create("Frame", {
			BackgroundColor3 = Color3.new(0, 0, 0),
			BackgroundTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 63,
		})
		gradBlack.Parent = sv
		addCorner(gradBlack, 2)
		create("UIGradient", {
			Color = ColorSequence.new(Color3.new(0, 0, 0), Color3.new(0, 0, 0)),
			Transparency = NumberSequence.new({
				NumberSequenceKeypoint.new(0, 1),
				NumberSequenceKeypoint.new(1, 0),
			}),
			Rotation = 90,
		}).Parent = gradBlack

		local svKnob = create("Frame", {
			BackgroundColor3 = THEME.text,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 10, 0, 10),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = 64,
		})
		svKnob.Parent = sv
		addCorner(svKnob, 999)
		addStroke(svKnob, 2, THEME.bg, 0)

		local hue = create("ImageButton", {
			Name = "Hue",
			AutoButtonColor = false,
			BackgroundColor3 = THEME.bg,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 168, 0, 38),
			Size = UDim2.new(0, 12, 0, 110),
			ZIndex = 61,
		})
		hue.Parent = popup
		addCorner(hue, 2)
		addStroke(hue, 1, THEME.strokeSoft, 0)
		create("UIGradient", {
			Color = ColorSequence.new({
				ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
				ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
				ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
				ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
				ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
				ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
				ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
			}),
			Rotation = 90,
		}).Parent = hue

		local hueKnob = create("Frame", {
			BackgroundColor3 = THEME.text,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 4, 0, 2),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0, 0),
			ZIndex = 64,
		})
		hueKnob.Parent = hue
		addCorner(hueKnob, 999)

		local outPreview = create("Frame", {
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 190, 0, 38),
			Size = UDim2.new(0, 50, 0, 24),
			ZIndex = 61,
		})
		outPreview.Parent = popup
		addCorner(outPreview, 2)
		addStroke(outPreview, 1, THEME.strokeSoft, 0)

		local rgbLbl = makeLabel(popup, "", 11, THEME.muted, Enum.TextXAlignment.Left)
		rgbLbl.Position = UDim2.new(0, 190, 0, 66)
		rgbLbl.Size = UDim2.new(0, 60, 0, 14)
		rgbLbl.ZIndex = 61
		rgbLbl.TextTransparency = 0.25

		local hexBox = create("TextBox", {
			BackgroundColor3 = THEME.bg,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 190, 0, 84),
			Size = UDim2.new(0, 50, 0, 18),
			ClearTextOnFocus = false,
			Text = "#FFFFFF",
			Font = Enum.Font.GothamMedium,
			TextSize = 11,
			TextColor3 = THEME.value,
			TextXAlignment = Enum.TextXAlignment.Center,
			ZIndex = 61,
		})
		hexBox.Parent = popup
		addCorner(hexBox, 2)
		addStroke(hexBox, 1, THEME.strokeSoft, 0)

		local closeBtn = create("TextButton", {
			BackgroundColor3 = THEME.bg,
			BorderSizePixel = 0,
			Position = UDim2.new(0, 190, 0, 148),
			Size = UDim2.new(0, 50, 0, 20),
			AutoButtonColor = false,
			Text = "OK",
			Font = Enum.Font.GothamMedium,
			TextSize = 12,
			TextColor3 = THEME.value,
			ZIndex = 61,
		})
		closeBtn.Parent = popup
		addCorner(closeBtn, 2)
		addStroke(closeBtn, 1, THEME.strokeSoft, 0)

		local function toHex(c)
			return string.format("#%02X%02X%02X", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
		end
		local function fromHex(s)
			s = tostring(s or ""):gsub("%s+", "")
			s = s:gsub("^#", "")
			if #s == 3 then
				s = s:sub(1, 1) .. s:sub(1, 1) .. s:sub(2, 2) .. s:sub(2, 2) .. s:sub(3, 3) .. s:sub(3, 3)
			end
			if #s ~= 6 then return nil end
			local r = tonumber(s:sub(1, 2), 16)
			local g = tonumber(s:sub(3, 4), 16)
			local b = tonumber(s:sub(5, 6), 16)
			if not r or not g or not b then return nil end
			return Color3.fromRGB(r, g, b)
		end

		local function updateUI(fire)
			sv.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
			local c = hsvToColor3(h, s, v)
			outPreview.BackgroundColor3 = c
			rgbLbl.Text = string.format("%d,%d,%d", math.floor(c.R * 255 + 0.5), math.floor(c.G * 255 + 0.5), math.floor(c.B * 255 + 0.5))
			hexBox.Text = toHex(c)
			svKnob.Position = UDim2.new(s, 0, 1 - v, 0)
			hueKnob.Position = UDim2.new(0.5, 0, 1 - h, 0)
			setColor(c, fire)
		end

		updateUI(false)

		local draggingSV = false
		local draggingHue = false
		local dragInput

		local function setSVFromPos(pos)
			pos = toV2(pos)
			local rel = (pos - sv.AbsolutePosition)
			local sx = clamp01(rel.X / math.max(1, sv.AbsoluteSize.X))
			local vy = clamp01(rel.Y / math.max(1, sv.AbsoluteSize.Y))
			s = sx
			v = 1 - vy
			updateUI(true)
		end

		local function setHFromPos(pos)
			pos = toV2(pos)
			local rel = (pos - hue.AbsolutePosition)
			local hy = clamp01(rel.Y / math.max(1, hue.AbsoluteSize.Y))
			h = 1 - hy
			updateUI(true)
		end

		sv.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingSV = true
				dragInput = input
				setSVFromPos(input.Position)
			end
		end)
		sv.InputEnded:Connect(function(input)
			if input == dragInput then
				draggingSV = false
			end
		end)

		hue.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				draggingHue = true
				dragInput = input
				setHFromPos(input.Position)
			end
		end)
		hue.InputEnded:Connect(function(input)
			if input == dragInput then
				draggingHue = false
			end
		end)

		UIS.InputChanged:Connect(function(input)
			if dragInput and input.UserInputType == Enum.UserInputType.Touch and input ~= dragInput then return end
			if (draggingSV or draggingHue) and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				if draggingSV then
					setSVFromPos(input.Position)
				elseif draggingHue then
					setHFromPos(input.Position)
				end
			end
		end)

		hexBox.FocusLost:Connect(function()
			local c = fromHex(hexBox.Text)
			if c then
				h, s, v = color3ToHsv(c)
				updateUI(true)
			else
				hexBox.Text = toHex(color)
			end
		end)

		-- click outside closes
		local blocker = create("TextButton", {
			Name = "Blocker",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			AutoButtonColor = false,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 59,
		})
		blocker.Parent = window.Overlay
		blocker.LayoutOrder = -1
		connectTap(blocker, function()
			if popup.Parent then popup:Destroy() end
			if blocker.Parent then blocker:Destroy() end
		end)

		connectTap(closeBtn, function()
			if popup.Parent then popup:Destroy() end
			if blocker.Parent then blocker:Destroy() end
		end)

		applyPopupIn(popup)

		local scroll = fieldBtn:FindFirstAncestorWhichIsA("ScrollingFrame")
		if scroll then
			if scrollConn then scrollConn:Disconnect() end
			scrollConn = scroll:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
				if popup.Parent then popup:Destroy() end
			end)
		end
	end

	connectTap(fieldBtn, function()
		openPopup()
	end)

	local api = {
		Get = function() return color end,
		Set = function(c)
			if typeof(c) ~= "Color3" then return end
			setColor(c, true)
		end,
	}

	if window and flag then
		window:_registerFlag(flag, {
			Get = api.Get,
			Set = api.Set,
		})
	end

	return api
end

function Group:AddLabel(text)
	local row = makeRow(self.Body)
	row.Size = UDim2.new(1, 0, 0, 18)
	local lbl = makeLabel(row, tostring(text or ""), 12, THEME.muted, Enum.TextXAlignment.Left)
	lbl.Position = UDim2.new(0, 0, 0, 0)
	lbl.Size = UDim2.new(1, 0, 1, 0)
	return {
		Set = function(v)
			lbl.Text = tostring(v or "")
		end,
	}
end

function Group:AddButton(text, callback)
	local row = makeRow(self.Body)
	row.Size = UDim2.new(1, 0, 0, 22)
	local btn = create("TextButton", {
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 1, 0),
		AutoButtonColor = false,
		Text = tostring(text or "Button"),
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = THEME.value,
	})
	btn.Parent = row
	addCorner(btn, 2)
	addStroke(btn, 1, THEME.strokeSoft, 0)
	connectTap(btn, function()
		if callback then taskSpawn(callback) end
	end)
	return {
		SetText = function(t)
			btn.Text = tostring(t or "")
		end,
	}
end

function Group:AddTextBox(label, defaultText, callback, flag)
	callback, flag = normalizeCallbackAndFlag(callback, flag)
	local window = self.Tab and self.Tab.Window
	local row = makeRow(self.Body)
	row.Size = UDim2.new(1, 0, 0, 44)
	
	local lbl = makeLabel(row, label or "Text", 12, THEME.label, Enum.TextXAlignment.Left)
	lbl.Position = UDim2.new(0, 0, 0, 0)
	lbl.Size = UDim2.new(1, 0, 0, 16)

	local box = create("TextBox", {
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		Position = UDim2.new(0, 0, 0, 18),
		Size = UDim2.new(1, 0, 0, 26),
		ClearTextOnFocus = false,
		Text = tostring(defaultText or ""),
		PlaceholderText = "",
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = THEME.value,
		TextXAlignment = Enum.TextXAlignment.Left,
	})
	box.Parent = row
	addCorner(box, 6)
	addStroke(box, 1, THEME.stroke, 0.25)
	addPadding(box, 6)

	local function fire()
		if window and flag then
			window.Flags = window.Flags or {}
			window.Flags[flag] = box.Text
		end
		if callback then taskSpawn(callback, box.Text) end
	end
	box.FocusLost:Connect(function(enter)
		fire()
	end)

	local api = {
		Get = function() return box.Text end,
		Set = function(v)
			box.Text = tostring(v or "")
			fire()
		end,
	}

	if window and flag then
		window:_registerFlag(flag, {
			Get = api.Get,
			Set = api.Set,
		})
	end

	return api
end

function Group:AddKeybind(label, defaultKeyCode, callback, flag)
	callback, flag = normalizeCallbackAndFlag(callback, flag)
	local window = self.Tab and self.Tab.Window
	local row = makeRow(self.Body)
	row.Size = UDim2.new(1, 0, 0, 22)
	local lbl = makeLabel(row, label or "Keybind", 12, THEME.label, Enum.TextXAlignment.Left)
	lbl.Position = UDim2.new(0, 0, 0, 0)
	lbl.Size = UDim2.new(1, -190, 1, 0)

	local key = defaultKeyCode or Enum.KeyCode.RightShift
	local btn = create("TextButton", {
		BackgroundColor3 = THEME.bg,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0.5),
		Position = UDim2.new(1, 0, 0.5, 0),
		Size = UDim2.new(0, 170, 0, 26),
		AutoButtonColor = false,
		Text = key.Name,
		Font = Enum.Font.Gotham,
		TextSize = 12,
		TextColor3 = THEME.value,
	})
	btn.Parent = row
	addCorner(btn, 6)
	addStroke(btn, 1, THEME.stroke, 0.25)

	local capturing = false
	connectTap(btn, function()
		capturing = true
		btn.Text = "Press a key..."
	end)

	local conn
	conn = UIS.InputBegan:Connect(function(input, gp)
		if not capturing or gp then return end
		if input.UserInputType == Enum.UserInputType.Keyboard then
			capturing = false
			key = input.KeyCode
			btn.Text = key.Name
			if window and flag then
				window.Flags = window.Flags or {}
				window.Flags[flag] = key
			end
			if callback then taskSpawn(callback, key) end
		end
	end)

	local api = {
		Get = function() return key end,
		Set = function(v)
			if typeof(v) == "EnumItem" and v.EnumType == Enum.KeyCode then
				key = v
				btn.Text = key.Name
				if window and flag then
					window.Flags = window.Flags or {}
					window.Flags[flag] = key
				end
				if callback then taskSpawn(callback, key) end
			end
		end,
	}

	if window and flag then
		window:_registerFlag(flag, {
			Get = api.Get,
			Set = api.Set,
		})
	end

	return api
end

-- Optional helper: loader utility (requested)
function PulseUI.LoadLibrary(RAW_URL)
	RAW_URL = tostring(RAW_URL or "")
	-- 1) Executor: loadstring + HttpGet
	if RAW_URL ~= "" and type(loadstring) == "function" and typeof(game) == "Instance" and type(game.HttpGet) == "function" then
		local okSrc, src = pcall(function()
			return game:HttpGet(RAW_URL)
		end)
		if okSrc and type(src) == "string" then
			local ok, libOrErr = pcall(function()
				return loadstring(src)()
			end)
			if ok and type(libOrErr) == "table" and type(libOrErr.CreateWindow) == "function" then
				return libOrErr
			end
			warn("PulseUI RAW_URL load failed:", libOrErr)
		else
			warn("PulseUI RAW_URL HttpGet failed:", src)
		end
	end

	-- 2) Executor fallback: loadfile/readfile (if you saved ui.lua locally)
	if type(loadfile) == "function" then
		local ok, lib = pcall(function()
			return loadfile("ui.lua")()
		end)
		if ok and type(lib) == "table" and type(lib.CreateWindow) == "function" then
			return lib
		end
	end

	-- 3) Studio fallback: require a ModuleScript named "ui"
	local ok, lib = pcall(function()
		if typeof(script) == "Instance" and script.Parent then
			return require(script.Parent:WaitForChild("ui"))
		end
		return nil
	end)
	if ok and type(lib) == "table" and type(lib.CreateWindow) == "function" then
		return lib
	end

	error("Could not load PulseUI. Set RAW_URL, or place a ModuleScript named 'ui' next to this script.")
end

-- Optional runtime self-test (doesn't run unless called)
function PulseUI._SelfTest()
	local win = PulseUI:CreateWindow({
		Title = "Pulse SelfTest",
		FooterText = "SelfTest",
		HomeTab = { DiscordInvite = "", Changelog = {} },
	})
	local tab = win:CreateTab("Test")
	local g = tab:CreateGroup("Controls", "left")

	local dd = g:AddDropdown("Dynamic", { "A", "B" }, "A", function() end, "test.dropdown")
	g:AddToggle("Toggle", false, function() end, "test.toggle")
	g:AddColorPicker("Color", Color3.fromRGB(255, 0, 0), function() end, "test.color")
	g:AddKeybind("Key", Enum.KeyCode.K, function() end, "test.key")

	dd.SetOptions({ "B", "C" }, "C")
	win:SaveConfig("__pulse_selftest")
	win:SetFlag("test.toggle", true)
	win:SetFlag("test.dropdown", "B")
	win:LoadConfig("__pulse_selftest")
	win:Notify({ Title = "SelfTest", Content = "If you saw this, Notify works." })
	return win
end

return PulseUI
