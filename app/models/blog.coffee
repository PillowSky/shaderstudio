'use strict'

mongoose = require('../services/mongoose')

BlogSchema = new mongoose.Schema({

})

module.exports = mongoose.model('Blog', BlogSchema)
