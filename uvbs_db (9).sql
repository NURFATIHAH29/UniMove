-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 25, 2026 at 02:46 PM
-- Server version: 9.5.0
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `uvbs_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `bookings`
--

CREATE TABLE `bookings` (
  `booking_id` int NOT NULL,
  `user_id` varchar(12) NOT NULL,
  `staff_name` varchar(100) DEFAULT NULL,
  `phone_number` varchar(20) DEFAULT NULL,
  `vehicle_type` enum('Bus','Van','Car','Lorry') NOT NULL,
  `start_date` date NOT NULL,
  `end_date` date NOT NULL,
  `trip_slot` varchar(20) DEFAULT 'Full Day',
  `pickup_location` varchar(255) NOT NULL,
  `destination` varchar(255) NOT NULL,
  `map_link` text,
  `passengers` int NOT NULL,
  `purpose` text NOT NULL,
  `status` varchar(20) DEFAULT 'Confirmed',
  `assigned_vehicle_id` varchar(255) DEFAULT NULL,
  `assigned_driver_id` varchar(255) DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `vehicle_condition_post` varchar(50) DEFAULT 'Good',
  `driver_notes_post` text,
  `trip_completed_at` timestamp NULL DEFAULT NULL,
  `vehicle_quantity` int DEFAULT '1'
) ;

--
-- Dumping data for table `bookings`
--

INSERT INTO `bookings` (`booking_id`, `user_id`, `staff_name`, `phone_number`, `vehicle_type`, `start_date`, `end_date`, `trip_slot`, `pickup_location`, `destination`, `map_link`, `passengers`, `purpose`, `status`, `assigned_vehicle_id`, `assigned_driver_id`, `created_at`, `vehicle_condition_post`, `driver_notes_post`, `trip_completed_at`, `vehicle_quantity`) VALUES
(94, '050329110666', 'NURFATIHAH BINTI MANZUL', '01155593747', 'Car', '2026-06-24', '2026-06-25', 'Full Day', 'hostel', 'Kuantan', 'https://www.google.com/maps?q=3.7214328,103.074694', 5, 'PPPP', 'Completed', '1', '32', '2026-06-24 14:53:59', 'Good', 'tiada', '2026-06-24 17:00:52', 1),
(95, '050329110666', 'NURFATIHAH BINTI MANZUL', '01155593747', 'Bus', '2026-06-24', '2026-06-25', 'Full Day', 'TAPAK KONVO', 'UNIVERSITI KEBANGSAAN MALAYSIA(UKM)', 'https://www.google.com/maps?q=2.9240809,101.7812216', 30, 'PROGRAM CODING', 'Completed', '15', '30,31', '2026-06-24 16:38:19', 'Good', 'tiada', '2026-06-24 16:52:20', 1),
(96, '050329110666', 'NURFATIHAH BINTI MANZUL', '01155593747', 'Van', '2026-06-25', '2026-06-26', 'Full Day', 'UMTCC', 'MUZIUM TERENGGANU', 'https://www.google.com/maps?q=5.3185729,103.1021128', 15, 'PROGRAM ILMIAH', 'Confirmed', '7', '41', '2026-06-25 02:06:53', 'Good', NULL, NULL, 1),
(97, '050302120098', 'NOOR AMEERA BINTI YUSOFF', '0102145085', 'Van', '2026-06-30', '2026-07-01', 'Full Day', 'Kolej Kediaman UMT', 'Besut', 'https://www.google.com/maps?q=5.5833333,102.5', 30, 'Dinner COMTECH', 'Completed', '7', '47', '2026-06-25 02:38:24', 'Good', '', '2026-06-25 03:05:25', 1),
(98, '050302120098', 'NOOR AMEERA BINTI YUSOFF', '0102145085', 'Car', '2026-06-29', '2026-06-30', 'Full Day', 'PSR', 'Lapangan Terbang Sultan Mahmud', 'https://www.google.com/maps?q=5.3771073,103.0984306', 10, 'International Field Trip', 'Confirmed', '1,2', '48,49', '2026-06-25 02:39:52', 'Good', NULL, NULL, 2),
(99, '050302120098', 'NOOR AMEERA BINTI YUSOFF', '0102145085', 'Bus', '2026-07-09', '2026-07-10', 'Full Day', 'UMTCC', 'USM', 'https://www.google.com/maps?q=5.3574323,100.3035504', 60, 'PROGRAM KEBUDAYAAN', 'Confirmed', '15,16', '50,51,52,53', '2026-06-25 02:42:16', 'Good', NULL, NULL, 2),
(100, '050302120098', 'NOOR AMEERA BINTI YUSOFF', '0102145085', 'Van', '2026-07-09', '2026-07-10', 'Full Day', 'TAPAK KONVO', 'MUZIUM TERENGGANU', 'https://www.google.com/maps?q=5.3185729,103.1021128', 15, 'PROGRAM BERILMIAH', 'Confirmed', '7,8', '47,48', '2026-06-25 02:42:53', 'Good', NULL, NULL, 2),
(102, '050925040190', 'AIN SUFIAH BINTI AZMAN', '0176640676', 'Bus', '2026-07-01', '2026-07-02', 'Full Day', 'UMTCC', 'UNIVERSITI KEBANGSAAN MALAYSIA(UKM)', 'https://www.google.com/maps?q=2.9240809,101.7812216', 30, 'Field Trip', 'Cancelled by Admin', '15', '50,51', '2026-06-25 02:52:14', 'Good', NULL, NULL, 1);

-- --------------------------------------------------------

--
-- Table structure for table `drivers`
--

CREATE TABLE `drivers` (
  `driver_id` int NOT NULL,
  `full_name` varchar(100) NOT NULL,
  `staff_id` varchar(20) NOT NULL,
  `license_class` varchar(20) NOT NULL,
  `license_expiration` date DEFAULT NULL,
  `phone_number` varchar(20) NOT NULL,
  `emergency_contact` varchar(50) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'READY'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `drivers`
--

INSERT INTO `drivers` (`driver_id`, `full_name`, `staff_id`, `license_class`, `license_expiration`, `phone_number`, `emergency_contact`, `status`) VALUES
(47, 'Muhammad Hazim Bin Adnan', 'DRV-0001', 'Class D', '2029-02-25', '017-6640676', '012-6323407', 'AVAILABLE'),
(48, 'Azman Bakri Bin Salleh', 'DRV-0002', 'Class D', '2028-01-25', '018-2789600', '013-8802105', 'AVAILABLE'),
(49, 'Abdullah Bin Zakari', 'DRV-0003', 'Class D', '2028-11-25', '017-4578342', 'N/A', 'AVAILABLE'),
(50, 'Zakaria Bin Abu', 'DRV-0004', 'Class E (Bus)', '2026-12-25', '016-4590342', '012-6323407', 'AVAILABLE'),
(51, 'Mohd Yusri Bin A.Loh', 'DRV-0005', 'Class E (Bus)', '2028-03-25', '014-7823140', '012-45', 'AVAILABLE'),
(52, 'Muhammad Azam Bin Azman', 'DRV-0006', 'Class E (Bus)', '2027-05-25', '013-3446789', 'N/A', 'AVAILABLE'),
(53, 'Ahmad Shahril Bin Musa', 'DRV-0007', 'Class E (Lorry)', '2028-08-12', '019-3341234', '019-3341235', 'AVAILABLE'),
(54, 'Khairul Anuar Bin Zainal', 'DRV-0008', 'Class E (Lorry)', '2029-04-19', '011-2345678', 'N/A', 'READY'),
(55, 'Mohd Faizul Bin Rahman', 'DRV-0009', 'Class D (Van)', '2027-11-05', '016-7789123', '016-7789120', 'AVAILABLE'),
(56, 'Muhammad Syamil Bin Rosli', 'DRV-0010', 'Class D (Van)', '2028-06-30', '013-5564321', '013-5564300', 'AVAILABLE'),
(57, 'Rizal Bin Mohd Noor', 'DRV-0011', 'Class E (Bus)', '2029-01-15', '017-9988776', '017-9988770', 'READY'),
(58, 'Zulkifli Bin Ibrahim', 'DRV-0012', 'Class D', '2028-09-22', '012-3344556', 'N/A', 'READY'),
(59, 'Yusof Abdul Kadil', 'DRV-0014', 'Class E (Bus)', '2026-06-17', '0168032725', 'N/A', 'READY');

-- --------------------------------------------------------

--
-- Table structure for table `feedback`
--

CREATE TABLE `feedback` (
  `feedback_id` int NOT NULL,
  `user_id` varchar(20) NOT NULL,
  `category` varchar(50) NOT NULL,
  `message` text NOT NULL,
  `status` varchar(20) DEFAULT 'Confirmed',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `feedback`
--

INSERT INTO `feedback` (`feedback_id`, `user_id`, `category`, `message`, `status`, `created_at`) VALUES
(8, '050329110666', 'Driver Behaviour', 'Driver baik dan punctual. Terima kasih atas kerjasamanya', 'Confirmed', '2026-06-21 01:33:29'),
(9, '050925040190', 'Driver Behaviour', 'Driver tidak mematuhi masa', 'Confirmed', '2026-06-25 03:09:02');

-- --------------------------------------------------------

--
-- Table structure for table `notifications`
--

CREATE TABLE `notifications` (
  `notification_id` int NOT NULL,
  `user_id` varchar(20) DEFAULT NULL,
  `booking_id` int DEFAULT NULL,
  `message` text,
  `is_read` tinyint DEFAULT '0',
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `notifications`
--

INSERT INTO `notifications` (`notification_id`, `user_id`, `booking_id`, `message`, `is_read`, `created_at`) VALUES
(1, '050329110666', 89, 'CRITICAL WARNING: Tempahan anda (Booking ID: #89 bagi kenderaan Car) telah dibatalkan oleh pihak Admin atas sebab: fyfyjfjf', 1, '2026-06-24 14:18:18'),
(2, '050329110666', 88, 'CRITICAL WARNING: Your booking (Booking ID: #88 for vehicle Car) has been cancelled by the Admin due to: IM SORRY FOR THIS', 1, '2026-06-24 14:37:11'),
(3, '050329110666', 92, 'CRITICAL WARNING: Your booking (Booking ID: #92 for vehicle Van) has been cancelled by the Admin due to: ANOTHER IMPORTANT PROGRAM IS ON THE SAME DATE', 1, '2026-06-24 14:49:27'),
(4, '050925040190', 102, 'CRITICAL WARNING: Your booking (Booking ID: #102 for vehicle Bus) has been cancelled by the Admin due to: Kekurangan bas', 1, '2026-06-25 02:54:59');

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `user_id` varchar(12) NOT NULL,
  `full_name` varchar(255) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL,
  `department` varchar(100) DEFAULT NULL,
  `staff_id` varchar(20) DEFAULT NULL,
  `status` varchar(20) DEFAULT 'APPROVED'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`user_id`, `full_name`, `email`, `password`, `role`, `department`, `staff_id`, `status`) VALUES
('040715121014', 'ELSA FADLIN BINTI MERSING', 'S75412@ocean.umt.edu.my', 'elsa123', 'staff', 'FACULTY OF COMPUTER SCIENCE', 'S75412', 'APPROVED'),
('050302120098', 'NOOR AMEERA BINTI YUSOFF', 's76240@ocean.umt.edu.my', 'ameera123', 'staff', 'FSKM', 'STAFF02', 'APPROVED'),
('050329110666', 'NURFATIHAH BINTI MANZUL', 's76273@ocean.umt.edu.my', 'Tihah29@', 'staff', 'FACULTY OF COMPUTER SCIENCE', 'STAFF01', 'APPROVED'),
('050925040190', 'AIN SUFIAH BINTI AZMAN', 's76105@ocean.umt.edu.my', 'ain123', 'staff', 'FSKM', 'S76105', 'APPROVED'),
('ADMIN01', 'Super Admin', 'admin@ocean.umt.edu.my', 'admin123', 'admin', 'PPH', 'ADM001', 'APPROVED'),
('DRV-0001', 'Muhammad Hazim Bin Adnan', 'drv-0001@umt.edu.my', 'muhammadhazimbinadnan123', 'driver', NULL, NULL, 'APPROVED'),
('DRV-0002', 'Azman Bakri Bin Salleh', 'drv-0002@umt.edu.my', 'azmanbakribinsalleh123', 'driver', NULL, NULL, 'APPROVED'),
('DRV-0003', 'Abdullah Bin Zakari', 'drv-0003@umt.edu.my', 'abdullahbinzakari123', 'driver', NULL, NULL, 'APPROVED'),
('DRV-0004', 'Zakaria Bin Abu', 'drv-0004@umt.edu.my', 'zakariabinabu123', 'driver', NULL, NULL, 'APPROVED'),
('DRV-0005', 'Mohd Yusri Bin A.Loh', 'drv-0005@umt.edu.my', 'mohdyusribina.loh123', 'driver', NULL, NULL, 'APPROVED'),
('DRV-0006', 'Muhammad Azam Bin Azman', 'drv-0006@umt.edu.my', 'muhammadazambinazman123', 'driver', NULL, NULL, 'APPROVED'),
('DRV-0007', 'Ahmad Shahril Bin Musa', 'drv-0007@umt.edu.my', 'ahmadshahrilbinmusa123', 'driver', NULL, 'DRV-0007', 'APPROVED'),
('DRV-0008', 'Khairul Anuar Bin Zainal', 'drv-0008@umt.edu.my', 'khairulanuarbinzainal123', 'driver', NULL, 'DRV-0008', 'APPROVED'),
('DRV-0009', 'Mohd Faizul Bin Rahman', 'drv-0009@umt.edu.my', 'mohdfaizulbinrahman123', 'driver', NULL, 'DRV-0009', 'APPROVED'),
('DRV-0010', 'Muhammad Syamil Bin Rosli', 'drv-0010@umt.edu.my', 'muhammadsyamilbinrosli123', 'driver', NULL, 'DRV-0010', 'APPROVED'),
('DRV-0011', 'Rizal Bin Mohd Noor', 'drv-0011@umt.edu.my', 'rizalbinmohdnoor123', 'driver', NULL, 'DRV-0011', 'APPROVED'),
('DRV-0012', 'Zulkifli Bin Ibrahim', 'drv-0012@umt.edu.my', 'zulkiflibinibrahim123', 'driver', NULL, 'DRV-0012', 'APPROVED'),
('DRV-0014', 'Yusof Abdul Kadil', 'drv-0014@umt.edu.my', 'yusofabdulkadil123', 'driver', NULL, NULL, 'APPROVED');

-- --------------------------------------------------------

--
-- Table structure for table `vehicles`
--

CREATE TABLE `vehicles` (
  `vehicle_id` int NOT NULL,
  `model` varchar(100) NOT NULL,
  `plate_number` varchar(20) NOT NULL,
  `type` enum('Bus','Van','Car','Lorry') NOT NULL,
  `capacity` int NOT NULL,
  `status` enum('Available','In-Use','Maintenance') DEFAULT 'Available',
  `roadtax_expiry` date DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

--
-- Dumping data for table `vehicles`
--

INSERT INTO `vehicles` (`vehicle_id`, `model`, `plate_number`, `type`, `capacity`, `status`, `roadtax_expiry`, `created_at`) VALUES
(1, 'Toyota Innova', 'VGD 1234', 'Car', 7, 'Available', '2026-12-15', '2026-06-15 14:08:18'),
(2, 'Honda Civic', 'WPP 5678', 'Car', 5, 'Available', '2026-10-22', '2026-06-15 14:08:18'),
(3, 'Proton Saga', 'AKM 7766', 'Car', 5, 'Available', '2027-02-18', '2026-06-15 14:08:18'),
(4, 'Perodua Myvi', 'WYH 4455', 'Car', 5, 'Available', '2026-08-05', '2026-06-15 14:08:18'),
(5, 'Toyota Camry', 'BND 7711', 'Car', 5, 'Available', '2026-11-30', '2026-06-15 14:08:18'),
(6, 'Honda CR-V', 'VJQ 2233', 'Car', 5, 'Available', '2027-05-14', '2026-06-15 14:08:18'),
(7, 'Toyota Hiace', 'WUY 8899', 'Van', 10, 'Available', '2026-09-09', '2026-06-15 14:08:18'),
(8, 'Nissan Urvan', 'KDA 5566', 'Van', 12, 'Available', '2027-01-20', '2026-06-15 14:08:18'),
(9, 'Ford Transit', 'BLM 1122', 'Van', 14, 'Available', '2026-07-25', '2026-06-15 14:08:18'),
(11, 'Isuzu Elf', 'JMM 4321', 'Lorry', 2, 'Available', '2026-08-19', '2026-06-15 14:08:18'),
(12, 'Isiziu Forward', 'MCE 6677', 'Lorry', 3, 'Available', '2027-03-11', '2026-06-15 14:08:18'),
(13, 'Hino 300 Series', 'TBR 4433', 'Lorry', 3, 'Available', '2026-10-05', '2026-06-15 14:08:18'),
(14, 'Mitsubishi Fuso', 'PQQ 3344', 'Lorry', 3, 'Available', '2026-11-15', '2026-06-15 14:08:18'),
(15, 'Scania K-Series', 'NDD 8822', 'Bus', 44, 'Available', '2027-06-01', '2026-06-15 14:08:18'),
(16, 'Hino Poncho', 'KCC 1122', 'Bus', 25, 'Available', '2026-07-14', '2026-06-15 14:08:18'),
(17, 'Volvo B8RLE', 'WWW 9911', 'Bus', 40, 'Available', '2026-09-28', '2026-06-15 14:08:18'),
(18, 'Mercedes-Benz O500R', 'PMA 5500', 'Bus', 44, 'Available', '2027-04-19', '2026-06-15 14:08:18'),
(20, 'Perodua Axia', 'UMT4747', 'Car', 5, 'Available', NULL, '2026-06-25 02:58:06');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `bookings`
--
ALTER TABLE `bookings`
  ADD PRIMARY KEY (`booking_id`),
  ADD KEY `fk_assigned_vehicle` (`assigned_vehicle_id`);

--
-- Indexes for table `drivers`
--
ALTER TABLE `drivers`
  ADD PRIMARY KEY (`driver_id`),
  ADD UNIQUE KEY `staff_id` (`staff_id`);

--
-- Indexes for table `feedback`
--
ALTER TABLE `feedback`
  ADD PRIMARY KEY (`feedback_id`);

--
-- Indexes for table `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`notification_id`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`user_id`);

--
-- Indexes for table `vehicles`
--
ALTER TABLE `vehicles`
  ADD PRIMARY KEY (`vehicle_id`),
  ADD UNIQUE KEY `plate_number` (`plate_number`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `bookings`
--
ALTER TABLE `bookings`
  MODIFY `booking_id` int NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `drivers`
--
ALTER TABLE `drivers`
  MODIFY `driver_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=60;

--
-- AUTO_INCREMENT for table `feedback`
--
ALTER TABLE `feedback`
  MODIFY `feedback_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `notifications`
--
ALTER TABLE `notifications`
  MODIFY `notification_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `vehicles`
--
ALTER TABLE `vehicles`
  MODIFY `vehicle_id` int NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
