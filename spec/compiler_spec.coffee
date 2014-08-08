Compiler = require('../src/compiler')

describe 'Compiler', ->
  beforeEach ->
    @rootNode = {}
    @compiler = new Compiler(@rootNode)

  describe '#constructor', ->
    it 'saves recieved ASTree in @root', ->
      expect(@compiler.root).to.be.equal @rootNode

    it 'has empty @buffer for keeping compiled code', ->
      expect(@compiler.buffer).to.be.eql ''

  describe '#compileNode', ->
    context 'node is root node', ->
      it 'calls @compileRoot node', ->
        sinon.spy(@compiler, 'compileRoot')
        @compiler.compileNode(type: 'root')
        expect(@compiler.compileRoot).to.be.calledOnce

    context 'node is plain text node', ->
      it 'calls @compilePlain node', ->
        sinon.spy(@compiler, 'compilePlain')
        @compiler.compileNode(type: 'plain')
        expect(@compiler.compilePlain).to.be.calledOnce

    context 'node is script node', ->
      it 'calls @compileScript node', ->
        sinon.spy(@compiler, 'compileScript')
        @compiler.compileNode(type: 'script')
        expect(@compiler.compileScript).to.be.calledOnce

    context 'node is silent script node', ->
      it 'calls @compileSilentScript node', ->
        sinon.spy(@compiler, 'compileSilentScript')
        @compiler.compileNode(type: 'silent_script')
        expect(@compiler.compileSilentScript).to.be.calledOnce

    context 'node is haml comment node', ->
      it 'calls @compileHamlComment node', ->
        sinon.spy(@compiler, 'compileHamlComment')
        @compiler.compileNode(type: 'haml_comment')
        expect(@compiler.compileHamlComment).to.be.calledOnce

    context 'node is tag node', ->
      it 'calls @compileTag node', ->
        sinon.spy(@compiler, 'compileTag')
        @compiler.compileNode(type: 'tag')
        expect(@compiler.compileTag).to.be.calledOnce

    context 'node is comment node', ->
      it 'calls @compileComment node', ->
        sinon.spy(@compiler, 'compileComment')
        @compiler.compileNode(type: 'comment')
        expect(@compiler.compileComment).to.be.calledOnce

    context 'node is doctype node', ->
      it 'calls @compileDoctype node', ->
        sinon.spy(@compiler, 'compileDoctype')
        @compiler.compileNode(type: 'doctype')
        expect(@compiler.compileDoctype).to.be.calledOnce

    context 'node is filter node', ->
      it 'calls @compileFilter node', ->
        sinon.spy(@compiler, 'compileFilter')
        @compiler.compileNode(type: 'filter')
        expect(@compiler.compileFilter).to.be.calledOnce

