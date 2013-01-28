--[[

	PointShop MySQL Adapter by _Undefined
	
	Usage:
	
		First, make sure you have the MySQLOO module installed from:
			http://www.facepunch.com/showthread.php?t=1220537
			Installation instructions are in that thread.
	
		Then configure your MySQL details below and import the tables into your
			database using the provided sql file. If you do not have a database
			already set up, do that before importing the file.
		
		MAKE SURE YOU ALLOW REMOTE ACCESS TO YOUR DATABASE FROM YOUR GMOD SERVERS IP ADDRESS.
	
]]--

-- config, change these to match your setup

local mysql_hostname = 'localhost' -- Your MySQL server address.
local mysql_username = 'root' -- Your MySQL username.
local mysql_password = '' -- Your MySQL password.
local mysql_database = 'pointshop' -- Your MySQL database.
local mysql_port = 3306 -- Your MySQL port. Most likely is 3306.

local sync_delay = 30 -- Number of seconds between this server updating from MySQL.

-- end config, don't change anything below unless you know what you're doing

require('mysqloo')

local shouldmysql = false

if not mysqloo then
	Error('PointShop MySQL: MySQLOO is missing! Please install the module: http://www.facepunch.com/showthread.php?t=1220537' .. "\n")
	return
end

local PS_Points = {}
local PS_Items = {}

local db = mysqloo.connect(mysql_hostname, mysql_username, mysql_password, mysql_database, mysql_port)

function db:onConnected()
	MsgN('PointShop MySQL: Connected!')
	
	shouldmysql = true
	
	PS_MySQL_Sync(true)
	
	timer.Create('PS_MySQL_Sync', sync_delay, 0, PS_MySQL_Sync) -- start the timer to update points
end

function db:onConnectionFailed(err)
	MsgN('PointShop MySQL: Connection Failed, please check your settings: ' .. err)
end

db:connect()

function PS_MySQL_Sync(all)
	if not shouldmysql then return end
	if not all and #player.GetAll() < 1 then return end
	
	local IDs = ""
	
	for k,v in pairs(player.GetAll()) do
		IDs = IDs .. (#IDs == 0 and "" or ", ") .. "'" .. v:UniqueID() .. "'"
	end
	
	-- get points
	
	local q
	
	if all then
		q = db:query("SELECT * FROM `pointshop_points`")
	else
		q = db:query("SELECT * FROM `pointshop_points` WHERE `uniqueid` IN (" .. IDs ..")")
	end
	
	function q:onSuccess(data)
		for _, row in pairs(data) do
			PS_Points[tostring(row.uniqueid)] = row.points
			
			local ply = player.GetByUniqueID(tostring(row.uniqueid))
			
			if ply then
				ply.PS_Points = PS:ValidatePoints(tonumber(row.points))
				ply:PS_SendPoints()
			end
		end
	end
	
	function q:onError(err, sql)
		MsgN('PointShop MySQL: Query Failed: ' .. err .. ' (' .. sql .. ')')
	end
	
	q:start()
	
	-- get items
	
	local q
	
	if all then
		q = db:query("SELECT * FROM `pointshop_items`")
	else
		q = db:query("SELECT * FROM `pointshop_items` WHERE `uniqueid` IN (" .. IDs ..")")
	end	
	
	function q:onSuccess(data)
		for _, row in pairs(data) do
			PS_Items[tostring(row.uniqueid)] = row.items
			
			local ply = player.GetByUniqueID(tostring(row.uniqueid))
			
			if ply then
				ply.PS_Items = PS:ValidateItems(util.JSONToTable(row.items))
				ply:PS_SendItems()
			end
		end
	end
	
	function q:onError(err, sql)
		MsgN('PointShop MySQL: Query Failed: ' .. err .. ' (' .. sql .. ')')
	end
	
	q:start()
	
	MsgN('PointShop MySQL: Synchronising Points and Items from MySQL!')
end

-- Override Player.SetPData and Player.GetPData

local Player = FindMetaTable('Player')

if not Player then
	MsgN('PointShop MySQL: Could not alter meta table, falling back to PData!')
	return
end

local oldPlayerSetPData = Player.SetPData
local oldPlayerGetPData = Player.GetPData

function Player:SetPData(key, value)
	if not shouldmysql or not key == 'PS_Points' and not key == 'PS_Items' then
		return oldPlayerSetPData(self, key, value)
	end
	
	if key == 'PS_Points' then
	    PS_Points[self:UniqueID()] = value

	    local q = db:query("INSERT INTO `pointshop_points` (uniqueid, points) VALUES ('" .. self:UniqueID() .. "', '" .. value .. "') ON DUPLICATE KEY UPDATE points = VALUES(points)")
	    q:start()
	end
		
	if key == 'PS_Items' then
	    PS_Items[self:UniqueID()] = value

	    local q = db:query("INSERT INTO `pointshop_items` (uniqueid, items) VALUES ('" .. self:UniqueID() .. "', '" .. value .. "') ON DUPLICATE KEY UPDATE items = VALUES(items)")
	    q:start()
	end

	return oldPlayerSetPData(self, key, value) -- Sets PData too as a backup!
end

function Player:GetPData(key, default)	
	if not shouldmysql or not key == 'PS_Points' and not key == 'PS_Items' then
		return oldPlayerGetPData(self, key, default)
	end
	
	if key == 'PS_Points' then
		return PS_Points[self:UniqueID()] and PS_Points[self:UniqueID()] or default
	end
	
	if key == 'PS_Items' then
		return PS_Items[self:UniqueID()] and PS_Items[self:UniqueID()] or default
	end
end

-- concommand to sync items and points to MySQL. Any existing data will be lost.

concommand.Add('ps_mysql_sync', function(ply, cmd, args)
	if not shouldmysql then -- check if MySQL is working first!
		MsgN('PointShop MySQL: MySQL is not connected, please check your settings!')
		return
	end
	
	if IsValid(ply) then return end -- only allowed from server console
	
	local data = sql.Query("SELECT * FROM playerpdata")
	
	for _, row in pairs(data) do
		local parts = string.Explode("[", row.infoid)
		local uniqueid = parts[1]
		local key = string.sub(parts[2], 0, -2)
		
		if key == 'PS_Points' then
			local q = db:query("DELETE FROM `pointshop_points` WHERE `uniqueid` = '" .. uniqueid .. "'")
			q:start()
			
			local q = db:query("INSERT INTO `pointshop_points` VALUES ('" .. uniqueid .. "', '" .. row.value .. "')")	
			q:start()
			
			PS_Points[tostring(uniqueid)] = row.value
		end
		
		if key == 'PS_Items' then
			local q = db:query("DELETE FROM `pointshop_items` WHERE `uniqueid` = '" .. uniqueid .. "'")
			q:start()
			
			local q = db:query("INSERT INTO `pointshop_items` VALUES ('" .. uniqueid .. "', '" .. row.value .. "')")	
			q:start()
			
			PS_Items[tostring(uniqueid)] = row.value
		end
	end
	
	MsgN('PointShop MySQL: Synchronised PointShop Points and Items to MySQL!')
end)
