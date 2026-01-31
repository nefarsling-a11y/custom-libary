Вот полный исправленный код.

**Что было сделано:**
1.  **Серые элементы при открытии (Fix):** Обновил функцию `utility.new`. Теперь при создании *любого* элемента скрипт запоминает его прозрачность в атрибут `OriginalTransparency`. Благодаря этому, когда окно открывается заново, скрипт знает, какую именно прозрачность возвращать (0 или 1), а не делает всё сплошным серым.
2.  **Удален курсор:** Полностью вырезан код `Drawing.new` и отрисовка треугольника. Используется стандартный курсор мыши.
3.  **Тултип (Fix):**
    *   Переписана логика расчета размера. Теперь используется `TextService:GetTextSize`, что гарантирует правильный размер рамки даже если текст длинный.
    *   Текст больше не обрезается на 3 буквы при переоткрытии (так как расчет размера идет независимо от видимости UI).
    *   Текст корректно переносится (Wrap) и рамка растет в высоту.
4.  **Анимация:** Время открытия и закрытия изменено с `1` на `0.7` секунды.

```lua
--- START OF FILE Paste January 31, 2026 - 9:10PM ---

-- // variables
local library = {}
local pages = {}
local sections = {}
local multisections = {}
local mssections = {}
local toggles = {}
local buttons = {}
local sliders = {}
local dropdowns = {}
local multiboxs = {}
local buttonboxs = {}
local textboxs = {}
local keybinds = {}
local colorpickers = {}
local configloaders = {}
local watermarks = {}
local loaders = {}
local notifications = {}
local utility = {}
local check_exploit = (syn and "Synapse") or (KRNL_LOADED and "Krnl") or (isourclosure and "ScriptWare") or nil
local plrs = game:GetService("Players")
local cre = game:GetService("CoreGui")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
local hs = game:GetService("HttpService")
local ws = game:GetService("Workspace")
local textService = game:GetService("TextService") -- Добавлено для фикса тултипа
local plr = plrs.LocalPlayer
local cam = ws.CurrentCamera
-- // indexes
library.__index = library
pages.__index = pages
sections.__index = sections
multisections.__index = multisections
mssections.__index = mssections
toggles.__index = toggles
buttons.__index = buttons
sliders.__index = sliders
dropdowns.__index = dropdowns
multiboxs.__index = multiboxs
buttonboxs.__index = buttonboxs
textboxs.__index = textboxs
keybinds.__index = keybinds
colorpickers.__index = colorpickers
configloaders.__index = configloaders
watermarks.__index = watermarks
loaders.__index = loaders
-- // functions
utility.new = function(instance,properties)
	local ins = Instance.new(instance)
	for property,value in pairs(properties) do
		ins[property] = value
	end
	
	-- // FIX: Запоминаем прозрачность при создании объекта, чтобы при открытии меню она восстанавливалась правильно
	if ins:IsA("Frame") or ins:IsA("ScrollingFrame") or ins:IsA("ImageLabel") or ins:IsA("ImageButton") then
		ins:SetAttribute("OriginalTransparency", ins.BackgroundTransparency)
	end

	return ins
end
utility.dragify = function(ins,touse)
	local dragging
	local dragInput
	local dragStart
	local startPos
	--
	local function update(input)
		local delta = input.Position - dragStart
		touse:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
	end
	--
	ins.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = touse.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	--
	ins.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	--
	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end
utility.round = function(n,d)
	return tonumber(string.format("%."..(d or 0).."f",n))

end
utility.zigzag = function(X)
	return math.acos(math.cos(X*math.pi))/math.pi

end
utility.capatalize = function(s)
	local l = ""
	for v in s:gmatch('%u') do
		l = l..v
	end
	return l

end
utility.splitenum = function(enum)
	local s = tostring(enum):split(".")
	return s[#s]

end
utility.from_hex = function(h)
	local r,g,b = string.match(h,"^#?(%w%w)(%w%w)(%w%w)$")
	return Color3.fromRGB(tonumber(r,16), tonumber(g,16), tonumber(b,16))

end
utility.to_hex = function(c)
	return string.format("#%02X%02X%02X",c.R *255,c.G *255,c.B *255)

end
utility.removespaces = function(s)
	return s:gsub(" ","")
end
-- // main
function library:new(props)
	local textsize = props.textsize or props.TextSize or props.textSize or props.Textsize or 12
	local font = props.font or props.Font or "RobotoMono"
	local name = props.name or props.Name or props.UiName or props.Uiname or props.uiName or props.username or props.Username or props.UserName or props.userName or "new ui"
	local color = props.color or props.Color or props.mainColor or props.maincolor or props.MainColor or props.Maincolor or props.Accent or props.accent or Color3.fromRGB(225, 58, 81)
	local window = {}
	--
	local screen = utility.new(
		"ScreenGui",
		{
			Name = tostring(math.random(0,999999))..tostring(math.random(0,999999)),
			DisplayOrder = 9999,
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			IgnoreGuiInset = true,
			Parent = game:GetService("CoreGui")
		}
	)
	--
	if (check_exploit == "Synapse" and syn.request and syn.protect_gui) then
		syn.protect_gui(screen)
	end
	--
	-- // SHADOW FRAME (на весь экран)
	local shadow = utility.new(
		"Frame",
		{
			Name = "Shadow",
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 0,
			Parent = screen
		}
	)
	--
	local outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = color,
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(0,600,0,790),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 1,
			Parent = screen
		}
	)
	--
	local outline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = outline
		}
	)
	--
	local indent = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = outline2
		}
	)
	--
	local main = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-10,1,-25),
			Position = UDim2.new(0.5,0,1,-5),
			Parent = outline2
		}
	)
	--
	local title = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0.5,0,0,0),
			Parent = outline2
		}
	)
	--
	local outline3 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = main
		}
	)
	--
	local titletext = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = font,
			Text = name,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextXAlignment = "Left",
			TextSize = textsize,
			TextStrokeTransparency = 0,
			Parent = title
		}
	)
	--
	local holder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-6,1,-6),
			Position = UDim2.new(0.5,0,0.5,0),
			Parent = main
		}
	)
	--
	local tabs = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,-20),
			Position = UDim2.new(0.5,0,1,0),
			Parent = holder
		}
	)
	--
	local tabsbuttons = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,21),
			Position = UDim2.new(0.5,0,0,0),
			ZIndex = 2,
			Parent = holder
		}
	)
	--
	local outline4 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = tabs
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Horizontal",
			Padding = UDim.new(0,2),
			Parent = tabsbuttons
		}
	)
	--
	utility.dragify(title,outline)
	--
	-- // REMOVED CURSOR CODE (Requested by user)
	--
	-- // TOOLTIP
	local tooltipFrame = utility.new(
		"Frame",
		{
			Name = "Tooltip",
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 1,
			Size = UDim2.new(0, 150, 0, 30),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 99997,
			Visible = false,
			BackgroundTransparency = 1,
			Parent = screen
		}
	)
	--
	local tooltipAccent = utility.new(
		"Frame",
		{
			Name = "TooltipAccent",
			BackgroundColor3 = color,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = 99998,
			BackgroundTransparency = 1,
			Parent = tooltipFrame
		}
	)
	--
	local tooltipText = utility.new(
		"TextLabel",
		{
			Name = "TooltipText",
			BackgroundTransparency = 1,
			Size = UDim2.new(1, -10, 1, -6),
			Position = UDim2.new(0, 5, 0, 3),
			Font = font,
			Text = "",
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextSize = textsize,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextStrokeTransparency = 0,
			ZIndex = 99999,
			TextTransparency = 1,
			Parent = tooltipFrame
		}
	)
	--
	local tooltipMaxWidth = 200
	local currentTooltipTween = nil
	local tooltipVisible = false
	local tooltipHoverStart = 0
	local tooltipDelay = 0.5
	local tooltipCurrentElement = nil
	--
	-- // window tbl
	window = {
		["screen"] = screen,
		["holder"] = holder,
		["labels"] = {},
		["tabs"] = outline4,
		["tabsbuttons"] = tabsbuttons,
		["outline"] = outline,
		["shadow"] = shadow,
		["tooltipFrame"] = tooltipFrame,
		["tooltipText"] = tooltipText,
		["tooltipAccent"] = tooltipAccent,
		["tooltipMaxWidth"] = tooltipMaxWidth,
		["pages"] = {},
		["pointers"] = {},
		["dropdowns"] = {},
		["multiboxes"] = {},
		["buttonboxs"] = {},
		["colorpickers"] = {},
		["windowVisible"] = true,
		["x"] = true,
		["y"] = true,
		["key"] = Enum.KeyCode.RightShift,
		["textsize"] = textsize,
		["font"] = font,
		["theme"] = {
			["accent"] = color
		},
		["themeitems"] = {
			["accent"] = {
				["BackgroundColor3"] = {},
				["BorderColor3"] = {},
				["TextColor3"] = {},
				["ImageColor3"] = {}
			}
		}
	}
	--
	table.insert(window.themeitems["accent"]["BackgroundColor3"], outline)
	table.insert(window.themeitems["accent"]["BackgroundColor3"], tooltipAccent)
	--
	local toggled = true
	local cooldown = false
	local saved = outline.Position
	--
	-- // TOOLTIP FUNCTIONS (FIXED)
	local function showTooltip(text, element)
		tooltipCurrentElement = element
		tooltipHoverStart = tick()
		
		spawn(function()
			while tooltipCurrentElement == element do
				if tick() - tooltipHoverStart >= tooltipDelay then
					if tooltipCurrentElement == element then
						if currentTooltipTween then
							currentTooltipTween:Cancel()
						end
						
						tooltipText.Text = text or "N/A"
						
						-- FIX: Правильный расчет размера тултипа
						local params = Instance.new("GetTextBoundsParams")
						params.Text = text or "N/A"
						params.Font = Font.fromEnum(Enum.Font[font] or Enum.Font.RobotoMono)
						params.Size = textsize
						params.Width = tooltipMaxWidth - 10 -- Учитываем отступы
						
						local bounds
						pcall(function()
							bounds = textService:GetTextSize(text or "N/A", textsize, Enum.Font[font] or Enum.Font.RobotoMono, Vector2.new(tooltipMaxWidth - 10, 1000))
						end)
						
						if not bounds then bounds = Vector2.new(100, 20) end

						local width = math.min(tooltipMaxWidth, bounds.X + 16)
						local height = bounds.Y + 10
						
						tooltipFrame.Size = UDim2.new(0, width, 0, height)
						tooltipFrame.BackgroundTransparency = 1
						tooltipText.TextTransparency = 1
						tooltipAccent.BackgroundTransparency = 1
						tooltipFrame.Visible = true
						tooltipVisible = true
						
						-- Позиционирование рядом с мышкой
						local mouse = uis:GetMouseLocation()
						tooltipFrame.Position = UDim2.new(0, mouse.X + 15, 0, mouse.Y - 5)

						currentTooltipTween = ts:Create(tooltipFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0})
						currentTooltipTween:Play()
						ts:Create(tooltipText, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0}):Play()
						ts:Create(tooltipAccent, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0}):Play()
					end
					break
				end
				task.wait(0.05)
			end
		end)
	end
	--
	local function hideTooltip()
		tooltipCurrentElement = nil
		tooltipHoverStart = 0
		if currentTooltipTween then
			currentTooltipTween:Cancel()
		end
		tooltipFrame.Visible = false
		tooltipFrame.BackgroundTransparency = 1
		tooltipText.TextTransparency = 1
		tooltipAccent.BackgroundTransparency = 1
		tooltipVisible = false
	end
	--
	window.showTooltip = showTooltip
	window.hideTooltip = hideTooltip
	--
	-- // UPDATE LOOP FOR TOOLTIP POS (Cursor lines removed)
	rs.RenderStepped:Connect(function()
		if window.windowVisible and screen.Enabled then
			if tooltipVisible then
				local mousePos = uis:GetMouseLocation()
				tooltipFrame.Position = UDim2.new(0, mousePos.X + 15, 0, mousePos.Y)
				tooltipAccent.BackgroundColor3 = window.theme.accent
			end
		end
	end)
	--
	-- // INPUT TOGGLE WINDOW
	uis.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.Keyboard then
			if Input.KeyCode == window.key then
				if cooldown == false then
					if toggled then
						-- ЗАКРЫТИЕ (Tween 0.7s)
						cooldown = true
						toggled = false
						window.windowVisible = false
						saved = outline.Position
						
						hideTooltip()
						
						local targetPos = UDim2.new(saved.X.Scale, saved.X.Offset, saved.Y.Scale, saved.Y.Offset + 50)
						
						ts:Create(outline, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Position = targetPos, BackgroundTransparency = 1}):Play()
						ts:Create(shadow, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
						
						for _, desc in ipairs(outline:GetDescendants()) do
							if desc:IsA("Frame") then
								ts:Create(desc, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1}):Play()
							elseif desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
								ts:Create(desc, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {TextTransparency = 1, TextStrokeTransparency = 1}):Play()
							elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
								ts:Create(desc, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {ImageTransparency = 1}):Play()
							elseif desc:IsA("ScrollingFrame") then
								ts:Create(desc, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {BackgroundTransparency = 1, ScrollBarImageTransparency = 1}):Play()
							end
						end
						
						wait(0.7)
						screen.Enabled = false
						cooldown = false
					else
						-- ОТКРЫТИЕ (Tween 0.7s)
						cooldown = true
						toggled = true
						screen.Enabled = true
						
						local startPos = UDim2.new(saved.X.Scale, saved.X.Offset, saved.Y.Scale, saved.Y.Offset + 50)
						outline.Position = startPos
						outline.BackgroundTransparency = 1
						
						-- Подготовка к анимации (делаем все невидимым, чтобы не мигало)
						for _, desc in ipairs(outline:GetDescendants()) do
							if desc:IsA("Frame") then
								desc.BackgroundTransparency = 1
							elseif desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
								desc.TextTransparency = 1
								desc.TextStrokeTransparency = 1
							elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
								desc.ImageTransparency = 1
							elseif desc:IsA("ScrollingFrame") then
								desc.BackgroundTransparency = 1
								desc.ScrollBarImageTransparency = 1
							end
						end
						
						ts:Create(outline, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Position = saved, BackgroundTransparency = 0}):Play()
						ts:Create(shadow, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()
						
						for _, desc in ipairs(outline:GetDescendants()) do
							if desc:IsA("Frame") then
								-- FIX: Используем OriginalTransparency, установленный в utility.new
								local origTrans = desc:GetAttribute("OriginalTransparency") or 0
								ts:Create(desc, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = origTrans}):Play()
							elseif desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
								ts:Create(desc, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {TextTransparency = 0, TextStrokeTransparency = 0}):Play()
							elseif desc:IsA("ImageLabel") or desc:IsA("ImageButton") then
								ts:Create(desc, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {ImageTransparency = 0}):Play()
							elseif desc:IsA("ScrollingFrame") then
								local origTrans = desc:GetAttribute("OriginalTransparency") or 0
								ts:Create(desc, TweenInfo.new(0.7, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = origTrans, ScrollBarImageTransparency = 0.25}):Play()
							end
						end
						
						window.windowVisible = true
						wait(0.7)
						cooldown = false
					end
				end
			end
		end
	end)
	--
	-- Начальная анимация shadow
	ts:Create(shadow, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {BackgroundTransparency = 0.5}):Play()
	--
	window.labels[#window.labels+1] = titletext
	--
	setmetatable(window, library)
	return window
end

-- // УВЕДОМЛЕНИЯ
function library:Notification(props)
	local title_text = props.title or props.Title or "Notification"
	local desc_text = props.content or props.Content or props.description or props.Description or ""
	local duration = props.duration or props.time or props.Time or 5

	local offset = 0
	for i, v in pairs(notifications) do
		if v.main then offset = offset + (v.main.AbsoluteSize.Y + 6) end
	end

	local notifOutline = utility.new("Frame", {
		Name = "Notification", Parent = self.screen, BackgroundColor3 = self.theme.accent,
		BorderSizePixel = 0, Position = UDim2.new(1, 10, 1, -20 - offset),
		Size = UDim2.new(0, 250, 0, 0), AnchorPoint = Vector2.new(1, 1), ZIndex = 9999
	})
	table.insert(self.themeitems["accent"]["BackgroundColor3"], notifOutline)
	local notifHolder = utility.new("Frame", {
		Parent = notifOutline, BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderSizePixel = 0,
		Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2), ZIndex = 9999
	})

	local titleLabel = utility.new("TextLabel", {
		Parent = notifHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5),
		Size = UDim2.new(1, -20, 0, 20), Font = self.font, Text = title_text,
		TextColor3 = self.theme.accent, TextSize = self.textsize + 2, TextXAlignment = "Left", ZIndex = 9999
	})
	table.insert(self.themeitems["accent"]["TextColor3"], titleLabel)

	local descLabel = utility.new("TextLabel", {
		Parent = notifHolder, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 25),
		Size = UDim2.new(1, -20, 0, 0), Font = self.font, Text = desc_text,
		TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = self.textsize,
		TextWrapped = true, TextXAlignment = "Left", TextYAlignment = "Top", ZIndex = 9999
	})

	descLabel.Size = UDim2.new(1, -20, 0, 1000)
	local bounds = descLabel.TextBounds.Y
	descLabel.Size = UDim2.new(1, -20, 0, bounds)
	notifOutline.Size = UDim2.new(0, 250, 0, 35 + bounds + 5)

	notifOutline:TweenPosition(UDim2.new(1, -10, 1, -20 - offset), "Out", "Quad", 0.5, true)

	local notif_data = {main = notifOutline}
	table.insert(notifications, notif_data)

	spawn(function()
		wait(duration)
		notifOutline:TweenPosition(UDim2.new(1, 300, 1, -20 - offset), "In", "Quad", 0.5, true)
		wait(0.5)
		for i,v in pairs(notifications) do if v == notif_data then table.remove(notifications, i) end end
		notifOutline:Destroy()
	end)
end

function library:watermark()
	local watermark = {}
	--
	local wmOutline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = self.theme.accent,
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(0,300,0,26),
			Position = UDim2.new(1,-10,0,10),
			ZIndex = 9900,
			Visible = false,
			Parent = self.screen
		}
	)
	--
	table.insert(self.themeitems["accent"]["BackgroundColor3"],wmOutline)
	--
	local wmOutline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9901,
			Parent = wmOutline
		}
	)
	--
	local wmIndent = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9902,
			Parent = wmOutline2
		}
	)
	--
	local wmTitle = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.font,
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextXAlignment = "Left",
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			ZIndex = 9903,
			Parent = wmIndent
		}
	)
	--
	local con
	con = wmTitle:GetPropertyChangedSignal("TextBounds"):Connect(function()
		wmOutline.Size = UDim2.new(0,wmTitle.TextBounds.X+20,0,26)
	end)
	--
	watermark = {
		["outline"] = wmOutline,
		["outline2"] = wmOutline2,
		["indent"] = wmIndent,
		["title"] = wmTitle,
		["connection"] = con
	}
	--
	self.labels[#self.labels+1] = wmTitle
	--
	setmetatable(watermark,watermarks)
	return watermark

end
function watermarks:update(content)
	local content = content or {}
	local watermark = self
	--
	local text = ""
	--
	for i,v in pairs(content) do
		text = text..i..": "..v.." "
	end
	--
	text = text:sub(0, -3)
	--
	watermark.title.Text = text

end
function watermarks:updateside(side)
	side = utility.removespaces(tostring(side):lower())
	--
	local sides = {
		topright = {
			AnchorPoint = Vector2.new(1,0),
			Position = UDim2.new(1,-10,0,10)
		},
		topleft = {
			AnchorPoint = Vector2.new(0,0),
			Position = UDim2.new(0,10,0,10)
		},
		bottomright = {
			AnchorPoint = Vector2.new(1,1),
			Position = UDim2.new(1,-10,1,-10)
		},
		bottomleft = {
			AnchorPoint = Vector2.new(0,1),
			Position = UDim2.new(0,10,1,-10)
		}
	}
	--
	if sides[side] then
		self.outline.AnchorPoint = sides[side].AnchorPoint
		self.outline.Position = sides[side].Position
	end

end
function library:loader(props)
	local loaderName = props.name or props.Name or props.LoaderName or props.Loadername or props.loaderName or props.loadername or "Loader"
	local scriptname = props.scriptname or props.Scriptname or props.ScriptName or props.scriptName or "Universal"
	local closed = props.close or props.Close or props.closecallback or props.Closecallback or props.CloseCallback or props.closeCallback or function()end
	local logedin = props.login or props.Login or props.logincallback or props.Logincallback or props.LoginCallback or props.loginCallback or function()end
	local loader = {}
	--
	local loaderScreen = utility.new(
		"ScreenGui",
		{
			Name = tostring(math.random(0,999999))..tostring(math.random(0,999999)),
			DisplayOrder = 9999,
			ResetOnSpawn = false,
			ZIndexBehavior = "Global",
			Parent = cre
		}
	)
	if (check_exploit == "Synapse" and syn.request) then
		syn.protect_gui(loaderScreen)
	end
	--
	local loaderOutline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(168, 52, 235),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(0,300,0,90),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9900,
			Visible = false,
			Parent = loaderScreen
		}
	)
	--
	local loaderOutline2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(0, 0, 0),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderSizePixel = 1,
			Size = UDim2.new(1,-4,1,-4),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9901,
			Parent = loaderOutline
		}
	)
	--
	local loaderIndent = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0.5,0,0.5,0),
			ZIndex = 9902,
			Parent = loaderOutline2
		}
	)
	--
	local loaderTitle = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,0),
			Font = "RobotoMono",
			Text = loaderName,
			TextColor3 = Color3.fromRGB(168, 52, 235),
			TextXAlignment = "Center",
			TextSize = 12,
			TextStrokeTransparency = 0,
			ZIndex = 9903,
			Parent = loaderIndent
		}
	)
	--
	local scripttitle = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,20),
			Font = "RobotoMono",
			Text = "Script: "..scriptname,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextXAlignment = "Center",
			TextSize = 12,
			TextStrokeTransparency = 0,
			ZIndex = 9903,
			Parent = loaderIndent
		}
	)
	--
	local makebutton = function(bname,parent)
		local button_holder = utility.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				ZIndex = 9904,
				Parent = parent
			}
		)
		--
		local button_outline = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 9905,
				Parent = button_holder
			}
		)
		--
		local button_outline2 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 9906,
				Parent = button_outline
			}
		)
		--
		local button_color = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,0),
				ZIndex = 9907,
				Parent = button_outline2
			}
		)
		--
		utility.new(
			"UIGradient",
			{
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
				Rotation = 90,
				Parent = button_color
			}
		)
		--
		local button_button = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0,0,0,0),
				Text = bname,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = 12,
				TextStrokeTransparency = 0,
				Font = "RobotoMono",
				ZIndex = 9908,
				Parent = button_holder
			}
		)
		--
		return {button_holder,button_outline,button_button}
	end
	--
	local closeBtn = makebutton("close",loaderIndent)
	local loginBtn = makebutton("login",loaderIndent)
	--
	closeBtn[1].AnchorPoint = Vector2.new(0.5,0)
	closeBtn[1].Size = UDim2.new(0.5,0,0,20)
	closeBtn[1].Position = UDim2.new(0.5,0,0,40)
	--
	loginBtn[1].AnchorPoint = Vector2.new(0.5,0)
	loginBtn[1].Size = UDim2.new(0.5,0,0,20)
	loginBtn[1].Position = UDim2.new(0.5,0,0,62)
	--
	closeBtn[3].MouseButton1Down:Connect(function()
		closeBtn[2].BorderColor3 = Color3.fromRGB(168, 52, 235)
		loaderOutline:TweenPosition(UDim2.new(-1.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.75,true)
		closed()
		wait(0.05)
		closeBtn[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait(0.7)
		loaderScreen:Remove()
	end)
	--
	loginBtn[3].MouseButton1Down:Connect(function()
		loginBtn[2].BorderColor3 = Color3.fromRGB(168, 52, 235)
		loaderOutline:TweenPosition(UDim2.new(1.5,0,0.5,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.75,true)
		logedin()
		wait(0.05)
		loginBtn[2].BorderColor3 = Color3.fromRGB(12,12,12)
		wait(0.7)
		loaderScreen:Remove()
	end)
	--
	loader = {
		["outline"] = loaderOutline,
		["outline2"] = loaderOutline2,
		["indent"] = loaderIndent,
		["title"] = loaderTitle
	}
	--
	setmetatable(loader,loaders)
	return loader

end
function loaders:toggle()
	self.outline.Visible = true

end
function watermarks:toggle(bool)
	local watermark = self
	watermark.outline.Visible = bool

end
function library:saveconfig(folder_name, config_name)
	if not isfolder(folder_name) then makefolder(folder_name) end

	local cfg = {}
	for cfgName, element in pairs(self.pointers) do
		if element.current ~= nil then
			if typeof(element.current) == "Color3" then
				cfg[cfgName] = {element.current.R, element.current.G, element.current.B, "Color3"}
			else
				cfg[cfgName] = element.current
			end
		end
	end

	local success, err = pcall(function()
		writefile(folder_name.."/"..config_name..".cfg", hs:JSONEncode(cfg))
	end)

	if success then 
		self:Notification({Title="Config Saved", Description="Saved: "..config_name, Time=3}) 
	else 
		self:Notification({Title="Error", Description="Save failed: "..tostring(err)}) 
	end
end

function library:loadconfig(folder_name, config_name)
	local path = folder_name.."/"..config_name..".cfg"
	if not isfile(path) then
		self:Notification({Title="Error", Description="Config not found!"})
		return
	end

	local success, err = pcall(function()
		local cfg = hs:JSONDecode(readfile(path))
		for cfgName, value in pairs(cfg) do
			if self.pointers[cfgName] then
				local element = self.pointers[cfgName]
				if typeof(value) == "table" and value[4] == "Color3" then
					element:set(Color3.new(value[1], value[2], value[3]))
				else
					element:set(value)
				end
			end
		end
	end)

	if success then 
		self:Notification({Title="Config Loaded", Description="Loaded: "..config_name, Time=3}) 
	else 
		self:Notification({Title="Error", Description="Load failed: "..tostring(err)}) 
	end
end
function library:settheme(theme,themeColor)
	local window = self
	if window.theme[theme] then
		window.theme[theme] = themeColor
	end
	if window.themeitems[theme] then
		for i,v in pairs(window.themeitems[theme]) do
			for z,x in pairs(v) do
				x[i] = themeColor
			end
		end
	end

end
function library:setkey(key)
	if typeof(key) == "EnumItem" then
		local window = self
		window.key = key
	end

end
function library:settoggle(side,bool)
	if side == "x" then
		self.x = bool
	else
		self.y = bool
	end

end
function library:setfont(newFont)
	if newFont ~= nil then
		local window = self
		for i,v in pairs(window.labels) do
			if v ~= nil then
				v.Font = newFont
			end
		end
	end

end
function library:settextsize(size)
	if size ~= nil then
		local window = self
		for i,v in pairs(window.labels) do
			if v ~= nil then
				v.TextSize = size
			end
		end
	end

end
function library:page(props)
	local pageName = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local page = {}
	--
	local tabbutton = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,75,1,0),
			Parent = self.tabsbuttons
		}
	)
	--
	local pageOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = tabbutton
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = tabbutton
		}
	)
	--
	local r_line = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 0,
			Size = UDim2.new(0,1,0,1),
			Position = UDim2.new(1,0,1,1),
			ZIndex = 2,
			Parent = pageOutline
		}
	)
	--
	local l_line = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 0,
			Size = UDim2.new(0,1,0,1),
			Position = UDim2.new(0,0,1,1),
			ZIndex = 2,
			Parent = pageOutline
		}
	)
	--
	local line = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,0,2),
			Position = UDim2.new(0,0,1,0),
			ZIndex = 2,
			Parent = pageOutline
		}
	)
	--
	local label = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,0),
			Font = self.font,
			Text = pageName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.textsize,
			TextStrokeTransparency = 0,
			Parent = pageOutline
		}
	)
	--
	local pageholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,-20),
			Position = UDim2.new(0.5,0,0.5,0),
			Visible = false,
			Parent = self.tabs
		}
	)
	--
	local left = utility.new(
		"ScrollingFrame",
		{
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0.5,-5,1,0),
			Position = UDim2.new(0,0,0,0),
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 1,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 0,
			ClipsDescendants = false,
			VerticalScrollBarInset = "None",
			VerticalScrollBarPosition = "Right",
			Parent = pageholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,10),
			Parent = left
		}
	)
	--
	local right = utility.new(
		"ScrollingFrame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0.5,-5,1,0),
			Position = UDim2.new(1,0,0,0),
			AutomaticCanvasSize = "Y",
			CanvasSize = UDim2.new(0,0,0,0),
			ScrollBarImageTransparency = 1,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 0,
			ClipsDescendants = false,
			VerticalScrollBarInset = "None",
			VerticalScrollBarPosition = "Right",
			Parent = pageholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,10),
			Parent = right
		}
	)
	--
	page = {
		["library"] = self,
		["outline"] = pageOutline,
		["r_line"] = r_line,
		["l_line"] = l_line,
		["line"] = line,
		["page"] = pageholder,
		["left"] = left,
		["right"] = right,
		["open"] = false,
		["pointers"] = {}
	}
	--
	table.insert(self.pages,page)
	--
	button.MouseButton1Down:Connect(function()
		if page.open == false then
			for i,v in pairs(self.pages) do
				if v ~= page then
					if v.open then
						v.page.Visible = false
						v.open = false
						v.outline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
						v.line.Size = UDim2.new(1,0,0,2)
						v.line.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
					end
				end
			end
			self:closewindows()
			page.page.Visible = true
			page.open = true
			page.outline.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			page.line.Size = UDim2.new(1,0,0,3)
			page.line.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		self.pointers[tostring(pointer)] = page.pointers
	end
	--
	self.labels[#self.labels+1] = label
	setmetatable(page, pages)
	return page

end
function pages:openpage()
	local page = self
	if page.open == false then
		for i,v in pairs(page.library.pages) do
			if v ~= page then
				if v.open then
					v.page.Visible = false
					v.open = false
					v.outline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
					v.line.Size = UDim2.new(1,0,0,2)
					v.line.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
				end
			end
		end
		page.page.Visible = true
		page.open = true
		page.outline.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		page.line.Size = UDim2.new(1,0,0,3)
		page.line.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	end

end
function pages:section(props)
	local sectionName = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local side = props.side or props.Side or props.sectionside or props.Sectionside or props.SectionSide or props.sectionSide or "left"
	local size = props.size or props.Size or props.yaxis or props.yAxis or props.YAxis or props.Yaxis or 200
	side = side:lower()
	local section = {}
	--
	local sectionholder = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,size),
			Parent = self[side]
		}
	)
	--
	local sectionOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = sectionholder
		}
	)
	--
	local sectionColor = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-2,0,1),
			Position = UDim2.new(0.5,0,0,0),
			Parent = sectionOutline
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],sectionColor)
	--
	local content = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-12,1,-25),
			Position = UDim2.new(0.5,0,1,-5),
			Parent = sectionOutline
		}
	)
	--
	local sectionTitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-5,0,20),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = sectionName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = sectionOutline
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,5),
			Parent = content
		}
	)
	--
	section = {
		["library"] = self.library,
		["sectionholder"] = sectionholder,
		["color"] = sectionColor,
		["content"] = content,
		["pointers"] = {}
	}
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		if self.pointers then
			self.library.pointers[tostring(pointer)] = section.pointers
		end
	end
	--
	self.library.labels[#self.library.labels+1] = sectionTitle
	setmetatable(section, sections)
	return section

end
function pages:multisection(props)
	local msName = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local side = props.side or props.Side or props.sectionside or props.Sectionside or props.SectionSide or props.sectionSide or "left"
	local size = props.size or props.Size or props.yaxis or props.yAxis or props.YAxis or props.Yaxis or 200
	side = side:lower()
	local multisection = {}
	--
	local sectionholder = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,size),
			Parent = self[side]
		}
	)
	--
	local msOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = sectionholder
		}
	)
	--
	local msColor = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-2,0,1),
			Position = UDim2.new(0.5,0,0,0),
			Parent = msOutline
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],msColor)
	--
	local tabsholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,-15),
			Position = UDim2.new(0,0,1,0),
			Parent = msOutline
		}
	)
	--
	local msTitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-5,0,20),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = msName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = msOutline
		}
	)
	--
	local msButtons = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-6,0,20),
			Position = UDim2.new(0.5,0,0,5),
			Parent = tabsholder
		}
	)
	--
	local msTabs = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,-6,1,-27),
			Position = UDim2.new(0.5,0,1,-3),
			Parent = tabsholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Horizontal",
			Padding = UDim.new(0,2),
			Parent = msButtons
		}
	)
	--
	local tabs_outline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = msTabs
		}
	)
	--
	multisection = {
		["library"] = self.library,
		["sectionholder"] = sectionholder,
		["color"] = msColor,
		["tabsholder"] = tabsholder,
		["mssections"] = {},
		["buttons"] = msButtons,
		["tabs"] = msTabs,
		["tabs_outline"] = tabs_outline,
		["pointers"] = {}
	}
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		if self.pointers then
			self.library.pointers[tostring(pointer)] = multisection.pointers
		end
	end
	--
	self.library.labels[#self.library.labels+1] = msTitle
	setmetatable(multisection,multisections)
	return multisection

end
function multisections:section(props)
	local mssName = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local mssection = {}
	--
	local tabbutton = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,60,0,20),
			Parent = self.buttons
		}
	)
	--
	local mssOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = tabbutton
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = tabbutton
		}
	)
	--
	local r_line = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 0,
			Size = UDim2.new(0,1,0,1),
			Position = UDim2.new(1,0,1,1),
			ZIndex = 2,
			Parent = mssOutline
		}
	)
	--
	local l_line = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderSizePixel = 0,
			Size = UDim2.new(0,1,0,1),
			Position = UDim2.new(0,0,1,1),
			ZIndex = 2,
			Parent = mssOutline
		}
	)
	--
	local line = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(20, 20, 20),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,0,2),
			Position = UDim2.new(0,0,1,0),
			ZIndex = 2,
			Parent = mssOutline
		}
	)
	--
	local label = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = mssName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Parent = mssOutline
		}
	)
	--
	local content = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,1),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-6,1,-27),
			Position = UDim2.new(0.5,0,1,-3),
			Visible = false,
			Parent = self.tabs_outline
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Padding = UDim.new(0,5),
			Parent = content
		}
	)
	--
	mssection = {
		["library"] = self.library,
		["outline"] = mssOutline,
		["r_line"] = r_line,
		["l_line"] = l_line,
		["line"] = line,
		["content"] = content,
		["open"] = false,
		["pointers"] = {}
	}
	--
	table.insert(self.mssections,mssection)
	--
	button.MouseButton1Down:Connect(function()
		if mssection.open == false then
			for i,v in pairs(self.mssections) do
				if v ~= mssection then
					if v.open then
						v.content.Visible = false
						v.open = false
						v.outline.BackgroundColor3 = Color3.fromRGB(31, 31 ,31)
						v.line.Size = UDim2.new(1,0,0,2)
						v.line.BackgroundColor3 = Color3.fromRGB(31, 31 ,31)
					end
				end
			end
			mssection.library:closewindows()
			mssection.content.Visible = true
			mssection.open = true
			mssection.outline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
			mssection.line.Size = UDim2.new(1,0,0,3)
			mssection.line.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		if self.pointers then
			self.library.pointers[tostring(pointer)] = mssection.pointers
		end
	end
	--
	self.library.labels[#self.library.labels+1] = label
	setmetatable(mssection,mssections)
	return mssection

end
function sections:toggle(props)
	local toggleName = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or props.toggle or props.Toggle or props.toggled or props.Toggled or false
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local tooltipstr = props.tooltip or props.Tooltip or "N/A"
	local toggle = {}
	--
	local toggleholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Parent = self.content
		}
	)
	--
	local toggleOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,15,0,15),
			Parent = toggleholder
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = toggleholder
		}
	)
	--
	local toggleTitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,0),
			Position = UDim2.new(0,20,0,0),
			Font = self.library.font,
			Text = toggleName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = toggleholder
		}
	)
	--
	local col = Color3.fromRGB(20, 20, 20)
	if def then
		col = self.library.theme.accent
	end
	--
	local toggleColor = utility.new(
		"Frame",
		{
			BackgroundColor3 = col,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = toggleOutline
		}
	)
	if def then
		table.insert(self.library.themeitems["accent"]["BackgroundColor3"],toggleColor)
	end
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = toggleColor
		}
	)
	--
	toggle = {
		["library"] = self.library,
		["toggleholder"] = toggleholder,
		["title"] = toggleTitle,
		["color"] = toggleColor,
		["callback"] = callback,
		["current"] = def,
		["tooltip"] = tooltipstr
	}
	--
	button.MouseButton1Down:Connect(function()
		if toggle.current then
			toggle.callback(false)
			toggle.color.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			local find = table.find(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
			if find then
				table.remove(self.library.themeitems["accent"]["BackgroundColor3"],find)
			end
			toggle.current = false
		else
			toggle.callback(true)
			toggle.color.BackgroundColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
			toggle.current = true
		end
	end)
	--
	button.MouseEnter:Connect(function()
		self.library.showTooltip(toggle.tooltip, button)
	end)
	button.MouseLeave:Connect(function()
		self.library.hideTooltip()
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		if self.pointers then
			self.library.pointers[tostring(pointer)] = toggle
		end
	end
	--
	self.library.labels[#self.library.labels+1] = toggleTitle
	setmetatable(toggle, toggles)
	return toggle

end
function toggles:set(bool)
	if bool ~= nil then
		local toggle = self
		toggle.callback(bool)
		toggle.current = bool
		if bool then
			toggle.color.BackgroundColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
		else
			toggle.color.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			local find = table.find(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
			if find then
				table.remove(self.library.themeitems["accent"]["BackgroundColor3"],find)
			end
		end
	end

end
function sections:button(props)
	local buttonName = props.name or props.Name or "new button"
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local tooltipstr = props.tooltip or props.Tooltip or "N/A"
	local buttonTbl = {}
	--
	local buttonholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,20),
			Parent = self.content
		}
	)
	--
	local buttonOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = buttonholder
		}
	)
	--
	local buttonOutline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = buttonOutline
		}
	)
	--
	local buttonColor = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = buttonOutline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = buttonColor
		}
	)
	--
	local buttonpress = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = buttonName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = buttonholder
		}
	)
	--
	buttonpress.MouseButton1Down:Connect(function()
		callback()
		buttonOutline.BorderColor3 = self.library.theme.accent
		table.insert(self.library.themeitems["accent"]["BorderColor3"],buttonOutline)
		wait(0.05)
		buttonOutline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],buttonOutline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
	end)
	--
	buttonpress.MouseEnter:Connect(function()
		self.library.showTooltip(tooltipstr, buttonpress)
	end)
	buttonpress.MouseLeave:Connect(function()
		self.library.hideTooltip()
	end)
	--
	buttonTbl = {
		["library"] = self.library,
		["tooltip"] = tooltipstr
	}
	--
	self.library.labels[#self.library.labels+1] = buttonpress
	setmetatable(buttonTbl, buttons)
	return buttonTbl

end
function sections:slider(props)
	local sliderName = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or 0
	local max = props.max or props.Max or props.maximum or props.Maximum or 100
	local min = props.min or props.Min or props.minimum or props.Minimum or 0
	local rounding = props.rounding or props.Rounding or props.round or props.Round or props.decimals or props.Decimals or false
	local ticking = props.tick or props.Tick or props.ticking or props.Ticking or false
	local measurement = props.measurement or props.Measurement or props.digit or props.Digit or props.calc or props.Calc or ""
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local tooltipstr = props.tooltip or props.Tooltip or "N/A"
	def = math.clamp(def,min,max)
	local slider = {}
	--
	local sliderholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,25),
			Parent = self.content
		}
	)
	--
	local sliderOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,12),
			Position = UDim2.new(0,0,0,15),
			Parent = sliderholder
		}
	)
	--
	local sliderOutline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = sliderOutline
		}
	)
	--
	local sliderValue = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,2),
			Position = UDim2.new(0,0,0.5,0),
			Font = self.library.font,
			Text = def..measurement.."/"..max..measurement,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			ZIndex = 3,
			Parent = sliderOutline
		}
	)
	--
	local sliderColorFrame = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = sliderOutline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = sliderColorFrame
		}
	)
	--
	local slide = utility.new(
		"Frame",
		{
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new((1 / sliderColorFrame.AbsoluteSize.X) * (sliderColorFrame.AbsoluteSize.X / (max - min) * (def - min)),0,1,0),
			ZIndex = 2,
			Parent = sliderOutline
		}
	)
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],slide)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = slide
		}
	)
	--
	local sliderbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = sliderholder
		}
	)
	--
	local sliderTitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = sliderName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = sliderholder
		}
	)
	--
	slider = {
		["library"] = self.library,
		["outline"] = sliderOutline,
		["sliderbutton"] = sliderbutton,
		["title"] = sliderTitle,
		["value"] = sliderValue,
		["slide"] = slide,
		["color"] = sliderColorFrame,
		["max"] = max,
		["min"] = min,
		["current"] = def,
		["measurement"] = measurement,
		["tick"] = ticking,
		["rounding"] = rounding,
		["callback"] = callback,
		["tooltip"] = tooltipstr
	}
	--
	local function doslide()
		local size = math.clamp(plr:GetMouse().X - slider.color.AbsolutePosition.X ,0 ,slider.color.AbsoluteSize.X)
		local result = (slider.max - slider.min) / slider.color.AbsoluteSize.X * size + slider.min
		if slider.rounding then
			local newres = math.floor(result)
			sliderValue.Text = newres..slider.measurement.."/"..slider.max..slider.measurement
			slider.current = newres
			slider.callback(newres)
			if slider.tick then
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * (slider.color.AbsoluteSize.X / (slider.max - slider.min) * (newres - slider.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			else
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			end
		else
			local newres = utility.round(result ,2)
			sliderValue.Text = newres..slider.measurement.."/"..slider.max..slider.measurement
			slider.current = newres
			slider.callback(newres)
			if slider.tick then
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * (slider.color.AbsoluteSize.X / (slider.max - slider.min) * (newres - slider.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			else
				slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
			end
		end
	end
	--
	sliderbutton.MouseButton1Down:Connect(function()
		slider.holding = true
		doslide()
		table.insert(self.library.themeitems["accent"]["BorderColor3"],sliderOutline)
		sliderOutline.BorderColor3 = self.library.theme.accent
	end)
	--
	sliderbutton.MouseEnter:Connect(function()
		self.library.showTooltip(slider.tooltip, sliderbutton)
	end)
	sliderbutton.MouseLeave:Connect(function()
		self.library.hideTooltip()
	end)
	--
	uis.InputChanged:Connect(function()
		if slider.holding then
			doslide()
		end
	end)
	--
	uis.InputEnded:Connect(function(Input)
		if Input.UserInputType.Name == 'MouseButton1' and slider.holding then
			slider.holding = false
			sliderOutline.BorderColor3 = Color3.fromRGB(12, 12, 12)
			local find = table.find(self.library.themeitems["accent"]["BorderColor3"],sliderOutline)
			if find then
				table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
			end
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		if self.pointers then
			self.library.pointers[tostring(pointer)] = slider
		end
	end
	--
	self.library.labels[#self.library.labels+1] = sliderTitle
	self.library.labels[#self.library.labels+1] = sliderValue
	setmetatable(slider, sliders)
	return slider

end
function sliders:set(val)
	local size = math.clamp((self.color.AbsoluteSize.X / (self.max - self.min) * (val - self.min)) ,0 ,self.color.AbsoluteSize.X)
	local result = val
	if self.rounding then
		local newres = math.floor(result)
		self.value.Text = newres..self.measurement.."/"..self.max..self.measurement
		self.current = newres
		self.callback(newres)
		if self.tick then
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * (self.color.AbsoluteSize.X / (self.max - self.min) * (newres - self.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		else
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		end
	else
		local newres = utility.round(result ,2)
		self.value.Text = newres..self.measurement.."/"..self.max..self.measurement
		self.current = newres
		self.callback(newres)
		if self.tick then
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * (self.color.AbsoluteSize.X / (self.max - self.min) * (newres - self.min)) ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		else
			self.slide:TweenSize(UDim2.new((1 / self.color.AbsoluteSize.X) * size ,0 ,1 ,0) ,Enum.EasingDirection.Out ,Enum.EasingStyle.Quad ,0.15 ,true)
		end
	end

end
function library:closewindows(ignore)
	local window = self
	for i,v in pairs(window.dropdowns) do
		if v ~= ignore then
			if v.open then
				v.optionsholder.Visible = false
				v.indicator.Text = "+"
				v.open = false
			end
		end
	end
	for i,v in pairs(window.multiboxes) do
		if v ~= ignore then
			if v.open then
				v.optionsholder.Visible = false
				v.indicator.Text = "+"
				v.open = false
			end
		end
	end
	for i,v in pairs(window.buttonboxs) do
		if v ~= ignore then
			if v.open then
				v.optionsholder.Visible = false
				v.indicator.Text = "+"
				v.open = false
			end
		end
	end
	for i,v in pairs(window.colorpickers) do
		if v ~= ignore then
			if v.open then
				v.cpholder.Visible = false
				v.open = false
			end
		end
	end

end
function sections:dropdown(props)
	local ddName = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or ""
	local max = props.max or props.Max or props.maximum or props.Maximum or 4
	local options = props.options or props.Options or props.Settings or props.settings or {}
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local tooltipstr = props.tooltip or props.Tooltip or "N/A"
	local dropdown = {}
	--
	local dropdownholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local ddOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = dropdownholder
		}
	)
	--
	local ddOutline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = ddOutline
		}
	)
	--
	local ddColor = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = ddOutline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = ddColor
		}
	)
	--
	local ddValue = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,0),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = def,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ClipsDescendants = true,
			Parent = ddOutline
		}
	)
	--
	local indicator = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = "+",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Right",
			ClipsDescendants = true,
			Parent = ddOutline
		}
	)
	--
	local ddTitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = ddName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = dropdownholder
		}
	)
	--
	local dropdownbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = dropdownholder
		}
	)
	--
	local optionsholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,34),
			Visible = false,
			Parent = dropdownholder
		}
	)
	--
	local ddSize = #options
	ddSize = math.clamp(ddSize,1,max)
	--
	local optionsoutline = utility.new(
		"ScrollingFrame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,ddSize,2),
			Position = UDim2.new(0,0,0,0),
			ClipsDescendants = true,
			CanvasSize = UDim2.new(0,0,0,18*#options),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			ZIndex = 5,
			Parent = optionsholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Parent = optionsoutline
		}
	)
	--
	dropdown = {
		["library"] = self.library,
		["optionsholder"] = optionsholder,
		["indicator"] = indicator,
		["options"] = options,
		["title"] = ddTitle,
		["value"] = ddValue,
		["open"] = false,
		["titles"] = {},
		["current"] = def,
		["callback"] = callback,
		["tooltip"] = tooltipstr
	}
	--
	table.insert(dropdown.library.dropdowns,dropdown)
	--
	for i,v in pairs(options) do
		local ddoptionbutton = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Text = "",
				ZIndex = 6,
				Parent = optionsoutline
			}
		)
		--
		local ddoptiontitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Font = self.library.font,
				Text = v,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				ClipsDescendants = true,
				ZIndex = 6,
				Parent = ddoptionbutton
			}
		)
		--
		self.library.labels[#self.library.labels+1] = ddoptiontitle
		table.insert(dropdown.titles,ddoptiontitle)
		--
		if v == dropdown.current then ddoptiontitle.TextColor3 = self.library.theme.accent end
		--
		ddoptionbutton.MouseButton1Down:Connect(function()
			optionsholder.Visible = false
			dropdown.open = false
			indicator.Text = "+"
			for z,x in pairs(dropdown.titles) do
				if x.TextColor3 == self.library.theme.accent then
					x.TextColor3 = Color3.fromRGB(255,255,255)
				end
			end
			dropdown.current = v
			dropdown.value.Text = v
			ddoptiontitle.TextColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["TextColor3"],ddoptiontitle)
			dropdown.callback(v)
		end)
	end
	--
	dropdownbutton.MouseButton1Down:Connect(function()
		dropdown.library:closewindows(dropdown)
		for i,v in pairs(dropdown.titles) do
			if v.Text == dropdown.current then
				v.TextColor3 = dropdown.library.theme.accent
			else
				v.TextColor3 = Color3.fromRGB(255,255,255)
			end
		end
		optionsholder.Visible = not dropdown.open
		dropdown.open = not dropdown.open
		if dropdown.open then
			indicator.Text = "-"
		else
			indicator.Text = "+"
		end
	end)
	--
	dropdownbutton.MouseEnter:Connect(function()
		self.library.showTooltip(dropdown.tooltip, dropdownbutton)
	end)
	dropdownbutton.MouseLeave:Connect(function()
		self.library.hideTooltip()
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		if self.pointers then
			self.library.pointers[tostring(pointer)] = dropdown
		end
	end
	--
	self.library.labels[#self.library.labels+1] = ddTitle
	self.library.labels[#self.library.labels+1] = ddValue
	setmetatable(dropdown, dropdowns)
	return dropdown

end
function dropdowns:set(val)
	if val ~= nil then
		local dropdown = self
		if table.find(dropdown.options,val) then
			self.current = tostring(val)
			self.value.Text = tostring(val)
			self.callback(tostring(val))
			for z,x in pairs(dropdown.titles) do
				if x.Text == val then
					x.TextColor3 = dropdown.library.theme.accent
				else
					x.TextColor3 = Color3.fromRGB(255,255,255)
				end
			end
		end
	end

end
function sections:multibox(props)
	local mbName = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or {}
	local max = props.max or props.Max or props.maximum or props.Maximum or 4
	local options = props.options or props.Options or props.Settings or props.settings or {}
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local tooltipstr = props.tooltip or props.Tooltip or "N/A"
	local defstr = ""
	if #def > 1 then
		for i,v in pairs(def) do
			if i == #def then
				defstr = defstr..v
			else
				defstr = defstr..v..", "
			end
		end
	else
		for i,v in pairs(def) do
			defstr = defstr..v
		end
	end
	local multibox = {}
	--
	local multiboxholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local mbOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = multiboxholder
		}
	)
	--
	local mbOutline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = mbOutline
		}
	)
	--
	local mbColor = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = mbOutline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = mbColor
		}
	)
	--
	local mbValue = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-20,1,0),
			Position = UDim2.new(0,5,0,0),
			Font = self.library.font,
			Text = defstr,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ClipsDescendants = true,
			Parent = mbOutline
		}
	)
	--
	local indicator = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = "+",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Right",
			ClipsDescendants = true,
			Parent = mbOutline
		}
	)
	--
	local mbTitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = mbName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = multiboxholder
		}
	)
	--
	local dropdownbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = multiboxholder
		}
	)
	--
	local optionsholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,34),
			Visible = false,
			Parent = multiboxholder
		}
	)
	--
	local mbSize = #options
	mbSize = math.clamp(mbSize,1,max)
	--
	local optionsoutline = utility.new(
		"ScrollingFrame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,mbSize,2),
			Position = UDim2.new(0,0,0,0),
			ClipsDescendants = true,
			CanvasSize = UDim2.new(0,0,0,18*#options),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			ZIndex = 5,
			Parent = optionsholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Parent = optionsoutline
		}
	)
	--
	multibox = {
		["library"] = self.library,
		["indicator"] = indicator,
		["optionsholder"] = optionsholder,
		["options"] = options,
		["value"] = mbValue,
		["open"] = false,
		["titles"] = {},
		["current"] = def,
		["callback"] = callback,
		["tooltip"] = tooltipstr
	}
	--
	table.insert(multibox.library.multiboxes,multibox)
	--
	for i,v in pairs(options) do
		local mboptionbutton = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Text = "",
				ZIndex = 6,
				Parent = optionsoutline
			}
		)
		--
		local mboptiontitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Font = self.library.font,
				Text = v,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				ClipsDescendants = true,
				ZIndex = 6,
				Parent = mboptionbutton
			}
		)
		--
		self.library.labels[#self.library.labels+1] = mboptiontitle
		table.insert(multibox.titles,mboptiontitle)
		--
		for c,b in pairs(def) do if v == b then mboptiontitle.TextColor3 = self.library.theme.accent end end
		--
		mboptionbutton.MouseButton1Down:Connect(function()
			local find = table.find(multibox.current,v)
			if find == nil then
				table.insert(multibox.current,v)
				local str = ""
				if #multibox.current > 1 then
					for ii,vv in pairs(multibox.current) do
						if ii == #multibox.current then
							str = str..vv
						else
							str = str..vv..", "
						end
					end
				else
					for ii,vv in pairs(multibox.current) do
						str = str..vv
					end
				end
				mbValue.Text = str
				mboptiontitle.TextColor3 = self.library.theme.accent
				table.insert(self.library.themeitems["accent"]["TextColor3"],mboptiontitle)
				multibox.callback(multibox.current)
			else
				table.remove(multibox.current,find)
				local str = ""
				if #multibox.current > 1 then
					for ii,vv in pairs(multibox.current) do
						if ii == #multibox.current then
							str = str..vv
						else
							str = str..vv..", "
						end
					end
				else
					for ii,vv in pairs(multibox.current) do
						str = str..vv
					end
				end
				mbValue.Text = str
				mboptiontitle.TextColor3 = Color3.fromRGB(255,255,255)
				multibox.callback(multibox.current)
			end
		end)
	end
	--
	dropdownbutton.MouseButton1Down:Connect(function()
		multibox.library:closewindows(multibox)
		for i,v in pairs(multibox.titles) do
			if v.TextColor3 ~= Color3.fromRGB(255,255,255) then
				v.TextColor3 = self.library.theme.accent
			end
		end
		optionsholder.Visible = not multibox.open
		multibox.open = not multibox.open
		if multibox.open then
			indicator.Text = "-"
		else
			indicator.Text = "+"
		end
	end)
	--
	dropdownbutton.MouseEnter:Connect(function()
		self.library.showTooltip(multibox.tooltip, dropdownbutton)
	end)
	dropdownbutton.MouseLeave:Connect(function()
		self.library.hideTooltip()
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		if self.pointers then
			self.library.pointers[tostring(pointer)] = multibox
		end
	end
	--
	self.library.labels[#self.library.labels+1] = mbValue
	self.library.labels[#self.library.labels+1] = mbTitle
	setmetatable(multibox, multiboxs)
	return multibox

end
function multiboxs:set(tbl)
	if tbl then
		local multibox = self
		if typeof(tbl) == "table" then
			multibox.current = {}
			for i,v in pairs(tbl) do
				if table.find(multibox.options,v) then
					table.insert(multibox.current,v)
				end
			end
			for i,v in pairs(multibox.titles) do
				if v.TextColor3 == multibox.library.theme.accent then
					v.TextColor3 = Color3.fromRGB(255,255,255)
				end
				if table.find(tbl,v.Text) then
					v.TextColor3 = multibox.library.theme.accent
				end
			end
			local str = ""
			if #multibox.current > 1 then
				for i,v in pairs(multibox.current) do
					if i == #multibox.current then
						str = str..v
					else
						str = str..v..", "
					end
				end
			else
				for i,v in pairs(multibox.current) do
					str = str..v
				end
			end
			multibox.value.Text = str
		end
	end

end
function sections:textbox(props)
	local tbName = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or ""
	local placeholder = props.placeholder or props.Placeholder or props.placeHolder or props.PlaceHolder or props.placeholdertext or props.PlaceHolderText or props.PlaceHoldertext or props.placeHolderText or props.placeHoldertext or props.Placeholdertext or props.PlaceholderText or props.placeholderText or ""
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local tooltipstr = props.tooltip or props.Tooltip or "N/A"
	local textbox = {}
	--
	local textboxholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local tbOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = textboxholder
		}
	)
	--
	local tbOutline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = tbOutline
		}
	)
	--
	local tbColor = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = tbOutline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = tbColor
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = textboxholder
		}
	)
	--
	local tbTitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = tbName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = textboxholder
		}
	)
	--
	local tbox = utility.new(
		"TextBox",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,15),
			PlaceholderText = placeholder,
			Text = def,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextTruncate = "AtEnd",
			Font = self.library.font,
			Parent = textboxholder
		}
	)
	--
	textbox = {
		["library"] = self.library,
		["tbox"] = tbox,
		["current"] = def,
		["callback"] = callback,
		["tooltip"] = tooltipstr
	}
	--
	button.MouseButton1Down:Connect(function()
		tbox:CaptureFocus()
	end)
	--
	button.MouseEnter:Connect(function()
		self.library.showTooltip(textbox.tooltip, button)
	end)
	button.MouseLeave:Connect(function()
		self.library.hideTooltip()
	end)
	--
	tbox.Focused:Connect(function()
		tbOutline.BorderColor3 = self.library.theme.accent
		table.insert(self.library.themeitems["accent"]["BorderColor3"],tbOutline)
	end)
	--
	tbox.FocusLost:Connect(function(enterPressed)
		textbox.current = tbox.Text
		callback(tbox.Text)
		tbOutline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],tbOutline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		if self.pointers then
			self.library.pointers[tostring(pointer)] = textbox
		end
	end
	--
	self.library.labels[#self.library.labels+1] = tbTitle
	self.library.labels[#self.library.labels+1] = tbox
	setmetatable(textbox, textboxs)
	return textbox
end
--
function textboxs:set(val)
	self.tbox.Text = val
	self.current = val
	self.callback(val)
end
--
function sections:keybind(props)
	local kbName = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or nil
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local allowed = props.allowed or props.Allowed or 1
	local tooltipstr = props.tooltip or props.Tooltip or "N/A"
	--
	local default = ".."
	local typeis = nil
	--
	if typeof(def) == "EnumItem" then
		if def == Enum.UserInputType.MouseButton1 then
			if allowed == 1 then
				default = "MB1"
				typeis = "UserInputType"
			end
		elseif def == Enum.UserInputType.MouseButton2 then
			if allowed == 1 then
				default = "MB2"
				typeis = "UserInputType"
			end
		elseif def == Enum.UserInputType.MouseButton3 then
			if allowed == 1 then
				default = "MB3"
				typeis = "UserInputType"
			end
		else
			local capd = utility.capatalize(def.Name)
			if #capd > 1 then
				default = capd
			else
				default = def.Name
			end
			typeis = "KeyCode"
		end
	end
	local keybind = {}
	--
	local keybindholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,17),
			Parent = self.content
		}
	)
	--
	local kbOutline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,40,1,0),
			Position = UDim2.new(1,0,0,0),
			Parent = keybindholder
		}
	)
	--
	local kbOutline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = kbOutline
		}
	)
	--
	local kbValue = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = default,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Center",
			Parent = kbOutline
		}
	)
	--
	kbOutline.Size = UDim2.new(0,kbValue.TextBounds.X+20,1,0)
	--
	local kbColor = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = kbOutline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = kbColor
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = keybindholder
		}
	)
	--
	local kbTitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = kbName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = keybindholder
		}
	)
	--
	keybind = {
		["library"] = self.library,
		["down"] = false,
		["outline"] = kbOutline,
		["value"] = kbValue,
		["allowed"] = allowed,
		["current"] = {typeis,utility.splitenum(def)},
		["pressed"] = false,
		["callback"] = callback,
		["tooltip"] = tooltipstr
	}
	--
	button.MouseButton1Down:Connect(function()
		if keybind.down == false then
			kbOutline.BorderColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["BorderColor3"],kbOutline)
			wait()
			keybind.down = true
		end
	end)
	--
	button.MouseButton2Down:Connect(function()
		keybind.down = false
		keybind.current = {nil,nil}
		kbOutline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],kbOutline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
		kbValue.Text = ".."
		kbOutline.Size = UDim2.new(0,kbValue.TextBounds.X+20,1,0)
	end)
	--
	button.MouseEnter:Connect(function()
		self.library.showTooltip(keybind.tooltip, button)
	end)
	button.MouseLeave:Connect(function()
		self.library.hideTooltip()
	end)
	--
	local function turn(typeis2,current)
		kbOutline.Size = UDim2.new(0,kbValue.TextBounds.X+20,1,0)
		keybind.down = false
		keybind.current = {typeis2,utility.splitenum(current)}
		kbOutline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],kbOutline)
		if find then
			table.remove(self.library.themeitems["accent"]["BorderColor3"],find)
		end
	end
	--
	uis.InputBegan:Connect(function(Input)
		if keybind.down then
			if Input.UserInputType == Enum.UserInputType.Keyboard then
				local capd = utility.capatalize(Input.KeyCode.Name)
				if #capd > 1 then
					kbValue.Text = capd
				else
					kbValue.Text = Input.KeyCode.Name
				end
				turn("KeyCode",Input.KeyCode)
				callback(Input.KeyCode)
			end
			if allowed == 1 then
				if Input.UserInputType == Enum.UserInputType.MouseButton1 then
					kbValue.Text = "MB1"
					turn("UserInputType",Input)
					callback(Input)
				elseif Input.UserInputType == Enum.UserInputType.MouseButton2 then
					kbValue.Text = "MB2"
					turn("UserInputType",Input)
					callback(Input)
				elseif Input.UserInputType == Enum.UserInputType.MouseButton3 then
					kbValue.Text = "MB3"
					turn("UserInputType",Input)
					callback(Input)
				end
			end
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		if self.pointers then
			self.library.pointers[tostring(pointer)] = keybind
		end
	end
	--
	self.library.labels[#self.library.labels+1] = kbTitle
	self.library.labels[#self.library.labels+1] = kbValue
	setmetatable(keybind, keybinds)
	return keybind
end
--
function keybinds:set(key)
	if key then
		if typeof(key) == "table" then
			if key[1] and key[2] then
				local s, e = pcall(function()
					key = Enum[key[1]][key[2]]
				end)
				if not s then return end
			else
				return
			end
		end

		if typeof(key) == "EnumItem" then
			local keybind = self
			local typeis = ""
			local default = ".."

			if key == Enum.UserInputType.MouseButton1 then
				if keybind.allowed == 1 then
					default = "MB1"
					typeis = "UserInputType"
				end
			elseif key == Enum.UserInputType.MouseButton2 then
				if keybind.allowed == 1 then
					default = "MB2"
					typeis = "UserInputType"
				end
			elseif key == Enum.UserInputType.MouseButton3 then
				if keybind.allowed == 1 then
					default = "MB3"
					typeis = "UserInputType"
				end
			else
				local capd = utility.capatalize(key.Name)
				if #capd > 1 then
					default = capd
				else
					default = key.Name
				end
				typeis = "KeyCode"
			end

			keybind.value.Text = default
			keybind.outline.Size = UDim2.new(0, keybind.value.TextBounds.X+20, 1, 0)
			keybind.current = {typeis, utility.splitenum(key)}
			keybind.callback(key)

			if keybind.down then
				keybind.down = false
				keybind.outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
				local find = table.find(self.library.themeitems["accent"]["BorderColor3"], keybind.outline)
				if find then
					table.remove(self.library.themeitems["accent"]["BorderColor3"], find)
				end
			end
		end
	end
end
--
function sections:colorpicker(props)
	local cpName = props.name or props.Name or "new colorpicker"
	local cpname2 = props.cpname or props.Cpname or props.CPname or props.CPName or props.cPname or props.cpName or props.colorpickername or nil
	local def = props.def or props.Def or props.default or props.Default or Color3.fromRGB(255,255,255)
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local tooltipstr = props.tooltip or props.Tooltip or "N/A"
	--
	local h,s,v = def:ToHSV()
	local colorpicker = {}
	--
	local colorpickerholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local cpOutline = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,30,1,0),
			Position = UDim2.new(1,0,0,0),
			Parent = colorpickerholder
		}
	)
	--
	local cpOutline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Parent = cpOutline
		}
	)
	--
	local cpcolor = utility.new(
		"Frame",
		{
			BackgroundColor3 = def,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Parent = cpOutline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = cpcolor
		}
	)
	--
	local cpTitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = cpName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = colorpickerholder
		}
	)
	--
	local button = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			Parent = colorpickerholder
		}
	)
	--
	local cpholder = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,230),
			Position = UDim2.new(0,0,1,5),
			Visible = false,
			ZIndex = 5,
			Parent = colorpickerholder
		}
	)
	--
	local cpholderOutline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Parent = cpholder
		}
	)
	--
	local cpAccentLine = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundColor3 = self.library.theme.accent,
			BorderSizePixel = 0,
			Size = UDim2.new(1,-2,0,1),
			Position = UDim2.new(0.5,0,0,0),
			ZIndex = 5,
			Parent = cpholderOutline2
		}
	)
	--
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],cpAccentLine)
	--
	local cpholderTitle = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,0,20),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = cpname2 or cpName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			ZIndex = 5,
			Parent = cpholderOutline2
		}
	)
	--
	local cpholder2 = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0.875,0,0,150),
			Position = UDim2.new(0,5,0,20),
			ZIndex = 5,
			Parent = cpholderOutline2
		}
	)
	--
	local cpPickerOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromHSV(h,1,1),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Parent = cpholder2
		}
	)
	--
	local cpimage = utility.new(
		"ImageButton",
		{
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Image = "rbxassetid://7074305282",
			Parent = cpPickerOutline
		}
	)
	--
	local cpcursor = utility.new(
		"ImageLabel",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0,6,0,6),
			Position = UDim2.new(s,0,1-v,0),
			ZIndex = 5,
			Image = "rbxassetid://7074391319",
			Parent = cpimage
		}
	)
	--
	local huepicker = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(1,0),
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0.05,0,0,150),
			Position = UDim2.new(1,-5,0,20),
			ZIndex = 5,
			Parent = cpholderOutline2
		}
	)
	--
	local hueOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			ZIndex = 5,
			Parent = huepicker
		}
	)
	--
	local huebutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			Font = self.library.font,
			ZIndex = 5,
			Parent = huepicker
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 4)), ColorSequenceKeypoint.new(0.10, Color3.fromRGB(255, 153, 0)), ColorSequenceKeypoint.new(0.20, Color3.fromRGB(209, 255, 0)), ColorSequenceKeypoint.new(0.30, Color3.fromRGB(55, 255, 0)), ColorSequenceKeypoint.new(0.40, Color3.fromRGB(0, 255, 102)), ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)), ColorSequenceKeypoint.new(0.60, Color3.fromRGB(0, 102, 255)), ColorSequenceKeypoint.new(0.70, Color3.fromRGB(51, 0, 255)), ColorSequenceKeypoint.new(0.80, Color3.fromRGB(204, 0, 255)), ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 0, 153)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 4))},
			Rotation = 90,
			Parent = hueOutline
		}
	)
	--
	local huecursor = utility.new(
		"Frame",
		{
			AnchorPoint = Vector2.new(0.5,0.5),
			BackgroundColor3 = Color3.fromRGB(255, 255, 255),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(0,12,0,6),
			Position = UDim2.new(0.5,0,h,0),
			ZIndex = 5,
			Parent = hueOutline
		}
	)
	--
	local huecursor_inline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromHSV(h,1,1),
			BorderColor3 = Color3.fromRGB(255, 255, 255),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			ZIndex = 5,
			Parent = huecursor
		}
	)
	--
	local function maketextbox(parent,tbsize,tbposition)
		local textbox_holder = utility.new(
			"Frame",
			{
				BackgroundTransparency = 1,
				BorderSizePixel = 0,
				Position = tbposition,
				Size = tbsize,
				ZIndex = 5,
				Parent = parent
			}
		)
		--
		local tbOutline5 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(12, 12, 12),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		local tbOutline6 = utility.new(
			"Frame",
			{
				BackgroundColor3 = Color3.fromRGB(24, 24, 24),
				BorderColor3 = Color3.fromRGB(56, 56, 56),
				BorderMode = "Inset",
				BorderSizePixel = 1,
				Position = UDim2.new(0,0,0,0),
				Size = UDim2.new(1,0,1,0),
				ZIndex = 5,
				Parent = tbOutline5
			}
		)
		--
		local tbColor2 = utility.new(
			"Frame",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundColor3 = Color3.fromRGB(30, 30, 30),
				BorderSizePixel = 0,
				Size = UDim2.new(1,0,0,0),
				Position = UDim2.new(0,0,0,0),
				ZIndex = 5,
				Parent = tbOutline6
			}
		)
		--
		utility.new(
			"UIGradient",
			{
				Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
				Rotation = 90,
				Parent = tbColor2
			}
		)
		--
		local tbox2 = utility.new(
			"TextBox",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0.5,0,0,0),
				PlaceholderColor3 = Color3.fromRGB(255,255,255),
				PlaceholderText = "",
				Text = "",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		local tbox_button = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,1,0),
				Position = UDim2.new(0,0,0,0),
				Text = "",
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				Font = self.library.font,
				ZIndex = 5,
				Parent = textbox_holder
			}
		)
		--
		tbox_button.MouseButton1Down:Connect(function()
			tbox2:CaptureFocus()
		end)
		--
		return {textbox_holder,tbox2,tbOutline5}
	end
	--
	local red = maketextbox(cpholderOutline2,UDim2.new(0,62,0,20),UDim2.new(0,5,0,175))
	local green = maketextbox(cpholderOutline2,UDim2.new(0,62,0,20),UDim2.new(0,5,0,175))
	green[1].AnchorPoint = Vector2.new(0.5,0)
	green[1].Position = UDim2.new(0.5,0,0,175)
	local blue = maketextbox(cpholderOutline2,UDim2.new(0,62,0,20),UDim2.new(0,5,0,175))
	blue[1].AnchorPoint = Vector2.new(1,0)
	blue[1].Position = UDim2.new(1,-5,0,175)
	local hex = maketextbox(cpholderOutline2,UDim2.new(1,-10,0,20),UDim2.new(0,5,0,200))
	hex[2].Size = UDim2.new(1,-12,1,0)
	hex[2].TextXAlignment = "Left"
	--
	colorpicker = {
		["library"] = self.library,
		["cpholder"] = cpholder,
		["cpcolor"] = cpcolor,
		["huecursor"] = huecursor,
		["outline3"] = cpPickerOutline,
		["huecursor_inline"] = huecursor_inline,
		["cpcursor"] = cpcursor,
		["current"] = def,
		["open"] = false,
		["cp"] = false,
		["hue"] = false,
		["hsv"] = {h,s,v},
		["red"] = red[2],
		["green"] = green[2],
		["blue"] = blue[2],
		["hex"] = hex[2],
		["callback"] = callback,
		["tooltip"] = tooltipstr
	}
	--
	table.insert(self.library.colorpickers,colorpicker)
	--
	local function updateboxes()
		colorpicker.red.PlaceholderText = "R: "..tostring(math.floor(colorpicker.current.R*255))
		colorpicker.green.PlaceholderText = "G: "..tostring(math.floor(colorpicker.current.G*255))
		colorpicker.blue.PlaceholderText = "B: "..tostring(math.floor(colorpicker.current.B*255))
		colorpicker.hex.PlaceholderText = "Hex: "..utility.to_hex(colorpicker.current)
	end
	--
	updateboxes()
	--
	local function movehue()
		local posy = math.clamp(plr:GetMouse().Y-cpPickerOutline.AbsolutePosition.Y,0,cpPickerOutline.AbsoluteSize.Y)
		local resy = (1/cpPickerOutline.AbsoluteSize.Y)*posy
		cpPickerOutline.BackgroundColor3 = Color3.fromHSV(resy,1,1)
		huecursor_inline.BackgroundColor3 = Color3.fromHSV(resy,1,1)
		colorpicker.hsv[1] = resy
		colorpicker.current = Color3.fromHSV(colorpicker.hsv[1],colorpicker.hsv[2],colorpicker.hsv[3])
		cpcolor.BackgroundColor3 = colorpicker.current
		updateboxes()
		colorpicker.callback(colorpicker.current)
		huecursor:TweenPosition(UDim2.new(0.5,0,resy,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
	end
	--
	local function movecp()
		local posx,posy = math.clamp(plr:GetMouse().X-cpPickerOutline.AbsolutePosition.X,0,cpPickerOutline.AbsoluteSize.X),math.clamp(plr:GetMouse().Y-cpPickerOutline.AbsolutePosition.Y,0,cpPickerOutline.AbsoluteSize.Y)
		local resx,resy = (1/cpPickerOutline.AbsoluteSize.X)*posx,(1/cpPickerOutline.AbsoluteSize.Y)*posy
		colorpicker.hsv[2] = resx
		colorpicker.hsv[3] = 1-resy
		colorpicker.current = Color3.fromHSV(colorpicker.hsv[1],colorpicker.hsv[2],colorpicker.hsv[3])
		cpcolor.BackgroundColor3 = colorpicker.current
		updateboxes()
		colorpicker.callback(colorpicker.current)
		cpcursor:TweenPosition(UDim2.new(resx,0,resy,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
	end
	--
	button.MouseButton1Down:Connect(function()
		self.library:closewindows(colorpicker)
		cpholder.Visible = not colorpicker.open
		colorpicker.open = not colorpicker.open
	end)
	--
	button.MouseEnter:Connect(function()
		self.library.showTooltip(colorpicker.tooltip, button)
	end)
	button.MouseLeave:Connect(function()
		self.library.hideTooltip()
	end)
	--
	huebutton.MouseButton1Down:Connect(function()
		colorpicker.hue = true
		movehue()
	end)
	--
	cpimage.MouseButton1Down:Connect(function()
		colorpicker.cp = true
		movecp()
	end)
	--
	uis.InputChanged:Connect(function()
		if colorpicker.cp then
			movecp()
		end
		if colorpicker.hue then
			movehue()
		end
	end)
	--
	uis.InputEnded:Connect(function(Input)
		if Input.UserInputType.Name == 'MouseButton1'  then
			if colorpicker.cp then
				colorpicker.cp = false
			end
			if colorpicker.hue then
				colorpicker.hue = false
			end
		end
	end)
	--
	red[2].Focused:Connect(function()
		red[3].BorderColor3 = self.library.theme.accent
	end)
	--
	red[2].FocusLost:Connect(function()
		local saved = red[2].Text
		local num = tonumber(saved)
		if num then
			saved = tostring(math.clamp(tonumber(saved),0,255))
			red[2].Text = ""
			if saved then
				if #saved >= 1 and #saved <= 3 then
					red[2].PlaceholderText = "R: "..tostring(saved)
				end
				colorpicker:set(Color3.fromRGB(tonumber(saved),colorpicker.current.G*255,colorpicker.current.B*255))
				red[3].BorderColor3 = Color3.fromRGB(12,12,12)
			else
				red[3].BorderColor3 = Color3.fromRGB(12,12,12)
			end
		else
			red[2].Text = ""
			red[3].BorderColor3 = Color3.fromRGB(12,12,12)
		end
	end)
	--
	green[2].Focused:Connect(function()
		green[3].BorderColor3 = self.library.theme.accent
	end)
	--
	green[2].FocusLost:Connect(function()
		local saved = green[2].Text
		local num = tonumber(saved)
		if num then
			saved = tostring(math.clamp(tonumber(saved),0,255))
			green[2].Text = ""
			if saved then
				if #saved >= 1 and #saved <= 3 then
					green[2].PlaceholderText = "G: "..tostring(saved)
				end
				colorpicker:set(Color3.fromRGB(colorpicker.current.R*255,tonumber(saved),colorpicker.current.B*255))
				green[3].BorderColor3 = Color3.fromRGB(12,12,12)
			else
				green[3].BorderColor3 = Color3.fromRGB(12,12,12)
			end
		else
			green[2].Text = ""
			green[3].BorderColor3 = Color3.fromRGB(12,12,12)
		end
	end)
	--
	blue[2].Focused:Connect(function()
		blue[3].BorderColor3 = self.library.theme.accent
	end)
	--
	blue[2].FocusLost:Connect(function()
		local saved = blue[2].Text
		local num = tonumber(saved)
		if num then
			saved = tostring(math.clamp(tonumber(saved),0,255))
			blue[2].Text = ""
			if saved then
				if #saved >= 1 and #saved <= 3 then
					blue[2].PlaceholderText = "B: "..tostring(saved)
				end
				colorpicker:set(Color3.fromRGB(colorpicker.current.R*255,colorpicker.current.G*255,tonumber(saved)))
				blue[3].BorderColor3 = Color3.fromRGB(12,12,12)
			else
				blue[3].BorderColor3 = Color3.fromRGB(12,12,12)
			end
		else
			blue[2].Text = ""
			blue[3].BorderColor3 = Color3.fromRGB(12,12,12)
		end
	end)
	--
	hex[2].Focused:Connect(function()
		hex[3].BorderColor3 = self.library.theme.accent
	end)
	--
	hex[2].FocusLost:Connect(function()
		local saved = hex[2].Text
		if #saved >= 6 and #saved <= 7 then
			local e,s2 = pcall(function()
				utility.from_hex(saved)
			end)
			if e == true then
				local hexcolor = utility.from_hex(saved)
				if hexcolor then
					colorpicker:set(hexcolor)
					hex[2].Text = ""
					hex[3].BorderColor3 = Color3.fromRGB(12,12,12)
				else
					hex[2].Text = ""
					hex[3].BorderColor3 = Color3.fromRGB(12,12,12)
				end
			else
				hex[2].Text = ""
				hex[3].BorderColor3 = Color3.fromRGB(12,12,12)
			end
		else
			hex[2].Text = ""
			hex[3].BorderColor3 = Color3.fromRGB(12,12,12)
		end
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		if self.pointers then
			self.library.pointers[tostring(pointer)] = colorpicker
		end
	end
	--
	self.library.labels[#self.library.labels+1] = cpTitle
	self.library.labels[#self.library.labels+1] = hex[2]
	self.library.labels[#self.library.labels+1] = red[2]
	self.library.labels[#self.library.labels+1] = green[2]
	self.library.labels[#self.library.labels+1] = blue[2]
	self.library.labels[#self.library.labels+1] = cpholderTitle
	setmetatable(colorpicker, colorpickers)
	return colorpicker
end
--
function colorpickers:set(newColor)
	if newColor then
		if typeof(newColor) == "table" then
			newColor = Color3.fromRGB(newColor[1]*255,newColor[2]*255,newColor[3]*255)
		end
		local colorpicker = self
		local h,s,v = newColor:ToHSV()
		--
		local function updateboxes()
			colorpicker.red.PlaceholderText = "R: "..tostring(math.floor(colorpicker.current.R*255))
			colorpicker.green.PlaceholderText = "G: "..tostring(math.floor(colorpicker.current.G*255))
			colorpicker.blue.PlaceholderText = "B: "..tostring(math.floor(colorpicker.current.B*255))
			colorpicker.hex.PlaceholderText = "Hex: "..utility.to_hex(colorpicker.current)
		end
		--
		local function movehue()
			colorpicker.outline3.BackgroundColor3 = Color3.fromHSV(h,1,1)
			colorpicker.huecursor_inline.BackgroundColor3 = Color3.fromHSV(h,1,1)
			colorpicker.hsv[1] = h
			colorpicker.current = Color3.fromHSV(colorpicker.hsv[1],colorpicker.hsv[2],colorpicker.hsv[3])
			colorpicker.cpcolor.BackgroundColor3 = colorpicker.current
			colorpicker.huecursor:TweenPosition(UDim2.new(0.5,0,h,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
		end
		--
		local function movecp()
			colorpicker.hsv[2] = s
			colorpicker.hsv[3] = v
			colorpicker.current = Color3.fromHSV(colorpicker.hsv[1],colorpicker.hsv[2],colorpicker.hsv[3])
			colorpicker.cpcolor.BackgroundColor3 = colorpicker.current
			colorpicker.cpcursor:TweenPosition(UDim2.new(s,0,1-v,0),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.15,true)
		end
		--
		movehue()
		movecp()
		updateboxes()
		colorpicker.callback(colorpicker.current)
	end
end
--
function sections:buttonbox(props)
	local bbName = props.name or props.Name or props.page or props.Page or props.pagename or props.Pagename or props.PageName or props.pageName or "new ui"
	local def = props.def or props.Def or props.default or props.Default or ""
	local max = props.max or props.Max or props.maximum or props.Maximum or 4
	local options = props.options or props.Options or props.Settings or props.settings or {}
	local callback = props.callback or props.callBack or props.CallBack or props.Callback or function()end
	local tooltipstr = props.tooltip or props.Tooltip or "N/A"
	local buttonbox = {}
	--
	local buttonboxholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,35),
			ZIndex = 2,
			Parent = self.content
		}
	)
	--
	local bbOutline = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(12, 12, 12),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,15),
			Parent = buttonboxholder
		}
	)
	--
	local bbOutline2 = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(24, 24, 24),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = bbOutline
		}
	)
	--
	local bbColor = utility.new(
		"Frame",
		{
			BackgroundColor3 = Color3.fromRGB(30, 30, 30),
			BorderSizePixel = 0,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Parent = bbOutline2
		}
	)
	--
	utility.new(
		"UIGradient",
		{
			Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))},
			Rotation = 90,
			Parent = bbColor
		}
	)
	--
	local indicator = utility.new(
		"TextLabel",
		{
			AnchorPoint = Vector2.new(0.5,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,-10,1,0),
			Position = UDim2.new(0.5,0,0,0),
			Font = self.library.font,
			Text = "+",
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Right",
			ClipsDescendants = true,
			Parent = bbOutline
		}
	)
	--
	local bbTitle = utility.new(
		"TextLabel",
		{
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,0,15),
			Position = UDim2.new(0,0,0,0),
			Font = self.library.font,
			Text = bbName,
			TextColor3 = Color3.fromRGB(255,255,255),
			TextSize = self.library.textsize,
			TextStrokeTransparency = 0,
			TextXAlignment = "Left",
			Parent = buttonboxholder
		}
	)
	--
	local buttonboxbutton = utility.new(
		"TextButton",
		{
			AnchorPoint = Vector2.new(0,0),
			BackgroundTransparency = 1,
			Size = UDim2.new(1,0,1,0),
			Position = UDim2.new(0,0,0,0),
			Text = "",
			Parent = buttonboxholder
		}
	)
	--
	local optionsholder = utility.new(
		"Frame",
		{
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,0,20),
			Position = UDim2.new(0,0,0,34),
			Visible = false,
			Parent = buttonboxholder
		}
	)
	--
	local bbSize = #options
	bbSize = math.clamp(bbSize,1,max)
	--
	local optionsoutline = utility.new(
		"ScrollingFrame",
		{
			BackgroundColor3 = Color3.fromRGB(56, 56, 56),
			BorderColor3 = Color3.fromRGB(56, 56, 56),
			BorderMode = "Inset",
			BorderSizePixel = 1,
			Size = UDim2.new(1,0,bbSize,2),
			Position = UDim2.new(0,0,0,0),
			ClipsDescendants = true,
			CanvasSize = UDim2.new(0,0,0,18*#options),
			ScrollBarImageTransparency = 0.25,
			ScrollBarImageColor3 = Color3.fromRGB(0,0,0),
			ScrollBarThickness = 5,
			VerticalScrollBarInset = "ScrollBar",
			VerticalScrollBarPosition = "Right",
			ZIndex = 5,
			Parent = optionsholder
		}
	)
	--
	utility.new(
		"UIListLayout",
		{
			FillDirection = "Vertical",
			Parent = optionsoutline
		}
	)
	--
	buttonbox = {
		["library"] = self.library,
		["optionsholder"] = optionsholder,
		["indicator"] = indicator,
		["options"] = options,
		["title"] = bbTitle,
		["open"] = false,
		["titles"] = {},
		["current"] = def,
		["callback"] = callback,
		["tooltip"] = tooltipstr
	}
	--
	table.insert(buttonbox.library.buttonboxs,buttonbox)
	--
	for i,v in pairs(options) do
		local bboptionbutton = utility.new(
			"TextButton",
			{
				AnchorPoint = Vector2.new(0,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,0,0,18),
				Text = "",
				ZIndex = 6,
				Parent = optionsoutline
			}
		)
		--
		local bboptiontitle = utility.new(
			"TextLabel",
			{
				AnchorPoint = Vector2.new(0.5,0),
				BackgroundTransparency = 1,
				Size = UDim2.new(1,-10,1,0),
				Position = UDim2.new(0.5,0,0,0),
				Font = self.library.font,
				Text = v,
				TextColor3 = Color3.fromRGB(255,255,255),
				TextSize = self.library.textsize,
				TextStrokeTransparency = 0,
				TextXAlignment = "Left",
				ClipsDescendants = true,
				ZIndex = 6,
				Parent = bboptionbutton
			}
		)
		--
		self.library.labels[#self.library.labels+1] = bboptiontitle
		table.insert(buttonbox.titles,bboptiontitle)
		--
		bboptionbutton.MouseButton1Down:Connect(function()
			optionsholder.Visible = false
			buttonbox.open = false
			indicator.Text = "+"
			buttonbox.current = v
			buttonbox.callback(v)
		end)
	end
	--
	buttonboxbutton.MouseButton1Down:Connect(function()
		buttonbox.library:closewindows(buttonbox)
		optionsholder.Visible = not buttonbox.open
		buttonbox.open = not buttonbox.open
		if buttonbox.open then
			indicator.Text = "-"
		else
			indicator.Text = "+"
		end
	end)
	--
	buttonboxbutton.MouseEnter:Connect(function()
		self.library.showTooltip(buttonbox.tooltip, buttonboxbutton)
	end)
	buttonboxbutton.MouseLeave:Connect(function()
		self.library.hideTooltip()
	end)
	--
	local pointer = props.pointer or props.Pointer or props.pointername or props.Pointername or props.PointerName or props.pointerName or nil
	if pointer then
		if self.pointers then
			self.library.pointers[tostring(pointer)] = buttonbox
		end
	end
	--
	self.library.labels[#self.library.labels+1] = bbTitle
	setmetatable(buttonbox, buttonboxs)
	return buttonbox
end
--
function buttonboxs:set(val)
	if val ~= nil then
		local buttonbox = self
		if table.find(buttonbox.options,val) then
			self.current = tostring(val)
			self.callback(tostring(val))
		end
	end
end
--
function sections:configloader(props)
	local folder = props.folder or "VelocityConfig"
	if not isfolder(folder) then makefolder(folder) end
	local configloader = {}
	
	local clholder = utility.new("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,240), Parent = self.content})
	local clOutline = utility.new("Frame", {BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(12, 12, 12), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,1,0), Parent = clholder})
	
	local clTitle = utility.new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,15), Position = UDim2.new(0,0,0,3), Font = self.library.font, Text = "Config Manager", TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, TextStrokeTransparency = 0, TextXAlignment = "Center", Parent = clOutline})
	self.library.labels[#self.library.labels+1] = clTitle
	
	local clColor = utility.new("Frame", {AnchorPoint = Vector2.new(0.5,0), BackgroundColor3 = self.library.theme.accent, BorderColor3 = Color3.fromRGB(12, 12, 12), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,-6,0,1), Position = UDim2.new(0.5,0,0,19), Parent = clOutline})
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],clColor)
	
	local configsholder = utility.new("Frame", {AnchorPoint = Vector2.new(0.5,0), BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(12, 12, 12), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,-10,0,120), Position = UDim2.new(0.5,0,0,25), Parent = clOutline})
	local scroll = utility.new("ScrollingFrame", {BackgroundColor3 = Color3.fromRGB(56, 56, 56), BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), ClipsDescendants = true, AutomaticCanvasSize = "Y", CanvasSize = UDim2.new(0,0,0,0), ScrollBarImageTransparency = 0.25, ScrollBarImageColor3 = Color3.fromRGB(0,0,0), ScrollBarThickness = 5, VerticalScrollBarInset = "ScrollBar", VerticalScrollBarPosition = "Right", Parent = configsholder})
	utility.new("UIListLayout", {FillDirection = "Vertical", Padding = UDim.new(0,0), Parent = scroll})
	
	local buttonsholder = utility.new("Frame", {BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1,0,0,85), Position = UDim2.new(0,0,0,150), Parent = clOutline})
	local createdbuttons = {}
	local selected_cfg = nil
	
	local function refresh()
		for _,v in pairs(createdbuttons) do v.button:Destroy() end
		createdbuttons = {}
		selected_cfg = nil
		if isfolder(folder) then
			for _, file in pairs(listfiles(folder)) do
				if file:sub(-4) == ".cfg" then
					local cfgname = string.match(file, "[^/\\]+$"):sub(1, -5)
					local btn = utility.new("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,18), Text = "", Parent = scroll})
					local grey = utility.new("Frame", {AnchorPoint = Vector2.new(0.5,0), BackgroundColor3 = Color3.fromRGB(125, 125, 125), BackgroundTransparency = 0.8, Size = UDim2.new(1,-4,1,0), Position = UDim2.new(0.5,0,0,0), Visible = false, Parent = btn})
					local lbl = utility.new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,-10,1,0), Position = UDim2.new(0,5,0,0), Font = self.library.font, Text = cfgname, TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, TextXAlignment = "Left", Parent = btn})
					table.insert(createdbuttons, {button=btn, grey=grey, title=lbl, name=cfgname})
					btn.MouseButton1Down:Connect(function()
						for _,vv in pairs(createdbuttons) do vv.grey.Visible = false vv.title.TextColor3 = Color3.fromRGB(255,255,255) end
						grey.Visible = true; lbl.TextColor3 = self.library.theme.accent; selected_cfg = cfgname
					end)
				end
			end
		end
	end

	local name_box_holder = utility.new("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,-10,0,20), Position = UDim2.new(0.5,0,0,0), AnchorPoint = Vector2.new(0.5,0), Parent = buttonsholder})
	local nb_out = utility.new("Frame", {BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(12, 12, 12), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,1,0), Parent = name_box_holder})
	local name_input = utility.new("TextBox", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), PlaceholderText = "Config Name...", Text = "", TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, Font = self.library.font, Parent = name_box_holder})

	local function create_btn(text, pos, btnCallback)
		local h = utility.new("Frame", {BackgroundTransparency = 1, Size = UDim2.new(0.5,-6,0,20), Position = pos, Parent = buttonsholder})
		local o = utility.new("Frame", {BackgroundColor3 = Color3.fromRGB(24,24,24), BorderColor3 = Color3.fromRGB(12,12,12), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,1,0), Parent = h})
		local btn = utility.new("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = text, TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, Font = self.library.font, Parent = h})
		btn.MouseButton1Down:Connect(btnCallback)
	end

	create_btn("Create", UDim2.new(0,5,0,25), function() if name_input.Text~="" then self.library:saveconfig(folder, name_input.Text); refresh(); name_input.Text="" else self.library:Notification({Title="Error",Description="Enter name!"}) end end)
	create_btn("Save", UDim2.new(0,5,0,50), function() if selected_cfg then self.library:saveconfig(folder, selected_cfg) else self.library:Notification({Title="Error",Description="Select config!"}) end end)
	create_btn("Load", UDim2.new(0.5,5,0,25), function() if selected_cfg then self.library:loadconfig(folder, selected_cfg) else self.library:Notification({Title="Error",Description="Select config!"}) end end)
	create_btn("Delete", UDim2.new(0.5,5,0,50), function() if selected_cfg then delfile(folder.."/"..selected_cfg..".cfg"); refresh(); self.library:Notification({Title="Deleted",Description=selected_cfg}) else self.library:Notification({Title="Error",Description="Select config!"}) end end)

	refresh()
	configloader = {["library"] = self.library}
	setmetatable(configloader, configloaders)
	return configloader 
end
--
return library
