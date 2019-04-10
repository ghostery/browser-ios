import buffer from 'buffer';
import UserAgent from 'react-native-user-agent';

if (!global.Buffer) {
  global.Buffer = buffer.Buffer;
}

if (!process.version) {
  process.version = '';
}

global.navigator.userAgent = navigator.userAgent || UserAgent.getUserAgent();
