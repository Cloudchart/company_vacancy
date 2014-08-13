##= require components/Avatar
##= require actions/PersonActionsCreator
##= require stores/PersonStore

# Imports
#
tag = React.DOM


AvatarComponent       = cc.require('cc.components.Avatar')
PersonActionsCreator  = cc.require('cc.actions.PersonActionsCreator')
PersonStore           = cc.require('cc.stores.PersonStore')


# Functions
#
getStateFromStores = (key) ->
  person: PersonStore.find(key)


# Component
#
Component = React.createClass


  onChange: ->
    @setState getStateFromStores(@props.key)


  componentDidMount: ->
    PersonStore.on('change', @onChange)
  
  
  componentWillUnmount: ->
    PersonStore.off('change', @onChange)
  
  
  getDefaultProps: ->
    shouldRenderLettersInAvatar: true
  
  
  getInitialState: ->
    getStateFromStores(@props.key)


  render: ->
    if @state.person
      
      avatarURL = @state.person.attr('avatar_url')
      
      classList = {
        'person':         true
        'with-avatar':  !!avatarURL
      }
      
      classList = _.reduce classList, ((memo, value, key) -> memo.push(key) if !!value ; memo), []
        
      (tag.div {
        className: classList.join(' ')
      },

        # Avatar
        #
        (AvatarComponent {
          avatarURL:            @state.person.attr('avatar_url')
          value:                @state.person.attr('full_name')
          shouldRenderContent:  @props.shouldRenderLettersInAvatar
        })

        # Name
        #
        (tag.header {}, @state.person.attr('full_name'))

        # Occupation
        #
        (tag.footer {}, @state.person.attr('occupation'))
        
        # Additional components
        #
        @props.children

      )
      
    else
      (tag.noscript {})



# Exports
#
cc.module('cc.components.Person').exports = Component
