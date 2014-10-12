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
      @timeout(10000)
      filesNumber = 8
      slimmy = new Slimmy()

      sinon.spy(slimmy, 'convertFile')
      slimmy.convertDir('./spec/fixtures/folder', false).then ->
        expect(slimmy.convertFile.callCount).to.be.equal(filesNumber)

  describe '#removeHamlFromDir', ->
    xit 'remove all haml files in a dir', ->
      @timeout(10000)
      filesNumber = 8
      slimmy = new Slimmy()

      sinon.spy(slimmy, 'deleteHamlFile')
      slimmy.removeHamlFromDir('./spec/fixtures/folder')
      expect(slimmy.deleteHamlFile.callCount).to.be.equal(filesNumber)

  describe '#convertFile', ->
    it 'at first parses provided file and then compiles slim from recieved ASTree', ->
      @slimmy.convertFile('./spec/fixtures/haml_document.haml', false).then =>
        expect(@slimmy.Parser::parseFile).to.be.calledOnce
        expect(@slimmy.Compiler.lastCall.args).to.be.eql [@rootNode]
        expect(@slimmy.Compiler::compile).to.be.calledOnce
        expect(@slimmy.Compiler::compile).to.be.calledAfter @slimmy.Parser::parseFile

    # not actual test case, just printing compiled (to slim) haml document to console
    it 'logs compiled fixture to console', ->
      slimmy = new Slimmy()
      slimmy.convertFile('./spec/fixtures/haml_document.haml', false).then ->
        # console.log('\n')
        # console.log(slimmy._compilationResults)

  describe '#convertString', ->
    it 'converts provided haml string to a slim code string', ->
      slimmy = new Slimmy()

      slimmy.convertString("""
        %html
          %head
          %body
      """).then (compiler) ->
        expect(compiler.buffer).to.be.equal """
          html
            head
            body\n
        """
