Parser = require './parser'
Compiler = require './compiler'

Slimmy = class

  Parser: Parser

  Compiler: Compiler

  convert: (filePath) ->
    @parser().parseFile(filePath).then (rootNode) =>
      compiler = new @Compiler(rootNode)
      compiler.compile()
      @_compilationResults = compiler.buffer

  parser: ->
    @_parser ?= new @Parser()

module.exports = Slimmy
