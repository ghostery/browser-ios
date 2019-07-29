import 'react-native/Libraries/Core/InitializeCore';
import './setup';
import 'process-nextick-args';
import React from 'react';
import { AppRegistry, StyleSheet, View, NativeModules, NativeEventEmitter } from 'react-native';
import { startup } from 'browser-core-cliqz-ios';
import Cliqz from './cliqzWrapper';
import { setDefaultSearchEngine } from 'browser-core-cliqz-ios/build/modules/core/search-engines';
import { addConnectionChangeListener, removeConnectionChangeListener } from 'browser-core-cliqz-ios/build/modules/platform/network';
import prefs from 'browser-core-cliqz-ios/build/modules/core/prefs';
import events from 'browser-core-cliqz-ios/build/modules/core/events';
import SearchUI from 'browser-core-cliqz-ios/build/modules/mobile-cards/SearchUI';
import { Provider as CliqzProvider } from 'browser-core-cliqz-ios/build/modules/mobile-cards/cliqz';
import inject from 'browser-core-cliqz-ios/build/modules/core/kord/inject';

const nativeBridge = NativeModules.JSBridge;

// set app global for debugging
// TODO chrmod: get rid of startup
const appStart = startup.then((app) => {
  global.app = app;
  return app;
});

const styles = StyleSheet.create({
  container: {
    flex: 1,
    flexDirection: 'column',
    backgroundColor: 'transparent'
  },
  footer: {
    height: 20,
    backgroundColor: '#656d7e',
    alignItems: 'center',
    justifyContent: 'center',
    borderBottomLeftRadius: 5,
    borderBottomRightRadius: 5
  },
  searchEnginesContainer: {
    flexDirection: 'row',
    justifyContent: 'space-evenly',
    marginTop: 20,
    marginBottom: 100,
  },
  searchEngineIcon: {
    height: 73,
    width: 73,
    borderRadius: 10,
    overflow: 'hidden',
  },
});

class MobileCards extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      results: {
        results: [],
        meta: {}
      },
      theme: 'light'
    }

    this.cliqz = new Cliqz(inject);
    this.isDeveloper = prefs.get('developer', false);
    this.appStart = appStart || Promise.resolve();

    events.sub('search:results', this.updateResults);
    events.sub('mobile-browser:notify-preferences', this.updatePreferences);
    events.sub('mobile-browser:set-search-engine', this.setSearchEngine);
    addConnectionChangeListener();
    this.eventEmitter = new NativeEventEmitter(nativeBridge);
    this.eventEmitter.addListener('action', this.onAction);
  }

  componentWillUnmount() {
    events.un_sub('mobile-browser:notify-preferences', this.updatePreferences);
    events.un_sub('mobile-browser:set-search-engine', this.setSearchEngine);
    events.un_sub('search:results', this.updateResults);
    removeConnectionChangeListener();
    this.eventEmitter.removeAllListeners();
  }

  onAction = async ({ action, args, id }) => {
    const [module, name] = action.split(':');
    const response = await inject.module(module).action(name, ...args);
    if (typeof id !== 'undefined') {
      nativeBridge.replyToAction(id, { result: response });
    }
  }

  setSearchEngine = (engine) => {
    setDefaultSearchEngine(engine);
  }

  updatePreferences = (_prefs) => {
    // clear cache with every visit to tab overiew and settings
    this.appStart.then(() => {
      Object.keys(_prefs).forEach((key) => {
        prefs.set(key, _prefs[key]);
      });
    });
  }

  updateResults = results => this.setState({ results, onboarding: false });

  render() {
    const { results, suggestions, meta, query } = this.state.results;
    NativeModules.QuerySuggestion.showQuerySuggestions(query, suggestions);
    return (
      <View style={styles.container}>
        <CliqzProvider value={this.cliqz}>
          <SearchUI
            results={results}
            meta={meta}
            theme={this.state.theme}
          />
        </CliqzProvider>
      </View>
    );
  }
}


AppRegistry.registerComponent('ExtensionApp', () => MobileCards);
