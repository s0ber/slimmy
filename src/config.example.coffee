MAIN_TAGS = 'body footer'.split(' ')

Config =
  shouldPrependWithEmptyLine: (node) ->
    isMainTag = node.type is 'tag' and node.data? and MAIN_TAGS.indexOf(node.data.name) isnt -1
    isMainTag or node.isComment?() or node.isIfKeyword()

module.exports = Config
