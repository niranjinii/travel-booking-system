const path = require("path");

const express = require("express");
const bcrypt = require("bcrypt");
const session = require("express-session");

const db = require("./database.js");
const { isAuthenticated } = require('./middleware.js');

//const blogRoutes = require('./routes/blog');

const app = express();

app.use(
  session({
    secret: "your-secret-key",
    resave: false,
    saveUninitialized: false,
  })
);

// Activate EJS view engine
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.use(express.urlencoded({ extended: true })); // Parse incoming request bodies
app.use(express.static("public")); // Serve static files (e.g. CSS files)

app.get("/", function (req, res) {
  res.render("index", { page: "index" });
});

app.get("/packages", async function (req, res) {
  try {
    const { q, theme } = req.query;
    let query = `SELECT DISTINCT p.* FROM package p
                 LEFT JOIN Package_Destination pd ON p.package_id = pd.package_id
                 LEFT JOIN Destination d ON pd.destination_id = d.destination_id
                 WHERE 1`;
    const params = [];
    if (theme && theme.trim() !== "") {
      query += ` AND p.theme = ?`;
      params.push(theme);
    }
    if (q && q.trim() !== "") {
      query += ` AND (p.package_name LIKE ? OR p.description LIKE ? OR d.name LIKE ?)`;
      const pattern = `%${q}%`;
      params.push(pattern, pattern, pattern);
    }

    const [packages] = await db.query(query, params);
    const [themes] = await db.query("SELECT DISTINCT theme FROM package");
    res.render("packages", {
      page: "packages",
      packages,
      themes,
      selectedTheme: theme || "",
      searchQuery: q || "",
    });
  } catch (err) {
    console.error("Error fetching packages:", err);
    res.status(500).send("Internal Server Error");
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
    return res.send("Passwords do not match!");
  }

  try {
    const [existingUser] = await db
      .query("SELECT * FROM user WHERE email = ?", [email]);

    if (existingUser.length > 0) {
      return res.send("Email already registered!");
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    await db
      .query("INSERT INTO user (name, email, password) VALUES (?, ?, ?)", [
        name,
        email,
        hashedPassword,
      ]);

    res.redirect("/login");
  } catch (err) {
    console.error(err);
    res.status(500).send("Error during registration");
  }
});

app.post("/login", async (req, res) => {
  const { email, password } = req.body;

  try {
    const [rows] = await db
      .query("SELECT * FROM user WHERE email = ?", [email]);

    if (rows.length === 0) {
      return res.send("Invalid email or password");
    }

    const user = rows[0];
    const match = await bcrypt.compare(password, user.password);

    if (!match) {
      return res.send("Invalid email or password");
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
    res.status(500).send("Error during login");
  }
});

app.get("/logout", (req, res) => {
  req.session.destroy((err) => {
    if (err) console.error(err);
    res.redirect("/login");
  });
});

app.get("/destinations", function (req, res) {
  res.render("destinations", { page: "destinations" });
});

app.get("/payment", async (req, res) => {
  try {
    const { package_id, travelers } = req.query;
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
      page: "payment",
    });
  } catch (err) {
    console.error(err);
    res.status(500).send("Internal Server Error");
  }
});

app.get("/package/:id", async function (req, res) {
  try {
    const id = req.params.id;
    // Fetch package details
    const [pkgRows] = await db.query(
      "SELECT * FROM package WHERE package_id = ?",
      [id]
    );
    if (pkgRows.length === 0) {
      return res.status(404).send("Package not found");
    }

    const pkg = pkgRows[0];

    const [transportRows] = await db.query(
      `SELECT t.mode, t.company, t.price
      FROM package_transport pt
      JOIN transport t ON pt.transport_id = t.transport_id
      WHERE pt.package_id = ?`,
      [id]
    );

    // Fetch destinations for the package (ordered by sequence_no)
    const [destRows] = await db.query(
      `SELECT d.name, d.location, pd.sequence_no
       FROM package_destination pd
       JOIN destination d ON pd.destination_id = d.destination_id
       WHERE pd.package_id = ?
       ORDER BY pd.sequence_no`,
      [id]
    );

    const destinationList = destRows.map((d) => d.name).join(", ");

    // Render page with both package and its destinations
    res.render("package-details", {
      package: pkg,
      destinations: destRows,
      destinationList: destinationList,
      transports: transportRows,
      page: `package/${id}`,
    });
  } catch (err) {
    console.error("Error fetching package details:", err);
    res.status(500).send("Internal Server Error");
  }
});

app.get("/profile", isAuthenticated, async (req, res) => {
  try {
    const userId = req.session.user.id; // make sure it's .id not .user_id
    console.log("✅ /profile route hit");
    console.log("🔹 Session userId:", userId);

    // Query user info
    const [userResults] = await db.query(
      "SELECT name, email FROM user WHERE user_id = ?",
      [userId]
    );

    if (userResults.length === 0) {
      return res.redirect("/login");
    }

    const user = {
      name: userResults[0].name,
      email: userResults[0].email,
      avatar: "https://i.pravatar.cc/150", // placeholder
    };

    // Query bookings
    const [bookingResults] = await db.query(
      `SELECT 
        b.booking_id,
        b.package_id,
        b.travel_start_date AS date,
        b.numtravelers AS people,
        p.package_name AS packageName,
        p.price AS totalPrice
      FROM booking b
      JOIN package p ON b.package_id = p.package_id
      WHERE b.user_id = ?`,
      [userId]
    );

    const bookings = bookingResults.map((b) => ({
      packageId: b.package_id,
      packageName: b.packageName,
      date: b.date,
      people: b.people,
      totalPrice: b.totalPrice * b.people,
      image: "https://via.placeholder.com/300x200?text=Travel+Package",
    }));

    res.render("profile", { user, bookings, page: "profile" });
  } catch (err) {
    console.error("❌ Error loading profile:", err);
    res.status(500).send("Server error");
  }
});




app.get("/booking/:id", (req, res) => {
  const booking = {
    id: 1,
    packageName: "Santorini Escape",
    destination: "Santorini, Greece",
    date: "2025-12-15",
    people: 2,
    totalPrice: 2400,
    status: "Paid",
  };
  res.render("booking-details", { booking, page: `booking/{$id}` });
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
  res.render("admin-dashboard", { packages, page: "admin" });
});

app.use(function (error, req, res, next) {
  // Default error handling function
  // Will become active whenever any route / middleware crashes
  console.log(error);
  res.status(500).render("500");
});


app.listen(3000);
