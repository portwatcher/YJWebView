navigator.vibrate = function () {
  window.cloudbox.talk( null, "Vibration", "vibrate", [] );
  return true;
};
