-- ===========================
-- 1. User Table
-- ===========================
CREATE TABLE User (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20)
);

-- ===========================
-- 2. Destination Table
-- ===========================
CREATE TABLE Destination (
    destination_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    location VARCHAR(100),
    description TEXT
);

-- ===========================
-- 3. Package Table
-- ===========================
CREATE TABLE Package (
    package_id INT PRIMARY KEY AUTO_INCREMENT,
    destination_id INT NOT NULL,
    package_name VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    duration_days INT,
    FOREIGN KEY (destination_id) REFERENCES Destination(destination_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ===========================
-- 4. Transport Table
-- ===========================
CREATE TABLE Transport (
    transport_id INT PRIMARY KEY AUTO_INCREMENT,
    mode VARCHAR(50) NOT NULL,           -- e.g. flight, train, bus
    company VARCHAR(100),
    price DECIMAL(10,2)
);

-- ===========================
-- 5. Package_Transport Table (M:N relationship)
-- ===========================
CREATE TABLE Package_Transport (
    package_id INT,
    transport_id INT,
    PRIMARY KEY (package_id, transport_id),
    FOREIGN KEY (package_id) REFERENCES Package(package_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (transport_id) REFERENCES Transport(transport_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ===========================
-- 6. Booking Table
-- ===========================
CREATE TABLE Booking (
    booking_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    package_id INT NOT NULL,
    transport_id INT NOT NULL,
    booking_date DATE NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (user_id) REFERENCES User(user_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (package_id) REFERENCES Package(package_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (transport_id) REFERENCES Transport(transport_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ===========================
-- 7. Payment Table
-- ===========================
CREATE TABLE Payment (
    payment_id INT PRIMARY KEY AUTO_INCREMENT,
    booking_id INT UNIQUE NOT NULL,      -- 1:1 with booking
    amount DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    method VARCHAR(50),                  -- e.g. credit card, UPI
    FOREIGN KEY (booking_id) REFERENCES Booking(booking_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);
