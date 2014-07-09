# Expose
#
tag = React.DOM


# Identity List Component
#
MainComponent = React.createClass

  
  gatherIdentities: ->
    @props.models_order.map (model_class_name) =>
      if uuids = @props.identities[model_class_name]
        models = _.sortBy uuids.map((uuid) -> cc.models[model_class_name].get(uuid)), @props.models_sorting[model_class_name]

        models.map (model) =>
            cc.react.shared.identities[model_class_name]
              onClick:  @props.onClick
              key:      model.uuid

      else if uuids == false
        # render loading
        null

    .filter (component) -> component
  
  
  getDefaultProps: ->
    models_order:   ['Vacancy', 'Person']
    models_sorting:
      Person:   ['last_name', 'first_name']
      Vacancy:  ['name']
  
  
  render: ->
    (tag.ul { className: 'identity-list' },
      @gatherIdentities()
    )


# Expose
#
@cc.react.shared.IdentityList = MainComponent
