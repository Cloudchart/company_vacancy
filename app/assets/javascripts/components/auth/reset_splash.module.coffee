# Imports
#
tag = React.DOM

SplashComponent = require('components/auth/splash')


# Main Component
#
Component = React.createClass


  render: ->
    (SplashComponent {
      header: 'Password Reset'
      note:   'Cloud<strong>Chart</strong> loves you.<br />Check your email soon.<br />Problems? <a href="mailto:support@cloudchart.co">support@cloudchart.co</a>'
    })


# Exports
#
module.exports = Component
