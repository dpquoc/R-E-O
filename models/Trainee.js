const oracledb = require('oracledb');

let Trainee = {};
let connection;

Trainee.addTrainee = async ({ SSN, Fname, Lname, address, phone ,   DoB, photo, company_ID }) => {
    try {
        connection = await oracledb.getConnection();

        const person = await connection.execute(
            `INSERT INTO Person (SSN, Fname, Lname, address, phone) VALUES
            (:SSN, :Fname, :Lname, :address, :phone)`,
            [SSN , Fname , Lname , address , phone]
        );
        const trainee = await connection.execute(
            `INSERT INTO Trainee (SSN, DoB, photo, company_ID) VALUES
            (:SSN, :DoB, :photo, :company_ID)`,
            [SSN , DoB , photo , company_ID]
        );
        const res = {person:person.rows , trainee:trainee.rows}
        return res;
    } catch (error) {
        throw error
    }
    finally{
        if (connection) {
            try {
                await connection.close();  // always release the connection back to the pool
            } catch (err) {
                console.error(err);
            }
        }
    }
};

Trainee.getTrainees = async ({name}) => {
    try {
        connection = await oracledb.getConnection();
        let searchString = 
        `SELECT Trainee.SSN , Fname , Lname , address, phone
        FROM Person
        INNER JOIN Trainee
        ON Person.SSN = Trainee.SSN
        `
        if ( name.length()=== 1){
            searchString = searchString +
            ` WHERE LOWER(Person.Fname) LIKE LOWER('%${name[0]}%') OR LOWER(Person.Lname) LIKE LOWER('%${name[0]}%')`
        }
        if ( name.length()=== 2){
            searchString = searchString +
            ` WHERE (LOWER(Person.Fname) LIKE LOWER('%${name[0]}%') AND LOWER(Person.Lname) LIKE LOWER('%${name[1]}%'))
            OR (LOWER(Person.Fname) LIKE LOWER('%${name[1]}%') AND LOWER(Person.Lname) LIKE LOWER('%${name[0]}%'))`
        }
        searchString = searchString + ` ORDER BY SSN ASC`
        const trainees = await connection.execute(searchString);
        return trainees.rows
    } catch (error) {
        throw error
    }
    finally{
        if (connection) {
            try {
                await connection.close();  // always release the connection back to the pool
            } catch (err) {
                console.error(err);
            }
        }
    }
};

Trainee.getSingleTrainee = async (id) => {
    try {
        connection = await oracledb.getConnection();

        const trainee = await connection.execute(`SELECT * FROM TRAINEE WHERE SSN = ${id}`);
        if (trainee.rowsAffected == 0){
            return {msg:`No trainee with this id : ${id}`}
        }
        const person = await connection.execute(`SELECT year FROM PERSON WHERE SSN = ${id}`);
        const seasonTrainee = await connection.execute(`SELECT * FROM SeasonTrainee WHERE SSN = ${id} ORDER BY year ASC`);
        seasonTrainee.rows.map( async row =>{
            //
            //IMPORTANT function_2 not known real name yet
            //
            let achievement = await connection.execute(`SELECT * FROM TABLE( function_2(${id} ,${row.year}) )`)
            row = {...row ,achievement: achievement.rows}
        } )
        return {person: person.rows , trainee: trainee.rows , seasonTrainee: seasonTrainee.rows}
    } catch (error) {
        throw error
    }
    finally{
        if (connection) {
            try {
                await connection.close();  // always release the connection back to the pool
            } catch (err) {
                console.error(err);
            }
        }
    }
};

module.exports = Trainee;
