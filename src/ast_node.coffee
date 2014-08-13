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

  checkForWarnings: ->
    nextNode = @nextNode()
    return if @isComment() or not nextNode?

    warningMessage =
      if @isPlain()
        if nextNode.isSilentScript() and not nextNode.isMidBlockKeyword()
          'Plain text is followed by a silent script, which execution result can be an inline element'
        else if nextNode.isNonLinkScript()
          'Plain text is followed by a script, which execution result can be an inline element'

      else if @isInline()
        elName = if @isInlineLink() then 'link' else 'tag'

        if nextNode.isSilentScript() and not nextNode.isMidBlockKeyword()
          "Inline #{elName} is followed by a silent script, which execution result can be an inline element"
        else if nextNode.isNonLinkScript()
          "Inline #{elName} is followed by a script, which execution result can be an inline element"

      else if @isNonLinkScript()
        if nextNode.isPlain()
          'Script, which execution can be an inline element, is followed by a plain text'
        else if nextNode.isInline()
          elName = if nextNode.isInlineLink() then 'link' else 'tag'
          "Script, which execution can be an inline element, is followed by an inline #{elName}"

      else if @isSilentScript() and not @isMidBlockKeyword()
        if nextNode.isPlain()
          'Silent script, which execution can be an inline element, is followed by a plain text'
        else if nextNode.isInline()
          elName = if nextNode.isInlineLink() then 'link' else 'tag'
          "Silent script, which execution can be an inline element, is followed by an inline #{elName}"

    if warningMessage?
      text: warningMessage
    else
      null

  isInline: ->
    switch
      when @type is 'plain'
        true
      when @type is 'tag' and INLINE_TAGS.indexOf(@data.name) isnt -1
        true
      when @isInlineLink()
        true
      else
        false

  isInlineLink: ->
    isLinkHelper = @isScript() and /^\s*link_to/.test @data.text
    isBlock = /do(\s\|\w+\|)?$/.test @data.text

    isLinkHelper and not isBlock

  isSilentScript: ->
    @type is 'silent_script'

  isNonLinkScript: ->
    @isScript() and not @isInlineLink()

  isMidBlockKeyword: ->
    MID_BLOCK_KEYWORDS.indexOf(@data.keyword) isnt -1

  isScript: ->
    @type is 'script'

  isPlain: ->
    @type is 'plain'

  isComment: ->
    @type is 'silent_script' and  /^\s*#/.test @data.text

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

      # skip comment nodes
      if nextNode?.isComment()
        nextNode = nextNode.nextNode()

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

      # skip comment nodes
      if prevNode?.isComment()
        prevNode = prevNode.prevNode()

    prevNode

module.exports = AstNode
