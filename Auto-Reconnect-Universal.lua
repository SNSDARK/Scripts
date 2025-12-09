local Players = game:GetService("Players")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")

local AutoReconnect = {
    Enabled = true,
    MaxRetries = 5,
    RetryDelay = 5,
    CurrentRetry = 0,
    LastDisconnectTime = 0,
    IsTeleporting = false,
    LastTeleportTime = 0,
    LastNormalState = tick(),
    WhitelistedGUIs = {}
}

-- Get the hidden GUI container
local hiddenGUI = gethui()

-- Whitelist of normal loading/teleport screens
AutoReconnect.WhitelistedGUIs = {
    "LoadingScreen",
    "TeleportGui",
    "CoreScriptTeleportGui",
    "DefaultLoadingScreen",
    "RobloxLoadingGUI",
    "LoadScreen",
    "LoadingGui",
    "GameLoadScreen",
    "Loading"
}

function AutoReconnect:IsWhitelistedGUI(guiName)
    guiName = string.lower(guiName)
    
    for _, whitelisted in ipairs(self.WhitelistedGUIs) do
        if guiName:find(string.lower(whitelisted)) then
            return true
        end
    end
    
    return false
end

function AutoReconnect:DetectErrorState()
    if not hiddenGUI then
        warn("[AutoReconnect] gethui() returned nil, falling back to CoreGui")
        hiddenGUI = game:GetService("CoreGui")
    end
    
    -- If we're teleporting, ignore most GUI detection for a while
    if self.IsTeleporting and tick() - self.LastTeleportTime < 30 then
        -- Still check for actual error screens during teleport
        local errorFound = false
        
        for _, guiObject in pairs(hiddenGUI:GetChildren()) do
            if guiObject:IsA("ScreenGui") then
                local name = guiObject.Name:lower()
                
                -- During teleport, only flag severe error screens
                local severeErrors = {
                    "errorfailedtojoin",
                    "errornetwork",
                    "errorconnectionfailed",
                    "errorkicked",
                    "errorbanned"
                }
                
                for _, severeError in ipairs(severeErrors) do
                    if name:find(severeError) then
                        return true, guiObject
                    end
                end
            end
        end
        return false, nil
    end
    
    -- Normal detection (not teleporting)
    for _, guiObject in pairs(hiddenGUI:GetChildren()) do
        if guiObject:IsA("ScreenGui") then
            local name = guiObject.Name:lower()
            
            -- Skip whitelisted loading screens
            if self:IsWhitelistedGUI(name) then
                continue
            end
            
            -- Error screen patterns (excluding teleport-related)
            local errorPatterns = {
                "errorfailed", "errorkick", "errorban",
                "disconnect", "connectionlost",
                "networkerror", "serverfull",
                "kickmessage", "banmessage",
                "errormessage", "rejoinnow"
            }
            
            for _, pattern in ipairs(errorPatterns) do
                if name:find(pattern) then
                    -- Make sure it's not a false positive
                    if not self:IsFalsePositive(guiObject) then
                        print(string.format("[AutoReconnect] Found error screen: %s", guiObject.Name))
                        return true, guiObject
                    end
                end
            end
            
            -- Check descendants for error text (but not loading text)
            if self:CheckDescendantsForErrors(guiObject) then
                print(string.format("[AutoReconnect] Found error text in: %s", guiObject.Name))
                return true, guiObject
            end
        end
    end
    
    return false, nil
end

function AutoReconnect:IsFalsePositive(guiObject)
    -- Check if this might be a normal loading screen or teleport GUI
    
    -- Look for loading indicators
    local loadingIndicators = {
        "loading", "pleasewait", "teleporting",
        "joining", "connecting", "loadingscreen"
    }
    
    local name = string.lower(guiObject.Name)
    for _, indicator in ipairs(loadingIndicators) do
        if name:find(indicator) then
            -- Check if it's actually an error disguised as loading
            for _, descendant in pairs(guiObject:GetDescendants()) do
                if descendant:IsA("TextLabel") then
                    local text = string.lower(tostring(descendant.Text))
                    if text:find("failed") or text:find("error") then
                        return false -- It's actually an error
                    end
                end
            end
            return true -- It's just a loading screen
        end
    end
    
    return false
end

function AutoReconnect:CheckDescendantsForErrors(guiObject)
    -- Look for actual error messages, not loading text
    local errorIndicators = {
        "disconnected from the game",
        "you have been kicked",
        "you are banned",
        "connection failed",
        "failed to join",
        "server is full",
        "error code",
        "unable to connect"
    }
    
    -- Exclude loading messages
    local loadingIndicators = {
        "loading",
        "joining game",
        "teleporting",
        "please wait"
    }
    
    for _, descendant in pairs(guiObject:GetDescendants()) do
        if descendant:IsA("TextLabel") or descendant:IsA("TextButton") or descendant:IsA("TextBox") then
            local text = string.lower(tostring(descendant.Text))
            
            -- First check if it's a loading message
            local isLoading = false
            for _, loadingText in ipairs(loadingIndicators) do
                if text:find(loadingText) then
                    isLoading = true
                    break
                end
            end
            
            if not isLoading then
                -- Check for actual errors
                for _, errorText in ipairs(errorIndicators) do
                    if text:find(errorText) then
                        return true
                    end
                end
            end
        end
    end
    
    return false
end

function AutoReconnect:MonitorTeleportState()
    -- Track when we initiate a teleport
    local teleportService = game:GetService("TeleportService")
    
    -- Listen for teleport initiation
    task.spawn(function()
        while true do
            -- Check if we're in a loading state that might be teleport
            local gameLoaded = pcall(function()
                return game:IsLoaded()
            end)
            
            if not gameLoaded and not self.IsTeleporting then
                -- Might be starting a teleport
                local hasLoadingScreen = false
                if hiddenGUI then
                    for _, gui in pairs(hiddenGUI:GetChildren()) do
                        if gui:IsA("ScreenGui") and self:IsWhitelistedGUI(gui.Name) then
                            hasLoadingScreen = true
                            break
                        end
                    end
                end
                
                if hasLoadingScreen then
                    self.IsTeleporting = true
                    self.LastTeleportTime = tick()
                    print("[AutoReconnect] Detected possible teleport start")
                end
            elseif gameLoaded and self.IsTeleporting then
                -- Teleport completed
                if tick() - self.LastTeleportTime > 5 then
                    self.IsTeleporting = false
                    print("[AutoReconnect] Teleport completed")
                end
            end
            
            task.wait(1)
        end
    end)
end

function AutoReconnect:IsStuckLoading()
    -- Different checks depending on teleport state
    
    if self.IsTeleporting then
        -- During teleport, be more patient
        if tick() - self.LastTeleportTime > 60 then
            -- Stuck in teleport for over 60 seconds
            return true
        end
        return false
    end
    
    -- Normal stuck loading detection
    local startCheckTime = tick()
    
    -- Check if game is stuck in loading state
    local loadedSuccess, isLoaded = pcall(function()
        return game:IsLoaded()
    end)
    
    if not loadedSuccess or not isLoaded then
        -- Wait longer to confirm it's actually stuck (not just slow loading)
        task.wait(10)
        
        local secondCheck = pcall(function()
            return game:IsLoaded()
        end)
        
        if not secondCheck then
            -- Also check for any GUI activity
            local hasGUIActivity = false
            if hiddenGUI then
                for _, gui in pairs(hiddenGUI:GetChildren()) do
                    if gui:IsA("ScreenGui") then
                        hasGUIActivity = true
                        break
                    end
                end
            end
            
            -- If no GUI activity and not loaded for 10+ seconds, it's stuck
            return not hasGUIActivity
        end
    end
    
    return false
end

function AutoReconnect:AttemptReconnection()
    if not self.Enabled or self.CurrentRetry >= self.MaxRetries then
        warn("[AutoReconnect] Max retries reached or disabled")
        return false
    end
    
    self.CurrentRetry += 1
    local currentTime = tick()
    
    -- Prevent rapid reconnection attempts
    if currentTime - self.LastDisconnectTime < 2 then
        return false
    end
    
    self.LastDisconnectTime = currentTime
    
    print(string.format("[AutoReconnect] Attempt %d/%d", self.CurrentRetry, self.MaxRetries))
    
    -- Set teleporting flag to avoid false positives
    self.IsTeleporting = true
    self.LastTeleportTime = tick()
    
    -- Create a visual indicator
    self:CreateReconnectIndicator()
    
    -- Delay before attempting
    task.wait(self.RetryDelay)
    
    -- Try to reconnect using TeleportService
    local success, errorMsg = pcall(function()
        TeleportService:Teleport(game.PlaceId)
    end)
    
    if not success then
        warn("[AutoReconnect] Teleport failed:", errorMsg)
        self:AlternativeRejoin()
    end
    
    return success
end

function AutoReconnect:CreateReconnectIndicator()
    if not hiddenGUI then return end
    
    -- Remove any existing indicator
    for _, gui in pairs(hiddenGUI:GetChildren()) do
        if gui.Name == "AutoReconnectIndicator" then
            gui:Destroy()
        end
    end
    
    -- Create new indicator
    local indicator = Instance.new("ScreenGui")
    indicator.Name = "AutoReconnectIndicator"
    indicator.DisplayOrder = 99999
    
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 200, 0, 50)
    frame.Position = UDim2.new(1, -210, 0, 10)
    frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 0
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.Text = string.format("Auto-Reconnecting... (%d/%d)", self.CurrentRetry, self.MaxRetries)
    label.TextColor3 = Color3.fromRGB(255, 200, 100)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.Gotham
    label.TextSize = 12
    
    label.Parent = frame
    frame.Parent = indicator
    indicator.Parent = hiddenGUI
    
    -- Auto-remove after 8 seconds or when teleport completes
    task.delay(8, function()
        if indicator and indicator.Parent then
            indicator:Destroy()
        end
    end)
end

function AutoReconnect:Initialize()
    print("[AutoReconnect] Initializing with teleport-aware detection")
    
    -- Start teleport state monitoring
    self:MonitorTeleportState()
    
    -- Main monitoring loop
    task.spawn(function()
        local consecutiveErrors = 0
        
        while self.Enabled do
            task.wait(3) -- Check every 3 seconds
            
            -- Skip if we're teleporting (recently)
            if self.IsTeleporting and tick() - self.LastTeleportTime < 15 then
                consecutiveErrors = 0
                continue
            end
            
            -- Check for error screens in gethui()
            local hasError, errorScreen = self:DetectErrorState()
            
            -- Check if game is stuck
            local isStuck = self:IsStuckLoading()
            
            if hasError or isStuck then
                consecutiveErrors += 1
                
                -- Only trigger reconnection after multiple consecutive detections
                if consecutiveErrors >= 2 then
                    local reason = hasError and "Error screen detected" or "Game stuck loading"
                    print(string.format("[AutoReconnect] Triggering reconnection: %s (consecutive: %d)", 
                          reason, consecutiveErrors))
                    
                    self:AttemptReconnection()
                    consecutiveErrors = 0
                    task.wait(5) -- Wait after reconnection attempt
                else
                    print(string.format("[AutoReconnect] Potential issue detected, waiting for confirmation (%d/2)", 
                          consecutiveErrors))
                end
            else
                consecutiveErrors = 0
                self.LastNormalState = tick()
            end
        end
    end)
    
    -- Setup network monitoring
    self:SetupNetworkMonitoring()
end

function AutoReconnect:SetupNetworkMonitoring()
    -- Monitor for actual disconnection events
    
    -- Player removal is a clear disconnection signal
    if Players.LocalPlayer then
        Players.LocalPlayer:GetPropertyChangedSignal("Parent"):Connect(function()
            if not Players.LocalPlayer.Parent then
                print("[AutoReconnect] Player object lost parent")
                task.wait(2)
                if not Players.LocalPlayer.Parent then
                    self:AttemptReconnection()
                end
            end
        end)
    end
    
    -- Listen for disconnection messages
    local success, guiService = pcall(function()
        return game:GetService("GuiService")
    end)
    
    if success then
        guiService.ErrorMessageChanged:Connect(function(message)
            if message then
                local lowerMessage = string.lower(message)
                -- Only trigger on clear disconnection messages, not loading messages
                if lowerMessage:find("disconnected") and 
                   not lowerMessage:find("loading") and
                   not lowerMessage:find("teleporting") then
                    print("[AutoReconnect] GUI Error:", message)
                    task.wait(3)
                    self:AttemptReconnection()
                end
            end
        end)
    end
end

-- Initialize the system
AutoReconnect:Initialize()

-- Export for manual control
return {
    Disable = function()
        AutoReconnect.Enabled = false
        print("[AutoReconnect] Disabled")
    end,
    
    Enable = function()
        AutoReconnect.Enabled = true
        print("[AutoReconnect] Enabled")
    end,
    
    ForceReconnect = function()
        print("[AutoReconnect] Force reconnecting...")
        AutoReconnect:AttemptReconnection()
    end
}