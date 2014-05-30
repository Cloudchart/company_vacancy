person_template = """
  <form class="person" data-id="{{=model.uuid}}">
    <aside class="avatar">
      <i class="fa fa-users"></i>
    </aside>
    
    <section class="name">
      <label>
        <input type="text" name="first_name" value="{{%model.first_name}}" autocomplete="off" autofocus="true" placeholder="{{=first_name_placeholder}}" required="true" class="blueprint" />
      </label>
      <label>
        <input type="text" name="last_name" value="{{%model.last_name}}" autocomplete="off" placeholder="{{=last_name_placeholder}}" required="true" class="blueprint" />
      </label>
    </section>
    
    <label>
      <textarea name="occupation" rows="2" class="blueprint" placeholder="{{=occupation_placeholder}}">{{%model.occupation}}</textarea>
    </label>
    
    <nav class="buttons">
      {{can_delete}}
        <a href="#" class="blueprint-button alert" data-behaviour="delete">
          <i class="fa fa-times"></i>
          {{=delete_button_title}}
        </a>
      {{/can_delete}}
      
      <div class="spacer"></div>
      
      <button class="blueprint">
        <i class="fa fa-check"></i>
        {{=submit_button_title}}
      </button>
    </nav>
  </form>
"""


templates =
  Person: new t $.trim person_template


form_options =
  Person:
    first_name_placeholder: 'Name'
    last_name_placeholder:  'Surname'
    occupation_placeholder: 'Occupation'
    delete_button_title:    'Delete'
    


class PersonFormView
  
  open: (model) ->
    return if @rendered
    
    self      = @
    @model    = model
    view      = templates[@model.constructor.name].render _.extend {}, form_options[@model.constructor.name],
      model:                  @model
      can_delete:             @model.is_exist()
      submit_button_title:    if @model.is_exist() then 'Update' else 'Create'
    
    cc.ui.modal view,
      after_show: ->
        self.on()

      after_close: ->
        self.off()
        self.close()

    @rendered = true
  

  on: ->
    @$form    = $('.modal-container form')
    model     = @model

    # Form submit
    #
    @$form.on 'submit', (event) =>
      event.preventDefault()

      attributes          = _.reduce @$form.serializeArray(), ((memo, entry) -> memo[entry.name] = entry.value ; memo), {}
      required_attributes = _.map @$form.get(0).querySelectorAll('[required]'), 'name'
      
      return if _.any(required_attributes, (name) -> !attributes[name])
      
      model_is_exist = model.is_exist()
      
      cc.blueprint.dispatcher.sync ->
        if model_is_exist
          model.update(attributes)
        else
          model.constructor.create(attributes)
      
      @off()
      cc.ui.modal.close()
    

    # Delete button click
    #
    @$form.on 'click', 'a[data-behaviour~="delete"]', (event) =>
      event.preventDefault()

      cc.blueprint.dispatcher.sync -> model.destroy()
      
      @off()
      cc.ui.modal.close()
  
  
  off: ->
    @$form.remove()


  close: ->
    @rendered = false
    delete @model


#
#
#


_.extend cc.blueprint.views,
  PersonForm: new PersonFormView
