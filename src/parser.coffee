Q = require 'q'
AstNode = require './ast_node'

class Parser

  # by providing public access to dependency,
  # we can mock it in tests on instance-level
  AstNode: AstNode

  parseFile: (filePath) ->
    @_execHamlFileParsing(filePath).then (data) =>
      @buildASTree(data)

  parseString: (hamlString) ->
    @_execHamlStringParsing(hamlString).then (data) =>
      @buildASTree(data)

  buildASTreeeeeee: (data) ->
    rootNode = @convertDataToAstNode(data)
    @setChildrenForAstNode(rootNode, data.children)

    rootNode

  buildASTree: (data) ->
    rootNode = @convertDataToAstNode(data)
    @setChildrenForAstNode(rootNode, data.children)

    rootNode

  setChildrenForAstNode: (node, childrenData = []) ->
    node.children ?= []
    for childData in childrenData
      childNode = @convertDataToAstNode(childData)
      @setParentForAstNode(childNode, node)
      node.children.push(childNode)
      @setChildrenForAstNode(childNode, childData.children)

  setParentForAstNode: (node, parentNode) ->
    node.setParent(parentNode)

  convertDataToAstNode: (data) ->
    new @AstNode(data)

  # this method executes async ruby command, you should mock it in tests
  _execHamlFileParsing: (filePath) ->
    dfd = Q.defer()
    exec = require('child_process').exec

    child = exec(@_hamlParseFileCmd(filePath), (error, output) ->
      dfd.resolve(JSON.parse(output))
    ).on('exit', (code) ->
      child.kill()
      unless code is 0
        console.log "Child process exited with exit code #{code}"
    )

    dfd.promise

  _hamlParseFileCmd: (filePath) ->
    converterPath = "#{__dirname}/../bin/haml_file_json_converter.rb"
    "ruby #{converterPath} #{filePath}"

  # this method executes async ruby command, you should mock it in tests
  _execHamlStringParsing: (hamlString) ->
    dfd = Q.defer()
    exec = require('child_process').exec

    child = exec(@_hamlParseStringCmd(hamlString), (error, output) ->
      dfd.resolve(JSON.parse(output))
    ).on('exit', (code) ->
      child.kill()
      unless code is 0
        console.log "Child process exited with exit code #{code}"
    )

    dfd.promise

  _hamlParseStringCmd: (hamlString) ->
    converterPath = "#{__dirname}/../bin/haml_string_json_converter.rb"
    "ruby #{converterPath} \"#{hamlString}\""

module.exports = Parser
