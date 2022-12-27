repeat wait()
until game:IsLoaded() and game:FindService('NetworkClient') and game.Players and game.Players.LocalPlayer and game.Players.LocalPlayer.Character 
and not game:GetService('Players').LocalPlayer:WaitForChild('PlayerGui'):WaitForChild('WorldTeleport'):WaitForChild('WorldTeleport').Visible

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local ShopMod = require(ReplicatedStorage.Shared.Shop)
local GearPerksMod = require(ReplicatedStorage.Shared.Gear.GearPerks)
local ItemsMod = require(ReplicatedStorage.Shared.Items)
local TeleportToDifferentServer = ReplicatedStorage.Shared.Teleport.TeleportToDifferentServer
local Hour = os.date("!*t").hour
local ServerPage = ""
local Searching = false
local StartSearch = false
local num = 0

local ServerList = {}

local function Round(Number, Decimal)
    local NegativeCheck = false
    local number = 0
    if not tonumber(Number) or Number == nil then
        return "Error: No Number Found"
    end
    if Number < 0 then
        Number = Number * -1
        NegativeCheck = true
    end
    if Number < 1e+3 and Number >= 0 then
        if NegativeCheck then
            return tostring("-" .. tostring(math.floor(Number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)))
        end
        return tostring(math.floor(Number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal))
    elseif Number >= 1e+3 and Number < 1e+6 then
        number = Number / 1e+3
        if NegativeCheck then
            return tostring("-" .. tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "K")
        end
        return tostring(tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "K")
    elseif Number >= 1e+6 and Number < 1e+9 then
        number = Number / 1e+6
        if NegativeCheck then
            return tostring("-" .. tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "M")
        end
        return tostring(tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "M")
    elseif Number >= 1e+9 and Number < 1e+12 then
        number = Number / 1e+9
        if NegativeCheck then
            return tostring("-" .. tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "B")
        end
        return tostring(tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "B")
    elseif Number >= 1e+12 and Number < 1e+15 then
        number = Number / 1e+12
        if NegativeCheck then
            return tostring("-" .. tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "T")
        end
        return tostring(tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "T")
    elseif Number >= 1e+15 and Number < 1e+18 then
        number = Number / 1e+15
        if NegativeCheck then
            return tostring("-" .. tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "Q")
        end
        return tostring(tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "Q")
    elseif Number >= 1e+18 and Number < 1e+21 then
        number = Number / 1e+18
        if NegativeCheck then
            return tostring("-" .. tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "Qn")
        end
        return tostring(tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "Qn")
    elseif Number >= 1e+21 and Number < 1e+24 then
        number = Number / 1e+21
        if NegativeCheck then
            return tostring("-" .. tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "Sx")
        end
        return tostring(tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "Sx")
    elseif Number >= 1e+24 and Number < 1e+27 then
        number = Number / 1e+24
        if NegativeCheck then
            return tostring("-" .. tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "Se")
        end
        return tostring(tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "Se")
    elseif Number >= 1e+27 and Number < 1e+30 then
        number = Number / 1e+27
        if NegativeCheck then
            return tostring("-" .. tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "Oc")
        end
        return tostring(tostring(math.floor(number * (10 ^ Decimal) + 0.5) / (10 ^ Decimal)) .. "Oc")
    end
end

local File = pcall(function()
    ServerList = HttpService:JSONDecode(readfile("ServersSaved.json"))
end)

if not File then
    table.insert(ServerList, Hour)
    writefile("ServersSaved.json", HttpService:JSONEncode(ServerList))
end

local isfile = isfile or is_file
local isfolder = isfolder or is_folder
local writefile = writefile or write_file
local makefolder = makefolder or make_folder or createfolder or create_folder

if makefolder then
    if not isfolder("WorldZero") then
        makefolder("WorldZero")
    end
end
local function LoadData(Name, Table)
    if isfile("WorldZero//"..Name..'.txt') then
        local NewTable = HttpService:JSONDecode(readfile("WorldZero//"..Name..'.txt'))
        table.clear(Table)
        for i,v in pairs(NewTable) do
            Table[i] = v
        end
    else
        writefile("WorldZero//"..Name..'.txt', HttpService:JSONEncode(Table))
    end
end
local function SaveData(Name, Table)
    writefile("WorldZero//"..Name..'.txt', HttpService:JSONEncode(Table))
end

local function Serverhop(PlaceID)
    local Site
    if ServerPage == "" then
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100'))
    else
        Site = game.HttpService:JSONDecode(game:HttpGet('https://games.roblox.com/v1/games/' .. PlaceID .. '/servers/Public?sortOrder=Asc&limit=100&cursor=' .. foundAnything))
    end
    local ID = ""
    if Site.nextPageCursor and Site.nextPageCursor ~= "null" and Site.nextPageCursor ~= nil then
        ServerPage = Site.nextPageCursor
    end
    local num = 0
    for i,v in pairs(Site.data) do
        local Possible = true
        ID = tostring(v.id)
        if tonumber(v.maxPlayers) > tonumber(v.playing) then
            for _, JobID in pairs(ServerList) do
                if num ~= 0 then
                    if ID == tostring(JobID) then
                        Possible = false
                    end
                else
                    if tonumber(Hour) ~= tonumber(JobID) then
                        local delfile = pcall(function()
                            delfile("ServersSaved.json")
                            ServerList = {}
                            table.insert(ServerList, Hour)
                        end)
                    end
                end
                num += 1
            end
            if Possible == true then
                table.insert(ServerList, ID)
                pcall(function()
                    writefile("ServersSaved.json", HttpService:JSONEncode(ServerList))
                    wait()
                    TeleportToDifferentServer:FireServer(tostring(ID))
                end)
                wait(10)
            end
        end
    end
end

local function Start()
    while wait() do
        pcall(function()
            Serverhop(game.PlaceId)
            if ServerPage ~= "" then
                Serverhop(game.PlaceId)
            end
        end)
    end
end


local function GetPerkPercentage(PerkValue)
    return tostring(math.floor(PerkValue*100)).."%"
end
local AllItemsDisplayKey = {}
local AllItems = {}
local SelectedItem = ""
local ToLoad = {
    ItemtoSelect = "",
    WebhookURL = "",
    StartSearch = false
}
local ChangeDropdown = false
for i,v in pairs(ItemsMod) do
    table.insert(AllItemsDisplayKey, v.DisplayKey)
    AllItems[v.DisplayKey] = i
end
local AllPerksDisplayName = {}
local AllPerks = {}
local PerksToFind = {
    ["Perk1"] = "",
    ["Perk2"] = "",
    ["Perk3"] = ""
}
local SearchPerk1 = false
local SearchPerk2 = false
local SearchPerk3 = false

for i,v in pairs(GearPerksMod) do
    table.insert(AllPerksDisplayName, v.DisplayName)
    AllPerks[v.DisplayName] = i
end

local PerkRanges = {}

for i,v in pairs(GearPerksMod) do
    for i2,v2 in pairs(v) do
        if i2 == "StatRange" then
            local MinExist = false
            local Min = 0
            local Max = 0
            for i3,v3 in ipairs(v2) do
                if not MinExist then
                    Min = v3
                    MinExist = true
                elseif MinExist then
                    Max = v3
                end
            end
            PerkRanges[i] = {["Min"] = Min, ["Max"] = Max}
        end
    end
end

local BypassCoinCheck = false

local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()
local Window = Rayfield:CreateWindow({
    Name = "World Zero",
    LoadingTitle = "World Zero Extra Features",
    LoadingSubtitle = "by Sense#1468",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "WorldZero",
        FileName = "TouchGrass"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
    KeySettings = {
        Title = "World Zero",
        Subtitle = "Key System",
        Note = "Join the discord",
        FileName = "TouchGrassKey",
        SaveKey = true,
        GrabKeyFromSite = false,
        Key = "TouchMoreGrass"
    }
})

----Tabs----

local Tab1 = Window:CreateTab("Item Shop Sniper")


----Buttons/Toggles/Dropdown/Slider----

Tab1:CreateSection("Item Info")

Tab1:CreateInput({
    Name = "Webhook Link",
    PlaceholderText = "",
    RemoveTextAfterFocusLost = true,
    Callback = function(Link)
        ToLoad.WebhookURL = Link
        SaveData("WZIS", ToLoad)
    end
})
Tab1:CreateInput({
    Name = "Input Item Name",
    PlaceholderText = "",
    RemoveTextAfterFocusLost = true,
    Callback = function(Item)
        for i,v in pairs(AllItemsDisplayKey) do
            if string.find(v, Item) then
                ToLoad.ItemtoSelect = v
            end
        end
        ChangeDropdown = true
    end
})

local ItemSelector = Tab1:CreateDropdown({
    Name = "Item Name",
    Options = AllItemsDisplayKey,
    CurrentOption = "Aether Armor",
    Callback = function(Item)
        SelectedItem = AllItems[Item]
    end
})

Tab1:CreateDropdown({
    Name = "Perk 1",
    Options = AllPerksDisplayName,
    CurrentOption = "Resist Frost",
    Flag = "Selected Perk 1",
    Callback = function(Perk)
        PerksToFind["Perk1"] = AllPerks[Perk]
    end
})

Tab1:CreateDropdown({
    Name = "Perk 2",
    Options = AllPerksDisplayName,
    CurrentOption = "Resist Frost",
    Flag = "Selected Perk 2",
    Callback = function(Perk)
        PerksToFind["Perk2"] = AllPerks[Perk]
    end
})

Tab1:CreateDropdown({
    Name = "Perk 3",
    Options = AllPerksDisplayName,
    CurrentOption = "Resist Frost",
    Flag = "Selected Perk 3",
    Callback = function(Perk)
        PerksToFind["Perk3"] = AllPerks[Perk]
    end
})

Tab1:CreateSection("Toggles")

Tab1:CreateToggle({
    Name = "Auto Buy (Warning: Will use all Gold)",
    CurrentValue = false,
    Flag = "Bypass Coin Check",
    Callback = function(bool)
        BypassCoinCheck = bool
    end
})

Tab1:CreateToggle({
    Name = "Search Perk 1",
    CurrentValue = false,
    Flag = "Search Perk 1",
    Callback = function(bool)
        SearchPerk1 = bool
    end
})

Tab1:CreateToggle({
    Name = "Perfect Perk 1",
    CurrentValue = false,
    Flag = "Perfect Perk 1",
    Callback = function(bool)
        PerfectPerk1 = bool
    end
})

Tab1:CreateToggle({
    Name = "Search Perk 2",
    CurrentValue = false,
    Flag = "Search Perk 2",
    Callback = function(bool)
        SearchPerk2 = bool
    end
})

Tab1:CreateToggle({
    Name = "Perfect Perk 2",
    CurrentValue = false,
    Flag = "Perfect Perk 2",
    Callback = function(bool)
        PerfectPerk2 = bool
    end
})

Tab1:CreateToggle({
    Name = "Search Perk 3",
    CurrentValue = false,
    Flag = "Search Perk 3",
    Callback = function(bool)
        SearchPerk3 = bool
    end
})

Tab1:CreateToggle({
    Name = "Perfect Perk 3",
    CurrentValue = false,
    Flag = "Perfect Perk 3",
    Callback = function(bool)
        PerfectPerk3 = bool
    end
})

local testing = Tab1:CreateToggle({
    Name = "Start",
    CurrentValue = false,
    Callback = function(bool)
        StartSearch = bool
    end
})

Rayfield:LoadConfiguration()
LoadData("WZIS", ToLoad)
ItemSelector:Set(ToLoad.ItemtoSelect)

spawn(function()
    while wait() do
        if ChangeDropdown then
            ItemSelector:Set(ToLoad.ItemtoSelect)
            SaveData("WZIS", ToLoad)
            ChangeDropdown = false
        end
    end 
end)

local ToBuy = {}


local function Notify(Title, Description, Price, PlayerToTrade, ItemToBuy)
    Rayfield:Notify({
        Title = Title,
        Content = Description,
        Duration = 1e9,
        Actions = {
            Close = {
                Name = "Close",
                Callback = function()
                end
            },
            Buy = {
                Name = "Buy Item - "..Price,
                Callback = function()
                    ShopMod.BuyItem(ShopMod, game.Players.LocalPlayer, PlayerToTrade, ItemToBuy)
                end
            }
        }
    })
end

local function Search()
    table.clear(ToBuy)
    for i,v in pairs(ReplicatedStorage.Profiles:GetChildren()) do
        if v and v:FindFirstChild("SellShop") and v.SellShop:FindFirstChild("Items") and v.SellShop.Active.Value == true and v.Name ~= game.Players.LocalPlayer.Name then
            for _,Item in pairs(v.SellShop.Items:GetChildren()) do
                if string.find(Item.Name, SelectedItem) then
                    num += 1
                    local DisplayName = ""
                    for i2,v2 in pairs(ItemsMod) do
                        if string.find(Item.Name, i2) then
                            DisplayName = v2.DisplayKey
                        end
                    end
                    local Names = {
                        ["Item Name"] = Item.Name,
                        ["Display Name"] = DisplayName
                    }
                    local Checks = {
                    Perk1 = false,
                    Perk2 = false,
                    Perk3 = false
                   } 
                    local Description = ""
                    if Item:FindFirstChild("Perk3") and (
                        (SearchPerk3 and not PerfectPerk3 or SearchPerk3 and PerfectPerk3 and Item.Perk3.PerkValue.Value == PerkRanges[Item.Perk3.Value].Max) and 
                        (PerksToFind["Perk1"] == Item.Perk3.Value or PerksToFind["Perk2"] == Item.Perk3.Value or PerksToFind["Perk3"] == Item.Perk3.Value) or 
                        Item:FindFirstChild("Perk2") and 
                        (SearchPerk2 and not PerfectPerk2 or SearchPerk2 and PerfectPerk2 and Item.Perk2.PerkValue.Value == PerkRanges[Item.Perk2.Value].Max) and 
                        (PerksToFind["Perk1"] == Item.Perk2.Value or PerksToFind["Perk2"] == Item.Perk2.Value or PerksToFind["Perk3"] == Item.Perk2.Value) or 
                        Item:FindFirstChild("Perk1") and 
                        (SearchPerk1 and not PerfectPerk1 or SearchPerk1 and PerfectPerk1 and Item.Perk1.PerkValue.Value == PerkRanges[Item.Perk1.Value].Max) and 
                        (PerksToFind["Perk1"] == Item.Perk1.Value or PerksToFind["Perk2"] == Item.Perk1.Value or PerksToFind["Perk3"] == Item.Perk1.Value)
                    ) then
                        Checks.Perk3 = true
                        Names["Perk 3"] = GearPerksMod[Item.Perk3.Value].DisplayName.." "..GetPerkPercentage(Item.Perk3.PerkValue.Value)
                        Names["Perk 2"] = GearPerksMod[Item.Perk2.Value].DisplayName.." "..GetPerkPercentage(Item.Perk2.PerkValue.Value)
                        Names["Perk 1"] = GearPerksMod[Item.Perk1.Value].DisplayName.." "..GetPerkPercentage(Item.Perk1.PerkValue.Value)
                        Description = Description.."Perk 1 - "..Names["Perk 1"].."\nPerk 2 - "..Names["Perk 2"].."\nPerk 3 - "..Names["Perk 3"]
                    elseif not Checks.Perk3 and (Item:FindFirstChild("Perk2") and (SearchPerk2 and not PerfectPerk2 or SearchPerk2 and PerfectPerk2 and Item.Perk2.PerkValue.Value == PerkRanges[Item.Perk2.Value].Max) and (PerksToFind["Perk1"] == Item.Perk2.Value or PerksToFind["Perk2"] == Item.Perk2.Value or PerksToFind["Perk3"] == Item.Perk2.Value) or Item:FindFirstChild("Perk1") and (SearchPerk1 and not PerfectPerk1 or SearchPerk1 and PerfectPerk1 and Item.Perk1.PerkValue.Value == PerkRanges[Item.Perk1.Value].Max) and (PerksToFind["Perk1"] == Item.Perk1.Value or PerksToFind["Perk2"] == Item.Perk1.Value or PerksToFind["Perk3"] == Item.Perk1.Value)) then
                        Checks.Perk2 = true
                        Names["Perk 2"] = GearPerksMod[Item.Perk2.Value].DisplayName.." "..GetPerkPercentage(Item.Perk2.PerkValue.Value)
                        Names["Perk 1"] = GearPerksMod[Item.Perk1.Value].DisplayName.." "..GetPerkPercentage(Item.Perk1.PerkValue.Value)
                        Description = Description.."Perk 1 - "..Names["Perk 1"].."\nPerk 2 - "..Names["Perk 2"]
                    elseif not Checks.Perk3 and not Checks.Perk2 and Item:FindFirstChild("Perk1") and (SearchPerk1 and not PerfectPerk1 or SearchPerk1 and PerfectPerk1 and Item.Perk1.PerkValue.Value == PerkRanges[Item.Perk1.Value].Max) and (PerksToFind["Perk1"] == Item.Perk1.Value or PerksToFind["Perk2"] == Item.Perk1.Value or PerksToFind["Perk3"] == Item.Perk1.Value) then
                        Checks.Perk1 = true
                        Names["Perk 1"] = GearPerksMod[Item.Perk1.Value].DisplayName.." "..GetPerkPercentage(Item.Perk1.PerkValue.Value)
                        Description = Description.."Perk 1 - "..Names["Perk 1"]
                    end
                    if ((SearchPerk1 and not PerfectPerk1 or SearchPerk1 and PerfectPerk1 and Item.Perk1.PerkValue.Value == PerkRanges[Item.Perk1.Value].Max) or (SearchPerk2 and not PerfectPerk2 or SearchPerk2 and PerfectPerk2 and Item.Perk2.PerkValue.Value == PerkRanges[Item.Perk2.Value].Max) or (SearchPerk3 and not PerfectPerk3 or SearchPerk3 and PerfectPerk3 and Item.Perk3.PerkValue.Value == PerkRanges[Item.Perk3.Value].Max)) and (Checks.Perk1 or Checks.Perk2 or Checks.Perk3) then
                        Item:SetAttribute("Listed", true)
                        if not BypassCoinCheck then
                            Notify(Names["Display Name"], Description, tostring(Round(Item.AskingPrice.Value, 2)), game.Players[v.Name], Item)
                        elseif BypassCoinCheck and game:GetService("ReplicatedStorage").Profiles[game.Players.LocalPlayer.Name].Currency.Gold >= Item.AskingPrice.Value then
                            ShopMod.BuyItem(ShopMod, game.Players.LocalPlayer, game.Players[v.Name], Item)
                        end
                        ToBuy[Names["Item Name"]..tostring(num)] = {['Item Number'] = num, ["Item Name"] = Item.Name, ["Display Name"] = Names["Display Name"], ["Price"] = tostring(Round(Item.AskingPrice.Value, 2)), ["Level"] = tostring(Item.Level.Value), ["Perk 1"] = Names["Perk 1"], ["Perk 2"] = Names["Perk 2"], ["Perk 3"] = Names["Perk 3"]}
                    elseif not SearchPerk1 and not SearchPerk2 and not SearchPerk3 then
                        Item:SetAttribute("Listed", true)
                        if not BypassCoinCheck then
                            Notify(Names["Display Name"], Description, tostring(Round(Item.AskingPrice.Value, 2)), game.Players[v.Name], Item)
                        elseif BypassCoinCheck and game:GetService("ReplicatedStorage").Profiles[game.Players.LocalPlayer.Name].Currency.Gold >= Item.AskingPrice.Value then
                            ShopMod.BuyItem(ShopMod, game.Players.LocalPlayer, game.Players[v.Name], Item)
                        end
                        ToBuy[Names["Item Name"]..tostring(num)] = {['Item Number'] = num, ["Item Name"] = Item.Name, ["Display Name"] = Names["Display Name"], ["Price"] = tostring(Round(Item.AskingPrice.Value, 2)), ["Level"] = tostring(Item.Level.Value), ["Perk 1"] = Names["Perk 1"], ["Perk 2"] = Names["Perk 2"], ["Perk 3"] = Names["Perk 3"]}
                    end
                end
            end
        end
    end
end

local ItemsTable = {
    {
        ['title'] = "World // Zero",
        ['description'] = "Item Shop Sniper made by - Sense#1468",
        ['color'] = tonumber(0x2B6BE4),
        ['footer'] = {
            ['text'] = tostring(os.date())
        },
        ['fields'] = {
            {
                ['name'] = "Search Finished",
                ['value'] = "JobId - "..tostring(game.JobId),
                ['inline'] = false
            }
        }
    }
}

local AddEmbeds = function(Title, Description, ...)
    local Table = {
        ['title'] = Title,
        ['description'] = Description,
        ['color'] = tonumber(0x2B6BE4),
        ['fields'] = ...
    }
    return Table
end

local AddFields = function(Name, Description, Inline)
    local Table = {
        ['name'] = Name,
        ['value'] = Description,
        ['inline'] = Inline
    }
    return Table
end

local function DiscordNotif()
    for i,v in pairs(ToBuy) do
        if type(v) == 'table' then
            local Table = {}
            table.insert(Table, AddFields('Level', v.Level, true))
            table.insert(Table, AddFields('Price', v.Price, true))
            table.insert(Table, AddFields('Item Number', v['Item Number'], true))
            if v['Perk 1'] then
                table.insert(Table, AddFields('Perk 1', v['Perk 1'], false))
            end
            if v['Perk 2'] then
                table.insert(Table, AddFields('Perk 2', v['Perk 2'], false))
            end
            if v['Perk 3'] then
                table.insert(Table, AddFields('Perk 3', v['Perk 3'], false))
            end
            table.insert(ItemsTable, AddEmbeds(v['Display Name'], v['Item Name'], Table))
        end
    end
    local PlayerData = HttpService:JSONEncode({
        ['content'] = '',
        ['embeds'] = {
            unpack(ItemsTable)
        }
    })
    local url = Link
    local data = PlayerData
    local headers = {["content-type"] = "application/json"}
    local request = http_request or request or HttpPost or syn.request
    request({Url = ToLoad.WebhookURL, Body = data, Method = "POST", Headers = headers})
end

if ToLoad.StartSearch then
    testing:Set(true)
end

spawn(function()
    while wait() do
        if StartSearch then
            wait(2)
            Search()
            wait(2)
            local ItemsFound = false
            for i,v in pairs(ToBuy) do
                ItemsFound = true
            end
            if ItemsFound then
                DiscordNotif()
            end
            testing:Set(false)
            wait(1)
            if not ItemsFound then
                Rayfield:Notify({
                    Title = "No Items Found",
                    Content = "Serverhop Initiated",
                    Duration = 5
                })
                ToLoad.StartSearch = true
                SaveData("WZIS", ToLoad)
                local QueueTeleport = (syn and syn.queue_on_teleport) or (fluxus and fluxus.queue_on_teleport) or queue_on_teleport
                QueueTeleport([[loadstring(game:HttpGet("https://raw.githubusercontent.com/SNSDARK/Scripts/main/WorldZero-ISS.lua"))()]])
                Start()
            end
        end
    end
end)
