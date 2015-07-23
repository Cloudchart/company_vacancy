let Immutable = require('immutable')
let React     = require('react')

Immutable.Seq(document.querySelectorAll('[data-new-react-class]')).forEach((node) => {
  let component = require('./components/' + node.dataset.newReactClass)
  let props     = {}

  try { props = JSON.parse(node.dataset.reactProps) } catch(e) {}

  React.render(React.createElement(component, props), node)
})
