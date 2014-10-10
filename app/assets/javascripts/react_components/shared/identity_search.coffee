###
  Used in:

  react_components/editor/blocks/identity_selector
###

# Expose
#
tag = React.DOM


# Normalize query
#
normalizeQuery = (query) ->
  query.split(' ').map((part) -> part.trim()).filter((part) -> part.length).map((part) -> part.toLowerCase()).join(' ')


# Main component
#
MainComponent = React.createClass


  preloadModels: (model_class_name) ->
    return if @modelsLoaded(model_class_name)

    if url = @props.models[model_class_name]
      cc.models[model_class_name].load(url).done =>
        @onModelsLoaded(model_class_name)
    else
      @onModelsLoaded(model_class_name)
  

  onModelsLoaded: (model_class_name) ->
    loaded_models = @state.loaded_models.slice(0)
    loaded_models.push(model_class_name)
    @setState { loaded_models: loaded_models }
  

  modelsLoaded: (model_class_name) ->
    @state.loaded_models.indexOf(model_class_name) > -1


  search: ->
    Object.keys(@props.models).reduce (memo, model_class_name) =>
      @preloadModels(model_class_name)

      memo[model_class_name] = if @modelsLoaded(model_class_name)
        
        model_class = cc.models[model_class_name]
        models      = model_class.instances
          
        _.each @state.normalized_query.split(' '), (query) ->
          models = _.filter models, (model) -> model.matches(query)
        
        _.pluck models, 'uuid'
        
      else
        false
      
      memo
    , {}
  
  
  focus: ->
    @getDOMNode().focus()
  

  blur: ->
    @getDOMNode().blur()
    

  onChange: (event) ->
    @setState
      query:            event.target.value
      normalized_query: normalizeQuery(event.target.value)
  

  onKeyUp: (event) ->
    event.target.blur() if event.which == 27
  
  
  onFocus: (event) ->
    @search()
    @setState
      active: true
  
  
  onBlur: (event) ->
    @props.onBlur() if @props.onBlur instanceof Function

    @setState
      active:           false
      query:            ''
      normalized_query: ''
  

  getDefaultProps: ->
    placeholder:  'Search identities'
    models:       {}
  
  
  getInitialState: ->
    active:           false
    query:            ''
    normalized_query: ''
    loaded_models:    []


  componentDidUpdate: (prevProps, prevState) ->
    if ['normalized_query', 'loaded_models'].some((state_key) => @state[state_key] != prevState[state_key])
      @props.onSearch(@search()) if @props.onSearch instanceof Function


  render: ->
    (tag.input {
      type:         'text'
      className:    'identity-search'
      value:        @state.query
      placeholder:  @props.placeholder
      onChange:     @onChange
      onKeyUp:      @onKeyUp
      onFocus:      @onFocus
      onBlur:       @onBlur
    })


# Expose
#
@cc.react.shared.IdentitySearch = MainComponent
