import React from 'react';
import Relay from 'react-relay';

import {pluralize} from '../../utils/string';

class CollectionSlab extends React.Component {

  render () {
    return (
      <div className="collection-slab">
        <a href={ this.props.collection.url } className="through">
          <span>{ this.props.collection.title }</span>
          <em>{ pluralize(this.props.collection.insights.count, 'insight', 'insights') }</em>
        </a>
      </div>
    );
  }
}

export default Relay.createContainer(CollectionSlab, {
  fragments: {
    collection: () => Relay.QL`
      fragment on Collection {
        title
        url
        insights {
          count
        }
      }
    `
  }
});
