var express = require('express');
var router = express.Router();
const notAdminController = require('../Controllers/notAdminController');

/* GET home page. */
// Ejecuta la función index de adminController
router.get('/', notAdminController.index);

module.exports = router;
