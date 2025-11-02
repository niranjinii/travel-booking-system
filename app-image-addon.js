app.get("/packages", async (req, res) => {
  try {
    const [packages] = await db.query("SELECT * FROM Package");

    // map images manually (ensure files exist in /public/images)
    const imageMap = {
      "Golden Triangle Tour": "/images/golden_triangle.jpg",
      "Goa Beach Getaway": "/images/goa.jpg",
      "Himalayan Adventure": "/images/himalaya.jpg",
      "Kerala Backwaters": "/images/kerala.jpg",
      "Europe Explorer": "/images/europe.jpg",
      "Japan Discovery": "/images/japan.jpg",
      // add all your packages here
    };

    const withImages = packages.map((pkg) => ({
      ...pkg,
      image: imageMap[pkg.package_name] || "/images/default.jpg",
    }));

    // distinct themes for dropdown
    const [themes] = await db.query("SELECT DISTINCT theme FROM Package");

    res.render("packages", { page: "packages", packages: withImages, themes });
  } catch (err) {
    console.error(err);
    res.status(500).send("Error loading packages");
  }
});
