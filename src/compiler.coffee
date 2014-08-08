class Compiler

  constructor: (rootNode) ->
    @root = rootNode
    @buffer = ''

  compileNode: (node) ->
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

    @[compilationMethod](node)

  compileRoot: (node) ->

  compilePlain: (node) ->

  compileScript: (node) ->

  compileSilentScript: (node) ->

  compileHamlComment: (node) ->

  compileTag: (node) ->

  compileComment: (node) ->

  compileDoctype: (node) ->

  compileFilter: (node) ->

module.exports = Compiler
