try
  config = require './config'
catch
  config = require './config.example'

_ = require 'underscore'

INDENTATION = "  "
IND_LEVEL = 0
LINE_BREAK = '\n'
MID_BLOCK_KEYWORDS = 'else elsif rescue ensure end when'.split(' ')

class Compiler

  constructor: (rootNode, @fileCompilationMode = true) ->
    @root = rootNode
    @buffer = ''
    @_currentLine = 1
    @warnings = []

  compile: ->
    @compileNode(@root, IND_LEVEL)
    @compileChildrenNodes(@root, IND_LEVEL)

  compileChildrenNodes: (node, indLevel) ->
    return unless node.children
    for child in node.children
      @compileNode(child, indLevel)
      @compileChildrenNodes(child, indLevel + 1)

  compileNode: (node, indLevel) ->
    if @fileCompilationMode and @currentLine() isnt 1
      @addNewLine() if @_shouldPrependWithEmptyLine(node)

    warning = node.checkForWarnings?()
    if warning?
      warning.startLine = @currentLine()
      @warnings.push(warning)

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

    for key, value of node.data.attributes
      if key is 'class'
        tag += '.' + value.split(' ').join('.')
      else if key is 'id'
        tag += '#' + value

    nextNode = node.nextNode?()
    if node.isInline?() and nextNode?.isInline()
      tag += '>'

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
    hashes = _.map(hashes, (attrsHash) ->
      attrsHash = attrsHash.replace(/\n/g, ' ')
      attrsHash = attrsHash.replace(/(\w+\s\?\s'.+'\s:\s'.+?')/g, '($1)')
      newAttrsHash = ''
      insideBrackets = false
      insideHash = false
      skipChar = false

      for i in [0...attrsHash.length]
        if skipChar
          skipChar = false
          continue

        prevChar = attrsHash[i - 1] || ''
        char = attrsHash[i]
        nextChar = attrsHash[i + 1]

        if not insideBrackets and '[{("\''.indexOf(char) isnt -1
          if char is '{'
            insideHash = true
          insideBrackets = true
        else if insideBrackets and ']})"\''.indexOf(char) isnt -1
          if insideHash
            if char is '}'
              insideHash = false
              insideBrackets = false
          else
            insideBrackets = false

        unless insideBrackets
          if "#{char}#{nextChar}" is ': ' and prevChar isnt ' '
            newAttrsHash += '='
            skipChar = true
            continue
          else if "#{char}#{nextChar}" is ', '
            newAttrsHash += ' '
            skipChar = true
            continue

        newAttrsHash += char

      newAttrsHash
    )

    hashes

  _shouldPrependWithEmptyLine: (node) ->
    return if not @fileCompilationMode or not config?
    config.shouldPrependWithEmptyLine(node)

module.exports = Compiler
