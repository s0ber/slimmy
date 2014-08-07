Q = require 'q'

class Parser

  parseFile: (filePath) ->
    @_execHamlParsing(filePath).then (data) =>
      AstNode = @astNodeClass()
      @root = new AstNode(data)

  convertDataToAstNode: ->

  # this method executes async ruby command, you should mock it in tests
  _execHamlParsing: (filePath) ->
    dfd = Q.defer()
    exec = require('child_process').exec
    dfd.resolve('ololo')
    dfd.promise

  astNodeClass: ->
    @_astNodeClass ?= require './ast_node'

module.exports = Parser
