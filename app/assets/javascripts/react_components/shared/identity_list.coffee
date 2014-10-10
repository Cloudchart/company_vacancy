###
  Used in:

  react_components/editor/blocks/identity_selector
###

##= require components/Person
##= require components/Vacancy

# Expose
#
tag = React.DOM


IdentityComponents = 
  Person:   cc.require('cc.components.Person')
  Vacancy:  cc.require('cc.components.Vacancy')


# Identity List Component
#
MainComponent = React.createClass


  onIdentityClick: (uuid) ->
    @props.onClick({ target: { value: uuid }}) if _.isFunction(@props.onClick)

  
  gatherIdentities: ->
    @props.models_order.map (model_class_name) =>
      if uuids = @props.identities[model_class_name]
        models = _.sortBy uuids.map((uuid) -> cc.models[model_class_name].get(uuid)), @props.models_sorting[model_class_name]

        models.map (model) =>
          
          (tag.li {
            onClick:  @onIdentityClick.bind(@, model.uuid)
            key:      model.uuid
          },
            (IdentityComponents[model_class_name] {
              key:    model.uuid
            })
          )
          
          

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
    (tag.ul {
      className: 'identity-list'
    },
      @gatherIdentities()
    )


# Expose
#
@cc.react.shared.IdentityList = MainComponent
