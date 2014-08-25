PREPEND_NEW_LINE_TAGS = 'body ol footer'.split(' ')
PREPEND_NEW_LINE_CLASSES = [
  'panel'
  'form__controls'
  'items_menu'
  'items_menu__item'
  'form-experience_field'
]

Config =
  shouldPrependWithEmptyLine: (node) ->
    shouldPrepend = node.type is 'tag' and node.data? and PREPEND_NEW_LINE_TAGS.indexOf(node.data.name) isnt -1
    shouldPrepend \
      or node.isComment?() \
      or (node.isIfKeyword?() and not node.parent?.isIfKeyword?()) \
      or node.hasClass?(PREPEND_NEW_LINE_CLASSES)

  shouldAppendEmptyLine: (node) ->
    false

module.exports = Config
