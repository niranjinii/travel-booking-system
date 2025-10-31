-- ==================================
-- 1. USERS (15)
-- ==================================
INSERT INTO User (user_id, name, email, password, phone) VALUES
(1, 'Aarav Patel', 'aarav@example.com', 'hashedpass1', '9876543210'),          -- Gujarat
(2, 'Meera Shah', 'meera@example.com', 'hashedpass2', '9123456780'),           -- Maharashtra/Gujarat
(3, 'Rohan Mehta', 'rohan@example.com', 'hashedpass3', '9988776611'),          -- North India
(4, 'Sanya Rao', 'sanya@example.com', 'hashedpass4', '7894561230'),            -- South India
(5, 'Kabir Singh', 'kabir@example.com', 'hashedpass5', '9001122334'),          -- Punjab
(6, 'Ananya Iyer', 'ananya@example.com', 'hashedpass6', '9123987456'),         -- Tamil Nadu
(7, 'Veer Kapoor', 'veer@example.com', 'hashedpass7', '9898012345'),           -- Delhi
(8, 'Nisha Verma', 'nisha@example.com', 'hashedpass8', '9898212345'),          -- North India
(9, 'Rahul Jain', 'rahul@example.com', 'hashedpass9', '9876001122'),           -- Rajasthan
(10, 'Priya Das', 'priya@example.com', 'hashedpass10', '9876123001'),          -- Bengal
(11, 'Arjun Nair', 'arjun@example.com', 'hashedpass11', '8854776622'),         -- Kerala
(12, 'Neelima Menon', 'neelima@example.com', 'hashedpass12', '9988223344'),    -- Kerala
(13, 'Ritika Chatterjee', 'ritika@example.com', 'hashedpass13', '9112233445'), -- Bengal
(14, 'Tashi Lama', 'tashi@example.com', 'hashedpass14', '8855223344'),         -- Northeast/Border region (Sikkim)
(15, 'Yash Gupta', 'yash@example.com', 'hashedpass15', '9988445566');          -- Uttar Pradesh


-- ==================================
-- 2. DESTINATIONS (30)
-- ==================================
INSERT INTO Destination (destination_id, name, location) VALUES
(1, 'Goa', 'India'),
(2, 'Jaipur', 'India'),
(3, 'Agra', 'India'),
(4, 'Kerala', 'India'),
(5, 'Ladakh', 'India'),
(6, 'Paris', 'France'),
(7, 'Rome', 'Italy'),
(8, 'London', 'United Kingdom'),
(9, 'Amsterdam', 'Netherlands'),
(10, 'Zurich', 'Switzerland'),
(11, 'Berlin', 'Germany'),
(12, 'Prague', 'Czech Republic'),
(13, 'Vienna', 'Austria'),
(14, 'Tokyo', 'Japan'),
(15, 'Kyoto', 'Japan'),
(16, 'Osaka', 'Japan'),
(17, 'Seoul', 'South Korea'),
(18, 'Bangkok', 'Thailand'),
(19, 'Phuket', 'Thailand'),
(20, 'Singapore', 'Singapore'),
(21, 'Bali', 'Indonesia'),
(22, 'Hanoi', 'Vietnam'),
(23, 'Dubai', 'UAE'),
(24, 'Doha', 'Qatar'),
(25, 'Maldives', 'Indian Ocean'),
(26, 'Sydney', 'Australia'),
(27, 'Melbourne', 'Australia'),
(28, 'New York', 'USA'),
(29, 'Los Angeles', 'USA'),
(30, 'Istanbul', 'Turkey');

-- ==================================
-- 3. PACKAGES (25)
-- ==================================
INSERT INTO Package (package_id, package_name, description, price, duration_days, theme) VALUES
(1, 'Goa Beach Escape', 
 "Unwind on Goa's golden beaches with parasailing, seafood shacks, and laid-back nightlife. Includes a sunset cruise and spice plantation visit.", 
 22000, 4, 'Beach'),

(2, 'Indian Golden Triangle', 
 "Explore India's cultural heritage through Delhi, Agra, and Jaipur. Witness the Taj Mahal, forts, palaces, and vibrant bazaars.", 
 55000, 6, 'Cultural'),

(3, 'Kerala Backwaters & Hills', 
 "Sail through the serene backwaters of Alleppey, enjoy Ayurvedic massages, and explore Munnar's tea estates and wildlife parks.", 
 48000, 5, 'Nature'),

(4, 'Ladakh Adventure Expedition', 
 "A high-altitude adventure through Leh, Nubra Valley, and Pangong Lake. Perfect for thrill seekers and photographers", 
 75000, 7, 'Adventure'),

(5, 'Dubai Luxury Getaway', 
 "Shop at Dubai Mall, ride over the dunes on a desert safari, and experience luxury stays overlooking the skyline.", 
 90000, 5, 'Luxury'),

(6, 'Paris & Rome Romance', 
 "A dreamy European escape through the art, food, and charm of Paris and the timeless ruins of Rome. Includes Seine cruise and Colosseum tour.", 
 125000, 7, 'Honeymoon'),

(7, 'European Discovery Tour', 
 "Visit the must-see capitals — Paris, Amsterdam, Zurich, and Rome. A journey across art, architecture, and breathtaking scenery.", 
 185000, 10, 'Luxury'),

(8, 'Central Europe Explorer', 
 "From Vienna's classical elegance to Prague's Gothic charm and Berlin's modern vibe — discover the essence of Central Europe.", 
 160000, 9, 'Cultural'),

(9, 'London & Scotland Heritage Trail', 
 "Discover royal palaces, London's landmarks, and the Scottish Highlands' misty lochs and castles.", 
 110000, 8, 'Heritage'),

(10, 'Asian Circuit', 
 "Experience the best of Asia — Bangkok's street food, Singapore's futuristic skyline, and Bali's tropical serenity — in one circuit.", 
 120000, 9, 'Adventure'),

(11, 'Japan Highlights', 
 "From the neon streets of Tokyo to Kyoto's shrines and Osaka's food culture, this trip captures Japan's contrasts beautifully.", 
 145000, 8, 'Cultural'),

(12, 'Korean & Japan Fusion Tour', 
 "Explore Seoul's energy and Tokyo's tech wonders in this modern cultural blend across East Asia.", 
 150000, 9, 'Cultural'),

(13, 'Vietnam & Thailand Discovery', 
 "Cruise Ha Long Bay, visit Hanoi's markets, and relax on the beaches of Phuket and Krabi.", 
 90000, 7, 'Budget'),

(14, 'Singapore Family Fiesta', 
 "Perfect for families — visit Sentosa, Universal Studios, and Night Safari with kid-friendly hotels and transfers.", 
 75000, 5, 'Family'),

(15, 'Maldives Overwater Bliss', 
 "A luxury island escape with water villas, snorkeling adventures, and sunset dinners by the ocean.", 
 155000, 5, 'Luxury'),

(16, 'Bali Wellness Retreat', 
 "Yoga mornings, tropical spas, and peaceful nature — rejuvenate mind and soul in Bali's lush landscapes.", 
 60000, 6, 'Wellness'),

(17, 'Australia East Coast Explorer', 
 "Explore Sydney's iconic harbor, Melbourne's laneways, and the Great Ocean Road's coastal wonders.", 
 130000, 8, 'Adventure'),

(18, 'American East-West Experience', 
 "Start in New York's skyscrapers, then fly to sunny Los Angeles for beaches, Hollywood, and amusement parks.", 
 210000, 10, 'City Tour'),

(19, 'Doha & Dubai Arabian Experience', 
 "Twin-gulf experience combining luxury shopping, desert safaris, and cultural heritage in Doha and Dubai.", 
 95000, 6, 'Luxury'),

(20, 'Turkey Cultural Odyssey', 
 "Wander through Istanbul's mosques and bazaars, and explore Cappadocia's surreal landscapes.", 
 105000, 7, 'Cultural'),

(21, 'Goa Monsoon Magic', 
 "Witness lush green landscapes, waterfalls, and cozy cafes as Goa transforms during the monsoon.", 
 18000, 4, 'Seasonal'),

(22, 'Indian Himalayan Trail', 
 "Trek across Himachal's mountain passes, visit monasteries, and soak in natural hot springs.", 
 68000, 8, 'Adventure'),

(23, 'Romantic Bali & Maldives Getaway', 
 "A twin-island paradise combining Bali's spiritual calm with the Maldives' pure luxury. Ideal for couples.", 
 175000, 8, 'Honeymoon'),

(24, "Backpacker's Euro Trail", 
 "A budget-friendly multi-country adventure through Berlin, Prague, and Amsterdam with hostel stays and train travel.", 
 95000, 9, 'Budget'),

(25, 'Southeast Asia Explorer', 
 "Explore Singapore, Bangkok, and Hanoi for a mix of modern cities, temples, and local experiences.", 
 115000, 8, 'Cultural');

-- ==================================
-- 4. PACKAGE_DESTINATION
-- ==================================
INSERT INTO Package_Destination (package_id, destination_id, sequence_no) VALUES
(1, 1, 1),
(2, 2, 1), (2, 3, 2),
(3, 4, 1),
(4, 5, 1),
(5, 23, 1),
(6, 6, 1), (6, 7, 2),
(7, 6, 1), (7, 9, 2), (7, 10, 3), (7, 7, 4),
(8, 13, 1), (8, 12, 2), (8, 11, 3),
(9, 8, 1),
(10, 18, 1), (10, 20, 2), (10, 21, 3),
(11, 14, 1), (11, 15, 2), (11, 16, 3),
(12, 17, 1), (12, 14, 2),
(13, 22, 1), (13, 19, 2),
(14, 20, 1),
(15, 25, 1),
(16, 21, 1),
(17, 26, 1), (17, 27, 2),
(18, 28, 1), (18, 29, 2),
(19, 24, 1), (19, 23, 2),
(20, 30, 1),
(21, 1, 1),
(22, 5, 1),
(23, 21, 1), (23, 25, 2),
(24, 11, 1), (24, 12, 2), (24, 9, 3),
(25, 20, 1), (25, 18, 2), (25, 22, 3);

-- ==================================
-- 5. TRANSPORT
-- ==================================
INSERT INTO Transport (transport_id, mode, company, price) VALUES
(1, 'Flight', 'Air India', 15000),
(2, 'Flight', 'Emirates', 35000),
(3, 'Flight', 'Singapore Airlines', 40000),
(4, 'Train', 'Indian Railways', 2500),
(5, 'Bus', 'RedBus', 1200),
(6, 'Cruise', 'BlueWave', 50000),
(7, 'Flight', 'Qantas', 38000),
(8, 'Flight', 'Japan Airlines', 42000),
(9, 'Flight', 'British Airways', 45000),
(10, 'Flight', 'Lufthansa', 46000);

-- ==================================
-- 6. PACKAGE_TRANSPORT
-- ==================================
INSERT INTO Package_Transport (package_id, transport_id) VALUES
(1,1),
(2,4),
(3,1),
(4,1),
(5,2),
(6,9),
(7,9),
(8,10),
(9,9),
(10,3),
(11,8),
(12,8),
(13,3),
(14,3),
(15,3),
(16,3),
(17,7),
(18,9),
(19,2),
(20,9),
(21,1),
(22,1),
(23,3),
(24,10),
(25,3);

-- ==================================
-- 7. BOOKINGS
-- ==================================
INSERT INTO Booking (booking_id, user_id, package_id, transport_id, booking_date, travel_start_date, numtravelers, status) VALUES
(1,1,1,1,'2025-01-05','2025-01-12',2,'Confirmed'),
(2,2,5,2,'2025-02-01','2025-02-10',1,'Confirmed'),
(3,3,7,9,'2025-02-20','2025-03-05',2,'Pending'),
(4,4,4,1,'2025-03-10','2025-03-20',3,'Confirmed'),
(5,5,6,9,'2025-03-28','2025-04-10',2,'Confirmed'),
(6,6,10,3,'2025-04-10','2025-04-25',4,'Confirmed'),
(7,7,11,8,'2025-05-01','2025-05-11',1,'Pending'),
(8,8,15,3,'2025-05-25','2025-06-09',2,'Confirmed'),
(9,9,13,3,'2025-06-10','2025-06-30',3,'Confirmed'),
(10,10,18,9,'2025-06-20','2025-07-18',1,'Pending'),
(11,11,17,7,'2025-07-15','2025-08-05',2,'Confirmed'),
(12,12,19,2,'2025-08-25','2025-09-14',2,'Confirmed'),
(13,13,22,1,'2025-09-10','2025-09-25',1,'Confirmed'),
(14,14,23,3,'2025-09-25','2025-10-10',2,'Pending'),
(15,15,24,10,'2025-09-28','2025-10-15',3,'Confirmed');

-- ==================================
-- 8. PAYMENTS
-- ==================================
INSERT INTO Payment (payment_id, booking_id, amount, payment_date, method) VALUES
(1,1,44000,'2025-01-12','UPI'),
(2,2,90000,'2025-02-10','Credit Card'),
(3,3,185000,'2025-03-05','UPI'),
(4,4,75000,'2025-03-20','UPI'),
(5,5,125000,'2025-04-10','Net Banking'),
(6,6,120000,'2025-04-25','Credit Card'),
(7,7,145000,'2025-05-11','UPI'),
(8,8,155000,'2025-06-09','Credit Card'),
(9,9,90000,'2025-06-30','UPI'),
(10,10,210000,'2025-07-18','Credit Card'),
(11,11,130000,'2025-08-05','UPI'),
(12,12,95000,'2025-09-14','Credit Card'),
(13,13,68000,'2025-09-25','UPI'),
(14,14,175000,'2025-10-10','UPI'),
(15,15,95000,'2025-10-15','Credit Card');
