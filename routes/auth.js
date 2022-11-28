const express = require('express')
const router = express.Router()
const {login, logout } = require('../UWC2.0/controllers/auth')

router.post('/login', login)
router.get('/logout', logout)
module.exports = router