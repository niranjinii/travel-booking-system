const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: 'localhost',
    database: 'travel_booking',
    user: 'root',
    password: 'hani0812!'
});

module.exports = pool;