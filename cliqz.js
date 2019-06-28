import 'react-native/Libraries/Core/InitializeCore';
import './setup';
import 'process-nextick-args';
import React from 'react';
import { AppRegistry, StyleSheet, View, AsyncStorage } from 'react-native';
import { startup, components } from 'browser-core-cliqz-ios';

async function cleanUpStorage() {
  const migrateKey = '@migrated';
  const migrateVersion = '1';
  const migrated = await AsyncStorage.getItem(migrateKey);
  if (migrated !== migrateVersion) {
    console.log('Migrate legacy storage');
    const keys = await AsyncStorage.getAllKeys();
    // prune legacy fs and anti-tracking storage namespaces
    const pruneKeys = keys.filter(k => k.startsWith('@fs:') || k.startsWith('@cliqzstorage'));
    await AsyncStorage.multiRemove(pruneKeys);
    await AsyncStorage.setItem(migrateKey, migrateVersion);
  } 
}

// set app global for debugging
const appStart = startup.then((app) => {
  global.app = app;
  cleanUpStorage();
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