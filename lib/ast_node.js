(function() {
  var AstNode, _;

  _ = require('underscore');

  AstNode = (function() {
    function AstNode(json) {
      _.extend(this, {
        type: json.type,
        data: _.clone(json.data)
      });
    }

    return AstNode;

  })();

  module.exports = AstNode;

}).call(this);
