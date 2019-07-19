import { NativeModules } from 'react-native';
import console from 'browser-core-lumen-ios/build/modules/core/console';

let translations;

export default function t(key) {
  if (!translations) {
    const locale = NativeModules.LocaleConstants.lang;
    switch (locale) {
      case 'de':
        translations = require('./localization/de.json');
        break;
      default:
        translations = require('./localization/en.json');
    }
  }
  const translation = translations[key];

  if (!translation) {
    console.warn(`Cannot find translation for key "${key}"`);
    return key;
  }

  return translation.message;
}