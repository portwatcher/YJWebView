var echo = {
  say: function ( word ) {
    window.webkit.messageHandlers.hub.talk( null, "Echo", "say", [ word ] );
  }
};

echo.say.toString = function () {
  return '[not native function]'
};
