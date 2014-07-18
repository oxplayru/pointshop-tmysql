pointshop-tmysql
================

MySQL adapter for PointShop that uses [tmysql4](https://code.google.com/p/blackawps-glua-modules/source/browse/#hg%2Fgm_tmysql4_boost%2FRelease) by Blackawps.

Install this folder as a separate addon. (Place entire `pointshop-tmysql` in `garrysmod/addons`)

tmysql4
================

Get tmysql4 from [Blackawps's Google Code](https://code.google.com/p/blackawps-glua-modules/source/browse/#hg%2Fgm_tmysql4_boost%2FRelease)
It's Windows AND Linux compatible! Make sure you install the correct libraries.

Configuration
================
1. Execute the `pointshop.sql` on the database you are configuring for use with Pointshop
2. Navigate to `lua/providers/tymsql.lua` and modify the MySQL connection information.
3. Edit Pointshop's `sh_config.lua`... Change `PS.Config.DataProvider = 'pdata'` to `PS.Config.DataProvider = 'tmysql'`

Credits
================
Adaptation by Spencer Sharkey (spencer@sf-n.com)

Adapted from adamdburton/pointshop-mysql
