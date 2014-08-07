Parser = require('../src/parser')
Q = require 'q'

describe 'Parser', ->

  beforeEach ->
    @parser = new Parser()

    AstNode = sinon.spy()
    @parser.astNodeClass = ->
      AstNode

    @rootNodeJson = {a: 1, b: 2, c: 3, children: [{a: 2}, {a: 3}, {b:3}]}
    @parser._execHamlParsing = (filePath) =>
      dfd = Q.defer()
      dfd.resolve(@rootNodeJson)
      dfd.promise

  describe '#parseFile', ->
    it 'saves tree of AstNode objects for given file in @root', ->
      @parser.parseFile('./fixtures/haml_document.haml').then =>
        AstNodeClass = @parser.astNodeClass()

        expect(@parser.root).to.be.instanceOf(AstNodeClass)
        expect(AstNodeClass).to.be.called.once
        expect(AstNodeClass.lastCall.args).to.be.eql [@rootNodeJson]

  describe '#_execHamlParsing', ->
    it 'parses file with ruby haml gem parser', ->
      parser = new Parser()
      parser._execHamlParsing('./fixtures/haml_document.haml').then (result) =>
        console.log result

  describe '#buildAstTree', ->
    xit 'creates tree of AstNode objects', ->
      data = {a: 1, children: [{a: 2}, {a: 3}, {a:4}]}

      result = @parser.buildAstTree(data)
      expect(result.constructor).to.match /AstNode/
      expect(result.children[0]).to.match /AstNode/

  describe '#convertDataToAstNode', ->
    xit 'converts json object to AstNode object', ->
      @parser.convertDataToAstNode(@rootNodeJson)
      expect(@parser._AstNode()).to.be.calledOnce
      expect(@parser._AstNode().lastCall.args).to.be.eql [a:1, b: 2, c: 3]

