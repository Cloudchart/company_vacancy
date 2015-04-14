# @cjsx React.DOM


GlobalState = require('global_state/state')


# Components
#
ModalStack  = require('components/modal_stack')
PinForm     = require('components/form/pin_form')


# Stores
#
PinStore  = require('stores/pin_store')
RoleStore = require('stores/role_store.cursor')
UserStore = require('stores/user_store.cursor')


# Exports
#
module.exports = React.createClass

  displayName: 'EditPinButton'


  mixins: [GlobalState.mixin, GlobalState.query.mixin]


  statics:
    queries:
      system_roles: ->
        """
          Viewer {
            system_roles
          }
        """


  handleClick: (event) ->
    ModalStack.show(@renderPinForm())



  componentWillMount: ->
    GlobalState.fetch(@getQuery('system_roles')).then =>
      if @isMounted()
        @setState
          loaders: @state.loaders.set('system_roles', true)


  isLoaded: ->
    @state.loaders.get('system_roles') == true


  isUnicornPin: ->
    true


  getInitialState: ->
    loaders:  Immutable.Map()
    user:     UserStore.me()


  renderPinForm: ->
    <PinForm uuid={ @props.uuid } onDone={ ModalStack.hide } onCancel={ ModalStack.hide } />


  render: ->
    return null unless @isLoaded()
    return null unless UserStore.isEditor()
    return null unless @isUnicornPin()

    <li onClick={ @handleClick }>
      <i className="fa fa-pencil" />
    </li>
