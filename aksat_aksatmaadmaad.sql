-- phpMyAdmin SQL Dump
-- version 5.2.3
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Sep 19, 2026 at 09:34 PM
-- Server version: 10.11.19-MariaDB
-- PHP Version: 8.4.25

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `aksat_aksatmaadmaad`
--

-- --------------------------------------------------------

--
-- Table structure for table `customers`
--

CREATE TABLE `customers` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `address` text DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `customers`
--

INSERT INTO `customers` (`id`, `user_id`, `name`, `phone`, `address`, `notes`, `created_at`, `updated_at`) VALUES
(1, 3, 'نامق علي ', '07705443223', '', NULL, '2026-08-26 21:29:01', '2026-08-26 21:29:01'),
(4, 5, 'احمد علي', '07714992467', 'الساعي', NULL, '2026-08-27 22:45:32', '2026-08-27 22:45:32'),
(6, 2, 'سميع', '077044433332', '', NULL, '2026-08-29 18:22:01', '2026-08-29 18:22:01'),
(7, 2, 'كريم', '07704443332', '', NULL, '2026-08-29 19:51:39', '2026-08-29 19:51:39'),
(8, 2, 'ياسين', '07765443445', '', NULL, '2026-08-29 19:52:16', '2026-08-29 19:52:16'),
(9, 2, 'لميس', '07785225441', '', NULL, '2026-08-30 00:40:01', '2026-08-30 00:40:01'),
(10, 2, 'محمد زياد', '0770000000', '', NULL, '2026-09-01 21:47:12', '2026-09-01 21:47:12'),
(11, 2, 'وليد ', '07708888552', '', NULL, '2026-09-01 21:52:34', '2026-09-01 21:52:34'),
(12, 2, 'حسين جاسم', '07705886995', '', NULL, '2026-09-02 05:29:38', '2026-09-02 05:29:38'),
(13, 14, 'احمد ', '0777777777', 'البصره', NULL, '2026-09-02 21:59:08', '2026-09-02 21:59:08'),
(14, 14, 'محمد علي', '0788888888888', 'التنومه', NULL, '2026-09-02 22:02:19', '2026-09-02 22:02:19'),
(15, 14, 'جاسم', '78000000000000', 'الجزائر', NULL, '2026-09-02 22:05:05', '2026-09-02 22:05:05'),
(16, 16, 'محمد علي', '0788888888', 'البصرة', NULL, '2026-09-02 23:10:44', '2026-09-02 23:10:44'),
(17, 21, 'عبدالرحمن', '07718419585', 'دهوك', NULL, '2026-09-04 10:10:42', '2026-09-04 10:10:42'),
(18, 23, 'محمد عطيه', '07807822866', '', NULL, '2026-09-04 21:36:02', '2026-09-04 21:36:02'),
(19, 2, 'هاشم سعيد', '077777777', '', NULL, '2026-09-05 00:00:32', '2026-09-05 00:00:32'),
(20, 25, 'علي', '08888554213', 'بصرة', NULL, '2026-09-11 17:02:56', '2026-09-11 17:02:56'),
(21, 24, 'حسين علي', '+9647714992467', 'البصرة', NULL, '2026-09-11 19:42:34', '2026-09-11 19:42:34'),
(22, 24, 'محمد', '+9647714992467', 'البصرة', NULL, '2026-09-11 19:49:46', '2026-09-11 19:49:46');

-- --------------------------------------------------------

--
-- Table structure for table `installments`
--

CREATE TABLE `installments` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `sale_id` int(11) NOT NULL,
  `installment_number` int(11) NOT NULL,
  `amount` decimal(15,2) NOT NULL,
  `paid_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `due_date` date NOT NULL,
  `paid_date` date DEFAULT NULL,
  `status` enum('pending','paid','late') DEFAULT 'pending',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `installments`
--

INSERT INTO `installments` (`id`, `user_id`, `sale_id`, `installment_number`, `amount`, `paid_amount`, `due_date`, `paid_date`, `status`, `notes`, `created_at`) VALUES
(1, 3, 1, 1, 0.03, 0.00, '2026-09-26', NULL, 'pending', NULL, '2026-08-26 21:29:03'),
(2, 3, 1, 2, 0.03, 0.00, '2026-10-26', NULL, 'pending', NULL, '2026-08-26 21:29:03'),
(9, 5, 4, 1, 37500.00, 37500.00, '2026-09-27', '2026-08-27', 'paid', NULL, '2026-08-27 22:45:32'),
(10, 5, 4, 2, 37500.00, 0.00, '2026-10-27', NULL, 'pending', NULL, '2026-08-27 22:45:32'),
(11, 5, 4, 3, 37500.00, 0.00, '2026-11-27', NULL, 'pending', NULL, '2026-08-27 22:45:32'),
(12, 5, 4, 4, 37500.00, 0.00, '2026-12-27', NULL, 'pending', NULL, '2026-08-27 22:45:32'),
(16, 2, 6, 1, 2000.00, 0.00, '2026-09-29', NULL, 'pending', NULL, '2026-08-29 18:22:01'),
(17, 2, 7, 1, 2000.00, 0.00, '2026-09-29', NULL, 'pending', NULL, '2026-08-29 19:51:39'),
(18, 2, 8, 1, 2000.00, 0.00, '2026-09-29', NULL, 'pending', NULL, '2026-08-29 19:52:16'),
(19, 2, 9, 1, 500.00, 0.00, '2026-09-30', NULL, 'pending', NULL, '2026-08-30 00:40:01'),
(20, 2, 9, 2, 500.00, 0.00, '2026-10-30', NULL, 'pending', NULL, '2026-08-30 00:40:01'),
(21, 2, 9, 3, 500.00, 0.00, '2026-11-30', NULL, 'pending', NULL, '2026-08-30 00:40:01'),
(22, 2, 9, 4, 500.00, 0.00, '2026-12-30', NULL, 'pending', NULL, '2026-08-30 00:40:01'),
(23, 2, 10, 1, 50000.00, 0.00, '2026-10-01', NULL, 'pending', NULL, '2026-08-31 19:20:37'),
(24, 2, 10, 2, 50000.00, 0.00, '2026-11-01', NULL, 'pending', NULL, '2026-08-31 19:20:37'),
(25, 2, 10, 3, 50000.00, 0.00, '2026-12-01', NULL, 'pending', NULL, '2026-08-31 19:20:37'),
(26, 2, 10, 4, 50000.00, 0.00, '2027-01-01', NULL, 'pending', NULL, '2026-08-31 19:20:37'),
(27, 2, 10, 5, 50000.00, 0.00, '2027-02-01', NULL, 'pending', NULL, '2026-08-31 19:20:37'),
(28, 2, 11, 1, 48000.00, 0.00, '2026-10-01', NULL, 'pending', NULL, '2026-09-01 21:47:12'),
(29, 2, 11, 2, 48000.00, 0.00, '2026-11-01', NULL, 'pending', NULL, '2026-09-01 21:47:12'),
(30, 2, 11, 3, 48000.00, 0.00, '2026-12-01', NULL, 'pending', NULL, '2026-09-01 21:47:12'),
(31, 2, 11, 4, 48000.00, 0.00, '2027-01-01', NULL, 'pending', NULL, '2026-09-01 21:47:12'),
(32, 2, 11, 5, 48000.00, 0.00, '2027-02-01', NULL, 'pending', NULL, '2026-09-01 21:47:12'),
(33, 2, 12, 1, 68000.00, 0.00, '2026-10-01', NULL, 'pending', NULL, '2026-09-01 21:52:34'),
(34, 2, 12, 2, 68000.00, 0.00, '2026-11-01', NULL, 'pending', NULL, '2026-09-01 21:52:34'),
(35, 2, 12, 3, 68000.00, 0.00, '2026-12-01', NULL, 'pending', NULL, '2026-09-01 21:52:34'),
(36, 2, 12, 4, 68000.00, 0.00, '2027-01-01', NULL, 'pending', NULL, '2026-09-01 21:52:34'),
(37, 2, 12, 5, 68000.00, 0.00, '2027-02-01', NULL, 'pending', NULL, '2026-09-01 21:52:34'),
(38, 2, 13, 1, 12500.00, 0.00, '2026-10-02', NULL, 'pending', NULL, '2026-09-02 05:29:38'),
(39, 2, 13, 2, 12500.00, 0.00, '2026-11-02', NULL, 'pending', NULL, '2026-09-02 05:29:38'),
(40, 2, 13, 3, 12500.00, 0.00, '2026-12-02', NULL, 'pending', NULL, '2026-09-02 05:29:38'),
(41, 2, 13, 4, 12500.00, 0.00, '2027-01-02', NULL, 'pending', NULL, '2026-09-02 05:29:38'),
(42, 14, 14, 1, 20000.00, 20000.00, '2026-10-02', '2026-09-02', 'paid', NULL, '2026-09-02 21:59:08'),
(43, 14, 14, 2, 20000.00, 20000.00, '2026-11-02', '2026-09-02', 'paid', NULL, '2026-09-02 21:59:08'),
(44, 14, 14, 3, 20000.00, 20000.00, '2026-12-02', '2026-09-02', 'paid', NULL, '2026-09-02 21:59:08'),
(45, 14, 14, 4, 20000.00, 0.00, '2027-01-02', NULL, 'pending', NULL, '2026-09-02 21:59:08'),
(46, 14, 15, 1, 80000.00, 80000.00, '2026-10-02', '2026-09-02', 'paid', NULL, '2026-09-02 22:02:19'),
(47, 14, 16, 1, 50000.00, 50000.00, '2026-10-02', '2026-09-02', 'paid', NULL, '2026-09-02 22:05:05'),
(48, 14, 16, 2, 50000.00, 50000.00, '2026-11-02', '2026-09-02', 'paid', NULL, '2026-09-02 22:05:05'),
(49, 16, 17, 1, 125000.00, 125000.00, '2026-10-02', '2026-09-02', 'paid', NULL, '2026-09-02 23:10:44'),
(50, 16, 17, 2, 125000.00, 125000.00, '2026-11-02', '2026-09-02', 'paid', NULL, '2026-09-02 23:10:44'),
(51, 21, 18, 1, 350.00, 350.00, '2026-10-04', '2026-09-04', 'paid', NULL, '2026-09-04 10:10:42'),
(52, 21, 18, 2, 350.00, 0.00, '2026-11-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(53, 21, 18, 3, 350.00, 0.00, '2026-12-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(54, 21, 18, 4, 350.00, 0.00, '2027-01-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(55, 21, 18, 5, 350.00, 0.00, '2027-02-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(56, 21, 18, 6, 350.00, 0.00, '2027-03-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(57, 21, 18, 7, 350.00, 0.00, '2027-04-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(58, 21, 18, 8, 350.00, 0.00, '2027-05-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(59, 21, 18, 9, 350.00, 0.00, '2027-06-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(60, 21, 18, 10, 350.00, 0.00, '2027-07-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(61, 21, 18, 11, 350.00, 0.00, '2027-08-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(62, 21, 18, 12, 350.00, 0.00, '2027-09-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(63, 21, 18, 13, 350.00, 0.00, '2027-10-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(64, 21, 18, 14, 350.00, 0.00, '2027-11-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(65, 21, 18, 15, 350.00, 0.00, '2027-12-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(66, 21, 18, 16, 350.00, 0.00, '2028-01-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(67, 21, 18, 17, 350.00, 0.00, '2028-02-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(68, 21, 18, 18, 350.00, 0.00, '2028-03-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(69, 21, 18, 19, 350.00, 0.00, '2028-04-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(70, 21, 18, 20, 350.00, 0.00, '2028-05-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(71, 21, 18, 21, 350.00, 0.00, '2028-06-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(72, 21, 18, 22, 350.00, 0.00, '2028-07-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(73, 21, 18, 23, 350.00, 0.00, '2028-08-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(74, 21, 18, 24, 350.00, 0.00, '2028-09-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(75, 21, 18, 25, 350.00, 0.00, '2028-10-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(76, 21, 18, 26, 350.00, 0.00, '2028-11-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(77, 21, 18, 27, 350.00, 0.00, '2028-12-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(78, 21, 18, 28, 350.00, 0.00, '2029-01-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(79, 21, 18, 29, 350.00, 0.00, '2029-02-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(80, 21, 18, 30, 350.00, 0.00, '2029-03-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(81, 21, 18, 31, 350.00, 0.00, '2029-04-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(82, 21, 18, 32, 350.00, 0.00, '2029-05-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(83, 21, 18, 33, 350.00, 0.00, '2029-06-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(84, 21, 18, 34, 350.00, 0.00, '2029-07-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(85, 21, 18, 35, 350.00, 0.00, '2029-08-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(86, 21, 18, 36, 350.00, 0.00, '2029-09-04', NULL, 'pending', NULL, '2026-09-04 10:10:42'),
(87, 23, 19, 1, 50000.00, 50000.00, '2026-10-04', '2026-09-04', 'paid', NULL, '2026-09-04 21:36:03'),
(88, 23, 19, 2, 50000.00, 50000.00, '2026-11-04', '2026-09-04', 'paid', NULL, '2026-09-04 21:36:03'),
(89, 23, 19, 3, 50000.00, 0.00, '2026-12-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(90, 23, 19, 4, 50000.00, 0.00, '2027-01-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(91, 23, 19, 5, 50000.00, 0.00, '2027-02-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(92, 23, 19, 6, 50000.00, 0.00, '2027-03-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(93, 23, 19, 7, 50000.00, 0.00, '2027-04-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(94, 23, 19, 8, 50000.00, 0.00, '2027-05-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(95, 23, 19, 9, 50000.00, 0.00, '2027-06-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(96, 23, 19, 10, 50000.00, 0.00, '2027-07-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(97, 23, 19, 11, 50000.00, 0.00, '2027-08-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(98, 23, 19, 12, 50000.00, 0.00, '2027-09-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(99, 23, 19, 13, 50000.00, 0.00, '2027-10-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(100, 23, 19, 14, 50000.00, 0.00, '2027-11-04', NULL, 'pending', NULL, '2026-09-04 21:36:03'),
(101, 2, 20, 1, 200000.00, 0.00, '2026-10-04', NULL, 'pending', NULL, '2026-09-04 23:58:50'),
(102, 2, 20, 2, 200000.00, 0.00, '2026-11-04', NULL, 'pending', NULL, '2026-09-04 23:58:50'),
(103, 2, 20, 3, 200000.00, 0.00, '2026-12-04', NULL, 'pending', NULL, '2026-09-04 23:58:50'),
(104, 2, 20, 4, 200000.00, 0.00, '2027-01-04', NULL, 'pending', NULL, '2026-09-04 23:58:50'),
(105, 2, 21, 1, 25000.00, 0.00, '2026-10-04', NULL, 'pending', NULL, '2026-09-05 00:00:32'),
(106, 2, 21, 2, 25000.00, 0.00, '2026-11-04', NULL, 'pending', NULL, '2026-09-05 00:00:32'),
(107, 2, 22, 1, 100000.00, 0.00, '2026-09-15', NULL, 'late', NULL, '2026-09-08 08:11:10'),
(108, 2, 22, 2, 100000.00, 0.00, '2026-09-22', NULL, 'pending', NULL, '2026-09-08 08:11:10'),
(109, 2, 22, 3, 100000.00, 0.00, '2026-09-29', NULL, 'pending', NULL, '2026-09-08 08:11:10'),
(110, 2, 22, 4, 100000.00, 0.00, '2026-10-06', NULL, 'pending', NULL, '2026-09-08 08:11:10'),
(111, 2, 23, 1, 10000.00, 0.00, '2026-10-09', NULL, 'pending', NULL, '2026-09-09 17:42:16'),
(112, 2, 23, 2, 10000.00, 0.00, '2026-11-09', NULL, 'pending', NULL, '2026-09-09 17:42:16'),
(113, 2, 23, 3, 10000.00, 0.00, '2026-12-09', NULL, 'pending', NULL, '2026-09-09 17:42:16'),
(114, 2, 23, 4, 10000.00, 0.00, '2027-01-09', NULL, 'pending', NULL, '2026-09-09 17:42:16'),
(115, 2, 24, 1, 100000.00, 0.00, '2026-10-11', NULL, 'pending', NULL, '2026-09-11 16:50:04'),
(116, 2, 24, 2, 100000.00, 0.00, '2026-11-11', NULL, 'pending', NULL, '2026-09-11 16:50:04'),
(117, 2, 24, 3, 100000.00, 0.00, '2026-12-11', NULL, 'pending', NULL, '2026-09-11 16:50:04'),
(118, 25, 25, 1, 100000.00, 0.00, '2026-10-11', NULL, 'pending', NULL, '2026-09-11 17:02:56'),
(119, 24, 26, 1, 50000.00, 0.00, '2026-10-11', '2026-09-11', 'paid', NULL, '2026-09-11 19:42:35'),
(120, 24, 26, 2, 50000.00, 0.00, '2026-11-11', '2026-09-11', 'paid', NULL, '2026-09-11 19:42:35'),
(121, 24, 26, 3, 50000.00, 0.00, '2026-12-11', NULL, 'pending', NULL, '2026-09-11 19:42:35'),
(122, 24, 27, 1, 50000.00, 0.00, '2026-10-11', '2026-09-11', 'paid', NULL, '2026-09-11 19:49:47'),
(123, 24, 27, 2, 50000.00, 0.00, '2026-11-11', '2026-09-11', 'paid', NULL, '2026-09-11 19:49:47'),
(124, 24, 27, 3, 50000.00, 0.00, '2026-12-11', '2026-09-11', 'paid', NULL, '2026-09-11 19:49:47');

-- --------------------------------------------------------

--
-- Table structure for table `inventory`
--

CREATE TABLE `inventory` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 0,
  `low_stock_threshold` int(11) NOT NULL DEFAULT 3,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inventory`
--

INSERT INTO `inventory` (`id`, `user_id`, `product_id`, `quantity`, `low_stock_threshold`, `notes`, `created_at`, `updated_at`) VALUES
(2, 3, 1, 0, 3, '', '2026-08-25 06:37:56', '2026-08-26 21:29:03'),
(5, 5, 4, 20, 3, '', '2026-08-27 22:53:42', '2026-08-27 22:53:42'),
(6, 2, 5, 9, 3, '', '2026-08-29 18:21:35', '2026-08-30 00:40:01'),
(7, 2, 6, 18, 3, '', '2026-08-30 19:22:46', '2026-09-01 21:47:12'),
(8, 2, 7, 10, 3, '', '2026-09-01 21:45:31', '2026-09-01 21:45:31'),
(9, 2, 8, 20, 5, '', '2026-09-01 21:53:55', '2026-09-01 21:53:55'),
(10, 2, 9, 19, 5, '', '2026-09-02 05:28:16', '2026-09-02 05:29:38'),
(11, 2, 10, 9, 2, '', '2026-09-02 05:43:52', '2026-09-11 16:50:04'),
(12, 14, 11, 8, 3, '', '2026-09-02 22:04:10', '2026-09-02 22:05:05'),
(13, 16, 12, 8, 3, '', '2026-09-02 23:09:26', '2026-09-02 23:10:44'),
(15, 23, 15, 19, 3, '', '2026-09-04 21:34:37', '2026-09-04 21:36:03'),
(16, 2, 16, 24, 2, '', '2026-09-04 23:56:59', '2026-09-04 23:58:50'),
(17, 2, 20, 29, 2, '', '2026-09-08 08:09:39', '2026-09-08 08:11:10'),
(18, 24, 21, 18, 3, '', '2026-09-11 16:10:04', '2026-09-11 19:49:47'),
(19, 25, 22, 9, 3, '', '2026-09-11 17:02:17', '2026-09-11 17:02:56');

-- --------------------------------------------------------

--
-- Table structure for table `inventory_movements`
--

CREATE TABLE `inventory_movements` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `movement_type` enum('add','subtract','return','adjustment') NOT NULL,
  `quantity` int(11) NOT NULL,
  `sale_id` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `inventory_movements`
--

INSERT INTO `inventory_movements` (`id`, `user_id`, `product_id`, `movement_type`, `quantity`, `sale_id`, `notes`, `created_at`) VALUES
(1, 3, 1, 'add', 1, NULL, '', '2026-08-25 06:37:56'),
(2, 3, 1, 'subtract', 1, 1, 'بيع رقم 1', '2026-08-26 21:29:03'),
(7, 5, 4, 'add', 20, NULL, '', '2026-08-27 22:53:42'),
(10, 2, 5, 'add', 13, NULL, '', '2026-08-29 18:21:35'),
(11, 2, 5, 'subtract', 1, 6, 'بيع رقم 6', '2026-08-29 18:22:01'),
(12, 2, 5, 'subtract', 1, 7, 'بيع رقم 7', '2026-08-29 19:51:39'),
(13, 2, 5, 'subtract', 1, 8, 'بيع رقم 8', '2026-08-29 19:52:16'),
(14, 2, 5, 'subtract', 1, 9, 'بيع رقم 9', '2026-08-30 00:40:01'),
(15, 2, 6, 'add', 20, NULL, '', '2026-08-30 19:22:46'),
(16, 2, 6, 'subtract', 1, 10, 'بيع رقم 10', '2026-08-31 19:20:37'),
(17, 2, 7, 'add', 10, NULL, '', '2026-09-01 21:45:31'),
(18, 2, 6, 'subtract', 1, 11, 'بيع رقم 11', '2026-09-01 21:47:12'),
(19, 2, 8, 'add', 20, NULL, '', '2026-09-01 21:53:55'),
(20, 2, 9, 'add', 20, NULL, '', '2026-09-02 05:28:16'),
(21, 2, 9, 'subtract', 1, 13, 'بيع رقم 13', '2026-09-02 05:29:38'),
(22, 2, 10, 'add', 10, NULL, '', '2026-09-02 05:43:52'),
(23, 14, 11, 'add', 10, NULL, '', '2026-09-02 22:04:10'),
(24, 14, 11, 'subtract', 2, 16, 'بيع رقم 16', '2026-09-02 22:05:05'),
(25, 16, 12, 'add', 10, NULL, '', '2026-09-02 23:09:26'),
(26, 16, 12, 'subtract', 2, 17, 'بيع رقم 17', '2026-09-02 23:10:44'),
(27, 23, 15, 'add', 20, NULL, '\n', '2026-09-04 21:34:04'),
(28, 23, 15, 'add', 20, NULL, '', '2026-09-04 21:34:37'),
(29, 23, 15, 'subtract', 1, 19, 'بيع رقم 19', '2026-09-04 21:36:03'),
(30, 2, 16, 'add', 25, NULL, '', '2026-09-04 23:56:59'),
(31, 2, 16, 'subtract', 1, 20, 'بيع رقم 20', '2026-09-04 23:58:50'),
(32, 2, 20, 'add', 30, NULL, '', '2026-09-08 08:09:39'),
(33, 2, 20, 'subtract', 1, 22, 'بيع رقم 22', '2026-09-08 08:11:10'),
(34, 24, 21, 'add', 20, NULL, '', '2026-09-11 16:10:04'),
(35, 2, 10, 'subtract', 1, 24, 'بيع رقم 24', '2026-09-11 16:50:04'),
(36, 25, 22, 'add', 10, NULL, '', '2026-09-11 17:02:17'),
(37, 25, 22, 'subtract', 1, 25, 'بيع رقم 25', '2026-09-11 17:02:56'),
(38, 24, 21, 'subtract', 1, 26, 'بيع رقم 26', '2026-09-11 19:42:35'),
(39, 24, 21, 'subtract', 1, 27, 'بيع رقم 27', '2026-09-11 19:49:47');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `cost_price` decimal(15,2) NOT NULL DEFAULT 0.00,
  `price` decimal(15,2) NOT NULL,
  `currency` enum('USD','LOCAL') NOT NULL DEFAULT 'LOCAL',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `user_id`, `name`, `cost_price`, `price`, `currency`, `notes`, `created_at`, `updated_at`) VALUES
(1, 3, 'ثلاجة', 0.05, 0.06, 'LOCAL', '', '2026-08-25 06:25:32', '2026-08-25 06:25:32'),
(4, 5, 'شاشة LG', 150000.00, 200000.00, 'LOCAL', NULL, '2026-08-27 22:42:11', '2026-08-27 22:42:11'),
(5, 2, 'ثلاجة', 1000.00, 2000.00, 'LOCAL', NULL, '2026-08-29 18:21:23', '2026-08-29 18:21:23'),
(6, 2, 'مجمده 25', 200000.00, 250000.00, 'LOCAL', NULL, '2026-08-30 19:22:24', '2026-08-31 00:14:36'),
(7, 2, 'مروحه', 25000.00, 30000.00, 'LOCAL', NULL, '2026-09-01 21:44:57', '2026-09-01 21:44:57'),
(8, 2, 'غساله', 300000.00, 350000.00, 'LOCAL', NULL, '2026-09-01 21:51:32', '2026-09-01 21:51:32'),
(9, 2, 'مكنسه كهربائيه', 50000.00, 60000.00, 'LOCAL', NULL, '2026-09-02 05:27:26', '2026-09-02 05:27:26'),
(10, 2, 'مجمده lg', 250000.00, 300000.00, 'LOCAL', NULL, '2026-09-02 05:43:23', '2026-09-02 05:43:23'),
(11, 14, 'شاشه', 60000.00, 80000.00, 'LOCAL', NULL, '2026-09-02 21:58:11', '2026-09-02 21:58:11'),
(12, 16, 'شاشة', 100000.00, 150000.00, 'LOCAL', NULL, '2026-09-02 23:08:43', '2026-09-02 23:08:43'),
(13, 16, 'تيست', 1000.00, 2000.00, 'LOCAL', NULL, '2026-09-03 21:54:21', '2026-09-03 21:54:21'),
(14, 21, 'سيارة 2025', 11600.00, 12600.00, 'USD', 'لايوجد', '2026-09-04 10:06:21', '2026-09-04 10:06:21'),
(15, 23, 'سبلت وستن 1.5 طن', 650000.00, 800000.00, 'LOCAL', NULL, '2026-09-04 21:32:22', '2026-09-04 21:32:22'),
(16, 2, 'سبلت lg 2 طن', 750000.00, 900000.00, 'LOCAL', NULL, '2026-09-04 23:54:48', '2026-09-04 23:54:48'),
(17, 2, 'مروحه سقفيه', 35000.00, 50000.00, 'LOCAL', NULL, '2026-09-04 23:55:28', '2026-09-04 23:55:28'),
(18, 2, 'موبايل ايفون 17', 700.00, 900.00, 'USD', NULL, '2026-09-04 23:56:14', '2026-09-04 23:56:14'),
(19, 2, 'كمبيوتر', 400000.00, 500000.00, 'LOCAL', NULL, '2026-09-08 08:06:36', '2026-09-08 08:06:36'),
(20, 2, 'موبايل كلاكسي', 400000.00, 500000.00, 'LOCAL', NULL, '2026-09-08 08:08:55', '2026-09-08 08:08:55'),
(21, 24, 'غسالة', 150000.00, 200000.00, 'LOCAL', NULL, '2026-09-11 16:09:42', '2026-09-11 16:09:42'),
(22, 25, 'شاشة', 100000.00, 150000.00, 'LOCAL', NULL, '2026-09-11 17:02:09', '2026-09-11 17:02:09');

-- --------------------------------------------------------

--
-- Table structure for table `sales`
--

CREATE TABLE `sales` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `customer_id` int(11) NOT NULL,
  `product_id` int(11) NOT NULL,
  `product_name` varchar(255) NOT NULL,
  `quantity` int(11) NOT NULL DEFAULT 1,
  `cost_price_at_sale` decimal(15,2) NOT NULL DEFAULT 0.00,
  `total_price` decimal(15,2) NOT NULL,
  `down_payment` decimal(15,2) DEFAULT 0.00,
  `remaining` decimal(15,2) NOT NULL,
  `installment_value` decimal(15,2) NOT NULL,
  `installments_count` int(11) NOT NULL,
  `installment_type` enum('weekly','monthly') NOT NULL,
  `currency` enum('USD','LOCAL') NOT NULL,
  `sale_date` date NOT NULL,
  `status` enum('active','completed') DEFAULT 'active',
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `sales`
--

INSERT INTO `sales` (`id`, `user_id`, `customer_id`, `product_id`, `product_name`, `quantity`, `cost_price_at_sale`, `total_price`, `down_payment`, `remaining`, `installment_value`, `installments_count`, `installment_type`, `currency`, `sale_date`, `status`, `notes`, `created_at`) VALUES
(1, 3, 1, 1, 'ثلاجة', 1, 0.05, 0.06, 0.00, 0.06, 0.03, 2, 'monthly', 'LOCAL', '2026-08-26', 'active', '', '2026-08-26 21:29:03'),
(4, 5, 4, 4, 'شاشة LG', 1, 150000.00, 200000.00, 50000.00, 150000.00, 37500.00, 4, 'monthly', 'LOCAL', '2026-08-27', 'active', '', '2026-08-27 22:45:32'),
(6, 2, 6, 5, 'ثلاجة', 1, 1000.00, 2000.00, 0.00, 2000.00, 2000.00, 1, 'monthly', 'LOCAL', '2026-08-29', 'active', '', '2026-08-29 18:22:01'),
(7, 2, 7, 5, 'ثلاجة', 1, 1000.00, 2000.00, 0.00, 2000.00, 2000.00, 1, 'monthly', 'LOCAL', '2026-08-29', 'active', '', '2026-08-29 19:51:39'),
(8, 2, 8, 5, 'ثلاجة', 1, 1000.00, 2000.00, 0.00, 2000.00, 2000.00, 1, 'monthly', 'LOCAL', '2026-08-29', 'active', '', '2026-08-29 19:52:16'),
(9, 2, 9, 5, 'ثلاجة', 1, 1000.00, 2000.00, 0.00, 2000.00, 500.00, 4, 'monthly', 'LOCAL', '2026-08-30', 'active', '', '2026-08-30 00:40:01'),
(10, 2, 9, 6, 'مجمده 25', 1, 200000.00, 250000.00, 0.00, 250000.00, 50000.00, 5, 'monthly', 'LOCAL', '2026-08-31', 'active', '', '2026-08-31 19:20:37'),
(11, 2, 10, 6, 'مجمده 25', 1, 200000.00, 250000.00, 10000.00, 240000.00, 48000.00, 5, 'monthly', 'LOCAL', '2026-09-01', 'active', '', '2026-09-01 21:47:12'),
(12, 2, 11, 8, 'غساله', 1, 300000.00, 350000.00, 10000.00, 340000.00, 68000.00, 5, 'monthly', 'LOCAL', '2026-09-01', 'active', '', '2026-09-01 21:52:34'),
(13, 2, 12, 9, 'مكنسه كهربائيه', 1, 50000.00, 60000.00, 10000.00, 50000.00, 12500.00, 4, 'monthly', 'LOCAL', '2026-09-02', 'active', '', '2026-09-02 05:29:38'),
(14, 14, 13, 11, 'شاشه', 1, 60000.00, 80000.00, 0.00, 80000.00, 20000.00, 4, 'monthly', 'LOCAL', '2026-09-02', 'active', '', '2026-09-02 21:59:08'),
(15, 14, 14, 11, 'شاشه', 1, 60000.00, 80000.00, 0.00, 80000.00, 80000.00, 1, 'monthly', 'LOCAL', '2026-09-02', 'completed', '', '2026-09-02 22:02:19'),
(16, 14, 15, 11, 'شاشه', 2, 60000.00, 160000.00, 60000.00, 100000.00, 50000.00, 2, 'monthly', 'LOCAL', '2026-09-02', 'completed', '', '2026-09-02 22:05:05'),
(17, 16, 16, 12, 'شاشة', 2, 100000.00, 300000.00, 50000.00, 250000.00, 125000.00, 2, 'monthly', 'LOCAL', '2026-09-02', 'completed', '', '2026-09-02 23:10:44'),
(18, 21, 17, 14, 'سيارة 2025', 1, 11600.00, 12600.00, 0.00, 12600.00, 350.00, 36, 'monthly', 'USD', '2026-09-04', 'active', '', '2026-09-04 10:10:42'),
(19, 23, 18, 15, 'سبلت وستن 1.5 طن', 1, 650000.00, 800000.00, 100000.00, 700000.00, 50000.00, 14, 'monthly', 'LOCAL', '2026-09-04', 'active', '', '2026-09-04 21:36:03'),
(20, 2, 12, 16, 'سبلت lg 2 طن', 1, 750000.00, 900000.00, 100000.00, 800000.00, 200000.00, 4, 'monthly', 'LOCAL', '2026-09-04', 'active', '', '2026-09-04 23:58:50'),
(21, 2, 19, 17, 'مروحه سقفيه', 1, 35000.00, 50000.00, 0.00, 50000.00, 25000.00, 2, 'monthly', 'LOCAL', '2026-09-04', 'active', '', '2026-09-05 00:00:32'),
(22, 2, 12, 20, 'موبايل كلاكسي', 1, 400000.00, 500000.00, 100000.00, 400000.00, 100000.00, 4, 'weekly', 'LOCAL', '2026-09-08', 'active', '', '2026-09-08 08:11:10'),
(23, 2, 12, 17, 'مروحه سقفيه', 1, 35000.00, 50000.00, 10000.00, 40000.00, 10000.00, 4, 'monthly', 'LOCAL', '2026-09-09', 'active', '', '2026-09-09 17:42:16'),
(24, 2, 12, 10, 'مجمده lg', 1, 250000.00, 300000.00, 0.00, 300000.00, 100000.00, 3, 'monthly', 'LOCAL', '2026-09-11', 'active', '', '2026-09-11 16:50:04'),
(25, 25, 20, 22, 'شاشة', 1, 100000.00, 150000.00, 50000.00, 100000.00, 100000.00, 1, 'monthly', 'LOCAL', '2026-09-11', 'active', '', '2026-09-11 17:02:56'),
(26, 24, 21, 21, 'غسالة', 1, 150000.00, 200000.00, 50000.00, 150000.00, 50000.00, 3, 'monthly', 'LOCAL', '2026-09-11', 'active', '', '2026-09-11 19:42:35'),
(27, 24, 22, 21, 'غسالة', 1, 150000.00, 200000.00, 50000.00, 150000.00, 50000.00, 3, 'monthly', 'LOCAL', '2026-09-11', 'completed', '', '2026-09-11 19:49:47');

-- --------------------------------------------------------

--
-- Table structure for table `settings`
--

CREATE TABLE `settings` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `setting_key` varchar(100) NOT NULL,
  `setting_value` text DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `settings`
--

INSERT INTO `settings` (`id`, `user_id`, `setting_key`, `setting_value`, `updated_at`) VALUES
(6, 5, 'store_name', 'بوينت', '2026-08-27 22:49:27'),
(7, 5, 'currency_name', 'دينار', '2026-08-27 22:49:27'),
(8, 5, 'currency_symbol', 'د.ع', '2026-08-27 22:49:27'),
(9, 5, 'exchange_rate', '1450', '2026-08-27 22:49:27'),
(10, 5, 'whatsapp_template', '', '2026-08-27 22:49:27'),
(11, 2, 'store_name', 'محمد', '2026-08-29 18:22:17'),
(12, 2, 'currency_name', 'دينار', '2026-08-29 18:22:17'),
(13, 2, 'currency_symbol', 'د.ع', '2026-08-29 18:22:17'),
(14, 2, 'exchange_rate', '1550', '2026-08-30 00:42:23'),
(15, 2, 'whatsapp_template', '', '2026-08-29 18:22:17'),
(16, 10, 'store_name', 'اقساطي', '2026-08-29 22:45:10'),
(17, 10, 'currency_name', 'دينار', '2026-08-29 22:45:10'),
(18, 10, 'currency_symbol', 'د.ع', '2026-08-29 22:45:10'),
(19, 10, 'exchange_rate', '1450', '2026-08-29 22:45:10'),
(20, 10, 'whatsapp_template', '', '2026-08-29 22:45:10'),
(26, 11, 'store_name', 'ممم', '2026-09-02 16:32:32'),
(27, 11, 'currency_name', 'دينار', '2026-09-02 16:32:32'),
(28, 11, 'currency_symbol', 'د.ع', '2026-09-02 16:32:32'),
(29, 11, 'exchange_rate', '1450', '2026-09-02 16:32:32'),
(30, 11, 'whatsapp_template', '', '2026-09-02 16:32:32'),
(31, 13, 'store_name', 'كوب', '2026-09-02 21:29:35'),
(32, 13, 'currency_name', 'دينار', '2026-09-02 21:29:35'),
(33, 13, 'currency_symbol', 'د.ع', '2026-09-02 21:29:35'),
(34, 13, 'exchange_rate', '1450', '2026-09-02 21:29:35'),
(35, 13, 'whatsapp_template', '', '2026-09-02 21:29:35');

-- --------------------------------------------------------

--
-- Table structure for table `subscriptions`
--

CREATE TABLE `subscriptions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `duration_value` int(11) NOT NULL,
  `duration_unit` enum('day','week','month','year') NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `status` enum('active','cancelled','expired') NOT NULL DEFAULT 'active',
  `created_by` int(11) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `subscriptions`
--

INSERT INTO `subscriptions` (`id`, `user_id`, `duration_value`, `duration_unit`, `start_date`, `end_date`, `status`, `created_by`, `notes`, `created_at`) VALUES
(1, 11, 1, 'month', '2026-09-02', '2026-10-02', 'active', 2, NULL, '2026-09-02 17:34:55'),
(2, 3, 1, 'month', '2026-09-03', '2026-10-03', 'cancelled', 2, NULL, '2026-09-03 14:23:02'),
(3, 3, 1, 'month', '2026-09-04', '2026-10-04', 'cancelled', 2, NULL, '2026-09-04 10:45:21'),
(4, 3, 1, 'month', '2026-09-04', '2026-10-04', 'cancelled', 2, NULL, '2026-09-04 16:01:41'),
(5, 23, 1, 'month', '2026-09-11', '2026-10-11', 'active', 2, NULL, '2026-09-11 15:38:22'),
(6, 22, 1, 'month', '2026-09-11', '2026-10-11', 'active', 2, NULL, '2026-09-11 15:38:36'),
(7, 21, 1, 'month', '2026-09-11', '2026-10-11', 'active', 2, NULL, '2026-09-11 15:38:57'),
(8, 20, 1, 'month', '2026-09-11', '2026-10-11', 'active', 2, NULL, '2026-09-11 15:39:04'),
(9, 19, 1, 'month', '2026-09-11', '2026-10-11', 'active', 2, NULL, '2026-09-11 15:39:13'),
(10, 25, 1, 'month', '2026-09-12', '2026-10-12', 'active', 2, NULL, '2026-09-12 19:26:38');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `name` varchar(100) NOT NULL,
  `role` varchar(20) DEFAULT 'user',
  `subscription_status` enum('active','cancelled','expired') NOT NULL DEFAULT 'active',
  `created_at` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`id`, `email`, `password`, `name`, `role`, `subscription_status`, `created_at`) VALUES
(1, 'admin@gmail.com', '$2y$10$e.R.4C2sU4n3w.D8P.3F.O.kI8Y/7N/5X.p8C/5F.M.Q.L/5D/4.', 'مدير النظام', 'user', 'active', '2026-08-25 00:36:00'),
(2, 'asmaomar5566@gmail.com', '$2y$10$MCD2hAH7A/JJrmD9ismSNeLD4tAW1PaDU9XfHKO1K8sy169nbfoHy', 'Moath', 'admin', 'active', '2026-08-28 14:40:57'),
(3, 'asma66@gmail.com', '$2y$10$LBRxbkqwF7pvXyhWbK3hy.MKimCkfk9Apl766EiAvqyqTCZvTHjNi', 'maad ahmed', 'user', 'cancelled', '2026-08-25 06:24:14'),
(4, 'm11287137@gmail.com', '$2y$10$PE563D7w0FoEgLkMacHA0OYZIcjXWMj3vZvKytXq5/Dg3AuzF5UIa', 'Moath', 'user', 'active', '2026-08-27 17:56:28'),
(5, 'montatherm39@gmail.com', '$2y$10$7YtF4NH6ckN16OSkCinB9O8TFq4hb9vB/6FnVxoCuYPw.ay9Vxmeu', 'Montather Mohammed', 'user', 'active', '2026-08-27 22:39:45'),
(6, 'gg@gg.cim', '$2y$10$MtaT.KxxLwpYF0hJjrEyyemRa9iSnt1fA8JZgHcssQgwGnW0PawmK', '\' OR \'1\'=\'1', 'user', 'active', '2026-08-27 23:28:20'),
(10, 'mu@mu.com', '$2y$10$akL4gxo0pOLzfe.5DTyYrePRsPsphGX5Ydg./KcuCzoDDL1bSSF76', 'منتظر', 'user', 'active', '2026-08-29 22:44:22'),
(11, 'cvvv19@gmail.com', '$2y$10$lujYZASWPNmHRPaaF1.J1evhV/DuqcOXDZi6Xaoc3MCT5UDa6FIV2', 'ننن', 'user', 'active', '2026-09-02 16:31:49'),
(12, 'sreersreer@gmail.com', '$2y$10$zvL54Z1pwafNRmdlyspdFeHVneVketOlfW9wtNMGyKLWq0gvYSqmq', 'My21', 'user', 'active', '2026-09-02 20:48:10'),
(13, 'g@g.com', '$2y$10$BIrRlOL2L4P0DH.HXdelLOhz0ELxaGOTmG5IVIFIbj/Juj6nwBXG.', 'منتظر محمد', 'user', 'active', '2026-09-02 21:29:11'),
(14, 'montatherm3923@gmail.com', '$2y$10$iYpuZsEYQETBlNs.vF3jo.vli1e5VovL5.XjItitl0B8EvRfoVYmW', 'على سامر', 'user', 'active', '2026-09-02 21:56:09'),
(15, 'montatherm3966@gmail.com', '$2y$10$vQJxD./LYTC1HV.bQgHo9.IdRSU8vXui2Df4shfW5LVZZZfeWsntG', 'على سمير', 'user', 'active', '2026-09-02 23:04:45'),
(16, 'montatherm39676@gmail.com', '$2y$10$Rqf6sbZnsULp7xVe.3Rl9OabpRsCwf7mZlrl4ESda.L5XZJAij5HO', 'علي سمير', 'user', 'active', '2026-09-02 23:07:54'),
(17, 'jwadalamry198@gmail.com', '$2y$10$.gWmFkTXAgXXDfr6OXHHm.jdGIXexJj5S1RsENk0Gxt0va8D4gr1q', 'جواد كاظم جبار', 'user', 'active', '2026-09-03 07:23:23'),
(18, 'doass@gmail.com', '$2y$10$gqfj/1T7LZO7H5XBkXmK0eAFy1icsqi44f8pEeFC54njpf.KGy.Be', 'محمد', 'user', 'active', '2026-09-03 18:10:18'),
(19, 'aboalmel96@gmail.com', '$2y$10$omnVsJfIemRojH1hHoZ8puGN1vcVIhK8YuDP/pZH7Qm25.KLQUneW', 'علي عجيل', 'user', 'active', '2026-09-04 09:19:36'),
(20, 'dhhdjejrjd@gmail.com', '$2y$10$LLJz9OstioU/bSTUS8Dh8.2qkuTA9dXapvOe3vbrYGlxos.3DeRre', 'علي الرضا', 'user', 'active', '2026-09-04 09:31:45'),
(21, 'haitham0076@gmail.com', '$2y$10$J8HpmLnrWksm13yI3i238ec6FSogOmM1xQljO98lqgDvjqYEH./RK', 'هيثم', 'user', 'active', '2026-09-04 10:02:56'),
(22, 'khd11@gmail.com', '$2y$10$6Sp4pTMZrzbtVG2LDT9rsOafWD4UXJYrSBq8/CNmLWkalnFOmsBJe', 'ali', 'user', 'active', '2026-09-04 10:43:18'),
(23, 'muhammedalmusawi334422@gmail.com', '$2y$10$gEBkb7jCkfWzNDJgP972puwF1vLeHAdH11BhBLdsEN4abvluV03bW', 'Muhammed', 'user', 'active', '2026-09-04 21:30:35'),
(24, 'm@m.com', '$2y$10$3nqw5jtsTPO2fRodsfesSOMMXO4/z.Ir0ZGzgMshpR9W5sJbqttmG', 'Montather Mohammed', 'user', 'active', '2026-09-11 16:09:14'),
(25, 'r@r.com', '$2y$10$eac3eoeYu5NRUvl2E6l/ie3nZNNMVPgmZM2hZz1fqZUTnaDrGS5qu', 'Rjj', 'user', 'active', '2026-09-11 17:01:12');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `customers`
--
ALTER TABLE `customers`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_name` (`name`),
  ADD KEY `idx_phone` (`phone`);

--
-- Indexes for table `installments`
--
ALTER TABLE `installments`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_sale` (`sale_id`),
  ADD KEY `idx_due_date` (`due_date`),
  ADD KEY `idx_status` (`status`);

--
-- Indexes for table `inventory`
--
ALTER TABLE `inventory`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user_product` (`user_id`,`product_id`),
  ADD KEY `idx_product` (`product_id`);

--
-- Indexes for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_product` (`product_id`),
  ADD KEY `idx_sale` (`sale_id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indexes for table `sales`
--
ALTER TABLE `sales`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `product_id` (`product_id`),
  ADD KEY `idx_customer` (`customer_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `idx_sale_date` (`sale_date`);

--
-- Indexes for table `settings`
--
ALTER TABLE `settings`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_setting` (`user_id`,`setting_key`);

--
-- Indexes for table `subscriptions`
--
ALTER TABLE `subscriptions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_user` (`user_id`),
  ADD KEY `idx_status` (`status`),
  ADD KEY `subscriptions_ibfk_2` (`created_by`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`email`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `customers`
--
ALTER TABLE `customers`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `installments`
--
ALTER TABLE `installments`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT for table `inventory`
--
ALTER TABLE `inventory`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=20;

--
-- AUTO_INCREMENT for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=40;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=23;

--
-- AUTO_INCREMENT for table `sales`
--
ALTER TABLE `sales`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=28;

--
-- AUTO_INCREMENT for table `settings`
--
ALTER TABLE `settings`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=36;

--
-- AUTO_INCREMENT for table `subscriptions`
--
ALTER TABLE `subscriptions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=11;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `customers`
--
ALTER TABLE `customers`
  ADD CONSTRAINT `customers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `installments`
--
ALTER TABLE `installments`
  ADD CONSTRAINT `installments_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `installments_ibfk_2` FOREIGN KEY (`sale_id`) REFERENCES `sales` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `inventory`
--
ALTER TABLE `inventory`
  ADD CONSTRAINT `inventory_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `inventory_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `inventory_movements`
--
ALTER TABLE `inventory_movements`
  ADD CONSTRAINT `inventory_movements_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `inventory_movements_ibfk_2` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `products`
--
ALTER TABLE `products`
  ADD CONSTRAINT `products_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `sales`
--
ALTER TABLE `sales`
  ADD CONSTRAINT `sales_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sales_ibfk_2` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `sales_ibfk_3` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`);

--
-- Constraints for table `settings`
--
ALTER TABLE `settings`
  ADD CONSTRAINT `settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `subscriptions`
--
ALTER TABLE `subscriptions`
  ADD CONSTRAINT `subscriptions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `subscriptions_ibfk_2` FOREIGN KEY (`created_by`) REFERENCES `users` (`id`) ON DELETE SET NULL;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
