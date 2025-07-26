local playerNames = {}
local namesICanSee = {}
local isAdmin = false
local showDistance = Config.NameDisplayDistance or 25.0
local offsetZ = Config.OffsetZ or 1.0

RegisterNetEvent('playernames:receiveAllPlayerNames', function(names)
    playerNames = names
end)

RegisterNetEvent('playernames:receiveNamesICanSee', function(names)
    namesICanSee = names or {}
end)

RegisterNetEvent('playernames:addNameICanSee', function(serverId)
    namesICanSee[tostring(serverId)] = true
end)

RegisterNetEvent('playernames:setAdmin', function(state)
    isAdmin = state
end)

Citizen.CreateThread(function()
    while true do
        Wait(Config.RefreshTime or 5000)
        TriggerServerEvent('playernames:getAllPlayerNames')
        TriggerServerEvent('playernames:getNamesICanSee')
        TriggerServerEvent('playernames:checkAdmin')
    end
end)

Citizen.CreateThread(function()
    while true do
        Wait(0)
        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)
        for _, player in ipairs(GetActivePlayers()) do
            local serverId = GetPlayerServerId(player)
            if serverId ~= GetPlayerServerId(PlayerId()) then
                local targetPed = GetPlayerPed(player)
                if DoesEntityExist(targetPed) then
                    local targetCoords = GetEntityCoords(targetPed)
                    local dist = #(myCoords - targetCoords)
                    if dist < showDistance or isAdmin then
                        local displayName = "Unknown"
                        if namesICanSee[tostring(serverId)] or isAdmin then
                            displayName = playerNames[tostring(serverId)] or "Unknown"
                        end
                        DrawText3D(targetCoords.x, targetCoords.y, targetCoords.z + offsetZ, displayName)
                    end
                end
            end
        end
    end
end)

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = GetDistanceBetweenCoords(px, py, pz, x, y, z, 1)
    local scale = (1 / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    scale = scale * fov
    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(Config.TextColor.r, Config.TextColor.g, Config.TextColor.b, Config.TextColor.a)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 370
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 41, 11, 41, 68)
    end
end

exports['qb-target']:AddGlobalPlayer({
    options = {
        {
            type = "client",
            event = "playernames:attemptIntroduce",
            icon = "fas fa-id-card",
            label = "Introduce Yourself",
            canInteract = function(entity, distance, data)
                local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(entity))
                return distance < 3.0 and targetId ~= GetPlayerServerId(PlayerId())
            end
        }
    },
    distance = 3.0
})

RegisterNetEvent('playernames:attemptIntroduce', function(data)
    local targetPed = data.entity
    local targetId = GetPlayerServerId(NetworkGetPlayerIndexFromPed(targetPed))
    if targetId and targetId ~= GetPlayerServerId(PlayerId()) then
        TriggerServerEvent('playernames:introduceTo', targetId)
    end
end)
