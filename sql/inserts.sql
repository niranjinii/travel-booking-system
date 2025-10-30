-- ==================================
-- 1. USERS (15)
-- ==================================
INSERT INTO User (name, email, password, phone) VALUES
('Aarav Patel', 'aarav@example.com', 'hashedpass1', '9876543210'),
('Meera Shah', 'meera@example.com', 'hashedpass2', '9123456780'),
('Rohan Mehta', 'rohan@example.com', 'hashedpass3', '9988776611'),
('Sanya Rao', 'sanya@example.com', 'hashedpass4', '7894561230'),
('Kabir Singh', 'kabir@example.com', 'hashedpass5', '9001122334'),
('Ananya Iyer', 'ananya@example.com', 'hashedpass6', '9123987456'),
('Veer Kapoor', 'veer@example.com', 'hashedpass7', '9898012345'),
('Nisha Verma', 'nisha@example.com', 'hashedpass8', '9898212345'),
('Rahul Jain', 'rahul@example.com', 'hashedpass9', '9876001122'),
('Priya Das', 'priya@example.com', 'hashedpass10', '9876123001'),
('Arjun Nair', 'arjun@example.com', 'hashedpass11', '8854776622'),
('Sara Khan', 'sara@example.com', 'hashedpass12', '9988223344'),
('Dev Malhotra', 'dev@example.com', 'hashedpass13', '9112233445'),
('Isha Reddy', 'isha@example.com', 'hashedpass14', '8855223344'),
('Yash Gupta', 'yash@example.com', 'hashedpass15', '9988445566');

-- ==================================
-- 2. DESTINATIONS (12)
-- ==================================
INSERT INTO Destination (name, location, description) VALUES
('Goa', 'India', 'Beaches & nightlife'),
('Paris', 'France', 'City of Love & Eiffel Tower'),
('Dubai', 'UAE', 'Luxury shopping & skyscrapers'),
('Tokyo', 'Japan', 'Tech & Culture'),
('Maldives', 'Indian Ocean', 'Luxury water villas'),
('Singapore', 'Singapore', 'Clean & modern city'),
('New York', 'USA', 'Times Square & Statue of Liberty'),
('Sydney', 'Australia', 'Opera House & Harbours'),
('Bangkok', 'Thailand', 'Night markets & temples'),
('London', 'UK', 'History & modern culture'),
('Bali', 'Indonesia', 'Beaches & temples'),
('Rome', 'Italy', 'Colosseum & heritage');

-- ==================================
-- 3. PACKAGES (20)
-- ==================================
INSERT INTO Package (package_name, price, duration_days, theme) VALUES
('Goa Beach Fun', 20000, 4, 'Beach'),
('Paris Romance', 90000, 5, 'Honeymoon'),
('Dubai Luxury Trip', 75000, 5, 'Luxury'),
('Tokyo Anime Tour', 85000, 6, 'Adventure'),
('Maldives Water Villa', 150000, 4, 'Luxury'),
('Singapore Family Pack', 60000, 4, 'Family'),
('NY Times Square Tour', 120000, 5, 'City Tour'),
('Sydney Opera Visit', 110000, 5, 'Adventure'),
('Bangkok Budget Trip', 30000, 3, 'Budget'),
('London Heritage Tour', 95000, 6, 'Heritage'),
('Bali Nature Retreat', 50000, 5, 'Nature'),
('Rome Ancient Wonders', 100000, 6, 'Heritage'),
('Goa Monsoon Special', 18000, 4, 'Seasonal'),
('Bangkok Party Nights', 32000, 3, 'Nightlife'),
('Maldives Couples Paradise', 155000, 4, 'Honeymoon'),
('Singapore Tech Tour', 65000, 5, 'Education'),
('Bali Yoga Escape', 45000, 6, 'Wellness'),
('Paris Family Trip', 87000, 6, 'Family'),
('Dubai Desert Safari', 70000, 4, 'Adventure'),
('Sydney Wildlife Tour', 105000, 5, 'Nature');

-- ==================================
-- 4. PACKAGE_DESTINATION (Multi-destination links)
-- ==================================
-- Each package linked to 1–3 destinations

INSERT INTO Package_Destination VALUES
(1, 1, 1), (1, 11, 2),
(2, 2, 1), (2, 10, 2),
(3, 3, 1), (3, 2, 2),
(4, 4, 1),
(5, 5, 1), (5, 1, 2),
(6, 6, 1), (6, 9, 2),
(7, 7, 1),
(8, 8, 1), (8, 7, 2),
(9, 9, 1), (9, 1, 2),
(10, 10, 1), (10, 12, 2),
(11, 11, 1),
(12, 12, 1), (12, 10, 2),
(13, 1, 1), (13, 5, 2),
(14, 9, 1), (14, 3, 2),
(15, 5, 1),
(16, 6, 1), (16, 4, 2),
(17, 11, 1),
(18, 2, 1), (18, 6, 2),
(19, 3, 1),
(20, 8, 1), (20, 5, 2);

-- ==================================
-- 5. TRANSPORT (6)
-- ==================================
INSERT INTO Transport (mode, company, price) VALUES
('Flight', 'Air India', 15000),
('Flight', 'Emirates', 35000),
('Flight', 'Singapore Airlines', 40000),
('Train', 'Indian Railways', 2500),
('Bus', 'RedBus', 1200),
('Cruise', 'BlueWave', 50000);

-- ==================================
-- 6. PACKAGE_TRANSPORT (Many-to-many)
-- ==================================
INSERT INTO Package_Transport VALUES
(1,1),(1,4),
(2,2),
(3,2),(3,1),
(4,1),
(5,3),
(6,3),
(7,2),
(8,2),
(9,4),(9,5),
(10,1),
(11,1),
(12,1),
(13,4),
(14,1),
(15,2),
(16,3),
(17,1),
(18,2),
(19,2),
(20,2);

-- ==================================
-- 7. BOOKINGS (15)
-- ==================================
INSERT INTO Booking (user_id, package_id, transport_id, booking_date, travel_start_date, numtravelers, status) VALUES
(1,1,1,'2025-01-05','2025-01-12',2,'Confirmed'),
(2,3,2,'2025-02-01','2025-02-10',1,'Confirmed'),
(3,5,3,'2025-02-20','2025-03-05',2,'Pending'),
(4,9,4,'2025-03-10','2025-03-15',3,'Confirmed'),
(5,2,2,'2025-03-28','2025-04-20',2,'Confirmed'),
(6,6,3,'2025-04-10','2025-04-25',4,'Confirmed'),
(7,10,1,'2025-05-01','2025-05-11',1,'Pending'),
(8,11,1,'2025-05-25','2025-06-09',2,'Confirmed'),
(9,14,1,'2025-06-10','2025-06-30',3,'Confirmed'),
(10,7,2,'2025-06-20','2025-07-18',1,'Pending'),
(11,12,1,'2025-07-15','2025-08-05',2,'Confirmed'),
(12,15,2,'2025-08-25','2025-09-14',2,'Confirmed'),
(13,1,4,'2025-09-10','2025-09-25',1,'Confirmed'),
(14,19,2,'2025-09-25','2025-10-10',2,'Pending'),
(15,20,2,'2025-09-28','2025-10-15',3,'Confirmed');

-- ==================================
-- 8. PAYMENTS (15)
-- ==================================
INSERT INTO Payment (booking_id, amount, payment_date, method) VALUES
(1,40000,'2025-01-12','UPI'),
(2,75000,'2025-02-10','Credit Card'),
(3,300000,'2025-03-05','UPI'),
(4,90000,'2025-03-15','UPI'),
(5,180000,'2025-04-20','Net Banking'),
(6,240000,'2025-04-25','Credit Card'),
(7,95000,'2025-05-11','UPI'),
(8,100000,'2025-06-09','UPI'),
(9,96000,'2025-06-30','UPI'),
(10,240000,'2025-07-18','Credit Card'),
(11,200000,'2025-08-05','Credit Card'),
(12,310000,'2025-09-14','UPI'),
(13,20000,'2025-09-25','UPI'),
(14,140000,'2025-10-10','UPI'),
(15,315000,'2025-10-15','Credit Card');
