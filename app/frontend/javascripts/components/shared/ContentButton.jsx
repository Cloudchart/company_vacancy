import React from 'react';

export default class ContentButton extends React.Component {

  static defaultProps = {
    label: 'Get Access',
    text: 'Requires Twitter account. Free while in beta.',
    href: '/login'
  };

  render () {
    return (
      <div className="content-button">
        <a className="button button_opaque" href={ this.props.href }>{ this.props.label }</a>
        <p>{ this.props.text }</p>
      </div>
    )
  }
}
