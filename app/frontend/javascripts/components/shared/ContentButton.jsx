import React from 'react';

import './ContentButton.style';

export default class ContentButton extends React.Component {

  static defaultProps = {
    label: 'Get Access',
    text: 'Requires Twitter account. Free while in beta.',
    href: '/login'
  };

  _handleClick (event) {
    window.location = this.props.href;
  }

  render () {
    return (
      <div className="content-button">
        <a className="button button_opaque" href="{ this.props.href }">{ this.props.label }</a>
        <button className="opaque" onClick={ this._handleClick }>{ this.props.label }</button>
        <p>{ this.props.text }</p>
      </div>
    )
  }
}
