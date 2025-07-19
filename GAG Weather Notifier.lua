local WebhookURL = "https://discord.com/api/webhooks/1396144376446451712/M3bjs3AweDF5I-iRoWW064l4-7EcoMj0MbmeOygoscvuBpiSvoxc1Urp7YjNRy2ZtHrU"
local PlayerData;

local WeatherList = {
    AcidRain = {["Role"] = "<@&1396144603287261274>"},
    --"AirHead" = {["Role"] = ""},
    AlienInvasionEvent = {["Role"] = "<@&1396144657028874381>"},
    ArmageddonEvent = {["Role"] = "<@&1396144716994580530>"},
    AuroraBorealis = {["Role"] = "<@&1396144759180890194>"},
    --"BeeEvent" = {["Role"] = ""},
    --"BeenadoEvent" = {["Role"] = ""},
    --"BeeStorm" = {["Role"] = ""},
    Blackhole = {["Role"] = "<@&1396144988437483632>"},
    BloodMoonEvent = {["Role"] = "<@&1396146353570189392>"},
    ChickenRain = {["Role"] = "<@&1396145067382538452>"},
    ChocolateRain = {["Role"] = "<@&1396145121103315125>"},
    CrystalBeams = {["Role"] = "<@&1396145231732146306>"},
    Disco = {["Role"] = "<@&1396145271720640595>"},
    DJJhai = {["Role"] = "<@&1396145271720640595>"},
    DJSandstorm = {["Role"] = "<@&1396145322543284254>"},
    DroughtEvent = {["Role"] = "<@&1396146188356681748>"},
    Enlightenment = {["Role"] = "<@&1396145369691459675>"},
    FrostEvent = {["Role"] = "<@&1396145441439092949>"},
    Gale = {["Role"] = "<@&1396145486259425320>"},
    HeatwaveEvent = {["Role"] = "<@&1396145547479482610>"},
    --"JandelFloat" = {["Role"] = ""},
    --"JandelLazer" = {["Role"] = ""},
    JanzenStorm = {["Role"] = "<@&1396146229875970180>"},
    --"JandelZombie" = {["Role"] = ""},
    MeteorShower = {["Role"] = "<@&1396145578248765534>"},
    MeteorStrike = {["Role"] = "<@&1396145687908974623>"},
    --"MonsterMash" = {["Role"] = ""},
    NightEvent = {["Role"] = "<@&1396146353570189392>"},
    --"Obby" = {["Role"] = ""},
    --"PoolParty" = {["Role"] = ""},
    RadioactiveCarrot = {["Role"] = "<@&1396146648341811241>"},
    RainEvent = {["Role"] = "<@&1396146766532837417>"},
    Rainbow = {["Role"] = "<@&1396146798443233462>"},
    Sandstorm = {["Role"] = "<@&1396145322543284254>"},
    --"SheckleRain" = {["Role"] = ""},
    ShootingStars = {["Role"] = "<@&1396146921516699899>"},
    SolarEclipse = {["Role"] = "<@&1396146971156283512>"},
    SolarFlareEvent = {["Role"] = "<@&1396147052819251342>"},
    SpaceTravelEvent = {["Role"] = "<@&1396147099036553276>"},
    --"SummerEvent" = {["Role"] = ""},
    SunGod = {["Role"] = "<@&1396149426547855552>"},
    --"TextCollect" = {["Role"] = ""},
    Thunderstorm = {["Role"] = "<@&1396146229875970180>"},
    TornadoEvent = {["Role"] = "<@&1396147140413227149>"},
    TropicalRain = {["Role"] = "<@&1396147170964406412>"},
    UnderTheSea = {["Role"] = "<@&1396147219492634755>"},
    Volcano = {["Role"] = "<@&1396147292020543558>"},
    Windy = {["Role"] = "<@&1396147326841520178>"},
    ZenAura = {["Role"] = "<@&1396147356293922936>"},
}

local function UpdateWebhook(Role)
    PlayerData = game:GetService("HttpService"):JSONEncode({
        ["username"] = "Weather Update",
        ["content"] = Role .. "\n\nLast Updated <t:" .. tostring(os.time()) .. ":R>",
    })
end

local function CheckWeather(Weather)
    if game:GetService("Workspace"):GetAttribute(Weather) then
        return game:GetService("Workspace"):GetAttribute(Weather)
    end
    return false
end

game:GetService("Workspace").AttributeChanged:Connect(function(attr)
    for i,v in pairs (WeatherList) do
        if attr == i and CheckWeather(attr) then
            UpdateWebhook(WeatherList[attr].Role)
            http_request({Url = WebhookURL, Body = PlayerData, Method = "POST", Headers = {["Content-Type"] = "application/json"}})
            break
        end
    end
end)
