(function() {
  var Compiler, HAML_EXTENSION_REGEXP, Parser, Q, Slimmy, fs, walk, _;

  Q = require('q');

  _ = require('underscore');

  fs = require('fs');

  walk = require('walk');

  Parser = require('./parser');

  Compiler = require('./compiler');

  HAML_EXTENSION_REGEXP = /\.haml$/;

  Slimmy = (function() {
    function _Class() {}

    _Class.prototype.Parser = Parser;

    _Class.prototype.Compiler = Compiler;

    _Class.prototype.convert = function(filePath, writeToFile) {
      if (writeToFile == null) {
        writeToFile = false;
      }
      filePath = this.getAbsolutePath(filePath);
      return this.parser().parseFile(filePath).then((function(_this) {
        return function(rootNode) {
          var compiler;
          compiler = new _this.Compiler(rootNode);
          compiler.compile();
          _this._compilationResults = compiler.buffer;
          if (writeToFile) {
            return _this.writeToSlimFile(filePath, compiler.buffer);
          }
        };
      })(this));
    };

    _Class.prototype.convertDir = function(dirPath, writeToFile) {
      var files, walker;
      if (writeToFile == null) {
        writeToFile = false;
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
      return Q.all(_.map(files, (function(_this) {
        return function(file) {
          console.log("Converting file:\n" + file);
          return _this.convert(file, writeToFile);
        };
      })(this)));
    };

    _Class.prototype.writeToSlimFile = function(filePath, slimCode) {
      var fd, slimFilePath;
      slimFilePath = filePath.replace(HAML_EXTENSION_REGEXP, '.slim');
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

    _Class.prototype.parser = function() {
      return this._parser != null ? this._parser : this._parser = new this.Parser();
    };

    return _Class;

  })();

  module.exports = Slimmy;

}).call(this);
