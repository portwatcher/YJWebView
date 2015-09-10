(function () {
  if (window.cloudbox.reset) {
    return;
  }

  document.body.style.webkitTouchCallout='none';
  document.body.style.webkitUserSelect='none';
  document.documentElement.style.webkitUserSelect='none';
  document.documentElement.style.webkitTouchCallout='none';

  var elements = document.querySelectorAll('h1, h2, h3, h4, h5, span, p');
  for (var i = 0; i < elements.length; i++) {
    var element = elements[i];
    element.style.webkitUserSelect = 'text';
  }


  new MutationObserver(function (mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.addedNodes.length) {
        for (var i = 0; i < mutation.addedNodes.length; i++) {
          var node = mutation.addedNodes[i];
          if (node && 'querySelectorAll' in node) {
            var addedText = node.querySelectorAll('h1, h2, h3, h4, h5, span, p');

            if (addedText.length) {
              for (var j = 0; j < addedText.length; j++) {
                if (addedText.item(j)) {
                  addedText.item(j).style.webkitUserSelect = 'text';
                }
              }
            }
          } else {
            continue;
          }
        }
      }
    });
  }).observe(document.body, {
    childList: true,
    subtree: true
  });

  window.cloudbox.reset = true;
})();
