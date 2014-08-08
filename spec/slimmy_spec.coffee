Slimmy = require('../src/slimmy')

describe 'Slimmy', ->

  beforeEach ->
    @rootNode = rootNode =
      type: 'root',
      data:
        {a: 1, b: 2, c: 3}
      children: [
        {type: 'tag', data: {a: 2}, children: []}
        {type: 'tag', data: {a: 3}, children: []}
        {type: 'tag', data: {b: 3}, children: []}
      ]

    @slimmy = new Slimmy()
    @slimmy.Parser = class
      parseFile: (filePath) -> rootNode

    sinon.spy(@slimmy.Parser::, 'parseFile')

    @slimmy.Compiler = class
      compile: (rootNode) ->

    sinon.spy(@slimmy.Compiler::, 'compile')

  describe '#convert', ->
    it 'at first parses provided file and then compiles slim from recieved ASTree', ->
      @slimmy.convert('./fixtures/haml_document.haml')
      expect(@slimmy.Parser::parseFile).to.be.calledOnce
      expect(@slimmy.Compiler::compile).to.be.calledOnce

      expect(@slimmy.Compiler::compile).to.be.calledAfter @slimmy.Parser::parseFile
      expect(@slimmy.Compiler::compile.lastCall.args).to.be.eql [@rootNode]
