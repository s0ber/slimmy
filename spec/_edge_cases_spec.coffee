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
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
          ' Plain text string
          | and another string.\n
        """

      @slimmy.convertString("""
          Plain text string
          and another string
          and one more string.
        """)
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
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
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
          ' Plain text string
          span
            ' and another string
            strong
              | and one more inner string.\n
        """

    it 'makes plain text node has trailing space if next node is inline link', ->
      @slimmy.convertString("""
          Plain text string
          %span
            and another string
            = link_to 'Some link'
            %strong and one more inner string.

        """)
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
          ' Plain text string
          span
            ' and another string
            => link_to 'Some link'
            strong
              | and one more inner string.\n
        """

    it 'makes inline tag has trailing space if next node is plain text', ->
      @slimmy.convertString("""
          Plain text string
          %span.with_class
            and another string
            %strong and one more inner string,
            and more,
          and even more.
        """)
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
          ' Plain text string
          span.with_class>
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
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
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

    it 'makes inline tag has trailing space if next node is inline link', ->
      @slimmy.convertString("""
          Plain text string
          %span
            and another string
            %strong and one more inner string,
            = link_to 'Some link'
            %i and cursiv string,
          %em and even more,
          and more.
        """)
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
          ' Plain text string
          span>
            ' and another string
            strong>
              | and one more inner string,
            => link_to 'Some link'
            i
              | and cursiv string,
          em>
            | and even more,
          | and more.\n
        """

    it 'makes inline link has trailing space if next node is plain text', ->
      @slimmy.convertString("""
          Plain text string
          %span
            and another string
            = link_to 'Some link'
            and more,
          and even more.
        """)
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
          ' Plain text string
          span>
            ' and another string
            => link_to 'Some link'
            | and more,
          | and even more.\n
        """

    it 'makes inline link has trailing space if next node is inline tag', ->
      @slimmy.convertString("""
          Plain text string
          %span
            and another string
            %strong and one more inner string,
            = link_to 'Some link'
            %i and cursiv string,
          %em and even more,
          and more.
        """)
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
          ' Plain text string
          span>
            ' and another string
            strong>
              | and one more inner string,
            => link_to 'Some link'
            i
              | and cursiv string,
          em>
            | and even more,
          | and more.\n
        """

    it 'makes inline link has trailing space if next node is inline link', ->
      @slimmy.convertString("""
          Plain text string
          %span
            and another string
            %strong and one more inner string,
            and more,
            = link_to 'Some link,'
            = link_to 'Some another link'
          and even more.
        """)
      .then (compiler) ->
        expect(compiler.buffer).to.be.equal """
          ' Plain text string
          span>
            ' and another string
            strong>
              | and one more inner string,
            ' and more,
            => link_to 'Some link,'
            = link_to 'Some another link'
          | and even more.\n
        """

  describe 'Warnings', ->
    context 'plain text followed by silent script', ->
      it 'throws a warning', ->
        @slimmy.convertString("""
            Plain text string
            - if true
              %span Some text.
            - else
              %span Another text.
          """)
        .then (compiler) ->
          expect(compiler.warnings).to.include
            text: 'Plain text is followed by a silent script, which execution result can be an inline element',
            startLine: 1

    context 'plain text followed by script', ->
      it 'throws a warning', ->
        @slimmy.convertString("""
            Text here.
            %div
              Some text in div.
            Plain text string
            = some_helper
            Another text.
            And more text.
          """)
        .then (compiler) ->
          expect(compiler.warnings).to.include
            text: 'Plain text is followed by a script, which execution result can be an inline element',
            startLine: 4

    context 'inline tag followed by silent script', ->
      it 'throws a warning', ->
        @slimmy.convertString("""
            Text here.
            %span
              Some text in div.
            - if true
              True
            - else
              False
            Another text.
            And more text.
          """)
        .then (compiler) ->
          expect(compiler.warnings).to.be.include
            text: 'Inline tag is followed by a silent script, which execution result can be an inline element',
            startLine: 2

    context 'inline tag followed by script', ->
      it 'throws a warning', ->
        @slimmy.convertString("""
            Text here.
            And more text.
            %span
              Some text in div.
            = some_helper
            Another text.
          """)
        .then (compiler) ->
          expect(compiler.warnings).to.include
            text: 'Inline tag is followed by a script, which execution result can be an inline element',
            startLine: 3

    context 'inline link followed by silent script', ->
      it 'throws a warning', ->
        @slimmy.convertString("""
            Text here.
            = link_to 'Some link'
            - if true
              True
            - else
              False
            Another text.
            And more text.
          """)
        .then (compiler) ->
          expect(compiler.warnings).to.be.include
            text: 'Inline link is followed by a silent script, which execution result can be an inline element',
            startLine: 2

    context 'inline link followed by script', ->
      it 'throws a warning', ->
        @slimmy.convertString("""
            Text here.
            And more text.
            %span
              Some text in div.
            = link_to ...
            = some_helper
            Another text.
          """)
        .then (compiler) ->
          expect(compiler.warnings).to.include
            text: 'Inline link is followed by a script, which execution result can be an inline element',
            startLine: 5

    context 'silent script followed by a plain text', ->
      it 'throws a warning', ->
        @slimmy.convertString("""
            - if true
              True
            - else
              False

            Another text.
          """)
        .then (compiler) ->
          expect(compiler.warnings).to.include
            text: 'Silent script, which execution can be an inline element, is followed by a plain text',
            startLine: 1

    context 'silent script followed by inline tag', ->
      it 'throws a warning', ->
        @slimmy.convertString("""
            - if true
              True
            - else
              False
            %span Another text.
          """)
        .then (compiler) ->
          expect(compiler.warnings).to.include
            text: 'Silent script, which execution can be an inline element, is followed by an inline tag',
            startLine: 1

    context 'script (not an inline link) followed by a plain text', ->
      it 'throws a warning', ->
        @slimmy.convertString("""
            = some_helper
            Another text.
          """)
        .then (compiler) ->
          expect(compiler.warnings).to.include
            text: 'Script, which execution can be an inline element, is followed by a plain text',
            startLine: 1

    context 'script (not an inline link) followed by inline tag', ->
      it 'throws a warning', ->
        @slimmy.convertString("""
            = some_helper
            %span Another text.
          """)
        .then (compiler) ->
          expect(compiler.warnings).to.include
            text: 'Script, which execution can be an inline element, is followed by an inline tag',
            startLine: 1

    context 'there is interpolated ruby code inside filter', ->
      it 'throws a warning', ->
        @slimmy.convertString('''
            :javascript
              $(\'body\').append #{some_method}
          ''')
        .then (compiler) ->
          expect(compiler.warnings).to.include
            text: 'There is interpolated ruby code inside javascript filter, which is not escaped in haml, but escaped by default in slim',
            startLine: 1

    context 'there is inline element inside silent script', ->
      it 'throws a warning', ->
        @slimmy.convertString("""
            - collection.each do |item|
              %div
              = link_to 'Something'
          """)
        .then (compiler) ->
          expect(compiler.warnings).to.include
            text: 'There is inline element inside silent script block, which may have trailing whitespace',
            startLine: 3

