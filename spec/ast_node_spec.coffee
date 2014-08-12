AstNode = require '../src/ast_node'

describe 'AstNode', ->

  beforeEach ->
    @rootNodeJson =
      type: 'root',
      data:
        {a: 1, b: 2, c: 3}
      children: [
        {type: 'tag', data: {a: 2}, children: []}
        {type: 'tag', data: {a: 3}, children: []}
        {type: 'tag', data: {b: 3}, children: []}
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

