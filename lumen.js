import 'react-native/Libraries/Core/InitializeCore';
import './setup';
import 'process-nextick-args';
import React from 'react';
import {
  AppRegistry,
  StyleSheet, View,
  Text,
  ScrollView,
  NativeModules,
  NativeEventEmitter,
  TouchableWithoutFeedback,
} from 'react-native';

import { startup } from 'browser-core-lumen-ios';
import { setDefaultSearchEngine } from 'browser-core-lumen-ios/build/modules/core/search-engines';
import { addConnectionChangeListener, removeConnectionChangeListener } from 'browser-core-lumen-ios/build/modules/platform/network';
import prefs from 'browser-core-lumen-ios/build/modules/core/prefs';
import events from 'browser-core-lumen-ios/build/modules/core/events';
import SearchUI from 'browser-core-lumen-ios/build/modules/mobile-cards/SearchUI';
import SearchUIVertical from 'browser-core-lumen-ios/build/modules/mobile-cards-vertical/SearchUI';
import { Provider as CliqzProvider } from 'browser-core-lumen-ios/build/modules/mobile-cards/cliqz';
import { Provider as ThemeProvider } from 'browser-core-lumen-ios/build/modules/mobile-cards-vertical/withTheme';
import inject from 'browser-core-lumen-ios/build/modules/core/kord/inject';
import NativeDrawable, { normalizeUrl } from 'browser-core-lumen-ios/build/modules/mobile-cards/components/custom/NativeDrawable';

import Onboarding from './js/lumen-onboarding';
import Cliqz from './cliqzWrapper';
import t from './js/i18n';

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
    height: 40,
    backgroundColor: '#656d7e',
    alignItems: 'center',
    justifyContent: 'center',
    borderBottomLeftRadius: 10,
    borderBottomRightRadius: 10,
  },
  searchEnginesContainer: {
    flexDirection: 'row',
    justifyContent: 'space-evenly',
    marginTop: 20,
    marginBottom: 100,
    textAlign: 'center',
  },
  searchEngineIcon: {
    height: 74,
    width: 74,
    borderRadius: 10,
    overflow: 'hidden',
  },
  searchEngineText: {
    color: 'white',
    textAlign: 'center',
  },
});

class MobileCards extends React.Component {
  constructor(props) {
    super(props);
    this.state = {
      onboarding: false,
      results: {
        results: [],
        meta: {}
      },
      isReady: false,
      hasQuery: false,
      theme: 'lumen-light',
      query: '',
    }

    this.cliqz = new Cliqz(inject);
    this.isDeveloper = prefs.get('developer', false);
    this.appStart = appStart || Promise.resolve();
    this.init();
    this.scrollRef = React.createRef();
  }

  async init() {
    await this.appStart;
    const config = await nativeBridge.getConfig();
    this.setState({
      onboarding: config.onboarding,
      isReady: true,
    });
    events.sub('search:results', this.updateResults);
    events.sub('mobile-browser:notify-preferences', this.updatePreferences);
    events.sub('mobile-browser:set-search-engine', this.setSearchEngine);
    addConnectionChangeListener();
    this.eventEmitter = new NativeEventEmitter(nativeBridge);
    this.eventEmitter.addListener('action', this.onAction);
    this.eventEmitter.addListener('publishEvent', this.onEvent);
  }

  componentWillUnmount() {
    if (!this.eventEmitter) {
      return;
    }
    events.un_sub('mobile-browser:notify-preferences', this.updatePreferences);
    events.un_sub('mobile-browser:set-search-engine', this.setSearchEngine);
    events.un_sub('search:results', this.updateResults);
    removeConnectionChangeListener();
    this.eventEmitter.removeAllListeners();
  }

  onEvent = () => {}

  onAction = async ({ action, args, id }) => {
    const [module, name] = action.split(':');
    if (this.state.onboarding === true && module === 'search' && name === 'startSearch') {
      // don't start search until onboarding is finished
      this.retryLastSearch = () => this.onAction({ action, args, id });
      this.setState({
        query: args[0],
        hasQuery: true,
      });
      return;
    } else {
      this.setState({
        query: args[0],
      });
    }
    if (action === 'core:setPref') {
      prefs.set(...args);
      return;
    }
    const response = await inject.module(module).action(name, ...args);
    if (typeof id !== 'undefined') {
      nativeBridge.replyToAction(id, response);
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

  updateResults = results => {
    if (this.scrollRef.current) {
      this.scrollRef.current.scrollTo({ y: 0, animated: false });
    }
    this.setState({ results, onboarding: false });
  }

  onTryNowPressed = (choice) => {
    NativeModules.Onboarding.tryLumenSearch(choice);
    setTimeout(() => {
      this.setState({
        onboarding: false,
      }, () => {
        if (choice && this.retryLastSearch) {
          this.retryLastSearch();
          this.retryLastSearch = null;
        }
      });
    }, 1000); // wait for onboarding animation to finish
  }

  openSearchEngineLink = async (url, index) => {
    const results = this.state.results || {};
    const meta = results.meta || {};
    const query = this.state.query;
    await inject.module('mobile-cards').action('openLink', url, {
      action: 'click',
      elementName: 'icon',
      isFromAutoCompletedUrl: false,
      isNewTab: false,
      isPrivateMode: false,
      isPrivateResult: meta.isPrivate,
      query,
      isSearchEngine: true,
      rawResult: {
        index: index,
        url,
        provider: 'instant',
        type: 'supplementary-search',
      },
      resultOrder: meta.resultOrder,
      url,
    });
  }

  render() {
    if (!this.state.isReady) {
      return null;
    }
    const { results, suggestions, meta, query } = this.state.results;
    const appearance = this.state.theme;
    const layout = 'vertical';
    const SearchComponent = layout === "horizontal" ? SearchUI : SearchUIVertical;
    if (this.state.onboarding) {
      return (
        <Onboarding onChoice={this.onTryNowPressed} hasQuery={this.state.hasQuery}/>
      );
    } else {
      NativeModules.QuerySuggestion.showQuerySuggestions(query, suggestions);
      return (
        <View style={styles.container}>
          <CliqzProvider value={this.cliqz}>
            <ThemeProvider value={appearance}>
              <ScrollView
                bounces={false}
                ref={this.scrollRef}
              >
                <SearchComponent
                  results={results}
                  meta={meta}
                  theme={appearance}
                  style={{ backgroundColor: 'white', paddingTop: 9 }}
                  cardListStyle={{ paddingLeft: 0, paddingRight: 0 }}
                  header={<View />}
                  separator={<View style={{ height: 0.5, backgroundColor: '#D9D9D9' }} />}
                  footer={<View />}
                />
                <>
                  { /* TODO chrmod: colors and font sizes */ }
                  { results.length === 0 &&
                    <View style={{ backgroundColor: 'white', height: 80, alignItems: 'center', justifyContent: 'center' }}>
                      <Text style={{ color: '#656d7e' }}>{t('search_no_results')}</Text>
                    </View>
                  }
                  <View style={styles.footer}>
                    <Text style={{ color: 'white', }}>
                      {t('search_footer')}
                    </Text>
                  </View>
                  <View style={{ alignItems: 'center', justifyContent: 'center', marginTop: 20 }}>
                    <Text style={{ color: 'white' }}>{t('search_alternative_search_engines_info')}</Text>
                  </View>
                  <View style={styles.searchEnginesContainer}>
                    <TouchableWithoutFeedback
                      onPress={() => this.openSearchEngineLink(`https://google.com/search?q=${encodeURIComponent(this.state.query)}`, 0)}
                    >
                      <View>
                        <NativeDrawable
                          style={styles.searchEngineIcon}
                          source={normalizeUrl('google.svg')}
                        />
                        <Text style={styles.searchEngineText}>Google</Text>
                      </View>
                    </TouchableWithoutFeedback>
                    <TouchableWithoutFeedback
                      onPress={() => this.openSearchEngineLink(`https://duckduckgo.com/?q=${encodeURIComponent(this.state.query)}`, 1)}
                    >
                      <View>
                        <NativeDrawable
                          style={styles.searchEngineIcon}
                          source={normalizeUrl('ddg.svg')}
                        />
                        <Text style={styles.searchEngineText}>DuckDuckGo</Text>
                      </View>
                    </TouchableWithoutFeedback>
                    <TouchableWithoutFeedback
                      onPress={() => this.openSearchEngineLink(`https://www.bing.com/search?q=${encodeURIComponent(this.state.query)}`, 2)}
                    >
                      <View>
                        <NativeDrawable
                          style={styles.searchEngineIcon}
                          source={normalizeUrl('bing.svg')}
                        />
                        <Text style={styles.searchEngineText}>Bing</Text>
                      </View>
                    </TouchableWithoutFeedback>
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
