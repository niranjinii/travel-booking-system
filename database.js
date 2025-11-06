const mysql = require('mysql2/promise');

const pool = mysql.createPool({
    host: 'localhost',
    database: 'travel_booking',
    user: 'root',
    password: 'njhjgh47'
});

module.exports = pool;