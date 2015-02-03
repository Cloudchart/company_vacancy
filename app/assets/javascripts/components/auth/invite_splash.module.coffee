# Imports
#
tag = cc.require('react/dom')

SplashComponent = require('components/auth/splash')


# Main Component
#
Component = React.createClass


  render: ->
    (SplashComponent {
      header: 'Invite Requested'
      note:   'Cloud<strong>Chart</strong> loves you.<br />If you feel you\'re missing out,<br />let us know at <a href="mailto:friends@cloudchart.co">friends@cloudchart.co</a>'
    })


# Exports
#
module.exports = Component
