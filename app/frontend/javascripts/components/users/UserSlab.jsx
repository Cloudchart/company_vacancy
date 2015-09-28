import React from 'react';
import Relay from 'react-relay';

import './UserSlab.style';

class UserSlab extends React.Component {

  render () {
    return (
      <figure className="user-slab">
        <img src={ this.props.user.avatar } />
        <figcaption>
          <a href={ this.props.user.url }>
            { this.props.user.full_name }
          </a>
        </figcaption>
      </figure>
    );
  }
};

export default Relay.createContainer(UserSlab, {
  fragments: {
    user: () => Relay.QL`
      fragment on User {
        full_name
        url
        avatar(size: 160)
      }
    `
  }
});
