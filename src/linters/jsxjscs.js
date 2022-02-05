var reactTools = require('react-tools');
var jscs = require('jscs');

module.exports = (function() {
  return function(code, config) {
    var errors;
    var transformedCode = reactTools.transform(code);
    var checker = new jscs();

    checker.registerDefaultRules();
    checker.configure(config);

    errors = checker.checkString(transformedCode);
    return errors._errorList.map(function(error) {
      return {
        line: error.line,
        message: '```\n' + errors.explainError(error) + '```\n'
      };
    });
  };
}());
