module.exports = {
    mReadAsoUP:async function(connection, function_){
        const sqlRes = await connection.executeStoredProcedure("ReadAsoUP");
        const usuarios = await connection.executeStoredProcedure("ReadUser");
        const properties = await connection.executeStoredProcedure("ReadProperty");
        function_(sqlRes, usuarios, properties);
    },
    mCreateAsoUP:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("CreateAsoUP", null, {
            inUsername:data.username,
            inNumFinca:data.numFinca,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mDeleteAsoUP:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("DeleteAsoUP", null, {
            inUsername:data.username,
            inNumFinca:data.numFinca,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mUpdateAsoUP:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("UpdateAsoUP", null, {
            inUsername:data.username,
            inNumFinca:data.numFinca,
            inNewDate:data.newDate,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mGetUserProps:async function(connection, username, function_){
        let resultCode, ResultMessage;
        const sqlResProp = await connection.executeStoredProcedure("GetPropsFromUser", null, {
            inUsername:username,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlResProp);
    },
}