##= require ./splash

# Imports
#
tag = cc.require('react/dom')

SplashComponent = cc.require('react/modals/splash')


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
cc.module('react/modals/invite-splash').exports = Component
