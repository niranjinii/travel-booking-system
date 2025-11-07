CREATE OR REPLACE VIEW top_3_packages AS
SELECT 
    p.package_id,
    p.package_name,
    COUNT(b.booking_id) AS bookings_count
FROM package p
LEFT JOIN booking b ON p.package_id = b.package_id
GROUP BY p.package_id, p.package_name
ORDER BY bookings_count DESC
LIMIT 3;

DELIMITER //
CREATE FUNCTION calculate_discount(travelers INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    DECLARE discount DECIMAL(5,2) DEFAULT 0.00;
    IF travelers >= 4 THEN
        SET discount = 0.15;
    ELSEIF travelers = 3 THEN
        SET discount = 0.10;
    ELSEIF travelers = 2 THEN
        SET discount = 0.05;
    END IF;
    RETURN discount;
END //
DELIMITER ;

DELIMITER //
CREATE PROCEDURE create_booking_and_payment (
    IN p_user_id INT,
    IN p_package_id INT,
    IN p_booking_date DATE,
    IN p_travel_start_date DATE,
    IN p_transport_id INT,
    IN p_numtravelers INT,
    IN p_amount DECIMAL(10,2),
    IN p_method VARCHAR(50)
)
BEGIN
    DECLARE new_booking_id INT;

    INSERT INTO booking (user_id, package_id, booking_date, travel_start_date, transport_id, numtravelers)
    VALUES (p_user_id, p_package_id, p_booking_date, p_travel_start_date, p_transport_id, p_numtravelers);

    SET new_booking_id = LAST_INSERT_ID();

    INSERT INTO payment (booking_id, amount, payment_date, method)
    VALUES (new_booking_id, p_amount, p_booking_date, p_method);
END //
DELIMITER ;

CREATE OR REPLACE VIEW user_bookings_view AS
SELECT 
    b.booking_id,
    b.user_id,
    b.package_id,
    b.booking_date,
    b.travel_start_date,
    b.numtravelers,
    p.package_name,
    p.price
FROM booking b
JOIN package p ON b.package_id = p.package_id;

DROP FUNCTION IF EXISTS calculate_total_price;
DELIMITER $$

CREATE FUNCTION calculate_total_price(
    basePrice DECIMAL(10,2),
    travelers INT,
    transportPrice DECIMAL(10,2),
    discount DECIMAL(5,4)
)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE baseTotal DECIMAL(10,2);

    SET baseTotal = (basePrice * travelers) + (transportPrice * travelers);

    RETURN baseTotal * (1 - discount);
END$$

DELIMITER ;



DELIMITER //
CREATE PROCEDURE cancel_booking(IN p_booking_id INT, IN p_user_id INT)
BEGIN
    DECLARE count_booking INT;
    SELECT COUNT(*) INTO count_booking
    FROM booking
    WHERE booking_id = p_booking_id AND user_id = p_user_id;

    IF count_booking > 0 THEN
        DELETE FROM booking WHERE booking_id = p_booking_id;
    END IF;
END //
DELIMITER ;

DELIMITER //

CREATE TRIGGER prevent_overlapping_bookings
BEFORE INSERT ON booking
FOR EACH ROW
BEGIN
    DECLARE pkg_duration INT;
    DECLARE new_start DATE;
    DECLARE new_end DATE;

    -- Get the package duration_days from your schema
    SELECT duration_days INTO pkg_duration
    FROM package
    WHERE package_id = NEW.package_id;

    SET new_start = NEW.travel_start_date;
    SET new_end = DATE_ADD(new_start, INTERVAL pkg_duration - 1 DAY);

    -- Check for any overlapping bookings for the same user
    IF EXISTS (
        SELECT 1
        FROM booking b
        JOIN package p ON b.package_id = p.package_id
        WHERE b.user_id = NEW.user_id
          AND (
              (NEW.travel_start_date BETWEEN b.travel_start_date AND DATE_ADD(b.travel_start_date, INTERVAL p.duration_days - 1 DAY))
           OR (new_end BETWEEN b.travel_start_date AND DATE_ADD(b.travel_start_date, INTERVAL p.duration_days - 1 DAY))
           OR (b.travel_start_date BETWEEN new_start AND new_end)
          )
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'You already have a booking that overlaps these dates.';
    END IF;
END;
//
DELIMITER ;


DELIMITER //

CREATE PROCEDURE update_user_profile(
    IN p_user_id INT,
    IN p_name VARCHAR(255),
    IN p_email VARCHAR(255),
    IN p_phone VARCHAR(20)
)
BEGIN
    -- Check if the new email belongs to another user
    IF EXISTS (
        SELECT 1 FROM user 
        WHERE email = p_email AND user_id <> p_user_id
    ) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Email is already in use by another account.';
    ELSE
        UPDATE user
        SET name = p_name,
            email = p_email,
            phone = p_phone
        WHERE user_id = p_user_id;
    END IF;
END //

DELIMITER ;

DELIMITER //
CREATE TRIGGER trg_payment_audit
AFTER INSERT ON payment
FOR EACH ROW
BEGIN
    INSERT INTO payment_audit (
        payment_id, booking_id, amount, payment_date, method, action_type
    )
    VALUES (
        NEW.payment_id, NEW.booking_id, NEW.amount, NEW.payment_date, NEW.method, 'INSERT'
    );
END;
//
DELIMITER ;

