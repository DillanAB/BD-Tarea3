var createError = require('http-errors');
var express = require('express');
var path = require('path');
var cookieParser = require('cookie-parser');  
var bodyParser = require('body-parser'); //Agregado para los inputs
var logger = require('morgan');

// Se declaran variables con la dirección de todos los routers
var indexRouter = require('./routes/index');
//var usersRouter = require('./routes/users');
var adminRouter = require('./routes/admin');
var notAdminRouter = require('./routes/notAdmin');

var app = express();

// view engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

app.use(logger('dev'));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());
app.use(bodyParser.urlencoded({ extends: false })); //Necesario para el body-parser
app.use(bodyParser.json()); //Necesario para el body-parser
app.use(express.static(path.join(__dirname, 'public')));

// Para cada router se utiliza la función use
app.use('/', indexRouter);
//app.use('/users', usersRouter);
app.use('/admin', adminRouter);
app.use('/notAdmin', notAdminRouter);

// catch 404 and forward to error handler
app.use(function(req, res, next) {
  next(createError(404));
});

// error handler
app.use(function(err, req, res, next) {
  // set locals, only providing error in development
  res.locals.message = err.message;
  res.locals.error = req.app.get('env') === 'development' ? err : {};

  // render the error page
  res.status(err.status || 500);
  res.render('error');
});

module.exports = app;
