# ✈️ Travel Booking System

This is a full-stack web application for a travel booking and package management system. It provides a complete portal for users to browse, book, and manage travel packages, and a separate, powerful dashboard for administrators to manage the platform's data.

The application is built with a **Node.js/Express** backend, a **MySQL** database, and **EJS** for server-side rendering.

## ✨ Key Features

* **User Authentication:** Secure user registration and login with password hashing (bcrypt).
* **Package Browsing:** View all travel packages with dynamic server-side filtering (by price, duration, theme) and search.
* **Booking System:** A complete booking flow, including transport selection, traveler-based discounts, and payment processing.
* **Profile Management:** Users can view their booking history, manage (update) their profile, and cancel upcoming bookings.
* **Admin Dashboard:** A private admin route (`/admin/dashboard`) showing:
    * Key statistics (Total Users, Total Bookings, Total Revenue).
    * Top-spending users.
    * Average booking value per package.
    * A live payment audit log.
* **Advanced Database Logic:** The system relies on a robust set of database-level logic to ensure data integrity.
    * **Triggers:** Automatically prevent overlapping bookings and create a payment audit trail.
    * **Procedures:** Handle complex transactions like creating a booking + payment in one go (`create_booking_and_payment`).
    * **Functions:** Centralize business logic like calculating discounts (`calculate_discount`) and total revenue.

## 🛠️ Tech Stack

* **Backend:** Node.js, Express.js
* **Database:** MySQL
* **Frontend:** EJS (Embedded JavaScript), HTML5, CSS3
* **Core Libraries:** `mysql2`, `bcrypt`, `express-session`, `connect-flash`

## Database Features

This project heavily utilizes advanced MySQL features:

* **Stored Procedures:** `create_booking_and_payment`, `cancel_booking`, `update_user_profile`, `TopSpendingUsers`
* **Stored Functions:** `calculate_discount`, `calculate_total_price`, `TotalRevenue`, `TotalSpentByUser`
* **Triggers:** `prevent_overlapping_bookings`, `trg_payment_audit`
* **Views:** `top_3_packages`, `user_bookings_view`
* **Advanced Queries:** Nested/Correlated Subqueries, Joins (LEFT, INNER), and Aggregate Queries (COUNT, SUM, AVG, GROUP BY).

## 🚀 Getting Started

### Prerequisites

* Node.js (v14+)
* MySQL Server

### Installation & Setup

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/niranjinii/travel-booking-system.git
    cd travel-booking-system
    ```

2.  **Install NPM packages:**
    ```bash
    npm install
    ```

3.  **Set up the Database:**
    * Create a new MySQL database.
    * Configure your database credentials in `database.js`.
    * Run the SQL scripts in the `/sql` folder in this order:
        1.  `schema.sql` (to create the tables)
        2.  `inserts.sql` (to add sample data)
        3.  `queries.sql` (to create all procedures, functions, triggers)

4.  **Run the application:**
    ```bash
    npm start
    ```
    The server will start on `http://localhost:3000`.