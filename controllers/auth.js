const { StatusCodes } = require('http-status-codes')
const { BadRequestError, UnauthenticatedError } = require('../errors/index')
const { attachCookiesToResponse} = require('../utils/jwt')
const bcrypt = require('bcryptjs');


const login = async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    throw new BadRequestError('Please provide username and password');
  }

  if ( username != process.env.USER){
    console.log(process.env.USER);
    throw new UnauthenticatedError('Username or Password is wrong 1');
  }
  const isPasswordCorrect = await bcrypt.compare(password, process.env.PASSWORD);
  if (!isPasswordCorrect) {
    throw new UnauthenticatedError('Username or Password is wrong');
  }
  
  attachCookiesToResponse({ res, user: {id:12345678 , role:'admin'} });

  res.status(StatusCodes.OK).json({ msg: 'Login successful!' ,user: {id:12345678 , role:'admin'} });
};

const logout = async (req, res) => {
  res.cookie('token', 'logout', {
    httpOnly: true,
    expires: new Date(Date.now() + 1000),
  });
  res.status(StatusCodes.OK).json({ msg: 'User logged out!' });
};

module.exports = {
  login,
  logout,
};
