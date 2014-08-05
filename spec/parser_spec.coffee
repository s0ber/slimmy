Parser = require('../src/parser')

describe 'Parser', ->

  beforeEach ->
    @originalAstNode = Parser._AstNode
    AstNode = sinon.spy()
    Parser._AstNode = -> AstNode

  afterEach ->
    Parser._AstNode = @originalAstNode

  describe '.parseFile', ->
    xit 'returns tree of AstNode objects for given file', ->
      Parser.parseFile('./fixtures/haml_document.haml').done (result) ->
        expect(result.constructor).to.match /AstTree/

  describe '.buildAstTree', ->
    xit 'creates tree of AstNode objects', ->
      data = {a: 1, children: [{a: 2}, {a: 3}, {a:4}]}

      result = Parser.buildAstTree(data)
      expect(result.constructor).to.match /AstTree/
      expect(result.children[0]).to.match /AstNode/

  describe '.convertDataToAstNode', ->
    xit 'converts json object to AstNode object', ->
      data = {a: 1, b: 2, c: 3, children: [{a: 2}, {a: 3}, {b:3}]}

      Parser.convertDataToAstNode(data)
      expect(Parser._AstNode()).to.be.calledOnce
      expect(Parser._AstNode().lastCall.args).to.be.eql [a:1, b: 2, c: 3]

