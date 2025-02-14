process.env.NODE_ENV = process.env.NODE_ENV || 'uat'

const environment = require('./environment')

module.exports = environment.toWebpackConfig()
