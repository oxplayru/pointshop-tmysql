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
		
		If you're upgrading from the old version, run the following SQL before starting your server and then remove the old tables (pointshop_points and pointshop_items):
		
			INSERT INTO `pointshop_data` SELECT `pointshop_points`.`uniqueid`, `points`, `items` FROM `pointshop_points` INNER JOIN `pointshop_items` ON `pointshop_items`.`uniqueid` = `pointshop_points`.`uniqueid`
		
		Once configured, change PS.Config.DataProvider = 'pdata' to PS.Config.DataProvider = 'mysql' in pointshop's sh_config.lua.
	
]]--

-- config, change these to match your setup

local mysql_hostname = 'localhost' -- Your MySQL server address.
local mysql_username = 'root' -- Your MySQL username.
local mysql_password = '' -- Your MySQL password.
local mysql_database = 'pointshop' -- Your MySQL database.
local mysql_port = 3306 -- Your MySQL port. Most likely is 3306.

-- end config, don't change anything below unless you know what you're doing

require('mysqloo')

local shouldmysql = false

local db = mysqloo.connect(mysql_hostname, mysql_username, mysql_password, mysql_database, mysql_port)

function db:onConnected()
	MsgN('PointShop MySQL: Connected!')
	shouldmysql = true
end

function db:onConnectionFailed(err)
	MsgN('PointShop MySQL: Connection Failed, please check your settings: ' .. err)
end

db:connect()

PROVIDER.Fallback = 'pdata'

function PROVIDER:GetData(ply, callback)
	if not shouldmysql then self:GetFallback():GetData(ply, callback) end
	
	local q = db:query("SELECT * FROM `pointshop_data` WHERE uniqueid = '" .. ply:UniqueID() .. "'")
	
	function q:onSuccess(data)
		if #data > 0 then
			local row = data[1]
		
			local points = row.points or 0
			local items = util.JSONToTable(row.items or '{}')
		
			callback(points, items)
		else
			callback(0, {})
		end
	end
	
	function q:onError(err, sql)
		MsgN('PointShop MySQL: Query Failed: ' .. err .. ' (' .. sql .. ')')
		callback(0, {})
	end
	
	q:start()
end

function PROVIDER:SetData(ply, points, items)
	if not shouldmysql then self:GetFallback():SetData(ply, points, items) end
	
	local q = db:query("INSERT INTO `pointshop_data` (uniqueid, points, items) VALUES ('" .. ply:UniqueID() .. "', '" .. (points or 0) .. "', '" .. util.TableToJSON(items or {}) .. "') ON DUPLICATE KEY UPDATE points = VALUES(points), items = VALUES(items)")
	
	function q:onError(err, sql)
		MsgN('PointShop MySQL: Query Failed: ' .. err .. ' (' .. sql .. ')')
	end
	
	q:start()
end