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

  compileScript: (node, indLevel) ->

  compileSilentScript: (node, indLevel) ->

  compileHamlComment: (node, indLevel) ->

  compileTag: (node, indLevel) ->

  compileComment: (node, indLevel) ->

  compileDoctype: (node, indLevel) ->

  compileFilter: (node, indLevel) ->

  compileSpec: (node, indLevel) ->
    @buffer += @getIndent(indLevel) + node.data.text + LINE_BREAK

  getIndent: (indLevel) ->
    if indLevel then Array(indLevel + 1).join(INDENTATION) else ''

module.exports = Compiler
