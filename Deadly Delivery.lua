getgenv().WebhookURL = "https://discord.com/api/webhooks/1374670443159490564/8g747eHRDImcJd6wMc0pZ3JzSvRuatD0LZ593Jvoqu8jegLKZ8hfE81FomlZRtvUINFE"
local MainScript = [[repeat task.wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and game:FindService("NetworkClient")
if getgenv().ScriptStarted then return end
getgenv().ScriptStarted = true
task.wait(2)
local Players = game.Players
local PLR = Players.LocalPlayer
local TeleportService = cloneref(game:GetService("TeleportService"))
local CoreGui = cloneref(game:GetService("CoreGui"))
local PromptGui = CoreGui:WaitForChild("RobloxPromptGui", 10)
local Overlay = PromptGui and PromptGui:WaitForChild("promptOverlay", 10)
PLR.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

local function IsPlayerKicked(): boolean
    if not Overlay then return false end
    for _, child in ipairs(Overlay:GetChildren()) do
        if child:IsA("Frame") and child.Name == "ErrorPrompt" then
            return true
        end
    end
    return false
end

local function Reconnect()
    local playersCount = #Players:GetPlayers()
    if playersCount <= 1 then
        warn("[AutoReconnect] Player kicked — rejoining new server...")
        PLR:Kick("\n\nReconnecting...")
        task.wait(5)
        TeleportService:Teleport(game.PlaceId, PLR)
    else
        warn("[AutoReconnect] Player kicked — rejoining current instance...")
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, PLR)
    end
end

task.spawn(function()
    while task.wait(2) do
        if IsPlayerKicked() then
            Reconnect()
        end
    end
end)

if Overlay then
    Overlay.ChildAdded:Connect(function(child)
        if child.Name == "ErrorPrompt" then
            task.wait(1)
            Reconnect()
        end
    end)
end

warn("[AutoReconnect] Loaded and monitoring for kicks.")
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
        -- Basic validation for webhook URL format
        if not url:find("discord%.com/api/webhooks/") then
            print("Warning: This doesn't look like a Discord webhook URL.")
            print("Webhooks usually look like: https://discord.com/api/webhooks/...")
        end
        
        -- Write to file
        local success, errorMsg = pcall(function()
            writefile("DeadlyDeliveryWH.txt", url)
        end)
        
        if success then
            print("Webhook URL saved successfully!")
            print("File saved as: DeadlyDeliveryWH.txt")
            return true
        else
            print("Error saving webhook: " .. tostring(errorMsg))
            return false
        end
    else
        print("Please provide a valid URL string")
        return false
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
if isfile("Deadly_Delivery.lua") then
    queue_on_teleport('loadstring(readfile("Deadly_Delivery.lua"))()')
end
if game.PlaceId == 125810438250765 then
    require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("BackpackSellAll")
    local function StartMatch()
        for _, v in pairs(game:GetService("Workspace").Match:GetChildren()) do
            if v and v:FindFirstChild("Left") and v.Left:FindFirstChild("ScreenPart") and v.Left.ScreenPart:FindFirstChild("SurfaceGui") and v.Left.ScreenPart.SurfaceGui:FindFirstChild("Creating") and v.Left.ScreenPart.SurfaceGui:FindFirstChild("Countdown") and (not v.Left.ScreenPart.SurfaceGui.Creating.Visible and not v.Left.ScreenPart.SurfaceGui.Countdown.Visible) then
                require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("JoinMatch", v:GetAttribute("MatchId"))
                task.wait(.5)
                require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("UploadSetting", {size = 1, onlyFriends = true})
                task.wait(20)
            end
        end
    end
    StartMatch()
end

if game.PlaceId == 125810438250765 then return end
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
    for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Bottom:GetChildren()) do
        if v:IsA("Frame") then
            MaxItems = MaxItems + 1
            if v.ItemDetails.ItemName.Text ~= "" then
                ItemOnInv = ItemOnInv + 1
            end
        end
    end
    if ItemOnInv >= MaxItems or game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.HandsFull.Visible then
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
local success, err = pcall(function()
    local current = getsimulationradius()
    setsimulationradius(math.huge)
    -- Try to set it back to verify it works
    setsimulationradius(current)
    CanSetSimulationRadius = true
end)

if not success then
    warn("setsimulationradius not functional: " .. tostring(err))
    CanSetSimulationRadius = false
end

local function IsPlayerItem(item)
    for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
        if player.Character and item:IsDescendantOf(player.Character) then
            return true
        end
    end
    return false
end

local function IsPullableItem(item)
    if not item:IsA("BasePart") then return false end
    if item.Anchored then return false end
    if not item.Parent then return false end
    if not item:IsDescendantOf(LootFolder) then return false end
    if IsPlayerItem(item) then return false end
    return true
end

local function AddToPullList(item)
    if item:IsA("BasePart") then
        if IsPullableItem(item) and not table.find(pulledItems, item) then
            item.CanCollide = false
            sethiddenproperty(item, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
            table.insert(pulledItems, item)
        end
    end
end

local function AddModelPartsToPullList(model)
    for _, part in pairs(model:GetDescendants()) do
        if part:IsA("BasePart") and IsPullableItem(part) and not table.find(pulledItems, part) then
            part.CanCollide = false
            sethiddenproperty(part, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
            table.insert(pulledItems, part)
        end
    end
end

local function RemoveFromPullList(item)
    local index = table.find(pulledItems, item)
    if index then
        table.remove(pulledItems, index)
    end
end

local function ShouldPullItem(item)
    if item:IsA("Tool") then
        return item:GetAttribute("Size") and item:GetAttribute("en") and item:HasTag("Interactable")
    elseif item:IsA("Model") then
        if HasPrimaryPart(item) and item:GetAttribute("en") and item:HasTag("Interactable") then
            local interactable = item:FindFirstChild("Interactable")
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
    return false
end

for _, v in ipairs(LootFolder:GetChildren()) do
    if ShouldPullItem(v) then
        AddModelPartsToPullList(v)
    end
end

local function HandleDescendantAdded(descendant)
    AddToPullList(descendant)
    
    if descendant:IsA("Tool") or descendant:IsA("Model") then
        if ShouldPullItem(descendant) then
            task.wait()
            AddModelPartsToPullList(descendant)
        end
    end
end

local function HandleDescendantRemoving(descendant)
    if descendant:IsA("BasePart") then
        RemoveFromPullList(descendant)
    elseif descendant:IsA("Model") or descendant:IsA("Tool") then
        for _, part in pairs(descendant:GetDescendants()) do
            if part:IsA("BasePart") then
                RemoveFromPullList(part)
            end
        end
    end
end

pullConnections.Added = LootFolder.DescendantAdded:Connect(HandleDescendantAdded)
pullConnections.Removed = LootFolder.DescendantRemoving:Connect(HandleDescendantRemoving)

pullConnections.Heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
    if not getgenv().PullItems then return end
    
    if CanSetSimulationRadius then
        setsimulationradius(math.huge)
    end
    
    if #pulledItems > 0 then
        for i = #pulledItems, 1, -1 do
            local item = pulledItems[i]
            if item and item.Parent and item:IsA("BasePart") and not item.Anchored then
                local targetPos = Elevator
                local distance = (item.Position - targetPos).Magnitude
                if distance > 3 then
                    item.Velocity = (targetPos - item.Position).Unit * 150
                    item.CanCollide = false
                else
                    item.Velocity = Vector3.zero
                    item.CanCollide = true
                    table.remove(pulledItems, i)
                end
            else
                table.remove(pulledItems, i)
            end
        end
    end
end)

local function AutoCollectOpen()
    local TEvent = require(game:GetService("ReplicatedStorage").Shared.Core.TEvent)
    local PLR = game:GetService("Players").LocalPlayer
    
    -- Define folders
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
        -- Check player exists
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
    
    -- Helper function to check if item should be collected
    local function ShouldCollectItem(v)
        if not v or not v:GetAttribute("en") then return false end
        
        -- Check Tools
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
            
        -- Check Models
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
        -- Safety check for player
        if not PLR.Character or not PLR.Character.PrimaryPart then
            task.wait(1)
        else
            if CheckInteractables() then
                -- Chests
                if CheckInteractables("Chests") then
                    for _, v in pairs(ClosetFolder:GetChildren()) do
                        if v and v:GetAttribute("Open") == false and v:GetAttribute("en") and canCollect(v) then
                            TEvent.FireRemote("Interactable", v)
                        end
                    end
                end
                
                -- Items
                if CheckInteractables("Items") then
                    for _, v in pairs(LootFolder:GetChildren()) do
                        if ShouldCollectItem(v) then
                            if HasPrimaryPart(v) then
                                if not v:GetAttribute("Teleported") then
                                    v:SetAttribute("Teleported", tick())
                                end
                                
                                local timeSinceTeleport = tick() - v:GetAttribute("Teleported")
                                
                                -- Fixed logic: properly parenthesized
                                if (CanSetSimulationRadius and timeSinceTeleport >= 5 or v.Folder.Interactable.LootUI.Frame.ItemName.Text == "Crocodile Egg") or not CanSetSimulationRadius then
                                    local lastParent = v.Parent
                                    repeat 
                                        task.wait()
                                        if HasPrimaryPart(v) then
                                            pcall(function()
                                                PLR.Character.HumanoidRootPart.CFrame = CFrame.new(
                                                    v.PrimaryPart.Position + Vector3.new(0, 10, 0)
                                                )
                                            end)
                                            CheckFullInv()
                                            CollectOpen(v)
                                            if v:GetAttribute("InteractCount") and v:GetAttribute("InteractCount") >= 5 then
                                                v:SetAttribute("Nigga", true)
                                            end
                                        end
                                    until not v or v.Parent ~= lastParent or v:GetAttribute("Nigga") or not HasPrimaryPart(v)
                                end
                            end
                        end
                    end
                end
                
                -- NPCs
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
                -- Return to elevator position
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
    local Data;
    local function DataUpdate()
        local TotalCash = 0
        for i,v in require(game:GetService("ReplicatedStorage").Shared.Core.Value).Item._value do
            TotalCash = tostring(v)
            break
        end
        Data = game:GetService("HttpService"):JSONEncode({
            ["username"] = "Deadly Delivery Escaped",
            ["content"] = game.Players.LocalPlayer.Name,
            ["embeds"] = {{
                    ["title"] = "Money Earned",
                    ["description"] = string.format("**$%s**\n**Goal:** $%s\n**Floor:** %s\n**Total Cash:** $%s\n\nUpdated %s", 
                        string.match(game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Goal.GoalProgressBar.GoalText.Cash.Text,"(%d+)"), 
                        string.match(game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Goal.GoalProgressBar.GoalText.Goal.Text, "(%d+)"),
                        string.match(game:GetService("Workspace")["\231\148\181\230\162\175"]["\231\167\187\229\138\1681"]["\231\148\181\230\162\175\233\151\168\229\143\163"].ElevatorUI.SurfaceGui.Frame.PowerText.Text, "(%d+)"),
                        TotalCash,
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
    local ValueMod = require(game:GetService("ReplicatedStorage").Shared.Core.Value)
    while true do
        if ValueMod.PlayerState._value ~= "Alive" then
            require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("ReturnToLobby")
            task.wait(10)
        end
        task.wait()
        local currentTime = os.clock()
        while Pass do task.wait(.5)
            if ValueMod.PlayerState._value ~= "Alive" then
                require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("ReturnToLobby")
                task.wait(10)
            end
            local Check = false
            local Check = CheckInteractables()
            if Check then
                currentTime = os.clock()
            end
            if (os.clock() - currentTime) >= 5 and not Check then
                Pass = false
                break
            end
        end
        if workspace["\231\148\181\230\162\175"].Left4["\230\142\167\229\136\182\229\143\176"].Yellowky.ContinuePart:GetAttribute("en") then
            local CurrentFloorText = game:GetService("Workspace")["\231\148\181\230\162\175"]["\231\167\187\229\138\1681"]["\231\148\181\230\162\175\233\151\168\229\143\163"].ElevatorUI.SurfaceGui.Frame.PowerText.Text
            local CurrentFloor = tonumber(string.match(CurrentFloorText, "(%d+)"))
            if CurrentFloor >= 30 then
                require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("SubmitVote", "retreat")
                DataUpdate()
                task.wait(20)
                http_request({Url = WebhookURL, Body = Data, Method = "POST", Headers = {["Content-Type"] = "application/json"}})
            end
            repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Countdown.Visible
            require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("SubmitVote", "continue")
            Pass = true
            repeat task.wait() 
                if game:GetService("Players").LocalPlayer.PlayerGui.Main.Func.Tip.Visible and game:GetService("Players").LocalPlayer.PlayerGui.Main.Func.Tip.TipContent.Text == "Goal not complete, collect more food!" then
                    require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("SubmitVote", "retreat")
                    DataUpdate()
                    task.wait(20)      
                    http_request({Url = WebhookURL, Body = Data, Method = "POST", Headers = {["Content-Type"] = "application/json"}})
                end
            until not game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Countdown.Visible
        end
    end
end

task.spawn(AlwaysInElevator)
task.spawn(NextFloorVote)
task.spawn(AutoCollectOpen)]]

local func, err = loadstring(MainScript)
if not func then
    warn("Loadstring failed, error below\n\n", err)
else
    print("successfully loaded script!")
end

--Load stuff, not intended to be included on MainScript

writefile("Deadly_Delivery.lua", MainScript)
loadstring(readfile("Deadly_Delivery.lua"))()
