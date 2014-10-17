###
  Used in:

  actions/BlockIdentityActionsCreator
  react_components/editor/blocks/people
###

##= require promise
##= require actions/ServerActionsCreator


promises = {}

ServerActionsCreator = cc.require('cc.actions.ServerActionsCreator')


urlForCreate = (model) ->
  "/blocks/#{model.attr('block_id')}/identities"


urlForDestroy = (model) ->
  "/identities/#{model.to_param()}"


# Module
#
Module =
  
  load: (url, force = false) ->
    delete promises[url] if force

    promises[url] ||= Promise.resolve(
      $.ajax
        url:      url
        type:     'GET'
        dataType: 'json'
    )
    
    promises[url].then(
      (json) ->
        ServerActionsCreator.doneReceiveBlockIdentities(json)
    ,
      (xhr) ->
    )
    
    promises[url]
  
  
  create: (model) ->
    $.ajax
      url:        urlForCreate(model)
      type:       'POST'
      dataType:   'json'
      data:
        block_identity: model.attr()

    .done (json) ->
      ServerActionsCreator.doneCreateBlockIdentity(model, json)

    .fail (xhr) ->
      ServerActionsCreator.failCreateBlockIdentity(model, xhr)
  

  destroy: (model) ->
    $.ajax
      url:        urlForDestroy(model)
      type:       'DELETE'
      dataType:   'json'
    
    .done ->
      ServerActionsCreator.doneDestroyBlockIdentity(model)
    
    .fail (xhr) ->
      ServerActionsCreator.failDestroyBlockIdentity(model, xhr)
  

# Exports
#
cc.module('cc.utils.BlockIdentitySyncAPI').exports = Module
