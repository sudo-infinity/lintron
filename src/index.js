var Linters = {
  JSXJSHint: require('./linters/jsxjshint.js'),
  JSXCheckStyle: require('./linters/jsxjscs.js'),
  CoffeeLint: require('./linters/cjsx.js')
};

module.exports = global.Linters = Linters;
