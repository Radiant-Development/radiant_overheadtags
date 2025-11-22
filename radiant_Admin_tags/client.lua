--[[
██████   █████  ██████  ██  █████  ███    ██ ████████
██   ██ ██   ██ ██   ██ ██ ██   ██ ████   ██    ██
██████  ███████ ██   ██ ██ ███████ ██ ██  ██    ██
██   ██ ██   ██ ██   ██ ██ ██   ██ ██  ██ ██    ██
██   ██ ██   ██ ██████  ██ ██   ██ ██   ████    ██
        R A D I A N T   D E V E L O P M E N T
]]

local Config = Config
local tags = {}
local showTags = true   -- F6 toggle

---------------------------------------------------------------------
-- UPDATE TAGS FROM SERVER
---------------------------------------------------------------------
RegisterNetEvent("radiant:tags:updateAll", function(data)
    tags = data or {}
end)

---------------------------------------------------------------------
-- OPEN NUI
---------------------------------------------------------------------
RegisterNetEvent("radiant:tags:openMenu", function()
    SetNuiFocus(true, true)
    SendNUIMessage({ action = "open" })
end)

---------------------------------------------------------------------
-- CLOSE NUI CALLBACK
---------------------------------------------------------------------
RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

---------------------------------------------------------------------
-- SAVE TAG CALLBACK (solid + left→right gradient)
---------------------------------------------------------------------
RegisterNUICallback("saveTag", function(data, cb)

    TriggerServerEvent(
        "radiant:tags:setTag",
        data.text,
        data.r, data.g, data.b,
        data.r2, data.g2, data.b2,
        data.style
    )

    SetNuiFocus(false, false)
    cb("ok")
end)

---------------------------------------------------------------------
-- TOGGLE TAG VISIBILITY (F6)
---------------------------------------------------------------------
RegisterCommand("toggletags", function()
    showTags = not showTags
end)
RegisterKeyMapping("toggletags", "Toggle Overhead Tags", "keyboard", "F6")

---------------------------------------------------------------------
-- HELPER: LINE OF SIGHT CHECK
---------------------------------------------------------------------
local function HasLOS(from, to)
    local hit = StartExpensiveSynchronousShapeTestLosProbe(
        from.x, from.y, from.z + 0.1,
        to.x,   to.y,   to.z + 0.1,
        -1, 0, 4
    )
    local _, hitBool = GetShapeTestResult(hit)
    return not hitBool
end

---------------------------------------------------------------------
-- HELPER: GET SCREEN COORD
---------------------------------------------------------------------
local function WorldToScreen(x, y, z)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    return onScreen, sx, sy
end

---------------------------------------------------------------------
-- GRADIENT DRAWER (SOLID OR LR GRADIENT)
---------------------------------------------------------------------
local function DrawText3DGradient(x, y, z, txt, c1, c2, style)
    local onScreen, sx, sy = WorldToScreen(x, y, z)
    if not onScreen then return end

    SetTextScale(0.35, 0.35)
    SetTextCentre(true)
    SetTextFont(4)
    SetTextProportional(1)

    if style == "lr" then
        -- Left → Right approximate gradient
        -- (We simulate a gradient by drawing text twice with clipping)
        
        -- Left half
        SetTextColour(c1[1], c1[2], c1[3], 255)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(txt)
        SetScriptGfxDrawOrder(0)
        SetScriptGfxDrawBehindPausemenu(true)
        EndTextCommandDisplayText(sx - 0.001, sy)

        -- Right half overlay
        SetTextColour(c2[1], c2[2], c2[3], 255)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(txt)
        EndTextCommandDisplayText(sx + 0.001, sy)

    else
        -- SOLID MODE
        SetTextColour(c1[1], c1[2], c1[3], 255)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(txt)
        EndTextCommandDisplayText(sx, sy)
    end
end

---------------------------------------------------------------------
-- MAIN DRAW LOOP
---------------------------------------------------------------------
CreateThread(function()
    while true do
        Wait(0)

        if not showTags or tags == nil then goto continue end

        local myPed = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)

        for src, info in pairs(tags) do
            local target = GetPlayerFromServerId(src)
            if target ~= -1 then
                local ped = GetPlayerPed(target)
                local coords = GetEntityCoords(ped)
                local dist = #(coords - myCoords)

                -- distance check
                if dist < Config.DrawDistance then

                    -- LOS check
                    if not Config.RequireLineOfSight or HasLOS(myCoords, coords) then
                        DrawText3DGradient(
                            coords.x, coords.y, coords.z + 1.2,
                            info.text,
                            info.color,
                            info.color2 or info.color,
                            info.style or "solid"
                        )
                    end
                end
            end
        end

        ::continue::
    end
end)
