import React from 'react';
import Relay from 'react-relay';

import InsightCardList from './InsightCardList';
import InsightCardListTouch from './InsightCardListTouch';
import InsightCard from './InsightCard';

import {deviceIs} from '../../utils/media';


class InsightsContainer extends React.Component {
  renderWeb () {
    return (
      <InsightCardList collections={ this.props.collections } />
    );
  }

  renderTouch () {
    return (
      <InsightCardListTouch collections={ this.props.collections } />
    );
  }

  render () {
    return deviceIs('iphone').matches ? this.renderTouch() : this.renderWeb();
  }
}

export default Relay.createContainer(InsightsContainer, {
  fragments: {
    collections: () => Relay.QL`
      fragment on Collection @relay(plural: true) {
        id
        title
        url
        insights(first: 3) {
          edges {
            node {
              id
              ${InsightCard.getFragment('insight')}
            }
          }
        }
      }
    `
  }
});
