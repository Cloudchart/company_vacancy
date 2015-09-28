import React from 'react';

import UserSlab from './UserSlab';

import './UserSlabList.style';


export default class UserSlabList extends React.Component {

  static defaultProps = {
    items: []
  };

  renderItem (item) {
    return (
      <li className="users-slabs__list-el" key={ item.id }>
        <UserSlab user={ item } />
      </li>
    )
  }

  render () {
    return (
      <div className="users-slabs">
        <ul className="users-slabs__list">
          { this.props.items.map(this.renderItem) }
        </ul>
      </div>
    );
  }
};
