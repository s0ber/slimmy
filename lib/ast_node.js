(function() {
  var AstNode, INLINE_TAGS, MID_BLOCK_KEYWORDS, _;

  _ = require('underscore');

  INLINE_TAGS = 'b big i small tt abbr acronym cite code dfn em kbd strong samp var a bdo map object q script span sub sup'.split(' ');

  MID_BLOCK_KEYWORDS = 'else elsif rescue ensure end when'.split(' ');

  AstNode = (function() {
    function AstNode(json) {
      var data;
      data = _.clone(json.data);
      if (data != null) {
        delete data.children;
      }
      _.extend(this, {
        type: json.type,
        data: data
      });
      this.parent = null;
    }

    AstNode.prototype.setParent = function(node) {
      return this.parent = node;
    };

    AstNode.prototype.checkForWarnings = function() {
      var elName, nextNode, warningMessage, _ref;
      if (this.isComment()) {
        return;
      }
      nextNode = this.nextNode();
      if (nextNode == null) {
        if (this.isInline() && ((_ref = this.parent) != null ? _ref.isSilentScript() : void 0)) {
          return {
            text: 'There is inline element inside silent script block, which may have trailing whitespace'
          };
        } else {
          return;
        }
      }
      warningMessage = this.isPlain() ? nextNode.isSilentScript() && !nextNode.isMidBlockKeyword() ? 'Plain text is followed by a silent script, which execution result can be an inline element' : nextNode.isNonLinkScript() ? 'Plain text is followed by a script, which execution result can be an inline element' : void 0 : this.isInline() ? (elName = this.isInlineLink() ? 'link' : 'tag', nextNode.isSilentScript() && !nextNode.isMidBlockKeyword() ? "Inline " + elName + " is followed by a silent script, which execution result can be an inline element" : nextNode.isNonLinkScript() ? "Inline " + elName + " is followed by a script, which execution result can be an inline element" : void 0) : this.isNonLinkScript() ? nextNode.isPlain() ? 'Script, which execution can be an inline element, is followed by a plain text' : nextNode.isInline() ? (elName = nextNode.isInlineLink() ? 'link' : 'tag', "Script, which execution can be an inline element, is followed by an inline " + elName) : void 0 : this.isSilentScript() && !this.isMidBlockKeyword() ? nextNode.isPlain() ? 'Silent script, which execution can be an inline element, is followed by a plain text' : nextNode.isInline() ? (elName = nextNode.isInlineLink() ? 'link' : 'tag', "Silent script, which execution can be an inline element, is followed by an inline " + elName) : void 0 : this.isFilter() ? /#{/.test(this.data.text) ? "There is interpolated ruby code inside " + this.data.name + " filter, which is not escaped in haml, but escaped by default in slim" : void 0 : void 0;
      if (warningMessage != null) {
        return {
          text: warningMessage
        };
      } else {
        return null;
      }
    };

    AstNode.prototype.isInline = function() {
      switch (false) {
        case this.type !== 'plain':
          return true;
        case !(this.type === 'tag' && INLINE_TAGS.indexOf(this.data.name) !== -1):
          return true;
        case !this.isInlineLink():
          return true;
        default:
          return false;
      }
    };

    AstNode.prototype.isInlineLink = function() {
      var isBlock, isLinkHelper;
      if (!this.isScript()) {
        return false;
      }
      isLinkHelper = /^\s*link_to/.test(this.data.text);
      isBlock = /do(\s\|\w+\|)?$/.test(this.data.text);
      return isLinkHelper && !isBlock;
    };

    AstNode.prototype.isSilentScript = function() {
      return this.type === 'silent_script';
    };

    AstNode.prototype.isNonLinkScript = function() {
      return this.isScript() && !this.isInlineLink();
    };

    AstNode.prototype.isMidBlockKeyword = function() {
      return MID_BLOCK_KEYWORDS.indexOf(this.data.keyword) !== -1;
    };

    AstNode.prototype.isScript = function() {
      return this.type === 'script';
    };

    AstNode.prototype.isPlain = function() {
      return this.type === 'plain';
    };

    AstNode.prototype.isFilter = function() {
      return this.type === 'filter';
    };

    AstNode.prototype.isComment = function() {
      return this.type === 'silent_script' && /^\s*#/.test(this.data.text);
    };

    AstNode.prototype.nextNode = function() {
      var index, nextNode;
      if ((this.parent == null) || !_.isArray(this.parent.children)) {
        nextNode = null;
      } else {
        index = this.parent.children.indexOf(this);
        nextNode = index === -1 || (this.parent.children[index + 1] == null) ? null : this.parent.children[index + 1];
        if (nextNode != null ? nextNode.isComment() : void 0) {
          nextNode = nextNode.nextNode();
        }
      }
      return nextNode;
    };

    AstNode.prototype.prevNode = function() {
      var index, prevNode;
      if ((this.parent == null) || !_.isArray(this.parent.children)) {
        prevNode = null;
      } else {
        index = this.parent.children.indexOf(this);
        prevNode = index === -1 || (this.parent.children[index - 1] == null) ? null : this.parent.children[index - 1];
        if (prevNode != null ? prevNode.isComment() : void 0) {
          prevNode = prevNode.prevNode();
        }
      }
      return prevNode;
    };

    AstNode.prototype.isLastChild = function() {
      return this.nextNode() == null;
    };

    return AstNode;

  })();

  module.exports = AstNode;

}).call(this);
