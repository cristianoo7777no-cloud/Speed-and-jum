-- SPEED + JUMP MENU
-- Minimizar, mover menu, velocidad y salto

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("SpeedJumpMenu")
if old then old:Destroy() end

local speed = 16
local jumpSize = 60
local unlocked = false
local minimized = false
local draggingMenu = false
local menuDragStart
local menuStartPos

local gui = Instance.new("ScreenGui")
gui.Name = "SpeedJumpMenu"
gui.ResetOnSpawn = false
gui.DisplayOrder = 999
gui.Parent = playerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(245, 285)
frame.Position = UDim2.new(0.5, -122, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

-- Barra superior para mover el menu
local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 36)
topBar.BackgroundColor3 = Color3.fromRGB(45, 50, 75)
topBar.BorderSizePixel = 0
topBar.Active = true
topBar.Parent = frame

local topCorner = Instance.new("UICorner")
topCorner.CornerRadius = UDim.new(0, 12)
topCorner.Parent = topBar

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -75, 1, 0)
title.Position = UDim2.fromOffset(8, 0)
title.BackgroundTransparency = 1
title.Text = "SPEED + JUMP"
title.TextColor3 = Color3.new(1, 1, 1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = topBar

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.fromOffset(32, 28)
minimizeButton.Position = UDim2.new(1, -38, 0, 4)
minimizeButton.Text = "−"
minimizeButton.TextScaled = true
minimizeButton.Font = Enum.Font.GothamBold
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.BackgroundColor3 = Color3.fromRGB(75, 90, 145)
minimizeButton.Parent = topBar

local function makeButton(text, x, y, w, parent, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(w, 34)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 = Color3.fromRGB(65, 85, 170)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.Parent = parent

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = b

    b.Activated:Connect(callback)
    return b
end

local function makeLabel(text, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 0, 26)
    l.Position = UDim2.fromOffset(8, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.new(1, 1, 1)
    l.TextScaled = true
    l.Font = Enum.Font.GothamBold
    l.Parent = frame
    return l
end

local speedLabel = makeLabel("Velocidad: 16", 42)
local sizeLabel = makeLabel("Tamaño salto: 60", 145)

local function setSpeed(value)
    speed = math.clamp(value, 0, 250)
    speedLabel.Text = "Velocidad: " .. speed

    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speed end
end

makeButton("- 1", 22, 75, 90, frame, function()
    setSpeed(speed - 1)
end)

makeButton("+ 1", 133, 75, 90, frame, function()
    setSpeed(speed + 1)
end)

makeButton("-", 22, 178, 90, frame, function()
    jumpSize = math.clamp(jumpSize - 5, 30, 150)
    sizeLabel.Text = "Tamaño salto: " .. jumpSize
end)

makeButton("+", 133, 178, 90, frame, function()
    jumpSize = math.clamp(jumpSize + 5, 30, 150)
    sizeLabel.Text = "Tamaño salto: " .. jumpSize
end)

local lockButton
lockButton = makeButton("BLOQUEADO", 22, 225, 201, frame, function()
    unlocked = not unlocked
    lockButton.Text = unlocked and "DESBLOQUEADO" or "BLOQUEADO"
    lockButton.BackgroundColor3 = unlocked
        and Color3.fromRGB(40, 155, 85)
        or Color3.fromRGB(65, 85, 170)
end)

-- Minimizar y restaurar
local function setMinimized(value)
    minimized = value

    for _, child in ipairs(frame:GetChildren()) do
        if child ~= topBar and child ~= corner then
            child.Visible = not minimized
        end
    end

    frame.Size = minimized
        and UDim2.fromOffset(245, 36)
        or UDim2.fromOffset(245, 285)

    minimizeButton.Text = minimized and "+" or "−"
end

minimizeButton.Activated:Connect(function()
    setMinimized(not minimized)
end)

-- Mover menu arrastrando la barra superior
local function beginDrag(input)
    if input.UserInputType ~= Enum.UserInputType.Touch
    and input.UserInputType ~= Enum.UserInputType.MouseButton1 then
        return
    end

    draggingMenu = true
    menuDragStart = input.Position
    menuStartPos = frame.Position
end

topBar.InputBegan:Connect(beginDrag)
title.InputBegan:Connect(beginDrag)

UserInputService.InputChanged:Connect(function(input)
    if not draggingMenu then return end

    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - menuDragStart
        frame.Position = UDim2.new(
            menuStartPos.X.Scale,
            menuStartPos.X.Offset + delta.X,
            menuStartPos.Y.Scale,
            menuStartPos.Y.Offset + delta.Y
        )
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch
    or input.UserInputType == Enum.UserInputType.MouseButton1 then
        draggingMenu = false
    end
end)

-- Boton de salto movil
local function findJumpButton()
    local touchGui = playerGui:FindFirstChild("TouchGui")
    local controls = touchGui and touchGui:FindFirstChild("TouchControlFrame")
    return controls and controls:FindFirstChild("JumpButton", true)
end

local connectedJump

local function setupJump()
    local jump = findJumpButton()
    if not jump then return end

    jump.Size = UDim2.fromOffset(jumpSize, jumpSize)

    if connectedJump == jump then return end
    connectedJump = jump

    local draggingJump = false
    local lastPosition

    jump.InputBegan:Connect(function(input)
        if not unlocked then return end

        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingJump = true
            lastPosition = input.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if not draggingJump or not unlocked then return end

        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - lastPosition
            jump.Position = UDim2.new(
                jump.Position.X.Scale,
                jump.Position.X.Offset + delta.X,
                jump.Position.Y.Scale,
                jump.Position.Y.Offset + delta.Y
            )
            lastPosition = input.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
        or input.UserInputType == Enum.UserInputType.MouseButton1 then
            draggingJump = false
        end
    end)
end

local function onCharacter(char)
