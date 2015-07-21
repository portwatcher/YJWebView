if ( !window.webkit ) {
  window.webkit = {
    messageHandlers: {},
    callbackHandlers: {}
  };
}

window.webkit.callbackHandlers = {
  callbacks: []
  register: function ( fn, caller ) {
    var index = callbacks.push( {
      fn: fn,
      caller: caller
    } );

    return index;
  },
  invoke: function ( callbackId, args ) {
    var callback = callbacks[ callbackId ];
    callback.fn.apply( callback.caller, args );

    callbacks.shift();
  }
};
