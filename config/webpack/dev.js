process.env.NODE_ENV = process.env.NODE_ENV || 'dev'

const environment = require('./environment')

module.exports = environment.toWebpackConfig()
