var reactTools = require('react-tools');
var jsHint = require('jshint');

module.exports = (function() {
  var _ = require('underscore');

  var globals;

  return function(code, config) {
    var transformedCode;

    if (config.globals) {
      globals = config.globals;
      delete config.globals;
    }

    transformedCode = reactTools.transform(code);
    jsHint.JSHINT(transformedCode, config, globals);
    return _(jsHint.JSHINT.data().errors).compact().map(function lintToError(lint) {
      return { line: lint.line, message: lint.reason };
    });
  };
}());
