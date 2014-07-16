@['vacancy_responses#index'] = (data) ->
  @cc.ujs.people_search(data)

  mountingPoint = document.querySelector('[data-react-mount-point~="reviewers"]')
  
  peopleComponent = cc.react.editor.blocks.People
    collection_url: data.collection_url
    url:            null

    save: (component) ->

      people  = component.state.people
      uuids   = people.map((person) -> person.uuid)

      ###
      $.ajax
        url:  null
        type: 'PUT'
        dataType: 'json'
        data:
          vacancy:
            reviewer_ids: uuids

      .done (json) ->
        component.setState({ people: json })

      .fail ->
      ###
  

  React.renderComponent(peopleComponent, mountingPoint) if mountingPoint
