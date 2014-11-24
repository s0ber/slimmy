(function() {
  var Config, PREPEND_NEW_LINE_CLASSES, PREPEND_NEW_LINE_TAGS;

  PREPEND_NEW_LINE_TAGS = 'body ol footer'.split(' ');

  PREPEND_NEW_LINE_CLASSES = ['panel', 'form__controls', 'items_menu', 'items_menu__item', 'form-experience_field'];

  Config = {
    shouldPrependWithEmptyLine: function(node) {
      var shouldPrepend, _ref;
      shouldPrepend = node.type === 'tag' && (node.data != null) && PREPEND_NEW_LINE_TAGS.indexOf(node.data.name) !== -1;
      return shouldPrepend || (typeof node.isComment === "function" ? node.isComment() : void 0) || ((typeof node.isIfKeyword === "function" ? node.isIfKeyword() : void 0) && !((_ref = node.parent) != null ? typeof _ref.isIfKeyword === "function" ? _ref.isIfKeyword() : void 0 : void 0)) || (typeof node.hasClass === "function" ? node.hasClass(PREPEND_NEW_LINE_CLASSES) : void 0);
    },
    shouldAppendEmptyLine: function(node) {
      return false;
    }
  };

  module.exports = Config;

}).call(this);
