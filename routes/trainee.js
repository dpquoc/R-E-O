const express = require('express')
const router = express.Router()

const {
  addTrainee,
  getTrainees,
  getSingleTrainee,
  getAchievement
} = require('../controllers/trainee')


router.route('/').post(addTrainee).get(getTrainees)
router.route('/:traineeID').get(getSingleTrainee)
router.route('/:traineeID/year').get(getAchievement)
module.exports = router