DROP TABLE IF EXISTS `pointshop_items`;
CREATE TABLE IF NOT EXISTS `pointshop_items` (
  `uniqueid` varchar(30) NOT NULL,
  `items` text NOT NULL,
  PRIMARY KEY (`uniqueid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;

DROP TABLE IF EXISTS `pointshop_points`;
CREATE TABLE IF NOT EXISTS `pointshop_points` (
  `uniqueid` varchar(30) NOT NULL,
  `points` int(12) NOT NULL,
  PRIMARY KEY (`uniqueid`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;