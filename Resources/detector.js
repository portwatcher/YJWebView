window.addEventListener('hashchange', function () {
  window.cloudbox.talk(null, 'Detector', 'hashChange', [location.hash]);
}, false);
