_ = require 'underscore'

INDENTATION = "  "
IND_LEVEL = 0
LINE_BREAK = '\n'
MAIN_TAGS = 'body footer'.split(' ')
MID_BLOCK_KEYWORDS = 'else elsif rescue ensure end when'.split(' ')

class Compiler

  constructor: (rootNode, @fileCompilationMode = true) ->
    @root = rootNode
    @buffer = ''
    @_currentLine = 0
    @warnings = []

  compile: ->
    @compileNode(@root, IND_LEVEL)
    @compileChildrenNodes(@root, IND_LEVEL)
    @addNewLine() if @fileCompilationMode

  compileChildrenNodes: (node, indLevel) ->
    return unless node.children
    for child in node.children
      @compileNode(child, indLevel)
      @compileChildrenNodes(child, indLevel + 1)

  compileNode: (node, indLevel) ->
    @addNewLine() if @_shouldPrependWithEmptyLine(node)

    compilationMethod = switch node.type
      when 'root'
        'compileRoot'
      when 'plain'
        'compilePlain'
      when 'script'
        'compileScript'
      when 'silent_script'
        'compileSilentScript'
      when 'haml_comment'
        'compileHamlComment'
      when 'tag'
        'compileTag'
      when 'comment'
        'compileComment'
      when 'doctype'
        'compileDoctype'
      when 'filter'
        'compileFilter'
      when 'spec'
        'compileSpec'

    return unless compilationMethod

    @[compilationMethod](node, indLevel)

    warning = node.checkForWarnings?()
    if warning?
      warning.startLine = @currentLine()
      @warnings.push(warning)

  compileRoot: (node, indLevel) ->

  compilePlain: (node, indLevel) ->
    firstChar = node.data.text[0]

    nextNode = node.nextNode?()
    plainTextPrefix =
      if nextNode?.isInline()
        "' "
      else
        '| '

    @buffer += @getIndent(indLevel) + plainTextPrefix + node.data.text
    @addNewLine()

  compileScript: (node, indLevel) ->
    scriptLen = node.data.text.length
    isInterpolatedString = node.data.text[0] is '"' and node.data.text[scriptLen - 1] is '"'

    if isInterpolatedString
      @buffer += @getIndent(indLevel) + node.data.text.substr(1, scriptLen - 2)
    else
      nextNode = node.nextNode?()
      scriptPrefix =
        if node.isInlineLink?() and nextNode?.isInline()
          "=>"
        else
          '='

      @buffer += @getIndent(indLevel) + scriptPrefix + node.data.text

    @addNewLine()

  compileSilentScript: (node, indLevel) ->
    isComment = /^ #/.test(node.data.text)
    @addNewLine() if isComment
    isMidBlockKeyword = node.data.keyword? and MID_BLOCK_KEYWORDS.indexOf(node.data.keyword) isnt -1

    indent =
      if isMidBlockKeyword
        @getIndent(indLevel - 1)
      else
        @getIndent(indLevel)

    @buffer += indent + '-' + node.data.text
    @addNewLine()

  compileHamlComment: (node, indLevel) ->

  compileTag: (node, indLevel) ->
    if node.data.name is 'div'
      tag =
        if _.size(node.data.attributes) is 0
          'div'
        else
          ''
    else
      tag = "#{node.data.name}"
      nextNode = node.nextNode?()
      if node.isInline?() and nextNode?.isInline()
        tag += '>'

    for key, value of node.data.attributes
      if key is 'class'
        tag += '.' + value.split(' ').join('.')
      else if key is 'id'
        tag += '#' + value

    @buffer += @getIndent(indLevel) + tag
    attrsHashes =  @compileAttrsHashes(node.data.attributes_hashes)
    @buffer += ' ' + attrsHashes.join(' ') if attrsHashes.length > 0

    if node.data.parse
      value = node.data.value.replace(/\s+(?=\s)/g,'').replace('( ', '(').replace(' )', ')')
      @buffer += ' =' + value
    else if node.data.value
      @addNewLine()
      @buffer += @getIndent(indLevel) + INDENTATION + '| ' + node.data.value

    @addNewLine()

  compileComment: (node, indLevel) ->
    @buffer += @getIndent(indLevel) + '/!'
    @buffer += " #{node.data.text}" if node.data.text
    @addNewLine()

  compileDoctype: (node, indLevel) ->
    doctype =
      if node.data.version is '5'
        'doctype html'
      else if node.data.version is '1.1'
        'doctype 1.1'
      else if node.data.type is 'strict'
        'doctype strict'
      else if node.data.type is 'frameset'
        'doctype frameset'
      else if node.data.type is 'mobile'
        'doctype mobile'
      else if node.data.type is 'basic'
        'doctype basic'
      else
        'doctype transitional'

    @buffer += @getIndent(indLevel) + doctype
    @addNewLine()

  compileFilter: (node, indLevel) ->
    filterStringFormatted = ''
    strings = _.compact(node.data.text.split(LINE_BREAK))
    strings = _.map strings, (string) =>
      @getIndent(indLevel) + INDENTATION + string

    @buffer += @getIndent(indLevel) + ":#{node.data.name}"
    @addNewLine()

    for str in strings
      @buffer += str
      @addNewLine()

    @addNewLine()

  compileSpec: (node, indLevel) ->
    @buffer += @getIndent(indLevel) + node.data.text
    @addNewLine()

  getIndent: (indLevel) ->
    if indLevel then Array(indLevel + 1).join(INDENTATION) else ''

  currentLine: ->
    @_currentLine

  addNewLine: ->
    @buffer += LINE_BREAK
    @_currentLine++

  compileAttrsHashes: (hashes = []) ->
    hashes = _.map(hashes, (attributesHash) ->
      attributesHash = attributesHash.replace(/\n/g, ' ')

      attributes = attributesHash.replace(/'/g, '"')
        .replace(/(\w+):/g, "\"$1\":")

      attributes = JSON.parse "{#{attributes}}"
      firstLevelKeys = _.keys(attributes)

      for key in firstLevelKeys
        regExp = new RegExp("(, )*#{key}: ")
        matcher = attributesHash.match(regExp)
        hasComma = matcher[1]?

        attributesHash =
          if hasComma
            attributesHash.replace(", #{key}: ", " #{key}=")
          else
            attributesHash.replace("#{key}: ", "#{key}=")

      attributesHash
    )

    hashes

  _shouldPrependWithEmptyLine: (node) ->
    return unless @fileCompilationMode
    node.type is 'tag' and node.data? and MAIN_TAGS.indexOf(node.data.name) isnt -1

module.exports = Compiler
