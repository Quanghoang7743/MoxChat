-- MySQL dump 10.13  Distrib 9.6.0, for macos26.3 (arm64)
--
-- Host: localhost    Database: messapp
-- ------------------------------------------------------
-- Server version	9.5.0

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
SET @MYSQLDUMP_TEMP_LOG_BIN = @@SESSION.SQL_LOG_BIN;
SET @@SESSION.SQL_LOG_BIN= 0;

--
-- GTID state at the beginning of the backup 
--

SET @@GLOBAL.GTID_PURGED=/*!80000 '+'*/ 'd176410a-e666-11f0-83f4-d8d9b80d1a5a:1-2440';

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conversation_participants`
--

DROP TABLE IF EXISTS `conversation_participants`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conversation_participants` (
  `conversation_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `participant_role` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'member',
  `nickname` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `joined_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `left_at` datetime(3) DEFAULT NULL,
  `removed_at` datetime(3) DEFAULT NULL,
  `last_read_message_id` bigint unsigned DEFAULT NULL,
  `last_read_at` datetime(3) DEFAULT NULL,
  `last_delivered_message_id` bigint unsigned DEFAULT NULL,
  `last_delivered_at` datetime(3) DEFAULT NULL,
  `muted_until` datetime(3) DEFAULT NULL,
  `is_muted` tinyint(1) NOT NULL DEFAULT '0',
  `is_pinned` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `is_hidden` tinyint(1) NOT NULL DEFAULT '0',
  `custom_conversation_name` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `unread_count_cache` int unsigned NOT NULL DEFAULT '0',
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`conversation_id`,`user_id`),
  KEY `idx_cp_user_active` (`user_id`,`left_at`,`removed_at`),
  KEY `idx_cp_user_pinned` (`user_id`,`is_pinned`),
  KEY `idx_cp_last_read_message_id` (`last_read_message_id`),
  KEY `fk_cp_last_delivered_message` (`last_delivered_message_id`),
  CONSTRAINT `fk_cp_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_cp_last_delivered_message` FOREIGN KEY (`last_delivered_message_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_cp_last_read_message` FOREIGN KEY (`last_read_message_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_cp_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_cp_role` CHECK ((`participant_role` in (_utf8mb4'owner',_utf8mb4'admin',_utf8mb4'member')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conversation_participants`
--

LOCK TABLES `conversation_participants` WRITE;
/*!40000 ALTER TABLE `conversation_participants` DISABLE KEYS */;
INSERT INTO `conversation_participants` VALUES (1,1,'member',NULL,'2026-03-27 07:09:54.000',NULL,NULL,23,'2026-04-02 07:22:25.000',23,'2026-04-02 07:22:25.000',NULL,0,0,0,0,NULL,0,'2026-03-27 07:09:54.000','2026-04-02 07:22:25.000'),(1,2,'member',NULL,'2026-03-27 07:09:54.000',NULL,NULL,23,'2026-03-30 02:27:45.000',23,'2026-03-30 02:27:45.000',NULL,0,0,0,0,NULL,0,'2026-03-27 07:09:54.000','2026-03-30 02:27:45.000'),(2,1,'member',NULL,'2026-03-27 07:17:39.000',NULL,NULL,20,'2026-03-30 02:25:09.000',20,'2026-03-30 02:25:09.000',NULL,0,0,0,0,NULL,0,'2026-03-27 07:17:39.000','2026-03-30 02:25:09.000'),(2,3,'member',NULL,'2026-03-27 07:17:39.000',NULL,NULL,11,'2026-03-27 07:24:24.000',11,'2026-03-27 07:24:24.000',NULL,0,0,0,0,NULL,4,'2026-03-27 07:17:39.000','2026-03-27 14:15:55.000');
/*!40000 ALTER TABLE `conversation_participants` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `conversations`
--

DROP TABLE IF EXISTS `conversations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `conversations` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `conversation_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` bigint unsigned NOT NULL,
  `owner_user_id` bigint unsigned DEFAULT NULL,
  `description` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_message_id` bigint unsigned DEFAULT NULL,
  `last_message_at` datetime(3) DEFAULT NULL,
  `member_count` int unsigned NOT NULL DEFAULT '0',
  `is_encrypted` tinyint(1) NOT NULL DEFAULT '0',
  `is_archived` tinyint(1) NOT NULL DEFAULT '0',
  `is_deleted` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_conversations_type_updated` (`conversation_type`,`updated_at`),
  KEY `idx_conversations_last_message_at` (`last_message_at`),
  KEY `idx_conversations_created_by` (`created_by`),
  KEY `fk_conversations_owner_user` (`owner_user_id`),
  KEY `fk_conversations_last_message` (`last_message_id`),
  CONSTRAINT `fk_conversations_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `fk_conversations_last_message` FOREIGN KEY (`last_message_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_conversations_owner_user` FOREIGN KEY (`owner_user_id`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `chk_conversations_type` CHECK ((`conversation_type` in (_utf8mb4'direct',_utf8mb4'group')))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `conversations`
--

LOCK TABLES `conversations` WRITE;
/*!40000 ALTER TABLE `conversations` DISABLE KEYS */;
INSERT INTO `conversations` VALUES (1,'direct',NULL,NULL,2,NULL,NULL,23,'2026-03-30 02:27:45.000',2,0,0,0,'2026-03-27 07:09:54.000','2026-03-30 02:27:45.000'),(2,'direct',NULL,NULL,1,NULL,NULL,20,'2026-03-27 14:15:55.000',2,0,0,0,'2026-03-27 07:17:39.000','2026-03-27 14:15:55.000');
/*!40000 ALTER TABLE `conversations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `direct_conversation_keys`
--

DROP TABLE IF EXISTS `direct_conversation_keys`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `direct_conversation_keys` (
  `user_low_id` bigint unsigned NOT NULL,
  `user_high_id` bigint unsigned NOT NULL,
  `conversation_id` bigint unsigned NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`user_low_id`,`user_high_id`),
  UNIQUE KEY `uk_direct_conversation_id` (`conversation_id`),
  KEY `fk_dck_user_high` (`user_high_id`),
  CONSTRAINT `fk_dck_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dck_user_high` FOREIGN KEY (`user_high_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_dck_user_low` FOREIGN KEY (`user_low_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_dck_user_order` CHECK ((`user_low_id` < `user_high_id`))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `direct_conversation_keys`
--

LOCK TABLES `direct_conversation_keys` WRITE;
/*!40000 ALTER TABLE `direct_conversation_keys` DISABLE KEYS */;
INSERT INTO `direct_conversation_keys` VALUES (1,2,1,'2026-03-27 07:09:54.000'),(1,3,2,'2026-03-27 07:17:39.000');
/*!40000 ALTER TABLE `direct_conversation_keys` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friend_requests`
--

DROP TABLE IF EXISTS `friend_requests`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friend_requests` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `requester_id` bigint unsigned NOT NULL,
  `addressee_id` bigint unsigned NOT NULL,
  `phone_snapshot` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'pending',
  `responded_at` datetime(3) DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_friend_requests_state` (`requester_id`,`addressee_id`,`status`),
  KEY `idx_friend_requests_addressee_status` (`addressee_id`,`status`),
  KEY `idx_friend_requests_requester_status` (`requester_id`,`status`),
  CONSTRAINT `fk_friend_requests_addressee` FOREIGN KEY (`addressee_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_friend_requests_requester` FOREIGN KEY (`requester_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_friend_requests_status` CHECK ((`status` in (_utf8mb4'pending',_utf8mb4'accepted',_utf8mb4'rejected',_utf8mb4'cancelled',_utf8mb4'expired')))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friend_requests`
--

LOCK TABLES `friend_requests` WRITE;
/*!40000 ALTER TABLE `friend_requests` DISABLE KEYS */;
INSERT INTO `friend_requests` VALUES (1,2,1,NULL,NULL,'accepted','2026-03-27 07:08:59.000','2026-03-27 07:05:39.000','2026-03-27 07:08:59.000'),(2,1,2,NULL,NULL,'accepted','2026-03-27 07:09:29.000','2026-03-27 07:05:48.000','2026-03-27 07:09:29.000'),(3,3,1,NULL,NULL,'accepted','2026-03-27 07:17:33.000','2026-03-27 07:17:27.000','2026-03-27 07:17:33.000');
/*!40000 ALTER TABLE `friend_requests` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `friendships`
--

DROP TABLE IF EXISTS `friendships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `friendships` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_low_id` bigint unsigned NOT NULL,
  `user_high_id` bigint unsigned NOT NULL,
  `created_by` bigint unsigned NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_friendships_pair` (`user_low_id`,`user_high_id`),
  KEY `idx_friendships_user_high` (`user_high_id`),
  KEY `fk_friendships_created_by` (`created_by`),
  CONSTRAINT `fk_friendships_created_by` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_friendships_user_high` FOREIGN KEY (`user_high_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_friendships_user_low` FOREIGN KEY (`user_low_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_friendships_order` CHECK ((`user_low_id` < `user_high_id`))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `friendships`
--

LOCK TABLES `friendships` WRITE;
/*!40000 ALTER TABLE `friendships` DISABLE KEYS */;
INSERT INTO `friendships` VALUES (1,1,2,1,'2026-03-27 07:08:59.000'),(2,1,3,1,'2026-03-27 07:17:33.000');
/*!40000 ALTER TABLE `friendships` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `job_batches`
--

DROP TABLE IF EXISTS `job_batches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `job_batches` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `total_jobs` int NOT NULL,
  `pending_jobs` int NOT NULL,
  `failed_jobs` int NOT NULL,
  `failed_job_ids` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `options` mediumtext COLLATE utf8mb4_unicode_ci,
  `cancelled_at` int DEFAULT NULL,
  `created_at` int NOT NULL,
  `finished_at` int DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `job_batches`
--

LOCK TABLES `job_batches` WRITE;
/*!40000 ALTER TABLE `job_batches` DISABLE KEYS */;
/*!40000 ALTER TABLE `job_batches` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `jobs`
--

DROP TABLE IF EXISTS `jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `queue` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempts` tinyint unsigned NOT NULL,
  `reserved_at` int unsigned DEFAULT NULL,
  `available_at` int unsigned NOT NULL,
  `created_at` int unsigned NOT NULL,
  PRIMARY KEY (`id`),
  KEY `jobs_queue_index` (`queue`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `jobs`
--

LOCK TABLES `jobs` WRITE;
/*!40000 ALTER TABLE `jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_attachments`
--

DROP TABLE IF EXISTS `message_attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message_attachments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `message_id` bigint unsigned NOT NULL,
  `attachment_type` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_ext` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mime_type` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint unsigned NOT NULL,
  `storage_provider` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 's3',
  `storage_bucket` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `storage_key` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `thumbnail_url` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `checksum_sha256` varchar(64) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `width` int DEFAULT NULL,
  `height` int DEFAULT NULL,
  `duration_seconds` int DEFAULT NULL,
  `preview_text` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  KEY `idx_message_attachments_message` (`message_id`),
  KEY `idx_message_attachments_storage_key` (`storage_key`(191)),
  CONSTRAINT `fk_message_attachments_message` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `chk_message_attachments_type` CHECK ((`attachment_type` in (_utf8mb4'image',_utf8mb4'video',_utf8mb4'audio',_utf8mb4'file')))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_attachments`
--

LOCK TABLES `message_attachments` WRITE;
/*!40000 ALTER TABLE `message_attachments` DISABLE KEYS */;
/*!40000 ALTER TABLE `message_attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `message_reactions`
--

DROP TABLE IF EXISTS `message_reactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `message_reactions` (
  `message_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `reaction_code` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`message_id`,`user_id`,`reaction_code`),
  KEY `idx_message_reactions_user` (`user_id`),
  CONSTRAINT `fk_message_reactions_message` FOREIGN KEY (`message_id`) REFERENCES `messages` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_message_reactions_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `message_reactions`
--

LOCK TABLES `message_reactions` WRITE;
/*!40000 ALTER TABLE `message_reactions` DISABLE KEYS */;
INSERT INTO `message_reactions` VALUES (2,2,'❤️','2026-03-27 07:11:36.000'),(5,1,'👍','2026-03-27 07:26:55.000'),(6,3,'❤️','2026-03-27 07:27:05.000'),(7,1,'👍','2026-03-27 07:24:52.000'),(9,1,'❤️','2026-03-27 07:24:39.000'),(11,1,'❤️','2026-03-27 07:24:36.000');
/*!40000 ALTER TABLE `message_reactions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `messages`
--

DROP TABLE IF EXISTS `messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `messages` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `conversation_id` bigint unsigned NOT NULL,
  `sender_id` bigint unsigned NOT NULL,
  `client_message_id` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `message_type` varchar(30) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'text',
  `content` text COLLATE utf8mb4_unicode_ci,
  `content_json` json DEFAULT NULL,
  `reply_to_message_id` bigint unsigned DEFAULT NULL,
  `forward_from_message_id` bigint unsigned DEFAULT NULL,
  `sent_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `delivered_at` datetime(3) DEFAULT NULL,
  `edited_at` datetime(3) DEFAULT NULL,
  `deleted_for_everyone_at` datetime(3) DEFAULT NULL,
  `sender_deleted_at` datetime(3) DEFAULT NULL,
  `message_status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'sent',
  `has_attachments` tinyint(1) NOT NULL DEFAULT '0',
  `metadata_json` json DEFAULT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_messages_client_message_id_sender` (`sender_id`,`client_message_id`),
  KEY `idx_messages_conversation_id_id` (`conversation_id`,`id` DESC),
  KEY `idx_messages_conversation_sent_at` (`conversation_id`,`sent_at` DESC),
  KEY `idx_messages_sender_id` (`sender_id`),
  KEY `idx_messages_reply_to` (`reply_to_message_id`),
  KEY `idx_messages_forward_from` (`forward_from_message_id`),
  KEY `idx_messages_not_deleted` (`conversation_id`,`deleted_for_everyone_at`,`id` DESC),
  CONSTRAINT `fk_messages_conversation` FOREIGN KEY (`conversation_id`) REFERENCES `conversations` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_messages_forward_from` FOREIGN KEY (`forward_from_message_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_messages_reply_to` FOREIGN KEY (`reply_to_message_id`) REFERENCES `messages` (`id`) ON DELETE SET NULL,
  CONSTRAINT `fk_messages_sender` FOREIGN KEY (`sender_id`) REFERENCES `users` (`id`) ON DELETE RESTRICT,
  CONSTRAINT `chk_messages_status` CHECK ((`message_status` in (_utf8mb4'sending',_utf8mb4'sent',_utf8mb4'failed'))),
  CONSTRAINT `chk_messages_type` CHECK ((`message_type` in (_utf8mb4'text',_utf8mb4'image',_utf8mb4'video',_utf8mb4'audio',_utf8mb4'file',_utf8mb4'sticker',_utf8mb4'system',_utf8mb4'call',_utf8mb4'location',_utf8mb4'contact')))
) ENGINE=InnoDB AUTO_INCREMENT=24 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `messages`
--

LOCK TABLES `messages` WRITE;
/*!40000 ALTER TABLE `messages` DISABLE KEYS */;
INSERT INTO `messages` VALUES (1,1,1,'web-mn8kamjl-bdc7ip-mhlojs','text','hi',NULL,NULL,NULL,'2026-03-27 07:10:21.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 07:10:21.000','2026-03-27 07:10:21.000'),(2,1,2,'web-mn8katfx-bp3h07-y36z71','text',NULL,NULL,NULL,NULL,'2026-03-27 07:10:28.000',NULL,NULL,'2026-03-27 07:26:08.000','2026-03-27 07:26:04.000','sent',0,NULL,'2026-03-27 07:10:28.000','2026-03-27 07:26:08.000'),(3,1,1,'web-mn8kbhk2-p794ql-ij0ygg','text','test',NULL,NULL,NULL,'2026-03-27 07:11:01.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 07:11:01.000','2026-03-27 07:11:01.000'),(4,1,1,'web-mn8khaxg-fynyi3-j6ld1q','text','chào bạn',NULL,NULL,NULL,'2026-03-27 07:15:32.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 07:15:32.000','2026-03-27 07:15:32.000'),(5,2,1,'web-mn8kk31v-ijvjxz-f2kdde','text','hi',NULL,NULL,NULL,'2026-03-27 07:17:42.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 07:17:42.000','2026-03-27 07:17:42.000'),(6,2,3,'web-mn8kke7c-wabkib-hxet0o','text','chào mày',NULL,NULL,NULL,'2026-03-27 07:17:55.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 07:17:55.000','2026-03-27 07:17:55.000'),(7,2,3,'web-mn8kkhjn-gqtjsd-altuny','text','app lỏ quá',NULL,NULL,NULL,'2026-03-27 07:17:59.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 07:17:59.000','2026-03-27 07:17:59.000'),(8,2,1,'web-mn8kksex-fzl8ca-5u56m2','text','hí',NULL,NULL,NULL,'2026-03-27 07:18:15.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 07:18:15.000','2026-03-27 07:18:15.000'),(9,2,3,'web-mn8kpgta-a7ehsd-10did7','text','hi',NULL,NULL,NULL,'2026-03-27 07:21:52.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 07:21:52.000','2026-03-27 07:21:52.000'),(10,2,1,'web-mn8kpiiy-04ieii-bvogkj','text','mịa',NULL,NULL,NULL,'2026-03-27 07:21:55.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 07:21:55.000','2026-03-27 07:21:55.000'),(11,2,1,'web-mn8ksp1i-0hyrx5-i6lxkd','text','hehe',NULL,NULL,NULL,'2026-03-27 07:24:24.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 07:24:24.000','2026-03-27 07:24:24.000'),(12,1,1,'web-mn8nxy2b-wm5yht-s111zj','text','djaklds',NULL,NULL,NULL,'2026-03-27 08:52:28.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 08:52:28.000','2026-03-27 08:52:28.000'),(13,1,1,'web-mn8nxyvl-rg7y15-bf5cta','text','jdlkasda',NULL,NULL,NULL,'2026-03-27 08:52:29.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 08:52:29.000','2026-03-27 08:52:29.000'),(14,1,1,'web-mn8nxzm2-8y82qj-hg3dsh','text','kdjalskda',NULL,NULL,NULL,'2026-03-27 08:52:30.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 08:52:30.000','2026-03-27 08:52:30.000'),(15,1,1,'web-mn8ny0cd-ml2iey-8bwvfa','text','kdjalksd',NULL,NULL,NULL,'2026-03-27 08:52:31.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 08:52:31.000','2026-03-27 08:52:31.000'),(16,1,1,'web-mn8q76oi-i1mbax-j84az7','text','hi',NULL,NULL,NULL,'2026-03-27 09:55:38.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 09:55:38.000','2026-03-27 09:55:38.000'),(17,2,1,'web-mn8saegx-4qegug-9b98tr','text','gà vl',NULL,NULL,NULL,'2026-03-27 10:54:07.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 10:54:07.000','2026-03-27 10:54:07.000'),(18,2,1,'web-mn8zgvjm-v9qkvu-jyt4b2','text','hi',NULL,NULL,NULL,'2026-03-27 14:15:07.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 14:15:07.000','2026-03-27 14:15:07.000'),(19,2,1,'web-mn8zgyed-mtkvij-5bkno1','text','ds',NULL,NULL,NULL,'2026-03-27 14:15:10.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 14:15:10.000','2026-03-27 14:15:10.000'),(20,2,1,'web-mn8zhwvc-hpkvrd-16o5rw','text',NULL,NULL,NULL,NULL,'2026-03-27 14:15:55.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-27 14:15:55.000','2026-03-27 14:16:12.000'),(21,1,2,'web-mnckhsgg-z0yjrb-fth8j6','text','hí',NULL,NULL,NULL,'2026-03-30 02:27:00.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-30 02:27:00.000','2026-03-30 02:27:00.000'),(22,1,1,'web-mncki5se-awl5nq-6g1m5h','text','mịa mì',NULL,NULL,NULL,'2026-03-30 02:27:17.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-30 02:27:17.000','2026-03-30 02:27:17.000'),(23,1,1,'web-mnckir5y-t60qmm-55fz6l','text','test',NULL,NULL,NULL,'2026-03-30 02:27:45.000',NULL,NULL,NULL,NULL,'sent',0,NULL,'2026-03-30 02:27:45.000','2026-03-30 02:27:45.000');
/*!40000 ALTER TABLE `messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=18 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000001_create_cache_table',1),(2,'0001_01_01_000002_create_jobs_table',1),(3,'2026_03_24_000000_create_users_table',1),(4,'2026_03_24_151235_create_sessions_table',2),(5,'2026_03_24_162053_create_user_devices_table',3),(6,'2026_03_25_042349_create_personal_access_tokens_table',4),(7,'2026_03_26_000000_create_conversations_table',5),(8,'2026_03_26_000001_create_direct_conversation_keys_table',5),(9,'2026_03_26_000002_create_conversation_participants_table',5),(10,'2026_03_26_000003_create_messages_table',5),(11,'2026_03_26_000004_add_conversation_last_message_fk',5),(12,'2026_03_26_000005_create_message_attachments_table',5),(13,'2026_03_26_000006_create_message_reactions_table',5),(14,'2026_03_26_000007_create_user_privacy_settings_table',6),(15,'2026_03_26_000008_create_user_blocks_table',6),(16,'2026_03_26_000009_create_friend_requests_table',6),(17,'2026_03_26_000010_create_friendships_table',6);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (2,'App\\Models\\User',1,'auth_token','ed7fa1835ac5a9505a10c4b14e814211bdff28f1c9a49e7f2efde4c13d852304','[\"*\"]','2026-03-25 00:57:38',NULL,'2026-03-24 21:40:09','2026-03-25 00:57:38'),(4,'App\\Models\\User',2,'auth_token','b80ff01d25a4fda837f3f1a60efc04f8854b098ed8ebead2167e83e74be5de15','[\"*\"]','2026-03-27 00:26:32',NULL,'2026-03-27 00:05:27','2026-03-27 00:26:32'),(5,'App\\Models\\User',3,'auth_token','0fb03270f186a5d0dadd9caecd9cbd050aed12af513266778e0ad55258849fa4','[\"*\"]','2026-03-27 00:27:05',NULL,'2026-03-27 00:17:18','2026-03-27 00:27:05'),(6,'App\\Models\\User',1,'auth_token','da34041a6c573d489dd0ac7763774a7841f523f389683cf94f3ce8f35d485342','[\"*\"]','2026-03-29 19:27:54',NULL,'2026-03-29 19:25:08','2026-03-29 19:27:54'),(7,'App\\Models\\User',2,'auth_token','202f507cdf3d3fe35fe4abdf00c3e17a9c2da9b8365c6b3a2320253efc3e52d8','[\"*\"]','2026-03-29 19:28:46',NULL,'2026-03-29 19:26:51','2026-03-29 19:28:46'),(8,'App\\Models\\User',1,'auth_token','6b31e978300c51ed3fabab223b56e15c918729f869ab7e16bed1007bec3d7d2c','[\"*\"]','2026-04-02 00:22:25',NULL,'2026-03-31 19:19:27','2026-04-02 00:22:25'),(9,'App\\Models\\User',1,'auth_token','39411385e77e72e361b67dbc6218fe7075ab9dabf1f94a2ff9d027288c3d7818','[\"*\"]',NULL,NULL,'2026-03-31 19:21:24','2026-03-31 19:21:24'),(10,'App\\Models\\User',1,'auth_token','9cbf45718b98b2eef1899a4de61fcd99cd3612eb36788d4f67509dded27e8042','[\"*\"]',NULL,NULL,'2026-03-31 19:22:24','2026-03-31 19:22:24'),(11,'App\\Models\\User',1,'auth_token','ad18c3d28f757a7e84487d8f4a020386d2d169a1a023ca726e97ff80c8495898','[\"*\"]',NULL,NULL,'2026-03-31 19:25:27','2026-03-31 19:25:27'),(12,'App\\Models\\User',1,'auth_token','c16835b8a39925d6509f00448e1781b599bff27a50e6326e9cc397c1dce6c8a5','[\"*\"]',NULL,NULL,'2026-03-31 19:30:53','2026-03-31 19:30:53'),(13,'App\\Models\\User',1,'auth_token','642f4126415fbd5a6cae387d5cc3fce1e5c6e180e5cdf43e768fd60a72c7cd44','[\"*\"]',NULL,NULL,'2026-03-31 19:58:16','2026-03-31 19:58:16'),(14,'App\\Models\\User',1,'auth_token','f346f86b6ede737e4ba3f03427acbaa964736b6e2eccf5b490d099d5e226921a','[\"*\"]',NULL,NULL,'2026-03-31 20:06:56','2026-03-31 20:06:56'),(15,'App\\Models\\User',1,'auth_token','fada2fe99337f892003381946a88be8f7053d07c1b411a0d04faa00b3541c562','[\"*\"]',NULL,NULL,'2026-04-01 07:20:33','2026-04-01 07:20:33'),(16,'App\\Models\\User',1,'auth_token','f46eb2bff5fb7ef394fb3b38d4b59e4f4faf2ca5eb4b4a16eeea4144286a318d','[\"*\"]',NULL,NULL,'2026-04-01 07:27:12','2026-04-01 07:27:12'),(17,'App\\Models\\User',1,'auth_token','67c3523c204a8abc80b886edbe26189d5f5c17fb374bef84d396a55dac87c515','[\"*\"]',NULL,NULL,'2026-04-01 07:40:52','2026-04-01 07:40:52'),(18,'App\\Models\\User',1,'auth_token','f5ff850237a8515c04b3a5cf5df14a12177e9d19bab456d23c5a3caf15b1895d','[\"*\"]','2026-04-01 07:52:49',NULL,'2026-04-01 07:44:50','2026-04-01 07:52:49');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sessions`
--

DROP TABLE IF EXISTS `sessions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `sessions` (
  `id` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` bigint unsigned DEFAULT NULL,
  `ip_address` varchar(45) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `user_agent` text COLLATE utf8mb4_unicode_ci,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `last_activity` int NOT NULL,
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
INSERT INTO `sessions` VALUES ('2NpdgBePdPRP5MqMcn1D6uLGlKiCQgUmK4nzbpc9',NULL,'192.168.1.200','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJabWRaMVNOWmxCcFhPd1haYmZvc04zWUhndnIzWExuYTZUMWlpQWtqIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzE5Mi4xNjguMS4yMDA6ODAwMFwvbWFpbiIsInJvdXRlIjoibWFpbiJ9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19',1774837611),('CGpm9s1ZBjNTtl7hG2rzBiXpOoDJjGLZ2RP8TtJO',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJmNFhKc1J1ZWd1YzE1V3d1RTd1MU9Ockx6bDVNTTM2RG5IM0llanpHIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzAuMC4wLjA6ODAwMFwvbWFpbiIsInJvdXRlIjoibWFpbiJ9LCJfZmxhc2giOnsib2xkIjpbXSwibmV3IjpbXX19',1774837508),('Cpf8ffDN47GxYMnQTZc3s6mfGKPXpSj5petb5SJS',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','eyJfdG9rZW4iOiJ0ZVJKYnRCWFNONTNQUXMxNzE1a3hJMW5VM0NaemF6bnNvWlJLOTVMIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9tYWluIiwicm91dGUiOiJtYWluIn0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfX0=',1774681735),('GI20NLyiVBXNLYhF4u1wniQPzO4mh8qBlFJajDJf',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','eyJfdG9rZW4iOiI3Y2kxWFlyU01QUXJPSDJzRVZBZDJWcnk1ZjNmS3VjNnR5RVhpcDd1IiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9tYWluIiwicm91dGUiOiJtYWluIn0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfX0=',1775114544),('JzVgCkYPX0p0r7CFy8eI0TtR0hFzYc8ehMzLCgxr',NULL,'127.0.0.1','Dart/3.11 (dart:io)','eyJfdG9rZW4iOiJ6TjhOajhyZW9FSjc3NE5xQWZkbDBoRWtWVTlEbmlUaFJSTlJLTDdEIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==',1775053634),('lfLr1q0vwRomyJhLDcABiWXjbLe24iylb2oGd5AS',NULL,'127.0.0.1','Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36','eyJfdG9rZW4iOiIySGtwRlZKOXFTc0Y1M3o3bGFDODREQko5WGVnbFZoUXUwYlpFbWhkIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9tYWluIiwicm91dGUiOiJtYWluIn0sIl9mbGFzaCI6eyJvbGQiOltdLCJuZXciOltdfX0=',1775009967),('uWd0Ls3Va8cIbKu5W1eobJ5NfSFkxsBtB21xWDRe',NULL,'127.0.0.1','Dart/3.11 (dart:io)','eyJfdG9rZW4iOiIybHlYN2hkTEd1UmpsUWJVeGd1ZzJZcHpQY3c2dHlXcUk3WFc3ZFNCIiwiX3ByZXZpb3VzIjp7InVybCI6Imh0dHA6XC9cLzEyNy4wLjAuMTo4MDAwXC9sb2dpbiIsInJvdXRlIjoibG9naW4ifSwiX2ZsYXNoIjp7Im9sZCI6W10sIm5ldyI6W119fQ==',1775053494);
/*!40000 ALTER TABLE `sessions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_blocks`
--

DROP TABLE IF EXISTS `user_blocks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_blocks` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `blocker_id` bigint unsigned NOT NULL,
  `blocked_id` bigint unsigned NOT NULL,
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_user_blocks_pair` (`blocker_id`,`blocked_id`),
  KEY `idx_user_blocks_blocked` (`blocked_id`),
  CONSTRAINT `fk_user_blocks_blocked` FOREIGN KEY (`blocked_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  CONSTRAINT `fk_user_blocks_blocker` FOREIGN KEY (`blocker_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_blocks`
--

LOCK TABLES `user_blocks` WRITE;
/*!40000 ALTER TABLE `user_blocks` DISABLE KEYS */;
/*!40000 ALTER TABLE `user_blocks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `user_devices`
--

DROP TABLE IF EXISTS `user_devices`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_devices` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`)
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
-- Table structure for table `user_privacy_settings`
--

DROP TABLE IF EXISTS `user_privacy_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `user_privacy_settings` (
  `user_id` bigint unsigned NOT NULL,
  `allow_find_by_phone` tinyint(1) NOT NULL DEFAULT '1',
  `allow_friend_request` tinyint(1) NOT NULL DEFAULT '1',
  `auto_accept_contacts` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  PRIMARY KEY (`user_id`),
  CONSTRAINT `fk_ups_user` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `user_privacy_settings`
--

LOCK TABLES `user_privacy_settings` WRITE;
/*!40000 ALTER TABLE `user_privacy_settings` DISABLE KEYS */;
INSERT INTO `user_privacy_settings` VALUES (1,1,1,0,'2026-03-27 07:05:39.000','2026-03-27 07:05:39.000'),(2,1,1,0,'2026-03-27 07:05:27.000','2026-03-27 07:05:27.000'),(3,1,1,0,'2026-03-27 07:17:18.000','2026-03-27 07:17:18.000');
/*!40000 ALTER TABLE `user_privacy_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `phone_number` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `username` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `display_name` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password_hash` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `avatar_url` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `bio` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `birth_date` date DEFAULT NULL,
  `gender` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `account_status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'active',
  `presence_status` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'offline',
  `last_seen_at` datetime(3) DEFAULT NULL,
  `is_phone_verified` tinyint(1) NOT NULL DEFAULT '0',
  `is_email_verified` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
  `updated_at` datetime(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3) ON UPDATE CURRENT_TIMESTAMP(3),
  `deleted_at` datetime(3) DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_phone_number_unique` (`phone_number`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_username_unique` (`username`),
  KEY `users_account_status_index` (`account_status`),
  KEY `users_presence_status_index` (`presence_status`),
  KEY `users_last_seen_at_index` (`last_seen_at`),
  KEY `users_deleted_at_index` (`deleted_at`),
  CONSTRAINT `chk_users_account_status` CHECK ((`account_status` in (_utf8mb4'active',_utf8mb4'suspended',_utf8mb4'deleted'))),
  CONSTRAINT `chk_users_presence_status` CHECK ((`presence_status` in (_utf8mb4'online',_utf8mb4'offline',_utf8mb4'away',_utf8mb4'busy')))
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'0865770527',NULL,'quanghoang2004','quanghoang2004','$2y$12$OWT9DY.8tB8JWzTZK2oB9.NfzT9KmWnixKfhgRZSzEtpgWv46tbfW','https://i.pinimg.com/736x/a9/91/82/a991827a5ecb2f02ba52e733bdd1e2ea.jpg',NULL,'2004-11-21','male','active','offline','2026-04-01 14:44:50.000',0,0,'2026-03-25 04:35:24.000','2026-04-01 14:44:50.000',NULL),(2,'0896506413',NULL,'Minh Hoang','Minh Hoang','$2y$12$U4TI04b9xzSFhzd6zKFli.AWEAPxVBr/TTKjWUskvs9VVqRLikL7S',NULL,NULL,'2004-03-27','male','active','offline','2026-03-30 02:26:51.000',0,0,'2026-03-27 07:05:27.000','2026-03-30 02:26:51.000',NULL),(3,'0865619203',NULL,'tuan','tuan','$2y$12$hFkIvmDRosKq.ZZizhFEZOfLnU1G3P5IRbGagSN.aCW6VAolY2BzC',NULL,NULL,'2026-03-26','male','active','offline',NULL,0,0,'2026-03-27 07:17:18.000','2026-03-27 07:17:18.000',NULL);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
SET @@SESSION.SQL_LOG_BIN = @MYSQLDUMP_TEMP_LOG_BIN;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-02 15:08:31
