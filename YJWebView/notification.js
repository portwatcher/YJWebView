var Notification = function ( title, options ) {
  this.title = title;
  this.close = function () {
    window.cloudbox.talk( null, 'Notification', 'close', [] );
  };
  this.permission = 'default';
  if ( options ) {
    this.tag = options.tag;
    if ( options.icon.substring( 0, 4 ) !== 'http' ) {
      var link = document.createElement( 'a' );
      link.href = options.icon;
      options.icon = link.protocol + '//' + link.host + link.pathname + link.search + link.hash;
    }
    this.icon = options.icon;
    this.body = options.body;
  } else {
    options = {};
  }
  window.cloudbox.talk( null, 'Notification', 'show', [ title, options.body, options.icon ] );
};

Notification.requestPermission = function ( callback ) {
  window.cloudbox.talk( function ( status ) {
    Notification.permission = status;
    if ( callback ) {
      callback( status );
    }
  }, 'Notification', 'requestPermission', [] );
};
