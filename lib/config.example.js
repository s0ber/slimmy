(function() {
  var Config, MAIN_TAGS;

  MAIN_TAGS = 'body footer'.split(' ');

  Config = {
    shouldPrependWithEmptyLine: function(node) {
      var isMainTag;
      isMainTag = node.type === 'tag' && (node.data != null) && MAIN_TAGS.indexOf(node.data.name) !== -1;
      return isMainTag || (typeof node.isComment === "function" ? node.isComment() : void 0);
    }
  };

  module.exports = Config;

}).call(this);
