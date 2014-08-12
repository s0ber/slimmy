AstNode = require '../src/ast_node'

describe 'AstNode', ->

  beforeEach ->
    @rootNodeJson =
      type: 'root',
      data:
        {a: 1, b: 2, c: 3}
      children: [
        {type: 'tag', data: {a: 1}, children: []}
        {type: 'tag', data: {a: 2}, children: []}
        {type: 'tag', data: {a: 3}, children: []}
      ]

    @node = new AstNode(@rootNodeJson)

  describe '#constructor', ->
    it 'sets node type and node data in AstNode object', ->
      expect(@node.type).to.be.eql(@rootNodeJson.type)
      expect(@node.data).to.be.eql(@rootNodeJson.data)
      expect(@node.data).to.be.not.equal(@rootNodeJson.data)

    it 'sets data without children references in AstNode object', ->
      expect(@node.children).to.be.undefined

  describe '#setParent', ->
    it 'sets provided node as parent for the current node', ->
      @childNode = new AstNode(type: 'tag', data: {a: 2}, children: [])
      @childNode.setParent(@node)

      expect(@childNode.parent).to.be.equal @node

  describe '#nextNode', ->
    it 'returns next child node of parent node', ->
      Parser = require '../src/parser'
      parser = new Parser()
      rootNode = parser.buildASTree(@rootNodeJson)

      expect(rootNode.children[0].nextNode().data).to.be.eql {a: 2}
      expect(rootNode.children[1].nextNode().data).to.be.eql {a: 3}
      expect(rootNode.children[2].nextNode()).to.be.null

  describe '#prevNode', ->
    it 'returns prev child node of parent node', ->
      Parser = require '../src/parser'
      parser = new Parser()
      rootNode = parser.buildASTree(@rootNodeJson)

      expect(rootNode.children[2].prevNode().data).to.be.eql {a: 2}
      expect(rootNode.children[1].prevNode().data).to.be.eql {a: 1}
      expect(rootNode.children[0].prevNode()).to.be.null

  describe '#isInline', ->
    context 'node is plain text', ->
      it 'returns true', ->
        node = new AstNode
          type: 'plain'
          data: {text: 'Some text here.'}

        expect(node.isInline()).to.be.true

    context 'node is inline tag', ->
      it 'returns true', ->
        node = new AstNode
          type: 'tag'
          data: {name: 'span', value: 'Inline text'}

        expect(node.isInline()).to.be.true
