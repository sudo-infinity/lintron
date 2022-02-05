var cjsxTransform = require('coffee-react-transform');
var coffeeLint = require('../coffeelint/lib/coffeelint');

module.exports = function(code, config) {
  var transformedCode = cjsxTransform(code);
  var lints = coffeeLint.lint(transformedCode, config, false);
  return lints.map(function(lint) {
    return {line: lint.lineNumber, message: lint.message};
  });
};
