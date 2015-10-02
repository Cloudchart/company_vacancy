import React from 'react';
import Relay from 'react-relay';

class UserSlab extends React.Component {

  render () {
    return (
      <figure className="user-slab">
        <a className="user-slab__url" href={ this.props.user.url }>
          <img src={ this.props.user.avatar } />
          <figcaption>
            <span className="user-slab__name">{ this.props.user.full_name }</span>
          </figcaption>
        </a>
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
