screen.lockOrientation = function (orientation) {
  var handleOrientation = function (orientation) {
    if (orientation === 'landscape') {
      screen.orientation = 'landscape-primary';
      window.cloudbox.talk(null, 'ScreenOrientation', 'rotateToLandscape', []);
      return true;
    } else if (orientation === 'portrait') {
      screen.orientation = 'portrait-primary';
      window.cloudbox.talk(null, 'ScreenOrientation', 'rotateToPortrait', []);
      return true;
    } else if (orientation === 'portrait-primary') {
      screen.orientation = 'portrait-primary';
      window.cloudbox.talk(null, 'ScreenOrientation', 'rotateToPortrait', []);
      return true;
    } else if (orientation === 'portrait-secondary') {
      return false;
    } else if (orientation === 'landscape-primary') {
      screen.orientation = 'landscape-primary';
      window.cloudbox.talk(null, 'ScreenOrientation', 'rotateToLandscape', []);
      return true;
    } else if (orientation === 'landscape-secondary') {
      return false;
    } else if (orientation === 'default') {
      screen.orientation = 'portrait-primary';
      return true;
    }
  };

  if (Object.prototype.toString.call(orientation) === '[object Array]') {
    var oris = orientation;
    for (var i = 0, len = oris.length; i < len; i++) {
      handleOrientation(oris[i]);
    }
  }

  return handleOrientation(orientation);
};

screen.unlockOrientation = function () {
  window.cloudbox.talk(null, 'ScreenOrientation', 'unlockOrientation', []);
  return true;
};
