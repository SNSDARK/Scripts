-- Load Rayfield UI Library
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
 
-- Create Main Window
local Window = Rayfield:CreateWindow({
    Name = "Ghost Exploits",
    LoadingTitle = "Loading...",
    LoadingSubtitle = "",
})
 
local Evi1, Evi2, Evi3, Evi4 = false, false, false, false
local Fullbright = false
local LightingSettings = {
    Ambient = game.Lighting.Ambient,
    OutdoorAmbient = game.Lighting.OutdoorAmbient
}
local Lighting = cloneref(game:GetService("Lighting"))

-- Create Tools Tab
local Tab = Window:CreateTab("Ghost Tools", 4483362458)
local Tab2 = Window:CreateTab("Info")
 
-- Display Ghost Type
local GhostRoomLabel = Tab2:CreateLabel("Ghost Room: Checking...")
local GhostHuntingLabel = Tab2:CreateLabel("Ghost Hunting: Checking...")
local GhostSpecialLabel = Tab2:CreateLabel("Ghost Special Feature: None")
local Evidence1 = Tab2:CreateLabel("Evidence 1: None")
local Evidence2 = Tab2:CreateLabel("Evidence 2: None")
local Evidence3 = Tab2:CreateLabel("Evidence 3: None")
local Evidence4 = Tab2:CreateLabel("Evidence 4: None")
local TemperatureG = Tab2:CreateLabel("Temp on Ghostroom: 0°C")

local function AddEvidence(Evidence)
    if not Evi1 then
        Evidence1:Set("Evidence 1: " .. Evidence)
        Evi1 = true
    elseif not Evi2 then
        Evidence2:Set("Evidence 2: " .. Evidence)
        Evi2 = true
    elseif not Evi3 then
        Evidence3:Set("Evidence 3: " .. Evidence)
        Evi3 = true
    elseif not Evi4 then
        Evidence4:Set("Evidence 4: " .. Evidence)
        Evi4 = true
    end
end

-- ESP
loadstring(game:HttpGet("https://raw.githubusercontent.com/RelkzzRebranded/THEGHOSTISAMOLESTER/refs/heads/main/script.lua"))()

-- Fullbright Toggle
local FullbrightToggle = Tab:CreateButton({
    Name = "Loop Fullbright",
    CurrentValue = false,
    Flag = "Fullbright",
    Callback = function()
        Lighting.Brightness = 2
        Lighting.ClockTime = 14
        Lighting.FogEnd = 100000
        Lighting.GlobalShadows = false
        Lighting.OutdoorAmbient = Color3.fromRGB(128, 128, 128)
    end,
})
 
-- Loop WalkSpeed Toggle
local speed = 20  -- Default speed for the loop
local WalkSpeedLoopActive = false
 
local WalkSpeedToggle = Tab:CreateToggle({
    Name = "Loop WalkSpeed",
    CurrentValue = false,
    Flag = "WalkSpeed",
    Callback = function(Value)
        WalkSpeedLoopActive = Value
    end,
})
 
-- WalkSpeed Adjustment Slider
local SpeedSlider = Tab:CreateSlider({
    Name = "Adjust WalkSpeed",
    Range = {16, 30},
    Increment = 1,
    Suffix = " Speed",
    CurrentValue = speed,
    Callback = function(Value)
        speed = Value
    end,
})

task.defer(function()
    local player = game.Players.LocalPlayer
    local humanoid = player and player.Character and player.Character:FindFirstChild("Humanoid")
    local oldWalkspeed = player.Character:FindFirstChild("Humanoid").WalkSpeed
    while task.wait() do
        if WalkSpeedLoopActive and humanoid then
            humanoid.WalkSpeed = speed
            task.wait(0.1)
        else
            humanoid.WalkSpeed = oldWalkspeed
        end
    end
end)
 
-- NoClip Toggle
local noclip = false
local player = game.Players.LocalPlayer
local NoClipToggle = Tab:CreateToggle({
    Name = "NoClip",
    CurrentValue = false,
    Flag = "NoClip",
    Callback = function(Value)
        noclip = Value
    end,
})
task.defer(function()
    while task.wait() do
        if game:GetService("Workspace"):FindFirstChild("Ghost") then
            if game:GetService("Workspace").Ghost:GetAttribute("FavoriteRoom") then
                GhostRoomLabel:Set("Ghost Room: "..game:GetService("Workspace").Ghost:GetAttribute("FavoriteRoom"))
                pcall(function() TemperatureG:Set(string.format("Temp on Ghostroom: %.1f", game:GetService("Workspace").Map.Rooms[game:GetService("Workspace").Ghost:GetAttribute("FavoriteRoom")]:GetAttribute("Temperature")) .. "°C") end)
            end
            pcall(function() GhostHuntingLabel:Set("Ghost Hunting: "..tostring(game:GetService("Workspace").Ghost:GetAttribute("Hunting"))) end)
            if game:GetService("Workspace").Ghost:GetAttribute("Headless") then
                GhostSpecialLabel:Set("Ghost Special Feature: Headless / Dullahan")
            end
        end
    end
end)


task.defer(function()
    local Evidences = {
        GhostOrb = false,
        Handprints = false,
        Temperature = false,
        Laser = false,
        WitheredFlower = {['Checked'] = false, ['Instance'] = nil},
        SpiritBook = {['Checked'] = false, ['Instance'] = nil},
        EMF = {['Checked'] = false, ['Instance'] = nil},
    }
    for _,item in pairs(game:GetService("Workspace").Items:GetChildren()) do
        if item:GetAttribute("ItemName") == "Flower Pot" then
            Evidences.WitheredFlower.Instance = item
        end
        if item:GetAttribute("ItemName") == "Spirit Book" then
            Evidences.SpiritBook.Instance = item
        end
        if item:GetAttribute("ItemName") == "EMF Reader" then
            Evidences.EMF.Instance = item
        end
    end
    while task.wait() do
        if game:GetService("Workspace"):FindFirstChild("GhostOrb") and not Evidences.GhostOrb then
            AddEvidence("Ghost Orb")
            Evidences.GhostOrb = true
        end
        if #game:GetService("Workspace").Handprints:GetChildren() > 0 and not Evidences.Handprints then
            AddEvidence("Handprints")
            Evidences.Handprints = true
        end
        if game:GetService("Workspace").Map.Rooms[game:GetService("Workspace").Ghost:GetAttribute("FavoriteRoom")]:GetAttribute("Temperature") < 0 and not Evidences.Temperature then
            AddEvidence("Freezing Temperature")
            Evidences.Temperature = true
        end
        if not Evidences.Laser and game:GetService("Workspace").Ghost:GetAttribute("LaserVisible") then
            AddEvidence("Laser")
            Evidences.Laser = true
        end
        pcall(function()
            for _,item in pairs(game:GetService("Workspace").Items:GetChildren()) do
                if not Evidences.WitheredFlower.Checked and item:GetAttribute("ItemName") == "Flower Pot" and item:GetAttribute("PhotoRewardType") == "WitheredFlowers" then
                    AddEvidence("Withered Flowers")
                    Evidences.WitheredFlower.Checked = true
                end
                if not Evidences.SpiritBook.Checked and item:GetAttribute("ItemName") == "Spirit Book" and item:GetAttribute("PhotoRewardAvailable") and item:GetAttribute("PhotoRewardType") == "GhostWriting" then
                    AddEvidence("Spirit Book")
                    Evidences.SpiritBook.Checked = true
                end
                if not Evidences.EMF.Checked and item:GetAttribute("ItemName") == "EMF Reader" then
                    if item.Indicators['5'].Material == Enum.Material.Neon then
                        AddEvidence("EMF 5")
                        Evidences.EMF.Checked = true
                    end
                end
            end
        end)
    end
end)
task.defer(function()
    local NoClippingStarted
    local function NoClip()
        local speaker = game.Players.LocalPlayer
        if speaker.Character then
            for _, child in pairs(speaker.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then
                    child.CanCollide = false
                end
            end
        end
    end
    while task.wait() do
        if not noclip and NoClippingStarted then
            NoClippingStarted:Disconnect()
            NoClippingStarted = nil
        elseif noclip and not NoClippingStarted then
            NoClippingStarted = game:GetService("RunService").Stepped:Connect(NoClip)
        end
    end    
end)
