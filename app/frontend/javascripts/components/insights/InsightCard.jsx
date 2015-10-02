import React from 'react';
import Relay from 'react-relay';

import {truncate} from '../../utils/string';

const MAX_CONTENT_LENGTH = 230;

class InsightCard extends React.Component {
  render () {
    return (
      <div className="insight-card">
        <p className="content">
          <a href={ this.props.insight.url } className="through">
            { truncate(this.props.insight.content, MAX_CONTENT_LENGTH) }
          </a>
        </p>
        <ul className="controls">
          <li className="user">
            <a href={ this.props.insight.user.url }>
              { this.props.insight.user.full_name }
            </a>
          </li>
        </ul>
      </div>
    );
  }
};

export default Relay.createContainer(InsightCard, {
  fragments: {
    insight: () => Relay.QL`
      fragment on Insight {
        content
        url
        user {
          full_name
          url
        }
      }
    `
  }
});
