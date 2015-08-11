navigator.vibrate = function ( parameter ) {
  if ( parameter === undefined ) {
    return window.cloudbox.talk( null, 'Vibration', 'vibrate', [] );
  }

  if ( typeof parameter === 'number' ) {
    if ( parameter === 0 ) {
      //TODO: stop the vibration
    } else if ( parameter > 0 ) {
      window.cloudbox.talk( null, 'Vibration', 'vibrate', [ parameter ] );
    } else {
      throw new Error( 'invalid parameter' );
    }
  } else if ( parameter instanceof Array ) {
    for ( var i = 0; i < parameter.length; i++ ) {
      var time = parameter[ i ];
      if ( i === 0 ) {
        window.cloudbox.talk( null, 'Vibration', 'vibrate', [ time ] );
      } else if ( i % 2 === 1 ) { // even number
        if ( parameter[ i + 1 ] ) {
          var totalTime = 0;
          for ( var j = 0; j <= i; j++ ) {
            totalTime += parameter[ j ];
          }
          setTimeout( function () {
            window.cloudbox.talk( null, 'Vibration', 'vibrate', [ parameter[ i + 1 ] ] );
          }, totalTime );
        }
      }
    }
  } else {
    throw new Error( 'invalid parameter' );
  }
};
