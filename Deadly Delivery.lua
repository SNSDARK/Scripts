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

for _, cnx in pairs(getconnections(game:GetService("RunService").PreRender)) do
    local src = debug.info(cnx.Function, "s")
    if src:find("Stamina") then
        cnx:Disable()
    end
end

local function HasPrimaryPart(instance)
    return instance and instance:IsA("Model") and instance.PrimaryPart ~= nil
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

local function CheckInteractables(Bool)
    if Bool == "Chests" or Bool == nil then
        for _, v in pairs(game:GetService("Workspace").GameSystem.InteractiveItem:GetChildren()) do
            if v and v:GetAttribute("Open") == false and v:GetAttribute("en") and not v:GetAttribute("ItemDropped") then
                return true
            end
        end
    end
    if Bool == "Items" or Bool == nil then
        for _, v in pairs(game:GetService("Workspace").GameSystem.Loots.World:GetChildren()) do
            if v and v:IsA("Tool") and v:GetAttribute("Size") and v:GetAttribute("en") and v:HasTag("Interactable") and not v:GetAttribute("Nigga") and (v:FindFirstChild("Folder") and v.Folder:FindFirstChild("Interactable") and v.Folder.Interactable:FindFirstChild("LootUI") and v.Folder.Interactable.LootUI:FindFirstChild("Frame") and v.Folder.Interactable.LootUI.Frame:FindFirstChild("ItemName") and v.Folder.Interactable.LootUI.Frame.ItemName.Text ~= "Bloxy Cola") then
                local CurrentFloorText = game:GetService("Workspace")["\231\148\181\230\162\175"]["\231\167\187\229\138\1681"]["\231\148\181\230\162\175\233\151\168\229\143\163"].ElevatorUI.SurfaceGui.Frame.PowerText.Text
                local CurrentFloor = tonumber(string.match(CurrentFloorText, "(%d+)"))
                local ItemPriceText = v.Folder.Interactable.LootUI.Frame.Price.Text
                local ItemPrice = tonumber(string.match(ItemPriceText, "(%d+)"))
                local AcceptablePrice = 0
                if CurrentFloor >= 20 then AcceptablePrice = 40 end; if CurrentFloor >= 18 and CurrentFloor < 20 then AcceptablePrice = 30 end; if CurrentFloor >= 10 and CurrentFloor < 18 then AcceptablePrice = 20 end; if CurrentFloor < 10 then AcceptablePrice = 10 end
                if ItemPrice >= AcceptablePrice then
                    return true
                end
            end
        end
    end
    if Bool == "NPC" or Bool == nil then
        for _,v in pairs(game:GetService("Workspace").GameSystem.NPCModels:GetChildren()) do
            if v and v:GetAttribute("en") then
                return true
            end
        end
    end
    return false
end

local lastCollect = 0
local collectCooldown = 0.1
local function canCollect()
    return tick() - lastCollect >= collectCooldown
end

local HasSimrad = false
local success, err = pcall(setsimulationradius)

if success then
    HasSimrad = true
end

if HasSimrad then
    local LootFolder = game:GetService("Workspace").GameSystem.Loots.World
    local Elevator = Vector3.new(-310.421204, 323.808197, 406.190948)
    local pulledItems = {}
    local pullConnections = {}

    getgenv().PullItems = true

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
    if IsPullableItem(item) and not table.find(pulledItems, item) then
        item.CanCollide = false
        sethiddenproperty(item, "NetworkOwnershipRule", Enum.NetworkOwnership.Manual)
        table.insert(pulledItems, item)
    end 
    end

    local function RemoveFromPullList(item)
    local index = table.find(pulledItems, item)
    if index then
        table.remove(pulledItems, index)
    end
    end

    -- Initialize: Add existing items and set up connections
    for _, item in ipairs(LootFolder:GetDescendants()) do
    AddToPullList(item)
    end

    pullConnections.Added = LootFolder.DescendantAdded:Connect(AddToPullList)
    pullConnections.Removed = LootFolder.DescendantRemoving:Connect(RemoveFromPullList)

    -- Main pulling loop
    pullConnections.Heartbeat = game:GetService("RunService").Heartbeat:Connect(function()
    if not getgenv().PullItems then return end

    setsimulationradius(math.huge)

    if #pulledItems > 0 then
        for i = #pulledItems, 1, -1 do
            local item = pulledItems[i]
            if item and item.Parent and item:IsA("BasePart") and not item.Anchored then
                local targetPos = Elevator
                local distance = (item.Position - targetPos).Magnitude
                local lastVelocity = item.Velocity
                if distance > 3 then
                    item.Velocity = (targetPos - item.Position).Unit * 150
                    item.CanCollide = false
                else
                    item.Velocity = lastVelocity
                    item.CanCollide = true
                    table.remove(pulledItems, i)
                end
            else
                table.remove(pulledItems, i)
            end
        end
    end
    end)
end

local function AutoCollect()
    local TEvent = require(game:GetService("ReplicatedStorage").Shared.Core.TEvent)
    local ValueMod = require(game:GetService("ReplicatedStorage").Shared.Core.Value)
    while CheckInteractables() do task.wait()
        if CheckInteractables("Chests") then
            print("Opening Chests, Closets, Stuff")
            repeat task.wait()
            if canCollect()  then
                lastCollect = tick()
                for _, v in pairs(game:GetService("Workspace").GameSystem.InteractiveItem:GetChildren()) do
                    if v and v:GetAttribute("Open") == false and v:GetAttribute("en") then
                        TEvent.FireRemote("Interactable", v)
                    end
                end
            end
            until not CheckInteractables("Chests")
            print("Done Opening Stuff")
        end
        if CheckInteractables("Items") and not HasSimrad then
            print("Collecting Items")
            repeat task.wait()
                for _, v in pairs(game:GetService("Workspace").GameSystem.Loots.World:GetChildren()) do
                    if not HasSimrad and v and v:IsA("Tool") and v:GetAttribute("Size") and v:GetAttribute("en") and v:HasTag("Interactable") and not v:GetAttribute("Nigga") and (v:FindFirstChild("Folder") and v.Folder:FindFirstChild("Interactable") and v.Folder.Interactable:FindFirstChild("LootUI") and v.Folder.Interactable.LootUI:FindFirstChild("Frame") and v.Folder.Interactable.LootUI.Frame:FindFirstChild("ItemName") and v.Folder.Interactable.LootUI.Frame.ItemName.Text ~= "Bloxy Cola") then
                        local CurrentFloorText = game:GetService("Workspace")["\231\148\181\230\162\175"]["\231\167\187\229\138\1681"]["\231\148\181\230\162\175\233\151\168\229\143\163"].ElevatorUI.SurfaceGui.Frame.PowerText.Text
                        local CurrentFloor = tonumber(string.match(CurrentFloorText, "(%d+)"))
                        local ItemPriceText = v.Folder.Interactable.LootUI.Frame.Price.Text
                        local ItemPrice = tonumber(string.match(ItemPriceText, "(%d+)"))
                        local CurrentParent = v.Parent
                        local AcceptablePrice = 0
                        CheckFullInv()
                        if CurrentFloor >= 20 then AcceptablePrice = 40 end; if CurrentFloor >= 18 and CurrentFloor < 20 then AcceptablePrice = 30 end; if CurrentFloor >= 10 and CurrentFloor < 18 then AcceptablePrice = 20 end; if CurrentFloor < 10 then AcceptablePrice = 10 end
                        if ItemPrice >= AcceptablePrice then
                            repeat
                                task.wait()
                                if not v or v.Parent ~= CurrentParent or v:GetAttribute("Nigga") then
                                    break
                                end
                                pcall(function()
                                    game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v.PrimaryPart.CFrame.x, v.PrimaryPart.CFrame.y + 10, v.PrimaryPart.CFrame.z)
                                end)
                                if canCollect() then
                                    lastCollect = tick()
                                    TEvent.FireRemote("Interactable", v)
                                    if not v:GetAttribute("PickedUp") then
                                        v:SetAttribute("PickedUp", 1)
                                    else
                                        if v:GetAttribute("PickedUp") >= 20 then
                                            v:SetAttribute("Nigga", true)
                                            print(v.Folder.Interactable.LootUI.Frame.ItemName.Text.." was unable to pick up with price of $"..ItemPrice.."\nItem ID: "..v:GetAttribute("id").."\nUnique ID: "..v:GetAttribute("uid").."\nStuff: "..require(game:GetService("ReplicatedStorage").Shared.Core.ConstFunc).GetType(v:GetAttribute("id")))
                                            for i2,v2 in pairs(v:GetTags()) do
                                                print(i2,v2)
                                            end
                                            break
                                        else
                                            local CurrentCount = v:GetAttribute("PickedUp") + 1
                                            v:SetAttribute("PickedUp", CurrentCount)
                                        end
                                    end
                                end
                            until not v or v.Parent ~= CurrentParent or v:GetAttribute("Nigga")
                        end
                    end
                end
            until not CheckInteractables("Items")
            print("Done Collecting Items")
        end
        if CheckInteractables("NPC") then
            print("Rescuing NPCs")
            repeat task.wait()
                for _,v in pairs(game:GetService("Workspace").GameSystem.NPCModels:GetChildren()) do
                    if v and v:GetAttribute("en") then
                        pcall(function()
                            game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v.PrimaryPart.CFrame.x, v.PrimaryPart.CFrame.y + 10, v.PrimaryPart.CFrame.z)
                        end)
                        if canCollect() then
                            lastCollect = tick()
                            TEvent.FireRemote("Interactable", v)
                        end
                    end
                end
            until not CheckInteractables("NPC")
            print("Done rescuing NPCs")
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
            local Check = false
            for _, v in pairs(game:GetService("Workspace").GameSystem.InteractiveItem:GetChildren()) do
                if v and v:GetAttribute("Open") == false and v:GetAttribute("en") and not v:GetAttribute("ItemDropped") then
                    Check = true
                end
            end
            for _, v in pairs(game:GetService("Workspace").GameSystem.Loots.World:GetChildren()) do
                if v and v:IsA("Tool") and v:GetAttribute("Size") and v:GetAttribute("en") and v:HasTag("Interactable") and not v:GetAttribute("Nigga") and (v:FindFirstChild("Folder") and v.Folder:FindFirstChild("Interactable") and v.Folder.Interactable:FindFirstChild("LootUI") and v.Folder.Interactable.LootUI:FindFirstChild("Frame") and v.Folder.Interactable.LootUI.Frame:FindFirstChild("ItemName") and v.Folder.Interactable.LootUI.Frame.ItemName.Text ~= "Bloxy Cola") then
                    local CurrentFloorText = game:GetService("Workspace")["\231\148\181\230\162\175"]["\231\167\187\229\138\1681"]["\231\148\181\230\162\175\233\151\168\229\143\163"].ElevatorUI.SurfaceGui.Frame.PowerText.Text
                    local CurrentFloor = tonumber(string.match(CurrentFloorText, "(%d+)"))
                    local ItemPriceText = v.Folder.Interactable.LootUI.Frame.Price.Text
                    local ItemPrice = tonumber(string.match(ItemPriceText, "(%d+)"))
                    local AcceptablePrice = 0
                    if CurrentFloor >= 20 then AcceptablePrice = 40 end; if CurrentFloor >= 18 and CurrentFloor < 20 then AcceptablePrice = 30 end; if CurrentFloor >= 10 and CurrentFloor < 18 then AcceptablePrice = 20 end; if CurrentFloor < 10 then AcceptablePrice = 10 end
                    if ItemPrice >= AcceptablePrice then
                        Check = true
                    end
                    if v:IsA("Model") and HasPrimaryPart(v) and v:GetAttribute("en") and (v:FindFirstChild("Interactable") and v.Interactable:FindFirstChild("LootUI") and v.Interactable.LootUI:FindFirstChild("Frame") and v.Interactable.LootUI.Frame:FindFirstChild("ItemName") and v.Interactable.LootUI.Frame.ItemName.Text == "Cash") then
                        Check = true
                    end
                end
            end
            for _,v in pairs(game:GetService("Workspace").GameSystem.NPCModels:GetChildren()) do
                if v and v:GetAttribute("en") then
                    Check = true
                end
            end
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

local function AutoDungeon()
    while task.wait() do
        if CheckInteractables() then
            AutoCollect()
        end
        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(-310.421204, 323.808197, 406.190948, -0.999934316, 1.79530457e-09, -0.0114607625, 7.40721373e-10, 1, 9.20210894e-08, 0.0114607625, 9.20065588e-08, -0.999934316)
        repeat task.wait() until CheckInteractables()
    end
end

local function AlwaysInElevator()
    local TEvent = require(game:GetService("ReplicatedStorage").Shared.Core.TEvent)
    local ValueMod = require(game:GetService("ReplicatedStorage").Shared.Core.Value)
    while task.wait() do
        if ValueMod.IsHidding.Value ~= "InElevator" then
            TEvent.FireRemote("PlayerInElevator", true, game.Players.LocalPlayer.Character.PrimaryPart.CFrame.Position, TEvent.UnixTimeMillis())
            task.wait(1)
        end
    end
end

task.spawn(AlwaysInElevator)
task.spawn(AutoDungeon)
task.spawn(NextFloorVote)]]

local func, err = loadstring(MainScript)
if not func then
    warn("Loadstring failed, error below\n\n", err)
else
    print("successfully loaded script!")
end

--Load stuff, not intended to be included on MainScript

writefile("Deadly_Delivery.lua", MainScript)
loadstring(readfile("Deadly_Delivery.lua"))()
