person_template = new t $.trim """
  <li data-id="{{=uuid}}" class="person" data-behaviour="draggable">
    <aside class="icon">
      <i class="fa fa-users"></i>
    </aside>
    <h2>
      <span class="first_name light">{{=first_name}}</span>
      <span class="last_name">{{=last_name}}</span>
    </h2>
    <p>
      {{=occupation}}
    </p>
  </li>
"""

vacancy_template = new t $.trim """
  <li data-id="{{=uuid}}" class="vacancy" data-behaviour="draggable">
    <aside class="icon">
      <i class="fa fa-briefcase"></i>
    </aside>
    <h2>{{=name}}</h2>
    <p>
      Vacancy
    </p>
  </li>
"""

templates =
  Person:   person_template
  Vacancy:  vacancy_template



#
#
#


class FilterIdentityView
  

  @instances: {}
  
  @get: (uuid) ->
    @instances[uuid]


  constructor: (@model) ->
    @uuid                         = @model.uuid
    @constructor.instances[@uuid] = @


  render: ->
    return @ if @element and @rendered_at >= @model.updated_at

    @reset()

    @rendered_at    = new Date

    dummy           = document.createElement('div')
    dummy.innerHTML = templates[@model.constructor.className].render(@model)
    @element        = dummy.firstChild

    @
  
  
  reset: ->
    @element.parentNode.removeChild(@element) if @element and @element.parentNode
  

  destroy: ->
    @reset()
    delete @constructor.instances[@uuid]
    @
  

#
#
#

_.extend cc.blueprint.views,
  FilterIdentity: FilterIdentityView
