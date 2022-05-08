QBCore = nil

TriggerEvent('QBCore:GetObject', function(obj) QBCore = obj end)

RegisterNetEvent("id_playtimereward:addHour")
AddEventHandler("id_playtimereward:addHour", function()
    local Player = QBCore.Functions.GetPlayer(source)

	MySQL.scalar('SELECT hour FROM users WHERE identifier = ?', {identifier}, function(hour)
		if hour < Config.Hours then
            MySQL.Sync.execute('UPDATE users SET hour = hour + 1 WHERE identifier = @identifier', {
                ['@identifier'] = Player.identifier
            })
		end
	end)
end)

QBCore.Functions.CreateCallback('id_playtimereward:getHour', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

	MySQL.scalar('SELECT hour FROM users WHERE identifier = ?', {identifier}, function(hour)
        cb(hour)
	end)
end)

QBCore.Functions.CreateCallback('id_playtimereward:isPlateTaken', function (source, cb, plate)
	MySQL.query('SELECT * FROM owned_vehicles WHERE plate = ?', {plate}, function (result)
		cb(result[1] ~= nil)
	end)
end)

RegisterNetEvent("id_playtimereward:giveReward")
AddEventHandler("id_playtimereward:giveReward", function(plates)
    local Player = QBCore.Functions.GetPlayer(source)

    MySQL.update.await('UPDATE users SET hour = ? WHERE identifier = ?', {0, identifier})

    if Config.Reward == "vehicle" then
        local mods =
        '{"neonEnabled":[false,false,false,false],"modFrame":-1,"modEngine":3,"engineHealth":1000.0,"modSideSkirt":-1,"modFrontBumper":-1,"modOrnaments":-1,"health":995,"modGrille":-1,"modTransmission":2,"plate":"' ..
        plates ..
            '","modTrimB":-1,"fuelLevel":45.91801071167,"modDoorSpeaker":-1,"windows":[1,false,false,false,false,1,1,1,1,false,1,false,false],"modSpeakers":-1,"modAerials":-1,"modTurbo":1,"pearlescentColor":67,"modVanityPlate":-1,"modSpoilers":-1,"modAirFilter":-1,"modArchCover":-1,"tyreSmokeColor":[255,255,255],"modEngineBlock":-1,"modHood":-1,"modRightFender":-1,"bodyHealth":997.25,"dirtLevel":4.0228095054626,"wheels":0,"modPlateHolder":-1,"modBrakes":2,"wheelColor":156,"modSteeringWheel":-1,"modFender":-1,"color2":62,"color1":9,"neonColor":[255,0,255],"modExhaust":-1,"modDial":-1,"model":' ..
                GetHashKey(Config.VehicleReward) ..
                    ',"plateIndex":1,"windowTint":3,"modBackWheels":-1,"tyres":[false,false,false,false,false,false,false],"modTank":-1,"modHydrolic":-1,"modSmokeEnabled":1,"modRearBumper":-1,"modArmor":4,"modFrontWheels":-1,"modRoof":-1,"extras":[],"modAPlate":-1,"modXenon":1,"modLivery":-1,"modDashboard":-1,"modShifterLeavers":-1,"modTrimA":-1,"modTrunk":-1,"modHorns":-1,"modSeats":-1,"modSuspension":3,"modStruts":-1,"modWindows":-1,"doors":[false,false,false,false,false,false]}'

        MySQL.insert("INSERT INTO owned_vehicles (owner, plate, vehicle) VALUES (?, ?, ?)", {identifier, plates, mods}, function(rowsChanged) 
        end)
    end

    if Config.Reward == "money" then
        Player.Functions.AddMoney('bank', Config.MoneyReward, "Bank deposit")
    end

    if Config.Reward == "item" then
        Player.Functions.AddItem(Config.ItemReward, Config.ItemRewardCount, 1, info)
    end
end)