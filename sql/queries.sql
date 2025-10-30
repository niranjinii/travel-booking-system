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

--theres a few more but we  might not really use them, the ejs files themselves dont have much scope for complex ahh querries but ive kept some over here just incase, we can def add features for these querries in the frontend later