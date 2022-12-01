const Trainee = require('../models/Trainee')
const { StatusCodes } = require('http-status-codes')
const { BadRequestError } = require('../errors')

const addTrainee  = async (req, res) => {
    const { SSN, Fname, Lname, address, phone , DoB, photo, company_ID } = req.body
    const trainee = await Trainee.addTrainee({ SSN, Fname, Lname, address, phone ,   DoB, photo, company_ID } )
    res.status(StatusCodes.CREATED).json({ msg:'Trainee was successfully added' , traineeInfo:{ SSN, Fname, Lname, address, phone , DoB, photo, company_ID }})
}
const getTrainees = async (req, res) => {
    let {name} = req.query
    if ( !name ){
        name = ""
    }
    else{
        name = name.split(' ')
        if ( name.length> 2 ){   //
            throw new BadRequestError('Name contains only two fields : First name , Last name')
        }
    }
    // name === "" , name.length() === 1 || 2
    const trainees = await Trainee.getTrainees({name})
    res.status(StatusCodes.OK).json({trainees:trainees , nbHits: trainees.length})
}

const getSingleTrainee = async (req, res) => {
    const {traineeID} = req.params
    const allInfoTrainee = await Trainee.getSingleTrainee(traineeID)
    res.status(StatusCodes.OK).json(allInfoTrainee)
}
const getAchievement = async (req, res) => {
    const {traineeID}= req.params
    let {year} =req.query
    const achievementOfTrainee = await Trainee.getAchievement(traineeID, {year})
    res.status(StatusCodes.OK).json(achievementOfTrainee)
}

module.exports = {
  addTrainee,
  getTrainees,
  getSingleTrainee,
  getAchievement
}