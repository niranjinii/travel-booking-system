-- ==================================
-- 1. USERS (15)
-- ==================================
INSERT INTO User (user_id, name, email, password, phone) VALUES
(1, 'Aarav Patel', 'aarav@example.com', 'hashedpass1', '9876543210'),
(2, 'Meera Shah', 'meera@example.com', 'hashedpass2', '9123456780'),
(3, 'Rohan Mehta', 'rohan@example.com', 'hashedpass3', '9988776611'),
(4, 'Sanya Rao', 'sanya@example.com', 'hashedpass4', '7894561230'),
(5, 'Kabir Singh', 'kabir@example.com', 'hashedpass5', '9001122334'),
(6, 'Ananya Iyer', 'ananya@example.com', 'hashedpass6', '9123987456'),
(7, 'Veer Kapoor', 'veer@example.com', 'hashedpass7', '9898012345'),
(8, 'Nisha Verma', 'nisha@example.com', 'hashedpass8', '9898212345'),
(9, 'Rahul Jain', 'rahul@example.com', 'hashedpass9', '9876001122'),
(10, 'Priya Das', 'priya@example.com', 'hashedpass10', '9876123001'),
(11, 'Arjun Nair', 'arjun@example.com', 'hashedpass11', '8854776622'),
(12, 'Sara Khan', 'sara@example.com', 'hashedpass12', '9988223344'),
(13, 'Dev Malhotra', 'dev@example.com', 'hashedpass13', '9112233445'),
(14, 'Isha Reddy', 'isha@example.com', 'hashedpass14', '8855223344'),
(15, 'Yash Gupta', 'yash@example.com', 'hashedpass15', '9988445566');

-- ==================================
-- 2. DESTINATIONS (12)
-- ==================================
INSERT INTO Destination (destination_id, name, location) VALUES
(1, 'Goa', 'India'),
(2, 'Paris', 'France'),
(3, 'Dubai', 'UAE'),
(4, 'Tokyo', 'Japan'),
(5, 'Maldives', 'Indian Ocean'),
(6, 'Singapore', 'Singapore'),
(7, 'New York', 'USA'),
(8, 'Sydney', 'Australia'),
(9, 'Bangkok', 'Thailand'),
(10, 'London', 'UK'),
(11, 'Bali', 'Indonesia'),
(12, 'Rome', 'Italy');

-- ==================================
-- 3. PACKAGES (20)
-- ==================================
INSERT INTO Package (package_id, package_name, description, price, duration_days, theme) VALUES
(1, 'Goa Beach Fun', 'Relax at scenic beaches with exciting nightlife.', 20000, 4, 'Beach'),
(2, 'Paris Romance', 'Romantic getaway to the City of Love.', 90000, 5, 'Honeymoon'),
(3, 'Dubai Luxury Trip', 'Experience shopping and adventure in Dubai.', 75000, 5, 'Luxury'),
(4, 'Tokyo Anime Tour', 'Explore Akihabara and anime culture.', 85000, 6, 'Adventure'),
(5, 'Maldives Water Villa', 'Stay in water villas over turquoise lagoons.', 150000, 4, 'Luxury'),
(6, 'Singapore Family Pack', 'Fun-filled family trip to Singapore.', 60000, 4, 'Family'),
(7, 'NY Times Square Tour', 'Discover NYC’s iconic landmarks.', 120000, 5, 'City Tour'),
(8, 'Sydney Opera Visit', 'Visit the Opera House and explore Sydney.', 110000, 5, 'Adventure'),
(9, 'Bangkok Budget Trip', 'Affordable shopping and nightlife adventure.', 30000, 3, 'Budget'),
(10, 'London Heritage Tour', 'Explore London’s culture and history.', 95000, 6, 'Heritage'),
(11, 'Bali Nature Retreat', 'Rejuvenate in the serene nature of Bali.', 50000, 5, 'Nature'),
(12, 'Rome Ancient Wonders', 'Discover the Colosseum and ancient sites.', 100000, 6, 'Heritage'),
(13, 'Goa Monsoon Special', 'Enjoy Goa’s lush greenery during monsoon.', 18000, 4, 'Seasonal'),
(14, 'Bangkok Party Nights', 'Nightlife and clubbing adventure.', 32000, 3, 'Nightlife'),
(15, 'Maldives Couples Paradise', 'Perfect honeymoon with ocean views.', 155000, 4, 'Honeymoon'),
(16, 'Singapore Tech Tour', 'Discover modern tech hubs in Singapore.', 65000, 5, 'Education'),
(17, 'Bali Yoga Escape', 'Peaceful yoga retreat in tropical Bali.', 45000, 6, 'Wellness'),
(18, 'Paris Family Trip', 'Family-friendly adventure through Paris.', 87000, 6, 'Family'),
(19, 'Dubai Desert Safari', 'Thrilling desert ride and camping.', 70000, 4, 'Adventure'),
(20, 'Sydney Wildlife Tour', 'Meet Australia’s wildlife up close.', 105000, 5, 'Nature');

-- ==================================
-- 4. PACKAGE_DESTINATION
-- ==================================
INSERT INTO Package_Destination (package_id, destination_id, sequence_no) VALUES
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
-- 5. TRANSPORT
-- ==================================
INSERT INTO Transport (transport_id, mode, company, price) VALUES
(1, 'Flight', 'Air India', 15000),
(2, 'Flight', 'Emirates', 35000),
(3, 'Flight', 'Singapore Airlines', 40000),
(4, 'Train', 'Indian Railways', 2500),
(5, 'Bus', 'RedBus', 1200),
(6, 'Cruise', 'BlueWave', 50000);

-- ==================================
-- 6. PACKAGE_TRANSPORT
-- ==================================
INSERT INTO Package_Transport (package_id, transport_id) VALUES
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
-- 7. BOOKINGS
-- ==================================
INSERT INTO Booking (booking_id, user_id, package_id, transport_id, booking_date, travel_start_date, numtravelers, status) VALUES
(1,1,1,1,'2025-01-05','2025-01-12',2,'Confirmed'),
(2,2,3,2,'2025-02-01','2025-02-10',1,'Confirmed'),
(3,3,5,3,'2025-02-20','2025-03-05',2,'Pending'),
(4,4,9,4,'2025-03-10','2025-03-15',3,'Confirmed'),
(5,5,2,2,'2025-03-28','2025-04-20',2,'Confirmed'),
(6,6,6,3,'2025-04-10','2025-04-25',4,'Confirmed'),
(7,7,10,1,'2025-05-01','2025-05-11',1,'Pending'),
(8,8,11,1,'2025-05-25','2025-06-09',2,'Confirmed'),
(9,9,14,1,'2025-06-10','2025-06-30',3,'Confirmed'),
(10,10,7,2,'2025-06-20','2025-07-18',1,'Pending'),
(11,11,12,1,'2025-07-15','2025-08-05',2,'Confirmed'),
(12,12,15,2,'2025-08-25','2025-09-14',2,'Confirmed'),
(13,13,1,4,'2025-09-10','2025-09-25',1,'Confirmed'),
(14,14,19,2,'2025-09-25','2025-10-10',2,'Pending'),
(15,15,20,2,'2025-09-28','2025-10-15',3,'Confirmed');

-- ==================================
-- 8. PAYMENTS
-- ==================================
INSERT INTO Payment (payment_id, booking_id, amount, payment_date, method) VALUES
(1,1,40000,'2025-01-12','UPI'),
(2,2,75000,'2025-02-10','Credit Card'),
(3,3,300000,'2025-03-05','UPI'),
(4,4,90000,'2025-03-15','UPI'),
(5,5,180000,'2025-04-20','Net Banking'),
(6,6,240000,'2025-04-25','Credit Card'),
(7,7,95000,'2025-05-11','UPI'),
(8,8,100000,'2025-06-09','UPI'),
(9,9,96000,'2025-06-30','UPI'),
(10,10,240000,'2025-07-18','Credit Card'),
(11,11,200000,'2025-08-05','Credit Card'),
(12,12,310000,'2025-09-14','UPI'),
(13,13,20000,'2025-09-25','UPI'),
(14,14,140000,'2025-10-10','UPI'),
(15,15,315000,'2025-10-15','Credit Card');
