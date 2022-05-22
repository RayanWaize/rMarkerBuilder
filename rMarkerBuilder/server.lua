local ESX

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('rMarkerBuilder:getPlayerGroup', function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local group = xPlayer.getGroup()
    cb(group)
end)


ESX.RegisterServerCallback('rMarkerBuilder:getAllMarkers', function(source, cb)
	local allMarkers = {}
	MySQL.Async.fetchAll("SELECT * FROM markerbuilder", {}, function(data)
        for _,v in pairs(data) do
			table.insert(allMarkers, {
                id = v.id,
				coordsenter = v.coordsenter,
				coordsexit = v.coordsexit,
				textenter = v.textenter,
                textexit = v.textexit,
                vehEnter = v.vehenter,
			})
        end
        cb(allMarkers)
    end)
end)


RegisterServerEvent('rMarkerBuilder:createMarker')
AddEventHandler('rMarkerBuilder:createMarker', function(infoMarker)
    local _src = source
    MySQL.Async.execute("INSERT INTO markerbuilder (coordsenter, coordsexit, textenter, textexit, vehenter) VALUES (@coordsenter, @coordsexit, @textenter, @textexit, @vehenter)", {
        ['@coordsenter'] = json.encode(infoMarker.coordsenter),
        ['@coordsexit'] = json.encode(infoMarker.coordsexit),
        ['@textenter'] = infoMarker.textenter,
        ['@textexit'] = infoMarker.textexit,
        ['@vehenter'] = infoMarker.vehEnter,
    }, function(rowsChanged)
        TriggerClientEvent('esx:showNotification', _src, "Vous avez créé un marker.")
    end)
end)


RegisterServerEvent('rMarkerBuilder:deleteMarker')
AddEventHandler('rMarkerBuilder:deleteMarker', function(id)
    local _src = source
    MySQL.Async.execute("DELETE FROM markerbuilder WHERE id = @id", {
        ['@id'] = id
    }, function(rowsChanged)
        TriggerClientEvent('esx:showNotification', _src, "Vous avez supprimé un marker.")
    end)
end)