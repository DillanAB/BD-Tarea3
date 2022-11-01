var express = require('express');
const { route } = require('.');
var router = express.Router();
const adminController = require('../Controllers/adminController');

/* GET home page. */
// Ejecuta la función index de adminController
router.get('/', adminController.index);

//Personas
router.get('/person', adminController.person);
router.post("/createPerson", adminController.exCreatePerson);
router.post("/searchPerson", adminController.exSearchPerson);
router.post("/updatePerson", adminController.exUpdatePerson);
router.post("/deletePerson", adminController.exDeletePerson);

//Propiedades
router.get('/property', adminController.exReadProperty);
router.post("/createProperty", adminController.exCreateProperty);
router.post("/searchProperty", adminController.exSearchProperty);
router.post("/updateProperty", adminController.exUpdateProperty);
router.post("/deleteProperty", adminController.exDeleteProperty);

//Usuarios
router.get('/user', adminController.exUser);
//router.post("/", adminController.findUser);
router.post("/searchUser", adminController.exSearchUser);
router.post("/createUser", adminController.exCreateUser);
router.post("/updateUser", adminController.exUpdateUser);
router.post("/deleteUser", adminController.exDeleteUser);


//Asociación persona/propiedad
router.get('/asoPP', adminController.exReadAsoPP);
router.post("/createAsoPP", adminController.exCreateAsoPP);
router.post("/DeleteAsoPP", adminController.exDeleteAsoPP);
router.post("/UpdateAsoPP", adminController.exUpdateAsoPP);



//Asociación usuario/propiedad
router.get('/asoUP', adminController.exReadAsoUP);
router.post("/createAsoUP", adminController.exCreateAsoUP);
router.post("/DeleteAsoUP", adminController.exDeleteAsoUP);
router.post("/UpdateAsoUP", adminController.exUpdateAsoUP);

//Consultas
router.get('/consultas', adminController.exQuery);
router.post("/consulta1", adminController.exCons1);
router.post("/consulta2", adminController.exCons2);
router.post("/consulta3", adminController.exCons3);
router.post("/consulta4", adminController.exCons4);

module.exports = router;
