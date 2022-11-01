module.exports = {
    mReadPerson:async function(connection, function_){
        const sqlRes = await connection.executeStoredProcedure("ReadPerson");
        function_(sqlRes);
    },

    //Ejecuta el SP CreatePerson
    mCreatePerson:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("CreatePerson", null, {
            inName:data.name,
            inIdTipoDoc:data.tipoDoc,
            inValorDoc:data.valDoc,
            outResultCode:resultCode,
            outErrorMessage:ResultMessage
        }); 
        function_(sqlRes);
    }
}