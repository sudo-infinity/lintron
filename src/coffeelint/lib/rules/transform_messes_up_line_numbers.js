// Generated by CoffeeScript 1.7.1
(function() {
  var CamelCaseClasses;

  module.exports = CamelCaseClasses = (function() {
    function CamelCaseClasses() {}

    CamelCaseClasses.prototype.rule = {
      name: 'transform_messes_up_line_numbers',
      level: 'warn',
      message: 'Transforming source messes up line numbers',
      description: "This rule detects when changes are made by transform function,\nand warns that line numbers are probably incorrect."
    };

    CamelCaseClasses.prototype.tokens = [];

    CamelCaseClasses.prototype.lintToken = function(token, tokenApi) {};

    return CamelCaseClasses;

  })();

}).call(this);