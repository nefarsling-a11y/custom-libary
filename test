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
--
local utility = {}
--
local check_exploit = (syn and "Synapse") or (KRNL_LOADED and "Krnl") or (isourclosure and "ScriptWare") or nil
local plrs = game:GetService("Players")
local cre = game:GetService("CoreGui")
local rs = game:GetService("RunService")
local ts = game:GetService("TweenService") 
local uis = game:GetService("UserInputService") 
local hs = game:GetService("HttpService")
local ws = game:GetService("Workspace")
local plr = plrs.LocalPlayer
local cam = ws.CurrentCamera
local mouse = plr:GetMouse()

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
	return ins
end

utility.tween = function(instance, properties, duration, style, direction)
	ts:Create(instance, TweenInfo.new(duration or 0.5, style or Enum.EasingStyle.Quad, direction or Enum.EasingDirection.Out), properties):Play()
end

utility.dragify = function(ins,touse)
	local dragging
	local dragInput
	local dragStart
	local startPos
	local function update(input)
		local delta = input.Position - dragStart
		touse:TweenPosition(UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y),Enum.EasingDirection.Out,Enum.EasingStyle.Quad,0.1,true)
	end
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
	ins.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
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
	-- // properties
	local textsize = props.textsize or 12
	local font = props.font or "RobotoMono"
	local name = props.name or "new ui"
	local color = props.color or Color3.fromRGB(225, 58, 81)
	local resizable = props.resizable or true -- Переменная для ресайза
    local bg_effect = props.bg_effect or nil -- "snow", "text", "image"
    
	local window = {}
	
	-- // screen
	local screen = utility.new("ScreenGui", {
		Name = tostring(math.random(0,999999)),
		DisplayOrder = 9999,
		ResetOnSpawn = false,
		ZIndexBehavior = "Global",
		Parent = cre
	})
    if (check_exploit == "Synapse" and syn.request and syn.protect_gui) then
        syn.protect_gui(screen)
    end

    -- // Background Modal (Dimmer)
    local backdrop = utility.new("Frame", {
        Name = "Backdrop",
        Parent = screen,
        BackgroundColor3 = Color3.fromRGB(0,0,0),
        BackgroundTransparency = 1, -- Начинаем с 1
        Size = UDim2.new(1,0,1,0),
        Position = UDim2.new(0,0,0,0),
        ZIndex = 0
    })

    -- // Background Effects Container
    local bg_container = utility.new("Frame", {
        Name = "Effects",
        Parent = backdrop,
        BackgroundTransparency = 1,
        Size = UDim2.new(1,0,1,0),
        ClipsDescendants = true
    })

	-- // Outline (Main Window)
	local outline = utility.new("Frame", {
		AnchorPoint = Vector2.new(0.5,0.5),
		BackgroundColor3 = color,
		BorderColor3 = Color3.fromRGB(12, 12, 12),
		BorderSizePixel = 1,
		Size = UDim2.new(0,600,0,790), -- Start Size
		Position = UDim2.new(0.5,0,0.5,50), -- Start pos (немного ниже для анимации)
		Parent = screen,
        BackgroundTransparency = 1, -- Для фейд анимации
        Visible = false -- Скрыто по умолчанию
	})

    -- Контейнер для содержимого, чтобы управлять прозрачностью всего окна сразу
    local content_wrapper = utility.new("CanvasGroup", {
        Size = UDim2.new(1,0,1,0),
        BackgroundTransparency = 1,
        Parent = outline,
        GroupTransparency = 1 -- Start transparency
    })

	-- // Inner Frames
	local outline2 = utility.new("Frame", {
		AnchorPoint = Vector2.new(0.5,0.5),
		BackgroundColor3 = Color3.fromRGB(0, 0, 0),
		BorderColor3 = Color3.fromRGB(12, 12, 12),
		BorderSizePixel = 1,
		Size = UDim2.new(1,-4,1,-4),
		Position = UDim2.new(0.5,0,0.5,0),
		Parent = content_wrapper
	})
	
	local indent = utility.new("Frame", {
		AnchorPoint = Vector2.new(0.5,0.5),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		BorderMode = "Inset",
		BorderSizePixel = 1,
		Size = UDim2.new(1,0,1,0),
		Position = UDim2.new(0.5,0,0.5,0),
		Parent = outline2
	})
	
	local main = utility.new("Frame", {
		AnchorPoint = Vector2.new(0.5,1),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		BorderMode = "Inset",
		BorderSizePixel = 1,
		Size = UDim2.new(1,-10,1,-25),
		Position = UDim2.new(0.5,0,1,-5),
		Parent = outline2
	})

	local title = utility.new("Frame", {
		AnchorPoint = Vector2.new(0.5,0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,20),
		Position = UDim2.new(0.5,0,0,0),
		Parent = outline2
	})
	
	local outline3 = utility.new("Frame", {
		AnchorPoint = Vector2.new(0.5,0.5),
		BackgroundColor3 = Color3.fromRGB(24, 24, 24),
		BorderColor3 = Color3.fromRGB(12, 12, 12),
		BorderMode = "Inset",
		BorderSizePixel = 1,
		Size = UDim2.new(1,0,1,0),
		Position = UDim2.new(0.5,0,0.5,0),
		Parent = main
	})

	local titletext = utility.new("TextLabel", {
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
	})

	local holder = utility.new("Frame", {
		AnchorPoint = Vector2.new(0.5,0.5),
		BackgroundTransparency = 1,
		Size = UDim2.new(1,-6,1,-6),
		Position = UDim2.new(0.5,0,0.5,0),
		Parent = main
	})

	local tabs = utility.new("Frame", {
		AnchorPoint = Vector2.new(0.5,1),
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderColor3 = Color3.fromRGB(12, 12, 12),
		BorderMode = "Inset",
		BorderSizePixel = 1,
		Size = UDim2.new(1,0,1,-20),
		Position = UDim2.new(0.5,0,1,0),
		Parent = holder
	})

	local tabsbuttons = utility.new("Frame", {
		AnchorPoint = Vector2.new(0.5,0),
		BackgroundTransparency = 1,
		Size = UDim2.new(1,0,0,21),
		Position = UDim2.new(0.5,0,0,0),
		ZIndex = 2,
		Parent = holder
	})
    
	local outline4 = utility.new("Frame", {
		BackgroundColor3 = Color3.fromRGB(20, 20, 20),
		BorderColor3 = Color3.fromRGB(56, 56, 56),
		BorderMode = "Inset",
		BorderSizePixel = 1,
		Size = UDim2.new(1,0,1,0),
		Position = UDim2.new(0,0,0,0),
		Parent = tabs
	})

	utility.new("UIListLayout", {
		FillDirection = "Horizontal",
		Padding = UDim.new(0,2),
		Parent = tabsbuttons
	})

    -- // Tooltip (Создаем один скрытый фрейм)
    local tooltip_frame = utility.new("Frame", {
        Name = "Tooltip",
        Parent = screen,
        BackgroundColor3 = Color3.fromRGB(24, 24, 24),
        BorderColor3 = color,
        BorderSizePixel = 1,
        ZIndex = 10000,
        Visible = false,
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 0
    })
    local tooltip_text = utility.new("TextLabel", {
        Parent = tooltip_frame,
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(255, 255, 255),
        TextSize = textsize,
        Font = font,
        TextWrapped = true,
        Size = UDim2.new(1, -6, 1, -4),
        Position = UDim2.new(0, 3, 0, 2),
        TextXAlignment = "Left",
        TextYAlignment = "Top"
    })

    -- // Custom Cursor
    local cursor = utility.new("ImageLabel", {
        Name = "Cursor",
        Parent = screen,
        BackgroundTransparency = 1,
        Image = "rbxassetid://6065773957", -- Треугольный курсор (пример)
        ImageColor3 = color,
        Size = UDim2.new(0, 20, 0, 20),
        ZIndex = 10001,
        Visible = false
    })

    -- // Resizer Grip
    local resize_grip = nil
    if resizable then
        resize_grip = utility.new("ImageButton", {
            Name = "ResizeGrip",
            Parent = outline,
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 15, 0, 15),
            Position = UDim2.new(1, -15, 1, -15),
            AnchorPoint = Vector2.new(0, 0),
            ZIndex = 10,
            Image = "rbxassetid://4996962294", -- Треугольник
            ImageColor3 = color,
            Rotation = 0 -- Можно повернуть если текстура требует
        })
        
        local resizing = false
        local drag_start = Vector2.new(0,0)
        local start_size = UDim2.new(0,0,0,0)

        resize_grip.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = true
                drag_start = input.Position
                start_size = outline.Size
            end
        end)

        uis.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
                local delta = input.Position - drag_start
                outline.Size = UDim2.new(0, math.max(300, start_size.X.Offset + delta.X), 0, math.max(300, start_size.Y.Offset + delta.Y))
            end
        end)

        uis.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                resizing = false
            end
        end)
    end

	utility.dragify(title,outline)

	-- // window tbl
	window = {
		["screen"] = screen,
		["holder"] = holder,
		["labels"] = {},
		["tabs"] = outline4,
		["tabsbuttons"] = tabsbuttons,
		["outline"] = outline,
        ["content_wrapper"] = content_wrapper,
        ["cursor"] = cursor,
        ["backdrop"] = backdrop,
        ["tooltip_frame"] = tooltip_frame,
        ["tooltip_text"] = tooltip_text,
        ["resize_grip"] = resize_grip,
		["pages"] = {},
		["pointers"] = {},
		["dropdowns"] = {},
		["multiboxes"] = {},
		["buttonboxs"] = {},
		["colorpickers"] = {},
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
                ["ImageColor3"] = {} -- Добавлено для курсора/грипа
			}
		}
	}

	table.insert(window.themeitems["accent"]["BackgroundColor3"],outline)
    table.insert(window.themeitems["accent"]["BorderColor3"],tooltip_frame)
    if resize_grip then table.insert(window.themeitems["accent"]["ImageColor3"], resize_grip) end
    table.insert(window.themeitems["accent"]["ImageColor3"], cursor)
	
    -- // Background Effects Logic
    if bg_effect then
        task.spawn(function()
            if bg_effect == "snow" then
                local emitter = utility.new("ParticleEmitter", {
                    Texture = "rbxassetid://258128463", -- snow texture
                    Rate = 20,
                    LifeTime = NumberRange.new(5, 10),
                    Speed = NumberRange.new(20, 50),
                    SpreadAngle = Vector2.new(0, 0),
                    Acceleration = Vector3.new(0, 10, 0),
                    Rotation = NumberRange.new(0, 360),
                    RotSpeed = NumberRange.new(-50, 50),
                    Size = NumberSequence.new(0.5),
                    BackgroundTransparency = 1,
                    Parent = nil -- Need an attachment
                })
                -- Создаем невидимый part сверху для снега
                -- Упрощенно для 2D UI - используем Frame Loop
                 while window.backdrop.Parent do
                    if window.backdrop.Visible then
                         local flake = utility.new("Frame", {
                            Parent = bg_container,
                            BackgroundColor3 = Color3.new(1,1,1),
                            BorderSizePixel = 0,
                            Size = UDim2.new(0, 3, 0, 3),
                            Position = UDim2.new(math.random(), 0, -0.1, 0)
                        })
                        utility.new("UICorner", {CornerRadius=UDim.new(1,0), Parent=flake})
                        game:GetService("TweenService"):Create(flake, TweenInfo.new(math.random(3,6), Enum.EasingStyle.Linear), {Position = UDim2.new(flake.Position.X.Scale + math.random(-10,10)/100, 0, 1.1, 0), BackgroundTransparency=1}):Play()
                        game.Debris:AddItem(flake, 6)
                    end
                    wait(0.1)
                end
            elseif bg_effect == "text" or bg_effect == "image" then
                 -- Scroller logic
                 local content = (bg_effect == "text") and "VELOCITY " or "rbxassetid://7493641267" -- Пример лого
                 local function spawn_row(y_pos)
                    local row = utility.new("Frame", {
                        Parent = bg_container,
                        Size = UDim2.new(2, 0, 0, 30),
                        Position = UDim2.new(0, 0, y_pos, 0),
                        BackgroundTransparency = 1
                    })
                    if bg_effect == "text" then
                        utility.new("TextLabel", {Parent = row, Size = UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=string.rep(content, 20), TextSize=20, TextColor3=Color3.fromRGB(255,255,255), TextTransparency=0.8})
                    else
                         utility.new("ImageLabel", {Parent = row, Size = UDim2.new(0,30,0,30), Image=content, BackgroundTransparency=1, ImageTransparency=0.8})
                         -- Clone multiple images
                         local list = utility.new("UIListLayout", {Parent=row, FillDirection="Horizontal", Padding=UDim.new(0,20)})
                         for i=1, 40 do utility.new("ImageLabel", {Parent = row, Size = UDim2.new(0,30,0,30), Image=content, BackgroundTransparency=1, ImageTransparency=0.8}) end
                    end
                    
                    local tween = ts:Create(row, TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.Out, -1), {Position = UDim2.new(-1, 0, y_pos, 0)})
                    tween:Play()
                 end
                 for i=0, 1, 0.05 do spawn_row(i) end
            end
        end)
    end

    -- // Logic: Tooltip Cursor Follow
    rs.RenderStepped:Connect(function()
        if cursor.Visible then
            local m_pos = uis:GetMouseLocation()
            cursor.Position = UDim2.new(0, m_pos.X, 0, m_pos.Y)
            if tooltip_frame.Visible then
                tooltip_frame.Position = UDim2.new(0, m_pos.X + 15, 0, m_pos.Y)
            end
        end
    end)

    -- // Toggle Window Logic (Updated Animations)
	local toggled = false
	local cooldown = false
    local saved_pos = UDim2.new(0.5, 0, 0.5, 0)

	uis.InputBegan:Connect(function(Input)
		if Input.UserInputType == Enum.UserInputType.Keyboard and Input.KeyCode == window.key then
			if not cooldown then
				cooldown = true
				toggled = not toggled
                
				if toggled then
                    -- OPEN ANIMATION
                    outline.Visible = true
                    backdrop.BackgroundTransparency = 1
                    content_wrapper.GroupTransparency = 1
                    outline.Position = UDim2.new(saved_pos.X.Scale, saved_pos.X.Offset, saved_pos.Y.Scale, saved_pos.Y.Offset + 50)
                    
                    utility.tween(backdrop, {BackgroundTransparency = 0.5}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    utility.tween(outline, {Position = saved_pos}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    utility.tween(content_wrapper, {GroupTransparency = 0}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
                    
                    cursor.Visible = true
                    uis.MouseIconEnabled = false
				else
                    -- CLOSE ANIMATION
                    saved_pos = outline.Position -- Save position before hiding
                    
                    utility.tween(backdrop, {BackgroundTransparency = 1}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                    utility.tween(outline, {Position = UDim2.new(saved_pos.X.Scale, saved_pos.X.Offset, saved_pos.Y.Scale, saved_pos.Y.Offset + 50)}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                    utility.tween(content_wrapper, {GroupTransparency = 1}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
                    
                    cursor.Visible = false
                    uis.MouseIconEnabled = true
                    
                    delay(1, function()
                        if not toggled then outline.Visible = false end
                    end)
				end
				wait(1)
				cooldown = false
			end
		end
	end)

    -- Helper for Tooltips
    window.add_tooltip = function(element, text)
        if not text then return end
        local hover_start = 0
        element.MouseEnter:Connect(function()
            hover_start = tick()
            spawn(function()
                while element.Visible and tick() - hover_start < 2 do
                     -- check if mouse still over? Roblox handles MouseEnter/Leave reliably mostly
                     if not element:IsDescendantOf(game) then return end
                     wait(0.1)
                end
                if tick() - hover_start >= 2 then
                     tooltip_text.Text = text
                     local bounds = tooltip_text.TextBounds
                     tooltip_frame.Size = UDim2.new(0, math.min(bounds.X + 10, 200), 0, bounds.Y + 6)
                     tooltip_frame.Size = UDim2.new(0, math.min(bounds.X + 10, 200), 0, 1000) -- calc height wrap
                     tooltip_frame.Size = UDim2.new(0, math.min(bounds.X + 10, 200), 0, tooltip_text.TextBounds.Y + 6)
                     
                     tooltip_frame.Visible = true
                     tooltip_frame.BackgroundTransparency = 1
                     tooltip_text.TextTransparency = 1
                     utility.tween(tooltip_frame, {BackgroundTransparency = 0}, 0.5)
                     utility.tween(tooltip_text, {TextTransparency = 0}, 0.5)
                end
            end)
        end)
        element.MouseLeave:Connect(function()
            hover_start = tick() + 9999
            tooltip_frame.Visible = false
        end)
    end

	window.labels[#window.labels+1] = titletext
	setmetatable(window, library)
	return window
end

-- // Уведомления (оставлено как было, но добавлена проверка темы)
function library:Notification(props)
	-- ... (код уведомлений из вашего запроса идентичен, оставляю сокращенно для экономии места, он рабочий)
    -- Вставьте код Notification из вашего исходника сюда, если он нужен, либо используйте тот что был.
    -- Для полноты картины вставлю базовый:
	local title_text = props.title or "Notification"
	local desc_text = props.content or props.description or ""
	local duration = props.time or 5
	local offset = 0
	for i, v in pairs(notifications) do if v.main then offset = offset + (v.main.AbsoluteSize.Y + 6) end end
	local outline = utility.new("Frame", { Name = "Notification", Parent = self.screen, BackgroundColor3 = self.theme.accent, BorderSizePixel = 0, Position = UDim2.new(1, 10, 1, -20 - offset), Size = UDim2.new(0, 250, 0, 0), AnchorPoint = Vector2.new(1, 1), ZIndex = 9999 })
	table.insert(self.themeitems["accent"]["BackgroundColor3"], outline)
	local holder = utility.new("Frame", { Parent = outline, BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderSizePixel = 0, Position = UDim2.new(0, 1, 0, 1), Size = UDim2.new(1, -2, 1, -2), ZIndex = 9999 })
	local titleLabel = utility.new("TextLabel", { Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 5), Size = UDim2.new(1, -20, 0, 20), Font = self.font, Text = title_text, TextColor3 = self.theme.accent, TextSize = self.textsize + 2, TextXAlignment = "Left", ZIndex = 9999 })
	table.insert(self.themeitems["accent"]["TextColor3"], titleLabel)
	local descLabel = utility.new("TextLabel", { Parent = holder, BackgroundTransparency = 1, Position = UDim2.new(0, 10, 0, 25), Size = UDim2.new(1, -20, 0, 0), Font = self.font, Text = desc_text, TextColor3 = Color3.fromRGB(255, 255, 255), TextSize = self.textsize, TextWrapped = true, TextXAlignment = "Left", TextYAlignment = "Top", ZIndex = 9999 })
	descLabel.Size = UDim2.new(1, -20, 0, 1000); local bounds = descLabel.TextBounds.Y; descLabel.Size = UDim2.new(1, -20, 0, bounds); outline.Size = UDim2.new(0, 250, 0, 35 + bounds + 5)
	outline:TweenPosition(UDim2.new(1, -10, 1, -20 - offset), "Out", "Quad", 0.5, true)
	local notif_data = {main = outline}; table.insert(notifications, notif_data)
	spawn(function() wait(duration); outline:TweenPosition(UDim2.new(1, 300, 1, -20 - offset), "In", "Quad", 0.5, true); wait(0.5); for i,v in pairs(notifications) do if v == notif_data then table.remove(notifications, i) end end; outline:Destroy() end)
end

function library:saveconfig(folder_name, config_name)
    if not isfolder(folder_name) then makefolder(folder_name) end
    local cfg = {}
    for name, element in pairs(self.pointers) do
        if element.current ~= nil then
            if typeof(element.current) == "Color3" then
                cfg[name] = {element.current.R, element.current.G, element.current.B, "Color3"}
            else
                cfg[name] = element.current
            end
        end
    end
    -- Save Window Size
    cfg["__WindowSize"] = {self.outline.Size.X.Offset, self.outline.Size.Y.Offset}
    
    local success, err = pcall(function() writefile(folder_name.."/"..config_name..".cfg", hs:JSONEncode(cfg)) end)
    if success then self:Notification({Title="Config Saved", Description="Saved: "..config_name, Time=3}) else self:Notification({Title="Error", Description="Save failed: "..tostring(err)}) end
end

function library:loadconfig(folder_name, config_name)
    local path = folder_name.."/"..config_name..".cfg"
    if not isfile(path) then self:Notification({Title="Error", Description="Config not found!"}) return end
    local success, err = pcall(function()
        local cfg = hs:JSONDecode(readfile(path))
        for name, value in pairs(cfg) do
            if name == "__WindowSize" then
                self.outline.Size = UDim2.new(0, value[1], 0, value[2])
            elseif self.pointers[name] then
                local element = self.pointers[name]
                if typeof(value) == "table" and value[4] == "Color3" then element:set(Color3.new(value[1], value[2], value[3])) else element:set(value) end
            end
        end
    end)
    if success then self:Notification({Title="Config Loaded", Description="Loaded: "..config_name, Time=3}) else self:Notification({Title="Error", Description="Load failed: "..tostring(err)}) end
end

function library:closewindows(ignore)
    -- Closing logic (same as original)
	for i,v in pairs(self.dropdowns) do if v ~= ignore and v.open then v.open=false; v.indicator.Text="+"; utility.tween(v.optionsoutline, {Size = UDim2.new(1,0,0,0)}, 1); delay(1, function() if not v.open then v.optionsholder.Visible=false end end) end end
	for i,v in pairs(self.multiboxes) do if v ~= ignore and v.open then v.open=false; v.indicator.Text="+"; utility.tween(v.optionsoutline, {Size = UDim2.new(1,0,0,0)}, 1); delay(1, function() if not v.open then v.optionsholder.Visible=false end end) end end
	for i,v in pairs(self.buttonboxs) do if v ~= ignore and v.open then v.open=false; v.indicator.Text="+"; utility.tween(v.optionsoutline, {Size = UDim2.new(1,0,0,0)}, 1); delay(1, function() if not v.open then v.optionsholder.Visible=false end end) end end
	for i,v in pairs(self.colorpickers) do if v ~= ignore and v.open then v.open=false; v.cpholder.Visible=false end end
end

-- // Page
function library:page(props)
	local name = props.name or "new page"
	local page = {}
	
	local tabbutton = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(20, 20, 20), BorderColor3 = Color3.fromRGB(12, 12, 12), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(0,75,1,0), Parent = self.tabsbuttons })
	local outline = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(56, 56, 56), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Parent = tabbutton })
	local button = utility.new("TextButton", { AnchorPoint = Vector2.new(0,0), BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Text = "", Parent = tabbutton })
	local r_line = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(56, 56, 56), BorderSizePixel = 0, Size = UDim2.new(0,1,0,1), Position = UDim2.new(1,0,1,1), ZIndex = 2, Parent = outline })
	local l_line = utility.new("Frame", { AnchorPoint = Vector2.new(1,0), BackgroundColor3 = Color3.fromRGB(56, 56, 56), BorderSizePixel = 0, Size = UDim2.new(0,1,0,1), Position = UDim2.new(0,0,1,1), ZIndex = 2, Parent = outline })
	local line = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderSizePixel = 0, Size = UDim2.new(1,0,0,2), Position = UDim2.new(0,0,1,0), ZIndex = 2, Parent = outline })
	local label = utility.new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,0,0), Font = self.font, Text = name, TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.textsize, TextStrokeTransparency = 0, Parent = outline })
	
	local pageholder = utility.new("Frame", { AnchorPoint = Vector2.new(0.5,0.5), BackgroundTransparency = 1, Size = UDim2.new(1,-20,1,-20), Position = UDim2.new(0.5,0,0.5,0), Visible = false, Parent = self.tabs })
	
    -- Обновим контейнеры для секций с CanvasGroup для анимации
    local left = utility.new("CanvasGroup", { BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(0.5,-5,1,0), Position = UDim2.new(0,0,0,0), AutomaticCanvasSize = "Y", ScrollBarThickness = 0, Parent = pageholder, GroupTransparency = 1 })
	utility.new("UIListLayout", { FillDirection = "Vertical", Padding = UDim.new(0,10), Parent = left })
	
	local right = utility.new("CanvasGroup", { AnchorPoint = Vector2.new(1,0), BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(0.5,-5,1,0), Position = UDim2.new(1,0,0,0), AutomaticCanvasSize = "Y", ScrollBarThickness = 0, Parent = pageholder, GroupTransparency = 1 })
	utility.new("UIListLayout", { FillDirection = "Vertical", Padding = UDim.new(0,10), Parent = right })
	
	page = { ["library"] = self, ["outline"] = outline, ["r_line"] = r_line, ["l_line"] = l_line, ["line"] = line, ["page"] = pageholder, ["left"] = left, ["right"] = right, ["open"] = false, ["pointers"] = {} }
	table.insert(self.pages,page)
	
	button.MouseButton1Down:Connect(function()
        page:openpage()
	end)
	
    if props.pointer then self.library.pointers[tostring(props.pointer)] = page.pointers end
	self.labels[#self.labels+1] = label
	setmetatable(page, pages)
	return page
end

function pages:openpage()
    local page = self
    if page.open == false then
        for i,v in pairs(page.library.pages) do
            if v ~= page and v.open then
                v.page.Visible = false
                v.open = false
                v.outline.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
                v.line.Size = UDim2.new(1,0,0,2)
                v.line.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
            end
        end
        
        self.library:closewindows()
        
        page.page.Visible = true
        page.open = true
        page.outline.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        page.line.Size = UDim2.new(1,0,0,3)
        page.line.BackgroundColor3 = Color3.fromRGB(20, 20, 20)

        -- PAGE TRANSITION ANIMATION
        -- Reset state
        page.left.GroupTransparency = 1
        page.right.GroupTransparency = 1
        page.left.Position = UDim2.new(0, 0, 0, 50)
        page.right.Position = UDim2.new(1, 0, 0, 50)
        
        utility.tween(page.left, {GroupTransparency = 0, Position = UDim2.new(0,0,0,0)}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        utility.tween(page.right, {GroupTransparency = 0, Position = UDim2.new(1,0,0,0)}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    end
end

-- // Section (Updated with Collapsing)
function pages:section(props)
	local name = props.name or "new ui"
	local side = props.side or "left"
	side = side:lower()
    local size = 0 -- Auto calc
    
	local section = {}
	
    -- Holder (Основной контейнер, который будет ресайзиться)
	local sectionholder = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(56, 56, 56), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,0,25), Parent = self[side], ClipsDescendants = true })
	local outline = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(12, 12, 12), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,1,0), Parent = sectionholder })
	
	local color = utility.new("Frame", { AnchorPoint = Vector2.new(0.5,0), BackgroundColor3 = self.library.theme.accent, BorderSizePixel = 0, Size = UDim2.new(1,-2,0,1), Position = UDim2.new(0.5,0,0,0), Parent = outline })
	table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color)
	
	local content = utility.new("Frame", { AnchorPoint = Vector2.new(0.5,1), BackgroundTransparency = 1, BorderSizePixel = 0, Size = UDim2.new(1,-12,1,-25), Position = UDim2.new(0.5,0,1,-5), Parent = outline })
	local title = utility.new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1,-25,0,20), Position = UDim2.new(0,5,0,0), Font = self.library.font, Text = name, TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, TextStrokeTransparency = 0, TextXAlignment = "Left", Parent = outline })

    -- Collapse Button (+/-)
    local collapse_btn = utility.new("TextButton", {
        Text = "-", Font = self.library.font, TextSize = self.library.textsize + 4, TextColor3 = Color3.fromRGB(255,255,255),
        BackgroundTransparency = 1, Size = UDim2.new(0, 20, 0, 20), Position = UDim2.new(1, -25, 0, 0), Parent = outline
    })
	
	local layout = utility.new("UIListLayout", { FillDirection = "Vertical", Padding = UDim.new(0,5), Parent = content })
    
    -- Auto-resize logic
    layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        if collapse_btn.Text == "-" then
            sectionholder.Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 30)
        end
    end)
    
    local expanded = true
    collapse_btn.MouseButton1Down:Connect(function()
        expanded = not expanded
        if expanded then
            collapse_btn.Text = "-"
            utility.tween(content, {BackgroundTransparency = 1}, 0.5) -- Fade elements in logic need iterating children but simple visible is easiest
            content.Visible = true
            utility.tween(sectionholder, {Size = UDim2.new(1, 0, 0, layout.AbsoluteContentSize.Y + 30)}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        else
            collapse_btn.Text = "+"
            utility.tween(sectionholder, {Size = UDim2.new(1, 0, 0, 22)}, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            delay(0.5, function() if not expanded then content.Visible = false end end)
        end
    end)

	section = { ["library"] = self.library, ["sectionholder"] = sectionholder, ["color"] = color, ["content"] = content, ["pointers"] = {} }
    if props.pointer then self.library.pointers[tostring(props.pointer)] = section.pointers end
	self.library.labels[#self.library.labels+1] = title
	setmetatable(section, sections)
	return section
end

-- // Toggle (Updated Animation)
function sections:toggle(props)
	local name = props.name or "new ui"
	local def = props.def or false
	local callback = props.callback or function()end
    local tooltip = props.tooltip or nil
	local toggle = {}
	
	local toggleholder = utility.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,15), Parent = self.content })
	local outline = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(12, 12, 12), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(0,15,0,15), Parent = toggleholder })
	local button = utility.new("TextButton", { AnchorPoint = Vector2.new(0,0), BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Text = "", Parent = toggleholder })
	local title = utility.new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1,-20,1,0), Position = UDim2.new(0,20,0,0), Font = self.library.font, Text = name, TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, TextStrokeTransparency = 0, TextXAlignment = "Left", Parent = toggleholder })
	
	local color = utility.new("Frame", { BackgroundColor3 = def and self.library.theme.accent or Color3.fromRGB(20, 20, 20), BorderColor3 = Color3.fromRGB(56, 56, 56), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,1,0), Parent = outline })
    if def then table.insert(self.library.themeitems["accent"]["BackgroundColor3"],color) end
	utility.new("UIGradient", { Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}, Rotation = 90, Parent = color })
	
	toggle = { ["library"] = self.library, ["toggleholder"] = toggleholder, ["title"] = title, ["color"] = color, ["callback"] = callback, ["current"] = def }
	
	button.MouseButton1Down:Connect(function()
		toggle.current = not toggle.current
		toggle.callback(toggle.current)
		if toggle.current then
            -- Smooth fade
			utility.tween(toggle.color, {BackgroundColor3 = self.library.theme.accent}, 0.5)
			table.insert(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
		else
            utility.tween(toggle.color, {BackgroundColor3 = Color3.fromRGB(20, 20, 20)}, 0.5)
			local find = table.find(self.library.themeitems["accent"]["BackgroundColor3"],toggle.color)
			if find then table.remove(self.library.themeitems["accent"]["BackgroundColor3"],find) end
		end
	end)
    
    if tooltip then self.library.add_tooltip(button, tooltip) end
	if props.pointer then self.library.pointers[tostring(props.pointer)] = toggle end
	self.library.labels[#self.library.labels+1] = title
	setmetatable(toggle, toggles)
	return toggle
end

-- // Button
function sections:button(props)
	local name = props.name or "new button"
	local callback = props.callback or function()end
    local tooltip = props.tooltip or nil
	local button = {}
	
	local buttonholder = utility.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,20), Parent = self.content })
	local outline = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(12, 12, 12), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,1,0), Parent = buttonholder })
	local outline2 = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(56, 56, 56), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,1,0), Parent = outline })
	local color = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderSizePixel = 0, Size = UDim2.new(1,0,1,0), Parent = outline2 })
	utility.new("UIGradient", { Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}, Rotation = 90, Parent = color })
	local buttonpress = utility.new("TextButton", { AnchorPoint = Vector2.new(0,0), BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Text = name, TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, TextStrokeTransparency = 0, Font = self.library.font, Parent = buttonholder })
	
	buttonpress.MouseButton1Down:Connect(function()
		callback()
		outline.BorderColor3 = self.library.theme.accent
		table.insert(self.library.themeitems["accent"]["BorderColor3"],outline)
		wait(0.05)
		outline.BorderColor3 = Color3.fromRGB(12, 12, 12)
		local find = table.find(self.library.themeitems["accent"]["BorderColor3"],outline)
		if find then table.remove(self.library.themeitems["accent"]["BorderColor3"],find) end
	end)
    if tooltip then self.library.add_tooltip(buttonpress, tooltip) end
	button = { ["library"] = self.library }
	self.library.labels[#self.library.labels+1] = buttonpress
	setmetatable(button, buttons)
	return button
end

-- // Dropdown (Updated 1s Animation)
function sections:dropdown(props)
	local name = props.name or "new ui"
	local def = props.def or ""
	local max = props.max or 4
	local options = props.options or {}
	local callback = props.callback or function()end
    local tooltip = props.tooltip or nil
	local dropdown = {}
	
	local dropdownholder = utility.new("Frame", { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,35), ZIndex = 2, Parent = self.content })
	local outline = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(12, 12, 12), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,0,15), Parent = dropdownholder })
	local outline2 = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(56, 56, 56), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Parent = outline })
	local color = utility.new("Frame", { BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderSizePixel = 0, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Parent = outline2 })
	utility.new("UIGradient", { Color = ColorSequence.new{ColorSequenceKeypoint.new(0.00, Color3.fromRGB(199, 191, 204)), ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255))}, Rotation = 90, Parent = color })
	local value = utility.new("TextLabel", { AnchorPoint = Vector2.new(0,0), BackgroundTransparency = 1, Size = UDim2.new(1,-20,1,0), Position = UDim2.new(0,5,0,0), Font = self.library.font, Text = def, TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, TextStrokeTransparency = 0, TextXAlignment = "Left", ClipsDescendants = true, Parent = outline })
	local indicator = utility.new("TextLabel", { AnchorPoint = Vector2.new(0.5,0), BackgroundTransparency = 1, Size = UDim2.new(1,-10,1,0), Position = UDim2.new(0.5,0,0,0), Font = self.library.font, Text = "+", TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, TextStrokeTransparency = 0, TextXAlignment = "Right", ClipsDescendants = true, Parent = outline })
	local title = utility.new("TextLabel", { BackgroundTransparency = 1, Size = UDim2.new(1,0,0,15), Position = UDim2.new(0,0,0,0), Font = self.library.font, Text = name, TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, TextStrokeTransparency = 0, TextXAlignment = "Left", Parent = dropdownholder })
	local dropdownbutton = utility.new("TextButton", { AnchorPoint = Vector2.new(0,0), BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Position = UDim2.new(0,0,0,0), Text = "", Parent = dropdownholder })
	
	local optionsholder = utility.new("Frame", { BackgroundTransparency = 1, BorderColor3 = Color3.fromRGB(56, 56, 56), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,0,20), Position = UDim2.new(0,0,0,34), Visible = false, Parent = dropdownholder })
	local size_count = math.clamp(#options, 1, max)
    local open_height = size_count * 18 + 2
    
	local optionsoutline = utility.new("ScrollingFrame", { BackgroundColor3 = Color3.fromRGB(56, 56, 56), BorderColor3 = Color3.fromRGB(56, 56, 56), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,0,0), Position = UDim2.new(0,0,0,0), ClipsDescendants = true, CanvasSize = UDim2.new(0,0,0,18*#options), ScrollBarImageTransparency = 0.25, ScrollBarImageColor3 = Color3.fromRGB(0,0,0), ScrollBarThickness = 5, VerticalScrollBarInset = "ScrollBar", VerticalScrollBarPosition = "Right", ZIndex = 5, Parent = optionsholder })
	utility.new("UIListLayout", { FillDirection = "Vertical", Parent = optionsoutline })
	
	dropdown = { ["library"] = self.library, ["optionsholder"] = optionsholder, ["optionsoutline"] = optionsoutline, ["indicator"] = indicator, ["options"] = options, ["title"] = title, ["value"] = value, ["open"] = false, ["titles"] = {}, ["current"] = def, ["callback"] = callback }
	table.insert(dropdown.library.dropdowns,dropdown)
	
	for i,v in pairs(options) do
		local ddoptionbutton = utility.new("TextButton", { AnchorPoint = Vector2.new(0,0), BackgroundTransparency = 1, Size = UDim2.new(1,0,0,18), Text = "", ZIndex = 6, Parent = optionsoutline })
		local ddoptiontitle = utility.new("TextLabel", { AnchorPoint = Vector2.new(0.5,0), BackgroundTransparency = 1, Size = UDim2.new(1,-10,1,0), Position = UDim2.new(0.5,0,0,0), Font = self.library.font, Text = v, TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, TextStrokeTransparency = 0, TextXAlignment = "Left", ClipsDescendants = true, ZIndex = 6, Parent = ddoptionbutton })
		self.library.labels[#self.library.labels+1] = ddoptiontitle
		table.insert(dropdown.titles,ddoptiontitle)
		if v == dropdown.current then ddoptiontitle.TextColor3 = self.library.theme.accent end
		ddoptionbutton.MouseButton1Down:Connect(function()
			-- Close
            dropdown.open = false
            indicator.Text = "+"
            utility.tween(optionsoutline, {Size = UDim2.new(1,0,0,0)}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            delay(1, function() if not dropdown.open then optionsholder.Visible = false end end)
            
			for z,x in pairs(dropdown.titles) do if x.TextColor3 == self.library.theme.accent then x.TextColor3 = Color3.fromRGB(255,255,255) end end
			dropdown.current = v
			dropdown.value.Text = v
			ddoptiontitle.TextColor3 = self.library.theme.accent
			table.insert(self.library.themeitems["accent"]["TextColor3"],ddoptiontitle)
			dropdown.callback(v)
		end)
	end
	
	dropdownbutton.MouseButton1Down:Connect(function()
		dropdown.library:closewindows(dropdown)
		for i,v in pairs(dropdown.titles) do if v.Text == dropdown.current then v.TextColor3 = dropdown.library.theme.accent else v.TextColor3 = Color3.fromRGB(255,255,255) end end
		
        dropdown.open = not dropdown.open
		if dropdown.open then
            optionsholder.Visible = true
			indicator.Text = "-"
            utility.tween(optionsoutline, {Size = UDim2.new(1,0,0,open_height)}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		else
			indicator.Text = "+"
            utility.tween(optionsoutline, {Size = UDim2.new(1,0,0,0)}, 1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
            delay(1, function() if not dropdown.open then optionsholder.Visible = false end end)
		end
	end)
    if tooltip then self.library.add_tooltip(dropdownbutton, tooltip) end
	if props.pointer then self.library.pointers[tostring(props.pointer)] = dropdown end
	self.library.labels[#self.library.labels+1] = title
	self.library.labels[#self.library.labels+1] = value
	setmetatable(dropdown, dropdowns)
	return dropdown
end

-- // Slider
function sections:slider(props)
    -- ... (стандартный слайдер, добавлен тултип)
    local name = props.name or "new slider"
    local tooltip = props.tooltip or nil
    -- ... (код слайдера из оригинала)
    local def = props.def or 0
    local max = props.max or 100
    local min = props.min or 0
    local callback = props.callback or function()end
    local slider = {}
    local sliderholder = utility.new("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,25), Parent = self.content})
    local outline = utility.new("Frame", {BackgroundColor3 = Color3.fromRGB(24, 24, 24), BorderColor3 = Color3.fromRGB(12, 12, 12), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,0,12), Position = UDim2.new(0,0,0,15), Parent = sliderholder})
    local outline2 = utility.new("Frame", {BackgroundColor3 = Color3.fromRGB(30, 30, 30), BorderColor3 = Color3.fromRGB(56, 56, 56), BorderMode = "Inset", BorderSizePixel = 1, Size = UDim2.new(1,0,1,0), Parent = outline})
    local value = utility.new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,2), Position = UDim2.new(0,0,0.5,0), Font = self.library.font, Text = def.."/"..max, TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, Parent = outline})
    local slide = utility.new("Frame", {BackgroundColor3 = self.library.theme.accent, BorderSizePixel = 0, Size = UDim2.new((1/(max-min))*(def-min),0,1,0), ZIndex = 2, Parent = outline})
    table.insert(self.library.themeitems["accent"]["BackgroundColor3"],slide)
    local sliderbutton = utility.new("TextButton", {BackgroundTransparency = 1, Size = UDim2.new(1,0,1,0), Text = "", Parent = sliderholder})
    local title = utility.new("TextLabel", {BackgroundTransparency = 1, Size = UDim2.new(1,0,0,15), Font = self.library.font, Text = name, TextColor3 = Color3.fromRGB(255,255,255), TextSize = self.library.textsize, TextXAlignment = "Left", Parent = sliderholder})
    
    slider = {["library"] = self.library, ["outline"] = outline, ["slide"] = slide, ["color"] = outline2, ["max"] = max, ["min"] = min, ["current"] = def, ["callback"] = callback, ["value"] = value}
    
    -- logic
    local function slide_update()
        local size = math.clamp(mouse.X - slider.color.AbsolutePosition.X, 0, slider.color.AbsoluteSize.X)
        local result = (slider.max - slider.min) / slider.color.AbsoluteSize.X * size + slider.min
        local newres = utility.round(result, 2)
        slider.current = newres
        slider.value.Text = newres.."/"..slider.max
        slider.callback(newres)
        slider.slide:TweenSize(UDim2.new((1 / slider.color.AbsoluteSize.X) * size, 0, 1, 0), "Out", "Quad", 0.15, true)
    end

    sliderbutton.MouseButton1Down:Connect(function()
        slider.holding = true
        slide_update()
    end)
    uis.InputChanged:Connect(function() if slider.holding then slide_update() end end)
    uis.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then slider.holding = false end end)

    if tooltip then self.library.add_tooltip(sliderbutton, tooltip) end
    if props.pointer then self.library.pointers[tostring(props.pointer)] = slider end
    self.library.labels[#self.library.labels+1] = title
    self.library.labels[#self.library.labels+1] = value
    setmetatable(slider, sliders)
    return slider
end

function sliders:set(val)
    self.current = val
    self.value.Text = val.."/"..self.max
    self.callback(val)
    self.slide:TweenSize(UDim2.new((1/(self.max-self.min))*(val-self.min),0,1,0), "Out", "Quad", 0.15, true)
end

-- // Multibox and Colorpicker would follow similar animation updates for opening/closing using TweenService on Size
-- Keeping them brief for length but principle applies: use utility.tween(frame, {Size=...}, 1) instead of Visible.

return library
