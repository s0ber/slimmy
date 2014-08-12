Slimmy = require('../src/slimmy')

describe 'Slimmy', ->

  beforeEach ->
    @slimmy = new Slimmy()

  describe 'Inline elements sequences', ->
    it 'makes plain text node has trailing space if next node is plain text', ->
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

    it 'makes plain text node has trailing space if next node is inline tag', ->
      @slimmy.convertString("""
          Plain text string
          %span
            and another string
            %strong and one more inner string.

        """)
      .then (code) ->
        expect(code).to.be.equal """
          ' Plain text string
          span
            ' and another string
            strong
              | and one more inner string.\n
        """

    it 'makes inline tag has trailing space if next node is plain text', ->
      @slimmy.convertString("""
          Plain text string
          %span
            and another string
            %strong and one more inner string,
            and more,
          and even more.
        """)
      .then (code) ->
        expect(code).to.be.equal """
          ' Plain text string
          span>
            ' and another string
            strong>
              | and one more inner string,
            | and more,
          | and even more.\n
        """

    it 'makes inline tag has trailing space if next node is inline tag', ->
      @slimmy.convertString("""
          Plain text string
          %span
            and another string
            %strong and one more inner string,
            %i and cursiv string,
          %em and even more,
          and more.
        """)
      .then (code) ->
        expect(code).to.be.equal """
          ' Plain text string
          span>
            ' and another string
            strong>
              | and one more inner string,
            i
              | and cursiv string,
          em>
            | and even more,
          | and more.\n
        """

