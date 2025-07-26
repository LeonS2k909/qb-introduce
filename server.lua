local QBCore = exports['qb-core']:GetCoreObject()
local canSeeNames = {}

RegisterNetEvent('playernames:getAllPlayerNames', function()
    local src = source
    local players = {}
    for _, player in ipairs(QBCore.Functions.GetPlayers()) do
        local Player = QBCore.Functions.GetPlayer(player)
        if Player then
            local name = Player.PlayerData.charinfo.firstname .. " " .. Player.PlayerData.charinfo.lastname
            players[tostring(player)] = name
        end
    end
    TriggerClientEvent('playernames:receiveAllPlayerNames', src, players)
end)

RegisterNetEvent('playernames:getNamesICanSee', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local admin = false

    -- QBCore permission check
    if Player then
        local perms = Player.PlayerData.permission or ""
        if perms == "god" or perms == "admin" then
            admin = true
        end
    end

    -- ACE permission check
    if IsPlayerAceAllowed(src, "command") then
        admin = true
    end

    if admin then
        -- Admins can see all names
        local allPlayers = {}
        for _, player in ipairs(QBCore.Functions.GetPlayers()) do
            if player ~= src then
                allPlayers[tostring(player)] = true
            end
        end
        TriggerClientEvent('playernames:receiveNamesICanSee', src, allPlayers)
    else
        TriggerClientEvent('playernames:receiveNamesICanSee', src, canSeeNames[src] or {})
    end
end)

RegisterNetEvent('playernames:introduceTo', function(targetId)
    local src = source
    if not canSeeNames[targetId] then canSeeNames[targetId] = {} end
    canSeeNames[targetId][tostring(src)] = true
    TriggerClientEvent('playernames:addNameICanSee', targetId, src)
end)

RegisterNetEvent('playernames:checkAdmin', function()
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    local admin = false

    -- QBCore permission check
    if Player then
        local perms = Player.PlayerData.permission or ""
        if perms == "god" or perms == "admin" then
            admin = true
        end
    end

    -- ACE permission check
    if IsPlayerAceAllowed(src, "command") then
        admin = true
    end

    TriggerClientEvent('playernames:setAdmin', src, admin)
end)
