const User = require('../models/User')
const { StatusCodes } = require('http-status-codes')
const { BadRequestError, UnauthenticatedError } = require('../../errors/index')
const { attachCookiesToResponse} = require('../utils/jwt')


const login = async (req, res) => {
  const { username, password } = req.body;

  if (!username || !password) {
    throw new BadRequestError('Please provide username and password');
  }
  const user = await User.findOne({ username });

  if ( user != process.env.USERNAME){
    throw new UnauthenticatedError('Username or Password is wrong');
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
