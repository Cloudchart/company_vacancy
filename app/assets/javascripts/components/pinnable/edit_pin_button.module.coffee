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
      @setState
        loaders: @state.loaders.set('system_roles', true)


  isLoaded: ->
    @state.loaders.get('system_roles') == true


  isEditor: ->
    !!RoleStore.cursor.items
      .find (role) =>
        role.get('owner_id', null)    is null     and
        role.get('owner_type', null)  is null     and
        role.get('value')             is 'editor' and
        role.get('user_id')           is @state.user.get('uuid')



  getInitialState: ->
    loaders:  Immutable.Map()
    user:     UserStore.currentUserCursor()


  renderPinForm: ->
    <PinForm uuid={ @props.uuid } onDone={ ModalStack.hide } onCancel={ ModalStack.hide } />


  render: ->
    return null unless @isLoaded()
    return null unless @isEditor()

    <li onClick={ @handleClick }>
      <i className="fa fa-pencil" />
    </li>
