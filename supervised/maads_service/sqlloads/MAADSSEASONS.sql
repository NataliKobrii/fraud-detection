/*M!999999\- enable the sandbox mode */ 
-- MariaDB dump 10.19  Distrib 10.11.11-MariaDB, for debian-linux-gnu (x86_64)
--
-- Host: localhost    Database: maadsbml
-- ------------------------------------------------------
-- Server version	10.11.11-MariaDB-0+deb12u1

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `MAADSSEASONS`
--

DROP TABLE IF EXISTS `MAADSSEASONS`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `MAADSSEASONS` (
  `pkey` varchar(250) DEFAULT NULL,
  `winter` varchar(50) DEFAULT NULL,
  `summer` varchar(50) DEFAULT NULL,
  `shoulder` varchar(50) DEFAULT NULL,
  `trainperc` float DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `MAADSSEASONS`
--

LOCK TABLES `MAADSSEASONS` WRITE;
/*!40000 ALTER TABLE `MAADSSEASONS` DISABLE KEYS */;
INSERT INTO `MAADSSEASONS` VALUES
('admin_aesopowerdemand_csv','11,12,1,2','6,7,8','3,4,5,9,10',0.75),
('admin_stockdata_csv','11,12,1,2','6,7,8','3,4,5,9,10',0.75),
('admin_home_price_index_clean_4_csv','11,12,1,2','6,7,8','3,4,5,9,10',0.75),
('admin_final_housing_data_v2_post_2018_csv','11,12,1,2','6,7,8','3,4,5,9,10',0.75),
('admin_maads_train_aug_csv','11,12,1,2','6,7,8','3,4,5,9,10',1),
('admin_maads_train_csv','11,12,1,2','6,7,8','3,4,5,9,10',0.8),
('admin_maads_train_aug_binary_csv','11,12,1,2','6,7,8','3,4,5,9,10',0.8);
/*!40000 ALTER TABLE `MAADSSEASONS` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-18  0:50:00
