Slimmy = require('../src/slimmy')

describe 'Slimmy', ->

  beforeEach ->
    @slimmy = new Slimmy()

  describe 'Empty lines in file compilation mode', ->
    it 'prepends string with empty line, if it is main tag', ->
      @slimmy.convertString("""
        %head
        %body#unique.page.js-app-page_wrapper{class: 'my_class', data: {attr: 'value', another_attr: 'another_value'}}
          Some text here.
        """, true)
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
          head

          body#unique.page.js-app-page_wrapper class='my_class' data={attr: 'value', another_attr: 'another_value'}
            | Some text here.
          \n
          """
    it 'prepends compiled code with empty line if silent script is a comment', ->
      @slimmy.convertString("""
        %div

        - # it is comment
        """, true)
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
          div

          - # it is comment
          \n
          """

