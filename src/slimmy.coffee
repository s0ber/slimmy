fs = require 'fs'
Parser = require './parser'
Compiler = require './compiler'

Slimmy = class

  Parser: Parser

  Compiler: Compiler

  convert: (filePath, writeToFile = true) ->
    filePath = @getAbsolutePath(filePath)

    @parser().parseFile(filePath).then (rootNode) =>
      compiler = new @Compiler(rootNode)
      compiler.compile()
      @_compilationResults = compiler.buffer

      @writeToSlimFile(filePath, compiler.buffer) if writeToFile

  writeToSlimFile: (filePath, slimCode) ->
    console.log filePath
    slimFilePath = filePath.replace(/\.haml$/, '.slim')

    fd = fs.openSync(slimFilePath, 'w')
    fs.writeFileSync(slimFilePath, slimCode)
    fs.closeSync(fd)

  getAbsolutePath: (filePath) ->
    return unless filePath
    isAbsolutePath = filePath[0] is '/' or filePath[0] is '~'

    if isAbsolutePath
      filePath
    else
      filePath = "#{__dirname}/../#{filePath}"

  parser: ->
    @_parser ?= new @Parser()

module.exports = Slimmy
