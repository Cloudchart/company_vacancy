# Imports
#
tag = React.DOM


CompanyActions  = require('actions/company')
CompanyStore    = require('stores/company')

CompanyHeader   = require('components/company/header')
AutoSizingInput = require('components/form/autosizing_input')



# Main
#
Component = React.createClass


  onShareLinkClick: (event) ->
    event.preventDefault()
  
  
  onInputBlur: (event) ->
    CompanyActions.update(@props.key, {
      name:         @state.name
      description:  @state.description
    })


  onNameChange: (event) ->
    @setState({ name: event.target.value })
  
  
  onDescriptionChange: (event) ->
    @setState({ description: event.target.value })
  
  
  getStateFromStores: ->
    CompanyStore.get(@props.key).toJSON()
  
  
  refreshStateFromStores: ->
    @setState(@getStateFromStores())
  
  
  componentDidMount: ->
    CompanyStore.on('change', @refreshStateFromStores)
  

  componentWillUnmount: ->
    CompanyStore.off('change', @refreshStateFromStores)


  getInitialState: ->
    @getStateFromStores()


  render: ->
    placeholder = "ACME"
    
    (tag.article {
      className: 'company-2_0'
    },
    
      (CompanyHeader {
        key:          @props.key
        logotype_url: @state.logotype_url
        name:         @state.name
        description:  @state.description
      })
      
      (tag.section {
      })
    
      'Greatest And Brightest'

      (tag.div {
        className: 'paragraph'
      },
        "Digital October hosts unique educational programs inviting top educators and experts from around the world. Entrepreneurs and investors get access to best networking opportunities in an informal atmosphere of our Progress Bar located right next to the conference."
      )

      
      (tag.header null,
        'Open Positions'
      )
      
      
      (tag.div {
        className: 'image'
      },
        (tag.div {
          className: 'placeholder'
        },
          (tag.label null,
            (tag.h2 null,
              (tag.i { className: 'fa fa-picture-o' })
              "Product pucture goes here"
            )
            (tag.p null, "Use professional photography or graphics design.")
            (tag.p null, "Use pictures at least 1500 px wide with a ratio of 4:3.")
            (tag.p null, "1600x1200 px is a good start.")
          )
        )
      )
      
    )


# Exports
#
module.exports = Component
