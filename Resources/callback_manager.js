if ( !window.cloudbox ) {
  window.cloudbox = {
    callbackHandlers: {}
  };
}

window.cloudbox.callbackHandlers = {
  callbacks: [],
  register: function ( fn, caller ) {
    var index = this.callbacks.push( {
      fn: fn,
      caller: caller
    } );

    return index - 1;
  },
  invoke: function ( callbackId, args ) {
    var callback = this.callbacks[ callbackId ];

    if ( callback && callback.fn ) {
      callback.fn.apply( callback.caller, args );
    }

    this.callbacks.splice( callbackId, 1 );
  }
};

window.cloudbox.talk = function ( callback, receiver, action, args ) {
  if ( callback === undefined || receiver === undefined || action === undefined || args === undefined ) {
    throw new Error( 'arguments invalid, need 4 arguments, received ' + arguments.length );
  }

  var callbackId = null;
  if ( callback ) {
    callbackId = window.cloudbox.callbackHandlers.register( callback, arguments.callee.caller );
  }

  window.webkit.messageHandlers.hub.postMessage( {
    callbackId: callbackId,
    receiver: receiver,
    action: action,
    arguments: args
  } );
}

window.cloudbox.getHTMLElementsAtPoint = function (x, y) {
  var tags = ",";
    var e = document.elementFromPoint(x, y);

    while (e) {
      if (e.tagName) {
        tags += e.tagName + ',';
      }
      e = e.parentNode;
    }

    return tags;
}

window.cloudbox.getLinkHrefAtPoint = function (x, y) {
  var tags = "";
    var e = document.elementFromPoint(x, y);

    while (e) {
      if (e.src) {
        tags += e.src;
        break;
      }
      e = e.parentNode;
    }

    return tags;
};

window.cloudbox.getLinkSrcAtPoint = function (x, y) {
  var tags = "";
    var e = document.elementFromPoint(x, y);

    while (e) {
      if (e.href) {
        tags += e.href;
        break;
      }
      e = e.parentNode;
    }

    return tags;
};
