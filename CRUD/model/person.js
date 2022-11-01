module.exports = {
    mReadPerson:async function(connection, function_){
        const sqlRes = await connection.executeStoredProcedure("ReadPerson");
        function_(sqlRes);
    },
    mSearchPerson:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("SearchPerson", null, {
            inDocVal:data.valDoc,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        });
        function_(sqlRes);
    },
    mCreatePerson:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("CreatePerson", null, {
            inName:data.name,
            inIdTipoDoc:data.tipoDoc,
            inValorDoc:data.valDoc,
            inEmail:data.email,
            inTelefono1:data.tel1,
            inTelefono2:data.tel2,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mUpdatePerson:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("UpdatePerson", null, {
            inDocVal:data.valDoc,
            inNewName:data.newName,
            inNewEmail:data.newEmail,
            inNewTelefono1:data.newTel1,
            inNewTelefono2:data.newTel2,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mDeletePerson:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("DeletePerson", null, {
            inDocVal:data.valDoc,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    }
}