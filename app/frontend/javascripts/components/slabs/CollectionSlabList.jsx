import React from 'react';

import CollectionSlab from './CollectionSlab';


export default class CollectionSlabList extends React.Component {
  static defaultProps = {
    items: []
  };

  renderItem (item) {
    return (
      <li className="collections-slabs__list-el" key={ item.id }>
        <CollectionSlab collection={ item } />
      </li>
    )
  }

  render () {
    return (
      <div className="collections-slabs">
        <ul className="collections-slabs__list">
          { this.props.items.map(this.renderItem) }
        </ul>
      </div>
    );
  }
};
