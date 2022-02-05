var Linters = {
  JSXJSHint: require('./linters/jsxjshint.js'),
  JSXCheckStyle: require('./linters/jsxjscs.js')
};

module.exports = global.Linters = Linters;
