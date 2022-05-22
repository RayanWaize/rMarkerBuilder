local ESX = nil
local infoMarker = {}
local allMarkersInServer = {}
local vehEnter = false

Citizen.CreateThread(function()
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
	while ESX == nil do Citizen.Wait(100) end
end)

local function rMarkerBuilderKeyboard(TextEntry, ExampleText, MaxStringLenght)
    AddTextEntry('FMMC_KEY_TIP1', TextEntry)
    blockinput = true
    DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
    while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do 
        Wait(0)
    end
        
    if UpdateOnscreenKeyboard() ~= 2 then
        local result = GetOnscreenKeyboardResult()
        Wait(500)
        blockinput = false
        return result
    else
        Wait(500)
        blockinput = false
        return nil
    end
end

local function menuMarkerBuilder()
    local menuP = RageUI.CreateMenu("Créer un marker", Config.subTitle)
    local menuS = RageUI.CreateSubMenu(menuP, "Gestion des markers", Config.subTitle)
    RageUI.Visible(menuP, not RageUI.Visible(menuP))

    while menuP do
        Citizen.Wait(0)

        RageUI.IsVisible(menuP, true, true, true, function()

            RageUI.Separator("~b~Créer un marker")

            RageUI.ButtonWithStyle("Coordonnées entrée ?", nil, {RightLabel = ""}, true, function(_, _, s)
                if s then
                    infoMarker.coordsenter = GetEntityCoords(GetPlayerPed(-1))
                    ESX.ShowNotification("Vous avez choisi les coordonnées du point d'entrée.")
                end
            end)

            RageUI.ButtonWithStyle("Texte entrée ?", "Appuyez sur ~y~[E]~s~ ", {RightLabel = ""}, true, function(_, _, s)
                if s then
                    local result = rMarkerBuilderKeyboard("Entrez le texte du marker", "", 50)
                    if result ~= nil then
                        infoMarker.textenter = result
                        ESX.ShowNotification("Vous avez choisi le texte du point d'entrée.")
                    else
                        ESX.ShowNotification("Vous avez mis un texte invalide !")
                    end
                end
            end)

            RageUI.ButtonWithStyle("Coordonnées sortie ?", nil, {RightLabel = ""}, true, function(_, _, s)
                if s then
                    infoMarker.coordsexit = GetEntityCoords(GetPlayerPed(-1))
                    ESX.ShowNotification("Vous avez choisi les coordonnées du point d'entrée.")
                end
            end)

            RageUI.ButtonWithStyle("Texte sortie ?", "Appuyez sur ~y~[E]~s~ ", {RightLabel = ""}, true, function(_, _, s)
                if s then
                    local result = rMarkerBuilderKeyboard("Entrez le texte du marker", "", 50)
                    if result ~= nil then
                        infoMarker.textexit = result
                        ESX.ShowNotification("Vous avez choisi le texte du point d'entrée.")
                    else
                        ESX.ShowNotification("Vous avez mis un texte invalide !")
                    end
                end
            end)


            RageUI.Checkbox("Autoriser/Refuser l'accès au véhicule",nil, vehEnter,{},function(Hovered,Ative,Selected,Checked)
                if Selected then
                    vehEnter = Checked
                    if Checked then
                        infoMarker.vehEnter = true
                        ESX.ShowNotification("Vous avez autorisé l'accès au véhicule.")
                    else
                        infoMarker.vehEnter = false
                        ESX.ShowNotification("Vous avez refusé l'accès au véhicule.")
                    end
                end
            end)
            
            
            RageUI.ButtonWithStyle("~g~Créer le marker", nil, {RightLabel = "→→→"}, true, function(_, _, s)
                if s then
                    if infoMarker.coordsenter == nil then
                        ESX.ShowNotification("Vous avez laissé le nom vide.")
                    elseif infoMarker.textenter == nil then
                        ESX.ShowNotification("Vous avez laissé les coordonnées vide.")
                    elseif infoMarker.coordsexit == nil then
                        ESX.ShowNotification("Vous avez laissé le type de blips vide.")
                    elseif infoMarker.textexit == nil then
                        ESX.ShowNotification("Vous avez laissé la couleur de blips vide.")
                    else
                        TriggerServerEvent("rMarkerBuilder:createMarker", infoMarker)
                        refreshTable()
                    end
                end
            end)

            RageUI.ButtonWithStyle("~r~Annuler", nil, {RightLabel = "→→→"}, true, function(_, _, s)
                if s then
                    RageUI.CloseAll()
                    refreshTable()
                end
            end)


            RageUI.Line()

            RageUI.ButtonWithStyle("~o~Gestion des markers", nil, {}, true, function(_, _, s)
                if s then
                    getAllMarkers()
                end
            end, menuS)

        end)

        RageUI.IsVisible(menuS, true, true, true, function()

            RageUI.Separator("~b~Gestion des markers")

            for k,v in pairs(allMarkersInServer) do
                RageUI.ButtonWithStyle("Marker : "..v.id, "Texte entrée : "..v.textenter.."\nTexte sortie : "..v.textexit, {}, true, function(_, _, s)
                    if s then
                        TriggerServerEvent("rMarkerBuilder:deleteMarker", v.id)
                        RageUI.CloseAll()
                    end
                end)
            end

        end)

        if not RageUI.Visible(menuP) and not RageUI.Visible(menuS) then
            menuP = RMenu:DeleteType("menuP", true)
        end
    end
end

RegisterCommand("markersbuilder", function()
    ESX.TriggerServerCallback('rMarkerBuilder:getPlayerGroup', function(result)
        if result == "admin" or result == "superadmin" then
            menuMarkerBuilder()
        else
            ESX.ShowNotification("Vous n'avez pas les droits pour utiliser cette commande.")
        end
    end)
end)

function getAllMarkers()
    ESX.TriggerServerCallback('rMarkerBuilder:getAllMarkers', function(result)
        allMarkersInServer = result
    end)
end


---- Entrée/Sortie


Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rMarkerBuilder:getAllMarkers', function(result)
            while true do
                local Timer = 500
                for k,v in pairs(result) do
                local plyPos = GetEntityCoords(PlayerPedId())
                local pos = vector3(json.decode(v.coordsenter).x, json.decode(v.coordsenter).y, json.decode(v.coordsenter).z)
                local dist = #(plyPos-pos)
                if dist <= 10.0 then
                Timer = 0
                DrawMarker(22, pos, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 0, 255, 0, 255, 55555, false, true, 2, false, false, false, false)
                end
                if dist <= 3.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ "..v.textenter, time_display = 1 })
                    if IsControlJustPressed(1,51) then
                        if v.vehEnter == true then
                            if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
                                teleportPedAndVeh(json.decode(v.coordsexit), GetVehiclePedIsIn(PlayerPedId(), false))
                            else
                                teleportPed(json.decode(v.coordsexit))
                            end
                        else
                            teleportPed(json.decode(v.coordsexit))
                        end
                    end
                end
            end
            Citizen.Wait(Timer)
        end
    end)
end)


Citizen.CreateThread(function()
    ESX.TriggerServerCallback('rMarkerBuilder:getAllMarkers', function(result2)
            while true do
                local Timer = 500
                for k2,v2 in pairs(result2) do
                local plyPos = GetEntityCoords(PlayerPedId())
                local pos2 = vector3(json.decode(v2.coordsexit).x, json.decode(v2.coordsexit).y, json.decode(v2.coordsexit).z)
                local dist = #(plyPos-pos2)
                if dist <= 10.0 then
                Timer = 0
                DrawMarker(22, pos2, 0.0, 0.0, 0.0, 0, 0.0, 0.0, 0.45, 0.45, 0.45, 255, 0, 0, 255, 55555, false, true, 2, false, false, false, false)
                end
                if dist <= 3.0 then
                    Timer = 0
                        RageUI.Text({ message = "Appuyez sur ~y~[E]~s~ "..v2.textexit, time_display = 1 })
                    if IsControlJustPressed(1,51) then
                        if v2.vehEnter == true then
                            if IsPedInAnyVehicle(GetPlayerPed(-1), false) then
                                teleportPedAndVeh(json.decode(v2.coordsenter), GetVehiclePedIsIn(PlayerPedId(), false))
                            else
                                teleportPed(json.decode(v2.coordsenter))
                            end
                        else
                            teleportPed(json.decode(v2.coordsenter))
                        end
                    end
                end
            end
            Citizen.Wait(Timer)
        end
    end)
end)


function teleportPed(coords)
    local playerPed = PlayerPedId()
	SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
end

function teleportPedAndVeh(coords, veh)
    local playerPed = PlayerPedId()
    SetEntityCoords(playerPed, coords.x, coords.y, coords.z)
    SetEntityCoords(veh, coords.x, coords.y, coords.z)
    SetPedIntoVehicle(PlayerPedId(), veh, -1)
end

function refreshTable()
    infoMarker = {}
    vehEnter = false
end