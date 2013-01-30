DROP TABLE IF EXISTS `pointshop_data`;
CREATE TABLE `pointshop_data` (
 `uniqueid` varchar(30) NOT NULL,
 `points` int(32) NOT NULL,
 `items` text NOT NULL,
 PRIMARY KEY (`uniqueid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1