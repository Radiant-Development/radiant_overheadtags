local tags = {}

RegisterNetEvent("radiant:tags:updateAll", function(newTags)
    tags = newTags
end)

RegisterNetEvent("radiant:tags:openMenu", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })
end)

RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("saveTag", function(data, cb)
    TriggerServerEvent("radiant:tags:setTag", data.text, data.r, data.g, data.b)
    SetNuiFocus(false, false)
    cb("ok")
end)

-----------------------------------
-- DRAW TAG
-----------------------------------
CreateThread(function()
    while true do
        Wait(0)
        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)

        for sid, info in pairs(tags) do
            local target = GetPlayerFromServerId(sid)
            if target ~= -1 then
                local ped = GetPlayerPed(target)
                local coords = GetEntityCoords(ped)
                local dist = #(myCoords - coords)

                if dist < 30 then
                    DrawText3D(coords.x, coords.y, coords.z + 1.2, info.text, info.color)
                end
            end
        end
    end
end)

function DrawText3D(x,y,z,text,color)
    local onScreen,_x,_y = World3dToScreen2d(x, y, z)
    if not onScreen then return end

    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(color[1], color[2], color[3], 255)
    SetTextCentre(true)

    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(_x,_y)
end
