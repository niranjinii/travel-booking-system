const path = require("path");

const express = require("express");
const bcrypt = require("bcrypt");
const session = require("express-session");
const flash = require("connect-flash");

const db = require("./database.js");
const { isAdmin, isAuthenticated } = require("./middleware.js");
const { imageMap } = require("./app-image-addon.js");

//const blogRoutes = require('./routes/blog');

const app = express();

app.use(flash());

app.use(
  session({
    secret: "your-secret-key",
    resave: false,
    saveUninitialized: false,
  })
);

app.use((req, res, next) => {
  res.locals.message = req.session.message || null;
  delete req.session.message;
  next();
});

// Activate EJS view engine
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.use(express.urlencoded({ extended: true })); // Parse incoming request bodies
app.use(express.static("public")); // Serve static files (e.g. CSS files)

app.get("/", async (req, res) => {
  try {
    const [topPackages] = await db.query("SELECT * FROM top_3_packages");

    topPackages.forEach((p) => {
      p.image =
        imageMap[p.package_id] ||
        "https://via.placeholder.com/300x200?text=Travel";
    });

    res.render("index", {
      page: "index",
      user: req.session.user || null,
      topPackages,
    });
  } catch (err) {
    console.error("Error loading homepage:", err);
    res.render("index", {
      page: "index",
      user: req.session.user || null,
      topPackages: [],
    });
  }
});

app.get("/packages", async function (req, res) {
  try {
    const { q, theme, days, price } = req.query;

    let query = `SELECT DISTINCT p.* FROM package p
                 LEFT JOIN package_destination pd ON p.package_id = pd.package_id
                 LEFT JOIN destination d ON pd.destination_id = d.destination_id
                 WHERE 1`;
    const params = [];

    // Theme Filter
    if (theme && theme.trim() !== "") {
      query += ` AND p.theme = ?`;
      params.push(theme);
    }

    // Search Filter
    if (q && q.trim() !== "") {
      const pattern = `%${q}%`;
      query += ` AND (p.package_name LIKE ? OR p.description LIKE ? OR d.name LIKE ?)`;
      params.push(pattern, pattern, pattern);
    }

    // Days Filter
    if (days) {
      if (days === "1-3") query += ` AND p.duration_days BETWEEN 1 AND 3`;
      else if (days === "4-7") query += ` AND p.duration_days BETWEEN 4 AND 7`;
      else if (days === "8+") query += ` AND p.duration_days >= 8`;
    }

    // Price Filter
    // Price Filter
    if (price) {
      if (price === "<30000") query += ` AND p.price < 30000`;
      else if (price === "30000-60000")
        query += ` AND p.price BETWEEN 30000 AND 60000`;
      else if (price === ">60000") query += ` AND p.price > 60000`;
    }

    const [packages] = await db.query(query, params);

    // Attach Images
    packages.forEach((p) => {
      p.image =
        imageMap[p.package_id] ||
        "https://via.placeholder.com/300x200?text=Travel+Package";
    });

    const [themes] = await db.query("SELECT DISTINCT theme FROM package");

    res.render("packages", {
      page: "packages",
      packages,
      themes,
      user: req.session.user || null,
      selectedTheme: theme || "",
      searchQuery: q || "",
      selectedDays: days || "",
      selectedPrice: price || "",
    });
  } catch (err) {
    console.error("Error fetching packages:", err);
    res.status(500).render("500");
  }
});

app.get("/login", function (req, res) {
  res.render("login", { page: "login", user: req.session.user || null });
});

app.get("/signup", function (req, res) {
  res.render("register", { page: "register", user: req.session.user || null });
});

app.post("/register", async (req, res) => {
  const { name, email, phone, password, confirmPassword } = req.body;

  // Confirm Password Match
  if (password !== confirmPassword) {
    req.session.message = { type: "error", text: "Passwords do not match!" };
    return res.redirect("/signup");
  }

  // Phone number validation (must be 10 digits)
  if (!/^[0-9]{10}$/.test(phone)) {
    req.session.message = {
      type: "error",
      text: "Phone number must be 10 digits.",
    };
    return res.redirect("/signup");
  }

  // Password validation: ≥8 chars + at least 1 uppercase
  if (password.length < 8 || !/[A-Z]/.test(password)) {
    req.session.message = {
      type: "error",
      text: "Password must be at least 8 characters and contain one uppercase letter.",
    };
    return res.redirect("/signup");
  }

  try {
    const [existingUser] = await db.query(
      "SELECT * FROM user WHERE email = ?",
      [email]
    );

    if (existingUser.length > 0) {
      req.session.message = {
        type: "error",
        text: "Email already registered!",
      };
      return res.redirect("/signup");
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    await db.query(
      "INSERT INTO user (name, email, password, phone) VALUES (?, ?, ?, ?)",
      [name, email, hashedPassword, phone]
    );

    req.session.message = {
      type: "success",
      text: "Account created! Please login.",
    };
    res.redirect("/login");
  } catch (err) {
    console.error(err);
    req.session.message = { type: "error", text: "Registration failed." };
    res.redirect("/signup");
  }
});

app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const [rows] = await db.query("SELECT * FROM user WHERE email = ?", [
      email,
    ]);

    if (rows.length === 0) {
      req.session.message = {
        type: "error",
        text: "Invalid email or password.",
      };
      return res.redirect("/login");
    }

    const user = rows[0];
    const match = await bcrypt.compare(password, user.password);

    if (!match) {
      req.session.message = {
        type: "error",
        text: "Invalid email or password.",
      };
      return res.redirect("/login");
    }

    if (req.session.user) {
      req.session.destroy(() => {
        // Recreate session for the new login
        req.session = null;
      });
    }

    // Store user info in session
    req.session.user = {
      id: user.user_id,
      name: user.name,
      email: user.email,
      role: user.role,
    };

    if (user.role === "admin") {
      res.redirect("/admin/dashboard");
    } else {
      res.redirect("/");
    }
  } catch (err) {
    console.error(err);
    req.session.message = { type: "error", text: "Something went wrong." };
    res.redirect("/login");
  }
});

app.post("/logout", (req, res) => {
  req.session.destroy((err) => {
    if (err) console.error(err);
    res.redirect("/");
  });
});

app.get("/payment", async (req, res) => {
  try {
    const { package_id, travelers, date } = req.query;
    if (!package_id || !travelers) {
      return res.redirect("/packages");
    }

    // Fetch package details
    const [packageRows] = await db.query(
      `SELECT * FROM package WHERE package_id = ?`,
      [package_id]
    );
    if (!packageRows.length) {
      return res.status(404).send("Package not found");
    }
    const packageData = packageRows[0];

    // Fetch transport options
    const [transportRows] = await db.query(
      `SELECT t.transport_id, t.mode, t.company, t.price
       FROM package_transport pt
       JOIN transport t ON pt.transport_id = t.transport_id
       WHERE pt.package_id = ?`,
      [package_id]
    );

    // Apply group discount
    const [[{ discount }]] = await db.query(
      "SELECT calculate_discount(?) AS discount",
      [travelers]
    );

    // Calculate min date for travel (7 days from today)
    const minDateObj = new Date();
    minDateObj.setDate(minDateObj.getDate() + 7);
    const minDate = minDateObj.toISOString().split("T")[0];

    res.render("payment", {
      package: packageData,
      travelers,
      transports: transportRows,
      discount: (discount * 100).toFixed(0),
      date: date,
      minDate, // pass minDate
      page: "payment",
      user: req.session.user || null,
      message: req.session.message || null, // flash message
    });

    // Clear flash message
    req.session.message = null;
  } catch (err) {
    console.error(err);
    req.session.message = {
      type: "error",
      text: "Booking failed. Please try again",
    };
    res.redirect("/packages");
  }
});

app.get("/package/:id", async function (req, res) {
  try {
    const id = req.params.id;

    const [pkgRows] = await db.query(
      "SELECT * FROM package WHERE package_id = ?",
      [id]
    );
    if (pkgRows.length === 0) return res.status(404).render("404");

    const pkg = pkgRows[0];
    pkg.image =
      imageMap[pkg.package_id] ||
      "https://via.placeholder.com/500x350?text=Travel+Package";

    const [transportRows] = await db.query(
      `SELECT t.transport_id, t.mode, t.company, t.price
       FROM package_transport pt
       JOIN transport t ON pt.transport_id = t.transport_id
       WHERE pt.package_id = ?`,
      [id]
    );

    const [destRows] = await db.query(
      `SELECT d.name, d.location, pd.sequence_no
       FROM package_destination pd
       JOIN destination d ON pd.destination_id = d.destination_id
       WHERE pd.package_id = ?
       ORDER BY pd.sequence_no`,
      [id]
    );

    res.render("package-details", {
      package: pkg,
      destinations: destRows,
      destinationList: destRows.map((d) => d.name).join(", "),
      transports: transportRows,
      page: `package/${id}`,
      user: req.session.user || null,
      date: req.query.date || "",
    });
  } catch (err) {
    console.error("Error fetching package details:", err);
    res.status(500).render("500");
  }
});

app.get("/profile", isAuthenticated, async (req, res) => {
  try {
    const userId = req.session.user.id;

    const [userResults] = await db.query(
      "SELECT name, email, phone FROM user WHERE user_id = ?",
      [userId]
    );

    if (userResults.length === 0) return res.redirect("/login");

    const user = {
      name: userResults[0].name,
      email: userResults[0].email,
      phone: userResults[0].phone,
    };

    const [bookingResults] = await db.query(
      "SELECT * FROM user_bookings_view WHERE user_id = ?",
      [userId]
    );

    const bookings = bookingResults.map((b) => ({
      booking_id: b.booking_id,
      package_name: b.package_name,
      booking_date: b.booking_date
        ? new Date(b.booking_date).toISOString().split("T")[0]
        : "N/A",
      travel_start_date: b.travel_start_date
        ? new Date(b.travel_start_date).toISOString().split("T")[0]
        : "N/A",
      numtravelers: b.numtravelers,
      total_price: b.price * b.numtravelers,
      image:
        imageMap[b.package_id] ||
        "https://via.placeholder.com/300x200?text=Travel",
    }));

    res.render("profile", {
      user,
      bookings,
      page: "profile",
    });
  } catch (err) {
    console.error("❌ Error loading profile:", err);
    res.status(500).render("500");
  }
});

app.post("/process-payment", isAuthenticated, async (req, res) => {
  try {
    const userId = req.session.user.id; //|| request.session.user_id;

    // Ensure user is logged in
    if (!userId) {
      req.session.message = {
        type: "error",
        text: "Please login to continue.",
      };
      return res.redirect("/login");
    }

    const { package_id, travelers, method, transport_id, travel_start_date } =
      req.body;

    // Validate required fields
    if (
      !package_id ||
      !travelers ||
      !transport_id ||
      !method ||
      !travel_start_date
    ) {
      req.session.message = {
        type: "error",
        text: "Please select all required details before proceeding.",
      };
      return res.redirect(
        `/payment?package_id=${package_id}&travelers=${travelers}&date=${travel_start_date}`
      );
    }

    // Validate travelers
    if (isNaN(travelers) || travelers < 1) {
      req.session.message = {
        type: "error",
        text: "Invalid number of travelers.",
      };
      return res.redirect(`/packages`);
    }

    if (transport_id === "" || transport_id === "0") {
      req.session.message = {
        type: "error",
        text: "Please select a transport option.",
      };
      return res.redirect("back");
    }

    if (method.trim() === "") {
      req.session.message = {
        type: "error",
        text: "Please select a payment method.",
      };
      return res.redirect("back");
    }

    const travelDate = new Date(travel_start_date);
    const minAllowed = new Date();
    minAllowed.setDate(minAllowed.getDate() + 7);

    if (travelDate < minAllowed) {
      req.session.message = {
        type: "error",
        text: "Travel date must be at least 7 days from today.",
      };
      return res.redirect(`/package/${package_id}`);
    }

    const [[{ price: basePrice }]] = await db.query(
      "SELECT price FROM package WHERE package_id = ?",
      [package_id]
    );

    const [[{ price: transportPrice }]] = await db.query(
      "SELECT price FROM transport WHERE transport_id = ?",
      [transport_id]
    );

    const [[{ discount }]] = await db.query(
      "SELECT calculate_discount(?) AS discount",
      [travelers]
    );

    const [[{ totalPrice }]] = await db.query(
      "SELECT calculate_total_price(?, ?, ?, ?) AS totalPrice",
      [basePrice, travelers, transportPrice, discount]
    );

    await db.query("CALL create_booking_and_payment(?, ?, ?, ?, ?, ?, ?, ?)", [
      userId,
      package_id,
      new Date().toISOString().split("T")[0],
      travel_start_date,
      transport_id,
      travelers,
      totalPrice,
      method,
    ]);

    req.session.message = {
      type: "success",
      text: "Payment completed successfully!",
    };
    return res.redirect("/profile");
  } catch (err) {
    console.error(err);

    const redirectUrl = `/package/${req.body.package_id}`;

    // Check if the error comes from our trigger (overlapping booking)
    if (err.sqlState === "45000") {
      req.session.message = {
        type: "error",
        text:
          err.sqlMessage ||
          "You already have a booking that overlaps these dates.",
      };
    } else {
      req.session.message = {
        type: "error",
        text: "Payment failed. Please try again.",
      };
    }

    return res.redirect(redirectUrl);
  }
});

app.get("/booking/:id", isAuthenticated, async (req, res) => {
  try {
    const bookingId = req.params.id;
    const userId = req.session.user.id;

    // Fetch booking details joined with package and payment
    const [results] = await db.query(
      `SELECT 
        b.booking_id,
        b.booking_date,
        b.travel_start_date,
        b.numtravelers,
        p.package_name,
        p.price,
        pay.method AS payment_method,
        pay.amount AS payment_amount
      FROM booking b
      JOIN package p ON b.package_id = p.package_id
      LEFT JOIN payment pay ON b.booking_id = pay.booking_id
      WHERE b.booking_id = ? AND b.user_id = ?`,
      [bookingId, userId]
    );

    if (results.length === 0) {
      return res.status(404).render("404", { message: "Booking not found." });
    }

    const booking = results[0];

    // Format the booking object for EJS
    const bookingData = {
      id: booking.booking_id,
      packageName: booking.package_name,
      date: booking.booking_date
        ? new Date(booking.booking_date).toISOString().split("T")[0]
        : "N/A",
      travelDate: booking.travel_start_date
        ? new Date(booking.travel_start_date).toISOString().split("T")[0]
        : "N/A",
      people: booking.numtravelers,
      totalPrice:
        booking.payment_amount || booking.price * booking.numtravelers,
      paymentMethod: booking.payment_method || "N/A",
    };

    // Render booking-details.ejs
    res.render("booking-details", {
      booking: bookingData,
      page: "booking-details",
      user: req.session.user || null,
    });
  } catch (err) {
    console.error("Error fetching booking details:", err);
    res.status(500).render("500", {
      message: "Server error while loading booking details.",
    });
  }
});

app.post("/booking/:id/cancel", isAuthenticated, async (req, res) => {
  try {
    const bookingId = req.params.id;
    const userId =
      req.session.user && (req.session.user.id || req.session.user.user_id);
    if (!userId) return res.redirect("/login");

    const [checkBooking] = await db.query(
      "SELECT * FROM booking WHERE booking_id = ? AND user_id = ?",
      [bookingId, userId]
    );

    if (checkBooking.length === 0) {
      req.session.message = {
        type: "error",
        text: "Unauthorized or booking not found.",
      };
      return res.redirect("/profile");
    }

    await db.query("CALL cancel_booking(?, ?)", [bookingId, userId]);

    req.session.message = {
      type: "success",
      text: "Booking canceled successfully.",
    };
    res.redirect("/profile");
  } catch (err) {
    console.error("Error canceling booking:", err);
    req.session.message = {
      type: "error",
      text: "Server error while canceling booking.",
    };
    res.redirect("/profile");
  }
});

app.post("/update-profile", isAuthenticated, async (req, res) => {
  const { name, email, phone } = req.body;
  const userId = req.session.user.id;

   if (phone && !/^[0-9]{10}$/.test(phone)) {
    req.session.message = {
      type: "error",
      text: "Phone number must be exactly 10 digits.",
    };
    return res.redirect("/profile");
  }

  try {
    await db.query("CALL update_user_profile(?, ?, ?, ?)", [
      userId,
      name,
      email,
      phone || null,
    ]);

    // ✅ Update session data
    req.session.user.name = name;
    req.session.user.email = email;
    req.session.user.phone = phone;

    req.session.message = {
      type: "success",
      text: "Profile updated successfully!",
    };
  } catch (err) {
    console.log("Update error:", err);

    req.session.message = {
      type: "error",
      text: "Could not update profile. Try again.",
    };

    return res.redirect("/profile");
  }
});

// Admin dashboard route
app.get("/admin/dashboard", isAdmin, async (req, res) => {
  try {
    const [[{ userCount }]] = await db.query(
      "SELECT COUNT(*) AS userCount FROM user"
    );
    const [[{ bookingCount }]] = await db.query(
      "SELECT COUNT(*) AS bookingCount FROM booking"
    );
    const [[{ packageCount }]] = await db.query(
      "SELECT COUNT(*) AS packageCount FROM package"
    );
    const [[{ totalRevenue }]] = await db.query(
      "SELECT TotalRevenue() AS totalRevenue"
    );

    // Nested query: Avg booking value per package (Top 3)
    const [avgPackages] = await db.query(`
      SELECT p.package_name, 
             (SELECT AVG(pay.amount)
              FROM Payment pay
              JOIN Booking b2 ON pay.booking_id = b2.booking_id
              WHERE b2.package_id = p.package_id) AS avg_value
      FROM Package p
      ORDER BY avg_value DESC
      LIMIT 5;
    `);

    // Procedure: Top 3 spending users
    const [topUsers] = await db.query("CALL TopSpendingUsers()");

    // Fetch payment history (audit trail)
    const [paymentAudit] = await db.query(`
      SELECT audit_id, payment_id, booking_id, amount, method, action_type, action_date
      FROM payment_audit
      ORDER BY action_date DESC
      LIMIT 20; -- show recent 20 entries for clarity
    `);
    const [monthlyStats] = await db.query(`
  SELECT 
    DATE_FORMAT(payment_date, '%b') AS month,
    SUM(amount) AS total
  FROM payment
  GROUP BY DATE_FORMAT(payment_date, '%b'), MONTH(payment_date)
  ORDER BY MONTH(payment_date);
`);

    res.render("admin-dashboard", {
      page: "admin-dashboard",
      user: req.session.user || null,
      stats: { userCount, bookingCount, packageCount, totalRevenue },
      avgPackages,
      paymentAudit,
      topUsers: topUsers[0],
      monthlyStats,
    });
  } catch (err) {
    console.error(err);
    res.status(500).render("500");
  }
});

app.get("/about", (req, res) => {
  res.render("about", { page: "about", user: req.session.user || null });
});

// 404 Handler
app.use((req, res) => {
  res
    .status(404)
    .render("404", { page: "404", user: req.session.user || null });
});

// 500 Error Handler
app.use((err, req, res, next) => {
  console.error(err);
  res
    .status(500)
    .render("500", { page: "500", user: req.session.user || null });
});

app.listen(3000);
