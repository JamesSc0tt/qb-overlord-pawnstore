QBCore = exports['qb-core']:GetSharedObject() -- do not touch


CONFIG = {} -- do not touch

CONFIG['Debug'] = false

CONFIG['Job'] = false -- if you want the menu to only be accessible by the below job
CONFIG['JobName'] = 'pawnstore'

CONFIG['Max'] = 10 -- maximum items to buy/sell at one time

CONFIG['Locations'] = {} -- do not touch
CONFIG['Locations']['Sell'] = vector3(-269.757, 234.112, 90.60) -- where the menu is
CONFIG['Locations']['Stash'] = vector3(-266.44, 236.98, 90.57) -- where the counter is

CONFIG['UseBlip'] = true -- enable map blip
CONFIG['Locations']['Blip'] = vector3(-272.74, 243.68, 90.4)
CONFIG['Blip'] = {
	sprite = 431,
	color = 28,
	scale = 0.75,
	shortrange = true,
	name = "Harrison's Pawn Shop",
}

CONFIG['AllowOfflineSale'] = true -- allow players to sell at the offline spot if nobody with the job is available
CONFIG['OfflineValue'] = 0.8 -- % of full sale value when no player online (false to disable)
CONFIG['Locations']['Offline'] = vector3(-281.41, 243.7, 89.69) -- where the '[E] to sell goods' is

CONFIG['Items'] = { -- items that can be bought/sold at the pawnstore
	'goldbar',
	'rolex',
}

CONFIG['Prices'] = {} -- do not touch
CONFIG['Prices']['goldbar'] = {
	buy = 4500, -- the price the item can be bought at the laptop for 
	sell = 4000, -- the price the item can be sold at the laptop for
	offline = true, -- can the item be sold without a player with the job
	worth = { -- worth can be false if you do not want the prices to fluctuate
		min = 5, -- min the price can go up/down by 
		max = 15, -- max the price can go up/down by
		mininterval = 12000000, -- minimum time since last variation to go up/down (milliseconds)
		chance = 25, -- chance of it going up
		lastupdate = 0, -- do not touch
	},
}
CONFIG['Prices']['rolex'] = {
	buy = 400,
	sell = 250,
	offline = true,
	worth = false,
}