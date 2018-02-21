CREATE TABLE `images` (
	  `id` int(11) NOT NULL AUTO_INCREMENT,
	  `img_name` varchar(255) COLLATE utf8_unicode_ci NOT NULL,
	  `img_order` int(5) NOT NULL DEFAULT '0',
	  `created` datetime NOT NULL,
	  `modified` datetime NOT NULL,
	  `status` enum('1','0') COLLATE utf8_unicode_ci NOT NULL DEFAULT '1',
	  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
