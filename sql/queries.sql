-- =====================================================
-- ✅ SCHEMA-COMPATIBLE TRIGGERS, VIEWS & PROCEDURES
-- =====================================================

-- =========================================
-- Drop existing objects if they exist (for clean re-run)
-- =========================================
DROP TRIGGER IF EXISTS auto_payment_amount;
DROP TRIGGER IF EXISTS trg_set_travel_end;
DROP VIEW IF EXISTS BookingSummary;
DROP PROCEDURE IF EXISTS MakeBooking;
DROP PROCEDURE IF EXISTS UpdateBookingStatus;
DROP FUNCTION IF EXISTS TotalSpentByUser;
DROP FUNCTION IF EXISTS AvgPriceByTheme;
DROP PROCEDURE IF EXISTS GetBookingWithEndDate;

-- =========================================
-- Trigger: Automatically set payment amount
-- =========================================
DELIMITER //
CREATE TRIGGER auto_payment_amount
BEFORE INSERT ON Payment
FOR EACH ROW
BEGIN
    DECLARE pkg_price DECIMAL(10,2);
    DECLARE ppl INT;

    SELECT p.price, b.numtravelers
    INTO pkg_price, ppl
    FROM Booking b
    JOIN Package p ON b.package_id = p.package_id
    WHERE b.booking_id = NEW.booking_id;

    SET NEW.amount = pkg_price * ppl;
END //
DELIMITER ;

-- =========================================
-- Trigger: Auto-calculate travel_end_date
-- (travel_end_date already exists in schema)
-- =========================================
DELIMITER //
CREATE TRIGGER trg_set_travel_end
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
  DECLARE trip_days INT;
  SELECT duration_days INTO trip_days
  FROM Package WHERE package_id = NEW.package_id;

  SET NEW.travel_end_date = DATE_ADD(NEW.travel_start_date, INTERVAL trip_days DAY);
END//
DELIMITER ;

-- =========================================
-- View: Booking Summary (All destinations per booking)
-- =========================================
CREATE VIEW BookingSummary AS
SELECT 
    b.booking_id,
    u.name AS customer,
    GROUP_CONCAT(DISTINCT d.name ORDER BY pd.sequence_no SEPARATOR ', ') AS destinations,
    p.package_name,
    b.numtravelers,
    pay.amount,
    b.status
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Package p ON b.package_id = p.package_id
JOIN Package_Destination pd ON p.package_id = pd.package_id
JOIN Destination d ON pd.destination_id = d.destination_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id
GROUP BY b.booking_id, u.name, p.package_name, b.numtravelers, pay.amount, b.status;

-- =========================================
-- Procedure: Make Booking
-- =========================================
DELIMITER //
CREATE PROCEDURE MakeBooking (
    IN p_user_id INT,
    IN p_package_id INT,
    IN p_transport_id INT,
    IN p_numtravelers INT,
    IN p_status VARCHAR(50),
    IN p_travel_start_date DATE
)
BEGIN
    INSERT INTO Booking (user_id, package_id, transport_id, booking_date, travel_start_date, numtravelers, status)
    VALUES (p_user_id, p_package_id, p_transport_id, CURDATE(), p_travel_start_date, p_numtravelers, p_status);
END //
DELIMITER ;

-- =========================================
-- Procedure: Update Booking Status
-- =========================================
DELIMITER //
CREATE PROCEDURE UpdateBookingStatus (
    IN p_booking_id INT,
    IN p_status VARCHAR(50)
)
BEGIN
    UPDATE Booking
    SET status = p_status
    WHERE booking_id = p_booking_id;
END //
DELIMITER ;

-- =========================================
-- Function: Calculate Total Spent by User
-- =========================================
DELIMITER //
CREATE FUNCTION TotalSpentByUser(u_id INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(12,2);
    SELECT IFNULL(SUM(amount), 0) INTO total
    FROM Payment pay
    JOIN Booking b ON pay.booking_id = b.booking_id
    WHERE b.user_id = u_id;
    RETURN total;
END //
DELIMITER ;

-- =========================================
-- Function: Average Package Price by Theme
-- =========================================
DELIMITER //
CREATE FUNCTION AvgPriceByTheme(theme_name VARCHAR(50))
RETURNS DECIMAL(10,2)
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE avg_price DECIMAL(10,2);
    SELECT IFNULL(AVG(price), 0) INTO avg_price
    FROM Package
    WHERE theme = theme_name;
    RETURN avg_price;
END //
DELIMITER ;

-- =========================================
-- Procedure: Get Booking Details (with travel_end_date)
-- =========================================
DELIMITER //
CREATE PROCEDURE GetBookingWithEndDate()
BEGIN
    SELECT 
        b.booking_id,
        u.name AS user_name,
        p.package_name,
        GROUP_CONCAT(DISTINCT d.name ORDER BY pd.sequence_no SEPARATOR ', ') AS destinations,
        b.travel_start_date,
        b.travel_end_date,
        b.status,
        b.numtravelers,
        t.mode AS transport_mode,
        t.company AS transport_company
    FROM Booking b
    JOIN User u ON b.user_id = u.user_id
    JOIN Package p ON b.package_id = p.package_id
    JOIN Package_Destination pd ON p.package_id = pd.package_id
    JOIN Destination d ON pd.destination_id = d.destination_id
    JOIN Transport t ON b.transport_id = t.transport_id
    GROUP BY b.booking_id, u.name, p.package_name, b.travel_start_date, 
             b.travel_end_date, b.status, b.numtravelers, t.mode, t.company;
END //
DELIMITER ;

-- =========================================
-- Complex Queries
-- =========================================

-- 🏆 Best-Selling Packages (Top 5)
SELECT 
    p.package_name,
    COUNT(*) AS total_bookings
FROM Booking b
JOIN Package p ON b.package_id = p.package_id
GROUP BY p.package_id
ORDER BY total_bookings DESC
LIMIT 5;

-- 💰 Highest Revenue Packages (Top 5)
SELECT 
    p.package_name,
    SUM(pay.amount) AS total_revenue
FROM Payment pay
JOIN Booking b ON pay.booking_id = b.booking_id
JOIN Package p ON b.package_id = p.package_id
GROUP BY p.package_id
ORDER BY total_revenue DESC
LIMIT 5;