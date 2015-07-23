if ( !window.webkit ) {
  window.webkit = {
    messageHandlers: {},
    callbackHandlers: {}
  };
}

window.webkit.callbackHandlers = {
  callbacks: [],
  register: function ( fn, caller ) {
    var index = this.callbacks.push( {
      fn: fn,
      caller: caller
    } );

    return index;
  },
  invoke: function ( callbackId, args ) {
    var callback = this.callbacks[ callbackId ];
    callback.fn.apply( callback.caller, args );

    this.callbacks.splice( callbackId, 1 );
  }
};

window.webkit.messageHandlers.hub.talk = function ( callback, receiver, action, args ) {
  if ( callback === undefined || receiver === undefined || action === undefined || args === undefined ) {
    throw new Error( 'arguments invalid, need 4 arguments, received ' + arguments.length );
  }

  var callbackId = null;
  if ( callback ) {
    callbackId = window.webkit.callbackHandlers.register( callback, arguments.callee.caller );
  }

  window.webkit.messageHandlers.hub.postMessage( {
    callbackId: callbackId,
    receiver: receiver,
    action: action,
    arguments: args
  } );
}
