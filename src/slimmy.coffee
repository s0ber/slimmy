Q = require 'q'
_ = require 'underscore'
fs = require 'fs'
walk = require 'walk'
Riline = require 'riline'

Parser = require './parser'
Compiler = require './compiler'

HAML_EXTENSION_REGEXP = /\.haml$/

Slimmy = class

  Parser: Parser

  Compiler: Compiler

  convertString: (hamlCodeString, fileCompilationMode = false) ->
    @parser().parseString(hamlCodeString).then (rootNode) =>
      compiler = new @Compiler(rootNode, fileCompilationMode)
      compiler.compile()
      @_showWarnings(compiler)
      compiler

  convertFile: (filePath, writeToFile = false) ->
    filePath = @getAbsolutePath(filePath)

    @parser().parseFile(filePath).then (rootNode) =>
      compiler = new @Compiler(rootNode)
      compiler.compile()

      if writeToFile
        @_showWarnings(compiler, filePath)
      else
        @_showWarnings(compiler)

      @_compilationResults = compiler.buffer

      @writeToSlimFile(filePath, compiler.buffer) if writeToFile

  convertDir: (dirPath, writeToFile = false) ->
    dirPath = @getAbsolutePath(dirPath)
    files = []

    walker = walk.walkSync(dirPath,
      followLinks: false
      listeners:
        file: (root, stat, next) ->
          files.push "#{root}/#{stat.name}" if HAML_EXTENSION_REGEXP.test(stat.name)
          next()
    )

    console.log "Converting files:"
    Q
      .allSettled(_.map(files, (file) =>
        console.log(file)
        @convertFile(file, writeToFile)
      ))
      .catch((e) ->
        console.log e
      )
      .then(->
        console.log 'All files are converted.'
      )

  writeToSlimFile: (filePath, slimCode) ->
    slimFilePath = @getSlimPath(filePath)

    fd = fs.openSync(slimFilePath, 'w')
    fs.writeFileSync(slimFilePath, slimCode)
    fs.closeSync(fd)

  getAbsolutePath: (path) ->
    isAbsolutePath = path[0] is '/' or path[0] is '~'

    if isAbsolutePath
      path
    else
      path = "#{__dirname}/../#{path}"

  getSlimPath: (path) ->
    path.replace(HAML_EXTENSION_REGEXP, '.slim')

  parser: ->
    @_parser ?= new @Parser()

  _showWarnings: (compiler, filePath) ->
    return unless compiler.warnings?
    riline = new Riline(compiler.buffer)

    for warning in compiler.warnings
      text = warning.text
      text += '\n' + @getSlimPath(filePath) if filePath

      riline.addMessage
        text: text
        startLine: warning.startLine
        endLine: warning.endLine

    riline.printMessages()

module.exports = Slimmy
