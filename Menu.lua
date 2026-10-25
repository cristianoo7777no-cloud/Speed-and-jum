-- Speed and Jump Button Menu
-- Roblox - interfaz móvil

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = CoreGui:FindFirstChild("SpeedJumpMenu")
if old then old:Destroy() end

local speed = 16
local jumpSize = 60
local jumpX, jumpY = 0.85, 0.75
local locked = false

local gui = Instance.new("ScreenGui")
gui.Name = "SpeedJumpMenu"
gui.ResetOnSpawn = false
gui.Parent = CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.fromOffset(245, 310)
frame.Position = UDim2.new(0.5, -122, 0.35, 0)
frame.BackgroundColor3 = Color3.fromRGB(24, 24, 32)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true
frame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 12)
corner.Parent = frame

local function label(text, y)
    local l = Instance.new("TextLabel")
    l.Size = UDim2.new(1, -16, 0, 28)
    l.Position = UDim2.fromOffset(8, y)
    l.BackgroundTransparency = 1
    l.Text = text
    l.TextColor3 = Color3.new(1, 1, 1)
    l.TextScaled = true
    l.Font = Enum.Font.GothamBold
    l.Parent = frame
    return l
end

local function button(text, x, y, w, callback)
    local b = Instance.new("TextButton")
    b.Size = UDim2.fromOffset(w, 34)
    b.Position = UDim2.fromOffset(x, y)
    b.BackgroundColor3 = Color3.fromRGB(65, 85, 170)
    b.TextColor3 = Color3.new(1, 1, 1)
    b.TextScaled = true
    b.Font = Enum.Font.GothamBold
    b.Text = text
    b.Parent = frame

    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, 7)
    c.Parent = b

    b.Activated:Connect(callback)
    return b
end

local function setSpeed(value)
    speed = math.clamp(value, 0, 250)
    local char = player.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    if hum then hum.WalkSpeed = speed end
    speedLabel.Text = "Velocidad: " .. speed
end

local function getJumpButton()
    local pg = player:FindFirstChild("PlayerGui")
    local touch = pg and pg:FindFirstChild("TouchGui")
    local frame2 = touch and touch:FindFirstChild("TouchControlFrame")
    return frame2 and frame2:FindFirstChild("JumpButton", true)
end

local function updateJump()
    local b = getJumpButton()
    if not b then return end

    b.Size = UDim2.fromOffset(jumpSize, jumpSize)
    b.Position = UDim2.new(jumpX, -jumpSize / 2, jumpY, -jumpSize / 2)
end

label("SPEED + JUMP MENU", 8)

local speedLabel = label("Velocidad: " .. speed, 42)
button("−", 22, 75, 90, function()
    setSpeed(speed - 5)
end)
button("+", 133, 75, 90, function()
    setSpeed(speed + 5)
end)

label("TAMAÑO DEL BOTÓN DE SALTO", 115)
local sizeLabel = label("Tamaño: " .. jumpSize, 145)

button("−", 22, 178, 90, function()
    jumpSize = math.clamp(jumpSize - 10, 30, 150)
    sizeLabel.Text = "Tamaño: " .. jumpSize
    updateJump()
end)

button("+", 133, 178, 90, function()
    jumpSize = math.clamp(jumpSize + 10, 30, 150)
    sizeLabel.Text = "Tamaño: " .. jumpSize
    updateJump()
end)

button("MOVER ←", 22, 220, 90, function()
    jumpX = math.clamp(jumpX - 0.03, 0.05, 0.95)
    updateJump()
end)

button("MOVER →", 133, 220, 90, function()
    jumpX = math.clamp(jumpX + 0.03, 0.05, 0.95)
    updateJump()
end)

local lockButton
lockButton = button("BLOQUEAR", 22, 263, 201, function()
    locked = not locked
    frame.Draggable = not locked
    lockButton.Text = locked and "DESBLOQUEAR" or "BLOQUEAR"
end)

player.CharacterAdded:Connect(function(char)
    local hum = char:WaitForChild("Humanoid")
    task.wait(1)
    hum.WalkSpeed = speed
    updateJump()
end)

task.spawn(function()
    while gui.Parent do
        task.wait(2)
        updateJump()
    end
end)

setSpeed(speed)
updateJump()
