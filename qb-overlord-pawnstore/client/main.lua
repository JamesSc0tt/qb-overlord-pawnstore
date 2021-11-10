local loop_running = 0
local working = false
local menuactive = false

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())

    SetTextScale(0.32, 0.32)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 500
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 0, 0, 0, 80)
end

function doCallback(selling, key, amount)
	if amount < 1 or amount > CONFIG['Max'] then return end
	TriggerServerEvent('qb-overlord-pawnstore:buysell', selling, key, amount)
end

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
    if JobInfo.name == CONFIG['JobName'] then
    	working = true
    	if loop_running < 1 then
    		mainLoop()
    	end
    end
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
	if not CONFIG['Job'] then
		working = true
		if loop_running < 1 then
			mainLoop()
		end
	else
		QBCore.Functions.GetPlayerData(function(PlayerData)
			if PlayerData.job.name == CONFIG['JobName'] then
				working = true
				if loop_running < 1 then
					mainLoop()
				end
			end 
		end)
	end
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        Wait(200)
        if not CONFIG['Job'] then
			working = true
			if loop_running < 1 then
				mainLoop()
			end
		else
			QBCore.Functions.GetPlayerData(function(PlayerData)
				if PlayerData.job.name == CONFIG['JobName'] then
					working = true
					if loop_running < 1 then
						mainLoop()
					end
				end 
			end)
		end
    end
end)


RegisterNetEvent('qb-overlord-pawnstore:priceupdate',function(item, new_buy, new_sell)
	CONFIG['Prices'][item]['buy'] = new_buy
	CONFIG['Prices'][item]['sell'] = new_sell
	if working then
		local _item = QBCore.Shared.Items[item]
		TriggerEvent('chatMessage', 'PAWN STORE', 'info',  _item.label..' is now worth: $'..new_sell)
	end
end)

local menu = MenuV:CreateMenu('Pawn Store', 'Harrison\'s Pawn & Loan', 'middleleft', 255, 0, 0, 'size-125', 'default', 'menuv', 'pawnstore_main', 'native')
local buyMenu = MenuV:CreateMenu('Buy', 'Buy Product(s)', 'middleleft', 255, 0, 0, 'size-125', 'default', 'menuv', 'pawnstore_buy', 'native')
local sellMenu = MenuV:CreateMenu('Sell', 'Sell Product(s)', 'middleleft', 255, 0, 0, 'size-125', 'default', 'menuv', 'pawnstore_sell', 'native')

menu:AddButton({ icon = '', label = 'Buy', value = buyMenu, description = 'Buy goods from the store\'s stock' })
menu:AddButton({ icon = '', label = 'Sell', value = sellMenu, description = 'Sell goods to the store' })

buyMenu:On('open', function(m)
    m:ClearItems()
    for _, item in pairs(CONFIG['Items']) do
    	local _item = QBCore.Shared.Items[item]
    	local _worth = CONFIG['Prices'][item]['buy']
    	if _item and _worth then
    		local slider = m:AddSlider({ false,
	    		label = _item['label']..' ($'.._worth..')',
	    		min = 1,
	    		max = CONFIG['Max'],
	    		value = 0,
	    		values = {},
	    		description = item,
	    		saveOnUpdate = false,
	    		select = function(i)
	    			if CONFIG['debug'] then
	    				print('Attempting to buy '..i.data:GetValue()..'x '..i.data.Description)
	    			end
	    			doCallback(false, i.data.Description, i.data:GetValue())
		    	end
		    })
	    	for i=1, CONFIG['Max'] do
	    		slider:AddValue({
	    			label = i,
	    			value = i
	    		})
	    	end
    	end
    end
end)

sellMenu:On('open', function(m)
    m:ClearItems()
    for _, item in pairs(CONFIG['Items']) do
    	local _item = QBCore.Shared.Items[item]
    	local _worth = CONFIG['Prices'][item]['sell']
    	if _item and _worth then
    		local slider = m:AddSlider({ false,
	    		label = _item['label']..' ($'.._worth..')',
	    		min = 1,
	    		max = CONFIG['Max'],
	    		value = 0,
	    		values = {},
	    		description = item,
	    		saveOnUpdate = false,
	    		select = function(i)
	    			if CONFIG['debug'] then
	    				print('Attempting to buy '..i.data:GetValue()..'x '..i.data.Description)
	    			end
	    			doCallback(true, i.data.Description, i.data:GetValue())
		    	end
		    })
	    	for i=1, CONFIG['Max'] do
	    		slider:AddValue({
	    			label = i,
	    			value = i
	    		})
	    	end
    	end
    end
end)

function mainLoop()
	loop_running = loop_running + 1
	while working do Citizen.Wait(0)
		local plycoords = GetEntityCoords(PlayerPedId())
		if #(CONFIG['Locations']['Sell'] - plycoords) < 2 then
			if #(CONFIG['Locations']['Sell'] - plycoords) < 1.0 then
				DrawText3Ds(CONFIG['Locations']['Sell'].x, CONFIG['Locations']['Sell'].y, CONFIG['Locations']['Sell'].z, 'E - Use Laptop')
				if IsControlJustPressed(0,38) and not menuactive then
					MenuV:OpenMenu(menu)
				end
			else
				DrawText3Ds(CONFIG['Locations']['Sell'].x, CONFIG['Locations']['Sell'].y, CONFIG['Locations']['Sell'].z, 'Work Laptop')
			end
		end
	end
	loop_running = loop_running - 1
end

Citizen.CreateThread(function()
	Citizen.Wait(5000)
	if CONFIG['UseBlip'] then
		local blip = AddBlipForCoord(CONFIG['Locations']['Blip'])
        SetBlipSprite(blip, CONFIG['Blip'].sprite)
	    SetBlipColour(blip, CONFIG['Blip'].color)
		SetBlipScale(blip, CONFIG['Blip'].scale)
		SetBlipAsShortRange(blip, CONFIG['Blip'].shortrange)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString(CONFIG['Blip'].name)
		EndTextCommandSetBlipName(blip)
	end
	QBCore.Functions.TriggerCallback('qb-overlord-pawnstore:prices', function(prices)
		for item, data in pairs(CONFIG['Prices']) do
			if prices['buy'][item] then
				CONFIG['Prices'][item]['buy'] = prices['buy'][item]
			end
			if prices['sell'][item] then
				CONFIG['Prices'][item]['sell'] = prices['sell'][item]
			end
		end
	end)
	while true do Citizen.Wait(0) -- forgot this and crashed the entire server, well done james...
		local plypos = GetEntityCoords(PlayerPedId())
		local distfromoffline = #(CONFIG['Locations']['Offline'] - plypos)
		if distfromoffline < 2 then
			if distfromoffline < 1.5 then
				DrawText3Ds(CONFIG['Locations']['Offline'].x, CONFIG['Locations']['Offline'].y, CONFIG['Locations']['Offline'].z, 'E - Sell Goods')
				if IsControlJustPressed(0,38) then 
					TriggerServerEvent('qb-overlord-pawnstore:selloffline')
				end 
			else
				DrawText3Ds(CONFIG['Locations']['Offline'].x, CONFIG['Locations']['Offline'].y, CONFIG['Locations']['Offline'].z, 'Sell Goods')
			end
		end
		local distfromstash = #(CONFIG['Locations']['Stash'] - plypos)
		if distfromstash < 2 then
			if distfromstash < 1.5 then
				DrawText3Ds(CONFIG['Locations']['Stash'].x, CONFIG['Locations']['Stash'].y, CONFIG['Locations']['Stash'].z, 'E - Access Counter')
				if IsControlJustPressed(0,38) then 
					TriggerServerEvent("inventory:server:OpenInventory", "stash", 'pawn_store')
					TriggerEvent("inventory:client:SetCurrentStash", 'pawn_store')
				end 
			else
				DrawText3Ds(CONFIG['Locations']['Stash'].x, CONFIG['Locations']['Stash'].y, CONFIG['Locations']['Stash'].z, 'Counter')
			end
		end
	end
end)
