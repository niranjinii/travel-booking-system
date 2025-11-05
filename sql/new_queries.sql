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
