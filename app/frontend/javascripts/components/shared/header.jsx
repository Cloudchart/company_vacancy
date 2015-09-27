import React from 'react';
import Relay from 'react-relay';


export default class extends React.Component {

  render = () =>
    <header className="site-header">
      <a href="/" className="site-header__logo" />
      <button className="transparent" onClick={ this.handleLoginButtonClick }>
        Login with Twitter
        <i className="fa fa-twitter" />
      </button>
    </header>

  handleLoginButtonClick = (event) => window.location = '/login';
}
