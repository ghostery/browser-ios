/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

(function(){
  var messageHandler = window.webkit.messageHandlers.cliqzTrackingProtection;
  var win = window;
  while (win != win.parent) win = win.parent;
  var pageUrl = win.location.href;
 // -------------------------------------------------
 // Send ajax requests URLs to the host application
 // -------------------------------------------------
  var xhrProto = XMLHttpRequest.prototype,
  originalOpen = xhrProto.open,
  originalSend = xhrProto.send;

  xhrProto.open = function(method, url) {
      this._url = url;
      return originalOpen.apply(this, arguments);
  };

  xhrProto.send = function(body) {
      messageHandler.postMessage({ url: this._url, location: pageUrl })
      return originalSend.apply(this, arguments)
  };

 // -------------------------------------------------
 // Detect when new sources get set on Image and send them to the host application
 // -------------------------------------------------
  var originalImageSrc = Object.getOwnPropertyDescriptor(Image.prototype, 'src');
  delete Image.prototype.src;
  Object.defineProperty(Image.prototype, 'src', {
    get: function() {
      return originalImageSrc.get.call(this);
    },
    set: function(value) {
      messageHandler.postMessage({ url: value, location: pageUrl })
      originalImageSrc.set.call(this, value);
    }
  });

 // -------------------------------------------------
 // Listen to when new <script> elements get added to the dom
 // and send the source to the host application
 // -------------------------------------------------
  var observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      mutation.addedNodes.forEach(function(node) {
        if (node.tagName === 'SCRIPT' || node.tagName === 'IFRAME' || node.tagName === 'LINK') {
            messageHandler.postMessage({ url: node.src, location: pageUrl });
        }
      });
    });
  });

  observer.observe(document.documentElement, {
    childList: true,
    subtree: true
  });
})();
