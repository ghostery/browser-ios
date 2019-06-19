import buffer from 'buffer';
import UserAgent from 'react-native-user-agent';

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
