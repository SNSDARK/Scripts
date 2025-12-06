local CanSetSimulationRadius = false
local success, err = pcall(function()
    setsimulationradius(math.huge)
end)

if success then
    CanSetSimulationRadius = true
else
    warn("setsimulationradius not supported")
end
