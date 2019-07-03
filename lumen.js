import 'react-native/Libraries/Core/InitializeCore';
import './setup';
import 'process-nextick-args';
import React from 'react';
import { AppRegistry, StyleSheet, View, AsyncStorage } from 'react-native';
import { startup } from 'browser-core-lumen-ios';
import Cliqz from './cliqzWrapper';
import { setDefaultSearchEngine } from 'browser-core-lumen-ios/build/modules/core/search-engines';
import { addConnectionChangeListener, removeConnectionChangeListener } from 'browser-core-lumen-ios/build/modules/platform/network';
import prefs from 'browser-core-lumen-ios/build/modules/core/prefs';
import events from 'browser-core-lumen-ios/build/modules/core/events';
import SearchUI from 'browser-core-lumen-ios/build/modules/mobile-cards/SearchUI';
import SearchUIVertical from 'browser-core-lumen-ios/build/modules/mobile-cards-vertical/SearchUI';
import { Provider as CliqzProvider } from 'browser-core-lumen-ios/build/modules/mobile-cards/cliqz';
import { Provider as ThemeProvider } from 'browser-core-lumen-ios/build/modules/mobile-cards-vertical/withTheme';

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

class MobileCards extends React.Component {
  constructor(props) {
    super(props);
    this.cliqz = new Cliqz();
    this.isDeveloper = prefs.get('developer', false);
    this.appStart = props.appStart || Promise.resolve();

    events.sub('search:results', this.updateResults);
    events.sub('mobile-browser:notify-preferences', this.updatePreferences);
    events.sub('mobile-browser:set-search-engine', this.setSearchEngine);
    addConnectionChangeListener();
  }

  state = {
    results: {
      results: [],
      meta: {}
    },
    theme: 'light'
  }

  componentWillUnmount() {
    events.un_sub('mobile-browser:notify-preferences', this.updatePreferences);
    events.un_sub('mobile-browser:set-search-engine', this.setSearchEngine);
    events.un_sub('search:results', this.updateResults);
    removeConnectionChangeListener();
  }

  setSearchEngine = (engine) => {
    setDefaultSearchEngine(engine);
  }

  _setTheme(incognito) {
    const theme = incognito ? 'dark' : 'light';
    this.setState({ theme });
  }

  updatePreferences = (_prefs) => {
    // clear cache with every visit to tab overiew and settings
    this.appStart.then(() => {
      Object.keys(_prefs).forEach((key) => {
        prefs.set(key, _prefs[key]);
        if ((key === 'incognito')) {
          this._setTheme(_prefs[key]);
        }
      });
    });
  }

  updateResults = results => this.setState({ results });

  render() {
    const { results, suggestions, meta } = this.state.results;
    const appearance = this.state.theme;
    const layout = 'vertical';
    const SearchComponent = layout === "horizontal" ? SearchUI : SearchUIVertical;
    return (
        <View style={styles.container}>
          <CliqzProvider value={this.cliqz}>
            <ThemeProvider value={appearance}>
              <SearchComponent
                results={results}
                suggestions={suggestions}
                meta={meta}
                theme={appearance}
              />
            </ThemeProvider>
          </CliqzProvider>
        </View>
    );
  }
}


AppRegistry.registerComponent('ExtensionApp', () => AppContainer(MobileCards, appStart));