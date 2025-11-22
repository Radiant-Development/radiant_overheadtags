-----------------------------------------
-- R A D I A N T   D E V   C L I E N T
-----------------------------------------

local Config   = Config
local tags     = {}
local showTags = true  -- F6 toggle

-----------------------------------------------------
-- SYNC: UPDATE TAG TABLE FROM SERVER
-----------------------------------------------------
RegisterNetEvent("radiant:tags:updateAll", function(data)
    tags = data or {}
end)

-----------------------------------------------------
-- OPEN NUI MENU (WITH ROLE DROPDOWN DATA)
-----------------------------------------------------
RegisterNetEvent("radiant:tags:openMenu", function(roleOptions)
    SetNuiFocus(true, true)

    SendNUIMessage({
        action = "open",
        roles  = roleOptions or {}
    })
end)

-----------------------------------------------------
-- NUI CALLBACK: CLOSE MENU
-----------------------------------------------------
RegisterNUICallback("close", function(_, cb)
    SetNuiFocus(false, false)
    cb("ok")
end)

-----------------------------------------------------
-- NUI CALLBACK: SAVE TAG
-----------------------------------------------------
-- Expects payload from JS:
-- {
--   role    = "DEV" / "LSPD Officer" / etc,
--   message = "please do not disturb",
--   style   = "solid" / "lr",
--   r,g,b   = number,
--   r2,g2,b2= number (optional)
-- }
-----------------------------------------------------
RegisterNUICallback("saveTag", function(data, cb)
    -- Send whole payload to server (server expects table)
    TriggerServerEvent("radiant:tags:setTag", data)

    SetNuiFocus(false, false)
    cb("ok")
end)

-----------------------------------------------------
-- COMMAND + KEYBIND: TOGGLE TAG VISIBILITY (F6)
-----------------------------------------------------
RegisterCommand("toggletags", function()
    showTags = not showTags
end, false)

RegisterKeyMapping("toggletags", "Toggle Overhead Tags", "keyboard", "F6")

-----------------------------------------------------
-- HELPER: LINE OF SIGHT CHECK
-----------------------------------------------------
local function HasLOS(from, to)
    local handle = StartExpensiveSynchronousShapeTestLosProbe(
        from.x, from.y, from.z + 0.1,
        to.x,   to.y,   to.z + 0.1,
        -1, 0, 4
    )

    local _, hit = GetShapeTestResult(handle)
    return not hit
end

-----------------------------------------------------
-- HELPER: 3D → 2D SCREEN
-----------------------------------------------------
local function ToScreen(x, y, z)
    local onScreen, sx, sy = World3dToScreen2d(x, y, z)
    return onScreen, sx, sy
end

-----------------------------------------------------
-- DRAW: TEXT (SOLID OR LR GRADIENT)
-----------------------------------------------------
local function DrawText3DGradient(sx, sy, txt, c1, c2, style)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextCentre(true)

    if style == "lr" then
        -- Left side
        SetTextColour(c1[1], c1[2], c1[3], 255)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(txt)
        EndTextCommandDisplayText(sx - 0.001, sy)

        -- Right side overlay
        SetTextColour(c2[1], c2[2], c2[3], 255)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(txt)
        EndTextCommandDisplayText(sx + 0.001, sy)
    else
        -- Solid color
        SetTextColour(c1[1], c1[2], c1[3], 255)
        BeginTextCommandDisplayText("STRING")
        AddTextComponentSubstringPlayerName(txt)
        EndTextCommandDisplayText(sx, sy)
    end
end

-----------------------------------------------------
-- MAIN DRAW LOOP
-----------------------------------------------------
CreateThread(function()
    while true do
        Wait(0)

        if not showTags or not tags then
            goto continue
        end

        local myPed    = PlayerPedId()
        local myCoords = GetEntityCoords(myPed)

        for src, info in pairs(tags) do
            local ply = GetPlayerFromServerId(src)
            if ply ~= -1 then
                local ped    = GetPlayerPed(ply)
                local coords = GetEntityCoords(ped)
                local dist   = #(coords - myCoords)

                if dist < (Config.DrawDistance or 35.0) then
                    if not Config.RequireLineOfSight or HasLOS(myCoords, coords) then
                        local onScreen, sx, sy = ToScreen(coords.x, coords.y, coords.z + 1.15)
                        if onScreen then
                            local color1 = info.color  or {255, 255, 255}
                            local color2 = info.color2 or color1
                            local style  = info.style  or "solid"

                            -- Top line: main tag text (DEV / LSPD Officer)
                            if info.text and info.text ~= "" then
                                DrawText3DGradient(sx, sy, info.text, color1, color2, style)
                            end

                            -- Second line: optional sub-message, slightly lower
                            if info.message and info.message ~= "" then
                                DrawText3DGradient(sx, sy + 0.020, info.message, color1, color2, style)
                            end
                        end
                    end
                end
            end
        end

        ::continue::
    end
end)
