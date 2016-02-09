pointshop-tmysql
================

MySQL adapter for PointShop that uses [tmysql4](https://github.com/blackawps/gm_tmysql4/releases) by Blackawps.

Install this folder as a separate addon. (Place entire `pointshop-tmysql` folder in `garrysmod/addons`)

MySQL providers for pointshop are useful if you want to share data across multiple servers, or store it for access from different applications such as a website or donation system.

tMySQL4 Installation
================

Get tmysql4 from [Blackawps's Google Code](https://github.com/blackawps/gm_tmysql4/releases)
It's Windows AND Linux compatible!

You must also place either gm_tmysql4_win32.dll or gmsv_tmysql4_linux.dll in your `garrysmod/lua/bin` folder depending on your server's operating system. Obviously, `win32` for Windows and `linux` for linux operating systems.

Windows server users might also need to isntall the [Microsoft Visual C++ 2008 Redistributable Package](http://www.microsoft.com/en-us/download/details.aspx?id=29) for the module to operate properly. If you do not have it installed, the server will crash on startup. It package contains libraries tMySQL requires during runtime and will install them automatically for you.

Configuration
================
1. Execute the `pointshop.sql` on the database you are configuring for use with Pointshop. PhpMyAdmin or any other MySQL client application usually have an import feature.
2. Navigate to `lua/providers/tymsql.lua` within the addon folder and modify the MySQL connection information at the top of the file.
3. Edit Pointshop's `sh_config.lua`... Change `PS.Config.DataProvider = 'pdata'` to `PS.Config.DataProvider = 'tmysql'`

The MySQL server you are using must allow remote connections with the user provided. If you are using a web service like cPanel to manage your database, [here](http://www.liquidweb.com/kb/enable-remote-mysql-connections-in-cpanel/) is a helpful tutorial. If you're using a standalone MySQL server installation on a seperate server, [here](http://www.cyberciti.biz/tips/how-do-i-enable-remote-access-to-mysql-database-server.html) is tutorial that will help you. 

Some game server providers provide MySQL databases with servers, talk to your support agents to get info on how to set them up if you do not already know how.

Credits
================
Adaptation by Spencer Sharkey (spencer@sf-n.com)

Adapted from adamdburton/pointshop-mysql
