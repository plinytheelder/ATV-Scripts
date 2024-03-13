CREATE TABLE IF NOT EXISTS `ATVstats` (
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `RPL` smallint(6) NOT NULL,
  `deviceName` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `temperature` int(11) DEFAULT NULL,
  `reboot` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`deviceName`,`timestamp`,`RPL`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `ATVsummary` (
  `timestamp` datetime NOT NULL,
  `deviceName` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `arch` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `productmodel` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `voltorbversion` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `pogo` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mitmversion` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `temperature` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `magisk` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `MACe` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ip` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `hostname` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `playstore` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `proxyinfo` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `token` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `workers` varchar(40) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rotomUrl` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rotomsecret` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`deviceName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
