-- Full-Screen Stats Overlay
local StatsOverlay = {
    Enabled = true,
    UpdateInterval = 0.5, -- Update every 0.5 seconds
    LastUpdate = 0,
    ToggleKey = Enum.KeyCode.G,
    IsVisible = true,
    GameLoaded = false,
    StartTime = tick(),
    ValueModule = nil,
    ItemLootConfig = nil
}

-- Default data
StatsOverlay.Data = {
    Username = "Loading...",
    BestFood = "Loading...",
    CurrentStatus = "Initializing",
    TotalCoins = "0",
    Sellable = "0",
    CoinsPickedUp = "0",
    Time = "00:00:00"
}

-- ===========================================
-- 3D RENDER DISABLER MODULE
-- ===========================================
local RenderDisabler = {
    Enabled = false,
    OriginalSettings = {},
    SavedParts = {}
}

-- Nuclear option for maximum performance
function RenderDisabler:Enable2DMode()
    if self.Enabled then return end
    self.Enabled = true
    
    print("⚡ Enabling 2D Mode - Maximizing performance...")
    
    -- Save original settings
    self.OriginalSettings = {
        QualityLevel = settings().Rendering.QualityLevel,
        Shadows = game:GetService("Lighting").GlobalShadows,
        Outlines = game:GetService("Lighting").Outlines,
        CameraDistance = game:GetService("Workspace").CurrentCamera.MaxCameraDistance or 10000
    }
    
    -- 1. Set minimum quality
    settings().Rendering.QualityLevel = 1
    
    -- 2. Disable lighting effects
    local lighting = game:GetService("Lighting")
    lighting.GlobalShadows = false
    lighting.Outlines = false
    
    -- 3. Disable post-processing effects
    local effects = {"Bloom", "Blur", "ColorCorrection", "SunRays", "Atmosphere"}
    for _, effectName in ipairs(effects) do
        local effect = lighting:FindFirstChild(effectName)
        if effect then
            self.OriginalSettings[effectName] = effect.Enabled
            effect.Enabled = false
        end
    end
    
    -- 4. Disable particles and effects
    for _, obj in pairs(game:GetService("Workspace"):GetDescendants()) do
        if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
            if not self.SavedParts[obj] then
                self.SavedParts[obj] = {Enabled = obj.Enabled}
            end
            obj.Enabled = false
        end
    end
    
    -- 5. Reduce part quality and hide details
    for _, part in pairs(game:GetService("Workspace"):GetDescendants()) do
        if part:IsA("BasePart") then
            if not self.SavedParts[part] then
                self.SavedParts[part] = {
                    Material = part.Material,
                    Reflectance = part.Reflectance,
                    Transparency = part.Transparency
                }
            end
            
            -- Make parts simple
            part.Material = Enum.Material.SmoothPlastic
            part.Reflectance = 0
            
            -- Hide decorative parts (optional)
            if part.Name:find("Decal") or part.Name:find("Detail") or part.Name:find("Effect") then
                part.Transparency = 0.95
            end
            
            -- Remove decals
            for _, decal in pairs(part:GetChildren()) do
                if decal:IsA("Decal") then
                    if not self.SavedParts[decal] then
                        self.SavedParts[decal] = {Parent = decal.Parent}
                    end
                    decal:Destroy()
                end
            end
        end
    end
    
    -- 6. Hide player characters (optional)
    for _, player in pairs(game:GetService("Players"):GetPlayers()) do
        if player.Character then
            for _, part in pairs(player.Character:GetDescendants()) do
                if part:IsA("BasePart") then
                    if not self.SavedParts[part] then
                        self.SavedParts[part] = {Transparency = part.Transparency}
                    end
                    part.Transparency = 0.8  -- Make semi-transparent
                end
            end
        end
    end
    
    -- 7. Limit camera distance
    game:GetService("Workspace").CurrentCamera.MaxCameraDistance = 100
    
    print("✅ 2D Mode Enabled - 3D rendering minimized")
end

function RenderDisabler:Disable2DMode()
    if not self.Enabled then return end
    self.Enabled = false
    
    print("⚡ Disabling 2D Mode - Restoring graphics...")
    
    -- Restore quality settings
    if self.OriginalSettings.QualityLevel then
        settings().Rendering.QualityLevel = self.OriginalSettings.QualityLevel
    end
    
    if self.OriginalSettings.Shadows ~= nil then
        game:GetService("Lighting").GlobalShadows = self.OriginalSettings.Shadows
    end
    
    if self.OriginalSettings.Outlines ~= nil then
        game:GetService("Lighting").Outlines = self.OriginalSettings.Outlines
    end
    
    if self.OriginalSettings.CameraDistance then
        game:GetService("Workspace").CurrentCamera.MaxCameraDistance = self.OriginalSettings.CameraDistance
    end
    
    -- Restore post-processing effects
    local lighting = game:GetService("Lighting")
    local effects = {"Bloom", "Blur", "ColorCorrection", "SunRays", "Atmosphere"}
    for _, effectName in ipairs(effects) do
        local effect = lighting:FindFirstChild(effectName)
        if effect and self.OriginalSettings[effectName] ~= nil then
            effect.Enabled = self.OriginalSettings[effectName]
        end
    end
    
    -- Restore particles and effects
    for obj, saved in pairs(self.SavedParts) do
        if obj and obj.Parent then
            if obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Beam") then
                if saved.Enabled ~= nil then
                    obj.Enabled = saved.Enabled
                end
            elseif obj:IsA("BasePart") then
                if saved.Material then
                    obj.Material = saved.Material
                end
                if saved.Reflectance then
                    obj.Reflectance = saved.Reflectance
                end
                if saved.Transparency then
                    obj.Transparency = saved.Transparency
                end
            elseif obj:IsA("Decal") and saved.Parent then
                -- Decals were destroyed, can't restore easily
            end
        end
    end
    
    -- Clear saved parts
    self.SavedParts = {}
    self.OriginalSettings = {}
    
    print("✅ 2D Mode Disabled - 3D rendering restored")
end

-- Universal Number Formatter - Single Function
local function FormatNumber(num, prefix, decimals)
    -- Convert input to number
    num = tonumber(num) or 0
    prefix = prefix or ""
    decimals = decimals or 2
    
    -- Handle negative numbers
    local isNegative = num < 0
    if isNegative then
        num = math.abs(num)
    end
    
    -- Handle zero
    if num == 0 then
        return prefix .. "0"
    end
    
    -- Define suffixes
    local suffixes = {
        "",     -- 10^0
        "k",    -- 10^3
        "M",    -- 10^6
        "B",    -- 10^9
        "T",    -- 10^12
        "Qa",   -- 10^15
        "Qi",   -- 10^18
        "Sx",   -- 10^21
        "Sp",   -- 10^24
        "Oc"    -- 10^27
    }
    
    -- Find the appropriate suffix
    local suffixIndex = 0
    local tempNum = num
    
    while tempNum >= 1000 and suffixIndex < #suffixes - 1 do
        tempNum = tempNum / 1000
        suffixIndex = suffixIndex + 1
    end
    
    -- Scale the number
    local scaledNum = num / (1000 ^ suffixIndex)
    
    -- Format with specified decimals
    local formatPattern = "%." .. tostring(decimals) .. "f"
    local formatted = string.format(formatPattern, scaledNum)
    
    -- Remove trailing zeros and decimal point if needed
    formatted = formatted:gsub("0+$", "")  -- Remove trailing zeros
    formatted = formatted:gsub("%.$", "")  -- Remove trailing decimal point
    
    -- Get the suffix
    local suffix = suffixes[suffixIndex + 1] or ""
    
    -- Build the result
    local result = prefix .. formatted .. suffix
    
    if isNegative then
        result = "-" .. result
    end
    
    return result
end

function StatsOverlay:FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = math.floor(seconds % 60)
    
    return string.format("%02d:%02d:%02d", hours, minutes, secs)
end

function StatsOverlay:UpdateClock()
    local elapsed = tick() - self.StartTime
    return self:FormatTime(elapsed)
end

function StatsOverlay:GetPlayerUsername()
    local success, username = pcall(function()
        return game:GetService("Players").LocalPlayer.Name
    end)
    return success and username or "Unknown"
end

function StatsOverlay:GetBestFood()
    local success, result = pcall(function()
        if not self.ValueModule then
            self.ValueModule = require(game:GetService("ReplicatedStorage").Shared.Core.Value)
        end
        
        local HighestValue = 0
        local BestFoodId = ""
        local loots = self.ValueModule.GetAllValue().DungeonStats.loots
        
        for foodId, foodData in pairs(loots) do
            if foodData.sell and foodData.sell > HighestValue then
                HighestValue = foodData.sell
                BestFoodId = foodData.id
            end
        end
        
        if BestFoodId ~= "" and HighestValue > 0 then
            if not self.ItemLootConfig then
                self.ItemLootConfig = require(game:GetService("ReplicatedStorage").Config.item_loot)
            end
            local foodName = self.ItemLootConfig[BestFoodId] and self.ItemLootConfig[BestFoodId].name or "Unknown"
            return (foodName .. " | "..FormatNumber(HighestValue, "$", 2))
        end
        
        return "None"
    end)
    if not success then
        warn("Error: "..result)
    end
    return success and result or "None"
end

function StatsOverlay:GetTotalCoins()
    local success, result = pcall(function()
        if not self.ValueModule then
            self.ValueModule = require(game:GetService("ReplicatedStorage").Shared.Core.Value)
        end
        
        local allValues = self.ValueModule.GetAllValue()
        return FormatNumber(allValues.Item[101], "$", 2)
    end)
    
    return success and result or "0"
end

function StatsOverlay:GetSellable()
    local success, result = pcall(function()
        if not self.ValueModule then
            self.ValueModule = require(game:GetService("ReplicatedStorage").Shared.Core.Value)
        end
        
        local Sellable = 0
        local loots = self.ValueModule.GetAllValue().DungeonStats.loots
        
        for _, foodData in pairs(loots) do
            if foodData.sell then
                Sellable = Sellable + foodData.sell
            end
        end
        
        return FormatNumber(Sellable, "$", 2)
    end)
    
    return success and result or "0"
end

function StatsOverlay:GetCoinsPickedUp()
    local success, result = pcall(function()
        if not self.ValueModule then
            self.ValueModule = require(game:GetService("ReplicatedStorage").Shared.Core.Value)
        end
        
        local cash = self.ValueModule.GetAllValue().DungeonStats.cash or 0
        return FormatNumber(cash, "$", 2)
    end)
    
    return success and result or "0"
end

function StatsOverlay:Initialize()
    -- Use gethui() immediately
    local guiContainer
    local success, result = pcall(function()
        return gethui()
    end)
    
    guiContainer = success and result or game:GetService("CoreGui")
    
    -- Create full-screen GUI
    local screen = Instance.new("ScreenGui")
    screen.Name = "FullScreenOverlay"
    screen.DisplayOrder = 999998
    screen.ResetOnSpawn = false
    screen.IgnoreGuiInset = true -- Cover entire screen
    
    -- Full-screen background (optional dimming)
    local background = Instance.new("Frame")
    background.Name = "Background"
    background.Size = UDim2.new(1, 0, 1, 0)
    background.Position = UDim2.new(0, 0, 0, 0)
    background.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    background.BackgroundTransparency = 0 -- Very transparent, just slight dim
    background.BorderSizePixel = 0
    background.Active = false
    background.Selectable = false
    
    -- Main container - centered and large like in the image
    local container = Instance.new("Frame")
    container.Name = "Container"
    container.Size = UDim2.new(0.6, 0, 0.8, 0) -- Large size
    container.Position = UDim2.new(0.2, 0, 0.1, 0) -- Centered
    container.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
    container.BackgroundTransparency = 0.7 -- More transparent
    container.BorderSizePixel = 0
    container.Active = false
    container.Selectable = false
    
    -- Make all descendants untouchable
    container.DescendantAdded:Connect(function(descendant)
        if descendant:IsA("GuiObject") then
            descendant.Active = false
            descendant.Selectable = false
        end
    end)
    
    -- UI Elements
    local uiCorner = Instance.new("UICorner")
    uiCorner.CornerRadius = UDim.new(0.02, 0)
    uiCorner.Parent = container
    
    local uiStroke = Instance.new("UIStroke")
    uiStroke.Color = Color3.fromRGB(60, 60, 60)
    uiStroke.Thickness = 2
    uiStroke.Transparency = 0.3
    uiStroke.Parent = container
    
    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0.05, 0)
    padding.PaddingTop = UDim.new(0.05, 0)
    padding.PaddingRight = UDim.new(0.05, 0)
    padding.PaddingBottom = UDim.new(0.05, 0)
    padding.Parent = container
    
    -- Title - Large and centered like in image
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0.15, 0)
    title.Position = UDim2.new(0, 0, 0, 0)
    title.Text = "Deadly Delivery"
    title.TextColor3 = Color3.fromRGB(220, 220, 220)
    title.BackgroundTransparency = 1
    title.Font = Enum.Font.GothamBold
    title.TextScaled = true
    title.TextSize = 28
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.Active = false
    title.Selectable = false
    
    -- Separator
    local separator = Instance.new("Frame")
    separator.Name = "Separator"
    separator.Size = UDim2.new(1, 0, 0, 2)
    separator.Position = UDim2.new(0, 0, 0.15, 10)
    separator.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
    separator.BackgroundTransparency = 0.5
    separator.BorderSizePixel = 0
    separator.Active = false
    
    -- Stats Container - Fill most of the space
    local statsContainer = Instance.new("Frame")
    statsContainer.Name = "StatsContainer"
    statsContainer.Size = UDim2.new(1, 0, 0.85, -20)
    statsContainer.Position = UDim2.new(0, 0, 0.2, 0)
    statsContainer.BackgroundTransparency = 1
    statsContainer.Active = false
    statsContainer.Selectable = false
    
    -- Create stats rows with larger text
    self.Stats = {}
    local statNames = {
        "Username",
        "Best Food", 
        "Current Status",
        "Total Coins",
        "Sellable",
        "Coins Picked Up",
        "Time"
    }
    
    local statKeys = {
        "Username",
        "BestFood",
        "CurrentStatus", 
        "TotalCoins",
        "Sellable",
        "CoinsPickedUp",
        "Time"
    }
    
    for i = 1, 7 do
        local row = Instance.new("Frame")
        row.Name = "Row_" .. i
        row.Size = UDim2.new(1, 0, 1/7, 0)
        row.Position = UDim2.new(0, 0, (i-1)/7, 0)
        row.BackgroundTransparency = 1
        row.Active = false
        row.Selectable = false
        
        -- Stat name - larger text
        local statName = Instance.new("TextLabel")
        statName.Name = "Name"
        statName.Size = UDim2.new(0.4, 0, 1, 0)
        statName.Position = UDim2.new(0, 0, 0, 0)
        statName.Text = statNames[i] .. ":"
        statName.TextColor3 = Color3.fromRGB(200, 200, 200)
        statName.BackgroundTransparency = 1
        statName.Font = Enum.Font.GothamSemibold
        statName.TextScaled = true
        statName.TextSize = 16
        statName.TextXAlignment = Enum.TextXAlignment.Left
        statName.Active = false
        statName.Selectable = false
        
        -- Stat value - larger text
        local statValue = Instance.new("TextLabel")
        statValue.Name = "Value"
        statValue.Size = UDim2.new(0.6, 0, 1, 0)
        statValue.Position = UDim2.new(0.4, 0, 0, 0)
        statValue.Text = self.Data[statKeys[i]] or "Loading..."
        
        -- Color coding with brighter colors
        if statKeys[i] == "CurrentStatus" then
            statValue.TextColor3 = Color3.fromRGB(100, 200, 255) -- Bright Blue
        elseif statKeys[i] == "BestFood" then
            statValue.TextColor3 = Color3.fromRGB(255, 200, 100) -- Bright Orange
        elseif statKeys[i] == "TotalCoins" or statKeys[i] == "Sellable" or statKeys[i] == "CoinsPickedUp" then
            statValue.TextColor3 = Color3.fromRGB(150, 255, 150) -- Bright Green
        elseif statKeys[i] == "Time" then
            statValue.TextColor3 = Color3.fromRGB(255, 220, 100) -- Gold
        else
            statValue.TextColor3 = Color3.fromRGB(240, 240, 240) -- Bright White
        end
        
        statValue.BackgroundTransparency = 1
        statValue.Font = Enum.Font.GothamBold
        statValue.TextScaled = true
        statValue.TextSize = 22
        statValue.TextXAlignment = Enum.TextXAlignment.Left
        statValue.Active = false
        statValue.Selectable = false
        
        statName.Parent = row
        statValue.Parent = row
        row.Parent = statsContainer
        
        self.Stats[statKeys[i]] = statValue
    end
    
    -- Assemble hierarchy
    statsContainer.Parent = container
    separator.Parent = container
    title.Parent = container
    container.Parent = background
    background.Parent = screen
    screen.Parent = guiContainer
    
    -- Store references
    self.Screen = screen
    self.Container = container
    self.Background = background

    self.Enable2DMode = true
    
    print("Full-Screen Overlay initialized")
    
    return true
end

function StatsOverlay:SetupKeybind()
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.InputBegan:Connect(function(input, gameProcessed)
        if not gameProcessed and input.KeyCode == self.ToggleKey then
            self:ToggleVisibility()
        end
    end)
end

function StatsOverlay:ToggleVisibility()
    self.IsVisible = not self.IsVisible
    
    if self.Container then
        self.Container.Visible = self.IsVisible
        if self.Background then
            self.Background.Visible = self.IsVisible
        end

        if self.IsVisible then
            pcall(function()
                require(game:GetService("ReplicatedStorage").Shared.Core.FeatureManager)
                    .Set("AltUnlock", "UnLockMouse", true, 100)
            end)
            if self.Enable2DMode then
                RenderDisabler:Enable2DMode()
            end
            setfpscap(20)
        else
            pcall(function()
                require(game:GetService("ReplicatedStorage").Shared.Core.FeatureManager)
                    .Reset("AltUnlock")
            end)
            if self.Enable2DMode then
                RenderDisabler:Disable2DMode()
            end
            setfpscap(60)
        end

        print("Full-Screen Overlay: " .. (self.IsVisible and "Shown" or "Hidden"))
    end
end

function StatsOverlay:UpdateAllStats()
    -- Always update clock
    self.Data.Time = self:UpdateClock()
    
    -- Update other stats if game is loaded
    if self.GameLoaded then
        -- Get all stats
        local newData = {
            Username = self:GetPlayerUsername(),
            BestFood = self:GetBestFood(),
            TotalCoins = self:GetTotalCoins(),
            Sellable = self:GetSellable(),
            CoinsPickedUp = self:GetCoinsPickedUp(),
            Time = self.Data.Time
        }
        
        -- Update data
        for key, value in pairs(newData) do
            self.Data[key] = value
            if self.Stats and self.Stats[key] then
                self.Stats[key].Text = value
            end
        end
    end
end

function StatsOverlay:UpdateData(newData)
    -- Manual update function (for CurrentStatus)
    for key, value in pairs(newData) do
        if self.Data[key] ~= nil then
            self.Data[key] = value
            
            -- Update GUI if it exists
            if self.Stats and self.Stats[key] then
                self.Stats[key].Text = tostring(value)
            end
        end
    end
end

function StatsOverlay:StartAutoUpdate()
    task.spawn(function()
        while self.Enabled do
            local currentTime = tick()
            
            if currentTime - self.LastUpdate >= self.UpdateInterval then
                self.LastUpdate = currentTime
                
                -- Check if game is loaded
                if not self.GameLoaded then
                    local success, isLoaded = pcall(function()
                        return game:IsLoaded()
                    end)
                    
                    if success and isLoaded then
                        self.GameLoaded = true
                        print("Game loaded - Starting auto-updates")
                    end
                end
                
                -- Update all stats
                self:UpdateAllStats()
            end
            
            task.wait(0.1)
        end
    end)
end

-- Main initialization
function StatsOverlay:Start()
    -- Try to initialize immediately
    local success = pcall(function()
        self:Initialize()
        self:SetupKeybind()
        self:StartAutoUpdate()
    end)
    
    if success then
        print("Full-Screen Overlay started successfully!")
    else
        -- Retry after short delay
        print("Retrying overlay initialization...")
        task.wait(0.5)
        self:Start()
    end
end

-- ===========================================
-- START THE FULL-SCREEN OVERLAY
-- ===========================================
StatsOverlay:Start()

-- Expose API
local OverlayAPI = {
    Update = function(data)
        StatsOverlay:UpdateData(data)
    end,
    
    Toggle = function()
        StatsOverlay:ToggleVisibility()
    end,
    
    GetStats = function()
        return StatsOverlay.Data
    end,
    
    GetClock = function()
        return StatsOverlay:UpdateClock()
    end,
    
    ForceUpdate = function()
        StatsOverlay:UpdateAllStats()
    end,
    
    -- New: Adjust transparency
    SetTransparency = function(bgTransparency, containerTransparency)
        if StatsOverlay.Background then
            StatsOverlay.Background.BackgroundTransparency = bgTransparency or 0.85
        end
        if StatsOverlay.Container then
            StatsOverlay.Container.BackgroundTransparency = containerTransparency or 0.7
        end
    end,
    
    -- New: Adjust size/position
    SetSize = function(widthScale, heightScale)
        if StatsOverlay.Container then
            StatsOverlay.Container.Size = UDim2.new(widthScale or 0.6, 0, heightScale or 0.8, 0)
        end
    end,
    
    SetPosition = function(xScale, yScale)
        if StatsOverlay.Container then
            local currentSize = StatsOverlay.Container.Size
            StatsOverlay.Container.Position = UDim2.new(
                xScale or 0.2, 0,
                yScale or 0.1, 0
            )
        end
    end
}

return OverlayAPI
