Parser = require './parser'
Compiler = require './compiler'

Slimmy = class

  Parser: Parser

  Compiler: Compiler

  convert: (filePath) ->
    rootNode = @parser().parseFile(filePath)
    compiler = new @Compiler(rootNode)
    compiler.compile()

  parser: ->
    @_parser ?= new @Parser()

module.exports = Slimmy
