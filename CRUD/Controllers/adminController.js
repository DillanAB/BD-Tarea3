const con = require("../config/connection");
const user = require("../model/user");
const person = require("../model/person");
const proper = require("../model/property");
const asoPP = require("../model/asoPP");
const asoUP = require("../model/asoUP");
const query = require("../model/query");
const admin = require("../model/admin");

module.exports = {
    index:function(req, res) {
        res.render('Administrador/index');
    },
    //*******************Personas
    person:async function(req, res) {
        person.mReadPerson(con, function(sqlRes){
            res.render('Administrador/person', { 
                people:sqlRes.data});
        })
    },
    exSearchPerson:async function(req, res) {
        person.mSearchPerson(con, req.body, function(sqlRes){
            console.log(sqlRes.data);
            res.render('Administrador/Reads/readPerson', { 
                people:sqlRes.data});
        })
    },
    exCreatePerson:async function(req,res){
        console.log(req.body)
        person.mCreatePerson(con, req.body, function(sqlRes){
            exeFun(sqlRes, res, '/admin/person');
        });
    },
    exUpdatePerson:async function(req,res){
        console.log(req.body)
        person.mUpdatePerson(con, req.body, function(sqlRes){
            exeFun(sqlRes, res, '/admin/person');
        });
    },
    exDeletePerson:async function(req,res){
        console.log(req.body)
        person.mDeletePerson(con, req.body, function(sqlRes){
            exeFun(sqlRes, res, '/admin/person');
        });
    },
    //*******************Usuarios
    exUser:async function(req, res) {
        user.mReadUser(con, function(sqlRes){
            res.render('Administrador/user', { 
                users:sqlRes.data});
        })
    },
    exSearchUser:async function(req, res) {
        user.mSearchUser(con, req.body, function(sqlRes){
            console.log(sqlRes.data);
            res.render('Administrador/Reads/readUser', { 
                users:sqlRes.data});
        })
    },
    exCreateUser:async function(req,res){
        console.log(req.body)
        user.mCreateUser(con, req.body, function(sqlRes){
            exeFun(sqlRes, res, '/admin/user');
        });
    },
    exUpdateUser:async function(req, res) {
        user.mUpdateUser(con, req.body, function(sqlRes){
            exeFun(sqlRes, res, '/admin/user');
        })
    },
    exDeleteUser:async function(req, res) {
        user.mDeleteUser(con, req.body, function(sqlRes){
            exeFun(sqlRes, res, '/admin/user');
        })
    },
    //*******************Propiedades
    exCreateProperty:async function(req,res){
        proper.mCreateProperty(con, req.body, function(sqlRes){
            console.log(req.body);
            exeFun(sqlRes, res, '/admin/property');
        });
    },
    exReadProperty:async function(req, res) {
        proper.mReadProperty(con, function(sqlRes, sqlUse, sqlZone){
            res.render('Administrador/property', { 
                properties:sqlRes.data,
                uses:sqlUse.data,
                zones:sqlZone.data});
        })
    },
    exSearchProperty:async function(req, res) {
        proper.mSearchProperty(con, req.body, function(sqlRes){
            console.log(sqlRes.data);
            res.render('Administrador/Reads/readProperty', { 
                properties:sqlRes.data});
        })
    },
    exUpdateProperty:async function(req,res){
        proper.mUpdateProperty(con, req.body, function(sqlRes){
            console.log(req.body);
            exeFun(sqlRes, res, '/admin/property');
        });
    },
    exDeleteProperty:async function(req,res){
        proper.mDeleteProperty(con, req.body, function(sqlRes){
            console.log(req.body);
            exeFun(sqlRes, res, '/admin/property');
        });
    },
    exReadAsoPP:async function(req, res) {
        asoPP.mReadAsoPP(con, function(sqlRes, sqlPersona, sqlProp){
            res.render('Administrador/asoPP', { 
                asosPP:sqlRes.data,
                personas:sqlPersona.data,
                properties:sqlProp.data});
        })
    },
    exCreateAsoPP:async function(req,res){
        asoPP.mCreateAsoPP(con, req.body, function(sqlRes){
            console.log(req.body);
            exeFun(sqlRes, res, '/admin/asoPP');
        });
    },
    exDeleteAsoPP:async function(req,res){
        asoPP.mDeleteAsoPP(con, req.body, function(sqlRes){
            console.log(req.body);
            exeFun(sqlRes, res, '/admin/asoPP');
        });
    },
    exUpdateAsoPP:async function(req,res){
        asoPP.mUpdateAsoPP(con, req.body, function(sqlRes){
            console.log(req.body);
            exeFun(sqlRes, res, '/admin/asoPP');
        });
    },
    //*******************Asociaciones entre Usuarios/Propiedades
    exReadAsoUP:async function(req, res) {
        asoUP.mReadAsoUP(con, function(sqlRes, sqlUser, sqlProp){
            res.render('Administrador/asoUP', { 
                asosPP:sqlRes.data,
                usuarios:sqlUser.data,
                properties:sqlProp.data});
        })
    },
    exCreateAsoUP:async function(req,res){
        asoUP.mCreateAsoUP(con, req.body, function(sqlRes){
            console.log(req.body);
            exeFun(sqlRes, res, '/admin/asoUP');
        });
    },
    exDeleteAsoUP:async function(req,res){
        asoUP.mDeleteAsoUP(con, req.body, function(sqlRes){
            console.log(req.body);
            exeFun(sqlRes, res, '/admin/asoUP');
        });
    },
    exUpdateAsoUP:async function(req,res){
        asoUP.mUpdateAsoUP(con, req.body, function(sqlRes){
            console.log(req.body);
            exeFun(sqlRes, res, '/admin/asoUP');
        });
    },
    //*******************Consultas
    exQuery: function(req, res) {
        res.render('Administrador/query', { title: 'Login' });
    },
    exCons1:async function(req, res) {
        query.mCons1(con, req.body, function(sqlRes){
            console.log(req.body);
            console.log(sqlRes.body);
            res.render('Administrador/Reads/readCons1', { 
                properties:sqlRes.data});
        })
    },
    exCons2:async function(req, res) {
        query.mCons2(con, req.body, function(sqlRes){
            res.render('Administrador/Reads/readCons2', { 
                personas:sqlRes.data});
        })
    },
    exCons3:async function(req, res) {
        query.mCons3(con, req.body, function(sqlRes){
            res.render('Administrador/Reads/readCons3', { 
                properties:sqlRes.data});
        })
    },
    exCons4:async function(req, res) {
        query.mCons4(con, req.body, function(sqlRes){
            res.render('Administrador/Reads/readCons4', { 
                users:sqlRes.data});
        })
    }
}

function exeFun(sqlRes, res, route){
    let code = sqlRes.data[0][0].ResultCode;
    console.log("Código:",code);
    console.log(sqlRes.body);

    if(code == 0){ //Si no hubo errores
        console.log(sqlRes.data);
        res.redirect(route);
    }
    else{
        console.log("Error: ", sqlRes.data[0][0].ResultMessage);
        res.redirect(route);
    }
}