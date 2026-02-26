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
-- Table structure for table `OPTIMALALGOS`
--

DROP TABLE IF EXISTS `OPTIMALALGOS`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `OPTIMALALGOS` (
  `DATE` varchar(50) DEFAULT NULL,
  `PKEY` varchar(300) DEFAULT NULL,
  `ALGO` varchar(300) DEFAULT NULL,
  `ACCURACY` float DEFAULT NULL,
  `filenamereg` varchar(300) DEFAULT NULL,
  `filename2` varchar(300) DEFAULT NULL,
  `filename3` varchar(300) DEFAULT NULL,
  `filename4` varchar(300) DEFAULT NULL,
  `samplestr` varchar(300) DEFAULT NULL,
  `agentid` int(11) DEFAULT NULL,
  `producttype` varchar(250) DEFAULT NULL,
  `sample` float DEFAULT NULL,
  `numinputs` int(11) DEFAULT NULL,
  `predtype` varchar(250) DEFAULT NULL,
  `lowinterval` float DEFAULT NULL,
  `highinterval` float DEFAULT NULL,
  `season` varchar(50) DEFAULT NULL,
  `agentname` varchar(300) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `OPTIMALALGOS`
--

LOCK TABLES `OPTIMALALGOS` WRITE;
/*!40000 ALTER TABLE `OPTIMALALGOS` DISABLE KEYS */;
INSERT INTO `OPTIMALALGOS` VALUES
('2025-06-06','admin_aesopowerdemand_csv','NuSVR',0.63868,'./networks/Fiera Capital_ADMIN_AESOPOWERDEMAND_CSVALLSEASON_AG1_4_NuSVR_normal_961_ensemble_.pkl','./networks/Fiera Capital_ADMIN_AESOPOWERDEMAND_CSVALLSEASON_AG1_4_NuSVR_normal_961_ensemble_scalerx_.pkl','./networks/Fiera Capital_ADMIN_AESOPOWERDEMAND_CSVALLSEASON_AG1_4_NuSVR_normal_961_ensemble_scalery_.pkl','','s_961_',4,'ADMIN_AESOPOWERDEMAND_CSVALLSEASON_AG1_NuSVR_4_961_',961,3,'normal',-1,-1,'allseason','ADMIN_AESOPOWERDEMAND_CSVALLSEASON_AG1'),
('2025-06-06','admin_stockdata_csv','RidgeRegression',0.996,'./networks/Fiera Capital_ADMIN_STOCKDATA_CSVALLSEASON_AG1_4_RidgeRegression_normal_1.00000000_946_.pkl','./networks/Fiera Capital_ADMIN_STOCKDATA_CSVALLSEASON_AG1_4_RidgeRegression_normal_1.00000000_946_scalerx_.pkl','./networks/Fiera Capital_ADMIN_STOCKDATA_CSVALLSEASON_AG1_4_RidgeRegression_normal_1.00000000_946_scalery_.pkl','','s_946_',4,'ADMIN_STOCKDATA_CSVALLSEASON_AG1_RidgeRegression_10_1.00000000_',946,4,'normal',-1,-1,'allseason','ADMIN_STOCKDATA_CSVALLSEASON_AG1'),
('2025-07-15','admin_home_price_index_clean_4_csv','GradientBoostingRegressor',0.67372,'./networks/Otics_ADMIN_HOME_PRICE_INDEX_CLEAN_4_CSVALLSEASON_AG1_4_GradientBoostingRegressor_normal_2740_0.100_300_3_ensemble_.pkl','./networks/Otics_ADMIN_HOME_PRICE_INDEX_CLEAN_4_CSVALLSEASON_AG1_4_GradientBoostingRegressor_normal_2740_0.100_300_3_ensemble_scalerx_.pkl','./networks/Otics_ADMIN_HOME_PRICE_INDEX_CLEAN_4_CSVALLSEASON_AG1_4_GradientBoostingRegressor_normal_2740_0.100_300_3_ensemble_scalery_.pkl','','s_2740_',4,'ADMIN_HOME_PRICE_INDEX_CLEAN_4_CSVALLSEASON_AG1_GradientBoostingRegressor_4_2740_0.100_300_3_',2740,15,'normal',-1,-1,'allseason','ADMIN_HOME_PRICE_INDEX_CLEAN_4_CSVALLSEASON_AG1'),
('2025-07-22','admin_final_housing_data_v2_post_2018_csv','GradientBoostingRegressor',1,'./networks/Otics_ADMIN_FINAL_HOUSING_DATA_V2_POST_2018_CSVALLSEASON_AG1_4_GradientBoostingRegressor_normal_2114_0.100_300_3_ensemble_.pkl','./networks/Otics_ADMIN_FINAL_HOUSING_DATA_V2_POST_2018_CSVALLSEASON_AG1_4_GradientBoostingRegressor_normal_2114_0.100_300_3_ensemble_scalerx_.pkl','./networks/Otics_ADMIN_FINAL_HOUSING_DATA_V2_POST_2018_CSVALLSEASON_AG1_4_GradientBoostingRegressor_normal_2114_0.100_300_3_ensemble_scalery_.pkl','','s_2114_',4,'ADMIN_FINAL_HOUSING_DATA_V2_POST_2018_CSVALLSEASON_AG1_GradientBoostingRegressor_4_2114_0.100_300_3_',2114,12,'normal',-1,-1,'allseason','ADMIN_FINAL_HOUSING_DATA_V2_POST_2018_CSVALLSEASON_AG1'),
('2026-02-05','admin_maads_train_csv','LogisticRegression',0.88,'./networks/Otics_ADMIN_MAADS_TRAIN_CSVALLSEASON_AG1_4_LogisticRegression_normal_1553_ensembleone_.pkl','./networks/Otics_ADMIN_MAADS_TRAIN_CSVALLSEASON_AG1_4_LogisticRegression_normal_1553_ensembleone_scalerx_.pkl','','','s_1553_',4,'ADMIN_MAADS_TRAIN_CSVALLSEASON_AG1_LogisticRegression_4_1553_',1553,37,'normal',-1,-1,'allseason','ADMIN_MAADS_TRAIN_CSVALLSEASON_AG1'),
('2026-02-13','admin_maads_train_aug_binary_csv','LogisticRegression',0.941,'./networks/Otics_ADMIN_MAADS_TRAIN_AUG_BINARY_CSVALLSEASON_AG1_4_LogisticRegression_normal_1553_ensembleone_.pkl','./networks/Otics_ADMIN_MAADS_TRAIN_AUG_BINARY_CSVALLSEASON_AG1_4_LogisticRegression_normal_1553_ensembleone_scalerx_.pkl','','','s_1553_',4,'ADMIN_MAADS_TRAIN_AUG_BINARY_CSVALLSEASON_AG1_LogisticRegression_4_1553_',1553,44,'normal',-1,-1,'allseason','ADMIN_MAADS_TRAIN_AUG_BINARY_CSVALLSEASON_AG1');
/*!40000 ALTER TABLE `OPTIMALALGOS` ENABLE KEYS */;
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
