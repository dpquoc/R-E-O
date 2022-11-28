const oracledb = require('oracledb');
require('dotenv').config();

oracledb.autoCommit = true;
oracledb.outFormat = oracledb.OUT_FORMAT_OBJECT;


const connect = async () => {
    try {
        await oracledb.createPool({
           user          : process.env.ORACLE_USER,
           password      : process.env.ORACLE_PASSWORD,  
           connectString : process.env.ORACLE_URI,
         });   
     } 
     catch (err) {
        console.error("Connection Pool Error:" + err.message)  
        throw new Error(err);   
     }
};

module.exports = connect;