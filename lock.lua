-- FPS Control Panel Script (LocalScript)
-- Author: lao.xiao (revised by ChatGPT)

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Colors
local colors = {
    panel = Color3.fromRGB(40, 40, 40),
    border = Color3.fromRGB(80, 80, 80),
    text = Color3.fromRGB(220, 220, 220),
    title = Color3.fromRGB(255, 255, 255),
    button = Color3.fromRGB(60, 60, 60),
    buttonHover = Color3.fromRGB(80, 80, 80),
    buttonActive = Color3.fromRGB(100, 100, 100),
    green = Color3.fromRGB(0, 200, 100),
    red = Color3.fromRGB(255, 80, 80),
    yellow = Color3.fromRGB(255, 200, 60),
    highlight = Color3.fromRGB(255, 255, 0),
    blue = Color3.fromRGB(100, 100, 255),
}

local font = Enum.Font.Gotham
local fontBold = Enum.Font.GothamBold

-- Create UI function
local function createUI(className, props, parent)
    local obj = Instance.new(className)
    for k,v in pairs(props) do obj[k] = v end
    if parent then obj.Parent = parent end
    return obj
end

-- Create ScreenGui
local screenGui = createUI("ScreenGui", {Name = "FPSControlPanel", ResetOnSpawn = false}, PlayerGui)

-- Main Frame
local frame = createUI("Frame", {
    Size = UDim2.new(0, 300, 0, 320),
    Position = UDim2.new(0, 20, 0, 100),
    BackgroundColor3 = colors.panel,
    BorderSizePixel = 1,
    BorderColor3 = colors.border,
    Active = true,
    Draggable = true,
    Parent = screenGui
})

-- Title Bar
local titleBar = createUI("Frame", {
    Size = UDim2.new(1, 0, 0, 30),
    BackgroundTransparency = 1,
    Parent = frame
})

local title = createUI("TextLabel", {
    Size = UDim2.new(1, -60, 1, 0),
    Position = UDim2.new(0, 5, 0, 0),
    BackgroundTransparency = 1,
    Text = "FPS Control Panel",
    Font = fontBold,
    TextSize = 18,
    TextColor3 = colors.title,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = titleBar
})

local closeButton = createUI("TextButton", {
    Size = UDim2.new(0, 25, 1, 0),
    Position = UDim2.new(1, -30, 0, 0),
    BackgroundColor3 = colors.red,
    Text = "X",
    Font = fontBold,
    TextSize = 14,
    TextColor3 = colors.title,
    Parent = titleBar,
    ZIndex = 5
})

local minimizeButton = createUI("TextButton", {
    Size = UDim2.new(0, 25, 1, 0),
    Position = UDim2.new(1, -60, 0, 0),
    BackgroundColor3 = colors.yellow,
    Text = "-",
    Font = fontBold,
    TextSize = 14,
    TextColor3 = colors.text,
    Parent = titleBar,
    ZIndex = 5
})

-- FPS Limit Label
local sliderLabel = createUI("TextLabel", {
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 0, 40),
    BackgroundTransparency = 1,
    Text = "FPS Limit: 60",
    Font = font,
    TextSize = 14,
    TextColor3 = colors.text,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = frame
})

-- FPS Input TextBox
local slider = createUI("TextBox", {
    Size = UDim2.new(1, -20, 0, 30),
    Position = UDim2.new(0, 10, 0, 70),
    BackgroundColor3 = colors.button,
    BorderSizePixel = 1,
    BorderColor3 = colors.border,
    Text = "60",
    TextColor3 = colors.text,
    Font = font,
    TextSize = 14,
    ClearTextOnFocus = false,
    Parent = frame
})

-- Toggle FPS Lock Button
local toggleButton = createUI("TextButton", {
    Size = UDim2.new(0, 140, 0, 35),
    Position = UDim2.new(0.5, -70, 0, 120),
    BackgroundColor3 = colors.green,
    BorderSizePixel = 1,
    BorderColor3 = colors.border,
    Text = "FPS Lock: OFF",
    TextColor3 = colors.title,
    Font = fontBold,
    TextSize = 16,
    Parent = frame,
    ZIndex = 2
})

-- Apply Button
local applyButton = createUI("TextButton", {
    Size = UDim2.new(0, 140, 0, 35),
    Position = UDim2.new(0.5, -70, 1, -70),
    BackgroundColor3 = colors.button,
    BorderSizePixel = 1,
    BorderColor3 = colors.border,
    Text = "Apply",
    TextColor3 = colors.title,
    Font = fontBold,
    TextSize = 16,
    Parent = frame,
    ZIndex = 2
})

-- FPS Display Label
local fpsLabel = createUI("TextLabel", {
    Size = UDim2.new(1, -20, 0, 20),
    Position = UDim2.new(0, 10, 1, -100),
    BackgroundTransparency = 1,
    Text = "FPS: Measuring...",
    Font = font,
    TextSize = 14,
    TextColor3 = colors.highlight,
    TextXAlignment = Enum.TextXAlignment.Left,
    Parent = frame
})

-- State Variables
local fpsLockEnabled = false
local targetFPS = 60

-- FPS Monitor Variables
local frames = 0
local lastTick = tick()
local desiredFrameTime = 1 / targetFPS

-- FPS Lock Logic (with RenderStepped)
RunService.RenderStepped:Connect(function(delta)
    frames += 1
    if tick() - lastTick >= 1 then
        fpsLabel.Text = "FPS: " .. frames
        frames = 0
        lastTick = tick()
    end

    if fpsLockEnabled then
        desiredFrameTime = 1 / targetFPS
        -- Cek kalau frame terlalu cepat, tunggu sisanya
        if delta < desiredFrameTime then
            local waitTime = desiredFrameTime - delta
            task.wait(waitTime)
        end
    end
end)

-- Button Event Handlers
applyButton.MouseButton1Click:Connect(function()
    local value = tonumber(slider.Text)
    if value and value >= 30 and value <= 240 then
        targetFPS = value
        sliderLabel.Text = "FPS Limit: " .. value
        print("[FPS Control] FPS Limit set to: " .. value)
    else
        sliderLabel.Text = "FPS Limit: Invalid (30-240)"
        warn("[FPS Control] Invalid FPS limit entered!")
    end
end)

toggleButton.MouseButton1Click:Connect(function()
    fpsLockEnabled = not fpsLockEnabled
    toggleButton.Text = "FPS Lock: " .. (fpsLockEnabled and "ON" or "OFF")
    toggleButton.BackgroundColor3 = fpsLockEnabled and colors.red or colors.green
    print("[FPS Control] FPS Lock: " .. (fpsLockEnabled and "ON" or "OFF"))
end)

-- Toggle UI visibility with F5
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F5 then
        frame.Visible = not frame.Visible
        print("[FPS Control] Panel visibility toggled")
    end
end)

-- Close and Minimize buttons
closeButton.MouseButton1Click:Connect(function()
    screenGui:Destroy()
    print("[FPS Control] Panel closed")
end)

minimizeButton.MouseButton1Click:Connect(function()
    for _, child in ipairs(frame:GetChildren()) do
        if child ~= titleBar then
            child.Visible = not child.Visible
        end
    end
    print("[FPS Control] Panel minimized/maximized")
end)

-- Button hover effects
local function addButtonEffects(button)
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = colors.buttonHover
    end)
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = (button == toggleButton and (fpsLockEnabled and colors.red or colors.green)) or colors.button
    end)
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = colors.buttonActive
    end)
    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = colors.buttonHover
    end)
end

addButtonEffects(applyButton)
addButtonEffects(toggleButton)
addButtonEffects(closeButton)
addButtonEffects(minimizeButton)

print("FPS Control Panel Initialized")
