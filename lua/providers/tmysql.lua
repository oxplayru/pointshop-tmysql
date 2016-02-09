--[[

    PointShop tMySQL Adapter by Spencer Sharkey and fixed by Vampir
    Should work, and has verbose output.

    Adapted from _Undefined's pointshop-mysql
    
    Once configured, change PS.Config.DataProvider = 'pdata' to PS.Config.DataProvider = 'tmysql' in pointshop's sh_config.lua.
    
]]--

-- config, change these to match your setup

local mysql_hostname = 'localhost' -- Your MySQL server address.
local mysql_username = 'root' -- Your MySQL username.
local mysql_password = '' -- Your MySQL password.
local mysql_database = 'pointshop' -- Your MySQL database.
local mysql_port = 3306 -- Your MySQL port. Most likely is 3306.

-- end config, don't change anything below unless you know what you're doing

-- end config, don't change anything below unless you know what you're doing

require('tmysql4')

PROVIDER.Fallback = "pdata"

local db, err = tmysql.initialize(mysql_hostname, mysql_username, mysql_password, mysql_database, mysql_port)

if (err) then
    print("Error connecting to MySQL:")
    ErrorNoHalt(err)
else
    function PROVIDER:GetData(ply, callback)
        local qs = string.format("SELECT * FROM `pointshop_data` WHERE uniqueid='%s'", ply:UniqueID())
        db:Query(qs, function(res)
            if (not res[1].status) then ErrorNoHalt("[PSMySQL-GetData] "..res[1].error) return end
            if (#res < 1) then callback(0, {}) return end
            
            local row = res[1].data[1]
            --print("[PSMySQL-GetData] "..ply:UniqueID())
            callback(row.points or 0, util.JSONToTable(row.items or '{}'))
        end, QUERY_FLAG_ASSOC)
    end

    function PROVIDER:SetPoints(ply, points)
        local qs = string.format("INSERT INTO `pointshop_data` (uniqueid, points, items) VALUES ('%s', '%s', '[]') ON DUPLICATE KEY UPDATE points = VALUES(points)", ply:UniqueID(), points or 0)
        db:Query(qs, function(res)
            if (not res[1].status) then ErrorNoHalt("[PSMySQL-SetPoints] "..res[1].error) return end
         --   print("[PSMySQL-SetPoints] "..ply:UniqueID().."="..points)
        end, QUERY_FLAG_ASSOC)
    end

    function PROVIDER:GivePoints(ply, points)
        local qs = string.format("INSERT INTO `pointshop_data` (uniqueid, points, items) VALUES ('%s', '%s', '[]') ON DUPLICATE KEY UPDATE points = points + VALUES(points)", ply:UniqueID(), points or 0)
        db:Query(qs, function(res)
            if (not res[1].status) then ErrorNoHalt("[PSMySQL-GivePoints] "..res[1].error) return end
          --  print("[PSMySQL-GivePoints] "..ply:UniqueID().."+="..points)
        end, QUERY_FLAG_ASSOC)
    end

    function PROVIDER:TakePoints(ply, points)
        local qs = string.format("INSERT INTO `pointshop_data` (uniqueid, points, items) VALUES ('%s', '%s', '[]') ON DUPLICATE KEY UPDATE points = points - VALUES(points)", ply:UniqueID(), points or 0)
        db:Query(qs, function(res)
            if (not res[1].status) then ErrorNoHalt("[PSMySQL-TakePoints] "..res[1].error) return end
          --  print("[PSMySQL-TakePoints] "..ply:UniqueID().."-="..points)
        end, QUERY_FLAG_ASSOC)
    end

    function PROVIDER:SaveItem(ply, item_id, data)
        self:GiveItem(ply, item_id, data)
    end

    function PROVIDER:GiveItem(ply, item_id, data)
        local tmp = table.Copy(ply.PS_Items)
        tmp[item_id] = data
        local qs = string.format("INSERT INTO `pointshop_data` (uniqueid, points, items) VALUES ('%s', '0', '%s') ON DUPLICATE KEY UPDATE items = VALUES(items)", ply:UniqueID(), db:Escape(util.TableToJSON(tmp)))
        db:Query(qs, function(res)
            if (not res[1].status) then ErrorNoHalt("[PSMySQL-GiveItem] "..res[1].error) return end
         --   print("[PSMySQL-GiveItem] "..ply:UniqueID().."="..item_id)
        end, QUERY_FLAG_ASSOC)
    end

    function PROVIDER:TakeItem(ply, item_id)
        local tmp = table.Copy(ply.PS_Items)
        tmp[item_id] = nil
        local qs = string.format("INSERT INTO `pointshop_data` (uniqueid, points, items) VALUES ('%s', '0', '%s') ON DUPLICATE KEY UPDATE items = VALUES(items)", ply:UniqueID(), db:Escape(util.TableToJSON(tmp)))
        db:Query(qs, function(res)
            if (not res[1].status) then ErrorNoHalt("[PSMySQL-TakeItem] "..res[1].error) return end
           -- print("[PSMySQL-TakeItem] "..ply:UniqueID().."="..item_id)
        end, QUERY_FLAG_ASSOC)
    end

    function PROVIDER:SetData(ply, points, items)
        local qs = string.format("INSERT INTO `pointshop_data` (uniqueid, points, items) VALUES ('%s', '%s', '%s') ON DUPLICATE KEY UPDATE points = VALUES(points), items = VALUES(items)", ply:UniqueID(), points or 0, db:Escape(util.TableToJSON(items)))

        db:Query(qs, function(res)
            if (not res[1].status) then ErrorNoHalt("[PSMySQL-SetData] "..res[1].status) return end
           -- print("[PSMySQL-SetData] "..ply:UniqueID())
        end, QUERY_FLAG_ASSOC)
    end
end