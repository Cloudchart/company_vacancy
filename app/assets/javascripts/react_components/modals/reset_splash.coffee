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
      header: 'Password Reset'
      note:   'Cloud<strong>Chart</strong> loves you.<br />Check your email soon.<br />Problems? <a href="mailto:support@cloudchart.co">support@cloudchart.co</a>'
    })


# Exports
#
cc.module('react/modals/reset-splash').exports = Component
