const { isTokenValid } = require('../utils/jwt');
const UnauthenticatedError  = require('../errors/unauthenticated')

const authenticateUser = async (req, res, next) => {
  const token = req.signedCookies.token;

  if (!token) {
    throw new UnauthenticatedError('Authentication Invalid');
  }

  try {
    const { id, role } = isTokenValid({ token });
    req.user = { id, role };
    next();
  } catch (error) {
    throw new UnauthenticatedError('Authentication Invalid');
  }
};


module.exports = authenticateUser 
