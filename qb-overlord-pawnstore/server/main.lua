function check_auth(src)
	local auth = false
	local Player = QBCore.Functions.GetPlayer(src)
	if CONFIG['Job'] then
		if Player.PlayerData.job.name == CONFIG['JobName'] then
			auth = true
		end
	else
		auth = true
	end
	return auth 
end

QBCore.Functions.CreateCallback('qb-overlord-pawnstore:prices', function(source, cb)
	local prices = json.decode(LoadResourceFile(GetCurrentResourceName(), "./prices.json"))
    cb(prices)
end)

RegisterServerEvent('qb-overlord-pawnstore:selloffline', function()
	if CONFIG['Job'] then
		local total_pawnstaff = 0
		for k, v in pairs(QBCore.Functions.GetPlayers()) do
       		local Player = QBCore.Functions.GetPlayer(v)
       		if Player.PlayerData.job.name == CONFIG['JobName'] then
       			total_pawnstaff = total_pawnstaff + 1
       		end
       	end
		if total_pawnstaff > 0 then
			TriggerClientEvent('QBCore:Notify', source, "Speak to a member of staff!", "error")
			return
		end
	end
	local Player = QBCore.Functions.GetPlayer(source)
	if Player.PlayerData.items ~= nil then
		for _, item in pairs(Player.PlayerData.items) do
			if CONFIG['Prices'][item.name] then
				if CONFIG['Job'] and not CONFIG['Prices'][item.name].offline then
					TriggerClientEvent('QBCore:Notify', source, "Speak to a member of staff to sell "..item.label, "error")
				else
					local payout = CONFIG['Prices'][item.name]['sell'] * item.amount
					if CONFIG['OfflineValue'] then
						payout = payout * CONFIG['OfflineValue']
					end
					payout = math.floor(payout)
					TriggerClientEvent('QBCore:Notify', source, "Sold "..item.amount.."x "..item.label.." for $"..payout, "success")
					Player.Functions.AddMoney("cash", payout, "Pawn store: sold "..item.amount.."x "..item.label)
					Player.Functions.RemoveItem(item.name, item.amount)
					TriggerClientEvent('inventory:client:ItemBox', source, QBCore.Shared.Items[item.name], "remove")
				end
			end
		end
	end
end)

RegisterServerEvent('qb-overlord-pawnstore:buysell', function(selling, itemname, amount)
	if not check_auth(source) then
		print('Player '..source..' is attempting to exploit qb-overlord-pawnstore:buysell!')
		--DropPlayer('qb-overlord-pawnstore : exploit detected!')
		return
	end
	if amount < 1 or amount > CONFIG['Max'] then return end
	local Player = QBCore.Functions.GetPlayer(source)
	if selling then
		local item = Player.Functions.GetItemByName(itemname)
		if item ~= nil and item.amount >= amount then
			local _item = QBCore.Shared.Items[itemname]
			local payout = CONFIG['Prices'][itemname]['sell'] * amount
			Player.Functions.AddMoney("cash", payout, "Pawn store: sold "..amount.."x ".._item.label)
			Player.Functions.RemoveItem(itemname, amount)
			TriggerClientEvent('inventory:client:ItemBox', source, _item, "remove")
			TriggerClientEvent('QBCore:Notify', source, "You sold "..amount.."x ".._item.label, "success")
		else
			TriggerClientEvent('QBCore:Notify', source, "You do not have "..amount.."x "..itemname, "error")
		end
	else
		local _item = QBCore.Shared.Items[itemname]
		local cost = CONFIG['Prices'][itemname]['buy'] * amount
		if Player.PlayerData.money.cash >= cost then
			Player.Functions.RemoveMoney('cash', cost, "Pawn store: bought "..amount.."x ".._item.label)
			Player.Functions.AddItem(itemname, amount)
			TriggerClientEvent('QBCore:Notify', source, "You bought "..amount.."x ".._item.label, "success")
			TriggerClientEvent('inventory:client:ItemBox', source, _item, "add")
		else
			TriggerClientEvent('QBCore:Notify', source, "You cannot afford this!", "error")
		end
	end
end)

Citizen.CreateThread(function()
	Citizen.Wait(1000)
	local prices = json.decode(LoadResourceFile(GetCurrentResourceName(), "./prices.json"))
	if prices then
		if not prices['buy'] then prices['buy'] = {} end
		if not prices['sell'] then prices['sell'] = {} end
		for item, data in pairs(CONFIG.Prices) do
			if prices['buy'][item] then
				CONFIG['Prices'][item]['buy'] = prices['buy'][item]
				print('set '..item..' buy to '..CONFIG['Prices'][item]['buy'])
			end
			if prices['sell'][item] then
				CONFIG['Prices'][item]['sell'] = prices['sell'][item]
				print('set '..item..' sell to '..CONFIG['Prices'][item]['sell'])
			end
		end
	else
		prices = {}
		prices['buy'] = {}
		prices['sell'] = {}
		SaveResourceFile(GetCurrentResourceName(), "./prices.json", json.encode(prices), -1)
	end
	while true do 
		Citizen.Wait(0)
		for item, data in pairs(CONFIG['Prices']) do
			if data.worth then
				if data.worth.lastupdate == 0 or data.worth.lastupdate + data.worth.mininterval < GetGameTimer() then
					local pos = math.random(1,100) < data.worth.chance 
					local difference = math.random(data.worth.min, data.worth.max)
					local new_buy = data.buy
					local new_sell = data.sell
					if pos then
						new_sell = new_sell + difference
						new_buy = new_buy + difference
					else
						new_sell = new_sell - difference
						new_buy = new_buy - difference
					end
					CONFIG['Prices'][item]['buy'] = new_buy
					prices['buy'][item] = new_buy
					CONFIG['Prices'][item]['sell'] = new_sell
					prices['sell'][item] = new_sell
					TriggerClientEvent('qb-overlord-pawnstore:priceupdate', -1, item, new_buy, new_sell)
					SaveResourceFile(GetCurrentResourceName(), "./prices.json", json.encode(prices), -1)
					data.worth.lastupdate = GetGameTimer()
				end
			end
		end
		Citizen.Wait(1000)
	end
end)