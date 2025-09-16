-- Auto Fisch Script dengan Kavo UI
-- Fitur: Auto Cast Mode Legit dengan timing random

-- Load Kavo UI Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/DESRIYANDA/natural/main/kavo.lua"))()

-- Services
local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

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
local Window = Library.CreateLib("Auto Fisch", "Ocean")

local AutoTab = Window:NewTab("Auto Cast")
local AutoSection = AutoTab:NewSection("Auto Cast Settings")

AutoSection:NewToggle("Enable Auto Cast", "Aktifkan auto cast dengan timing random 1-3 detik", function(state)
    autoCast = state
    if state then
        print("Auto Cast: ON - Timing random 1-3 detik")
    else
        print("Auto Cast: OFF")
    end
end)

AutoSection:NewSlider("Cast Delay", "Delay antar cast dalam detik", 5, 1, function(value)
    autoCastDelay = value
    print("Cast Delay: " .. value .. " detik")
end)

local ShakeSection = AutoTab:NewSection("Auto Shake Settings")

ShakeSection:NewToggle("Enable Auto Shake", "Aktifkan auto shake dengan klik random 1-3 detik", function(state)
    autoShake = state
    if state then
        print("Auto Shake: ON - Klik random 1-3 detik")
    else
        print("Auto Shake: OFF")
        isShaking = false
    end
end)

local CatchSection = AutoTab:NewSection("Always Catch Settings")

CatchSection:NewToggle("Enable Always Catch", "Aktifkan always catch dengan random success rate", function(state)
    alwaysCatch = state
    if state then
        print("Always Catch: ON - 30% success, 70% fail (natural)")
    else
        print("Always Catch: OFF")
    end
end)

local InfoSection = AutoTab:NewSection("Informasi")
AutoSection:NewLabel("Auto Cast Mode Legit:")
AutoSection:NewLabel("- Timing hold: 1-3 detik (random)")
AutoSection:NewLabel("- Safe & Natural casting simulation")
AutoSection:NewLabel("")
AutoSection:NewLabel("Auto Shake Mode Legit:")
AutoSection:NewLabel("- Timing klik: 1-3 detik (random)")
AutoSection:NewLabel("- Otomatis klik button shake")
AutoSection:NewLabel("")
AutoSection:NewLabel("Always Catch Mode Legit:")
AutoSection:NewLabel("- 30% success rate (true)")
AutoSection:NewLabel("- 70% fail rate (false)")
AutoSection:NewLabel("- Natural fishing simulation")

local LoopTab = Window:NewTab("Loop Settings")
local LoopSection = LoopTab:NewSection("🔄 Loop Settings")

local LoopToggle = LoopSection:NewToggle("Enable Loop", "Automatically repeat fishing cycle", function(state)
    enableLoop = state
    print("Loop mode: " .. (enableLoop and "Enabled" or "Disabled"))
end)

LoopSection:NewLabel("Loop Settings:")
LoopSection:NewLabel("- Auto repeats: Cast → Shake → Catch")
LoopSection:NewLabel("- Random delay: 1-4 seconds")
LoopSection:NewLabel("- Natural fishing simulation")

local AFKTab = Window:NewTab("AFK Mode")
local AFKSection = AFKTab:NewSection("😴 AFK Mode")

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

AFKSection:NewLabel("AFK Mode Settings:")
AFKSection:NewLabel("- Active time: 5-10 minutes")
AFKSection:NewLabel("- Break time: 1-3 minutes")
AFKSection:NewLabel("- Realistic player simulation")

local lastShakeTime = 0
RunService.Heartbeat:Connect(function()
    if autoShake then
        local shakeui = PlayerGui:FindFirstChild("shakeui")
        if shakeui and shakeui:FindFirstChild("safezone") and shakeui.safezone:FindFirstChild("button") then
            local currentTime = tick()
            if currentTime - lastShakeTime >= math.random(1,3) then
                -- Trigger shake
                GuiService.SelectedObject = shakeui.safezone.button
                if GuiService.SelectedObject == shakeui.safezone.button then
                    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Return, false, game)
                    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Return, false, game)
                end
                lastShakeTime = currentTime
            end
        end
    end
end)
local lastCastTime = 0
local lastRodEquipped = nil

RunService.Heartbeat:Connect(function()
    -- Cek AFK mode terlebih dahulu
    if checkAFKMode() then return end
    if not autoCast then return end

    local currentTime = tick()
    local rod = FindRod()
    if rod then
        -- Cek apakah rod baru saja di-equip
        if lastRodEquipped ~= rod then
            lastRodEquipped = rod
            -- Cast langsung saat rod di-equip dan autoCast aktif
            if rod.values and rod.values:FindFirstChild("lure") then
                local lureValue = rod.values.lure.Value
                if lureValue <= 0.001 then
                    spawn(function()
                        performAutoCast()
                    end)
                    lastCastTime = currentTime
                end
            end
        end
        -- Cek interval autoCast seperti biasa
        if currentTime - lastCastTime >= autoCastDelay then
            if rod.values and rod.values:FindFirstChild("lure") then
                local lureValue = rod.values.lure.Value
                if lureValue <= 0.001 then
                    spawn(function()
                        performAutoCast()
                    end)
                    lastCastTime = currentTime
                end
            end
        end
    else
        lastRodEquipped = nil
    end
end)

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

if getchar() then
    getchar().ChildAdded:Connect(onCharacterChildAdded)
end

LocalPlayer.CharacterAdded:Connect(onCharacterAdded)

PlayerGui.ChildAdded:Connect(function(gui)
    if gui.Name == "shakeui" and autoShake then
        wait(0.1) -- Brief delay untuk memastikan UI fully loaded
        performAutoShake()
    elseif gui.Name == "reel" and alwaysCatch then
        -- Natural always catch: random delay, random perfect catch
        spawn(function()
            local minigameDelay = math.random(50, 150) / 100 -- 0.5-1.5 detik
            wait(minigameDelay)
            performAlwaysCatch()
        end)
    end
end)

print("Auto Fisch Script Loaded!")
print("Features:")
print("- Auto Cast Mode Legit dengan timing random 1-3 detik")
print("- Auto Shake Mode Legit dengan klik random 1-3 detik")
print("- Always Catch Mode Legit dengan 30% success rate")