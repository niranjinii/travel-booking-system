const path = require("path");

const express = require("express");
const bcrypt = require("bcrypt");
const session = require("express-session");
const flash = require("connect-flash");

const db = require("./database.js");
const { isAuthenticated } = require("./middleware.js");
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
    const { q, theme } = req.query;

    let query = `SELECT DISTINCT p.* FROM package p
                 LEFT JOIN package_destination pd ON p.package_id = pd.package_id
                 LEFT JOIN destination d ON pd.destination_id = d.destination_id
                 WHERE 1`;
    const params = [];

    if (theme && theme.trim() !== "") {
      query += ` AND p.theme = ?`;
      params.push(theme);
    }
    if (q && q.trim() !== "") {
      const pattern = `%${q}%`;
      query += ` AND (p.package_name LIKE ? OR p.description LIKE ? OR d.name LIKE ?)`;
      params.push(pattern, pattern, pattern);
    }

    const [packages] = await db.query(query, params);

    // ✅ Attach images
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
    });
  } catch (err) {
    console.error("Error fetching packages:", err);
    res.status(500).render("500");
  }
});

app.get("/login", function (req, res) {
  res.render("login", { page: "login" });
});

app.get("/signup", function (req, res) {
  res.render("register", { page: "register" });
});

app.post("/register", async (req, res) => {
  const { name, email, password, confirmPassword } = req.body;

  if (password !== confirmPassword) {
    req.session.message = { type: "error", text: "Passwords do not match!" };
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
      "INSERT INTO user (name, email, password) VALUES (?, ?, ?)",
      [name, email, hashedPassword]
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
    };

    res.redirect("/"); // redirect to dashboard or homepage
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

    // Fetch transport options for this package
    const [transportRows] = await db.query(
      `SELECT t.transport_id, t.mode, t.company, t.price
       FROM package_transport pt
       JOIN transport t ON pt.transport_id = t.transport_id
       WHERE pt.package_id = ?`,
      [package_id]
    );
    // --- Calculate base total ---
    let basePrice = packageData.price * travelers;

    // --- Apply group discounts ---
    let discount = 0;
    if (travelers >= 4) discount = 0.15;
    else if (travelers === 3) discount = 0.1;
    else if (travelers === 2) discount = 0.05;

    const discountedPrice = basePrice * (1 - discount);

    res.render("payment", {
      package: packageData,
      travelers,
      transports: transportRows,
      totalPrice: discountedPrice.toFixed(2),
      discount: (discount * 100).toFixed(0),
      date: date,
      page: "payment",
      user: req.session.user || null,
    });
  } catch (err) {
    console.error(err);
    res.status(500).send("Internal Server Error");
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
      "SELECT name, email FROM user WHERE user_id = ?",
      [userId]
    );

    if (userResults.length === 0) return res.redirect("/login");

    const user = {
      name: userResults[0].name,
      email: userResults[0].email,
    };

    const [bookingResults] = await db.query(
      `SELECT 
        b.booking_id,
        b.booking_date,
        b.travel_start_date,
        b.numtravelers,
        p.package_id,
        p.package_name,
        p.price
      FROM booking b
      JOIN package p ON b.package_id = p.package_id
      WHERE b.user_id = ?`,
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

    // ✅ Take flash message and clear it
    const message = req.session.message || null;
    req.session.message = null;

    res.render("profile", {
      user,
      bookings,
      page: "profile",
      message,
    });
  } catch (err) {
    console.error("❌ Error loading profile:", err);
    res.status(500).render("500");
  }
});


app.post("/process-payment", async (req, res) => {
  try {
    const userId = req.session.user.id;
    if (!userId) {
      req.session.message = {
        type: "error",
        text: "Please log in to complete payment.",
      };
      return res.redirect("/login");
    }

    const {
      package_id,
      travelers,
      total,
      method,
      transport_id,
      travel_start_date,
    } = req.body;

    if (
      !package_id ||
      !travelers ||
      !total ||
      !method ||
      !transport_id ||
      !travel_start_date
    ) {
      req.session.message = {
        type: "error",
        text: "Missing booking or payment details.",
      };
      return res.redirect("/");
    }

    const currentDate = new Date().toISOString().split("T")[0];

    const [bookingResult] = await db.query(
      `INSERT INTO booking (user_id, package_id, booking_date, travel_start_date, transport_id, numtravelers)
       VALUES (?, ?, ?, ?, ?, ?)`,
      [
        userId,
        package_id,
        currentDate,
        travel_start_date,
        transport_id,
        travelers,
      ]
    );

    const bookingId = bookingResult.insertId;

    await db.query(
      `INSERT INTO payment (booking_id, amount, payment_date, method)
       VALUES (?, ?, ?, ?)`,
      [bookingId, total, currentDate, method]
    );

    req.session.message = {
      type: "success",
      text: "Payment completed successfully!",
    };
    res.redirect("/profile");
  } catch (err) {
    console.error(err);

    return res.render("payment", {
      page: "payment",
      user: req.session.user || null,
      message: { type: "error", text: "Payment failed. Please try again." },
    });
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

    await db.query("DELETE FROM booking WHERE booking_id = ?", [bookingId]);

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

app.get("/admin", (req, res) => {
  const packages = [
    {
      id: 1,
      name: "Santorini Escape",
      location: "Greece",
      price: 1200,
      duration: "5 days",
    },
    {
      id: 2,
      name: "Bali Adventure",
      location: "Indonesia",
      price: 950,
      duration: "6 days",
    },
    {
      id: 3,
      name: "Swiss Alps Tour",
      location: "Switzerland",
      price: 1800,
      duration: "8 days",
    },
  ];
  res.render("admin-dashboard", {
    packages,
    page: "admin",
    user: req.session.user || null,
  });
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
