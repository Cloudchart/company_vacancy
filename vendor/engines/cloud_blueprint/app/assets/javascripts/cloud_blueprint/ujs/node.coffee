NodeModel = null

spinner = '<div class="lock"><i class="fa fa-spinner fa-spin"></i></div>'
  
# Activate node form submit
#
activate_form_submit = ->
  form_selector = '.modal-container form.node'
  field_re      = /node\[([^\]]*)\]/
    
  $(document).on 'submit', form_selector, (event) ->
    event.preventDefault()

    attributes = _.reduce $(@).serializeArray(), (memo, entry) ->
      memo[match[1]] = entry.value if match = entry.name.match(field_re) ; memo
    , {}
    
    model = NodeModel.get(@dataset.id)
    
    if model then model.update(attributes) else NodeModel.create(attributes)
    cc.ui.modal.close()


# Observe node form color index change
#


# Activate node delete link
#
activate_form_delete_link = ->
  link_selector = '.modal-container form.node a[data-behaviour~="delete"]'
  
  $(document).on 'click', link_selector, (event) ->
    event.preventDefault()

    NodeModel.get(@dataset.id).destroy()
    cc.ui.modal.close()
    
    

# Activate click on node
#
activate_click = ->
  activate_form_submit()
  activate_form_delete_link()
  activate_node_form_color_index_change()
  
  $container    = $('section.chart')
  node_selector = 'div.node'
  
  $container.on 'click', node_selector, (event) ->
    event.preventDefault()
    event.stopPropagation()
    
    cc.ui.modal(spinner, { locked: true })
    form = NodeModel.edit_form(@dataset.id)
      
    form.done (template) ->
      cc.ui.modal(template)
    
    form.fail ->
      cc.ui.modal.close()
      alert('fail')
  


_.extend cc.blueprint.common,
  activate_node_click: activate_click


$ ->
  NodeModel = cc.blueprint.models.Node
