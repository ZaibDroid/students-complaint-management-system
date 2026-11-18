-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: dcms_db
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

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
-- Table structure for table `application_attachments`
--

DROP TABLE IF EXISTS `application_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application_attachments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `application_id` bigint(20) unsigned NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_type` varchar(100) DEFAULT NULL,
  `file_size` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `application_attachments_application_id_index` (`application_id`),
  CONSTRAINT `application_attachments_application_id_foreign` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application_attachments`
--

LOCK TABLES `application_attachments` WRITE;
/*!40000 ALTER TABLE `application_attachments` DISABLE KEYS */;
INSERT INTO `application_attachments` VALUES (2,11,'scaled_1000319027.jpg','Applications/11/cT0ZeSfCubsDZuTC5B5tsPVqBl4gYi4hvSIVRkcA.jpg','application/octet-stream',74159,'2026-11-15 19:03:09','2026-11-15 19:03:09'),(3,12,'scaled_1000319223.jpg','Applications/12/8dBX9yRqnBZ4IjqTQfGZg8bVOGKS8Iu5OCs3TNDq.jpg','application/octet-stream',174554,'2026-11-15 19:08:20','2026-11-15 19:08:20'),(4,13,'scaled_1000319654.jpg','Applications/13/fwVUD8K0hYltVT1IQI39Pgeur9jLvftjGOpb9Gf0.jpg','application/octet-stream',219976,'2026-11-15 19:19:21','2026-11-15 19:19:21');
/*!40000 ALTER TABLE `application_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `application_categories`
--

DROP TABLE IF EXISTS `application_categories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application_categories` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `slug` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `application_categories_name_unique` (`name`),
  UNIQUE KEY `application_categories_slug_unique` (`slug`),
  KEY `application_categories_is_active_index` (`is_active`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application_categories`
--

LOCK TABLES `application_categories` WRITE;
/*!40000 ALTER TABLE `application_categories` DISABLE KEYS */;
INSERT INTO `application_categories` VALUES (1,'Academic','academic','Issues related to academics, courses, and faculty.',1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL),(2,'Infrastructure','infrastructure','Issues related to facilities, labs, and classrooms.',1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL),(3,'Exam','exam','Issues related to examinations and grading.',1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL),(4,'General','general','General inquiries and non-specific issues.',1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL);
/*!40000 ALTER TABLE `application_categories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `application_remarks`
--

DROP TABLE IF EXISTS `application_remarks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application_remarks` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `application_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `remark` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `application_remarks_application_id_foreign` (`application_id`),
  KEY `application_remarks_user_id_foreign` (`user_id`),
  CONSTRAINT `application_remarks_application_id_foreign` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  CONSTRAINT `application_remarks_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application_remarks`
--

LOCK TABLES `application_remarks` WRITE;
/*!40000 ALTER TABLE `application_remarks` DISABLE KEYS */;
INSERT INTO `application_remarks` VALUES (5,12,15,'the is not refundable according to the prospecus','2026-11-15 19:20:36','2026-11-15 19:20:36'),(6,13,15,'we resolve this as son as possible','2026-11-15 19:21:08','2026-11-15 19:21:08'),(7,11,15,'please process this application','2026-11-15 20:15:15','2026-11-15 20:15:15'),(8,11,4,'the chairman sb not allowing','2026-11-16 13:00:54','2026-11-16 13:00:54'),(9,11,15,'can you send to the chairman again','2026-11-16 13:14:53','2026-11-16 13:14:53'),(10,11,4,'if possible please allow this sir','2026-11-16 13:16:33','2026-11-16 13:16:33');
/*!40000 ALTER TABLE `application_remarks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `application_timeline`
--

DROP TABLE IF EXISTS `application_timeline`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `application_timeline` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `application_id` bigint(20) unsigned NOT NULL,
  `from_user_id` bigint(20) unsigned DEFAULT NULL,
  `to_user_id` bigint(20) unsigned DEFAULT NULL,
  `from_role` varchar(255) DEFAULT NULL,
  `to_role` varchar(255) DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `application_timeline_application_id_foreign` (`application_id`),
  KEY `application_timeline_from_user_id_foreign` (`from_user_id`),
  KEY `application_timeline_to_user_id_foreign` (`to_user_id`),
  CONSTRAINT `application_timeline_application_id_foreign` FOREIGN KEY (`application_id`) REFERENCES `applications` (`id`) ON DELETE CASCADE,
  CONSTRAINT `application_timeline_from_user_id_foreign` FOREIGN KEY (`from_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `application_timeline_to_user_id_foreign` FOREIGN KEY (`to_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `application_timeline`
--

LOCK TABLES `application_timeline` WRITE;
/*!40000 ALTER TABLE `application_timeline` DISABLE KEYS */;
INSERT INTO `application_timeline` VALUES (5,11,16,15,'Student','Batch Adviser','Submitted','Application submitted by student','2026-11-15 20:22:29','2026-11-15 20:22:29'),(6,12,16,15,'Student','Batch Adviser','Submitted','Application submitted by student','2026-11-15 20:22:29','2026-11-15 20:22:29'),(7,13,16,15,'Student','Batch Adviser','Submitted','Application submitted by student','2026-11-15 20:22:29','2026-11-15 20:22:29'),(8,12,15,NULL,'Batch Adviser',NULL,'Rejected','the is not refundable according to the prospecus','2026-11-15 20:22:29','2026-11-15 20:22:29'),(9,13,15,NULL,'Batch Adviser',NULL,'Resolved','we resolve this as son as possible','2026-11-15 20:22:29','2026-11-15 20:22:29'),(10,11,15,4,'Batch Adviser','Coordinator','Forwarded','please process this application','2026-11-15 20:22:29','2026-11-15 20:22:29'),(11,11,4,15,'Coordinator','Batch Adviser','Forwarded','the chairman sb not allowing','2026-11-16 13:00:56','2026-11-16 13:00:56'),(12,11,15,4,'Batch Adviser','Coordinator','Forwarded','can you send to the chairman again','2026-11-16 13:14:53','2026-11-16 13:14:53'),(13,11,4,3,'Coordinator','Chairman','Forwarded','if possible please allow this sir','2026-11-16 13:16:33','2026-11-16 13:16:33');
/*!40000 ALTER TABLE `application_timeline` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `applications`
--

DROP TABLE IF EXISTS `applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `applications` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `ticket_number` varchar(255) NOT NULL,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `student_id` bigint(20) unsigned NOT NULL,
  `assigned_to_id` bigint(20) unsigned DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `category_id` bigint(20) unsigned DEFAULT NULL,
  `status` enum('pending','forwarded','resolved','rejected','returned') NOT NULL DEFAULT 'pending',
  `priority` enum('low','medium','high','urgent') NOT NULL DEFAULT 'medium',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `applications_ticket_number_unique` (`ticket_number`),
  KEY `applications_student_id_status_index` (`student_id`,`status`),
  KEY `applications_assigned_to_id_status_index` (`assigned_to_id`,`status`),
  KEY `applications_priority_status_index` (`priority`,`status`),
  KEY `applications_created_at_index` (`created_at`),
  KEY `applications_deleted_at_index` (`deleted_at`),
  KEY `applications_category_id_status_index` (`category_id`,`status`),
  KEY `app_dept_status_created_idx` (`department_id`,`status`,`created_at`),
  CONSTRAINT `applications_assigned_to_id_foreign` FOREIGN KEY (`assigned_to_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `applications_category_id_foreign` FOREIGN KEY (`category_id`) REFERENCES `application_categories` (`id`),
  CONSTRAINT `applications_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`),
  CONSTRAINT `applications_student_id_foreign` FOREIGN KEY (`student_id`) REFERENCES `users` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `applications`
--

LOCK TABLES `applications` WRITE;
/*!40000 ALTER TABLE `applications` DISABLE KEYS */;
INSERT INTO `applications` VALUES (11,'DCMS-2026-0010',1,16,3,'Aloww the FYP lab on weekends','we want to work on the department PCs for the FYP during the weekend',1,'forwarded','medium','2026-11-15 19:03:09','2026-11-16 13:16:33',NULL),(12,'DCMS-2026-0011',1,16,15,'Refund the rechecking fee','I want to withdraw the complaint about the rechecking issue',1,'rejected','medium','2026-11-15 19:08:20','2026-11-15 19:20:36',NULL),(13,'DCMS-2026-0012',1,16,15,'The wifi is not working well in the Ai/Da lab','please resolve this issue',1,'resolved','medium','2026-11-15 19:19:21','2026-11-15 19:21:08',NULL);
/*!40000 ALTER TABLE `applications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `audit_logs`
--

DROP TABLE IF EXISTS `audit_logs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `audit_logs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `action` varchar(255) NOT NULL,
  `model_type` varchar(255) DEFAULT NULL,
  `model_id` bigint(20) unsigned DEFAULT NULL,
  `old_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`old_values`)),
  `new_values` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT NULL CHECK (json_valid(`new_values`)),
  `ip` varchar(45) DEFAULT NULL,
  `user_agent` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `audit_logs_user_id_foreign` (`user_id`),
  KEY `audit_logs_model_type_model_id_index` (`model_type`,`model_id`),
  CONSTRAINT `audit_logs_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=82 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `audit_logs`
--

LOCK TABLES `audit_logs` WRITE;
/*!40000 ALTER TABLE `audit_logs` DISABLE KEYS */;
INSERT INTO `audit_logs` VALUES (1,7,'UserLoggedIn','App\\Models\\User',7,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 15:55:16'),(2,7,'UserLoggedIn','App\\Models\\User',7,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 15:55:42'),(3,1,'UserLoggedIn','App\\Models\\User',1,NULL,NULL,'127.0.0.1','curl/8.13.0','2026-11-13 16:45:09'),(4,1,'UserLoggedIn','App\\Models\\User',1,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 16:46:36'),(5,3,'UserLoggedIn','App\\Models\\User',3,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 16:48:48'),(6,3,'UserLoggedIn','App\\Models\\User',3,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 17:01:11'),(7,3,'UserLoggedIn','App\\Models\\User',3,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 17:11:21'),(8,4,'UserLoggedIn','App\\Models\\User',4,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 17:11:47'),(9,4,'UserLoggedIn','App\\Models\\User',4,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 17:27:00'),(10,3,'UserLoggedIn','App\\Models\\User',3,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 17:27:52'),(11,4,'UserLoggedIn','App\\Models\\User',4,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 17:29:08'),(12,4,'UserLoggedIn','App\\Models\\User',4,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 17:52:22'),(13,7,'UserLoggedIn','App\\Models\\User',7,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 18:07:05'),(14,NULL,'UserLoggedIn','App\\Models\\User',8,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 18:11:14'),(15,7,'UserLoggedIn','App\\Models\\User',7,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-13 18:12:45'),(16,NULL,'UserLoggedIn','App\\Models\\User',8,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 16:11:35'),(17,NULL,'ApplicationSubmitted','App\\Models\\Application',3,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 16:40:18'),(18,NULL,'ApplicationSubmitted','App\\Models\\Application',4,NULL,NULL,'127.0.0.1','Symfony','2026-11-15 16:58:43'),(19,NULL,'UserLoggedIn','App\\Models\\User',8,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 17:11:53'),(20,NULL,'UserLoggedIn','App\\Models\\User',8,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 17:20:16'),(21,7,'UserLoggedIn','App\\Models\\User',7,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 17:28:55'),(22,NULL,'UserLoggedIn','App\\Models\\User',8,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 17:30:45'),(23,7,'UserLoggedIn','App\\Models\\User',7,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 17:44:51'),(24,7,'UserLoggedIn','App\\Models\\User',7,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 17:45:22'),(25,NULL,'UserLoggedIn','App\\Models\\User',8,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 17:46:35'),(26,7,'UserLoggedIn','App\\Models\\User',7,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 17:46:54'),(27,4,'UserLoggedIn','App\\Models\\User',4,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 17:54:16'),(28,7,'UserLoggedIn','App\\Models\\User',7,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 17:56:35'),(29,NULL,'ApplicationSubmitted','App\\Models\\Application',5,NULL,NULL,'127.0.0.1','Symfony','2026-11-15 18:06:17'),(30,NULL,'UserLoggedIn','App\\Models\\User',8,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:08:00'),(31,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:08:26'),(32,NULL,'ApplicationSubmitted','App\\Models\\Application',6,NULL,NULL,'127.0.0.1','Symfony','2026-11-15 18:19:27'),(33,NULL,'ApplicationSubmitted','App\\Models\\Application',7,NULL,NULL,'127.0.0.1','Symfony','2026-11-15 18:20:16'),(34,NULL,'ApplicationSubmitted','App\\Models\\Application',8,NULL,NULL,'127.0.0.1','Symfony','2026-11-15 18:20:37'),(35,NULL,'ApplicationSubmitted','App\\Models\\Application',9,NULL,NULL,'127.0.0.1','Symfony','2026-11-15 18:20:58'),(36,NULL,'ApplicationSubmitted','App\\Models\\Application',10,NULL,NULL,'127.0.0.1','Symfony','2026-11-15 18:21:13'),(37,NULL,'ApplicationResolved','App\\Models\\Application',10,NULL,NULL,'127.0.0.1','Symfony','2026-11-15 18:21:13'),(38,NULL,'UserLoggedIn','App\\Models\\User',8,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:28:14'),(39,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:28:30'),(40,NULL,'UserLoggedIn','App\\Models\\User',8,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:29:05'),(41,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:29:21'),(42,15,'ApplicationRejected','App\\Models\\Application',9,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:30:16'),(43,15,'ApplicationResolved','App\\Models\\Application',7,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:30:36'),(44,NULL,'UserLoggedIn','App\\Models\\User',8,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:34:44'),(45,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:35:04'),(46,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:35:51'),(47,NULL,'UserLoggedIn','App\\Models\\User',8,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:36:10'),(48,16,'UserLoggedIn','App\\Models\\User',16,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 18:55:55'),(49,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:00:01'),(50,16,'UserLoggedIn','App\\Models\\User',16,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:00:25'),(51,16,'ApplicationSubmitted','App\\Models\\Application',11,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:03:09'),(52,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:03:39'),(53,16,'UserLoggedIn','App\\Models\\User',16,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:05:17'),(54,16,'ApplicationSubmitted','App\\Models\\Application',12,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:08:20'),(55,16,'UserLoggedIn','App\\Models\\User',16,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:14:53'),(56,16,'UserLoggedIn','App\\Models\\User',16,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:17:02'),(57,16,'UserLoggedIn','App\\Models\\User',16,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:18:23'),(58,16,'ApplicationSubmitted','App\\Models\\Application',13,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:19:21'),(59,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:19:45'),(60,15,'ApplicationRejected','App\\Models\\Application',12,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:20:36'),(61,15,'ApplicationResolved','App\\Models\\Application',13,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:21:08'),(62,16,'UserLoggedIn','App\\Models\\User',16,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:29:17'),(63,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 19:42:52'),(64,16,'UserLoggedIn','App\\Models\\User',16,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 20:00:31'),(65,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 20:01:11'),(66,15,'ApplicationForwarded','App\\Models\\Application',11,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 20:15:17'),(67,4,'UserLoggedIn','App\\Models\\User',4,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 20:16:38'),(68,16,'UserLoggedIn','App\\Models\\User',16,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 20:17:04'),(69,16,'UserLoggedIn','App\\Models\\User',16,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 20:36:13'),(70,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 20:51:47'),(71,4,'UserLoggedIn','App\\Models\\User',4,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-15 20:59:54'),(72,16,'UserLoggedIn','App\\Models\\User',16,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-16 12:05:57'),(73,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-16 12:10:29'),(74,7,'UserLoggedIn','App\\Models\\User',7,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-16 12:11:00'),(75,4,'UserLoggedIn','App\\Models\\User',4,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-16 12:46:01'),(76,4,'ApplicationForwarded','App\\Models\\Application',11,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-16 13:00:56'),(77,15,'UserLoggedIn','App\\Models\\User',15,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-16 13:01:12'),(78,15,'ApplicationForwarded','App\\Models\\Application',11,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-16 13:14:53'),(79,4,'UserLoggedIn','App\\Models\\User',4,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-16 13:15:42'),(80,4,'ApplicationForwarded','App\\Models\\Application',11,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-16 13:16:33'),(81,3,'UserLoggedIn','App\\Models\\User',3,NULL,NULL,'127.0.0.1','Dart/3.13 (dart:io)','2026-11-16 14:12:35');
/*!40000 ALTER TABLE `audit_logs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `batches`
--

DROP TABLE IF EXISTS `batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `batches` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `start_year` int(11) NOT NULL,
  `end_year` int(11) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `batches_name_unique` (`name`),
  KEY `batches_start_year_index` (`start_year`),
  KEY `batches_end_year_index` (`end_year`),
  KEY `batches_is_active_index` (`is_active`),
  KEY `batches_created_at_index` (`created_at`),
  KEY `batches_department_id_is_active_index` (`department_id`,`is_active`),
  CONSTRAINT `batches_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `batches`
--

LOCK TABLES `batches` WRITE;
/*!40000 ALTER TABLE `batches` DISABLE KEYS */;
INSERT INTO `batches` VALUES (1,1,'Batch 2022-2026',2022,2026,1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL),(2,1,'Batch 2023-2027',2023,2027,1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL),(3,1,'Batch 2024-2028',2024,2028,1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL),(4,1,'Batch 2025-2029',2025,2029,1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL),(5,NULL,'2018',2018,2022,1,'2026-11-13 17:12:55','2026-11-13 17:17:02','2026-11-13 17:17:02');
/*!40000 ALTER TABLE `batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `campuses`
--

DROP TABLE IF EXISTS `campuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `campuses` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(150) NOT NULL,
  `code` varchar(50) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `campuses_code_unique` (`code`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `campuses`
--

LOCK TABLES `campuses` WRITE;
/*!40000 ALTER TABLE `campuses` DISABLE KEYS */;
INSERT INTO `campuses` VALUES (1,'Main Campus','MAIN',1,'2026-11-13 15:37:33','2026-11-13 15:37:33'),(2,'Main Campus','MC',1,'2026-11-13 15:37:35','2026-11-13 15:37:35');
/*!40000 ALTER TABLE `campuses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `departments`
--

DROP TABLE IF EXISTS `departments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `departments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `faculty_id` bigint(20) unsigned DEFAULT NULL,
  `name` varchar(255) NOT NULL,
  `code` varchar(255) NOT NULL,
  `description` text DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `departments_code_unique` (`code`),
  KEY `departments_faculty_id_foreign` (`faculty_id`),
  CONSTRAINT `departments_faculty_id_foreign` FOREIGN KEY (`faculty_id`) REFERENCES `faculties` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `departments`
--

LOCK TABLES `departments` WRITE;
/*!40000 ALTER TABLE `departments` DISABLE KEYS */;
INSERT INTO `departments` VALUES (1,2,'Department of Computer Science','CS',NULL,1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL);
/*!40000 ALTER TABLE `departments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `faculties`
--

DROP TABLE IF EXISTS `faculties`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `faculties` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `campus_id` bigint(20) unsigned NOT NULL,
  `name` varchar(150) NOT NULL,
  `code` varchar(50) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `faculties_code_unique` (`code`),
  KEY `faculties_campus_id_foreign` (`campus_id`),
  CONSTRAINT `faculties_campus_id_foreign` FOREIGN KEY (`campus_id`) REFERENCES `campuses` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `faculties`
--

LOCK TABLES `faculties` WRITE;
/*!40000 ALTER TABLE `faculties` DISABLE KEYS */;
INSERT INTO `faculties` VALUES (1,1,'Faculty of Electrical and Computing Engineering','FECE',1,'2026-11-13 15:37:33','2026-11-13 15:37:33'),(2,2,'Faculty of Electrical & Computer Engineering','ENG',1,'2026-11-13 15:37:35','2026-11-13 15:37:35');
/*!40000 ALTER TABLE `faculties` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `jobs` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) NOT NULL,
  `payload` longtext NOT NULL,
  `attempts` tinyint(3) unsigned NOT NULL,
  `reserved_at` int(10) unsigned DEFAULT NULL,
  `available_at` int(10) unsigned NOT NULL,
  `created_at` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB AUTO_INCREMENT=52 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `migrations` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) NOT NULL,
  `batch` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=39 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'2026_01_01_000000_create_personal_access_tokens_table',1),(2,'2026_01_01_000001_create_departments_table',1),(3,'2026_01_01_000002_create_batches_table',1),(4,'2026_01_01_000003_create_sections_table',1),(5,'2026_01_01_000004_create_permission_tables',1),(6,'2026_01_01_000005_create_users_table',1),(7,'2026_01_01_000006_create_user_assigned_sections_table',1),(8,'2026_01_01_000007_create_applications_table',1),(9,'2026_01_01_000008_create_application_attachments_table',1),(10,'2026_01_01_000009_create_application_remarks_table',1),(11,'2026_01_01_000010_create_application_timeline_table',1),(12,'2026_01_01_000011_create_notices_table',1),(13,'2026_01_01_000012_create_notice_targets_table',1),(14,'2026_01_01_000013_create_notifications_table',1),(15,'2026_01_01_000015_create_settings_table',1),(16,'2026_08_06_000000_refactor_database_architecture',1),(17,'2026_08_06_000001_create_application_categories_table',1),(18,'2026_08_06_000002_add_category_id_to_applications_table',1),(19,'2026_08_06_091514_add_status_and_schedule_to_notices_table',1),(20,'2026_08_06_091729_create_notice_attachments_table',1),(21,'2026_08_06_091748_create_notice_reads_table',1),(22,'2026_08_06_102036_alter_notifications_table_for_notification_center',1),(23,'2026_08_06_105030_create_media_table',1),(24,'2026_08_06_105201_drop_legacy_attachment_tables',1),(25,'2026_08_06_105825_create_user_devices_table',1),(26,'2026_08_06_105826_create_login_histories_table',1),(27,'2026_08_06_110002_add_must_change_password_to_users_table',1),(28,'2026_08_06_110016_modify_password_reset_tokens_for_otp',1),(29,'2026_08_06_110701_create_audit_logs_table',1),(30,'2026_08_06_121124_add_attachment_columns_to_applications_table',1),(31,'2026_10_07_125608_create_jobs_table',1),(32,'2026_10_07_125716_create_sessions_table',1),(33,'2026_11_06_000001_create_institutional_topology_tables',1),(34,'2026_11_06_000002_enhance_and_normalize_users_table',1),(35,'2026_11_06_000003_restructure_application_attachments_and_scoping',1),(36,'2026_11_06_000004_modernize_notices_targeting',1),(37,'2026_11_06_000005_cleanup_redundant_database_structures',1),(38,'2026_11_06_000006_create_ticket_sequences_table',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_has_permissions`
--

DROP TABLE IF EXISTS `model_has_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `model_has_permissions` (
  `permission_id` bigint(20) unsigned NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`model_id`,`model_type`),
  KEY `model_has_permissions_model_id_model_type_index` (`model_id`,`model_type`),
  CONSTRAINT `model_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_has_permissions`
--

LOCK TABLES `model_has_permissions` WRITE;
/*!40000 ALTER TABLE `model_has_permissions` DISABLE KEYS */;
/*!40000 ALTER TABLE `model_has_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `model_has_roles`
--

DROP TABLE IF EXISTS `model_has_roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `model_has_roles` (
  `role_id` bigint(20) unsigned NOT NULL,
  `model_type` varchar(255) NOT NULL,
  `model_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`role_id`,`model_id`,`model_type`),
  KEY `model_has_roles_model_id_model_type_index` (`model_id`,`model_type`),
  CONSTRAINT `model_has_roles_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `model_has_roles`
--

LOCK TABLES `model_has_roles` WRITE;
/*!40000 ALTER TABLE `model_has_roles` DISABLE KEYS */;
INSERT INTO `model_has_roles` VALUES (1,'App\\Models\\User',16),(3,'App\\Models\\User',7),(3,'App\\Models\\User',15),(4,'App\\Models\\User',4),(5,'App\\Models\\User',3),(9,'App\\Models\\User',1);
/*!40000 ALTER TABLE `model_has_roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notice_attachments`
--

DROP TABLE IF EXISTS `notice_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notice_attachments` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `notice_id` bigint(20) unsigned NOT NULL,
  `file_name` varchar(255) NOT NULL,
  `file_path` varchar(255) NOT NULL,
  `file_type` varchar(255) DEFAULT NULL,
  `file_size` int(11) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notice_attachments_notice_id_foreign` (`notice_id`),
  CONSTRAINT `notice_attachments_notice_id_foreign` FOREIGN KEY (`notice_id`) REFERENCES `notices` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notice_attachments`
--

LOCK TABLES `notice_attachments` WRITE;
/*!40000 ALTER TABLE `notice_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `notice_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notice_reads`
--

DROP TABLE IF EXISTS `notice_reads`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notice_reads` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `notice_id` bigint(20) unsigned NOT NULL,
  `user_id` bigint(20) unsigned NOT NULL,
  `read_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `notice_reads_notice_id_user_id_unique` (`notice_id`,`user_id`),
  KEY `notice_reads_user_id_foreign` (`user_id`),
  CONSTRAINT `notice_reads_notice_id_foreign` FOREIGN KEY (`notice_id`) REFERENCES `notices` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notice_reads_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notice_reads`
--

LOCK TABLES `notice_reads` WRITE;
/*!40000 ALTER TABLE `notice_reads` DISABLE KEYS */;
/*!40000 ALTER TABLE `notice_reads` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notices`
--

DROP TABLE IF EXISTS `notices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `sender_id` bigint(20) unsigned NOT NULL,
  `target_batch_id` bigint(20) unsigned DEFAULT NULL,
  `target_section_id` bigint(20) unsigned DEFAULT NULL,
  `target_role` varchar(50) DEFAULT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `tag` varchar(255) NOT NULL DEFAULT 'General',
  `status` varchar(255) NOT NULL DEFAULT 'draft',
  `published_at` timestamp NULL DEFAULT NULL,
  `scheduled_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `version` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notices_sender_id_created_at_index` (`sender_id`,`created_at`),
  KEY `notices_target_section_id_foreign` (`target_section_id`),
  KEY `notices_dept_status_pub_idx` (`department_id`,`status`,`published_at`),
  KEY `notices_batch_sec_idx` (`target_batch_id`,`target_section_id`),
  CONSTRAINT `notices_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `notices_sender_id_foreign` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `notices_target_batch_id_foreign` FOREIGN KEY (`target_batch_id`) REFERENCES `batches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `notices_target_section_id_foreign` FOREIGN KEY (`target_section_id`) REFERENCES `sections` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notices`
--

LOCK TABLES `notices` WRITE;
/*!40000 ALTER TABLE `notices` DISABLE KEYS */;
/*!40000 ALTER TABLE `notices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `type` varchar(255) NOT NULL,
  `title` varchar(255) NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `reference_type` varchar(255) DEFAULT NULL,
  `reference_id` bigint(20) unsigned DEFAULT NULL,
  `read_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notifications_created_at_index` (`created_at`),
  KEY `notifications_reference_type_reference_id_index` (`reference_type`,`reference_id`),
  KEY `notifications_read_at_index` (`read_at`),
  KEY `notifications_user_id_read_at_index` (`user_id`,`read_at`),
  CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (2,15,'ApplicationSubmitted','New Application Submitted','Application DCMS-2026-0010 submitted by zaib.','2026-11-15 20:22:29','2026-11-15 20:52:03','App\\Models\\Application',11,'2026-11-15 20:52:03'),(3,15,'ApplicationSubmitted','New Application Submitted','Application DCMS-2026-0011 submitted by zaib.','2026-11-15 20:22:29','2026-11-15 20:52:03','App\\Models\\Application',12,'2026-11-15 20:52:03'),(4,15,'ApplicationSubmitted','New Application Submitted','Application DCMS-2026-0012 submitted by zaib.','2026-11-15 20:22:29','2026-11-15 20:52:02','App\\Models\\Application',13,'2026-11-15 20:52:02'),(5,16,'ApplicationRejected','Application Rejected','Your Application DCMS-2026-0011 has been rejected.','2026-11-15 20:22:29','2026-11-15 20:51:04','App\\Models\\Application',12,'2026-11-15 20:51:04'),(6,16,'ApplicationResolved','Application Resolved','Your Application DCMS-2026-0012 has been resolved.','2026-11-15 20:22:29','2026-11-15 20:51:05','App\\Models\\Application',13,'2026-11-15 20:51:05'),(7,4,'ApplicationForwarded','Application Forwarded','Application DCMS-2026-0010 has been forwarded to you.','2026-11-15 20:22:29','2026-11-15 21:00:10','App\\Models\\Application',11,'2026-11-15 21:00:10'),(8,16,'ApplicationForwarded','Application Status Updated','Your Application DCMS-2026-0010 has been forwarded.','2026-11-15 20:22:29','2026-11-15 20:51:06','App\\Models\\Application',11,'2026-11-15 20:51:06'),(9,15,'ApplicationForwarded','Application Forwarded','Application DCMS-2026-0010 has been forwarded to you.','2026-11-16 13:00:56','2026-11-16 13:15:03','App\\Models\\Application',11,'2026-11-16 13:15:03'),(10,16,'ApplicationForwarded','Application Status Updated','Your Application DCMS-2026-0010 has been forwarded.','2026-11-16 13:00:56','2026-11-16 13:00:56','App\\Models\\Application',11,NULL),(11,4,'ApplicationForwarded','Application Forwarded','Application DCMS-2026-0010 has been forwarded to you.','2026-11-16 13:14:53','2026-11-16 13:15:48','App\\Models\\Application',11,'2026-11-16 13:15:48'),(12,16,'ApplicationForwarded','Application Status Updated','Your Application DCMS-2026-0010 has been forwarded.','2026-11-16 13:14:53','2026-11-16 13:14:53','App\\Models\\Application',11,NULL),(13,3,'ApplicationForwarded','Application Forwarded','Application DCMS-2026-0010 has been forwarded to you.','2026-11-16 13:16:33','2026-11-16 14:13:15','App\\Models\\Application',11,'2026-11-16 14:13:15'),(14,16,'ApplicationForwarded','Application Status Updated','Your Application DCMS-2026-0010 has been forwarded.','2026-11-16 13:16:33','2026-11-16 13:16:33','App\\Models\\Application',11,NULL);
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `permissions`
--

DROP TABLE IF EXISTS `permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `permissions` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `permissions_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `permissions`
--

LOCK TABLES `permissions` WRITE;
/*!40000 ALTER TABLE `permissions` DISABLE KEYS */;
INSERT INTO `permissions` VALUES (1,'applications.create','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(2,'applications.view_own','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(3,'notices.view','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(4,'applications.view_assigned','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(5,'applications.forward','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(6,'applications.resolve','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(7,'notices.create','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(8,'applications.view_department','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(9,'reports.export','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(10,'audit.view','web','2026-11-13 15:37:34','2026-11-13 15:37:34');
/*!40000 ALTER TABLE `permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) NOT NULL,
  `tokenable_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `token` varchar(64) NOT NULL,
  `abilities` text DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=66 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',1,'auth_token','a8c67623c9e6d216aa2a2df1b1cef107d4b4b2bfdb355604560ebc9deb672928','[\"*\"]',NULL,NULL,'2026-11-13 16:45:09','2026-11-13 16:45:09'),(3,'App\\Models\\User',3,'auth_token','ec40327e7573c0e5d01de178085866212bdaa15f51fe1093e34dc992b1ccaa91','[\"*\"]','2026-11-13 17:00:59',NULL,'2026-11-13 16:48:48','2026-11-13 17:00:59'),(4,'App\\Models\\User',3,'auth_token','af981cde2db8d9b2d5db0740d4c46a1c816f494b14f4daacaa50d8b52f22f136','[\"*\"]','2026-11-13 17:11:12',NULL,'2026-11-13 17:01:11','2026-11-13 17:11:12'),(5,'App\\Models\\User',3,'test','881b9c918da4b80614159d5ccff05dea0d8a4ca934eeea59d867b1eed88cd339','[\"*\"]','2026-11-13 17:06:22',NULL,'2026-11-13 17:06:22','2026-11-13 17:06:22'),(6,'App\\Models\\User',3,'test','9e5d176634284f3a2c05872137ebf57a65fff1338efa71ea6ee353b0902b4f30','[\"*\"]','2026-11-13 17:06:56',NULL,'2026-11-13 17:06:56','2026-11-13 17:06:56'),(7,'App\\Models\\User',3,'test','fb02833d94fa69aab7355ba272e011e752bdebd133d6b1a58b43b545ebeeaef9','[\"*\"]','2026-11-13 17:08:05',NULL,'2026-11-13 17:08:04','2026-11-13 17:08:05'),(9,'App\\Models\\User',4,'auth_token','9116554614c8a8b3fe545032f1fc00204c333c08bf331e3ab292ba321b4b9e2b','[\"*\"]','2026-11-13 17:24:44',NULL,'2026-11-13 17:11:47','2026-11-13 17:24:44'),(10,'App\\Models\\User',4,'test','c289298f1b40e9a502e4fdec67de7f7f1e363edbeac0606d791e8553bfb88bc4','[\"*\"]','2026-11-13 17:23:18',NULL,'2026-11-13 17:23:17','2026-11-13 17:23:18'),(12,'App\\Models\\User',3,'auth_token','142263eab92c410ecafb6033e73d641f7ad210e1b04cb6412f9c80be26a1a4af','[\"*\"]','2026-11-13 17:28:29',NULL,'2026-11-13 17:27:52','2026-11-13 17:28:29'),(13,'App\\Models\\User',4,'auth_token','e7ffb1457907c0eb61890d4adfa6c362748caa94479afe9f453e00063c52cf37','[\"*\"]','2026-11-13 17:52:09',NULL,'2026-11-13 17:29:08','2026-11-13 17:52:09'),(18,'App\\Models\\User',7,'auth_token','9223370986a90a89dc93a756aa69e20822625a7ba68033170577f9d3e3d06426','[\"*\"]','2026-11-13 18:12:50',NULL,'2026-11-13 18:12:45','2026-11-13 18:12:50'),(22,'App\\Models\\User',7,'auth_token','122047902a53acdcf8abeb55070058ff8b39987dbc57e202094e1329d5f8fe79','[\"*\"]','2026-11-15 17:30:25',NULL,'2026-11-15 17:28:55','2026-11-15 17:30:25'),(25,'App\\Models\\User',7,'auth_token','41906764e5b2044f3b265ea31fc49f3fd5379980048e965078a5fffc644aadda','[\"*\"]','2026-11-15 17:46:06',NULL,'2026-11-15 17:45:22','2026-11-15 17:46:06'),(29,'App\\Models\\User',7,'auth_token','079f43d4239f928ac0402820c301d8b6a78b2ac4e037180e316393acb49f0ce3','[\"*\"]','2026-11-15 18:07:17',NULL,'2026-11-15 17:56:35','2026-11-15 18:07:17'),(31,'App\\Models\\User',15,'auth_token','d1234c987a8d6fa1e23a1a7450b2ee666fd38388b95716244a5af391019f9b64','[\"*\"]','2026-11-15 18:27:47',NULL,'2026-11-15 18:08:26','2026-11-15 18:27:47'),(37,'App\\Models\\User',15,'auth_token','93de41fd2113e1f625420787247177f87c794b14718b76d91d28f4493b41738e','[\"*\"]','2026-11-15 18:35:27',NULL,'2026-11-15 18:35:04','2026-11-15 18:35:27'),(45,'App\\Models\\User',16,'auth_token','c4406570af4a953fa3821ab5672463387ef04b6b20b2e725696f573c79df0ea4','[\"*\"]','2026-11-15 19:14:39',NULL,'2026-11-15 19:05:17','2026-11-15 19:14:39'),(46,'App\\Models\\User',16,'auth_token','ae0e65f0d68d16d87a10ca60a6a9977bbf2b869c183776e421b6d96da5b2874b','[\"*\"]','2026-11-15 19:16:28',NULL,'2026-11-15 19:14:53','2026-11-15 19:16:28'),(47,'App\\Models\\User',16,'auth_token','b2696d0f03de09157641c76f78396b410311e01a8415cb03a02bcd62bf424493','[\"*\"]','2026-11-15 19:18:09',NULL,'2026-11-15 19:17:02','2026-11-15 19:18:09'),(51,'App\\Models\\User',15,'auth_token','aacd851909c37deb937dd2404bbc223954778f3682c251fc6e0043f6dfdb7592','[\"*\"]','2026-11-15 20:00:15',NULL,'2026-11-15 19:42:52','2026-11-15 20:00:15'),(55,'App\\Models\\User',16,'auth_token','90bb7b6f001fafbb6bb2c32f811a0977116356f15264c1b777dc043a132667c9','[\"*\"]','2026-11-15 20:35:59',NULL,'2026-11-15 20:17:04','2026-11-15 20:35:59'),(61,'App\\Models\\User',7,'auth_token','dc02d97ab91fda707629110c1042daf58191fc348d331492a3c3c96877ec7b5f','[\"*\"]','2026-11-16 12:12:46',NULL,'2026-11-16 12:11:00','2026-11-16 12:12:46'),(65,'App\\Models\\User',3,'auth_token','937c338ae33b1680ff6548e371ba32a92fccb9210b768dde4d068fb641491ba4','[\"*\"]','2026-11-16 14:13:15',NULL,'2026-11-16 14:12:35','2026-11-16 14:13:15');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `role_has_permissions`
--

DROP TABLE IF EXISTS `role_has_permissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `role_has_permissions` (
  `permission_id` bigint(20) unsigned NOT NULL,
  `role_id` bigint(20) unsigned NOT NULL,
  PRIMARY KEY (`permission_id`,`role_id`),
  KEY `role_has_permissions_role_id_foreign` (`role_id`),
  CONSTRAINT `role_has_permissions_permission_id_foreign` FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE,
  CONSTRAINT `role_has_permissions_role_id_foreign` FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `role_has_permissions`
--

LOCK TABLES `role_has_permissions` WRITE;
/*!40000 ALTER TABLE `role_has_permissions` DISABLE KEYS */;
INSERT INTO `role_has_permissions` VALUES (1,1),(1,9),(2,1),(2,9),(3,1),(3,9),(4,3),(4,9),(5,3),(5,9),(6,4),(6,9),(7,4),(7,9),(8,5),(8,9),(9,5),(9,9),(10,5),(10,9);
/*!40000 ALTER TABLE `role_has_permissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `roles`
--

DROP TABLE IF EXISTS `roles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `roles` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `guard_name` varchar(255) NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `roles_name_guard_name_unique` (`name`,`guard_name`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `roles`
--

LOCK TABLES `roles` WRITE;
/*!40000 ALTER TABLE `roles` DISABLE KEYS */;
INSERT INTO `roles` VALUES (1,'Student','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(2,'Class Representative','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(3,'Batch Adviser','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(4,'Coordinator','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(5,'Chairman','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(6,'Office Staff','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(7,'Dean','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(8,'Vice Chancellor','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(9,'Admin','web','2026-11-13 15:37:34','2026-11-13 15:37:34'),(10,'CR','web','2026-11-13 15:37:34','2026-11-13 15:37:34');
/*!40000 ALTER TABLE `roles` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sections`
--

DROP TABLE IF EXISTS `sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `batch_id` bigint(20) unsigned NOT NULL,
  `name` varchar(255) NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `sections_batch_id_name_unique` (`batch_id`,`name`),
  KEY `sections_created_at_index` (`created_at`),
  CONSTRAINT `sections_batch_id_foreign` FOREIGN KEY (`batch_id`) REFERENCES `batches` (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=25 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sections`
--

LOCK TABLES `sections` WRITE;
/*!40000 ALTER TABLE `sections` DISABLE KEYS */;
INSERT INTO `sections` VALUES (4,2,'A',1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL),(5,2,'B',1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL),(6,2,'C',1,'2026-11-13 15:37:35','2026-11-16 14:10:53','2026-11-16 14:10:53'),(7,3,'A',1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL),(8,3,'B',1,'2026-11-13 15:37:35','2026-11-13 15:37:35',NULL),(9,3,'C',1,'2026-11-13 15:37:35','2026-11-16 14:11:03','2026-11-16 14:11:03'),(13,5,'A',1,'2026-11-13 17:12:55','2026-11-13 17:12:55',NULL),(15,1,'B',1,'2026-11-15 17:31:09','2026-11-15 17:31:09',NULL),(16,1,'A',1,'2026-11-15 17:47:56','2026-11-15 17:47:56',NULL),(17,4,'A',1,'2026-11-15 17:53:03','2026-11-15 17:53:03',NULL),(18,4,'B',1,'2026-11-16 13:56:22','2026-11-16 14:05:56',NULL),(19,3,'D',1,'2026-11-16 13:58:39','2026-11-16 14:10:57','2026-11-16 14:10:57'),(22,4,'C',1,'2026-11-16 13:59:17','2026-11-16 14:11:09','2026-11-16 14:11:09'),(24,1,'C',1,'2026-11-16 14:10:04','2026-11-16 14:10:49','2026-11-16 14:10:49');
/*!40000 ALTER TABLE `sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sessions` (
  `id` varchar(255) NOT NULL,
  `user_id` bigint(20) unsigned DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `user_agent` text DEFAULT NULL,
  `payload` longtext NOT NULL,
  `last_activity` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `sessions_user_id_index` (`user_id`),
  KEY `sessions_last_activity_index` (`last_activity`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sessions`
--

LOCK TABLES `sessions` WRITE;
/*!40000 ALTER TABLE `sessions` DISABLE KEYS */;
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `settings`
--

DROP TABLE IF EXISTS `settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `settings` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `key` varchar(255) NOT NULL,
  `value` text DEFAULT NULL,
  `group` varchar(255) NOT NULL DEFAULT 'general',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `settings_key_unique` (`key`),
  KEY `settings_group_index` (`group`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `settings`
--

LOCK TABLES `settings` WRITE;
/*!40000 ALTER TABLE `settings` DISABLE KEYS */;
INSERT INTO `settings` VALUES (1,'app_name','Department Complaint Management System','general','2026-11-13 15:37:35','2026-11-13 15:37:35'),(2,'academic_year','2025-2026','general','2026-11-13 15:37:35','2026-11-13 15:37:35'),(3,'registration_enabled','1','general','2026-11-13 15:37:35','2026-11-13 15:37:35'),(4,'max_attachment_size_mb','10','uploads','2026-11-13 15:37:35','2026-11-13 15:37:35'),(5,'auto_assign_adviser','1','general','2026-11-13 15:37:35','2026-11-13 15:37:35');
/*!40000 ALTER TABLE `settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_sequences`
--

DROP TABLE IF EXISTS `ticket_sequences`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `ticket_sequences` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `current_value` bigint(20) unsigned NOT NULL DEFAULT 0,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `ticket_sequences_name_unique` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_sequences`
--

LOCK TABLES `ticket_sequences` WRITE;
/*!40000 ALTER TABLE `ticket_sequences` DISABLE KEYS */;
INSERT INTO `ticket_sequences` VALUES (1,'applications_2026',12,'2026-11-15 16:40:15','2026-11-15 19:19:21');
/*!40000 ALTER TABLE `ticket_sequences` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_assigned_sections`
--

DROP TABLE IF EXISTS `user_assigned_sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_assigned_sections` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `section_id` bigint(20) unsigned NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_assigned_sections_user_id_section_id_unique` (`user_id`,`section_id`),
  KEY `user_assigned_sections_section_id_foreign` (`section_id`),
  CONSTRAINT `user_assigned_sections_section_id_foreign` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE CASCADE,
  CONSTRAINT `user_assigned_sections_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_assigned_sections`
--

LOCK TABLES `user_assigned_sections` WRITE;
/*!40000 ALTER TABLE `user_assigned_sections` DISABLE KEYS */;
INSERT INTO `user_assigned_sections` VALUES (2,7,17,'2026-11-13 18:02:14','2026-11-13 18:02:14'),(4,15,16,'2026-11-16 13:42:29','2026-11-16 13:42:29');
/*!40000 ALTER TABLE `user_assigned_sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_devices`
--

DROP TABLE IF EXISTS `user_devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `user_devices` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint(20) unsigned NOT NULL,
  `device_id` varchar(255) NOT NULL,
  `device_name` varchar(255) DEFAULT NULL,
  `platform` varchar(255) DEFAULT NULL,
  `app_version` varchar(255) DEFAULT NULL,
  `os_version` varchar(255) DEFAULT NULL,
  `push_token` varchar(255) DEFAULT NULL,
  `ip_address` varchar(45) DEFAULT NULL,
  `refresh_token_hash` varchar(64) DEFAULT NULL,
  `refresh_token_expires_at` timestamp NULL DEFAULT NULL,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `revoked_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `user_devices_refresh_token_hash_unique` (`refresh_token_hash`),
  KEY `user_devices_user_id_foreign` (`user_id`),
  KEY `user_devices_device_id_index` (`device_id`),
  CONSTRAINT `user_devices_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_devices`
--

LOCK TABLES `user_devices` WRITE;
/*!40000 ALTER TABLE `user_devices` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_devices` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `id` bigint(20) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `registration_number` varchar(50) DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) NOT NULL,
  `must_change_password` tinyint(1) NOT NULL DEFAULT 1,
  `department_id` bigint(20) unsigned DEFAULT NULL,
  `batch_id` bigint(20) unsigned DEFAULT NULL,
  `section_id` bigint(20) unsigned DEFAULT NULL,
  `current_semester` tinyint(3) unsigned DEFAULT NULL,
  `semester` varchar(255) DEFAULT NULL,
  `adviser_id` bigint(20) unsigned DEFAULT NULL,
  `status` varchar(255) NOT NULL DEFAULT 'approved',
  `phone` varchar(255) DEFAULT NULL,
  `profile_image_url` varchar(255) DEFAULT NULL,
  `remember_token` varchar(100) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_registration_number_unique` (`registration_number`),
  KEY `users_batch_id_foreign` (`batch_id`),
  KEY `users_section_id_foreign` (`section_id`),
  KEY `users_adviser_id_foreign` (`adviser_id`),
  KEY `users_email_status_index` (`email`,`status`),
  KEY `users_department_id_status_index` (`department_id`,`status`),
  KEY `users_created_at_index` (`created_at`),
  KEY `users_deleted_at_index` (`deleted_at`),
  KEY `users_current_semester_index` (`current_semester`),
  CONSTRAINT `users_adviser_id_foreign` FOREIGN KEY (`adviser_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_batch_id_foreign` FOREIGN KEY (`batch_id`) REFERENCES `batches` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_department_id_foreign` FOREIGN KEY (`department_id`) REFERENCES `departments` (`id`) ON DELETE SET NULL,
  CONSTRAINT `users_section_id_foreign` FOREIGN KEY (`section_id`) REFERENCES `sections` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'System Administrator','admin@uetmardan.edu.pk','ADM-SYS-001',NULL,'$2y$12$ikSUZ6Au5G1uqHxmwSv9We28lBPbqphZc0OtkI1svKy2Ru72Fm.gm',1,1,NULL,NULL,NULL,NULL,NULL,'approved',NULL,NULL,NULL,'2026-11-13 16:43:26','2026-11-15 15:55:56',NULL),(3,'Usman sb','usman@uetmardan.edu.pk','USMAN',NULL,'$2y$12$gvza/4xlxTsQkr1TD/.nq.mVFgBq.PYEMwe6VKpXfr2tQv6IK.JQy',1,1,NULL,NULL,NULL,NULL,NULL,'approved',NULL,NULL,NULL,'2026-11-13 16:48:30','2026-11-15 20:25:05',NULL),(4,'Talha sb','talha@uetmardan.edu.pk','TALHA',NULL,'$2y$12$7jCeY1KKM2T6bYl2eoE9KOB8JpQHfCKfSzM0gIcBJppaboxHQLcB.',1,1,NULL,NULL,NULL,NULL,NULL,'approved',NULL,NULL,NULL,'2026-11-13 16:49:36','2026-11-15 20:25:05',NULL),(7,'Danyal sb','danyal@uetmardan.edu.pk','DANYAL',NULL,'$2y$12$cX/qjJU3fhvAbIM5q7xSieN9nNoFeNx8Itts.AbAzMIlfG2FlZlse',1,1,4,17,NULL,NULL,NULL,'approved','03029558889',NULL,NULL,'2026-11-13 18:02:14','2026-11-15 19:58:34',NULL),(15,'yousaf sb','yousaf@uetmardan.edu.pk','YOUSAF',NULL,'$2y$12$pEVUBpW7VMq16pUHZwZWquK0YPEMqCNq8Y0IDsbC0z8LVFG8IOFB2',1,1,1,16,NULL,NULL,NULL,'approved','03001234567',NULL,NULL,'2026-11-15 17:55:25','2026-11-16 13:42:29',NULL),(16,'zaib','23MDBCS407@uetmardan.edu.pk','23MDBCS407',NULL,'$2y$12$.JU/RPKjdyNfhIBNBifLSO7EfKulwUUen9DmNsNAIjKoPnzpIrtNq',1,1,1,15,8,'Semester 8',15,'approved','03029556564',NULL,NULL,'2026-11-15 18:54:56','2026-11-15 20:25:05',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-18 12:44:12
