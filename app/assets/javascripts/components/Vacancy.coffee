##= require utils/Colors
##= require components/Avatar
##= require stores/VacancyStore

# Imports
#
tag = React.DOM


VacancyColor      = cc.require('cc.utils.Colors.Vacancy')
AvatarComponent   = cc.require('cc.components.Avatar')
VacancyStore      = cc.require('cc.stores.VacancyStore')


# Functions
#
getStateFromStores = (key) ->
  vacancy: VacancyStore.find(key)


# Component
#
Component = React.createClass


  onChange: ->
    @setState getStateFromStores(@props.key)


  componentDidMount: ->
    VacancyStore.on('change', @onChange)
  
  
  componentWillUnmount: ->
    VacancyStore.off('change', @onChange)
  
  
  getInitialState: ->
    getStateFromStores(@props.key)


  render: ->
    if @state.vacancy
      
      classList = {
        'vacancy': true
      }
      
      classList = _.reduce classList, ((memo, value, key) -> memo.push(key) if !!value ; memo), []
        
      (tag.div {
        className: classList.join(' ')
      },

        # Avatar
        #
        (AvatarComponent {
          backgroundColor:      VacancyColor
          shouldRenderContent:  @props.shouldRenderIconInAvatar
        },
          (tag.i { className: 'fa fa-briefcase' })
        )

        # Name
        #
        (tag.header {}, @state.vacancy.attr('name'))

        # Description
        #
        (tag.footer {}, "Vacancy")
        
        # Additional components
        #
        @props.children

      )
      
    else
      (tag.noscript {})



# Exports
#
cc.module('cc.components.Vacancy').exports = Component
