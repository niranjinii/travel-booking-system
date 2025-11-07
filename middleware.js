function isAuthenticated(req, res, next) {
  if (req.session.user) {
    return next();
  }
  res.redirect("/login");
}

function isAdmin(req, res, next) {
  if (!req.session.user || req.session.user.role !== 'admin') {
    req.session.message = { type: 'error', text: 'Access denied: Admins only.' };
    return res.redirect('/');
  }
  next();
}

module.exports = { isAdmin, isAuthenticated };

