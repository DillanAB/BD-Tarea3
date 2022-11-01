module.exports = {
    mCons1:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("GetPropsFromPerson", null, {
            inName:data.name,
            inDocVal:data.valDoc,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mCons2:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("GetPropietarios", null, {
            inNumFinca:data.numFinca,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mCons3:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("GetPropsFromUser", null, {
            inUsername:data.username,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mCons4:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("GetUsers", null, {
            inNumFinca:data.numFinca,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    }
}