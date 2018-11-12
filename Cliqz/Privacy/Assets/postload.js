/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

var win = window;
while (win != win.parent) win = win.parent;
var pageUrl = win.location.href;
var tabID = REPLACE_WITH_TAB_ID;

var messageHandler = window.webkit.messageHandlers.cliqzTrackingProtectionPostLoad;
var sendMessage = function(url) { messageHandler.postMessage({ url: url, location: pageUrl, tabIdentifier: tabID }) };

// Send back the sources of every script and image in the dom back to the host applicaiton
Array.prototype.map.call(document.scripts, function(t) { return t.src }).forEach(sendMessage)
Array.prototype.map.call(document.images, function(t) { return t.src }).forEach(sendMessage)
