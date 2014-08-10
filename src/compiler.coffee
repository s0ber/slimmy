_ = require 'underscore'

INDENTATION = "  "
IND_LEVEL = 0
LINE_BREAK = '\n'

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
    @buffer += @getIndent(indLevel) + '=' + node.data.text + LINE_BREAK

  compileSilentScript: (node, indLevel) ->
    if /# EMPTY_LINE/.test(node.data.text)
      @buffer += '\n'
    else
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

    @buffer += @getIndent(indLevel) + tag + ' '
    @buffer += @compileAttrsHashes(node.data.attributes_hashes).join(' ') + LINE_BREAK

  compileComment: (node, indLevel) ->

  compileDoctype: (node, indLevel) ->

  compileFilter: (node, indLevel) ->

  compileSpec: (node, indLevel) ->
    @buffer += @getIndent(indLevel) + node.data.text + LINE_BREAK

  getIndent: (indLevel) ->
    if indLevel then Array(indLevel + 1).join(INDENTATION) else ''

  compileAttrsHashes: (hashes = []) ->
    hashes = _.map hashes, (attributesHash) ->
      attributesHash = attributesHash.replace(/\n/g, ' ')
      dataAttrs = attributesHash.match(/data: {(.+)}/)[1]
      attributesHash = attributesHash.replace(dataAttrs, '')

      items =
        for item in attributesHash.split(', ')
          item.replace(/(\w+): /, "$1=")
      attributesHash = items.join(' ').replace('data={}', "data={#{dataAttrs}}")
      attributesHash

    hashes

module.exports = Compiler
