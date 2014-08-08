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
    rootNode = @convertDataToAstNode(data)
    @setChildrenForAstNode(rootNode, data.children)

    rootNode

  setChildrenForAstNode: (node, childrenData = []) ->
    node.children ?= []
    for childData in childrenData
      childNode = @convertDataToAstNode(childData)
      node.children.push(childNode)
      @setChildrenForAstNode(childNode, childData.children)

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
    converterPath = "#{__dirname}/../bin/haml_json_converter.rb"

    isAbsolutePath = filePath[0] is '/' or filePath[0] is '~'
    unless isAbsolutePath
      filePath = "#{__dirname}/../#{filePath}"

    "ruby #{converterPath} #{filePath}"

module.exports = Parser
