import 'react-native/Libraries/Core/InitializeCore';
import './setup';
import 'process-nextick-args';
import { AppRegistry } from 'react-native';
import { startup } from 'browser-core-lumen-ios';

// set app global for debugging
startup.then((app) => {
  global.app = app;
});

AppRegistry.registerComponent('ExtensionApp', () => () => null);
