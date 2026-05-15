const { getScopedClient } = require('../config/supabase');
const AppError = require('../utils/AppError');
const catchAsync = require('../utils/catchAsync');

const protect = catchAsync(async (req, res, next) => {
  let token;
  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    return next(new AppError('You are not logged in. Please log in to get access.', 401));
  }

  const client = await getScopedClient(token);
  const { data: { user }, error } = await client.auth.getUser(token);

  if (error || !user) {
    return next(new AppError('Invalid token or session expired.', 401));
  }

  req.user = user;
  next();
});

module.exports = { protect };
