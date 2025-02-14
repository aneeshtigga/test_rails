process.env.NODE_ENV = process.env.NODE_ENV || 'qa'

const environment = require('./environment')

module.exports = environment.toWebpackConfig()
