_ = require 'underscore'

class AstNode

  constructor: (json) ->
    data = _.clone(json.data)
    delete data?.children

    _.extend(@, {type: json.type, data})

    @parent = null

  setParent: (node) ->
    @parent = node

module.exports = AstNode
