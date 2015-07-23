var echo = {
  say: function ( word ) {
    window.cloudbox.talk( null, "Echo", "say", [ word ] );
  }
};

echo.say.toString = function () {
  return '[not native code]'
};
