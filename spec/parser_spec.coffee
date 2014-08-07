Parser = require('../src/parser')
Q = require 'q'

describe 'Parser', ->

  beforeEach ->
    @parser = new Parser()
    @parser.AstNode = sinon.spy()

    @rootNodeJson = {a: 1, b: 2, c: 3, children: [{a: 2}, {a: 3}, {b:3}]}
    @parser._execHamlParsing = (filePath) =>
      dfd = Q.defer()
      dfd.resolve(@rootNodeJson)
      dfd.promise

  describe '#parseFile', ->
    it 'returns AstNode, which is root node of AST for given file', ->
      @parser.parseFile('./fixtures/haml_document.haml').then (rootNode) =>
        expect(@parser.AstNode).to.be.called.once
        expect(@parser.AstNode.lastCall.args).to.be.eql [@rootNodeJson]

        expect(rootNode).to.be.instanceOf(@parser.AstNode)

  describe '#buildASTree', ->
    xit 'creates tree of AstNode objects', ->
      data = {a: 1, children: [{a: 2}, {a: 3}, {a:4}]}

      result = @parser.buildASTree(data)
      expect(result.constructor).to.match /AstNode/
      expect(result.children[0]).to.match /AstNode/

  describe '#convertDataToAstNode', ->
    xit 'converts json object to AstNode object', ->
      @parser.convertDataToAstNode(@rootNodeJson)
      expect(@parser._AstNode()).to.be.calledOnce
      expect(@parser._AstNode().lastCall.args).to.be.eql [a:1, b: 2, c: 3]

  describe '#_execHamlParsing', ->
    xit 'parses file with ruby haml gem parser', ->
      parser = new Parser()
      parser.parseFile('./fixtures/haml_document.haml').then (result) =>
        console.log result

