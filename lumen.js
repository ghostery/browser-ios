import 'react-native/Libraries/Core/InitializeCore';
import './setup';
import 'process-nextick-args';
import React from 'react';
import { AppRegistry, StyleSheet, View, Text, ScrollView, NativeModules, Image, NativeEventEmitter } from 'react-native';
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
import Onboarding from './lumen-onboarding';

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
    height: 20,
    width: 20,
    borderRadius: 10,
    overflow: 'hidden',
  },
});

class MobileCards extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      onboarding: props.showSearchOnboarding,
      results: {
        results: [],
        meta: {}
      },
      theme: 'lumen-light'
    }

    this.cliqz = new Cliqz();
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

  onAction = ({ action, args, id }) => {
    const [module, name] = action.split(':');
    // TODO chrmod: it breaks in `inject.es` when you type clear and type again
    // TODO chrmod: block messages
    return this.appStart.then((app) => {
      return app.modules[module].action(name, ...args).then((response) => {
        if (typeof id !== 'undefined') {
          nativeBridge.replyToAction(id, response);
        }
        return response;
      });
    }).catch(e => console.error(e));
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

  onTryNowPressed = () => {
    // TODO chrmod: let messages pass
  }

  render() {
    const { results, suggestions, meta, query } = this.state.results;
    const appearance = this.state.theme;
    const layout = 'vertical';
    const SearchComponent = layout === "horizontal" ? SearchUI : SearchUIVertical;
    if (this.state.onboarding) {
      return (
        <Onboarding onTryNowPressed={this.onTryNowPressed} />
      );
    } else {
      NativeModules.QuerySuggestion.showQuerySuggestions(query, suggestions);
      return (
        <View style={styles.container}>
          <CliqzProvider value={this.cliqz}>
            <ThemeProvider value={appearance}>
              <ScrollView bounces={false} >
                <SearchComponent
                  results={results}
                  meta={meta}
                  theme={appearance}
                  style={{ backgroundColor: 'transparent', }}
                  cardListStyle={{ paddingLeft: 0, paddingRight: 0 }}
                  header={<View />}
                  separator={<View style={{ height: 0.5, backgroundColor: '#D9D9D9' }} />}
                  footer={<View />}
                />
                <>
                  { /* TODO chrmod: colors and font sizes and translations */ }
                  { results.length === 0 &&
                    <View style={{ backgroundColor: 'white', height: 80, alignItems: 'center', justifyContent: 'center' }}>
                      <Text style={{ color: '#656d7e' }}>KEINE TREFFER GEFUNDEN</Text>
                    </View>
                  }
                  <View style={styles.footer}>
                    <Text style={{ color: 'white', }}>
                      DIESE SUCHANFRAGE IST ANONYM
                    </Text>
                  </View>
                  <View style={{ alignItems: 'center', justifyContent: 'center', marginTop: 20 }}>
                    <Text style={{ color: 'white' }}>Lumen Suche trotzdem verlassen?</Text>
                  </View>
                  <View style={styles.searchEnginesContainer}>
                    { /* TODO chrmod: list + send openlink event onclick + real pngs */ }
                    <Image
                      style={styles.searchEngineIcon}
                      source={{ uri: 'https://cdn4.iconfinder.com/data/icons/new-google-logo-2015/400/new-google-favicon-512.png' }}
                    />
                    <Image
                      style={styles.searchEngineIcon}
                      source={{ uri: 'https://duckduckgo.com/assets/icons/meta/DDG-icon_256x256.png' }}
                    />
                    <Image
                      style={styles.searchEngineIcon}
                      source={{ uri: 'https://www.sclance.com/pngs/bing-png/bing_png_121500.png' }}
                    />
                  </View>
                </>
              </ScrollView>
            </ThemeProvider>
          </CliqzProvider>
        </View>
      );
    }
  }
}


AppRegistry.registerComponent('ExtensionApp', () => MobileCards);
