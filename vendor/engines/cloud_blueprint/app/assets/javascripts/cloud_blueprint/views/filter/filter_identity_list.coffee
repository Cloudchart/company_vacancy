identities = [
    name:     'Vacancy'
    sort_by:  'name'
  ,
    name:     'Person'
    sort_by:  ['last_name', 'first_name']
]

#
#

IdentityView = cc.blueprint.views.FilterIdentity


#
#
#


class FilterIdentityListView
  
  constructor: (container) ->
    @$container = $(container) ; throw "Container not found for #{@constructor.name}" unless @$container.length
  
  
  prepare_identity_views: (name) ->
    $container = @$container
    
    available_views         = _.filter IdentityView.instances, (view) -> view.model.constructor.name == name
    available_views_uuids   = _.map available_views, 'uuid'
    available_models        = _.map cc.blueprint.models[name].instances
    available_models_uuids  = _.map available_models, 'uuid'
    
    # delete views for removed models
    _.chain(available_views_uuids)
      .reject((uuid) -> _.contains available_models_uuids, uuid)
      .each((uuid) -> IdentityView.get(uuid).destroy())
    
    # create views for new models
    _.chain(available_models_uuids)
      .reject((uuid) -> _.contains available_views_uuids, uuid)
      .each((uuid) -> new IdentityView cc.blueprint.models[name].get(uuid))
    
    @
    

  render: ->
    container = @$container.get(0)

    _.each identities, (entry) =>
      @prepare_identity_views(entry.name)
    
      _.chain(cc.blueprint.models[entry.name].instances)
        .sortBy(entry.sort_by)
        .each((model) -> container.appendChild(IdentityView.get(model.uuid).render().element))

    @
    

#
#
#

_.extend cc.blueprint.views,
  FilterIdentityList: FilterIdentityListView
