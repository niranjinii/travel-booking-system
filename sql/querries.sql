--trigger for autocomplete pay ammount
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

--view to give booking summary
CREATE VIEW BookingSummary AS
SELECT 
    b.booking_id,
    u.name AS customer,
    d.name AS destination,
    p.package_name,
    b.numtravelers,
    pay.amount,
    b.status
FROM Booking b
JOIN User u ON b.user_id = u.user_id
JOIN Package p ON b.package_id = p.package_id
JOIN Destination d ON p.destination_id = d.destination_id
LEFT JOIN Payment pay ON b.booking_id = pay.booking_id;

--complex querries:

--best selling  pkg
SELECT d.name, COUNT(*) AS total_bookings
FROM Booking b
JOIN Package p ON b.package_id = p.package_id
JOIN Destination d ON p.destination_id = d.destination_id
GROUP BY d.destination_id
ORDER BY total_bookings DESC;

--highest revenue package

SELECT d.name, COUNT(*) AS total_bookings
FROM Booking b
JOIN Package p ON b.package_id = p.package_id
JOIN Destination d ON p.destination_id = d.destination_id
GROUP BY d.destination_id
ORDER BY total_bookings DESC;


DELIMITER //
CREATE TRIGGER trg_set_travel_end
BEFORE INSERT ON Booking
FOR EACH ROW
BEGIN
  DECLARE trip_days INT;
  SELECT duration_days INTO trip_days
  FROM Package WHERE package_id = NEW.package_id;
  
  SET NEW.travel_end = DATE_ADD(NEW.travel_start, INTERVAL trip_days DAY);
END//
DELIMITER ;

--  Procedure to book a package
DELIMITER //
CREATE PROCEDURE MakeBooking (
    IN p_user_id INT,
    IN p_package_id INT,
    IN p_transport_id INT,
    IN p_numtravelers INT,
    IN p_status VARCHAR(20)
)
BEGIN
    INSERT INTO Booking (user_id, package_id, transport_id, booking_date, numtravelers, status)
    VALUES (p_user_id, p_package_id, p_transport_id, CURDATE(), p_numtravelers, p_status);
END //
DELIMITER ;

-- Procedure to update booking status
DELIMITER //
CREATE PROCEDURE UpdateBookingStatus (
    IN p_booking_id INT,
    IN p_status VARCHAR(20)
)
BEGIN
    UPDATE Booking
    SET status = p_status
    WHERE booking_id = p_booking_id;
END //
DELIMITER ;

--  Function to calculate total spent by a user
DELIMITER //
CREATE FUNCTION TotalSpentByUser(u_id INT)
RETURNS DECIMAL(12,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(12,2);
    SELECT IFNULL(SUM(amount), 0) INTO total
    FROM Payment pay
    JOIN Booking b ON pay.booking_id = b.booking_id
    WHERE b.user_id = u_id;
    RETURN total;
END //
DELIMITER ;

--  Function to get average package price by theme
DELIMITER //
CREATE FUNCTION AvgPriceByTheme(theme_name VARCHAR(50))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE avg_price DECIMAL(10,2);
    SELECT AVG(price) INTO avg_price
    FROM Package
    WHERE theme = theme_name;
    RETURN avg_price;
END //
DELIMITER ;

--window func
-- Rank packages by popularity (number of bookings)
SELECT 
    p.package_name,
    COUNT(b.booking_id) AS total_bookings,
    RANK() OVER (ORDER BY COUNT(b.booking_id) DESC) AS popularity_rank
FROM Package p
LEFT JOIN Booking b ON p.package_id = b.package_id
GROUP BY p.package_id;

--procedure to get booking details fully, prolly better to use this in the booking page

DELIMITER $$

CREATE PROCEDURE GetBookingWithEndDate()
BEGIN
    SELECT 
        b.booking_id,
        u.name AS user_name,
        p.package_name,
        b.travel_start_date,
        DATE_ADD(b.travel_start_date, INTERVAL p.duration_days DAY) AS travel_end_date,
        b.status,
        b.numtravelers,
        t.mode AS transport_mode,
        t.company AS transport_company
    FROM Booking b
    JOIN User u ON b.user_id = u.user_id
    JOIN Package p ON b.package_id = p.package_id
    JOIN Transport t ON b.transport_id = t.transport_id;
END $$

DELIMITER ;
