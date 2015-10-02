import React from 'react';
import ReactDOM from 'react-dom';
import Relay from 'react-relay';

Array.prototype.forEach.call(document.querySelectorAll('[data-react-component]'), (node) => {
  let Component = require('./components/' + node.dataset.reactComponent);
  let Route = require('./routes/' + node.dataset.relayRoute);
  ReactDOM.render(<Relay.RootContainer Component={ Component } route={ new Route } />, node);
});
