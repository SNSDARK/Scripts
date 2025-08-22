local RunService = game:GetService("RunService")

local AttributeTimer = {}

local TimerConnections = {}

-- to set a timer attribute on an object with optional callback
function AttributeTimer.Set(Object, AttributeName, Duration, Options)
	-- Checky check parameters
	if not Object or not AttributeName or type(Duration) ~= "number" then
		warn("AttributeTimer.Set: Invalid parameters")
		return false
	end

	-- options
	Options = Options or {}
	local Callback = Options.Callback
	local OnTick = Options.OnTick
	local CountDown = Options.CountDown ~= false -- Defaults to countdown
	local AutoUpdate = Options.AutoUpdate ~= false -- Defaults to auto-update
	local DestroyOnComplete = Options.DestroyOnComplete == true -- Defaults to not destroying
	local Precision = Options.Precision or 0.1 -- update frequency, default 0.1 seconds

	-- a unique ID for this timer
	local TimerId = AttributeName .. "_" .. Object:GetFullName() .. "_" .. tostring(math.random(1, 10000))

	-- clean any existing timer with the same attribute name on this object
	AttributeTimer.Clear(Object, AttributeName)

	-- initial value
	local StartValue = CountDown and Duration or 0
	local EndValue = CountDown and 0 or Duration

	Object:SetAttribute(AttributeName, StartValue)

	-- If we don't need auto-update, just set the attribute and return
	if not AutoUpdate then
		return TimerId
	end

	-- Create the timer connection
	local StartTime = tick()
	local Connection = RunService.PreSimulation:Connect(function()
		if not Object or not Object:IsDescendantOf(game) then
			-- Object was destroyed, clean up connection
			AttributeTimer.Clear(Object, AttributeName)
			return
		end

		local ElapsedTime = tick() - StartTime
		local NewValue

		if CountDown then
			NewValue = math.max(0, Duration - ElapsedTime)
		else
			NewValue = math.min(Duration, ElapsedTime)
		end

		--  precision
		NewValue = math.floor(NewValue / Precision + 0.5) * Precision

		-- update
		Object:SetAttribute(AttributeName, NewValue)

		-- Call the OnTick callback if provided
		if OnTick and typeof(OnTick) == "function" then
			task.spawn(OnTick, Object, AttributeName, NewValue, ElapsedTime)
		end

		-- check if timer is complete
		local IsComplete = (CountDown and NewValue <= 0) or (not CountDown and NewValue >= Duration)

		if IsComplete then
			AttributeTimer.Clear(Object, AttributeName)

			-- call the completion callback
			if Callback and typeof(Callback) == "function" then
				task.spawn(Callback, Object, AttributeName)
			end

			-- destroy the object
			if DestroyOnComplete and Object then
				Object:Destroy()
			end
		end
	end)

	-- store the connection
	TimerConnections[TimerId] = {
		Connection = Connection,
		Object = Object,
		AttributeName = AttributeName
	}

	return TimerId
end

-- function to clear a timer by object and attribute name
function AttributeTimer.Clear(Object, AttributeName)
	if not Object or not AttributeName then return end

	-- find and disconnect any existing timers for this attribute
	for TimerId, Data in pairs(TimerConnections) do
		if Data.Object == Object and Data.AttributeName == AttributeName then
			if Data.Connection then
				Data.Connection:Disconnect()
			end
			TimerConnections[TimerId] = nil
		end
	end
end

-- to clear a timer by TimerId
function AttributeTimer.ClearById(TimerId)
	if not TimerId or not TimerConnections[TimerId] then return end

	local Data = TimerConnections[TimerId]
	if Data.Connection then
		Data.Connection:Disconnect()
	end
	TimerConnections[TimerId] = nil
end

-- to clear all timers
function AttributeTimer.ClearAll()
	for TimerId, Data in pairs(TimerConnections) do
		if Data.Connection then
			Data.Connection:Disconnect()
		end
	end

	table.clear(TimerConnections)
end

-- to pause a timer
function AttributeTimer.Pause(Object, AttributeName)
	if not Object or not AttributeName then return false end

	for TimerId, Data in pairs(TimerConnections) do
		if Data.Object == Object and Data.AttributeName == AttributeName then
			if Data.Connection then
				Data.Connection:Disconnect()

				-- store remaining time in the timer data
				local CurrentValue = Object:GetAttribute(AttributeName)
				if CurrentValue then
					Data.RemainingTime = CurrentValue
					Data.IsPaused = true
					TimerConnections[TimerId] = Data
					return true
				end
			end
		end
	end

	return false
end

-- to resume a paused timer
function AttributeTimer.Resume(Object, AttributeName)
	if not Object or not AttributeName then return false end

	for TimerId, Data in pairs(TimerConnections) do
		if Data.Object == Object and Data.AttributeName == AttributeName and Data.IsPaused then
			-- create a new timer with the remaining time
			local RemainingTime = Data.RemainingTime or 0

			-- clean up the old timer data
			TimerConnections[TimerId] = nil

			-- get the original options if any
			local Options = Data.Options or {}

			-- start a new timer with the remaining time
			AttributeTimer.Set(Object, AttributeName, RemainingTime, Options)
			return true
		end
	end

	return false
end

-- to get the remaining time of a timer
function AttributeTimer.GetRemaining(Object, AttributeName)
	if not Object or not AttributeName then return 0 end

	local Value = Object:GetAttribute(AttributeName)
	return Value or 0
end

-- to reset a timer
function AttributeTimer.Reset(Object, AttributeName)
	if not Object or not AttributeName then return false end

	for TimerId, Data in pairs(TimerConnections) do
		if Data.Object == Object and Data.AttributeName == AttributeName then
			-- get the original options if any
			local Options = Data.Options or {}
			local Duration = Data.Duration or 0

			-- clear the existing timer
			AttributeTimer.Clear(Object, AttributeName)

			-- start a new timer with the original duration
			AttributeTimer.Set(Object, AttributeName, Duration, Options)
			return true
		end
	end

	return false
end

return AttributeTimer
