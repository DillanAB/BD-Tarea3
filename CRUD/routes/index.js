var express = require('express');
var router = express.Router();
const loginController = require('../Controllers/loginController');

/* GET home page. */
// Ejecuta la función index de loginController
router.get('/', loginController.index);


router.post("/", loginController.findUser);

module.exports = router;
