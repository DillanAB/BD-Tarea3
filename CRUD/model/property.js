module.exports = {
    mReadProperty:async function(connection, function_){
        const sqlRes = await connection.executeStoredProcedure("ReadProperty");
        const sqlUse = await connection.executeStoredProcedure("ReadUse");
        const sqlZone = await connection.executeStoredProcedure("ReadZone");
        function_(sqlRes, sqlUse, sqlZone);
    },
    mSearchProperty:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("SearchProperty", null, {
            inNumFinca:data.fincNum,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        });
        function_(sqlRes);
    },
    mCreateProperty:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("CreateProperty", null, {
            inFincNum:data.fincaNum,
            inUseType:data.idUse,
            inZoneType:data.idZone,
            inArea:data.area,
            inFiscalValue:data.fiscalValue,
            inMedNum:data.medNum,
            inDate:data.dateVal,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mUpdateProperty:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("UpdateProperty", null, {
            inNumFinc:data.fincNum,
            inNewUse:data.newUse,
            inNewZone:data.newZone,
            inNewArea:data.newArea,
            inNewFiscalValue:data.newFiscalValue,
            inNewMedNum:data.newMedNum,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mDeleteProperty:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("DeleteProperty", null, {
            inNumFinc:data.fincNum,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    }
}