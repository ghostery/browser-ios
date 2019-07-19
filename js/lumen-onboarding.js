import React from 'react';
import { StyleSheet, View, Text, TouchableWithoutFeedback, Animated, Easing } from 'react-native';
import { XmlEntities } from 'html-entities';
import t from './i18n';

const styles = StyleSheet.create({
  container: {
    backgroundColor: 'white',
    borderBottomLeftRadius: 9,
    borderBottomRightRadius: 9,
    alignItems: 'center',
    justifyContent: 'center',
    paddingTop: 35,
    paddingBottom: 25,
  },
  tryNow: {
    backgroundColor: '#3647D0',
    borderRadius: 14,
    alignItems: 'center',
    justifyContent: 'center',
    height: 36,
    marginTop: 20,
  },
  title: {
    letterSpacing: 0.25,
    fontSize: 18,
    fontWeight: '700',
    lineHeight: 21,
  },
  body: {
    marginTop: 8,
    fontSize: 13,
    lineHeight: 16,
    fontWeight: '500',
  }
});

export default class Onboarding extends React.Component {
  state = {
    isClicked: false,
  }

  get checkMark() {
    if (!this._checkMark) {
      const entities = new XmlEntities();
      this._checkMark = entities.decode('&#10003;');
    }

    return this._checkMark;
  }

  componentWillMount() {
    this.animatedValue = new Animated.Value(0);
    this.interpolateColor = (from, to) => this.animatedValue.interpolate({
      inputRange: [0, 150],
      outputRange: [from, to]
    });
    this.interplateWidth = this.animatedValue.interpolate({
      inputRange: [0, 150],
      outputRange: [95, 36]
    });
  }

  onPress = (choice) => {
    this.props.onChoice(choice);
    Animated.timing(this.animatedValue, {
      toValue: 150,
      duration: 250,
      easing: Easing.ease
    }).start();
    this.setState({ isClicked: true });
  }

  render() {
    // TODO chrmod: translations
    const tryNowText = this.state.isClicked ? this.checkMark : t('onboarding_action_accept');
    const noThanksText = this.state.isClicked ? (this.props.hasQuery ? t('onboarding_result_with_query') : t('onboarding_result_without_query')) : t('onboarding_action_reject');
    const animatedStyle = {
      backgroundColor: this.interpolateColor('#3647D0', '#AEAFFF'),
      width: this.interplateWidth,
    };
    return (
      <View style={styles.container}>
        <Animated.Text
          style={[styles.title, { color: this.interpolateColor('#3647D0', '#FFFFFF') }]}
        >
          {t('onboarding_title')}
        </Animated.Text>
        <Animated.Text
          style={[styles.text, { color: this.interpolateColor('#A9ACC4', '#FFFFFF') }]}
        >
          {t('onboarding_description_line1')}
        </Animated.Text>
        <Animated.Text
          style={[styles.text, { color: this.interpolateColor('#A9ACC4', '#FFFFFF') }]}
        >
          {t('onboarding_description_line2')}
        </Animated.Text>
        <TouchableWithoutFeedback disabled={this.state.isClicked} onPress={() => this.onPress(true)}>
          <Animated.View style={[styles.tryNow, animatedStyle]}>
            <Text style={{ fontWeight: '700', fontSize: 14, lineHeight: 17, color: 'white' }}>{tryNowText}</Text>
          </Animated.View>
        </TouchableWithoutFeedback>
        <TouchableWithoutFeedback disabled={this.state.isClicked} onPress={() => this.onPress(false)}>
          <>
            <Animated.Text style={{ letterSpacing: -0.2, marginTop: 20, fontSize: 14, lineHeight: 17, fontWeight: '700', color: this.interpolateColor('#3647D0', '#3647D0')}}>{noThanksText}</Animated.Text>
          </>
        </TouchableWithoutFeedback>
      </View>
    );
  }
}