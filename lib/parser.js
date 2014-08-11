(function() {
  var AstNode, Parser, Q;

  Q = require('q');

  AstNode = require('./ast_node');

  Parser = (function() {
    function Parser() {}

    Parser.prototype.AstNode = AstNode;

    Parser.prototype.parseFile = function(filePath) {
      return this._execHamlParsing(filePath).then((function(_this) {
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
        node.children.push(childNode);
        _results.push(this.setChildrenForAstNode(childNode, childData.children));
      }
      return _results;
    };

    Parser.prototype.convertDataToAstNode = function(data) {
      return new this.AstNode(data);
    };

    Parser.prototype._execHamlParsing = function(filePath) {
      var child, dfd, exec;
      dfd = Q.defer();
      exec = require('child_process').exec;
      child = exec(this._hamlParseCmd(filePath), (function(_this) {
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

    Parser.prototype._hamlParseCmd = function(filePath) {
      var converterPath, isAbsolutePath;
      converterPath = "" + __dirname + "/../bin/haml_json_converter.rb";
      isAbsolutePath = filePath[0] === '/' || filePath[0] === '~';
      if (!isAbsolutePath) {
        filePath = "" + __dirname + "/../" + filePath;
      }
      return "ruby " + converterPath + " " + filePath;
    };

    return Parser;

  })();

  module.exports = Parser;

}).call(this);
