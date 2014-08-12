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

      @slimmy.convertString("""
          Plain text string
          and another string
          and one more string.
        """)
      .then (code) ->
        expect(code).to.be.equal """
          ' Plain text string
          ' and another string
          | and one more string.\n
        """

    it 'makes plain text node has trailing space if next node is inline tag node', ->
      @slimmy.convertString("""
          Plain text string
          %span
            and another string
            %span and one more inner string.

        """)
      .then (code) ->
        expect(code).to.be.equal """
          ' Plain text string
          span
            ' and another string
            span
              | and one more inner string.\n
        """

