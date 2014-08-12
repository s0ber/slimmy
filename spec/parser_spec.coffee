Parser = require('../src/parser')
Q = require 'q'

describe 'Parser', ->

  beforeEach ->
    @parser = new Parser()
    @parser.AstNode = sinon.spy()
    @parser.setParentForAstNode = ->

    @rootNodeJson =
      type: 'root',
      data:
        {a: 1, b: 2, c: 3}
      children: [
        {type: 'tag', data: {a: 2}, children: []}
        {type: 'tag', data: {a: 3}, children: []}
        {type: 'tag', data: {b: 3}, children: []}
      ]

    @parser._execHamlParsing = (filePath) =>
      dfd = Q.defer()
      dfd.resolve(@rootNodeJson)
      dfd.promise

  describe '#parseFile', ->
    it 'returns AstNode, which is root node of AST for given file', ->
      @parser.parseFile('./spec/fixtures/haml_document.haml').then (rootNode) =>
        expect(@parser.AstNode).to.be.called.once
        expect(@parser.AstNode.firstCall.args).to.be.eql [@rootNodeJson]

        expect(rootNode).to.be.instanceOf(@parser.AstNode)

  describe '#buildASTree', ->
    it 'creates tree of AstNode objects', ->
      data = {a: 1, children: [{a: 2}, {a: 3}, {a:4}]}

      result = @parser.buildASTree(data)
      expect(result).to.be.instanceof(@parser.AstNode)
      expect(result.children[0]).to.be.instanceof(@parser.AstNode)

  describe '#convertDataToAstNode', ->
    it 'converts json object to AstNode object', ->
      node = @parser.convertDataToAstNode(@rootNodeJson)
      expect(node).to.be.instanceOf(@parser.AstNode)

    it 'provides data to AstNode constructor', ->
      node = @parser.convertDataToAstNode(@rootNodeJson)
      expect(@parser.AstNode.lastCall.args).to.be.eql [@rootNodeJson]

  describe '#setChildrenForAstNode', ->
    it 'sets children for node', ->
      rootNode = @parser.convertDataToAstNode(@rootNodeJson)
      @parser.setChildrenForAstNode(rootNode, @rootNodeJson.children)
      expect(rootNode.children).to.have.length 3

    it 'makes children have @parent pointing to parent node', ->
      parser = new Parser()
      rootNode = parser.convertDataToAstNode(@rootNodeJson)
      parser.setChildrenForAstNode(rootNode, @rootNodeJson.children)

      for childNode in rootNode.children
        expect(childNode.parent).to.be.equal rootNode

  describe '#_execHamlParsing', ->
    it 'parses file with ruby haml gem parser', ->
      parser = new Parser()
      parser._execHamlParsing('./spec/fixtures/haml_document.haml').then (result) =>
        # console.log result
