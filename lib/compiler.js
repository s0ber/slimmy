(function() {
  var Compiler, INDENTATION, IND_LEVEL, LINE_BREAK, MAIN_TAGS, MID_BLOCK_KEYWORDS, _;

  _ = require('underscore');

  INDENTATION = "  ";

  IND_LEVEL = 0;

  LINE_BREAK = '\n';

  MAIN_TAGS = 'body footer'.split(' ');

  MID_BLOCK_KEYWORDS = 'else elsif rescue ensure end when'.split(' ');

  Compiler = (function() {
    function Compiler(rootNode) {
      this.root = rootNode;
      this.buffer = '';
    }

    Compiler.prototype.compile = function() {
      this.compileNode(this.root, IND_LEVEL);
      this.compileChildrenNodes(this.root, IND_LEVEL);
      return this.buffer += LINE_BREAK;
    };

    Compiler.prototype.compileChildrenNodes = function(node, indLevel) {
      var child, _i, _len, _ref, _results;
      if (!node.children) {
        return;
      }
      _ref = node.children;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        child = _ref[_i];
        this.compileNode(child, indLevel);
        _results.push(this.compileChildrenNodes(child, indLevel + 1));
      }
      return _results;
    };

    Compiler.prototype.compileNode = function(node, indLevel) {
      var compilationMethod;
      compilationMethod = (function() {
        switch (node.type) {
          case 'root':
            return 'compileRoot';
          case 'plain':
            return 'compilePlain';
          case 'script':
            return 'compileScript';
          case 'silent_script':
            return 'compileSilentScript';
          case 'haml_comment':
            return 'compileHamlComment';
          case 'tag':
            return 'compileTag';
          case 'comment':
            return 'compileComment';
          case 'doctype':
            return 'compileDoctype';
          case 'filter':
            return 'compileFilter';
          case 'spec':
            return 'compileSpec';
        }
      })();
      if (!compilationMethod) {
        return;
      }
      return this[compilationMethod](node, indLevel);
    };

    Compiler.prototype.compileRoot = function(node, indLevel) {};

    Compiler.prototype.compilePlain = function(node, indLevel) {
      var firstChar;
      firstChar = node.data.text[0];
      return this.buffer += this.getIndent(indLevel) + '| ' + node.data.text + LINE_BREAK;
    };

    Compiler.prototype.compileScript = function(node, indLevel) {
      var isInterpolatedString, scriptLen;
      scriptLen = node.data.text.length;
      isInterpolatedString = node.data.text[0] === '"' && node.data.text[scriptLen - 1] === '"';
      if (isInterpolatedString) {
        return this.buffer += this.getIndent(indLevel) + node.data.text.substr(1, scriptLen - 2) + LINE_BREAK;
      } else {
        return this.buffer += this.getIndent(indLevel) + '=' + node.data.text + LINE_BREAK;
      }
    };

    Compiler.prototype.compileSilentScript = function(node, indLevel) {
      var indent, isComment, isMidBlockKeyword;
      if (/# EMPTY_LINE/.test(node.data.text)) {
        return this.buffer += '\n';
      } else {
        isComment = /^ #/.test(node.data.text);
        if (isComment) {
          this.buffer += '\n';
        }
        isMidBlockKeyword = (node.data.keyword != null) && MID_BLOCK_KEYWORDS.indexOf(node.data.keyword) !== -1;
        indent = isMidBlockKeyword ? this.getIndent(indLevel - 1) : this.getIndent(indLevel);
        return this.buffer += indent + '-' + node.data.text + LINE_BREAK;
      }
    };

    Compiler.prototype.compileHamlComment = function(node, indLevel) {};

    Compiler.prototype.compileTag = function(node, indLevel) {
      var attrsHashes, isMainTag, key, tag, value, _ref;
      if (node.data.name === 'div') {
        tag = _.size(node.data.attributes) === 0 ? 'div' : '';
      } else {
        tag = "" + node.data.name;
      }
      _ref = node.data.attributes;
      for (key in _ref) {
        value = _ref[key];
        if (key === 'class') {
          tag += '.' + value.split(' ').join('.');
        } else if (key === 'id') {
          tag += '#' + value;
        }
      }
      isMainTag = MAIN_TAGS.indexOf(node.data.name) !== -1;
      if (isMainTag) {
        this.buffer += LINE_BREAK;
      }
      this.buffer += this.getIndent(indLevel) + tag;
      attrsHashes = this.compileAttrsHashes(node.data.attributes_hashes);
      if (attrsHashes.length > 0) {
        this.buffer += ' ' + attrsHashes.join(' ');
      }
      if (node.data.parse) {
        value = node.data.value.replace(/\s+(?=\s)/g, '').replace('( ', '(').replace(' )', ')');
        return this.buffer += ' =' + value + LINE_BREAK;
      } else if (node.data.value) {
        return this.buffer += LINE_BREAK + this.getIndent(indLevel) + INDENTATION + '| ' + node.data.value + LINE_BREAK;
      } else {
        return this.buffer += LINE_BREAK;
      }
    };

    Compiler.prototype.compileComment = function(node, indLevel) {
      this.buffer += this.getIndent(indLevel) + '/!';
      if (node.data.text) {
        this.buffer += " " + node.data.text;
      }
      return this.buffer += LINE_BREAK;
    };

    Compiler.prototype.compileDoctype = function(node, indLevel) {
      var doctype;
      doctype = node.data.version === '5' ? 'doctype html' : node.data.version === '1.1' ? 'doctype 1.1' : node.data.type === 'strict' ? 'doctype strict' : node.data.type === 'frameset' ? 'doctype frameset' : node.data.type === 'mobile' ? 'doctype mobile' : node.data.type === 'basic' ? 'doctype basic' : 'doctype transitional';
      return this.buffer += this.getIndent(indLevel) + doctype + LINE_BREAK;
    };

    Compiler.prototype.compileFilter = function(node, indLevel) {
      var filterStringFormatted, strings;
      filterStringFormatted = '';
      strings = _.compact(node.data.text.split('\n'));
      strings = _.map(strings, (function(_this) {
        return function(string) {
          return _this.getIndent(indLevel) + INDENTATION + string;
        };
      })(this));
      this.buffer += this.getIndent(indLevel) + (":" + node.data.name) + LINE_BREAK;
      return this.buffer += strings.join(LINE_BREAK) + LINE_BREAK + LINE_BREAK;
    };

    Compiler.prototype.compileSpec = function(node, indLevel) {
      return this.buffer += this.getIndent(indLevel) + node.data.text + LINE_BREAK;
    };

    Compiler.prototype.getIndent = function(indLevel) {
      if (indLevel) {
        return Array(indLevel + 1).join(INDENTATION);
      } else {
        return '';
      }
    };

    Compiler.prototype.compileAttrsHashes = function(hashes) {
      if (hashes == null) {
        hashes = [];
      }
      hashes = _.map(hashes, function(attributesHash) {
        var attributes, firstLevelKeys, hasComma, key, matcher, regExp, _i, _len;
        attributesHash = attributesHash.replace(/\n/g, ' ');
        attributes = attributesHash.replace(/'/g, '"').replace(/(\w+):/g, "\"$1\":");
        attributes = JSON.parse("{" + attributes + "}");
        firstLevelKeys = _.keys(attributes);
        for (_i = 0, _len = firstLevelKeys.length; _i < _len; _i++) {
          key = firstLevelKeys[_i];
          regExp = new RegExp("(, )*" + key + ": ");
          matcher = attributesHash.match(regExp);
          hasComma = matcher[1] != null;
          attributesHash = hasComma ? attributesHash.replace(", " + key + ": ", " " + key + "=") : attributesHash.replace("" + key + ": ", "" + key + "=");
        }
        return attributesHash;
      });
      return hashes;
    };

    return Compiler;

  })();

  module.exports = Compiler;

}).call(this);
