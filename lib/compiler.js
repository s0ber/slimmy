(function() {
  var Compiler, INDENTATION, IND_LEVEL, LINE_BREAK, MID_BLOCK_KEYWORDS, config, _;

  try {
    config = require('./config');
  } catch (_error) {
    config = require('./config.example');
  }

  _ = require('underscore');

  INDENTATION = "  ";

  IND_LEVEL = 0;

  LINE_BREAK = '\n';

  MID_BLOCK_KEYWORDS = 'else elsif rescue ensure end when'.split(' ');

  Compiler = (function() {
    function Compiler(rootNode, fileCompilationMode) {
      this.fileCompilationMode = fileCompilationMode != null ? fileCompilationMode : true;
      this.root = rootNode;
      this.buffer = '';
      this._currentLine = 1;
      this.warnings = [];
    }

    Compiler.prototype.compile = function() {
      this.compileNode(this.root, IND_LEVEL);
      return this.compileChildrenNodes(this.root, IND_LEVEL);
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
      var compilationMethod, warning;
      if (this.fileCompilationMode && this.currentLine() !== 1) {
        if (this._shouldPrependWithEmptyLine(node)) {
          this.addNewLine();
        }
      }
      warning = typeof node.checkForWarnings === "function" ? node.checkForWarnings() : void 0;
      if (warning != null) {
        warning.startLine = this.currentLine();
        this.warnings.push(warning);
      }
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
      var firstChar, nextNode, plainTextPrefix;
      firstChar = node.data.text[0];
      nextNode = typeof node.nextNode === "function" ? node.nextNode() : void 0;
      plainTextPrefix = (nextNode != null ? nextNode.isInline() : void 0) ? "' " : '| ';
      this.buffer += this.getIndent(indLevel) + plainTextPrefix + node.data.text;
      return this.addNewLine();
    };

    Compiler.prototype.compileScript = function(node, indLevel) {
      var isInterpolatedString, nextNode, scriptLen, scriptPrefix;
      scriptLen = node.data.text.length;
      isInterpolatedString = node.data.text[0] === '"' && node.data.text[scriptLen - 1] === '"';
      if (isInterpolatedString) {
        this.buffer += this.getIndent(indLevel) + node.data.text.substr(1, scriptLen - 2);
      } else {
        nextNode = typeof node.nextNode === "function" ? node.nextNode() : void 0;
        scriptPrefix = (typeof node.isInlineLink === "function" ? node.isInlineLink() : void 0) && (nextNode != null ? nextNode.isInline() : void 0) ? "=>" : '=';
        this.buffer += this.getIndent(indLevel) + scriptPrefix + node.data.text;
      }
      return this.addNewLine();
    };

    Compiler.prototype.compileSilentScript = function(node, indLevel) {
      var indent, isMidBlockKeyword;
      isMidBlockKeyword = (node.data.keyword != null) && MID_BLOCK_KEYWORDS.indexOf(node.data.keyword) !== -1;
      indent = isMidBlockKeyword ? this.getIndent(indLevel - 1) : this.getIndent(indLevel);
      this.buffer += indent + '-' + node.data.text;
      return this.addNewLine();
    };

    Compiler.prototype.compileHamlComment = function(node, indLevel) {};

    Compiler.prototype.compileTag = function(node, indLevel) {
      var attrsHashes, key, nextNode, tag, value, _ref;
      if (node.data.name === 'div') {
        tag = _.size(node.data.attributes) === 0 ? 'div' : '';
      } else {
        tag = "" + node.data.name;
        nextNode = typeof node.nextNode === "function" ? node.nextNode() : void 0;
        if ((typeof node.isInline === "function" ? node.isInline() : void 0) && (nextNode != null ? nextNode.isInline() : void 0)) {
          tag += '>';
        }
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
      this.buffer += this.getIndent(indLevel) + tag;
      attrsHashes = this.compileAttrsHashes(node.data.attributes_hashes);
      if (attrsHashes.length > 0) {
        this.buffer += ' ' + attrsHashes.join(' ');
      }
      if (node.data.parse) {
        value = node.data.value.replace(/\s+(?=\s)/g, '').replace('( ', '(').replace(' )', ')');
        this.buffer += ' =' + value;
      } else if (node.data.value) {
        this.addNewLine();
        this.buffer += this.getIndent(indLevel) + INDENTATION + '| ' + node.data.value;
      }
      return this.addNewLine();
    };

    Compiler.prototype.compileComment = function(node, indLevel) {
      this.buffer += this.getIndent(indLevel) + '/!';
      if (node.data.text) {
        this.buffer += " " + node.data.text;
      }
      return this.addNewLine();
    };

    Compiler.prototype.compileDoctype = function(node, indLevel) {
      var doctype;
      doctype = node.data.version === '5' ? 'doctype html' : node.data.version === '1.1' ? 'doctype 1.1' : node.data.type === 'strict' ? 'doctype strict' : node.data.type === 'frameset' ? 'doctype frameset' : node.data.type === 'mobile' ? 'doctype mobile' : node.data.type === 'basic' ? 'doctype basic' : 'doctype transitional';
      this.buffer += this.getIndent(indLevel) + doctype;
      return this.addNewLine();
    };

    Compiler.prototype.compileFilter = function(node, indLevel) {
      var filterStringFormatted, str, strings, _i, _len;
      filterStringFormatted = '';
      strings = _.compact(node.data.text.split(LINE_BREAK));
      strings = _.map(strings, (function(_this) {
        return function(string) {
          return _this.getIndent(indLevel) + INDENTATION + string;
        };
      })(this));
      this.buffer += this.getIndent(indLevel) + (":" + node.data.name);
      this.addNewLine();
      for (_i = 0, _len = strings.length; _i < _len; _i++) {
        str = strings[_i];
        this.buffer += str;
        this.addNewLine();
      }
      return this.addNewLine();
    };

    Compiler.prototype.compileSpec = function(node, indLevel) {
      this.buffer += this.getIndent(indLevel) + node.data.text;
      return this.addNewLine();
    };

    Compiler.prototype.getIndent = function(indLevel) {
      if (indLevel) {
        return Array(indLevel + 1).join(INDENTATION);
      } else {
        return '';
      }
    };

    Compiler.prototype.currentLine = function() {
      return this._currentLine;
    };

    Compiler.prototype.addNewLine = function() {
      this.buffer += LINE_BREAK;
      return this._currentLine++;
    };

    Compiler.prototype.compileAttrsHashes = function(hashes) {
      if (hashes == null) {
        hashes = [];
      }
      hashes = _.map(hashes, function(attrsHash) {
        var char, i, insideBrackets, newAttrsHash, nextChar, skipChar, _i, _ref;
        attrsHash = attrsHash.replace(/\n/g, ' ');
        newAttrsHash = '';
        insideBrackets = false;
        skipChar = false;
        for (i = _i = 0, _ref = attrsHash.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
          if (skipChar) {
            skipChar = false;
            continue;
          }
          char = attrsHash[i];
          nextChar = attrsHash[i + 1];
          if (!insideBrackets && '[{("\''.indexOf(char) !== -1) {
            insideBrackets = true;
          } else if (insideBrackets && ']})"\''.indexOf(char) !== -1) {
            insideBrackets = false;
          }
          if (!insideBrackets) {
            if (("" + char + nextChar) === ': ') {
              newAttrsHash += '=';
              skipChar = true;
              continue;
            } else if (("" + char + nextChar) === ', ') {
              newAttrsHash += ' ';
              skipChar = true;
              continue;
            }
          }
          newAttrsHash += char;
        }
        return newAttrsHash;
      });
      return hashes;
    };

    Compiler.prototype._shouldPrependWithEmptyLine = function(node) {
      if (!this.fileCompilationMode || (config == null)) {
        return;
      }
      return config.shouldPrependWithEmptyLine(node);
    };

    return Compiler;

  })();

  module.exports = Compiler;

}).call(this);
