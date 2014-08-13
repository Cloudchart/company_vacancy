##= require ../../../components/Person

# Expose
#
tag         = React.DOM

PersonModel = cc.models.Person

PersonComponent = cc.require('cc.components.Person')

# People component
#
Component = React.createClass

  
  onSaveDone: (json) ->
    @setState
      people: json.identities
  
  
  onSaveFail: ->


  save: ->
    return @props.save(@) if @props.save instanceof Function

    uuids = @state.people.map((person) -> person.uuid)

    $.ajax
      url:              @props.url
      type:             'PUT'
      dataType:         'JSON'
      data:
        block:
          identity_ids: if uuids.length == 0 then [''] else uuids
    .done @onSaveDone
    .fail @onSaveFail


  gatherPeople: (event) ->
    @state.people.map (person) =>
      (tag.div {
        key:            person.uuid
        className:      'container'
      },

        # Person Component
        #
        (PersonComponent {
          key:                          person.uuid
          shouldRenderLettersInAvatar:  false
        },

          # Delete Person from block
          #
          (tag.button { className: 'delete', onClick: @onPersonDelete.bind(@, person.uuid) }, 'Delete')
            
          # Change Person in block
          #
          (tag.button { className: 'change', onClick: @onPersonChange.bind(@, person.uuid) }, 'Change')

        )
      )
  
  
  onPersonSelect: (event) ->
    people = @state.people.slice(0)
    people.push(PersonModel.get(event.target.value))
    @setState
      people: people
  
  
  onPersonDelete: (uuid) ->
    person  = @state.people.filter((person) -> person.uuid == uuid)[0] ; return unless person
    people  = @state.people[..]
    
    people.splice(people.indexOf(person), 1)
    
    @setState
      people: people
  
  
  onPersonChange: (uuid) ->
    alert 'Not implemented yet.'


  getInitialState: ->
    people: @props.identities || []
  
  
  componentDidUpdate: (prevProps, prevState) ->
    prev_uuids  = prevState.people.map((person) -> person.uuid).sort()
    uuids       = @state.people.map((person) -> person.uuid).sort()

    @save() if prev_uuids < uuids or prev_uuids > uuids
  

  render: ->
    (tag.div { className: 'people' },
      @gatherPeople()
      (tag.div {
        key:        'selector'
        className:  'container'
      },
        (cc.react.editor.blocks.IdentitySelector {
          placeholder:      'Type name'
          models:           { Person: @props.collection_url }
          filtered_models:  { Person: _.pluck(@state.people, 'uuid') }
          onClick:          @onPersonSelect
        })
      )
    )


# Expose
#
cc.react.editor.blocks.People = Component
