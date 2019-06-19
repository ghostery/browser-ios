import 'react-native/Libraries/Core/InitializeCore';
import './setup';
import 'process-nextick-args';
import React from 'react';
import { AppRegistry, StyleSheet, View } from 'react-native';
import { startup, components } from 'browser-core-cliqz-ios';

// set app global for debugging
const appStart = startup.then((app) => {
  global.app = app;
});

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: 'transparent'
  },
});

// wrapper for a component to add top padding on iOS
function AppContainer(App, appStart) {
  return () => (
    <View style={styles.container}>
      <App appStart={appStart} />
    </View>
  );
}

// register components from config
Object.keys(components).forEach((component) => {
  AppRegistry.registerComponent(component, () => AppContainer(components[component], appStart));
});