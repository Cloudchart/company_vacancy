@['vacancy_responses#index'] = (data) ->
  mountingPoint = document.querySelector('main.cloud-profile div.vacancy-responses-wrapper div.reviewers')
  
  peopleComponent = cc.react.editor.blocks.People
    collection_url: data.collection_url
    identities: data.reviewers

    save: (component) ->

      people = component.state.people
      uuids = people.map((person) -> person.uuid)

      $.ajax
        url: data.reviewers_url
        type: 'PUT'
        dataType: 'json'
        data:
          vacancy:
            reviewer_ids: if uuids.length == 0 then [''] else uuids

      .done (json) ->
        component.setState({ people: json })

      # .fail ->
  

  React.renderComponent(peopleComponent, mountingPoint) if mountingPoint
