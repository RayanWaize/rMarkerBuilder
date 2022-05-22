CREATE TABLE `markerbuilder` (
  `id` int(11) NOT NULL,
  `coordsenter` varchar(255) NOT NULL,
  `coordsexit` varchar(255) NOT NULL,
  `textenter` varchar(50) NOT NULL,
  `textexit` varchar(50) NOT NULL,
  `vehenter` tinyint(1) NOT NULL DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE `markerbuilder`
  ADD PRIMARY KEY (`id`);


ALTER TABLE `markerbuilder`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;
COMMIT;