import React from 'react';
import Relay from 'react-relay';

export default class Header extends React.Component {

  render () {
    return (
      <header className="site-header">
        <a href="/" className="site-header__logo" />
        <a className="button button_transparent" href="/login">
          <span>Login with Twitter</span>
          <i className="fa fa-twitter" />
        </a>
      </header>
    );
  }
}
