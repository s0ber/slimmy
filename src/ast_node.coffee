_ = require 'underscore'

class AstNode

  constructor: (json) ->
    _.extend(@, type: json.type, data: _.clone(json.data))

module.exports = AstNode
