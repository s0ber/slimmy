(function() {
  var AstNode, Parser, Q;

  Q = require('q');

  AstNode = require('./ast_node');

  Parser = (function() {
    function Parser() {}

    Parser.prototype.AstNode = AstNode;

    Parser.prototype.parseFile = function(filePath) {
      return this._execHamlFileParsing(filePath).then((function(_this) {
        return function(data) {
          return _this.buildASTree(data);
        };
      })(this));
    };

    Parser.prototype.parseString = function(hamlString) {
      return this._execHamlStringParsing(hamlString).then((function(_this) {
        return function(data) {
          return _this.buildASTree(data);
        };
      })(this));
    };

    Parser.prototype.buildASTree = function(data) {
      var rootNode;
      rootNode = this.convertDataToAstNode(data);
      this.setChildrenForAstNode(rootNode, data.children);
      return rootNode;
    };

    Parser.prototype.setChildrenForAstNode = function(node, childrenData) {
      var childData, childNode, _i, _len, _results;
      if (childrenData == null) {
        childrenData = [];
      }
      if (node.children == null) {
        node.children = [];
      }
      _results = [];
      for (_i = 0, _len = childrenData.length; _i < _len; _i++) {
        childData = childrenData[_i];
        childNode = this.convertDataToAstNode(childData);
        this.setParentForAstNode(childNode, node);
        node.children.push(childNode);
        _results.push(this.setChildrenForAstNode(childNode, childData.children));
      }
      return _results;
    };

    Parser.prototype.setParentForAstNode = function(node, parentNode) {
      return node.setParent(parentNode);
    };

    Parser.prototype.convertDataToAstNode = function(data) {
      return new this.AstNode(data);
    };

    Parser.prototype._execHamlFileParsing = function(filePath) {
      var child, dfd, exec;
      dfd = Q.defer();
      exec = require('child_process').exec;
      child = exec(this._hamlParseFileCmd(filePath), (function(_this) {
        return function(error, output) {
          return dfd.resolve(JSON.parse(output));
        };
      })(this)).on('exit', function(code) {
        child.kill();
        if (code !== 0) {
          return console.log("Child process exited with exit code " + code);
        }
      });
      return dfd.promise;
    };

    Parser.prototype._hamlParseFileCmd = function(filePath) {
      var converterPath;
      converterPath = "" + __dirname + "/../bin/haml_file_json_converter.rb";
      return "ruby " + converterPath + " " + filePath;
    };

    Parser.prototype._execHamlStringParsing = function(hamlString) {
      var child, dfd, exec;
      dfd = Q.defer();
      exec = require('child_process').exec;
      child = exec(this._hamlParseStringCmd(hamlString), (function(_this) {
        return function(error, output) {
          return dfd.resolve(JSON.parse(output));
        };
      })(this)).on('exit', function(code) {
        child.kill();
        if (code !== 0) {
          return console.log("Child process exited with exit code " + code);
        }
      });
      return dfd.promise;
    };

    Parser.prototype._hamlParseStringCmd = function(hamlString) {
      var converterPath;
      converterPath = "" + __dirname + "/../bin/haml_string_json_converter.rb";
      return "ruby " + converterPath + " \"" + hamlString + "\"";
    };

    return Parser;

  })();

  module.exports = Parser;

}).call(this);
