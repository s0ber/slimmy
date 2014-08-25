AstNode = require '../src/ast_node'

describe 'AstNode', ->

  beforeEach ->
    @rootNodeJson =
      type: 'root',
      data:
        {a: 1, b: 2, c: 3}
      children: [
        {type: 'tag', data: {a: 1}, children: []}
        {type: 'silent_script', data: {text: ' # comment node'}, children: []}
        {type: 'tag', data: {a: 2}, children: []}
        {type: 'silent_script', data: {text: ' # comment node'}, children: []}
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
    it 'returns next child node of parent node and ignores comment nodes', ->
      Parser = require '../src/parser'
      parser = new Parser()
      rootNode = parser.buildASTree(@rootNodeJson)

      expect(rootNode.children[0].nextNode().data).to.be.eql {a: 2}
      expect(rootNode.children[2].nextNode().data).to.be.eql {a: 3}
      expect(rootNode.children[4].nextNode()).to.be.null

  describe '#prevNode', ->
    it 'returns prev child node of parent node and ignores comment nodes', ->
      Parser = require '../src/parser'
      parser = new Parser()
      rootNode = parser.buildASTree(@rootNodeJson)

      expect(rootNode.children[4].prevNode().data).to.be.eql {a: 2}
      expect(rootNode.children[2].prevNode().data).to.be.eql {a: 1}
      expect(rootNode.children[0].prevNode()).to.be.null

  describe '#isLastChild', ->
    it "returns true if node is a last child of it's parent", ->
      Parser = require '../src/parser'
      parser = new Parser()
      rootNode = parser.buildASTree(@rootNodeJson)

      expect(rootNode.children[4].isLastChild()).to.be.true
      expect(rootNode.children[2].isLastChild()).to.be.false

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

  describe '#isSilentScript', ->
    it 'returns true if node is silent script', ->
      node = new AstNode
        type: 'silent_script'
        data: {keyword: 'if'}

      expect(node.isSilentScript()).to.be.true

  describe '#isIfKeyword', ->
    it 'returns true if node is if keyword', ->
      node = new AstNode
        type: 'silent_script'
        data: {keyword: 'if'}

      expect(node.isSilentScript()).to.be.true

  describe '#isScript', ->
    it 'returns true if node is script', ->
      node = new AstNode
        type: 'script'
        data: {text: ' link_to'}

      expect(node.isScript()).to.be.true

  describe '#isComment', ->
    it 'returns true if node is silent script, which content starts with #', ->
      node = new AstNode
        type: 'silent_script'
        data: {text: ' # here is a comment'}

      expect(node.isComment()).to.be.true

  describe '#isFilter', ->
    it 'returns true if node is a filter', ->
      node = new AstNode
        type: 'filter'
        data: {name: 'javascript'}

      expect(node.isFilter()).to.be.true

  describe '#isInlineLink', ->
    context "node is script and it starts with 'link_to' and doesn't end with 'do'", ->
      it 'returns true', ->
        node = new AstNode
          type: 'script'
          data: {text: ' link_to "Link text", object_path, class: "my_class"'}

        expect(node.isInlineLink()).to.be.true

    context "node is script and it starts with 'link_to' and ends with 'do'", ->
      it 'returns false', ->
        node = new AstNode
          type: 'script'
          data: {text: ' link_to object_path, class: "my_class" do |block_var|'}

        expect(node.isInlineLink()).to.be.false

