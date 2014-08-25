(function() {
  var Compiler, HAML_EXTENSION_REGEXP, Parser, Q, Riline, Slimmy, fs, walk, _;

  Q = require('q');

  _ = require('underscore');

  fs = require('fs');

  walk = require('walk');

  Riline = require('riline');

  Parser = require('./parser');

  Compiler = require('./compiler');

  HAML_EXTENSION_REGEXP = /\.haml$/;

  Slimmy = (function() {
    function _Class() {}

    _Class.prototype.Parser = Parser;

    _Class.prototype.Compiler = Compiler;

    _Class.prototype.convertString = function(hamlCodeString, fileCompilationMode) {
      if (fileCompilationMode == null) {
        fileCompilationMode = false;
      }
      return this.parser().parseString(hamlCodeString).then((function(_this) {
        return function(rootNode) {
          var compiler;
          compiler = new _this.Compiler(rootNode, fileCompilationMode);
          compiler.compile();
          _this._showWarnings(compiler);
          return compiler;
        };
      })(this));
    };

    _Class.prototype.convertFile = function(filePath, writeToFile) {
      if (writeToFile == null) {
        writeToFile = true;
      }
      filePath = this.getAbsolutePath(filePath);
      return this.parser().parseFile(filePath).then((function(_this) {
        return function(rootNode) {
          var compiler;
          compiler = new _this.Compiler(rootNode);
          compiler.compile();
          if (writeToFile) {
            _this._showWarnings(compiler, filePath);
          } else {
            _this._showWarnings(compiler);
          }
          _this._compilationResults = compiler.buffer;
          if (writeToFile) {
            return _this.writeToSlimFile(filePath, compiler.buffer);
          }
        };
      })(this));
    };

    _Class.prototype.convertDir = function(dirPath, writeToFile, removeHamlFiles) {
      var files, walker;
      if (writeToFile == null) {
        writeToFile = true;
      }
      if (removeHamlFiles == null) {
        removeHamlFiles = false;
      }
      dirPath = this.getAbsolutePath(dirPath);
      files = [];
      walker = walk.walkSync(dirPath, {
        followLinks: false,
        listeners: {
          file: function(root, stat, next) {
            if (HAML_EXTENSION_REGEXP.test(stat.name)) {
              files.push("" + root + "/" + stat.name);
            }
            return next();
          }
        }
      });
      console.log("Converting files:");
      return Q.allSettled(_.map(files, (function(_this) {
        return function(filePath) {
          console.log(filePath);
          return _this.convertFile(filePath, writeToFile).then(function() {
            if (removeHamlFiles) {
              return _this.deleteHamlFile(filePath);
            }
          });
        };
      })(this)))["catch"](function(e) {
        return console.log(e);
      }).then(function() {
        return console.log('All files are converted.');
      });
    };

    _Class.prototype.writeToSlimFile = function(filePath, slimCode) {
      var fd, slimFilePath;
      slimFilePath = this.getSlimPath(filePath);
      fd = fs.openSync(slimFilePath, 'w');
      fs.writeFileSync(slimFilePath, slimCode);
      return fs.closeSync(fd);
    };

    _Class.prototype.getAbsolutePath = function(path) {
      var isAbsolutePath;
      isAbsolutePath = path[0] === '/' || path[0] === '~';
      if (isAbsolutePath) {
        return path;
      } else {
        return path = "" + __dirname + "/../" + path;
      }
    };

    _Class.prototype.getSlimPath = function(path) {
      return path.replace(HAML_EXTENSION_REGEXP, '.slim');
    };

    _Class.prototype.deleteHamlFile = function(filePath) {
      return fs.unlink(filePath);
    };

    _Class.prototype.parser = function() {
      return this._parser != null ? this._parser : this._parser = new this.Parser();
    };

    _Class.prototype._showWarnings = function(compiler, filePath) {
      var riline, text, warning, _i, _len, _ref;
      if (compiler.warnings == null) {
        return;
      }
      riline = new Riline(compiler.buffer);
      _ref = compiler.warnings;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        warning = _ref[_i];
        text = warning.text;
        if (filePath) {
          text += '\n' + this.getSlimPath(filePath);
        }
        riline.addMessage({
          text: text,
          startLine: warning.startLine,
          endLine: warning.endLine
        });
      }
      return riline.printMessages();
    };

    return _Class;

  })();

  module.exports = Slimmy;

}).call(this);
