repeat task.wait() until game:IsLoaded() and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character and game:FindService("NetworkClient")
task.wait(2)
if not game:GetService("Workspace"):GetAttribute("Take") then
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

if not game:GetService("Workspace"):GetAttribute("Take") or not game:GetService("Workspace"):GetAttribute("Map") then print("Not in dungeon") return end
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

local function HasPrimaryPart(instance)
    return instance and instance:IsA("Model") and instance.PrimaryPart ~= nil
end

local function CollectOpenItem(inst)
    require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("Interactable", inst)
end

local function SellAll()
    require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("BackpackSellAll")
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
        local Tweeny = TweeningService(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, CFrame.new(game:GetService("Workspace")["\231\148\181\230\162\175"].FoodGathering.Part9.Position.x, game:GetService("Workspace")["\231\148\181\230\162\175"].FoodGathering.Part9.Position.y + 3,  game:GetService("Workspace")["\231\148\181\230\162\175"].FoodGathering.Part9.Position.z), 0.01)
        Tweeny.Completed:Wait()
        for _,v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Bottom:GetChildren()) do
            if v:IsA("Frame") and v.ItemDetails.ItemName.Text ~= "" then
                local Timeout = false
                spawn(function()
                    task.wait(5)
                    Timeout = true
                end)
                repeat task.wait()
                    require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("Hotbar_Switch", tonumber(v.Name))
                    task.wait(.1)
                    require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("Hotbar_Drop")
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
            --[[if v and v:GetAttribute("Open") == true and v:GetAttribute("CloseAnim") and v:GetAttribute("en") and v:GetAttribute("ItemDropped") == true then
                return true
            end]]
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
                if CurrentFloor >= 20 then AcceptablePrice = 40 end; if CurrentFloor >= 15 and CurrentFloor < 20 then AcceptablePrice = 30 end; if CurrentFloor >= 10 and CurrentFloor < 15 then AcceptablePrice = 20 end; if CurrentFloor < 10 then AcceptablePrice = 10 end
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

local function CollectAllItems()
    CheckFullInv()
    while CheckInteractables("Items") do task.wait()
        for _, v in pairs(game:GetService("Workspace").GameSystem.Loots.World:GetChildren()) do
            if v:IsA("Tool") and HasPrimaryPart(v) and v:GetAttribute("Size") and v:GetAttribute("en") and v:HasTag("Interactable") and not v:GetAttribute("Nigga") and (v:FindFirstChild("Folder") and v.Folder:FindFirstChild("Interactable") and v.Folder.Interactable:FindFirstChild("LootUI") and v.Folder.Interactable.LootUI:FindFirstChild("Frame") and v.Folder.Interactable.LootUI.Frame:FindFirstChild("ItemName") and v.Folder.Interactable.LootUI.Frame.ItemName.Text ~= "Bloxy Cola") then
                local CurrentFloorText = game:GetService("Workspace")["\231\148\181\230\162\175"]["\231\167\187\229\138\1681"]["\231\148\181\230\162\175\233\151\168\229\143\163"].ElevatorUI.SurfaceGui.Frame.PowerText.Text
                local CurrentFloor = tonumber(string.match(CurrentFloorText, "(%d+)"))
                local ItemPriceText = v.Folder.Interactable.LootUI.Frame.Price.Text
                local ItemPrice = tonumber(string.match(ItemPriceText, "(%d+)"))
                local AcceptablePrice = 0
                if CurrentFloor >= 20 then AcceptablePrice = 40 end; if CurrentFloor >= 15 and CurrentFloor < 20 then AcceptablePrice = 30 end; if CurrentFloor >= 10 and CurrentFloor < 15 then AcceptablePrice = 20 end; if CurrentFloor < 10 then AcceptablePrice = 10 end
                CheckFullInv()
                local ItemParent = v.Parent
                local hasCollected = false
                local initialDelayPassed = false
                local SecondDelayPassed = false
                local ThirdDelayPassed = false
                spawn(function()
                    task.wait(0.1)
                    initialDelayPassed = true
                end)
                spawn(function()
                    task.wait(0.2)
                    SecondDelayPassed = true
                end)
                spawn(function()
                    task.wait(0.3)
                    ThirdDelayPassed = true
                end)
                if ItemPrice >= AcceptablePrice and HasPrimaryPart(v) then
                    repeat task.wait()
                        if v.Parent ~= ItemParent or not HasPrimaryPart(v) then
                            break
                        end
                        local currentTime = os.clock()
                        local Tweeny = TweeningService(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, CFrame.new(v.PrimaryPart.CFrame.x, v.PrimaryPart.CFrame.y + 10, v.PrimaryPart.CFrame.z), 0.01)
                        Tweeny.Completed:Wait()
                        if (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude < 20 then
                            if not hasCollected or initialDelayPassed or SecondDelayPassed then
                                if initialDelayPassed then initialDelayPassed = false end; if SecondDelayPassed then SecondDelayPassed = false end
                                CollectOpenItem(v)
                            end
                        end
                        if ThirdDelayPassed then
                            v:SetAttribute("Nigga", true)
                            break
                        end
                    until not v or v.Parent ~= ItemParent
                end
                CheckFullInv()
            end
        end
    end
end

local function FreeNPCs()
    for _, v in pairs(game:GetService("Workspace").GameSystem.NPCModels:GetChildren()) do
        if v and v:FindFirstChild("HumanoidRootPart") and HasPrimaryPart(v) and v:GetAttribute("en") then
            local CurrentTime = os.clock()
            repeat task.wait()
                local Tweeny = TweeningService(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, CFrame.new(v.PrimaryPart.CFrame.x, v.PrimaryPart.CFrame.y + 10, v.PrimaryPart.CFrame.z), 0.01)
                Tweeny.Completed:Wait()
                if (game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.Position - v.PrimaryPart.Position).Magnitude < 20 then
                    CollectOpenItem(v)
                end
            until not v:GetAttribute("en") or os.clock() - CurrentTime >= 2
        end
    end
end

local function OpenAllStuff()
    for _, v in pairs(game:GetService("Workspace").GameSystem.InteractiveItem:GetChildren()) do
        if v and v:GetAttribute("Open") == false and v:GetAttribute("en") and HasPrimaryPart(v) and not v:GetAttribute("ItemDropped") then
            local CurrentTime = os.clock()
            local initialDelayPassed = false
            local SecondDelayPassed = false
            spawn(function()
                task.wait(0.1)
                initialDelayPassed = true
            end)
            spawn(function()
                task.wait(0.2)
                SecondDelayPassed = true
            end)
            local hasCollected = false
            repeat task.wait()
                local Tweeny = TweeningService(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, CFrame.new(v.PrimaryPart.CFrame.x, v.PrimaryPart.CFrame.y + 10, v.PrimaryPart.CFrame.z), 0.01)
                Tweeny.Completed:Wait()
                if v:GetAttribute("Open") == true then
                    break
                end
                if not hasCollected or initialDelayPassed or SecondDelayPassed then
                    if initialDelayPassed then initialDelayPassed = false end; if SecondDelayPassed then SecondDelayPassed = false end
                    CollectOpenItem(v)
                end
            until v:GetAttribute("Open") == true or (os.clock() - CurrentTime) >= 2
            v:SetAttribute("ItemDropped", true)
        end
        --[[if v and v:GetAttribute("Open") == true and v:GetAttribute("CloseAnim") and v:GetAttribute("en") and HasPrimaryPart(v) and v:GetAttribute("ItemDropped") == true then
            local CurrentTime = os.clock()
            local initialDelayPassed = false
            local SecondDelayPassed = false
            spawn(function()
                task.wait(0.1)
                initialDelayPassed = true
            end)
            spawn(function()
                task.wait(0.2)
                SecondDelayPassed = true
            end)
            local hasCollected = false
            repeat task.wait()
                local Tweeny = TweeningService(game:GetService("Players").LocalPlayer.Character.HumanoidRootPart, CFrame.new(v.PrimaryPart.CFrame.x, v.PrimaryPart.CFrame.y + 10, v.PrimaryPart.CFrame.z), 0.01)
                Tweeny.Completed:Wait()
                if v:GetAttribute("Open") == false then
                    break
                end
                if not hasCollected or initialDelayPassed or SecondDelayPassed then
                    if initialDelayPassed then initialDelayPassed = false end; if SecondDelayPassed then SecondDelayPassed = false end
                    CollectOpenItem(v)
                end
            until v:GetAttribute("Open") == false or (os.clock() - CurrentTime) >= 2
        end]]
    end
end

local function NextFloorVote()
    local Evacuate = false
    spawn(function()
        while task.wait() do
            if game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Countdown.Visible and not Evacuate then
                local currentTime = os.clock()
                repeat task.wait()
                    if game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Countdown.Main.Num.Visible and os.clock() - currentTime < 10 then
                        break
                    end
                    if not game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Countdown.Main.Num.Visible and os.clock() - currentTime >= 10 then
                        require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("SubmitVote", "retreat")
                        Evacuate = true
                        repeat task.wait() until game:GetService("Players").LocalPlayer.PlayerGui.Main.Func.SpectateAndSettle.Main.Bottom.Return.Visible
                        require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("ReturnToLobby")
                        task.wait(20)
                    end
                until os.clock() - currentTime >= 60
            end
        end
    end)
    local Pass = true
    while true do
        task.wait()
        local currentTime = os.clock()
        while Pass do task.wait(.5)
            local Check = false
            for _, v in pairs(game:GetService("Workspace").GameSystem.InteractiveItem:GetChildren()) do
                if v and v:GetAttribute("Open") == false and v:GetAttribute("en") and not v:GetAttribute("ItemDropped") then
                    Check = true
                end
                --[[if v and v:GetAttribute("Open") == true and v:GetAttribute("CloseAnim") and v:GetAttribute("en") and v:GetAttribute("ItemDropped") == true then
                    Check = true
                end]]
            end
            for _, v in pairs(game:GetService("Workspace").GameSystem.Loots.World:GetChildren()) do
                if v and v:IsA("Tool") and v:GetAttribute("Size") and v:GetAttribute("en") and v:HasTag("Interactable") and not v:GetAttribute("Nigga") and (v:FindFirstChild("Folder") and v.Folder:FindFirstChild("Interactable") and v.Folder.Interactable:FindFirstChild("LootUI") and v.Folder.Interactable.LootUI:FindFirstChild("Frame") and v.Folder.Interactable.LootUI.Frame:FindFirstChild("ItemName") and v.Folder.Interactable.LootUI.Frame.ItemName.Text ~= "Bloxy Cola") then
                    local CurrentFloorText = game:GetService("Workspace")["\231\148\181\230\162\175"]["\231\167\187\229\138\1681"]["\231\148\181\230\162\175\233\151\168\229\143\163"].ElevatorUI.SurfaceGui.Frame.PowerText.Text
                    local CurrentFloor = tonumber(string.match(CurrentFloorText, "(%d+)"))
                    local ItemPriceText = v.Folder.Interactable.LootUI.Frame.Price.Text
                    local ItemPrice = tonumber(string.match(ItemPriceText, "(%d+)"))
                    local AcceptablePrice = 0
                    if CurrentFloor >= 20 then AcceptablePrice = 40 end; if CurrentFloor >= 15 and CurrentFloor < 20 then AcceptablePrice = 30 end; if CurrentFloor >= 10 and CurrentFloor < 15 then AcceptablePrice = 20 end; if CurrentFloor < 10 then AcceptablePrice = 10 end
                    if ItemPrice >= AcceptablePrice then
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
        if workspace["\231\148\181\230\162\175"].Left4["\230\142\167\229\136\182\229\143\176"].Yellowky.ContinuePart:GetAttribute("en") and not Evacuate then
            require(game:GetService("ReplicatedStorage").Shared.Core.TEvent).FireRemote("SubmitVote", "continue")
            Pass = true
            repeat task.wait() until not game:GetService("Players").LocalPlayer.PlayerGui.Main.HomePage.Countdown.Visible
        end
    end
end

local function AutoDungeon()
    while task.wait() do
        if CheckInteractables() then
            OpenAllStuff()
            CollectAllItems()
            FreeNPCs()
        end
        game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(game:GetService("Workspace")["\231\148\181\230\162\175"].FoodGathering.Part9.Position.x, game:GetService("Workspace")["\231\148\181\230\162\175"].FoodGathering.Part9.Position.y + 3,  game:GetService("Workspace")["\231\148\181\230\162\175"].FoodGathering.Part9.Position.z)
    end
end

task.spawn(AutoDungeon)
task.spawn(NextFloorVote)
