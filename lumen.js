import 'process-nextick-args';
import 'react-native/Libraries/Core/InitializeCore';
import setup from './setup';
import React from 'react';
import { AppRegistry } from 'react-native';
import { startup } from 'browser-core-lumen-ios';

// set app global for debugging
startup.then((app) => {
  global.app = app;
});

AppRegistry.registerComponent('ExtensionApp', () => () => null);
