_G.ScriptKey = "ycYcY9kgPlqG6yymqyTYuZS2fxZcRV24"

-------------------------------------------
if _G.ScriptRunning then return else end
_G.ScriptRunning = true

local vu = game:GetService("VirtualUser")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local VirtualInputManager = game:GetService("VirtualInputManager")
local PlayerLevel = LocalPlayer.PlayerGui.Health.Frame.Lev
local Premium = false

-- Auto Idle Functionality
LocalPlayer.Idled:Connect(function()
    if LocalPlayer.Character.Humanoid.Health <= 0 then
        wait()
    else
        vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        wait(1)
        vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end
end)

-------------------------------------------
print("Script Start")
-------------------------------------------

local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/jensonhirst/Orion/main/source')))()
local StarterGui = game:GetService('StarterGui')
local IsAutoAttacking, IsLimitRange, RangeLimit, IsAutoReset, isNoClip, IsAutoTrainerDummy = false, false, 40, false, false, false
local ScriptStarted, WavesTP, WaitWavesReset, StopPlus = false, false, false, false
local Attackfunction, co, delayedhit;

local ClassMoves = {
    ["Quincies"] = {
        "Celdryx's Hammer",
        "Hero's Sword",
        "Seele Schneider",
        "Gelphire's Flame",
        "Delthazar's Spikes"
    },
    ["Arrancars"] = {
        "Celdryx's Hammer",
        "Hero's Sword",
        "Arrancar Cero",
        "Cero Blast",
        "Gran Rey Cero",
        "Gelphire's Flame",
        "Delthazar's Spikes"
    },
    ["Sinners"] = {
        "Celdryx's Hammer",
        "Hero's Sword",
        "Sinful Spear",
        "Gelphire's Flame",
        "Delthazar's Spikes"
    },
    ["Soul Reapers"] = {
        "Celdryx's Hammer",
        "Hero's Sword",
        "Shikai",
        "Gelphire's Flame",
        "Getsuga Tensho"
    },
    ["Hollows"] = {
        "Celdryx's Hammer",
        "Hero's Sword",
        "Delthazar's Spikes",
        "Cero Bomb",
        "Gelphire's Flame"
    },
    ["Vizards"] = {
        "Celdryx's Hammer",
        "Hero's Sword",
        "Gelphire's Flame",
        "Delthazar's Spikes",
        "Getsuga Tensho"
    },
    ["Fullbringers"] = {
        "Celdryx's Hammer",
        "Hero's Sword",
        "Mace of Spheres",
        "Gelphire's Flame",
        "Delthazar's Spikes"
    },
    ["Royal Guard"] = {
        "Reitsu Wave",
        "Celdryx's Hammer",
        "Hero's Sword",
        "Royal Sword",
        "Blade Explosion"
    },
    ["Bounts"] = {
        "Vortex",
        "Tesseract",
        "Gelphire's Flame",
        "Celdryx's Hammer",
        "Gamma Quake"
    }
}

-- Find Attack Function
for _, v in next, getgc() do
    if typeof(v) == 'function' and not isexecutorclosure(v) and not isourclosure(v) and islclosure(v) then
        if debug.info(v, "n") == "projectilehit" then
            Attackfunction = v
        end
        if debug.info(v, "n") == "co" then
            co = v
        end
    end
end

for _, v in next, getgc() do
    if typeof(v) == 'function' and not isexecutorclosure(v) and not isourclosure(v) and islclosure(v) then
        if debug.info(v, 'n') == 'manacost' then
            hookfunction(v, function(...)
                return true
            end)
        end
    end
end

if _G.ScriptKey == "ycYcY9kgPlqG6yymqyTYuZS2fxZcRV24" then Premium = true end
if not Attackfunction or not co then StarterGui:SetCore('SendNotification', {Title = 'ERROR',Duration = 100000, Text = 'Please contact script owner'}) return end
------------------------------------------

-- Create UI Window
local Window = OrionLib:MakeWindow({
    Name = "Bleach Hollow's Return",
    TestMode = true,
    SaveConfig = true,
    ConfigFolder = "BHRScript"
})

-- Create Tabs
local Tab1 = Window:MakeTab({ Name = "Attack" })
local Tab2 = Window:MakeTab({ Name = "Level" })
local Tab3 = Window:MakeTab({ Name = "Misc" })

-- Tab 1: Attack Settings
Tab1:AddToggle({
    Name = "Start Auto",
    Default = false,
    Callback = function(Value) IsAutoAttacking = Value end
})

Tab1:AddToggle({
    Name = "Auto Attack Dummy",
    Default = false,
    Callback = function(Value) IsAutoTrainerDummy = Value end
})

Tab1:AddToggle({
    Name = "Limit Range",
    Default = false,
    Save = true,
    Flag = "IsLimitRange",
    Callback = function(Value) IsLimitRange = Value end
})

Tab1:AddSlider({
    Name = "Range Limit",
    Min = 20,
    Max = 1500,
    Default = RangeLimit,
    Color = Color3.fromRGB(1, 0, 0),
    Increment = 20,
    ValueName = "Range",
    Save = true,
    Flag = "RangeLimit",
    Callback = function(Value) RangeLimit = Value end
})

Tab1:AddLabel("This will reset the character to have the wave start over again")
Tab1:AddToggle({
    Name = "Auto Reset",
    Default = false,
    Save = true,
    Flag = "IsAutoReset",
    Callback = function(Value) IsAutoReset = Value end
})

Tab1:AddLabel("Doing waves? use this toggle for safety in case you get flinged")
Tab1:AddToggle({
    Name = "Waves TP Safety",
    Default = false,
    Save = true,
    Flag = "WavesTP",
    Callback = function(Value) WavesTP = Value end
})

-- Tab 3: Misc Settings
Tab3:AddToggle({
    Name = "No Clip",
    Default = false,
    Save = true,
    Flag = "isNoClip",
    Callback = function(Value) isNoClip = Value end
})

Tab3:AddLabel("This area is for testing purposes only!")
local TestingMode = false
Tab3:AddToggle({
    Name = "Test Mode",
    Default = false,
    Callback = function(Value) TestingMode = Value end
})

local UseCooldown = false
local WaitCooldown = 0.01
Tab3:AddToggle({
    Name = "Use Cooldown",
    Default = false,
    Callback = function(Value) UseCooldown = Value end
})

Tab3:AddSlider({
    Name = "Wait Time",
    Min = 0.001,
    Max = 0.1,
    Color = Color3.fromRGB(1, 0, 0),
    Increment = 0.001,
    ValueName = "",
    Default = 0.01,
    Callback = function(Value) WaitCooldown = Value end
})

local TOF = Tab2:AddLabel("Total Time: 00:00:00")
local LPS = Tab2:AddLabel("Average Level per second: 0")
local LPM = Tab2:AddLabel("Level per Minute: 0")
local LPTM = Tab2:AddLabel("Level per Ten Minutes: 0")
local LPH = Tab2:AddLabel("Level per Hour: 0")
local TLG = Tab2:AddLabel("Total Level Gained: 0")
------------------------------------------
-- Functions
local function ResetPlayer()
    if replicatesignal then
        replicatesignal(LocalPlayer.Kill)
    else
        LocalPlayer:FindFirstChild("Humanoid").Health = 0
    end
end

local function getPlayerRoot()
    local player = game.Players.LocalPlayer
    local pChar = player.Character
    if pChar.Humanoid.Health <= 0 then
        player.CharacterAdded:Wait()
    end
    if not pChar:FindFirstChild("HumanoidRootPart") then
        repeat task.wait() until pChar:FindFirstChild("HumanoidRootPart")
    end
    return pChar.HumanoidRootPart or pChar.PrimaryPart
end

local function LevelGainedCheck()
    local currentLevel = tonumber(PlayerLevel.Text:match("%d+"))
    while task.wait() do
        if IsAutoAttacking then
            TLG:Set("Total Level Gained: " .. tostring(tonumber(PlayerLevel.Text:match("%d+")) - currentLevel))
        else
            currentLevel = tonumber(PlayerLevel.Text:match("%d+"))
        end
    end
end

local function TweentoPosition(targetPos, Boolean)
    if not Boolean then return end
    if LocalPlayer.Character.Humanoid.Health <= 0 then return end
    if typeof(targetPos) ~= "Vector3" then
        warn("Vector3 expected, got " .. typeof(targetPos))
        return
    end
    if (LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position - targetPos).Magnitude <= 2 then return end
    while task.wait() do
        if LocalPlayer.Character.Humanoid.Health <= 0 then return end
        local playerPos = LocalPlayer.Character:WaitForChild("HumanoidRootPart").Position
        local direction = (targetPos - playerPos).Unit
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = CFrame.new(playerPos + direction)
        if (playerPos - targetPos).Magnitude <= 4 or not Boolean then break end
    end
end

local function TeleportToWaves()
    WaitWavesReset = true
    LocalPlayer.CharacterAdded:Wait()
    VirtualInputManager:SendKeyEvent(true, 119, false, game)
    task.wait(2)
    VirtualInputManager:SendKeyEvent(false, 119, false, game)
    VirtualInputManager:SendKeyEvent(true, 103, false, game)
    task.wait()
    VirtualInputManager:SendKeyEvent(false, 103, false, game)
    if WavesTP then
        LocalPlayer.Character:WaitForChild("HumanoidRootPart").CFrame = game:GetService("Workspace").City.Shack.TGWPortal.CFrame
        task.wait(0.7)
        TweentoPosition(game:GetService("Workspace"):FindFirstChild("ToTPforWaves").Position)
    end
    WaitWavesReset = false
end

local function WavesCheckTP()
    while task.wait() do
        if WavesTP and not WaitWavesReset and IsAutoAttacking then
            if LocalPlayer.Character.Humanoid.Health <= 0 then TeleportToWaves() end
            TweentoPosition(game:GetService("Workspace"):FindFirstChild("ToTPforWaves").Position, true)
        elseif not WavesTP and WaitWavesReset and not IsAutoAttacking then
            TweentoPosition(game:GetService("Workspace"):FindFirstChild("ToTPforWaves").Position, false)
        end
    end
end

local function AutoFarmAndLevelMonitor()
    -- Timing variables
    local startTime = os.time()
    local autoTime, autoMin, autoHour = 0, 0, 0

    -- Level monitoring variables
    local intervals = {
        { name = "1 Second", duration = 1 },
        { name = "1 Minute", duration = 60 },
        { name = "10 Minutes", duration = 600 },
        { name = "1 Hour", duration = 3600 }
    }
    local currentTime = os.clock()
    local currentLevel = tonumber(PlayerLevel.Text:match("%d+"))
    local intervalData = {}
    for _, interval in pairs(intervals) do
        intervalData[interval.name] = {
            lastTime = currentTime,
            lastLevel = currentLevel
        }
    end
    local lastLevelGain = 0

    while task.wait() do
        if not IsAutoAttacking then
            startTime = os.time()
            autoTime, autoMin, autoHour = 0, 0, 0
            TOF:Set("Total Time: 00:00:00")
            currentTime = os.clock()
            currentLevel = tonumber(PlayerLevel.Text:match("%d+"))
            for _, interval in pairs(intervals) do
                intervalData[interval.name].lastTime = currentTime
                intervalData[interval.name].lastLevel = currentLevel
            end
            lastLevelGain = 0
        elseif IsAutoAttacking then
            local currentTotalTime = os.time()
            local deltaTime = currentTotalTime - startTime
            autoHour = math.floor(deltaTime / 3600)
            autoMin = math.floor((deltaTime % 3600) / 60)
            autoTime = math.floor(deltaTime % 60)
            TOF:Set(string.format("Total Time: %02d:%02d:%02d", autoHour, autoMin, autoTime))
            currentTime = os.clock()
            currentLevel = tonumber(PlayerLevel.Text:match("%d+"))
            for _, interval in pairs(intervals) do
                local data = intervalData[interval.name]
                if currentTime - data.lastTime >= interval.duration then
                    local levelGain = currentLevel - data.lastLevel
                    data.lastTime = currentTime
                    data.lastLevel = currentLevel
                    if interval.name == "1 Second" then
                        local averagePerSecond = (levelGain + lastLevelGain) / 2
                        LPS:Set(string.format("Average Level per second: %.2f", averagePerSecond))
                        lastLevelGain = levelGain
                    elseif interval.name == "1 Minute" then
                        LPM:Set(string.format("Level per minute: %.2f", levelGain))
                    elseif interval.name == "10 Minutes" then
                        LPTM:Set(string.format("Level per ten minutes: %.2f", levelGain))
                    elseif interval.name == "1 Hour" then
                        LPH:Set(string.format("Level per hour: %.2f", levelGain))
                    end
                end
            end
        end
    end
end

local function AutoResetByLag()
    local frameRateValues = {}
    local averageFrameRate = 0
    local threshold = 45
    local sampleSize = 100
    while task.wait(0.1) do
        local currentFrameRate = game:GetService("Stats").Workspace.Heartbeat:GetValue()
        table.insert(frameRateValues, currentFrameRate)
        if #frameRateValues > sampleSize then
            table.remove(frameRateValues, 1)
        end
        local sum = 0
        for _, value in pairs(frameRateValues) do
            sum = sum + value
        end
        averageFrameRate = sum / #frameRateValues
        if averageFrameRate < threshold then
            ResetPlayer()
            TeleportToWaves()
        end
    end
end

local function FastWait()
    if TestingMode then
        return UseCooldown and task.wait(WaitCooldown) or task.wait()
    end
    if Premium then return task.wait(0.0535) end
    return task.wait(0.0339)
end

local function Attack(TargetHumanoid)
    if WaitWavesReset then repeat task.wait() until not WaitWavesReset end
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") and LocalPlayer.Character.Humanoid.Health > 0 then
        if not TargetHumanoid:IsA("Humanoid") then warn("Target not Humanoid") return end
        if TargetHumanoid.Health <= 0 then return end
        local targetPart = TargetHumanoid.Parent:FindFirstChild("HumanoidRootPart") or TargetHumanoid.Parent.PrimaryPart
        if Premium then
            for _, skill in pairs(ClassMoves[tostring(game.Players.LocalPlayer.Team)]) do
                co(Attackfunction, TargetHumanoid, targetPart, skill, {nil})
                if TargetHumanoid.Health <= 0 then break end
            end
            return
        end
        co(Attackfunction, TargetHumanoid, targetPart, ClassMoves[tostring(game.Players.LocalPlayer.Team)][1], {nil})
    end
end

local function AutoSoul()
    while task.wait() do
        local soulPart = game:GetService("Workspace").Folder:FindFirstChild("SoulPart")
        if soulPart and soulPart:FindFirstChild("TouchInterest") then
            soulPart.CanCollide = false
            soulPart.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
        end
    end
end

local function RemoveParticles()
    while task.wait() do
        for _, v in pairs(game:GetService("Players").LocalPlayer.Character:GetDescendants()) do
            if v:IsA("ParticleEmitter") or v:IsA("Fire") then
                v:Destroy()
            end
        end
    end
end

local function AutoHit()
    local Bosses = {"Delthazar", "Celdryx", "Shrade", "Valtores", "Gelphire The Inferno", "Belaham", "Kuro of Masked Darkness"}
    local BlacklistedMobs = {"Xylender"}
    while task.wait() do
        if IsAutoAttacking then
            for _, mob in pairs(game:GetService("Workspace").Mobs:GetChildren()) do
                if mob and mob:FindFirstChild("Humanoid") and mob.Humanoid.Health > 0 and (mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart) and not table.find(BlacklistedMobs, mob.Name) then
                    local distance = (mob.PrimaryPart.Position - getPlayerRoot().Position).Magnitude
                    if IsLimitRange and distance <= RangeLimit or not IsLimitRange then
                        if table.find(Bosses, mob.Name) then
                            while mob and mob:FindFirstChild("Humanoid") and (mob:FindFirstChild("HumanoidRootPart") or mob.PrimaryPart) and mob.Humanoid.Health > 0 and IsAutoAttacking and (IsLimitRange and distance <= RangeLimit or not IsLimitRange) do
                                Attack(mob.Humanoid)
                                distance = (mob.PrimaryPart.Position - getPlayerRoot().Position).Magnitude
                                FastWait()
                            end
                        elseif not table.find(Bosses, mob.Name) then
                            Attack(mob.Humanoid)
                            FastWait()
                        end
                    end
                end
            end
        end
        if IsAutoTrainerDummy then
            for _, mob in pairs(game:GetService("Workspace").TrainingGrounds.Trainers:GetChildren()) do
                Attack(mob.Humanoid)
                FastWait()
            end
        end
    end
end

local function StartNoClip()
    local NoClippingStarted
    local function NoClip()
        local speaker = LocalPlayer
        if speaker.Character then
            for _, child in pairs(speaker.Character:GetDescendants()) do
                if child:IsA("BasePart") and child.CanCollide then
                    child.CanCollide = false
                end
            end
        end
    end
    while task.wait() do
        if not isNoClip and NoClippingStarted then
            NoClippingStarted:Disconnect()
            NoClippingStarted = nil
        elseif isNoClip and not NoClippingStarted then
            NoClippingStarted = game:GetService("RunService").Stepped:Connect(NoClip)
        end
    end    
end

-------------------------------------------

-- Create Platforms
local function CreatePlatform(name, position, size, transparency)
    local platform = Instance.new("Part")
    platform.Name = name
    platform.Parent = game.Workspace
    platform.Anchored = true
    platform.Position = position
    platform.Size = size
    platform.Color = Color3.new(1, 1, 1)
    platform.Transparency = transparency
    platform.Material = Enum.Material.SmoothPlastic
    return platform
end

CreatePlatform("PlatformForGrindyBoiUWU", Vector3.new(2248.712890625, 5032.6455078125, 4594.582519531), Vector3.new(10, 1, 10), 0.75)
CreatePlatform("ToTPforWaves", Vector3.new(2248.712890625, 5036.6455078125, 4594.582519531), Vector3.new(1, 1, 1), 1)

for _, v in pairs(game:GetService("Workspace").TrainingGroundsRaid:GetChildren()) do 
    if v.CFrame == CFrame.new(2250.5, 5057, 4592.5, 0.707134247, 0, 0.707079291, 0, 1, 0, -0.707079291, 0, 0.707134247) then 
        v.Transparency = 1 
    end 
end

-- Start Coroutines
coroutine.wrap(AutoHit)()
coroutine.wrap(LevelGainedCheck)()
coroutine.wrap(AutoSoul)()
coroutine.wrap(AutoFarmAndLevelMonitor)()
coroutine.wrap(StartNoClip)()
coroutine.wrap(WavesCheckTP)()
coroutine.wrap(RemoveParticles)()
spawn(function()AutoResetByLag() end)

ScriptStarted = true
OrionLib:Init()
wait(5)
StarterGui:SetCore('SendNotification', {Title = 'Script Loaded',Duration = 5, Text = 'Enjoy, feel free to contact the script owner for bugs and issues.'})
game.NetworkClient.ChildRemoved:Connect(function()
    game:GetService'GuiService':ClearError()
end)
------------------------------------------
