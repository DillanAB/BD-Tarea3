const con = require("../config/connection");
const user = require("../model/user");
const asoUP = require("../model/asoUP");

module.exports = {
    index:function(req, res) {
        res.render('login', { title: 'Login' });
    },

    pr:function(req,res){
        res.send(req.body);
    },

    findUser:async function(req,res){
        console.log(req.body);
        user.find(con, req.body, function(sqlRes){
            let code = sqlRes.data[0][0].ResultCode;
            console.log("Código:",code);

            if(code == 0){ //Si no hubo errores
                console.log(sqlRes.data);
                let userType = sqlRes.data[0][0].TipoUsuario;

                if(userType == 1){
                    res.redirect('/admin');
                }
                else{
                    //res.redirect('/notAdmin');
                    asoUP.mGetUserProps(con, req.body.name,function(sqlResProp){
                        res.render('NoAdministrador/index', { 
                            properties:sqlResProp.data});
                        })
                    
                }
            }
            else{
                console.log("Error");
            }

        });
    }
}