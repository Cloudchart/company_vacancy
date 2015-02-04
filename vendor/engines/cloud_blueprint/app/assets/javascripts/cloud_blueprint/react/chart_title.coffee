# Imports
#
tag = React.DOM

InputComponent = require('legacy/input')


# Main Component
#
MainComponent = React.createClass

  
  getDefaultProps: ->
    disabled: true


  render: ->
    (tag.div { className: 'chart-title-editor' },

      (tag.a {
        className:  'title'
        href:       @props.company_url
      },
        @props.company_name
        " "
        (tag.i { className: 'fa fa-angle-right' })
        " "
      )
      
      (InputComponent {
        type:           'text'
        autoComplete:   'off'
        placeholder:    'Chart name'
        className:      'name'
        autoFocus:      @props.title == 'Default Chart'
        
        disabled:       @props.disabled
        value:          @props.title
        
        url:            @props.url
        readAttribute:  'title'
        saveAttribute:  'chart[title]'
      })

    )


# Exports
#
cc.module('blueprint/react/chart-title').exports = MainComponent
