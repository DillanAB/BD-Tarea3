const sql = require("mssql");

//Se envían los datos necesarios para acceder a la base de datos.
const rest = new (require("rest-mssql-nodejs"))({
    user: 'Dillan',
    password: 'DAB1219*',
    server: 'localhost',
    database: 'Servicios',
    options: {
        encrypt: true,
        trustServerCertificate: true
    }
});
module.exports=rest;