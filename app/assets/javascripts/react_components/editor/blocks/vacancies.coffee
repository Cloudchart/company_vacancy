# Expose
#
tag         = React.DOM

Model       = cc.models.Vacancy


# Main component
#
MainComponent = React.createClass

  
  save: ->
    uuids = _.pluck(@state.identities, 'uuid')
    
    $.ajax
      url:        @props.url
      type:       'PUT'
      dataType:   'json'
      data:
        block:
          identity_ids: if uuids.length == 0 then [''] else uuids

    .done @doneSave
    .fail @failSave
  
  
  doneSave: (json) ->
    @setState({ identities: json.identities })
  
  
  failSave: ->
  
  
  onIdentityDelete: (event) ->
    identity    = _.find @state.identities, (identity) -> identity.uuid == event.target.value
    identities  = @state.identities.slice(0)

    identities.splice(identities.indexOf(identity), 1)
    
    @setState({ identities: identities })
  
  
  onIdentityChange: ->
    alert 'Not implemented yet.'


  onIdentitySelect: (event) ->
    identities = @state.identities.slice(0)
    identities.push(Model.get(event.target.value))
    @setState({ identities: identities })
  
  
  gatherIdentities: ->
    _.map @state.identities, (identity) =>
      (tag.div {
        key:        identity.uuid
        className:  'container'
      },
        cc.react.editor.blocks.Vacancy
          onDelete:   @onIdentityDelete
          onChange:   @onIdentityChange
          model:      identity
      )


  getInitialState: ->
    identities: @props.identities
  
  
  componentDidUpdate: (prevProps, prevState) ->
    prev_uuids = _.chain(prevState.identities).pluck('uuid').sort()
    curr_uuids = _.chain(@state.identities).pluck('uuid').sort()
    
    @save() if prev_uuids < curr_uuids or prev_uuids > curr_uuids
    

  render: ->
    (tag.div {
      className: 'vacancies'
    },
      @gatherIdentities()
      (tag.div {
        key:        'selector'
        className:  'container'
      },
        (cc.react.editor.blocks.IdentitySelector {
          placeholder:      'Type name'
          models:           { Vacancy: @props.collection_url }
          filtered_models:  { Vacancy: _.pluck(@state.identities, 'uuid') }
          onClick:          @onIdentitySelect
        })
      )
    )


# Expose
#
cc.react.editor.blocks.Vacancies = MainComponent
