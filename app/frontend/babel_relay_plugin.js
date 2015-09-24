var Plugin = require('babel-relay-plugin');
var Schema = require('../../config/schema.json');

module.exports = Plugin(Schema.data)
