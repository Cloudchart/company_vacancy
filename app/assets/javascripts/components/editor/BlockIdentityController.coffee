###
  Used in:

  react_components/editor/blocks/people
###

##= require actions/BlockIdentityActionsCreator
##= require components/Person
##= require components/Vacancy
##= require stores/BlockIdentityStore


# Imports
#
tag = React.DOM

BlockIdentityActionsCreator   = cc.require('cc.actions.BlockIdentityActionsCreator')

PersonComponent               = cc.require('cc.components.Person')
VacancyComponent              = cc.require('cc.components.Vacancy')

BlockIdentityStore            = cc.require('cc.stores.BlockIdentityStore')


IdentityComponents =
  Person:   PersonComponent
  Vacancy:  VacancyComponent


# Functions
#
getStateFromStores = (key) ->
  identity: BlockIdentityStore.find(key)
  

# Main Component
#
Component = React.createClass


  getComponent: ->
    IdentityComponents[@state.identity.attr('identity_type')]
      key: @state.identity.attr('identity_id')


  gatherButtons: ->
    (tag.section {
      className: 'buttons'
    },
      (tag.button { className: 'delete', onClick: @onDeleteClick }, 'Delete')
      (tag.button { ckassName: 'change', onClick: @onChangeClick }, 'Change')
    )


  onDeleteClick: ->
    BlockIdentityActionsCreator.destroy(@props.key)
  
  
  onChangeClick: ->


  getDefaultProps: ->
    isReadOnly: false
  
  
  getInitialState: ->
    getStateFromStores(@props.key)


  render: ->
    (tag.div { className: 'controller aspect-ratio-1x1' },
      (tag.div { className: 'content' },
        @getComponent()
        @gatherButtons() unless @props.isReadOnly
      )
    )


# Exports
#
cc.module('cc.components.Editor.BlockIdentityController').exports = Component
