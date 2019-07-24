import buffer from 'buffer';
import UserAgent from 'react-native-user-agent';
import { YellowBox } from 'react-native';

YellowBox.ignoreWarnings([
  'Warning: NetInfo', // TODO: use netinfo from community package
  'Module RNSqlite2 requires main queue', // TODO: update the lib
  'Module RNFSManager requires main queue', // TODO: update the lib
  'Module RNDeviceInfo requires main queue', // TODO: update the lib
  'RCTBridge required', // TODO: potentially https://github.com/facebook/react-native/issues/16376
]);

if (!global.Buffer) {
  global.Buffer = buffer.Buffer;
}

if (!process.version) {
  process.version = '';
}
const chrome = {
  cliqz: {
    initTheme() {},
    createUITourTarget() {},
    deleteUITourTarget() {},
    hideUITour() {},
    showUITour() {},
  },
  webRequest: {
    onHeadersReceived: {
      addListener() {},
    },
  },
  history: {
    onVisited: {
      addListener() {},
    },
  },
};
global.browser = global.chrome = chrome;

global.navigator.userAgent = navigator.userAgent || UserAgent.getUserAgent();
