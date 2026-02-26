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
-- Table structure for table `OTICSSTAGINGTABLES`
--

DROP TABLE IF EXISTS `OTICSSTAGINGTABLES`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8mb4 */;
CREATE TABLE `OTICSSTAGINGTABLES` (
  `company` varchar(150) DEFAULT NULL,
  `username` varchar(50) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `sessionid` varchar(150) DEFAULT NULL,
  `tablename` varchar(550) DEFAULT NULL,
  `fieldnames` varchar(7999) DEFAULT NULL,
  `numrows` int(11) DEFAULT NULL,
  `numcols` int(11) DEFAULT NULL,
  `autofeature` int(11) DEFAULT NULL,
  `testtable` varchar(550) DEFAULT NULL,
  `datetime` varchar(50) DEFAULT NULL,
  `active` int(11) DEFAULT NULL,
  `istrained` int(11) DEFAULT NULL,
  `depvar` varchar(550) DEFAULT NULL,
  `pipelinekey` varchar(550) DEFAULT NULL,
  `tempfilename` varchar(550) DEFAULT NULL,
  `cleantable` varchar(550) DEFAULT NULL,
  `season` int(11) DEFAULT NULL,
  `outliersremove` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb3 COLLATE=utf8mb3_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `OTICSSTAGINGTABLES`
--

LOCK TABLES `OTICSSTAGINGTABLES` WRITE;
/*!40000 ALTER TABLE `OTICSSTAGINGTABLES` DISABLE KEYS */;
INSERT INTO `OTICSSTAGINGTABLES` VALUES
('Otics','admin','support@otics.ca','5oappghpmdq7qvo7tedn05gu9k','admin_aesopowerdemand_csv','Date,AESO_Power_Demand,Calgary_Weather,Edmonton_Weather,FtMac_Weather',1280,5,0,'admin_aesopowerdemand_csvTEST','20250606_0016',1,1,'AESO_Power_Demand','admin_aesopowerdemand_csv','/maads/agentfilesdocker/dist/csvuploads/admin_aesopowerdemand_csv_.csv','admin_aesopowerdemand_csvCleaned',0,0),
('Otics','admin','support@otics.ca','7563qv7663e1fl1a89devfkr3c','admin_stockdata_csv','Date,Open,High,Low,Close,Volume',1260,6,0,'admin_stockdata_csvTEST','20250606_0033',1,1,'close','admin_stockdata_csv','/maads/agentfilesdocker/dist/csvuploads/admin_stockdata_csv_.csv','admin_stockdata_csvCleaned',0,0),
('Otics','admin','support@otics.ca','kl80i8omaa7vgd10fqvh88jk5k','admin_home_price_index_clean_4_csv','Date,Location,CompIndex,CompBenchmark,CompYoYChange,SFDetachIndex,SFDetachBenchmark,SFDetachYoYChange,SFAttachIndex,SFAttachBenchmark,SFAttachYoYChange,THouseIndex,THouseBenchmark,THouseYoYChange,ApartIndex,ApartBenchmark,ApartYoYChange',3652,17,0,'admin_home_price_index_clean_4_csvTEST','20250715_2202',1,1,'ApartYoYChange','admin_home_price_index_clean_4_csv','/maads/agentfilesdocker/dist/csvuploads/admin_home_price_index_clean_4_csv_.csv','admin_home_price_index_clean_4_csvCleaned',0,0),
('Otics','admin','support@otics.ca','v2mpnhfmkksp003vuapi5bvsk0','admin_final_housing_data_v2_post_2018_csv','Date,Location,Price,Mortgage_Rate_Percent,GDP,Single_Starts,Semi_Detached_Starts,Row_Starts,Apartment_Starts,All_Starts,CPI_Ontario,Immigrants,Population_Ontario,Unemployment_Rate_Percent',2817,14,0,'admin_final_housing_data_v2_post_2018_csvTEST','20250722_2017',1,1,'GDP','admin_final_housing_data_v2_post_2018_csv','/maads/agentfilesdocker/dist/csvuploads/admin_final_housing_data_v2_post_2018_csv_.csv','admin_final_housing_data_v2_post_2018_csvCleaned',0,0),
('ARIMLABS','admin','nkobrii@arimlabs.ai','91ecqc3btrp1ibqjjla09tkqjb','admin_maads_train_aug_csv','Date,transactionamount,customerage,transactionduration,loginattempts,accountbalance,txn_hour,is_night,is_weekend,mcc,high_risk_mcc,medium_risk_mcc,new_country,new_device,new_ip,customer_tenure_days,short_tenure,high_amount,unusual_mcc_for_customer,txn_velocity_5min_sim,high_frequency,freq_2plus,proxy,severity_label,transactiontype_Credit,transactiontype_Debit,transactiontype_nan,channel_ATM,channel_Branch,channel_Online,channel_nan,customeroccupation_Doctor,customeroccupation_Engineer,customeroccupation_Retired,customeroccupation_Student,customeroccupation_nan,mcc_risk_high,mcc_risk_low,mcc_risk_medium,mcc_risk_nan,country_BR,country_CA,country_DE,country_FR,country_GB,country_IN,country_MX,country_PL,country_SG,country_UA,country_US,country_nan',1940,52,0,'admin_maads_train_aug_csvTEST','20260204_2216',1,1,'severity_label','admin_maads_train_aug_csv','/maads/agentfilesdocker/dist/csvuploads/admin_maads_train_aug_csv_.csv','admin_maads_train_aug_csvCleaned',0,0),
('ARIMLABS','admin','nkobrii@arimlabs.ai','foer27avuuafhtbednmu4fos0i','admin_maads_train_csv','Date,transactionamount,customerage,transactionduration,loginattempts,accountbalance,txn_hour,is_night,is_weekend,mcc,new_device,new_ip,customer_tenure_days,txn_velocity_5min_sim,transactiontype_Credit,transactiontype_Debit,transactiontype_nan,channel_ATM,channel_Branch,channel_Online,channel_nan,customeroccupation_Doctor,customeroccupation_Engineer,customeroccupation_Retired,customeroccupation_Student,customeroccupation_nan,country_BR,country_CA,country_DE,country_FR,country_GB,country_IN,country_MX,country_PL,country_SG,country_UA,country_US,country_nan,label',1940,39,0,'admin_maads_train_csvTEST','20260205_0201',1,1,'label','admin_maads_train_csv','/maads/agentfilesdocker/dist/csvuploads/admin_maads_train_csv_.csv','admin_maads_train_csvCleaned',0,0),
('ARIMLABS','admin','nkobrii@arimlabs.ai','43qv4nt1ikvrhd2qeb7rs84hgr','admin_maads_train_aug_binary_csv','Date,customerage,transactionduration,loginattempts,txn_hour,is_night,is_weekend,mcc,high_risk_mcc,medium_risk_mcc,new_device,new_ip,customer_tenure_days,short_tenure,unusual_mcc_for_customer,txn_velocity_5min_sim,high_frequency,freq_2plus,proxy,transactiontype_Credit,transactiontype_Debit,transactiontype_nan,channel_Branch,channel_Online,channel_nan,customeroccupation_Doctor,customeroccupation_Engineer,customeroccupation_Retired,customeroccupation_Student,customeroccupation_nan,mcc_risk_low,mcc_risk_medium,mcc_risk_nan,country_BR,country_CA,country_DE,country_FR,country_GB,country_IN,country_MX,country_PL,country_SG,country_UA,country_US,country_nan,label',1940,46,0,'admin_maads_train_aug_binary_csvTEST','20260213_1531',1,1,'label','admin_maads_train_aug_binary_csv','/maads/agentfilesdocker/dist/csvuploads/admin_maads_train_aug_binary_csv_.csv','admin_maads_train_aug_binary_csvCleaned',0,0);
/*!40000 ALTER TABLE `OTICSSTAGINGTABLES` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-02-17 21:35:00
