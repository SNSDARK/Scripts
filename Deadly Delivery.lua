
loadstring(game:HttpGet("https://raw.githubusercontent.com/SNSDARK/Scripts/refs/heads/main/Auto-Reconnect-Universal.lua"))()
repeat task.wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game:FindService("NetworkClient")
if getgenv().ScriptStarted then return end
getgenv().ScriptStarted = true
task.wait(2)
require(game.ReplicatedStorage.Shared.Features.Buff).AddBuffs(game.Players.LocalPlayer, {{name = "RoleStamina", type = "StaminaRegenRate", value = math.huge, tags = {"PersistOnDeath", "Multi"}}, {name = "RoleStamina", type = "StaminaLimit", value = math.huge, tags = {"PersistOnDeath", "Multi"}}})
getgenv().GoLobby = true
local GC = getconnections or get_signal_cons
if GC then
    for _,v in pairs(GC(game:GetService("Players").LocalPlayer.Idled)) do
        v:Disable()
    end
else
    game:GetService("Players").LocalPlayer.Idled:connect(function()
        if game:GetService("Players").LocalPlayer.Character.Humanoid.Health > 0 then
            game:GetService("VirtualUser"):Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
            wait(1)
            game:GetService("VirtualUser"):Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        end
    end)
end
local function saveWebhook(url)
    if url and type(url) == "string" and url ~= "" then
        local success, errorMsg = pcall(function()
            writefile("DeadlyDeliveryWH.txt", url)
        end)
    end
end
local function loadWebhook()
    if isfile and isfile("DeadlyDeliveryWH.txt") then
        local success, content = pcall(readfile, "DeadlyDeliveryWH.txt")
        
        if success then
            if content and content ~= "" then
                print("Loaded Webhook URL")
                return content
            else
                print("File exists but is empty")
                return nil
            end
        else
            print("Error reading file: " .. tostring(content))
            return nil
        end
    else
        print("No saved webhook found")
        return nil
    end
end
local WebhookURL = ""
saveWebhook(getgenv().WebhookURL)
local loadWH = loadWebhook()
if loadWH then
    WebhookURL = loadWH
end 
if require(game:GetService("ReplicatedStorage").Shared.Core.AssetId).world == "Lobby" then
    require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("BackpackSellAll")
    local function StartMatch(Setting)
        if type(Setting) ~= "table" then
            return warn("Invalid match setting")
        end
        local LobbyMade = ""
        repeat task.wait()
            for Name, lobby in require(game:GetService("ReplicatedStorage").Shared.Core.Value).GetAllValue().MatchInfo do
                if lobby.matchState == "Idle" then
                    require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("JoinMatch", Name)
                    LobbyMade = Name
                    break
                end
            end
        until LobbyMade ~= ""
        repeat task.wait() until require(game:GetService("ReplicatedStorage").Shared.Core.Value).GetAllValue().MatchInfo[LobbyMade].matchState == "Creating"
        require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("UploadSetting", Setting)
        repeat task.wait() until require(game:GetService("ReplicatedStorage").Shared.Core.Value).GetAllValue().MatchInfo[LobbyMade].matchState == "Reseting"
    end
    StartMatch({size = 1, onlyFriends = true})
    queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/SNSDARK/Scripts/refs/heads/main/Deadly%20Delivery.lua"))()')
end

if require(game:GetService("ReplicatedStorage").Shared.Core.AssetId).world ~= "Dungeon" then return end
local OverlayAPI = loadstring(game:HttpGet("https://raw.githubusercontent.com/SNSDARK/Scripts/refs/heads/main/DeadlyDeliveryGUI.lua"))()
require(game:GetService("ReplicatedStorage").Shared.Core.FeatureManager).Set("AltUnlock", "UnLockMouse", true, 100)
local LootFolder = game:GetService("Workspace").GameSystem.Loots.World
local ClosetFolder = game:GetService("Workspace").GameSystem.InteractiveItem
local NPCFolder = game:GetService("Workspace").GameSystem.NPCModels
local Elevator = Vector3.new(-310.421204, 323.808197, 406.190948)
local pulledItems = {}
local pullConnections = {}
local StartedScript = os.clock()
local function formatTime(seconds)
    seconds = math.floor(seconds)
    local hours = math.floor(seconds / 3600)
    local remainingAfterHours = seconds - (hours * 3600)
    local minutes = math.floor(remainingAfterHours / 60)
    local secs = remainingAfterHours - (minutes * 60) 
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

local function TweeningService(toTween, TargetPos, Delay)
    local TweenService = game:GetService("TweenService")
    local tweenInfo = TweenInfo.new(
        Delay, -- Time length
        Enum.EasingStyle.Linear, -- Easing style
        Enum.EasingDirection.Out, -- Easing direction
        0, -- Repeat count (0 means don't repeat)
        false, -- Reverse
        0 -- Delay time
    )
    local tweenGoal = {}
    if toTween:IsA("BasePart") then
        tweenGoal.CFrame = TargetPos
    else
        tweenGoal.Position = TargetPos
    end
    local tween = TweenService:Create(toTween, tweenInfo, tweenGoal)
    tween:Play()
    return tween
end

local function CheckFullInv()
    local ItemOnInv = 0
    local MaxItems = 0
    local CrocoEggToStore = false
    for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Bottom:GetChildren()) do
        if v:IsA("Frame") then
            MaxItems = MaxItems + 1
            if v.ItemDetails.ItemName.Text ~= "" then
                ItemOnInv = ItemOnInv + 1
            end
            if v.ItemDetails.ItemName.Text == "Crocodile Egg" then
                CrocoEggToStore = true
            end
        end
    end
    if ItemOnInv >= MaxItems or game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.HandsFull.Visible or CrocoEggToStore then
        for _,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Bottom:GetChildren()) do
            if v:IsA("Frame") and v.ItemDetails.ItemName.Text ~= "" then
                local Timeout = false
                spawn(function()
                    task.wait(10)
                    Timeout = true
                end)
                repeat task.wait()
                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-310.421204, 323.808197, 406.190948, -0.999934316, 1.79530457e-09, -0.0114607625, 7.40721373e-10, 1, 9.20210894e-08, 0.0114607625, 9.20065588e-08, -0.999934316)
                until v.ItemDetails.ItemName.Text == "" or Timeout
            end
        end
    end
end

local function HasPrimaryPart(model)
    return model.PrimaryPart ~= nil
end

local function CheckInteractables(Bool)
    local checkChests = Bool == nil or Bool == "Chests"
    local checkItems = Bool == nil or Bool == "Items"
    local checkNPC = Bool == nil or Bool == "NPC"
    if checkChests then
        for _, v in pairs(game:GetService("Workspace").GameSystem.InteractiveItem:GetChildren()) do
            if v and v:GetAttribute("Open") == false and v:GetAttribute("en") and not v:GetAttribute("ItemDropped") then
                return true
            end
        end
    end
    if checkItems then
        for _, v in pairs(game:GetService("Workspace").GameSystem.Loots.World:GetChildren()) do
            if v and v:GetAttribute("en") then
                if v:IsA("Tool") and v:GetAttribute("Size") and v:HasTag("Interactable") and not v:GetAttribute("Nigga") then
                    local folder = v:FindFirstChild("Folder")
                    if folder then
                        local interactable = folder:FindFirstChild("Interactable")
                        if interactable then
                            local lootUI = interactable:FindFirstChild("LootUI")
                            if lootUI then
                                local frame = lootUI:FindFirstChild("Frame")
                                if frame then
                                    local itemName = frame:FindFirstChild("ItemName")
                                    if itemName and itemName.Text ~= "Bloxy Cola" then
                                        return true
                                    end
                                end
                            end
                        end
                    else
                        return true
                    end
                end
                if v:IsA("Model") and HasPrimaryPart(v) then
                    local interactable = v:FindFirstChild("Interactable")
                    if interactable then
                        local lootUI = interactable:FindFirstChild("LootUI")
                        if lootUI then
                            local frame = lootUI:FindFirstChild("Frame")
                            if frame then
                                local itemName = frame:FindFirstChild("ItemName")
                                if itemName and itemName.Text == "Cash" then
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if checkNPC then
        for _,v in pairs(game:GetService("Workspace").GameSystem.NPCModels:GetChildren()) do
            if v and v:GetAttribute("en") then
                return true
            end
        end
    end
    
    return false
end

getgenv().PullItems = true

local CanSetSimulationRadius = false

local function AutoCollectOpen()
    local TEvent = require(game:GetService("ReplicatedStorage").Shared.Core.TEvent)
    local PLR = game:GetService("Players").LocalPlayer
    local ClosetFolder = game:GetService("Workspace").GameSystem.InteractiveItem
    local LootFolder = game:GetService("Workspace").GameSystem.Loots.World
    local NPCFolder = game:GetService("Workspace").GameSystem.NPCModels
    local collectCooldown = 0.1
    local function canCollect(item)
        if not item then return false end
        if not item:GetAttribute("lastCooldown") then
            item:SetAttribute("lastCooldown", tick())
            return true
        end
        return tick() - item:GetAttribute("lastCooldown") >= collectCooldown
    end
    local function CollectOpen(item)
        if not PLR.Character or not PLR.Character.PrimaryPart then return end
        if not item or not HasPrimaryPart(item) then return end
        local distance = (item.PrimaryPart.Position - PLR.Character.PrimaryPart.Position).Magnitude
        if distance < 20 and canCollect(item) then
            if not item:GetAttribute("InteractCount") then
                item:SetAttribute("InteractCount", 1)
            else
                local IncreaseCount = item:GetAttribute("InteractCount") + 1
                item:SetAttribute("InteractCount", IncreaseCount)
            end
            TEvent.FireRemote("Interactable", item)
            item:SetAttribute("lastCooldown", tick())
        end
    end
    local function ShouldCollectItem(v)
        if not v or not v:GetAttribute("en") then return false end
        if v:IsA("Tool") then
            if v:GetAttribute("Size") and v:HasTag("Interactable") and not v:GetAttribute("Nigga") then
                local folder = v:FindFirstChild("Folder")
                if folder then
                    local interactable = folder:FindFirstChild("Interactable")
                    if interactable then
                        local lootUI = interactable:FindFirstChild("LootUI")
                        if lootUI then
                            local frame = lootUI:FindFirstChild("Frame")
                            if frame then
                                local itemName = frame:FindFirstChild("ItemName")
                                if itemName and itemName.Text ~= "Bloxy Cola" then
                                    return true
                                end
                            end
                        end
                    end
                end
            end
        elseif v:IsA("Model") and HasPrimaryPart(v) and v:HasTag("Interactable") then
            local interactable = v:FindFirstChild("Interactable")
            if interactable then
                local lootUI = interactable:FindFirstChild("LootUI")
                if lootUI then
                    local frame = lootUI:FindFirstChild("Frame")
                    if frame then
                        local itemName = frame:FindFirstChild("ItemName")
                        if itemName and itemName.Text == "Cash" then
                            return true
                        end
                    end
                end
            end
        end
        
        return false
    end
    while task.wait() do
        if not PLR.Character or not PLR.Character.PrimaryPart then
            task.wait(1)
        else
            if CheckInteractables() then
                if CheckInteractables("Chests") then
                    for _, v in pairs(ClosetFolder:GetChildren()) do
                        if v and v:GetAttribute("Open") == false and v:GetAttribute("en") and canCollect(v) then
                            TEvent.FireRemote("Interactable", v)
                        end
                    end
                end
                if CheckInteractables("Items") then
                    for _, v in pairs(LootFolder:GetChildren()) do
                        if ShouldCollectItem(v) then
                            if HasPrimaryPart(v) then
                                if not v:GetAttribute("Teleported") then
                                    v:SetAttribute("Teleported", tick())
                                end
                                
                                local timeSinceTeleport = tick() - v:GetAttribute("Teleported")
                                if (CanSetSimulationRadius and timeSinceTeleport >= 5 or v:FindFirstChild("Folder") and v.Folder.Interactable.LootUI.Frame.ItemName.Text == "Crocodile Egg") or not CanSetSimulationRadius then
                                    local lastParent = v.Parent
                                    local TeleportTolastPos = false
                                    local lastPos = PLR.Character.HumanoidRootPart.CFrame
                                    if v:FindFirstChild("Folder") and v.Folder.Interactable.LootUI.Frame.ItemName.Text == "Crocodile Egg" then
                                        TeleportTolastPos = true
                                    end
                                    repeat 
                                        task.wait()
                                        if HasPrimaryPart(v) then
                                            if (v.PrimaryPart.Position - PLR.Character.HumanoidRootPart.Position).Magnitude > 20 and CanSetSimulationRadius or (v:FindFirstChild("Folder") and v.Folder.Interactable.LootUI.Frame.ItemName.Text == "Crocodile Egg" or not CanSetSimulationRadius) then
                                                pcall(function()
                                                    PLR.Character.HumanoidRootPart.CFrame = CFrame.new(
                                                        v.PrimaryPart.Position + Vector3.new(0, 10, 0)
                                                    )
                                                end)
                                            end
                                            CheckFullInv()
                                            CollectOpen(v)
                                            if v:GetAttribute("InteractCount") and v:GetAttribute("InteractCount") >= 5 then
                                                v:SetAttribute("Nigga", true)
                                            end
                                        end
                                    until not v or v.Parent ~= lastParent or v:GetAttribute("Nigga") or not HasPrimaryPart(v)
                                    if TeleportTolastPos then
                                        PLR.Character.HumanoidRootPart.CFrame = lastPos
                                    end
                                end
                            end
                        end
                    end
                end
                if CheckInteractables("NPC") then
                    for _, v in pairs(NPCFolder:GetChildren()) do
                        if v and v:GetAttribute("en") and HasPrimaryPart(v) then
                            pcall(function()
                                PLR.Character.HumanoidRootPart.CFrame = CFrame.new(
                                    v.PrimaryPart.Position + Vector3.new(0, 10, 0)
                                )
                            end)
                            CollectOpen(v)
                        end
                    end
                end
            else
                pcall(function()
                    PLR.Character.HumanoidRootPart.CFrame = CFrame.new(-310.421204, 323.808197, 406.190948)
                end)
                repeat task.wait() until CheckInteractables()
            end
        end
    end
end

local function AlwaysInElevator()
    local TEvent = require(game:GetService("ReplicatedStorage").Shared.Core.TEvent)
    local ValueMod = require(game:GetService("ReplicatedStorage").Shared.Core.Value)
    while task.wait() do
        if ValueMod.IsHidding.Value ~= "InElevator" then
            TEvent.FireRemote("PlayerInElevator", true, game.Players.LocalPlayer.Character.PrimaryPart.CFrame.Position, TEvent.UnixTimeMillis())
            task.wait(.1)
        end
    end
end

local function NextFloorVote()
    local ValueMod = require(game:GetService("ReplicatedStorage").Shared.Core.Value)
    local Data;
    local function CheckPlayerDead()
        if ValueMod.PlayerState._value ~= "Alive" then
            OverlayAPI.Update({CurrentStatus = "Current Floor "..tostring(ValueMod.DungeonStats._value.level).." | You died, returning to lobby"})
            require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("ReturnToLobby")
            task.wait(10)
        end
    end
    local goLobby = getgenv().GoLobby or false
    local function DataUpdate()
        local TotalCash = 0
        for i,v in ValueMod.DungeonStats._value.loots do
            TotalCash = TotalCash + v.sell
        end
        local SoldItems = "No"
        if goLobby then
            SoldItems = "Yes"
        end
        Data = game:GetService("HttpService"):JSONEncode({
            ["username"] = "Deadly Delivery Escaped",
            ["content"] = game.Players.LocalPlayer.Name,
            ["embeds"] = {{
                    ["title"] = "Money Earned",
                    ["description"] = string.format("**$%s**\n**Goal:** $%s\n**Floor:** %s\n**Sellable + Coins Earned:** $%s + $%s\n**Total Cash:** $%s\n**Sold?:** %s\n\nUpdated %s", 
                        ValueMod.DungeonStats._value.totalPrice, 
                        ValueMod.DungeonStats._value.goal,
                        ValueMod.DungeonStats._value.level,
                        TotalCash,
                        ValueMod.DungeonStats._value.cash,
                        ValueMod.Item._value[101],
                        SoldItems,
                        string.format("<t:%d:R>", os.time())
                    ),
                    ["color"] = 5763719, -- Blue color
                    ["footer"] = {
                        ["text"] = "Finished in: " .. formatTime(os.clock() - StartedScript)
                    }
                }}
            })
    end
    local Pass = true
    while true do
        OverlayAPI.Update({CurrentStatus = "Current Floor "..tostring(ValueMod.DungeonStats._value.level).." | Waiting"})
        CheckPlayerDead()
        task.wait()
        local currentTime = os.clock()
        while Pass do task.wait(.5)
            OverlayAPI.Update({CurrentStatus = "Current Floor "..tostring(ValueMod.DungeonStats._value.level).." | Grabbing items"})
            CheckPlayerDead()
            local Check = CheckInteractables()
            if Check then
                currentTime = os.clock()
            end
            if (os.clock() - currentTime) >= 5 and not Check then
                Pass = false
                break
            end
        end
        if ValueMod.DungeonStats._value.canVote then
            local CurrentFloor = ValueMod.DungeonStats._value.level
            if CurrentFloor >= 30 or not ValueMod.GetAllValue().DungeonStats.canContinue then
                OverlayAPI.Update({CurrentStatus = "Current Floor "..tostring(ValueMod.DungeonStats._value.level).." | Done, waiting to go in lobby"})
                require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("SubmitVote", "retreat")
                DataUpdate()
                repeat task.wait() until ValueMod.GetAllValue().DungeonStats.isEnd
                queue_on_teleport('loadstring(game:HttpGet("https://raw.githubusercontent.com/SNSDARK/Scripts/refs/heads/main/Deadly%20Delivery.lua"))()')
                http_request({Url = WebhookURL, Body = Data, Method = "POST", Headers = {["Content-Type"] = "application/json"}})
                task.wait()
                if goLobby then
                    require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("ReturnToLobby")
                else
                    local TeleportService = cloneref(game:GetService("TeleportService"))
                    game.Players.LocalPlayer:Kick("\n\nReconnecting...")
                    TeleportService:Teleport(game.PlaceId, game.Players.LocalPlayer)
                end
                task.wait(10)
            end
            require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("SubmitVote", "continue")
            OverlayAPI.Update({CurrentStatus = "Current Floor "..tostring(ValueMod.DungeonStats._value.level).." | Voted to next Floor"})
            Pass = true
            repeat task.wait() 
                CheckPlayerDead()
            until ValueMod.DungeonStats._value.level ~= CurrentFloor
        end
    end
end

task.spawn(AlwaysInElevator)
task.spawn(NextFloorVote)
task.spawn(AutoCollectOpen)
