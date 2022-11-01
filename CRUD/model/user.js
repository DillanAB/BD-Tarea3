module.exports = {
    //Ejecuta el SP FindUser
    find:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("FindUser", null, {
            inName:data.name,
            inClave:data.password,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mReadUser:async function(connection, function_){
        const sqlRes = await connection.executeStoredProcedure("ReadUser");
        function_(sqlRes);
    },
    mSearchUser:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("SearchUser", null, {
            inUsername:data.username,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        });
        function_(sqlRes);
    },
    mCreateUser:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("CreateUser", null, {
            inValDoc:data.valDoc,
            inUsername:data.username,
            inPassword:data.password,
            inUserType:data.userType,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mUpdateUser:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("UpdateUser", null, {
            inUsername:data.username,
            inNewUsername:data.newUsername,
            inNewPassword:data.newPassword,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    },
    mDeleteUser:async function(connection, data, function_){
        let resultCode, ResultMessage;
        const sqlRes = await connection.executeStoredProcedure("DeleteUser", null, {
            inUsername:data.username,
            outResultCode:resultCode,
            outResultMessage:ResultMessage
        }); 
        function_(sqlRes);
    }
}