const express = require('express')
const router = express.Router()


const {
  addTrainee,
  getTrainees,
  getSingleTrainee
} = require('../controllers/trainee')


router.route('/').post(addTrainee).get(getTrainees)
router.route('/:traineeID').get(getSingleTrainee)

module.exports = router