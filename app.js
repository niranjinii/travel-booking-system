const path = require("path");

const express = require("express");

//const blogRoutes = require('./routes/blog');

const app = express();

// Activate EJS view engine
app.set("view engine", "ejs");
app.set("views", path.join(__dirname, "views"));

app.use(express.urlencoded({ extended: true })); // Parse incoming request bodies
app.use(express.static("public")); // Serve static files (e.g. CSS files)

app.get("/", function (req, res) {
  res.render("index", { page: "index" });
});

app.get("/packages", function (req, res) {
  res.render("packages", { page: "packages" });
});

app.get("/login", function (req, res) {
  res.render("login", { page: "login" });
});

app.get("/signup", function (req, res) {
  res.render("register", { page: "register" });
});

app.get("/destinations", function (req, res) {
  res.render("destinations", { page: "destinations" });
});

app.get("/payment", (req, res) => {
  const booking = {
    packageName: "Discover Japan: Tokyo to Kyoto",
    date: "2025-11-15",
    people: 2,
    totalPrice: 4200,
  };

  res.render("payment", { booking, page: 'payment'});
});

app.get("/package/:id", (req, res) => {
  const dummyPackage = {
    id: 1,
    name: "Enchanting Europe Getaway",
    location: "France, Switzerland, Italy",
    description:
      "Discover the charm of Europe with guided city tours, breathtaking landscapes, and cultural adventures across France, Switzerland, and Italy. Perfect for travelers seeking elegance, history, and adventure.",
    duration: "10 Days / 9 Nights",
    price: 1899,
    category: "Luxury Tour",
    image: "/images/carousel1.jpg",
    gallery: [
      "/images/eiffel-tower.jpg",
      "/images/switzerland-lake.jpg",
      "/images/venice.jpg",
    ],
  };

  res.render("package-details", {
    package: dummyPackage,
    page: `package/{$id}`,
  });
});

app.get("/profile", (req, res) => {
  const user = {
    name: "Ava Williams",
    email: "ava.williams@example.com",
    avatar: "https://i.pravatar.cc/150?img=47"
  };

  const bookings = [
    {
      packageId: 1,
      packageName: "Explore Bali Paradise",
      date: "2025-11-22",
      people: 2,
      totalPrice: 2800,
      image: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e"
    },
    {
      packageId: 2,
      packageName: "Swiss Alps Adventure",
      date: "2026-01-10",
      people: 4,
      totalPrice: 5200,
      image: "https://images.unsplash.com/photo-1506744038136-46273834b3fb"
    }
  ];

  res.render("profile", { user, bookings, page: 'profile' });
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


app.use(function (error, req, res, next) {
  // Default error handling function
  // Will become active whenever any route / middleware crashes
  console.log(error);
  res.status(500).render("500");
});

app.listen(3000);
