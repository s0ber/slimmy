_ = require 'underscore'
INLINE_TAGS = 'b big i small tt abbr acronym cite code dfn em kbd strong samp var a bdo map object q script span sub sup'.split(' ')
MID_BLOCK_KEYWORDS = 'else elsif rescue ensure end when'.split(' ')

class AstNode

  constructor: (json) ->
    data = _.clone(json.data)
    delete data?.children

    _.extend(@, {type: json.type, data})

    @parent = null

  setParent: (node) ->
    @parent = node

  isInline: ->
    switch
      when @type is 'plain'
        true
      when @type is 'tag' and INLINE_TAGS.indexOf(@data.name) isnt -1
        true
      else
        false

  isSilentScript: ->
    @type is 'silent_script' and MID_BLOCK_KEYWORDS.indexOf(@data.keyword) is -1

  isScript: ->
    @type is 'script'

  isPlain: ->
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
