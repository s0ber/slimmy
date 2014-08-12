_ = require 'underscore'

class AstNode

  constructor: (json) ->
    data = _.clone(json.data)
    delete data?.children

    _.extend(@, {type: json.type, data})

    @parent = null

  setParent: (node) ->
    @parent = node

  isInline: ->
    @type is 'plain'

  nextNode: ->
    if not @parent? or not _.isArray(@parent.children)
      nextNode = null
    else
      index = @parent.children.indexOf(@)
      nextNode =
        if index is -1 or not @parent.children[index + 1]?
          null
        else
          @parent.children[index + 1]

    nextNode

  prevNode: ->
    if not @parent? or not _.isArray(@parent.children)
      prevNode = null
    else
      index = @parent.children.indexOf(@)
      prevNode =
        if index is -1 or not @parent.children[index - 1]?
          null
        else
          @parent.children[index - 1]

    prevNode

module.exports = AstNode
