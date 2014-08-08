Parser = require './parser'
Compiler = require './compiler'

Slimmy = class

  Parser: Parser

  Compiler: Compiler

  convert: (filePath) ->
    compiler = new @Compiler()
    slimCode = compiler.compile(@parser().parseFile(filePath))

  parser: ->
    @_parser ?= new @Parser()

module.exports = Slimmy
