process.env.NODE_ENV = process.env.NODE_ENV || 'perf'

const environment = require('./environment')

module.exports = environment.toWebpackConfig()
