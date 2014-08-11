_ = require 'underscore'

INDENTATION = "  "
IND_LEVEL = 0
LINE_BREAK = '\n'
MAIN_TAGS = 'body footer'.split(' ')

class Compiler

  constructor: (rootNode) ->
    @root = rootNode
    @buffer = ''

  compile: ->
    @compileNode(@root, IND_LEVEL)
    @compileChildrenNodes(@root, IND_LEVEL)

  compileChildrenNodes: (node, indLevel) ->
    return unless node.children
    for child in node.children
      @compileNode(child, indLevel)
      @compileChildrenNodes(child, indLevel + 1)

  compileNode: (node, indLevel) ->
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
    @buffer += @getIndent(indLevel) + '| ' + node.data.text + LINE_BREAK

  compileScript: (node, indLevel) ->
    scriptLen = node.data.text.length
    isInterpolatedString = node.data.text[0] is '"' and node.data.text[scriptLen - 1] is '"'

    if isInterpolatedString
      @buffer += @getIndent(indLevel) + node.data.text.substr(1, scriptLen - 2) + LINE_BREAK
    else
      @buffer += @getIndent(indLevel) + '=' + node.data.text + LINE_BREAK

  compileSilentScript: (node, indLevel) ->
    if /# EMPTY_LINE/.test(node.data.text)
      @buffer += '\n'
    else
      isComment = /^ #/.test(node.data.text)
      @buffer += '\n' if isComment
      @buffer += @getIndent(indLevel) + '-' + node.data.text + LINE_BREAK

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

    isMainTag = MAIN_TAGS.indexOf(node.data.name) isnt -1
    @buffer += LINE_BREAK if isMainTag
    @buffer += @getIndent(indLevel) + tag
    attrsHashes =  @compileAttrsHashes(node.data.attributes_hashes)
    @buffer += ' ' + attrsHashes.join(' ') if attrsHashes.length > 0

    if node.data.parse
      value = node.data.value.replace(/\s+(?=\s)/g,'').replace('( ', '(').replace(' )', ')')
      @buffer += ' =' + value + LINE_BREAK
    else if node.data.value
      @buffer += LINE_BREAK + @getIndent(indLevel) + INDENTATION + '| ' + node.data.value + LINE_BREAK
    else
      @buffer += LINE_BREAK

  compileComment: (node, indLevel) ->
    @buffer += @getIndent(indLevel) + '/!'
    @buffer += " #{node.data.text}" if node.data.text
    @buffer += LINE_BREAK

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

    @buffer += @getIndent(indLevel) + doctype + LINE_BREAK

  compileFilter: (node, indLevel) ->
    filterStringFormatted = ''
    strings = _.compact(node.data.text.split('\n'))
    strings = _.map strings, (string) =>
      @getIndent(indLevel) + INDENTATION + string

    @buffer += @getIndent(indLevel) + ":#{node.data.name}" + LINE_BREAK
    @buffer += strings.join(LINE_BREAK) + LINE_BREAK + LINE_BREAK

  compileSpec: (node, indLevel) ->
    @buffer += @getIndent(indLevel) + node.data.text + LINE_BREAK

  getIndent: (indLevel) ->
    if indLevel then Array(indLevel + 1).join(INDENTATION) else ''

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

module.exports = Compiler
