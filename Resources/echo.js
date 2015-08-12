var echo = {
  say: function ( word, callback ) {
    if ( callback ) {
      window.cloudbox.talk( callback, 'Echo', 'say', [ word ] );
    } else {
      window.cloudbox.talk( null, 'Echo', 'say', [ word ] );
    }
  }
};

echo.say.toString = function () {
  return '[not native code]';
};
