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

      it 'compiles nothing', ->
        @compiler.compileRoot(type: 'root', data: {text: 'Some text'})
        expect(@compiler.buffer).to.be.eql ''

    context 'node is plain text node', ->
      it 'calls @compilePlain node', ->
        try
          sinon.spy(@compiler, 'compilePlain')
          @compiler.compileNode(type: 'plain')
        catch e
          expect(@compiler.compilePlain).to.be.calledOnce

      it 'compiles based on node.data.text value', ->
        @compiler.compilePlain
          type: 'plain'
          data: {text: 'Some text'}

        expect(@compiler.buffer).to.be.eql """
          | Some text\n
          """

    context 'node is script node', ->
      it 'calls @compileScript node', ->
        try
          sinon.spy(@compiler, 'compileScript')
          @compiler.compileNode(type: 'script')
        catch e
          expect(@compiler.compileScript).to.be.calledOnce

      it 'compiles proper slim string for script evaluation', ->
        @compiler.compileScript
          type: 'script',
          data:
            text: ' link_to title, path, class: "menu-item js-app-menu_item #{\'is-active\' if current_page}", data: {menu_item_id: options[:menu_item_id]}'

        expect(@compiler.buffer).to.be.eql '= link_to title, path, class: "menu-item js-app-menu_item #{\'is-active\' if current_page}\", data: {menu_item_id: options[:menu_item_id]}\n'

      it 'compiles text string with interpolated ruby code if script is a string', ->
        @compiler.compileScript
          "type": "script"
          "data":
            "text": '"Some #{a} here."'

        expect(@compiler.buffer).to.be.eql 'Some #{a} here.\n'

    context 'node is silent script node', ->
      it 'calls @compileSilentScript node', ->
        try
          sinon.spy(@compiler, 'compileSilentScript')
          @compiler.compileNode(type: 'silent_script')
        catch e
          expect(@compiler.compileSilentScript).to.be.calledOnce

      it 'compiles proper slim string for silent script evaluation', ->
        @compiler.compileSilentScript
          type: 'silent_script'
          data:
            text: ' menu_items.each do |title, path, options = {}|'

        expect(@compiler.buffer).to.be.eql '- menu_items.each do |title, path, options = {}|\n'

      it 'prepends compiled code with empty line if silent script is a comment', ->
        @compiler.compileSilentScript
          type: 'silent_script'
          data:
            text: ' # it is comment'

        expect(@compiler.buffer).to.be.eql """

        - # it is comment\n
        """

      it 'works good with midlevel keywords', ->
        node =
          "type": "silent_script",
          "data":
            "text": " if true",
            "keyword": "if",
          "children": [
            {"type": "tag",
            "data":
              "name": "span",
              "value": "It was true"}
            {"type": "silent_script",
            "data":
              "text": " else",
              "keyword": "else"}
            {"type": "tag",
            "data":
              "name": "span",
              "value": "it was false..."}
          ]

        @compiler.compileNode(node, 0)
        @compiler.compileChildrenNodes(node, 1)
        expect(@compiler.buffer).to.be.equal """
          - if true
            span
              | It was true
          - else
            span
              | it was false...

        """

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

      it 'compiles proper slim string for tag without id or classes', ->
        @compiler.compileTag
          "type": "tag",
          "data":
            "name": "span"
            "attributes": {}
            "attributes_hashes": [
              "class: 'my_class', data: {attr: 'value', another_attr: 'another_value'}"
            ]

        expect(@compiler.buffer).to.be.equal """
          span class='my_class' data={attr: 'value', another_attr: 'another_value'}\n
          """

      it 'compiles div tag if no classes or no id for this div provided', ->
        @compiler.compileTag
          "type": "tag",
          "data":
            "name": "div"
            "attributes": {}
            "attributes_hashes": [
              "class: 'my_class', data: {attr: 'value', another_attr: 'another_value'}"
            ]
            "value": "Some text here."

        @compiler.compileTag
          "type": "tag",
          "data":
            "name": "div"
            "attributes": {
              "class": "some_class"
            }
            "attributes_hashes": [
              "class: 'other_class'"
            ]
            "value": "Some text here."

        expect(@compiler.buffer).to.be.equal """
          div class='my_class' data={attr: 'value', another_attr: 'another_value'}
            | Some text here.
          .some_class class='other_class'
            | Some text here.\n
          """

      it 'compiles proper slim string for tag with id or classes', ->
        @compiler.compileTag
          "type": "tag",
          "data":
            "name": "div"
            "attributes":
              "id": "unique"
              "class": "page js-app-page_wrapper"
            "attributes_hashes": [
              "class: 'my_class', data: {attr: 'value', another_attr: 'another_value'}"
            ]

        expect(@compiler.buffer).to.be.equal """
          #unique.page.js-app-page_wrapper class='my_class' data={attr: 'value', another_attr: 'another_value'}\n
          """

      it 'compiles inner text on the next line, if it exists', ->
        @compiler.compileTag
          "type": "tag",
          "data":
            "name": "div"
            "attributes":
              "id": "unique"
              "class": "page js-app-page_wrapper"
            "attributes_hashes": [
              "class: 'my_class', data: {attr: 'value', another_attr: 'another_value'}"
            ]
            "value": "Some text here."

        expect(@compiler.buffer).to.be.equal """
          #unique.page.js-app-page_wrapper class='my_class' data={attr: 'value', another_attr: 'another_value'}
            | Some text here.\n
          """

      it 'prepends string with line break, if it is main tag', ->
        @compiler.compileTag
          "type": "tag",
          "data":
            "name": "body"
            "attributes":
              "id": "unique"
              "class": "page js-app-page_wrapper"
            "attributes_hashes": [
              "class: 'my_class', data: {attr: 'value', another_attr: 'another_value'}"
            ]
            "value": "Some text here."

        expect(@compiler.buffer).to.be.equal """

          body#unique.page.js-app-page_wrapper class='my_class' data={attr: 'value', another_attr: 'another_value'}
            | Some text here.\n
          """
      it 'works with parsed data', ->
        @compiler.compileTag
          "type": "tag",
          "data":
            "name": "span",
            "parse": true,
            "value": "link_to item_path, class: 'menu-item_link'"

        expect(@compiler.buffer).to.be.equal """
          span =link_to item_path, class: 'menu-item_link'\n
          """

      it 'works with multiline text strings', ->
        @compiler.compileTag
          "type": "tag",
          "data":
            "name": "p",
            "parse": true,
            "value": "h(                         \"I think this might get \" +  \"pretty long so I should \" + \"probably make it \" +        \"multiline so it doesn't \" + \"look awful.\" )"

        expect(@compiler.buffer).to.be.equal """
          p =h("I think this might get " + \
          "pretty long so I should " + \
          "probably make it " + \
          "multiline so it doesn't " + \
          "look awful.")\n
          """

    context 'node is comment node', ->
      it 'calls @compileComment node', ->
        try
          sinon.spy(@compiler, 'compileComment')
          @compiler.compileNode(type: 'comment')
        catch e
          expect(@compiler.compileComment).to.be.calledOnce

      it 'compiles node as html comment', ->
        @compiler.compileComment
          type: 'comment'
          data:
            text: 'Some comment here'

        expect(@compiler.buffer).to.be.eql('/! Some comment here\n')

      it 'compiles node as html comment even if not text provided', ->
        @compiler.compileComment
          type: 'comment'
          data:
            text: ''

        expect(@compiler.buffer).to.be.eql('/!\n')

    context 'node is doctype node', ->
      it 'calls @compileDoctype node', ->
        try
          sinon.spy(@compiler, 'compileDoctype')
          @compiler.compileNode(type: 'doctype')
        catch e
          expect(@compiler.compileDoctype).to.be.calledOnce

      it 'compiles proper slim doctype', ->
        @compiler.compileDoctype
          "type": "doctype"
          "data":
            "version": "5"

        expect(@compiler.buffer).to.be.eql 'doctype html\n'

    context 'node is filter node', ->
      it 'calls @compileFilter node', ->
        try
          sinon.spy(@compiler, 'compileFilter')
          @compiler.compileNode(type: 'filter')
        catch e
          expect(@compiler.compileFilter).to.be.calledOnce

      it 'compiles slim filter with proper indentation', ->
        @compiler.compileFilter
          "type": "filter"
          "data":
            "name": "sass"
            "text": ".my_class.is-blue\n  color: blue\n\n"

        expect(@compiler.buffer).to.be.equal """
          :sass
            .my_class.is-blue
              color: blue
          \n
        """

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

  describe '#compileAttrsHash', ->
    it 'compiles attributes hashes into slim format', ->
      hashes = [
        "class: 'my_class', data: {attr: 'value', another_attr: 'another_value'}"
        "class: 'my_class',\ndata: {attr: 'value',\nanother_attr: 'another_value'}"
        "class: ['my_class', 'my_another_class']"
      ]

      expect(@compiler.compileAttrsHashes(hashes)).to.be.eql [
        "class='my_class' data={attr: 'value', another_attr: 'another_value'}",
        "class='my_class' data={attr: 'value', another_attr: 'another_value'}"
        "class=['my_class', 'my_another_class']"
      ]

