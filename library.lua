-- ====================== ABYSS CUSTOM UI LIBRARY (MOTOR) ======================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")
local Camera = Workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Library = {}

function Library:CreateWindow(config)
	config = config or {}
	local titleText = config.Title or "ABYSS • PANEL"

	-- Duplikáció és cleanup
	if PlayerGui:FindFirstChild("AbyssCustomUI") then
		PlayerGui.AbyssCustomUI:Destroy()
	end
	if CoreGui:FindFirstChild("AbyssSplash") then
		CoreGui.AbyssSplash:Destroy()
	end

	local AllConnections = {}
	local AllFeatures = {}

	local function AddConn(conn)
		table.insert(AllConnections, conn)
		return conn
	end

	local function KillEverything()
		for _, conn in ipairs(AllConnections) do
			pcall(function() conn:Disconnect() end)
		end
		AllConnections = {}

		local gui = PlayerGui:FindFirstChild("AbyssCustomUI")
		if gui then gui:Destroy() end
		local splash = CoreGui:FindFirstChild("AbyssSplash")
		if splash then splash:Destroy() end
	end

	-- ===== INTRO / SPLASH =====
	do
		local SplashGui = Instance.new("ScreenGui")
		SplashGui.Name = "AbyssSplash"
		SplashGui.IgnoreGuiInset = true
		SplashGui.DisplayOrder = 1000
		SplashGui.Parent = CoreGui

		local bg = Instance.new("Frame")
		bg.Size = UDim2.fromScale(1, 1)
		bg.BackgroundColor3 = Color3.fromRGB(8, 10, 12)
		bg.BorderSizePixel = 0
		bg.BackgroundTransparency = 1
		bg.Parent = SplashGui

		local title = Instance.new("TextLabel")
		title.Size = UDim2.new(1, 0, 0, 80)
		title.Position = UDim2.new(0, 0, 0.38, 0)
		title.BackgroundTransparency = 1
		title.Text = "ABYSS"
		title.Font = Enum.Font.GothamBlack
		title.TextSize = 72
		title.TextColor3 = Color3.fromRGB(0, 230, 150)
		title.TextTransparency = 1
		title.Parent = bg

		local sub = Instance.new("TextLabel")
		sub.Size = UDim2.new(1, 0, 0, 28)
		sub.Position = UDim2.new(0, 0, 0.38, 80)
		sub.BackgroundTransparency = 1
		sub.Text = "Custom Panel  •  Loaded"
		sub.Font = Enum.Font.Gotham
		sub.TextSize = 18
		sub.TextColor3 = Color3.fromRGB(200, 220, 210)
		sub.TextTransparency = 1
		sub.Parent = bg

		local ti = TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		TweenService:Create(bg, ti, {BackgroundTransparency = 0}):Play()
		task.wait(0.1)
		TweenService:Create(title, ti, {TextTransparency = 0}):Play()
		task.wait(0.15)
		TweenService:Create(sub, ti, {TextTransparency = 0}):Play()
		task.wait(1.2)

		local out = TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		TweenService:Create(title, out, {TextTransparency = 1}):Play()
		TweenService:Create(sub, out, {TextTransparency = 1}):Play()
		TweenService:Create(bg, out, {BackgroundTransparency = 1}):Play()
		task.wait(0.45)
		SplashGui:Destroy()
	end

	-- ===== TÉMA ÉS UI ALAPOK =====
	local Theme = {
		Background = Color3.fromRGB(15, 17, 20),
		Main       = Color3.fromRGB(22, 25, 30),
		CardBg     = Color3.fromRGB(18, 20, 24),
		Accent     = Color3.fromRGB(0, 230, 150),
		Text       = Color3.fromRGB(240, 245, 250),
		DarkText   = Color3.fromRGB(140, 155, 165),
		ToggleOn   = Color3.fromRGB(0, 180, 100),
		ToggleOff  = Color3.fromRGB(40, 45, 50),
	}

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "AbyssCustomUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.DisplayOrder = 999
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.Parent = PlayerGui

	-- Lebegő ikon
	local IconBtn = Instance.new("TextButton")
	IconBtn.Name = "AbyssIcon"
	IconBtn.Size = UDim2.new(0, 45, 0, 45)
	IconBtn.Position = UDim2.new(0, 20, 0, 20)
	IconBtn.BackgroundColor3 = Theme.Main
	IconBtn.Text = "A"
	IconBtn.TextSize = 22
	IconBtn.Font = Enum.Font.GothamBold
	IconBtn.TextColor3 = Theme.Accent
	IconBtn.Parent = ScreenGui
	Instance.new("UICorner", IconBtn).CornerRadius = UDim.new(0, 10)

	local IconStroke = Instance.new("UIStroke")
	IconStroke.Color = Theme.Accent
	IconStroke.Thickness = 2
	IconStroke.Parent = IconBtn

	do
		local dragging, dragStart, startPos
		IconBtn.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = IconBtn.Position
			end
		end)
		IconBtn.InputEnded:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = false
			end
		end)
		AddConn(UserInputService.InputChanged:Connect(function(input)
			if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
				local delta = input.Position - dragStart
				IconBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			end
		end))
	end

	-- Fő Panel
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "Main"
	MainFrame.Size = UDim2.new(0, 700, 0, 500)
	MainFrame.Position = UDim2.new(0.5, -350, 0.5, -250)
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.BorderSizePixel = 0
	MainFrame.Visible = false
	MainFrame.Active = true
	MainFrame.Draggable = true
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui
	Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 12)

	local CustomBg = Instance.new("ImageLabel")
	CustomBg.Name = "CustomBackground"
	CustomBg.Size = UDim2.new(1, 0, 1, 0)
	CustomBg.BackgroundTransparency = 1
	CustomBg.Image = "rbxassetid://126868241449239"
	CustomBg.ImageTransparency = 0.65
	CustomBg.ScaleType = Enum.ScaleType.Crop
	CustomBg.Parent = MainFrame

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Color3.fromRGB(40, 50, 55)
	MainStroke.Thickness = 2
	MainStroke.Parent = MainFrame

	-- Fejléc
	local TopBar = Instance.new("Frame")
	TopBar.Size = UDim2.new(1, 0, 0, 45)
	TopBar.BackgroundColor3 = Theme.Main
	TopBar.BackgroundTransparency = 0.1
	TopBar.BorderSizePixel = 0
	TopBar.Parent = MainFrame
	Instance.new("UICorner", TopBar).CornerRadius = UDim.new(0, 12)

	local Title = Instance.new("TextLabel")
	Title.Size = UDim2.new(1, -140, 1, 0)
	Title.Position = UDim2.new(0, 16, 0, 0)
	Title.BackgroundTransparency = 1
	Title.Text = titleText
	Title.TextColor3 = Theme.Accent
	Title.TextSize = 16
	Title.Font = Enum.Font.GothamBold
	Title.TextXAlignment = Enum.TextXAlignment.Left
	Title.Parent = TopBar

	local KillBtn = Instance.new("TextButton")
	KillBtn.Size = UDim2.new(0, 60, 0, 28)
	KillBtn.Position = UDim2.new(1, -110, 0.5, -14)
	KillBtn.BackgroundColor3 = Color3.fromRGB(160, 40, 40)
	KillBtn.Text = "KILL"
	KillBtn.TextColor3 = Color3.new(1, 1, 1)
	KillBtn.TextSize = 12
	KillBtn.Font = Enum.Font.GothamBold
	KillBtn.Parent = TopBar
	Instance.new("UICorner", KillBtn).CornerRadius = UDim.new(0, 6)
	KillBtn.MouseButton1Click:Connect(KillEverything)

	local CloseBtn = Instance.new("TextButton")
	CloseBtn.Size = UDim2.new(0, 30, 0, 28)
	CloseBtn.Position = UDim2.new(1, -40, 0.5, -14)
	CloseBtn.BackgroundColor3 = Color3.fromRGB(45, 30, 30)
	CloseBtn.Text = "X"
	CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	CloseBtn.TextSize = 14
	CloseBtn.Font = Enum.Font.GothamBold
	CloseBtn.Parent = TopBar
	Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)
	CloseBtn.MouseButton1Click:Connect(function()
		MainFrame.Visible = false
	end)

	IconBtn.MouseButton1Click:Connect(function()
		MainFrame.Visible = not MainFrame.Visible
	end)

	-- Tab Bar
	local TabBar = Instance.new("ScrollingFrame")
	TabBar.Name = "TabBar"
	TabBar.Size = UDim2.new(0, 150, 1, -68)
	TabBar.Position = UDim2.new(0, 12, 0, 55)
	TabBar.BackgroundColor3 = Theme.Main
	TabBar.BackgroundTransparency = 0.2
	TabBar.BorderSizePixel = 0
	TabBar.ScrollBarThickness = 3
	TabBar.ScrollBarImageColor3 = Theme.Accent
	TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
	TabBar.AutomaticCanvasSize = Enum.AutomaticSize.Y
	TabBar.Parent = MainFrame
	Instance.new("UICorner", TabBar).CornerRadius = UDim.new(0, 10)

	local TabList = Instance.new("UIListLayout")
	TabList.Padding = UDim.new(0, 6)
	TabList.Parent = TabBar

	local ContentArea = Instance.new("Frame")
	ContentArea.Size = UDim2.new(1, -180, 1, -68)
	ContentArea.Position = UDim2.new(0, 168, 0, 55)
	ContentArea.BackgroundTransparency = 1
	ContentArea.Parent = MainFrame

	local FirstTab = true
	local CurrentTab = nil
	local WindowObj = {}

	function WindowObj:AddTab(name, icon)
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, -6, 0, 36)
		btn.Position = UDim2.new(0, 3, 0, 0)
		btn.BackgroundColor3 = Color3.fromRGB(25, 28, 32)
		btn.Text = "  " .. name
		btn.TextColor3 = Theme.Text
		btn.TextSize = 13
		btn.Font = Enum.Font.GothamMedium
		btn.TextXAlignment = Enum.TextXAlignment.Left
		btn.Parent = TabBar
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)

		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.ScrollBarThickness = 4
		page.ScrollBarImageColor3 = Theme.Accent
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		page.AutomaticCanvasSize = Enum.AutomaticSize.Y
		page.Visible = false
		page.Parent = ContentArea

		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.Parent = page

		local tabData = {Button = btn, Page = page, Name = name}

		btn.MouseButton1Click:Connect(function()
			if CurrentTab then
				CurrentTab.Page.Visible = false
				CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(25, 28, 32)
			end
			page.Visible = true
			btn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
			CurrentTab = tabData
		end)

		if FirstTab then
			FirstTab = false
			btn.BackgroundColor3 = Color3.fromRGB(0, 120, 80)
			page.Visible = true
			CurrentTab = tabData
		end

		local TabObj = {}

		function TabObj:AddSection(text)
			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(1, -8, 0, 24)
			label.BackgroundTransparency = 1
			label.Text = text
			label.TextColor3 = Theme.Accent
			label.TextSize = 13
			label.Font = Enum.Font.GothamBold
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = page
		end

		function TabObj:AddToggle(name, default, callback)
			local frame = Instance.new("Frame")
			frame.Size = UDim2.new(1, -8, 0, 42)
			frame.BackgroundColor3 = Theme.CardBg
			frame.BackgroundTransparency = 0.15
			frame.Parent = page
			Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(35, 40, 45)
			stroke.Thickness = 1
			stroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Size = UDim2.new(0.7, 0, 1, 0)
			label.Position = UDim2.new(0, 12, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = name
			label.TextColor3 = Theme.Text
			label.TextSize = 13
			label.Font = Enum.Font.GothamMedium
			label.TextXAlignment = Enum.TextXAlignment.Left
			label.Parent = frame

			local tBtn = Instance.new("TextButton")
			tBtn.Size = UDim2.new(0, 54, 0, 26)
			tBtn.Position = UDim2.new(1, -64, 0.5, -13)
			tBtn.BackgroundColor3 = default and Theme.ToggleOn or Theme.ToggleOff
			tBtn.Text = default and "ON" or "OFF"
			tBtn.TextColor3 = Color3.new(1, 1, 1)
			tBtn.TextSize = 11
			tBtn.Font = Enum.Font.GothamBold
			tBtn.Parent = frame
			Instance.new("UICorner", tBtn).CornerRadius = UDim.new(0, 6)

			local state = default
			tBtn.MouseButton1Click:Connect(function()
				state = not state
				tBtn.Text = state and "ON" or "OFF"
				tBtn.BackgroundColor3 = state and Theme.ToggleOn or Theme.ToggleOff
				if callback then callback(state) end
			end)
		end

		return TabObj
	end

	return WindowObj
end

return Library
