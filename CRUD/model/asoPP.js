module.exports = {
    mReadAsoPP:async function(connection, function_){
        const sqlRes = await connection.executeStoredProcedure("ReadAsoPP");
        const personas = await connection.executeStoredProcedure("ReadPerson");
        const properties = await connection.executeStoredProcedure("ReadProperty");
        function_(sqlRes, personas, properties);
    },
    mCreateAsoPP:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("CreateAsoPP", null, {
            inDocVal:data.docVal,
            inNumFinca:data.numFinca,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mDeleteAsoPP:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("DeleteAsoPP", null, {
            inDocVal:data.docVal,
            inNumFinca:data.numFinca,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mUpdateAsoPP:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("UpdateAsoPP", null, {
            inDocVal:data.docVal,
            inNumFinca:data.numFinca,
            inDate:data.newDate,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    }
}