--[[
    auto event
    Премиум-меню (тёмно-серый, острые углы)
    Открытие/закрытие: Insert
    Функции:
      - Test Feature      (On/Off)
      - level 1           (3 телепорта, интервал 6 сек)
      - level 2           (2 телепорта, интервал 6 сек)
      - level 3           (1 телепорт)
      - level 4           (2 телепорта, интервал 6 сек)
      - level 5           (1 телепорт)
      - level 6           (1 телепорт)
      - level 7           (1 телепорт)
      - level 8           (2 телепорта, интервал 6 сек)
      - DestroyGUI        (полное отключение всего)
--]]

if _G.AutoEventMenuLoaded then
    pcall(function() _G.AutoEventDestroy() end)
end
_G.AutoEventMenuLoaded = true

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local GUI_OBJECTS = {}
local ACTIVE_FUNCTIONS = {}
local CLEANUP_CALLBACKS = {}
local destroyed = false

local function track(obj)
    table.insert(GUI_OBJECTS, obj)
    return obj
end

--------------------------------------------------------------------
-- Палитра
--------------------------------------------------------------------
local COLORS = {
    Background     = Color3.fromRGB(28, 28, 30),
    TopBar         = Color3.fromRGB(20, 20, 22),
    Panel          = Color3.fromRGB(38, 38, 41),
    PanelHover     = Color3.fromRGB(48, 48, 52),
    Stroke         = Color3.fromRGB(60, 60, 64),
    Accent         = Color3.fromRGB(0, 170, 255),
    AccentOff      = Color3.fromRGB(70, 70, 74),
    TextPrimary    = Color3.fromRGB(235, 235, 240),
    TextSecondary  = Color3.fromRGB(150, 150, 158),
    Danger         = Color3.fromRGB(200, 60, 60),
    DangerHover    = Color3.fromRGB(230, 80, 80),
}

local function new(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props or {}) do
        obj[k] = v
    end
    return obj
end

local function stroke(parent, color, thickness)
    return new("UIStroke", {
        Parent = parent,
        Color = color or COLORS.Stroke,
        Thickness = thickness or 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
    })
end

--------------------------------------------------------------------
-- ScreenGui
--------------------------------------------------------------------
local screenGui = new("ScreenGui", {
    Name = "AutoEventMenu",
    ResetOnSpawn = false,
    IgnoreGuiInset = true,
    ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
    Parent = playerGui,
})
track(screenGui)

--------------------------------------------------------------------
-- Главное окно
--------------------------------------------------------------------
local main = new("Frame", {
    Name = "Main",
    Parent = screenGui,
    Size = UDim2.fromOffset(340, 520),
    Position = UDim2.new(0.5, -170, 0.5, -260),
    BackgroundColor3 = COLORS.Background,
    BorderSizePixel = 0,
    Active = true,
    ClipsDescendants = true,
})
track(main)
stroke(main, COLORS.Stroke, 1)

track(new("Frame", {
    Parent = main,
    Size = UDim2.new(1, 0, 0, 2),
    BackgroundColor3 = COLORS.Accent,
    BorderSizePixel = 0,
}))

--------------------------------------------------------------------
-- Верхняя панель
--------------------------------------------------------------------
local topBar = new("Frame", {
    Name = "TopBar",
    Parent = main,
    Size = UDim2.new(1, 0, 0, 36),
    BackgroundColor3 = COLORS.TopBar,
    BorderSizePixel = 0,
})
track(topBar)

track(new("TextLabel", {
    Parent = topBar,
    Size = UDim2.new(1, -80, 1, 0),
    Position = UDim2.fromOffset(12, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.GothamBold,
    Text = "auto event",
    TextSize = 15,
    TextColor3 = COLORS.TextPrimary,
    TextXAlignment = Enum.TextXAlignment.Left,
}))

local statusLabel = new("TextLabel", {
    Parent = topBar,
    Size = UDim2.fromOffset(68, 36),
    Position = UDim2.new(1, -76, 0, 0),
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    Text = "IDLE",
    TextSize = 11,
    TextColor3 = COLORS.TextSecondary,
    TextXAlignment = Enum.TextXAlignment.Right,
})
track(statusLabel)

--------------------------------------------------------------------
-- Контент
--------------------------------------------------------------------
local content = new("ScrollingFrame", {
    Name = "Content",
    Parent = main,
    Position = UDim2.fromOffset(0, 36),
    Size = UDim2.new(1, 0, 1, -36 - 44),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    CanvasSize = UDim2.new(0, 0, 0, 0),
    AutomaticCanvasSize = Enum.AutomaticSize.Y,
    ScrollBarThickness = 4,
    ScrollBarImageColor3 = COLORS.Stroke,
})
track(content)

track(new("UIListLayout", {
    Parent = content,
    Padding = UDim.new(0, 8),
    SortOrder = Enum.SortOrder.LayoutOrder,
}))

track(new("UIPadding", {
    Parent = content,
    PaddingTop = UDim.new(0, 10),
    PaddingLeft = UDim.new(0, 10),
    PaddingRight = UDim.new(0, 10),
    PaddingBottom = UDim.new(0, 10),
}))

--------------------------------------------------------------------
-- Нижняя панель
--------------------------------------------------------------------
local bottomBar = new("Frame", {
    Name = "BottomBar",
    Parent = main,
    Size = UDim2.new(1, 0, 0, 44),
    Position = UDim2.new(0, 0, 1, -44),
    BackgroundColor3 = COLORS.TopBar,
    BorderSizePixel = 0,
})
track(bottomBar)
stroke(bottomBar, COLORS.Stroke, 1)

--------------------------------------------------------------------
-- Фабрика переключателей
--------------------------------------------------------------------
local function createToggle(name, description, onEnable, onDisable)
    local card = new("Frame", {
        Name = name,
        Parent = content,
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundColor3 = COLORS.Panel,
        BorderSizePixel = 0,
    })
    track(card)
    stroke(card, COLORS.Stroke, 1)

    track(new("TextLabel", {
        Parent = card,
        Position = UDim2.fromOffset(12, 10),
        Size = UDim2.new(1, -100, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = name,
        TextSize = 14,
        TextColor3 = COLORS.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
    }))

    track(new("TextLabel", {
        Parent = card,
        Position = UDim2.fromOffset(12, 32),
        Size = UDim2.new(1, -100, 0, 24),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = description,
        TextSize = 11,
        TextWrapped = true,
        TextColor3 = COLORS.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }))

    local switch = new("TextButton", {
        Parent = card,
        Size = UDim2.fromOffset(64, 28),
        Position = UDim2.new(1, -76, 0.5, -14),
        BackgroundColor3 = COLORS.AccentOff,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = "OFF",
        TextSize = 12,
        TextColor3 = COLORS.TextPrimary,
    })
    track(switch)
    local switchStroke = stroke(switch, COLORS.Stroke, 1)

    local state = false
    ACTIVE_FUNCTIONS[name] = false

    local function applyVisual()
        if state then
            switch.BackgroundColor3 = COLORS.Accent
            switch.Text = "ON"
            switchStroke.Color = COLORS.Accent
            card.BackgroundColor3 = COLORS.PanelHover
        else
            switch.BackgroundColor3 = COLORS.AccentOff
            switch.Text = "OFF"
            switchStroke.Color = COLORS.Stroke
            card.BackgroundColor3 = COLORS.Panel
        end
    end

    local function setState(newState, silent)
        state = newState
        ACTIVE_FUNCTIONS[name] = state
        applyVisual()
        if not silent then
            if state then
                if onEnable then task.spawn(onEnable) end
            else
                if onDisable then task.spawn(onDisable) end
            end
        end
    end

    switch.MouseButton1Click:Connect(function()
        if destroyed then return end
        setState(not state)
    end)
    switch.MouseEnter:Connect(function()
        if not state then switch.BackgroundColor3 = COLORS.PanelHover end
    end)
    switch.MouseLeave:Connect(function() applyVisual() end)

    applyVisual()
    return { SetState = setState, GetState = function() return state end, Frame = card }
end

--------------------------------------------------------------------
-- Фабрика кнопок-действий
--------------------------------------------------------------------
local function createActionButton(name, description, onClick)
    local card = new("Frame", {
        Name = name,
        Parent = content,
        Size = UDim2.new(1, 0, 0, 66),
        BackgroundColor3 = COLORS.Panel,
        BorderSizePixel = 0,
    })
    track(card)
    stroke(card, COLORS.Stroke, 1)

    track(new("TextLabel", {
        Parent = card,
        Position = UDim2.fromOffset(12, 10),
        Size = UDim2.new(1, -100, 0, 18),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = name,
        TextSize = 14,
        TextColor3 = COLORS.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
    }))

    track(new("TextLabel", {
        Parent = card,
        Position = UDim2.fromOffset(12, 32),
        Size = UDim2.new(1, -100, 0, 24),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = description,
        TextSize = 11,
        TextWrapped = true,
        TextColor3 = COLORS.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
    }))

    local btn = new("TextButton", {
        Parent = card,
        Size = UDim2.fromOffset(64, 28),
        Position = UDim2.new(1, -76, 0.5, -14),
        BackgroundColor3 = COLORS.Accent,
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Font = Enum.Font.GothamBold,
        Text = "GO",
        TextSize = 12,
        TextColor3 = COLORS.TextPrimary,
    })
    track(btn)
    local btnStroke = stroke(btn, COLORS.Accent, 1)

    btn.MouseEnter:Connect(function()
        btn.BackgroundColor3 = COLORS.PanelHover
        btnStroke.Color = COLORS.Accent
    end)
    btn.MouseLeave:Connect(function()
        btn.BackgroundColor3 = COLORS.Accent
        btnStroke.Color = COLORS.Accent
    end)

    btn.MouseButton1Click:Connect(function()
        if destroyed then return end
        if onClick then task.spawn(onClick) end
    end)

    return { Frame = card, Button = btn }
end

--------------------------------------------------------------------
-- Движок последовательности телепортов
--------------------------------------------------------------------
local function startTeleportSequence(points, tag, guard)
    if destroyed then return guard end
    if guard.active then return guard end
    guard.active = true
    guard.cancel = false

    guard.thread = task.spawn(function()
        for i, cf in ipairs(points) do
            if guard.cancel or destroyed then break end

            local char = player.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then
                statusLabel.Text = "NO CHAR"
                statusLabel.TextColor3 = COLORS.Danger
                break
            end

            hrp.CFrame = cf
            statusLabel.Text = tag .. " " .. i .. "/" .. #points
            statusLabel.TextColor3 = COLORS.Accent

            if i < #points then
                local waited = 0
                while waited < 6 do
                    if guard.cancel or destroyed then break end
                    task.wait(0.1)
                    waited += 0.1
                end
            end
        end

        if not destroyed then
            statusLabel.Text = "IDLE"
            statusLabel.TextColor3 = COLORS.TextSecondary
        end
        guard.active = false
    end)

    return guard
end

--------------------------------------------------------------------
-- ТЕСТОВАЯ функция
--------------------------------------------------------------------
local testConn
local function testOnEnable()
    if destroyed then return end
    statusLabel.Text = "ACTIVE"
    statusLabel.TextColor3 = COLORS.Accent
    if testConn then testConn:Disconnect() end
    testConn = RunService.Heartbeat:Connect(function()
        if destroyed then return end
        local char = player.Character
        if char then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp:FindFirstChild("TestHighlight") == nil then
                local hl = Instance.new("Highlight")
                hl.Name = "TestHighlight"
                hl.FillColor = COLORS.Accent
                hl.FillTransparency = 0.7
                hl.OutlineColor = COLORS.Accent
                hl.Parent = char
            end
        end
    end)
end

local function testOnDisable()
    statusLabel.Text = "IDLE"
    statusLabel.TextColor3 = COLORS.TextSecondary
    if testConn then testConn:Disconnect(); testConn = nil end
    local char = player.Character
    if char then
        local hl = char:FindFirstChild("TestHighlight")
        if hl then hl:Destroy() end
    end
end

table.insert(CLEANUP_CALLBACKS, testOnDisable)

local testToggle = createToggle(
    "Test Feature",
    "Тестовая функция. Включает подсветку персонажа.",
    testOnEnable,
    testOnDisable
)
table.insert(CLEANUP_CALLBACKS, function()
    testToggle.SetState(false, true)
end)

--------------------------------------------------------------------
-- level 1 — 3 телепорта, интервал 6 сек
--------------------------------------------------------------------
local level1Points = {
    CFrame.new(-167.836838, 6.36136961, 13.3791351) * CFrame.Angles(0, 0, 0),
    CFrame.new(93.5000763, 7.49148798, -114.51683) * CFrame.Angles(0, 0, 0),
    CFrame.new(-163.539551, 5.98544455, -124.390968) * CFrame.Angles(0, 0, 0),
}
local level1Guard = { active = false, cancel = false, thread = nil }

createActionButton(
    "level 1",
    "Последовательность из 3 телепортов с интервалом 6 секунд.",
    function() startTeleportSequence(level1Points, "L1", level1Guard) end
)

table.insert(CLEANUP_CALLBACKS, function()
    level1Guard.cancel = true
    level1Guard.active = false
    if level1Guard.thread then
        pcall(function() task.cancel(level1Guard.thread) end)
        level1Guard.thread = nil
    end
end)

--------------------------------------------------------------------
-- level 2 — 2 телепорта, интервал 6 сек
--------------------------------------------------------------------
local level2Points = {
    CFrame.new(
        -141.585373, 3.82585669, 37.8057709,
        -0.375183344, 0, -0.926950634,
         0,           1,  0,
         0.926950634, 0, -0.375183344
    ),
    CFrame.new(
        -244.949997, 6.50000095, -147.5,
         1, 0, 0,
         0, 1, 0,
         0, 0, 1
    ),
}
local level2Guard = { active = false, cancel = false, thread = nil }

createActionButton(
    "level 2",
    "Два телепорта с интервалом 6 секунд. Первая точка с поворотом, вторая — без.",
    function() startTeleportSequence(level2Points, "L2", level2Guard) end
)

table.insert(CLEANUP_CALLBACKS, function()
    level2Guard.cancel = true
    level2Guard.active = false
    if level2Guard.thread then
        pcall(function() task.cancel(level2Guard.thread) end)
        level2Guard.thread = nil
    end
end)

--------------------------------------------------------------------
-- level 3 — одиночный телепорт
--------------------------------------------------------------------
local level3Points = {
    CFrame.new(
        -0.300000012, -159.895004, 352.5,
         1, 0, 0,
         0, 1, 0,
         0, 0, 1
    ),
}
local level3Guard = { active = false, cancel = false, thread = nil }

createActionButton(
    "level 3",
    "Одиночный телепорт в точку уровня 3.",
    function() startTeleportSequence(level3Points, "L3", level3Guard) end
)

table.insert(CLEANUP_CALLBACKS, function()
    level3Guard.cancel = true
    level3Guard.active = false
    if level3Guard.thread then
        pcall(function() task.cancel(level3Guard.thread) end)
        level3Guard.thread = nil
    end
end)

--------------------------------------------------------------------
-- level 4 — 2 телепорта, интервал 6 сек
--------------------------------------------------------------------
local level4Points = {
    CFrame.new(
        -29.394577, 0.932749748, 207.709,
        -2.05039978e-05, -0.5,          -0.866025329,
         1,               4.05311584e-05, -4.70876694e-05,
         5.86211681e-05, -0.866025388,   0.5
    ),
    CFrame.new(
        -414.799988, 6.70001316, -137.499985,
         1, 0, 0,
         0, 1, 0,
         0, 0, 1
    ),
}
local level4Guard = { active = false, cancel = false, thread = nil }

createActionButton(
    "level 4",
    "Два телепорта с интервалом 6 секунд. Первая точка с поворотом, вторая — без.",
    function() startTeleportSequence(level4Points, "L4", level4Guard) end
)

table.insert(CLEANUP_CALLBACKS, function()
    level4Guard.cancel = true
    level4Guard.active = false
    if level4Guard.thread then
        pcall(function() task.cancel(level4Guard.thread) end)
        level4Guard.thread = nil
    end
end)

--------------------------------------------------------------------
-- level 5 — одиночный телепорт
--------------------------------------------------------------------
local level5Points = {
    CFrame.new(
        -633.229126, 565.200012, 186.499985,
         1, 0, 0,
         0, 1, 0,
         0, 0, 1
    ),
}
local level5Guard = { active = false, cancel = false, thread = nil }

createActionButton(
    "level 5",
    "Одиночный телепорт в точку уровня 5.",
    function() startTeleportSequence(level5Points, "L5", level5Guard) end
)

table.insert(CLEANUP_CALLBACKS, function()
    level5Guard.cancel = true
    level5Guard.active = false
    if level5Guard.thread then
        pcall(function() task.cancel(level5Guard.thread) end)
        level5Guard.thread = nil
    end
end)

--------------------------------------------------------------------
-- level 6 — одиночный телепорт
--------------------------------------------------------------------
local level6Points = {
    CFrame.new(
        12.6737003, 43.5250168, 339.024658,
         1, 0, 0,
         0, 1, 0,
         0, 0, 1
    ),
}
local level6Guard = { active = false, cancel = false, thread = nil }

createActionButton(
    "level 6",
    "Одиночный телепорт в точку уровня 6.",
    function() startTeleportSequence(level6Points, "L6", level6Guard) end
)

table.insert(CLEANUP_CALLBACKS, function()
    level6Guard.cancel = true
    level6Guard.active = false
    if level6Guard.thread then
        pcall(function() task.cancel(level6Guard.thread) end)
        level6Guard.thread = nil
    end
end)

--------------------------------------------------------------------
-- level 7 — одиночный телепорт
--------------------------------------------------------------------
local level7Points = {
    CFrame.new(
        -30.2548828, 44.4184265, -167.400009,
         1, 0, 0,
         0, 1, 0,
         0, 0, 1
    ),
}
local level7Guard = { active = false, cancel = false, thread = nil }

createActionButton(
    "level 7",
    "Одиночный телепорт в точку уровня 7.",
    function() startTeleportSequence(level7Points, "L7", level7Guard) end
)

table.insert(CLEANUP_CALLBACKS, function()
    level7Guard.cancel = true
    level7Guard.active = false
    if level7Guard.thread then
        pcall(function() task.cancel(level7Guard.thread) end)
        level7Guard.thread = nil
    end
end)

--------------------------------------------------------------------
-- level 8 — 2 телепорта, интервал 6 сек
--------------------------------------------------------------------
local level8Points = {
    CFrame.new(
        53.1049194, 125.807198, 381.047272,
         1, 0, 0,
         0, 1, 0,
         0, 0, 1
    ),
    CFrame.new(
        -3.39999986, 126.400002, 390.700073,
         1, 0, 0,
         0, 1, 0,
         0, 0, 1
    ),
}
local level8Guard = { active = false, cancel = false, thread = nil }

createActionButton(
    "level 8",
    "Два телепорта с интервалом 6 секунд. Обе точки без поворота.",
    function() startTeleportSequence(level8Points, "L8", level8Guard) end
)

table.insert(CLEANUP_CALLBACKS, function()
    level8Guard.cancel = true
    level8Guard.active = false
    if level8Guard.thread then
        pcall(function() task.cancel(level8Guard.thread) end)
        level8Guard.thread = nil
    end
end)

--------------------------------------------------------------------
-- DestroyGUI
--------------------------------------------------------------------
local destroyBtn = new("TextButton", {
    Name = "DestroyGUI",
    Parent = bottomBar,
    Size = UDim2.new(1, -20, 0, 28),
    Position = UDim2.new(0, 10, 0.5, -14),
    BackgroundColor3 = COLORS.Danger,
    BorderSizePixel = 0,
    AutoButtonColor = false,
    Font = Enum.Font.GothamBold,
    Text = "DestroyGUI",
    TextSize = 13,
    TextColor3 = COLORS.TextPrimary,
})
track(destroyBtn)
local destroyStroke = stroke(destroyBtn, COLORS.Danger, 1)

destroyBtn.MouseEnter:Connect(function()
    destroyBtn.BackgroundColor3 = COLORS.DangerHover
    destroyStroke.Color = COLORS.DangerHover
end)
destroyBtn.MouseLeave:Connect(function()
    destroyBtn.BackgroundColor3 = COLORS.Danger
    destroyStroke.Color = COLORS.Danger
end)

local function destroyAll()
    if destroyed then return end
    destroyed = true

    for _, cb in ipairs(CLEANUP_CALLBACKS) do
        pcall(cb)
    end

    for name in pairs(ACTIVE_FUNCTIONS) do
        ACTIVE_FUNCTIONS[name] = false
    end

    for _, obj in ipairs(GUI_OBJECTS) do
        pcall(function() obj:Destroy() end)
    end

    _G.AutoEventMenuLoaded = false

    if _G.AutoEventToggleConn then
        pcall(function() _G.AutoEventToggleConn:Disconnect() end)
        _G.AutoEventToggleConn = nil
    end
end

_G.AutoEventDestroy = destroyAll

destroyBtn.MouseButton1Click:Connect(destroyAll)

--------------------------------------------------------------------
-- Перетаскивание
--------------------------------------------------------------------
local dragging = false
local dragStart, startPos

topBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = main.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType == Enum.UserInputType.MouseMovement
        or input.UserInputType == Enum.UserInputType.Touch then
        local delta = input.Position - dragStart
        main.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

--------------------------------------------------------------------
-- Insert
--------------------------------------------------------------------
_G.AutoEventToggleConn = UserInputService.InputBegan:Connect(function(input, gp)
    if gp or destroyed then return end
    if input.KeyCode == Enum.KeyCode.Insert then
        main.Visible = not main.Visible
    end
end)

--------------------------------------------------------------------
-- Респавн
--------------------------------------------------------------------
player.CharacterAdded:Connect(function()
    task.wait(1)
    if destroyed then return end
    if ACTIVE_FUNCTIONS["Test Feature"] then
        testOnEnable()
    end
end)
