Slimmy = require('../src/slimmy')
Q = require 'q'

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
      parseFile: (filePath) ->
        dfd = Q.defer()
        dfd.resolve(rootNode)
        dfd.promise

    sinon.spy(@slimmy.Parser::, 'parseFile')

    @slimmy.Compiler = class
      compile: (rootNode) ->

    sinon.spy(@slimmy, 'Compiler')
    sinon.spy(@slimmy.Compiler::, 'compile')

  describe '#convertDir', ->
    it 'converts all haml files in a dir', ->
      filesNumber = 8
      sinon.spy(@slimmy, 'convert')
      @slimmy.convertDir('./spec/fixtures/folder/')
      expect(@slimmy.convert.callCount).to.be.equal(filesNumber)

  describe '#convert', ->
    it 'at first parses provided file and then compiles slim from recieved ASTree', ->
      @slimmy.convert('./spec/fixtures/haml_document.haml').then =>
        expect(@slimmy.Parser::parseFile).to.be.calledOnce
        expect(@slimmy.Compiler.lastCall.args).to.be.eql [@rootNode]
        expect(@slimmy.Compiler::compile).to.be.calledOnce
        expect(@slimmy.Compiler::compile).to.be.calledAfter @slimmy.Parser::parseFile

    # not actual test case, just printing compiled (to slim) haml document to console
    it 'logs compiled fixture to concole', ->
      slimmy = new Slimmy()
      slimmy.convert('./spec/fixtures/haml_document.haml').then ->
        console.log('\n')
        console.log(slimmy._compilationResults)

