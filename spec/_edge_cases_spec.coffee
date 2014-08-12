Slimmy = require('../src/slimmy')

describe 'Slimmy', ->

  beforeEach ->
    @slimmy = new Slimmy()

  describe 'Inline tags sequences', ->
    it 'makes plain text node has trailing space if next node is plain text node', ->
      @slimmy.convertString("""
          Plain text string
          and another string.
        """)
      .then (code) ->
        expect(code).to.be.equal """
          ' Plain text string
          | and another string.\n
        """

