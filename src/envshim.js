if (typeof window == 'undefined') {
  global = this;
  console = {};
  ['error', 'log', 'info', 'warn'].forEach(function (fn) {
    if (!(fn in console)) {
      console[fn] = function () {};
    }
  });
} else {
  global = window;
}
