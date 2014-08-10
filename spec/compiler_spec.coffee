Compiler = require('../src/compiler')

describe 'Compiler', ->
  beforeEach ->
    # this tree contain nodes with type 'spec',
    # which is not actual haml node type, but it is useful for testing
    # how tree is being build
    @rootNode =
      type: 'root'
      data: ''
      children: [
        {type: 'spec', data: {text: '.test_el'}, children: [
          {type: 'spec', data: {text: '.test_inner_el_1'}, children: []}
          {type: 'spec', data: {text: '.test_inner_el_2'}, children: [
            {type: 'spec', data: {text: '.test_inner_el_3'}, children: []}
          ]}
          {type: 'spec', data: {text: '.test_another_el_1'}, children: []}
          {type: 'spec', data: {text: '.test_another_el_2'}, children: [
            {type: 'spec', data: {text: '.test_another_el_3'}, children: []}
            {type: 'spec', data: {text: '.test_another_el_4'}, children: []}
          ]}
        ]}
      ]

    @compiler = new Compiler(@rootNode)

  describe '#constructor', ->
    it 'saves recieved ASTree in @root', ->
      expect(@compiler.root).to.be.equal @rootNode

    it 'has empty @buffer for keeping compiled code', ->
      expect(@compiler.buffer).to.be.eql ''

  describe '#compile', ->
    it 'compiles provided ASTree into slim code string', ->
      @compiler.compile()
      expect(@compiler.buffer).to.be.equal """
                                           .test_el
                                             .test_inner_el_1
                                             .test_inner_el_2
                                               .test_inner_el_3
                                             .test_another_el_1
                                             .test_another_el_2
                                               .test_another_el_3
                                               .test_another_el_4

                                           """

  describe '#compileNode', ->
    context 'node is root node', ->
      it 'calls @compileRoot node', ->
        try
          sinon.spy(@compiler, 'compileRoot')
          @compiler.compileNode(type: 'root')
        catch e
        expect(@compiler.compileRoot).to.be.calledOnce

    context 'node is plain text node', ->
      it 'calls @compilePlain node', ->
        try
          sinon.spy(@compiler, 'compilePlain')
          @compiler.compileNode(type: 'plain')
        catch e
          expect(@compiler.compilePlain).to.be.calledOnce

    context 'node is script node', ->
      it 'calls @compileScript node', ->
        try
          sinon.spy(@compiler, 'compileScript')
          @compiler.compileNode(type: 'script')
        catch e
          expect(@compiler.compileScript).to.be.calledOnce

    context 'node is silent script node', ->
      it 'calls @compileSilentScript node', ->
        try
          sinon.spy(@compiler, 'compileSilentScript')
          @compiler.compileNode(type: 'silent_script')
        catch e
          expect(@compiler.compileSilentScript).to.be.calledOnce

    context 'node is haml comment node', ->
      it 'calls @compileHamlComment node', ->
        try
          sinon.spy(@compiler, 'compileHamlComment')
          @compiler.compileNode(type: 'haml_comment')
        catch e
          expect(@compiler.compileHamlComment).to.be.calledOnce

    context 'node is tag node', ->
      it 'calls @compileTag node', ->
        try
          sinon.spy(@compiler, 'compileTag')
          @compiler.compileNode(type: 'tag')
        catch e
          expect(@compiler.compileTag).to.be.calledOnce

    context 'node is comment node', ->
      it 'calls @compileComment node', ->
        try
          sinon.spy(@compiler, 'compileComment')
          @compiler.compileNode(type: 'comment')
        catch e
          expect(@compiler.compileComment).to.be.calledOnce

    context 'node is doctype node', ->
      it 'calls @compileDoctype node', ->
        try
          sinon.spy(@compiler, 'compileDoctype')
          @compiler.compileNode(type: 'doctype')
        catch e
          expect(@compiler.compileDoctype).to.be.calledOnce

    context 'node is filter node', ->
      it 'calls @compileFilter node', ->
        try
          sinon.spy(@compiler, 'compileFilter')
          @compiler.compileNode(type: 'filter')
        catch e
          expect(@compiler.compileFilter).to.be.calledOnce

    context 'node is spec node', ->
      it 'calls @compileSpec node', ->
        try
          sinon.spy(@compiler, 'compileSpec')
          @compiler.compileNode(type: 'spec')
        catch e
          expect(@compiler.compileSpec).to.be.calledOnce

      it 'compiles node based on only node.data.text value', ->
        @compiler.buffer = ''
        @compiler.compileNode
          type: 'spec'
          data: {text: 'OLOLO'}

        expect(@compiler.buffer).to.be.equal 'OLOLO\n'
