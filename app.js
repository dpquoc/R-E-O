require('dotenv').config();
require('express-async-errors');

const cookieParser = require('cookie-parser');
// extra security packages
const helmet = require('helmet');
const xss = require('xss-clean');


//express
const express = require('express');
const app = express();

//connect to database
const connectDB = require('./db/connect');

const authenticateUser = require('./middlewares/authentication');

// routers
const auth = require('./routes/auth');
const trainee = require('./routes/trainee');

// error handler
const notFoundMiddleware = require('./middlewares/not-found');
const errorHandlerMiddleware = require('./middlewares/error-handler');

//
//cookie and json body parsers
app.use(express.json());
app.use(cookieParser(process.env.JWT_SECRET));
//Extra security apply
app.use(helmet());
app.use(xss());



app.get('/', (req, res) => {
  res.send('<h1>UWC2.0</h1><a href="/api-docs">API Documentation</a>');
});
//routes
app.use('/api/v1/auth', auth);
app.use('/api/v1/trainee' ,trainee);


app.use(notFoundMiddleware);
app.use(errorHandlerMiddleware);

const port = process.env.PORT || 3000;

const start = async () => {
  try {
    await connectDB();
    console.log('Connected to database');
    app.listen(port, () =>
      console.log(`Server is listening on port ${port}...`)
    );
  } catch (error) {
    console.log(error);
  }
};

start();