--[[
	╔═══════════════════════════════════════════════════════╗
	║              QWERTY-UI  ·  MainModule                 ║
	║     Beautiful Roblox UI Library · GitHub-Powered      ║
	║                                                       ║
	║  GitHub: https://github.com/YOURNAME/QWERTY-UI        ║
	║                                                       ║
	║  USAGE (in a LocalScript):                            ║
	║    local UI = loadstring(game:HttpGet(               ║
	║      "https://raw.githubusercontent.com/             ║
	║       YOURNAME/QWERTY-UI/main/QWERTY-UI.lua"         ║
	║    ))()                                               ║
	║                                                       ║
	║    local Window = UI.new("My Window")                 ║
	║    local Tab    = Window:Tab("Main")                  ║
	║    Tab:Button("Click Me", function() end)             ║
	╚═══════════════════════════════════════════════════════╝
--]]

-- ─── Services ────────────────────────────────────────────
local TweenService    = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService      = game:GetService("RunService")
local Players         = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer
local Mouse       = LocalPlayer:GetMouse()

-- ─── Constants ───────────────────────────────────────────
local GITHUB_RAW = "https://raw.githubusercontent.com/YOURNAME/QWERTY-UI/main/"

local THEME = {
	-- Window chrome
	WindowBg        = Color3.fromRGB(18, 18, 28),
	TitleBar        = Color3.fromRGB(24, 24, 38),
	TitleBarGrad1   = Color3.fromRGB(30, 28, 55),
	TitleBarGrad2   = Color3.fromRGB(18, 18, 28),
	Border          = Color3.fromRGB(60, 55, 100),
	BorderInner     = Color3.fromRGB(40, 38, 70),

	-- Accent
	Accent          = Color3.fromRGB(120, 90, 255),
	AccentHover     = Color3.fromRGB(145, 115, 255),
	AccentDark      = Color3.fromRGB(75, 55, 180),
	AccentGlow      = Color3.fromRGB(100, 70, 220),

	-- Tabs
	TabBg           = Color3.fromRGB(22, 22, 35),
	TabActive       = Color3.fromRGB(30, 28, 52),
	TabHover        = Color3.fromRGB(26, 24, 44),

	-- Elements
	ElementBg       = Color3.fromRGB(26, 24, 42),
	ElementHover    = Color3.fromRGB(34, 32, 56),
	ElementStroke   = Color3.fromRGB(55, 50, 90),

	-- Slider / Toggle
	SliderFill      = Color3.fromRGB(120, 90, 255),
	SliderTrack     = Color3.fromRGB(35, 33, 58),
	ToggleOn        = Color3.fromRGB(90, 220, 160),
	ToggleOff       = Color3.fromRGB(55, 50, 80),

	-- Text
	TextPrimary     = Color3.fromRGB(235, 232, 255),
	TextSecondary   = Color3.fromRGB(140, 130, 185),
	TextMuted       = Color3.fromRGB(90, 82, 130),
	TextAccent      = Color3.fromRGB(160, 135, 255),

	-- Notifications
	NotifBg         = Color3.fromRGB(22, 20, 38),
	NotifSuccess    = Color3.fromRGB(80, 220, 150),
	NotifError      = Color3.fromRGB(255, 90, 110),
	NotifWarn       = Color3.fromRGB(255, 200, 80),
	NotifInfo       = Color3.fromRGB(90, 170, 255),

	-- Misc
	Shadow          = Color3.fromRGB(0, 0, 0),
	Separator       = Color3.fromRGB(42, 40, 65),
	ScrollBar       = Color3.fromRGB(60, 55, 100),
}

local TWEEN_FAST   = TweenInfo.new(0.15, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_MEDIUM = TweenInfo.new(0.25, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local TWEEN_SLOW   = TweenInfo.new(0.4,  Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

-- ─── Utility ─────────────────────────────────────────────
local function tween(obj, info, props)
	TweenService:Create(obj, info, props):Play()
end

local function makeCorner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 10)
	c.Parent = parent
	return c
end

local function makeStroke(parent, color, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = color or THEME.Border
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0
	s.Parent = parent
	return s
end

local function makeGradient(parent, color0, color1, rotation)
	local g = Instance.new("UIGradient")
	g.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, color0),
		ColorSequenceKeypoint.new(1, color1),
	})
	g.Rotation = rotation or 90
	g.Parent = parent
	return g
end

local function makeShadow(parent, size, transparency)
	-- Soft drop-shadow using an ImageLabel with a blurred circle asset
	local shadow = Instance.new("ImageLabel")
	shadow.Name = "_Shadow"
	shadow.AnchorPoint = Vector2.new(0.5, 0.5)
	shadow.BackgroundTransparency = 1
	shadow.Position = UDim2.new(0.5, 0, 0.5, 6)
	shadow.Size = UDim2.new(1, size or 30, 1, size or 30)
	shadow.ZIndex = parent.ZIndex - 1
	shadow.Image = "rbxassetid://6015897843" -- Roblox drop shadow asset
	shadow.ImageColor3 = THEME.Shadow
	shadow.ImageTransparency = transparency or 0.55
	shadow.ScaleType = Enum.ScaleType.Slice
	shadow.SliceCenter = Rect.new(49, 49, 450, 450)
	shadow.Parent = parent
	return shadow
end

-- ─── Dragging Helper ─────────────────────────────────────
local function makeDraggable(frame, handle)
	handle = handle or frame
	local dragging, dragInput, dragStart, startPos

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging  = true
			dragStart = input.Position
			startPos  = frame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	handle.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			tween(frame, TWEEN_FAST, {
				Position = UDim2.new(
					startPos.X.Scale,
					startPos.X.Offset + delta.X,
					startPos.Y.Scale,
					startPos.Y.Offset + delta.Y
				)
			})
		end
	end)
end

-- ─── Notification System ──────────────────────────────────
local NotifHolder

local function ensureNotifHolder()
	if NotifHolder and NotifHolder.Parent then return end
	local sg = Instance.new("ScreenGui")
	sg.Name = "QWERTY_Notifs"
	sg.ResetOnSpawn = false
	sg.DisplayOrder = 9999
	sg.Parent = LocalPlayer:WaitForChild("PlayerGui")

	NotifHolder = Instance.new("Frame")
	NotifHolder.Name = "Holder"
	NotifHolder.BackgroundTransparency = 1
	NotifHolder.AnchorPoint = Vector2.new(1, 1)
	NotifHolder.Position = UDim2.new(1, -20, 1, -20)
	NotifHolder.Size = UDim2.new(0, 310, 1, -20)
	NotifHolder.Parent = sg

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	layout.Padding = UDim.new(0, 8)
	layout.Parent = NotifHolder
end

local function notify(opts)
	opts = opts or {}
	local title    = opts.Title    or "Notification"
	local desc     = opts.Desc     or ""
	local duration = opts.Duration or 4
	local ntype    = opts.Type     or "Info" -- Info | Success | Error | Warn

	ensureNotifHolder()

	local accentColor = ({
		Info    = THEME.NotifInfo,
		Success = THEME.NotifSuccess,
		Error   = THEME.NotifError,
		Warn    = THEME.NotifWarn,
	})[ntype] or THEME.NotifInfo

	local icons = { Info = "ℹ", Success = "✓", Error = "✕", Warn = "⚠" }

	-- Container
	local card = Instance.new("Frame")
	card.Name = "Notif"
	card.BackgroundColor3 = THEME.NotifBg
	card.Size = UDim2.new(1, 0, 0, 64)
	card.BackgroundTransparency = 1
	card.ClipsDescendants = true
	card.Parent = NotifHolder
	makeCorner(card, 10)
	makeStroke(card, THEME.Border, 1, 0.4)
	makeShadow(card, 20, 0.6)

	-- Accent bar
	local bar = Instance.new("Frame")
	bar.BackgroundColor3 = accentColor
	bar.Size = UDim2.new(0, 3, 1, 0)
	bar.BorderSizePixel = 0
	bar.Parent = card
	makeCorner(bar, 3)

	-- Icon
	local icon = Instance.new("TextLabel")
	icon.BackgroundTransparency = 1
	icon.Position = UDim2.new(0, 14, 0, 0)
	icon.Size = UDim2.new(0, 24, 1, 0)
	icon.Text = icons[ntype] or "ℹ"
	icon.TextColor3 = accentColor
	icon.TextSize = 18
	icon.Font = Enum.Font.GothamBold
	icon.Parent = card

	-- Title
	local titleLbl = Instance.new("TextLabel")
	titleLbl.BackgroundTransparency = 1
	titleLbl.Position = UDim2.new(0, 44, 0, 10)
	titleLbl.Size = UDim2.new(1, -54, 0, 20)
	titleLbl.Text = title
	titleLbl.TextColor3 = THEME.TextPrimary
	titleLbl.TextSize = 13
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.TextXAlignment = Enum.TextXAlignment.Left
	titleLbl.Parent = card

	-- Desc
	local descLbl = Instance.new("TextLabel")
	descLbl.BackgroundTransparency = 1
	descLbl.Position = UDim2.new(0, 44, 0, 30)
	descLbl.Size = UDim2.new(1, -54, 0, 28)
	descLbl.Text = desc
	descLbl.TextColor3 = THEME.TextSecondary
	descLbl.TextSize = 11
	descLbl.Font = Enum.Font.Gotham
	descLbl.TextXAlignment = Enum.TextXAlignment.Left
	descLbl.TextWrapped = true
	descLbl.Parent = card

	-- Progress bar
	local prog = Instance.new("Frame")
	prog.BackgroundColor3 = accentColor
	prog.AnchorPoint = Vector2.new(0, 1)
	prog.Position = UDim2.new(0, 3, 1, 0)
	prog.Size = UDim2.new(1, -3, 0, 2)
	prog.BorderSizePixel = 0
	prog.Parent = card

	-- Slide in
	card.Position = UDim2.new(1, 20, 0, 0)
	tween(card, TWEEN_MEDIUM, { BackgroundTransparency = 0, Position = UDim2.new(0, 0, 0, 0) })

	-- Shrink progress
	tween(prog, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })

	-- Slide out + destroy
	task.delay(duration, function()
		tween(card, TWEEN_MEDIUM, { BackgroundTransparency = 1, Position = UDim2.new(1, 20, 0, 0) })
		task.delay(0.3, function() card:Destroy() end)
	end)
end

-- ─── QWERTY-UI Constructor ────────────────────────────────
local Library = {}
Library.__index = Library

function Library.new(title, opts)
	opts = opts or {}
	local self = setmetatable({}, Library)
	self._tabs   = {}
	self._active = nil

	-- ── ScreenGui ──────────────────────────────────────────
	local gui = Instance.new("ScreenGui")
	gui.Name = "QWERTY_UI_" .. title:gsub("%s", "_")
	gui.ResetOnSpawn = false
	gui.DisplayOrder = 100
	gui.Parent = LocalPlayer:WaitForChild("PlayerGui")
	self._gui = gui

	-- ── Main Window ────────────────────────────────────────
	local win = Instance.new("Frame")
	win.Name = "Window"
	win.BackgroundColor3 = THEME.WindowBg
	win.AnchorPoint = Vector2.new(0.5, 0.5)
	win.Position = UDim2.new(0.5, 0, 0.5, 0)
	win.Size = UDim2.new(0, opts.Width or 560, 0, opts.Height or 380)
	win.ClipsDescendants = true
	win.Parent = gui
	makeCorner(win, 12)
	makeStroke(win, THEME.Border, 1.5)
	makeShadow(win, 50, 0.45)
	self._win = win

	-- ── Title Bar ──────────────────────────────────────────
	local titleBar = Instance.new("Frame")
	titleBar.Name = "TitleBar"
	titleBar.BackgroundColor3 = THEME.TitleBar
	titleBar.Size = UDim2.new(1, 0, 0, 44)
	titleBar.Parent = win
	makeCorner(titleBar, 12) -- top corners only workaround: clip inner bottom
	makeGradient(titleBar, THEME.TitleBarGrad1, THEME.TitleBarGrad2, 135)

	-- Cover bottom corners of titlebar
	local tbCover = Instance.new("Frame")
	tbCover.BackgroundColor3 = THEME.TitleBar
	tbCover.Position = UDim2.new(0, 0, 0.5, 0)
	tbCover.Size = UDim2.new(1, 0, 0.5, 0)
	tbCover.BorderSizePixel = 0
	tbCover.Parent = titleBar
	makeGradient(tbCover, THEME.TitleBarGrad1, THEME.TitleBarGrad2, 135)

	-- Separator under title bar
	local sep = Instance.new("Frame")
	sep.BackgroundColor3 = THEME.Border
	sep.Position = UDim2.new(0, 0, 0, 44)
	sep.Size = UDim2.new(1, 0, 0, 1)
	sep.BorderSizePixel = 0
	sep.Parent = win

	-- Dot decorations (Win-styled close/min but beautiful)
	local dotFrame = Instance.new("Frame")
	dotFrame.BackgroundTransparency = 1
	dotFrame.Position = UDim2.new(0, 12, 0.5, 0)
	dotFrame.AnchorPoint = Vector2.new(0, 0.5)
	dotFrame.Size = UDim2.new(0, 60, 0, 12)
	dotFrame.Parent = titleBar

	local dotColors = {
		Color3.fromRGB(255, 95, 87),
		Color3.fromRGB(255, 189, 46),
		Color3.fromRGB(40, 200, 64),
	}
	for i, col in ipairs(dotColors) do
		local dot = Instance.new("Frame")
		dot.BackgroundColor3 = col
		dot.Size = UDim2.new(0, 11, 0, 11)
		dot.Position = UDim2.new(0, (i - 1) * 17, 0.5, 0)
		dot.AnchorPoint = Vector2.new(0, 0.5)
		dot.Parent = dotFrame
		makeCorner(dot, 99)
	end

	-- Title text
	local titleLbl = Instance.new("TextLabel")
	titleLbl.BackgroundTransparency = 1
	titleLbl.AnchorPoint = Vector2.new(0.5, 0.5)
	titleLbl.Position = UDim2.new(0.5, 0, 0.5, 0)
	titleLbl.Size = UDim2.new(1, -150, 1, 0)
	titleLbl.Text = title
	titleLbl.TextColor3 = THEME.TextPrimary
	titleLbl.TextSize = 13
	titleLbl.Font = Enum.Font.GothamBold
	titleLbl.Parent = titleBar

	-- Version label
	local verLbl = Instance.new("TextLabel")
	verLbl.BackgroundTransparency = 1
	verLbl.AnchorPoint = Vector2.new(1, 0.5)
	verLbl.Position = UDim2.new(1, -14, 0.5, 0)
	verLbl.Size = UDim2.new(0, 80, 1, 0)
	verLbl.Text = "QWERTY-UI"
	verLbl.TextColor3 = THEME.TextMuted
	verLbl.TextSize = 10
	verLbl.Font = Enum.Font.Gotham
	verLbl.TextXAlignment = Enum.TextXAlignment.Right
	verLbl.Parent = titleBar

	makeDraggable(win, titleBar)

	-- ── Tab Bar ────────────────────────────────────────────
	local tabBar = Instance.new("Frame")
	tabBar.Name = "TabBar"
	tabBar.BackgroundColor3 = THEME.TabBg
	tabBar.Position = UDim2.new(0, 0, 0, 45)
	tabBar.Size = UDim2.new(0, 130, 1, -45)
	tabBar.Parent = win

	local tabSep = Instance.new("Frame")
	tabSep.BackgroundColor3 = THEME.Border
	tabSep.Position = UDim2.new(1, 0, 0, 0)
	tabSep.Size = UDim2.new(0, 1, 1, 0)
	tabSep.BorderSizePixel = 0
	tabSep.Parent = tabBar

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.Parent = tabBar

	local tabPad = Instance.new("UIPadding")
	tabPad.PaddingTop = UDim.new(0, 8)
	tabPad.PaddingLeft = UDim.new(0, 8)
	tabPad.PaddingRight = UDim.new(0, 8)
	tabPad.Parent = tabBar

	self._tabBar = tabBar

	-- ── Content Area ───────────────────────────────────────
	local content = Instance.new("Frame")
	content.Name = "Content"
	content.BackgroundTransparency = 1
	content.Position = UDim2.new(0, 131, 0, 45)
	content.Size = UDim2.new(1, -131, 1, -45)
	content.Parent = win
	self._content = content

	-- Open animation
	win.Size = UDim2.new(0, 0, 0, 0)
	win.BackgroundTransparency = 1
	tween(win, TWEEN_MEDIUM, {
		Size = UDim2.new(0, opts.Width or 560, 0, opts.Height or 380),
		BackgroundTransparency = 0
	})

	return self
end

-- ─── Tab ─────────────────────────────────────────────────
function Library:Tab(name, icon)
	local tabData = { _elements = {}, _name = name }

	-- Tab button
	local btn = Instance.new("TextButton")
	btn.BackgroundColor3 = THEME.TabBg
	btn.BackgroundTransparency = 1
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.Text = (icon and (icon .. "  ") or "") .. name
	btn.TextColor3 = THEME.TextMuted
	btn.TextSize = 12
	btn.Font = Enum.Font.GothamSemibold
	btn.AutoButtonColor = false
	btn.ClipsDescendants = true
	btn.Parent = self._tabBar
	makeCorner(btn, 8)

	-- Active indicator stripe
	local stripe = Instance.new("Frame")
	stripe.BackgroundColor3 = THEME.Accent
	stripe.AnchorPoint = Vector2.new(0, 0.5)
	stripe.Position = UDim2.new(0, -4, 0.5, 0)
	stripe.Size = UDim2.new(0, 3, 0, 18)
	stripe.BorderSizePixel = 0
	stripe.Parent = btn
	makeCorner(stripe, 4)

	-- Scroll container for elements
	local scroll = Instance.new("ScrollingFrame")
	scroll.BackgroundTransparency = 1
	scroll.Position = UDim2.new(0, 0, 0, 0)
	scroll.Size = UDim2.new(1, 0, 1, 0)
	scroll.ScrollBarThickness = 3
	scroll.ScrollBarImageColor3 = THEME.ScrollBar
	scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
	scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
	scroll.Visible = false
	scroll.Parent = self._content

	local layout = Instance.new("UIListLayout")
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Padding = UDim.new(0, 6)
	layout.Parent = scroll

	local pad = Instance.new("UIPadding")
	pad.PaddingTop    = UDim.new(0, 10)
	pad.PaddingLeft   = UDim.new(0, 10)
	pad.PaddingRight  = UDim.new(0, 10)
	pad.PaddingBottom = UDim.new(0, 10)
	pad.Parent = scroll

	tabData._scroll = scroll
	tabData._btn    = btn
	tabData._stripe = stripe

	-- Hover
	btn.MouseEnter:Connect(function()
		if self._active ~= tabData then
			tween(btn, TWEEN_FAST, { BackgroundTransparency = 0.88, TextColor3 = THEME.TextSecondary })
		end
	end)
	btn.MouseLeave:Connect(function()
		if self._active ~= tabData then
			tween(btn, TWEEN_FAST, { BackgroundTransparency = 1, TextColor3 = THEME.TextMuted })
		end
	end)

	btn.MouseButton1Click:Connect(function()
		self:_selectTab(tabData)
	end)

	table.insert(self._tabs, tabData)

	-- Auto-select first tab
	if #self._tabs == 1 then
		task.defer(function() self:_selectTab(tabData) end)
	end

	-- ── Element Builders ──────────────────────────────────
	local Tab = {}

	-- Helper: base element frame
	local function baseElement(height)
		local el = Instance.new("Frame")
		el.BackgroundColor3 = THEME.ElementBg
		el.Size = UDim2.new(1, 0, 0, height or 40)
		el.ClipsDescendants = false
		el.Parent = scroll
		makeCorner(el, 8)
		makeStroke(el, THEME.ElementStroke, 1, 0.5)
		return el
	end

	-- ── Button ────────────────────────────────────────────
	function Tab:Button(text, callback, desc)
		local el = baseElement(40)
		el.BackgroundColor3 = THEME.ElementBg

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Position = UDim2.new(0, 14, 0, 0)
		lbl.Size = UDim2.new(1, -80, 1, 0)
		lbl.Text = text
		lbl.TextColor3 = THEME.TextPrimary
		lbl.TextSize = 13
		lbl.Font = Enum.Font.GothamSemibold
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = el

		if desc then
			el.Size = UDim2.new(1, 0, 0, 54)
			lbl.Position = UDim2.new(0, 14, 0, 6)
			lbl.Size = UDim2.new(1, -80, 0, 20)
			local descLbl = Instance.new("TextLabel")
			descLbl.BackgroundTransparency = 1
			descLbl.Position = UDim2.new(0, 14, 0, 28)
			descLbl.Size = UDim2.new(1, -80, 0, 18)
			descLbl.Text = desc
			descLbl.TextColor3 = THEME.TextMuted
			descLbl.TextSize = 10
			descLbl.Font = Enum.Font.Gotham
			descLbl.TextXAlignment = Enum.TextXAlignment.Left
			descLbl.Parent = el
		end

		-- Ripple button
		local clickBtn = Instance.new("TextButton")
		clickBtn.BackgroundTransparency = 1
		clickBtn.Size = UDim2.new(1, 0, 1, 0)
		clickBtn.Text = ""
		clickBtn.AutoButtonColor = false
		clickBtn.Parent = el

		local function ripple(x, y)
			local rip = Instance.new("Frame")
			rip.BackgroundColor3 = THEME.Accent
			rip.BackgroundTransparency = 0.7
			rip.AnchorPoint = Vector2.new(0.5, 0.5)
			rip.Position = UDim2.new(0, x, 0, y)
			rip.Size = UDim2.new(0, 0, 0, 0)
			rip.ZIndex = 10
			rip.Parent = el
			makeCorner(rip, 99)
			tween(rip, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
				Size = UDim2.new(0, 200, 0, 200),
				BackgroundTransparency = 1,
			})
			task.delay(0.4, function() rip:Destroy() end)
		end

		clickBtn.MouseEnter:Connect(function()
			tween(el, TWEEN_FAST, { BackgroundColor3 = THEME.ElementHover })
		end)
		clickBtn.MouseLeave:Connect(function()
			tween(el, TWEEN_FAST, { BackgroundColor3 = THEME.ElementBg })
		end)
		clickBtn.MouseButton1Click:Connect(function()
			local mp = UserInputService:GetMouseLocation()
			local abs = el.AbsolutePosition
			ripple(mp.X - abs.X, mp.Y - abs.Y)
			if callback then callback() end
		end)
	end

	-- ── Toggle ────────────────────────────────────────────
	function Tab:Toggle(text, default, callback, desc)
		local state = default or false
		local el = baseElement(desc and 54 or 40)

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Position = UDim2.new(0, 14, 0, desc and 6 or 0)
		lbl.Size = UDim2.new(1, -66, 0, 20)
		lbl.Text = text
		lbl.TextColor3 = THEME.TextPrimary
		lbl.TextSize = 13
		lbl.Font = Enum.Font.GothamSemibold
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = el

		if desc then
			local d = Instance.new("TextLabel")
			d.BackgroundTransparency = 1
			d.Position = UDim2.new(0, 14, 0, 28)
			d.Size = UDim2.new(1, -66, 0, 18)
			d.Text = desc
			d.TextColor3 = THEME.TextMuted
			d.TextSize = 10
			d.Font = Enum.Font.Gotham
			d.TextXAlignment = Enum.TextXAlignment.Left
			d.Parent = el
		end

		-- Track
		local track = Instance.new("Frame")
		track.AnchorPoint = Vector2.new(1, 0.5)
		track.Position = UDim2.new(1, -12, 0.5, 0)
		track.Size = UDim2.new(0, 38, 0, 20)
		track.BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff
		track.Parent = el
		makeCorner(track, 99)

		-- Knob
		local knob = Instance.new("Frame")
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.AnchorPoint = Vector2.new(0, 0.5)
		knob.Position = state and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
		knob.Size = UDim2.new(0, 16, 0, 16)
		knob.Parent = track
		makeCorner(knob, 99)

		local clickBtn = Instance.new("TextButton")
		clickBtn.BackgroundTransparency = 1
		clickBtn.Size = UDim2.new(1, 0, 1, 0)
		clickBtn.Text = ""
		clickBtn.AutoButtonColor = false
		clickBtn.Parent = el

		local function updateVisual()
			tween(track, TWEEN_FAST, { BackgroundColor3 = state and THEME.ToggleOn or THEME.ToggleOff })
			tween(knob,  TWEEN_FAST, { Position = state and UDim2.new(0, 20, 0.5, 0) or UDim2.new(0, 2, 0.5, 0) })
		end

		clickBtn.MouseButton1Click:Connect(function()
			state = not state
			updateVisual()
			if callback then callback(state) end
		end)

		updateVisual()

		return {
			Set = function(v)
				state = v
				updateVisual()
				if callback then callback(state) end
			end,
			Get = function() return state end,
		}
	end

	-- ── Slider ────────────────────────────────────────────
	function Tab:Slider(text, min, max, default, callback, suffix)
		min = min or 0; max = max or 100; default = default or min
		local val = default
		local el = baseElement(58)

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Position = UDim2.new(0, 14, 0, 8)
		lbl.Size = UDim2.new(1, -90, 0, 18)
		lbl.Text = text
		lbl.TextColor3 = THEME.TextPrimary
		lbl.TextSize = 12
		lbl.Font = Enum.Font.GothamSemibold
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = el

		local valLbl = Instance.new("TextLabel")
		valLbl.BackgroundTransparency = 1
		valLbl.AnchorPoint = Vector2.new(1, 0)
		valLbl.Position = UDim2.new(1, -12, 0, 8)
		valLbl.Size = UDim2.new(0, 70, 0, 18)
		valLbl.Text = tostring(val) .. (suffix or "")
		valLbl.TextColor3 = THEME.TextAccent
		valLbl.TextSize = 12
		valLbl.Font = Enum.Font.GothamBold
		valLbl.TextXAlignment = Enum.TextXAlignment.Right
		valLbl.Parent = el

		-- Track
		local trackBg = Instance.new("Frame")
		trackBg.BackgroundColor3 = THEME.SliderTrack
		trackBg.Position = UDim2.new(0, 14, 0, 38)
		trackBg.Size = UDim2.new(1, -28, 0, 6)
		trackBg.Parent = el
		makeCorner(trackBg, 6)

		local fill = Instance.new("Frame")
		fill.BackgroundColor3 = THEME.SliderFill
		fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
		fill.Parent = trackBg
		makeCorner(fill, 6)
		makeGradient(fill, THEME.Accent, THEME.AccentHover, 90)

		-- Knob
		local knob = Instance.new("Frame")
		knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		knob.AnchorPoint = Vector2.new(0.5, 0.5)
		knob.Position = UDim2.new((val - min) / (max - min), 0, 0.5, 0)
		knob.Size = UDim2.new(0, 14, 0, 14)
		knob.Parent = trackBg
		makeCorner(knob, 99)

		local dragging = false

		trackBg.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = true
			end
		end)

		UserInputService.InputChanged:Connect(function(input)
			if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
				local abs = trackBg.AbsolutePosition
				local sz  = trackBg.AbsoluteSize
				local pct = math.clamp((input.Position.X - abs.X) / sz.X, 0, 1)
				val = math.round(min + pct * (max - min))
				valLbl.Text = tostring(val) .. (suffix or "")
				tween(fill,  TWEEN_FAST, { Size = UDim2.new(pct, 0, 1, 0) })
				tween(knob,  TWEEN_FAST, { Position = UDim2.new(pct, 0, 0.5, 0) })
				if callback then callback(val) end
			end
		end)

		UserInputService.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 then
				dragging = false
			end
		end)

		return {
			Set = function(v)
				val = math.clamp(v, min, max)
				local pct = (val - min) / (max - min)
				valLbl.Text = tostring(val) .. (suffix or "")
				tween(fill, TWEEN_FAST, { Size = UDim2.new(pct, 0, 1, 0) })
				tween(knob, TWEEN_FAST, { Position = UDim2.new(pct, 0, 0.5, 0) })
				if callback then callback(val) end
			end,
			Get = function() return val end,
		}
	end

	-- ── Dropdown ──────────────────────────────────────────
	function Tab:Dropdown(text, options, default, callback)
		local selected = default or options[1]
		local open = false
		local el = baseElement(40)
		el.ClipsDescendants = false

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Position = UDim2.new(0, 14, 0, 0)
		lbl.Size = UDim2.new(0.5, 0, 1, 0)
		lbl.Text = text
		lbl.TextColor3 = THEME.TextPrimary
		lbl.TextSize = 12
		lbl.Font = Enum.Font.GothamSemibold
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = el

		local selLbl = Instance.new("TextLabel")
		selLbl.BackgroundTransparency = 1
		selLbl.AnchorPoint = Vector2.new(1, 0.5)
		selLbl.Position = UDim2.new(1, -32, 0.5, 0)
		selLbl.Size = UDim2.new(0.45, 0, 1, 0)
		selLbl.Text = selected
		selLbl.TextColor3 = THEME.TextAccent
		selLbl.TextSize = 12
		selLbl.Font = Enum.Font.GothamBold
		selLbl.TextXAlignment = Enum.TextXAlignment.Right
		selLbl.Parent = el

		-- Arrow
		local arrow = Instance.new("TextLabel")
		arrow.BackgroundTransparency = 1
		arrow.AnchorPoint = Vector2.new(1, 0.5)
		arrow.Position = UDim2.new(1, -10, 0.5, 0)
		arrow.Size = UDim2.new(0, 18, 0, 18)
		arrow.Text = "▾"
		arrow.TextColor3 = THEME.TextMuted
		arrow.TextSize = 12
		arrow.Font = Enum.Font.GothamBold
		arrow.Parent = el

		-- Dropdown panel
		local panel = Instance.new("Frame")
		panel.BackgroundColor3 = THEME.Panel or Color3.fromRGB(20, 18, 36)
		panel.Position = UDim2.new(0, 0, 1, 4)
		panel.Size = UDim2.new(1, 0, 0, 0)
		panel.ClipsDescendants = true
		panel.ZIndex = 20
		panel.Visible = false
		panel.Parent = el
		makeCorner(panel, 8)
		makeStroke(panel, THEME.Border, 1, 0.3)

		local panelLayout = Instance.new("UIListLayout")
		panelLayout.SortOrder = Enum.SortOrder.LayoutOrder
		panelLayout.Parent = panel

		local panelPad = Instance.new("UIPadding")
		panelPad.PaddingTop    = UDim.new(0, 4)
		panelPad.PaddingBottom = UDim.new(0, 4)
		panelPad.Parent = panel

		for _, opt in ipairs(options) do
			local optBtn = Instance.new("TextButton")
			optBtn.BackgroundTransparency = 1
			optBtn.Size = UDim2.new(1, 0, 0, 30)
			optBtn.Text = opt
			optBtn.TextColor3 = opt == selected and THEME.TextAccent or THEME.TextSecondary
			optBtn.TextSize = 12
			optBtn.Font = Enum.Font.Gotham
			optBtn.AutoButtonColor = false
			optBtn.ZIndex = 21
			optBtn.Parent = panel

			optBtn.MouseEnter:Connect(function()
				tween(optBtn, TWEEN_FAST, { BackgroundTransparency = 0.88, TextColor3 = THEME.TextPrimary })
				optBtn.BackgroundColor3 = THEME.Accent
			end)
			optBtn.MouseLeave:Connect(function()
				tween(optBtn, TWEEN_FAST, { BackgroundTransparency = 1, TextColor3 = opt == selected and THEME.TextAccent or THEME.TextSecondary })
			end)
			optBtn.MouseButton1Click:Connect(function()
				selected = opt
				selLbl.Text = opt
				for _, child in ipairs(panel:GetChildren()) do
					if child:IsA("TextButton") then
						child.TextColor3 = child.Text == selected and THEME.TextAccent or THEME.TextSecondary
					end
				end
				tween(panel, TWEEN_FAST, { Size = UDim2.new(1, 0, 0, 0) })
				panel.Visible = false
				open = false
				tween(arrow, TWEEN_FAST, { Rotation = 0 })
				if callback then callback(selected) end
			end)
		end

		local totalH = #options * 30 + 8

		local clickBtn = Instance.new("TextButton")
		clickBtn.BackgroundTransparency = 1
		clickBtn.Size = UDim2.new(1, 0, 1, 0)
		clickBtn.Text = ""
		clickBtn.AutoButtonColor = false
		clickBtn.Parent = el

		clickBtn.MouseButton1Click:Connect(function()
			open = not open
			panel.Visible = open
			tween(panel, TWEEN_FAST, { Size = open and UDim2.new(1, 0, 0, totalH) or UDim2.new(1, 0, 0, 0) })
			tween(arrow, TWEEN_FAST, { Rotation = open and 180 or 0 })
		end)

		return {
			Set = function(v) selected = v; selLbl.Text = v; if callback then callback(v) end end,
			Get = function() return selected end,
		}
	end

	-- ── Label / Separator ─────────────────────────────────
	function Tab:Label(text)
		local el = Instance.new("TextLabel")
		el.BackgroundTransparency = 1
		el.Size = UDim2.new(1, 0, 0, 22)
		el.Text = "  " .. text
		el.TextColor3 = THEME.TextMuted
		el.TextSize = 11
		el.Font = Enum.Font.GothamSemibold
		el.TextXAlignment = Enum.TextXAlignment.Left
		el.Parent = scroll
	end

	function Tab:Separator(text)
		local wrap = Instance.new("Frame")
		wrap.BackgroundTransparency = 1
		wrap.Size = UDim2.new(1, 0, 0, 20)
		wrap.Parent = scroll

		local line = Instance.new("Frame")
		line.BackgroundColor3 = THEME.Separator
		line.AnchorPoint = Vector2.new(0, 0.5)
		line.Position = UDim2.new(0, 0, 0.5, 0)
		line.Size = UDim2.new(1, 0, 0, 1)
		line.Parent = wrap

		if text then
			local lbl = Instance.new("TextLabel")
			lbl.BackgroundColor3 = THEME.WindowBg
			lbl.AnchorPoint = Vector2.new(0.5, 0.5)
			lbl.Position = UDim2.new(0.5, 0, 0.5, 0)
			lbl.Size = UDim2.new(0, #text * 7 + 16, 0, 16)
			lbl.Text = text
			lbl.TextColor3 = THEME.TextMuted
			lbl.TextSize = 10
			lbl.Font = Enum.Font.GothamSemibold
			lbl.Parent = wrap
		end
	end

	-- ── Input ─────────────────────────────────────────────
	function Tab:Input(text, placeholder, callback)
		local el = baseElement(54)

		local lbl = Instance.new("TextLabel")
		lbl.BackgroundTransparency = 1
		lbl.Position = UDim2.new(0, 14, 0, 6)
		lbl.Size = UDim2.new(1, -28, 0, 16)
		lbl.Text = text
		lbl.TextColor3 = THEME.TextPrimary
		lbl.TextSize = 12
		lbl.Font = Enum.Font.GothamSemibold
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.Parent = el

		local inputBox = Instance.new("TextBox")
		inputBox.BackgroundColor3 = THEME.SliderTrack
		inputBox.Position = UDim2.new(0, 14, 0, 26)
		inputBox.Size = UDim2.new(1, -28, 0, 22)
		inputBox.PlaceholderText = placeholder or "Type here..."
		inputBox.PlaceholderColor3 = THEME.TextMuted
		inputBox.Text = ""
		inputBox.TextColor3 = THEME.TextPrimary
		inputBox.TextSize = 12
		inputBox.Font = Enum.Font.Gotham
		inputBox.ClearTextOnFocus = false
		inputBox.Parent = el
		makeCorner(inputBox, 6)
		makeStroke(inputBox, THEME.ElementStroke, 1, 0.4)

		inputBox.Focused:Connect(function()
			tween(inputBox, TWEEN_FAST, { })
			makeStroke(inputBox, THEME.Accent, 1, 0)
		end)

		inputBox.FocusLost:Connect(function(enter)
			if enter and callback then callback(inputBox.Text) end
		end)

		return {
			Get = function() return inputBox.Text end,
			Set = function(v) inputBox.Text = v end,
		}
	end

	return Tab
end

-- ─── Tab Selection Internal ───────────────────────────────
function Library:_selectTab(tabData)
	if self._active == tabData then return end
	if self._active then
		local prev = self._active
		tween(prev._btn, TWEEN_FAST, {
			BackgroundTransparency = 1,
			TextColor3 = THEME.TextMuted
		})
		tween(prev._stripe, TWEEN_FAST, { Position = UDim2.new(0, -4, 0.5, 0) })
		prev._scroll.Visible = false
	end
	self._active = tabData
	tween(tabData._btn, TWEEN_FAST, {
		BackgroundTransparency = 0.85,
		TextColor3 = THEME.TextAccent
	})
	tabData._btn.BackgroundColor3 = THEME.Accent
	tween(tabData._stripe, TWEEN_FAST, { Position = UDim2.new(0, 0, 0.5, 0) })
	tabData._scroll.Visible = true
end

-- ─── Destroy ─────────────────────────────────────────────
function Library:Destroy()
	tween(self._win, TWEEN_MEDIUM, {
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1
	})
	task.delay(0.3, function() self._gui:Destroy() end)
end

-- ─── Public API ───────────────────────────────────────────
return {
	new      = function(title, opts) return Library.new(title, opts) end,
	Notify   = notify,
	Theme    = THEME,
	Version  = "1.0.0",

	--[[
		QUICK-START EXAMPLE
		────────────────────
		local UI = loadstring(game:HttpGet(
			"https://raw.githubusercontent.com/YOURNAME/QWERTY-UI/main/QWERTY-UI.lua"
		))()

		-- Optional: customise theme before creating windows
		-- UI.Theme.Accent = Color3.fromRGB(255, 100, 80)

		local win = UI.new("My Game", { Width = 560, Height = 400 })

		local main = win:Tab("🏠 Home")
		local sets  = win:Tab("⚙ Settings")

		main:Button("Say Hello", function()
			UI.Notify({ Title = "Hello!", Desc = "Button was pressed.", Type = "Success" })
		end, "Sends a notification")

		main:Separator("Options")

		local godToggle = main:Toggle("God Mode", false, function(v)
			-- your logic
		end)

		local speedSlider = main:Slider("Walk Speed", 16, 100, 16, function(v)
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = v
		end, " stud/s")

		sets:Dropdown("Theme", {"Dark", "Light", "Neon"}, "Dark", function(v)
			print("Theme:", v)
		end)

		sets:Input("Server Note", "Enter a message...", function(text)
			print("Note:", text)
		end)
	--]]
}
