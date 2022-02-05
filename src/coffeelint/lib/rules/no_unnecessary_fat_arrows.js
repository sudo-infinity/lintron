// Generated by CoffeeScript 1.7.1
(function() {
  var NoUnnecessaryFatArrows, any,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  any = function(arr, test) {
    return arr.reduce((function(res, elt) {
      return res || test(elt);
    }), false);
  };

  module.exports = NoUnnecessaryFatArrows = (function() {
    function NoUnnecessaryFatArrows() {
      this.needsFatArrow = __bind(this.needsFatArrow, this);
      this.isThis = __bind(this.isThis, this);
    }

    NoUnnecessaryFatArrows.prototype.rule = {
      name: 'no_unnecessary_fat_arrows',
      level: 'warn',
      message: 'Unnecessary fat arrow',
      description: "Disallows defining functions with fat arrows when `this`\nis not used within the function."
    };

    NoUnnecessaryFatArrows.prototype.lintAST = function(node, astApi) {
      this.astApi = astApi;
      this.lintNode(node);
      return void 0;
    };

    NoUnnecessaryFatArrows.prototype.lintNode = function(node) {
      var error;
      if ((this.isFatArrowCode(node)) && (!this.needsFatArrow(node))) {
        error = this.astApi.createError({
          lineNumber: node.locationData.first_line + 1
        });
        this.errors.push(error);
      }
      return node.eachChild((function(_this) {
        return function(child) {
          return _this.lintNode(child);
        };
      })(this));
    };

    NoUnnecessaryFatArrows.prototype.isCode = function(node) {
      return this.astApi.getNodeName(node) === 'Code';
    };

    NoUnnecessaryFatArrows.prototype.isFatArrowCode = function(node) {
      return this.isCode(node) && node.bound;
    };

    NoUnnecessaryFatArrows.prototype.isValue = function(node) {
      return this.astApi.getNodeName(node) === 'Value';
    };

    NoUnnecessaryFatArrows.prototype.isThis = function(node) {
      return this.isValue(node) && node.base.value === 'this';
    };

    NoUnnecessaryFatArrows.prototype.needsFatArrow = function(node) {
      return this.isCode(node) && (any(node.params, (function(_this) {
        return function(param) {
          return param.contains(_this.isThis) != null;
        };
      })(this)) || (node.body.contains(this.isThis) != null) || (node.body.contains((function(_this) {
        return function(child) {
          if (!_this.astApi.getNodeName(child)) {
            return (child.isSuper != null) && child.isSuper;
          } else {
            return _this.isFatArrowCode(child) && _this.needsFatArrow(child);
          }
        };
      })(this)) != null));
    };

    return NoUnnecessaryFatArrows;

  })();

}).call(this);
