import React from 'react';

import CollectionSlab from './CollectionSlab';


export default class CollectionSlabList extends React.Component {
  static defaultProps = {
    items: []
  };

  renderItem (item) {
    <CollectionSlab collection={ item } key={ item.id } />
  }

  render () {
    return (
      <div className="collections-slabs">
        { this.props.items.map(this.renderItem) }
      </div>
    );
  }
};
