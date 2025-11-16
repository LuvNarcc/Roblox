--[[

    DataService
    ==============

    Purpose:
    Handles player data with Roblox DataStores.
    Keeps a local cache while players are in-game,
    and syncs data back to the DataStore when needed.

    Usage:
    • Load(player)      → Fetch or create default data
    • Get(player)       → Access cached data
    • Set/Increment     → Modify stats safely
    • Save(player)      → Write data to DataStore
    • Unload(player)    → Clear cache on leave
    • Reset(player)     → Wipe data back to defaults

    Notes:
    • Each player gets their own copy of DEFAULT_DATA
    • Extend DEFAULT_DATA with your own stats
    • Designed to be simple, reusable, and safe

]]




--// DataService \\--

local DataService = {}

--// Default Data \\--

local DEFAULT_DATA = {
    TimePlayed = 0,
    Wins = 0,
    HighestLevelReached = 1,
    Credits = 0,
}

--// Services \\--

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

--// DataStore \\--

local DataStoreKey = RunService:IsStudio() and "PlayerData_Studio" or "PlayerData"
local PlayerDataStore = DataStoreService:GetDataStore(DataStoreKey)

--// Internal Cache \\--

local PlayerCache = {}

--// Utility Functions \\--

function DataService.DeepCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = typeof(v) == "table" and DataService.DeepCopy(v) or v
    end
    return copy
end

--// Core Functions \\--

function DataService.LoadData(UserId, player)
    local success, data = pcall(function()
        return PlayerDataStore:GetAsync(tostring(UserId))
    end)

    if success and typeof(data) == "table" then
        for key, defaultValue in pairs(DEFAULT_DATA) do
            if data[key] == nil then
                data[key] = defaultValue
            end
        end
        PlayerCache[player] = data
    else
        PlayerCache[player] = DataService.DeepCopy(DEFAULT_DATA)
    end

    return PlayerCache[player]
end

function DataService.GetData(player)
    return PlayerCache[player]
end

function DataService.SaveData(UserId, data)
    pcall(function()
        PlayerDataStore:SetAsync(tostring(UserId), data)
    end)
end

function DataService.SavePlayer(player)
    local data = PlayerCache[player]
    if data then
        DataService.SaveData(player.UserId, data)
    end
end

function DataService.Unload(player)
    PlayerCache[player] = nil
end

--// Convenience Functions \\--

function DataService.SetStat(player, key, value)
    local data = PlayerCache[player]
    if data and DEFAULT_DATA[key] ~= nil then
        data[key] = value
    end
end

function DataService.IncrementStat(player, key, amount)
    local data = PlayerCache[player]
    if data and DEFAULT_DATA[key] ~= nil then
        data[key] = (data[key] or 0) + amount
    end
end

function DataService.HasData(player)
    return PlayerCache[player] ~= nil
end

function DataService.ResetPlayerData(player)
    if not player then return end
    local resetData = DataService.DeepCopy(DEFAULT_DATA)
    PlayerCache[player] = resetData
    DataService.SaveData(player.UserId, resetData)
    return resetData
end

return DataService
