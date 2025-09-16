-- Auto Fisch Script dengan Kavo UI
-- Fitur: Auto Cast Mode Legit dengan timing random

-- Load Kavo UI Library from our repository
local Library
local success, result = pcall(function()
    return loadstring(game:HttpGet("https://raw.githubusercontent.com/DESRIYANDA/natural/main/kavo.lua"))()
end)

if success then
    Library = result
    print("✅ Kavo UI Library loaded successfully from our repository!")
else
    warn("❌ Failed to load Kavo UI Library. Error: " .. tostring(result))
    return
end

-- Services
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

-- Variables
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:FindFirstChildOfClass("PlayerGui")
local autoCast = false
local autoCastDelay = 2
local autoShake = false
local isShaking = false
local alwaysCatch = false
local enableLoop = true
local enableAFK = false

-- AFK Mode Variables
local afkStartTime = 0
local isAFK = false
local afkDuration = 0
local nextAFKTime = 0

-- Helper Functions
local function getchar()
    return LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
end

-- AFK Mode Functions
local function initializeAFK()
    if enableAFK then
        -- Set waktu untuk AFK pertama (5-10 menit dari sekarang)
        local initialDelay = math.random(300, 600) -- 5-10 menit dalam detik
        nextAFKTime = tick() + initialDelay
        print("AFK mode enabled. Next AFK in " .. math.floor(initialDelay/60) .. " minutes")
    end
end

local function checkAFKMode()
    if not enableAFK then return false end
    
    local currentTime = tick()
    
    -- Cek apakah sudah waktunya untuk AFK
    if not isAFK and currentTime >= nextAFKTime then
        -- Mulai AFK
        isAFK = true
        afkStartTime = currentTime
        afkDuration = math.random(60, 180) -- 1-3 menit dalam detik
        print("🛌 Going AFK for " .. math.floor(afkDuration/60) .. " minutes...")
        return true
    end
    
    -- Cek apakah AFK sudah selesai
    if isAFK and (currentTime - afkStartTime) >= afkDuration then
        -- Selesai AFK
        isAFK = false
        -- Set waktu AFK berikutnya (5-10 menit lagi)
        local nextDelay = math.random(300, 600)
        nextAFKTime = currentTime + nextDelay
        print("✅ Back from AFK! Next AFK in " .. math.floor(nextDelay/60) .. " minutes")
        return false
    end
    
    return isAFK
end

local function FindRod()
    local character = getchar()
    for _, tool in pairs(character:GetChildren()) do
        if tool:IsA("Tool") and tool:FindFirstChild("events") and tool.events:FindFirstChild("cast") then
            return tool
        end
    end
    return nil
end

-- Auto Cast Function dengan timing random
local function performAutoCast()
    if not autoCast then return end
    
    local rod = FindRod()
    if not rod then return end
    
    -- Generate random timing antara 1-3 detik
    local randomTiming = math.random(100, 300) / 100 -- 1.00 sampai 3.00 detik
    
    -- Start mouse hold (tekan mouse)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, LocalPlayer, 0)
    
    -- Wait dengan timing random
    wait(randomTiming)
    
    -- Release mouse hold (lepas mouse)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, LocalPlayer, 0)
end

-- Auto Shake Function dengan timing random
local function performAutoShake()
    if not autoShake or isShaking then return end
    
    local shakeUI = PlayerGui:FindFirstChild("shakeui")
    if not shakeUI then return end
    
    local safezone = shakeUI:FindFirstChild("safezone")
    if not safezone then return end
    
    local button = safezone:FindFirstChild("button")
    if not button or not button.Visible then return end
    
    isShaking = true
    
    spawn(function()
        while shakeUI.Parent and button.Visible and autoShake do
            -- Generate random timing antara 1-3 detik untuk setiap klik
            local randomClickTiming = math.random(100, 300) / 100 -- 1.00 sampai 3.00 detik
            
            -- Klik button shake
            VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
            wait(0.05) -- Brief delay
            VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
            
            -- Wait dengan timing random sebelum klik berikutnya
            wait(randomClickTiming)
        end
        isShaking = false
    end)
end

-- Always Catch Function dengan random percentage
local function performAlwaysCatch()
    if not alwaysCatch then return end
    
    -- Random percentage: 30% true, 70% false
    local randomPercentage = math.random(1, 100)
    local catchSuccess = randomPercentage <= 30 -- 30% chance untuk true
    
    -- arg1 selalu 100, arg2 random berdasarkan percentage
    ReplicatedStorage:WaitForChild("events"):WaitForChild("reelfinished"):FireServer(100, catchSuccess)
    
    print("Always Catch triggered - Success: " .. tostring(catchSuccess) .. " (" .. randomPercentage .. "%)")
    
    -- Setelah catch, tunggu delay random 1-4 detik lalu kembali ke auto cast
    if autoCast and enableLoop then
        spawn(function()
            local loopDelay = math.random(100, 400) / 100 -- 1.00 sampai 4.00 detik
            print("Waiting " .. string.format("%.2f", loopDelay) .. "s before next auto cast...")
            wait(loopDelay)
            
            -- Cek AFK mode sebelum melanjutkan
            if not checkAFKMode() and autoCast and enableLoop then
                spawn(function()
                    performAutoCast()
                end)
            end
        end)
    end
end

-- Create Main Window
local Window = Library.CreateLib("Auto Fisch - Mode Legit", "Ocean")

-- UI Visibility Variables
local UIVisible = true
local FloatingButton = nil

-- Function to create floating button
local function createFloatingButton()
    if FloatingButton then FloatingButton:Destroy() end
    
    FloatingButton = Instance.new("ScreenGui")
    FloatingButton.Name = "AutoFischFloat"
    FloatingButton.Parent = PlayerGui
    FloatingButton.ResetOnSpawn = false
    
    local Button = Instance.new("TextButton")
    Button.Name = "FloatButton"
    Button.Parent = FloatingButton
    Button.Size = UDim2.new(0, 100, 0, 50)
    Button.Position = UDim2.new(0, 20, 0, 100)
    Button.BackgroundColor3 = Color3.fromRGB(0, 162, 255)
    Button.BorderSizePixel = 0
    Button.Text = "🎣 Show UI"
    Button.TextColor3 = Color3.fromRGB(255, 255, 255)
    Button.TextScaled = true
    Button.Font = Enum.Font.GothamBold
    
    -- Make button rounded
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = Button
    
    -- Make button draggable
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    Button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Button.Position
        end
    end)
    
    Button.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            Button.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    Button.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    -- Button click to show UI
    Button.MouseButton1Click:Connect(function()
        if not dragging then
            UIVisible = true
            Library:ToggleUI()
            FloatingButton.Enabled = false
        end
    end)
end

-- Function to toggle UI visibility
local function toggleUI()
    UIVisible = not UIVisible
    if UIVisible then
        Library:ToggleUI()
        if FloatingButton then FloatingButton.Enabled = false end
    else
        Library:ToggleUI()
        createFloatingButton()
        FloatingButton.Enabled = true
    end
end

-- Create Tab
local AutoTab = Window:NewTab("Auto Cast")
local AutoSection = AutoTab:NewSection("Auto Cast Settings")

-- Auto Cast Toggle
AutoSection:NewToggle("Enable Auto Cast", "Aktifkan auto cast dengan timing random 1-3 detik", function(state)
    autoCast = state
    if state then
        print("Auto Cast: ON - Timing random 1-3 detik")
    else
        print("Auto Cast: OFF")
    end
end)

-- Auto Cast Delay Slider
AutoSection:NewSlider("Cast Delay", "Delay antar cast dalam detik", 5, 1, function(value)
    autoCastDelay = value
    print("Cast Delay: " .. value .. " detik")
end)

-- Auto Shake Section
local ShakeSection = AutoTab:NewSection("Auto Shake Settings")

-- Auto Shake Toggle
ShakeSection:NewToggle("Enable Auto Shake", "Aktifkan auto shake dengan klik random 1-3 detik", function(state)
    autoShake = state
    if state then
        print("Auto Shake: ON - Klik random 1-3 detik")
    else
        print("Auto Shake: OFF")
        isShaking = false
    end
end)

-- Always Catch Section
local CatchSection = AutoTab:NewSection("Always Catch Settings")

-- Always Catch Toggle
CatchSection:NewToggle("Enable Always Catch", "Aktifkan always catch dengan random success rate", function(state)
    alwaysCatch = state
    if state then
        print("Always Catch: ON - 30% success, 70% fail (natural)")
    else
        print("Always Catch: OFF")
    end
end)

-- Info Section
local InfoSection = AutoTab:NewSection("Informasi")
end)

-- Loop Settings Section

-- Loop Settings Section
local LoopSection = Window:NewSection("🔄 Loop Settings")

local LoopToggle = LoopSection:NewToggle("Enable Loop", "Automatically repeat fishing cycle", function(state)
    enableLoop = state
    print("Loop mode: " .. (enableLoop and "Enabled" or "Disabled"))
end)

-- AFK Mode Section
local AFKSection = Window:NewSection("😴 AFK Mode")

local AFKToggle = AFKSection:NewToggle("Enable AFK Mode", "Simulate realistic breaks", function(state)
    enableAFK = state
    if state then
        initializeAFK()
        print("AFK mode: Enabled")
    else
        isAFK = false
        print("AFK mode: Disabled")
    end
end)

-- UI Controls Section
local UISection = Window:NewSection("🎛️ UI Controls")

UISection:NewButton("Minimize to Floating Button", "Hide UI and show floating button", function()
    toggleUI()
    print("UI minimized to floating button")
end)

-- Main Loop untuk Auto Cast
local lastCastTime = 0

RunService.Heartbeat:Connect(function()
    -- Cek AFK mode terlebih dahulu
    if checkAFKMode() then return end
    
    if not autoCast then return end
    
    local currentTime = tick()
    if currentTime - lastCastTime >= autoCastDelay then
        local rod = FindRod()
        if rod then
            -- Cek apakah rod ready untuk cast (tidak sedang casting)
            if rod.values and rod.values:FindFirstChild("lure") then
                local lureValue = rod.values.lure.Value
                -- Jika lure value rendah, artinya tidak sedang memancing
                if lureValue <= 0.001 then
                    spawn(function()
                        performAutoCast()
                    end)
                    lastCastTime = currentTime
                end
            end
        end
    end
end)

-- Event listener untuk rod equipped/unequipped
local function onCharacterChildAdded(child)
    if child:IsA("Tool") and child:FindFirstChild("events") and child.events:FindFirstChild("cast") and autoCast then
        wait(autoCastDelay)
        spawn(function()
            performAutoCast()
        end)
        lastCastTime = tick()
    end
end

local function onCharacterAdded(character)
    character.ChildAdded:Connect(onCharacterChildAdded)
end

-- Connect events
if getchar() then
    getchar().ChildAdded:Connect(onCharacterChildAdded)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

-- Event listener untuk Shake UI
PlayerGui.ChildAdded:Connect(function(gui)
    if gui.Name == "shakeui" and autoShake then
        wait(0.1) -- Brief delay untuk memastikan UI fully loaded
        performAutoShake()
    elseif gui.Name == "reel" and alwaysCatch then
        wait(0.5) -- Delay sedikit sebelum auto reel
        performAlwaysCatch()
    end
end)

-- Keybind untuk toggle UI (Right Ctrl)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.RightControl then
        toggleUI()
        print("UI toggled with Right Ctrl")
    end
end)

print("Auto Fisch Script Loaded!")
print("Features:")
print("- Auto Cast Mode Legit dengan timing random 1-3 detik")
print("- Auto Shake Mode Legit dengan klik random 1-3 detik")
print("- Always Catch Mode Legit dengan 30% success rate")