Q = require 'q'
AstNode = require './ast_node'

class Parser

  # by providing public access to dependency,
  # we can mock it in tests on instance-level
  AstNode: AstNode

  parseFile: (filePath) ->
    @_execHamlParsing(filePath).then (data) =>
      @buildASTree(data)

  buildASTree: (data) ->
    @convertDataToAstNode(data)

  convertDataToAstNode: (data) ->
    new @AstNode(data)

  # this method executes async ruby command, you should mock it in tests
  _execHamlParsing: (filePath) ->
    dfd = Q.defer()
    exec = require('child_process').exec

    child = exec(@_hamlParseCmd(filePath), (error, output) =>
      dfd.resolve(JSON.parse(output))
    ).on('exit', (code) ->
      child.kill()
      unless code is 0
        console.log "Child process exited with exit code #{code}"
    )

    dfd.promise

  _hamlParseCmd: (filePath) ->
    isAbsolutePath = filePath[0] is '/' or filePath[0] is '~'
    filePath = "./../#{filePath}" unless isAbsolutePath

    "ruby ./../bin/haml_slim_converter.rb #{filePath}"

module.exports = Parser
