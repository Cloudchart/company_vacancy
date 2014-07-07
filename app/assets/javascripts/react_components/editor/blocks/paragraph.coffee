# Expose tags
#
tag = React.DOM


# Placeholders
#
placeholders =

  about:
    0: "Tell a short story about your company — what does your company do and why it's important. Be brief, be clear, be straightforward. At about 70 words / 500 characters we'll crub your enthusiasm."

  product:
    0: "Tell us about your product or service. If you have several, add your bestseller or the one you're most proud of — you can add others later. About 70 words is enough."

  people:
    1: "Describe your team. Put forward the greatest and the brightest. Make sure they star prominently in your company chart. Up to 6 people should be enough for everyone."

  default: "Default placeholder"


placeholder = (section, position) ->
  placeholders[section]?[position] || placeholders[section]?.default || placeholders.default


# Params for create or update
#
paramsForCreateOrUpdate = (paragraph, content) ->
  block:
    paragraphs_attributes: [
      id:       paragraph.uuid
      content:  content
    ]


# Params for delete
#
paramsForDelete = ->
  block:
    identity_ids: ['']


# Save paragraph
#
saveParagraph = (paragraph, content, done_callback, fail_callback) ->

  type = if !paragraph.uuid
    if content then 'POST' else null
  else
    if content then 'PUT' else 'DELETE'

  return done_callback(paragraph) if type == null
  
  data = new FormData
  data.append("block_identity[identity_attributes][content]", content)
  
  $.ajax
    url:          paragraph.url
    type:         type
    data:         data
    dataType:     'json'
    contentType:  false
    processData:  false
  .done done_callback
  .fail fail_callback


# Lock component
#
LockComponent = React.createClass

  render: ->
    (tag.i { className: 'fa fa-lock lock' })

  
# Paragraph Block component
#

Component = React.createClass

  
  emptyIdentity: ->
    url: @props.url + '/identities'


  getInitialState: ->
    identity:       @props.identities[0] || @emptyIdentity()
    synchronizing:  false
  
  
  onSaveComplete: (json) ->
    @setState
      identity:       json || @emptyIdentity()
      synchronizing:  false
  

  onSaveFailure: ->
    @setState { synchronizing: false }
  
  
  onChange: (event) ->
    return if (@state.identity.content || "") == event.target.value
    @setState { synchronizing: true }
    saveParagraph(@state.identity, event.target.value, @onSaveComplete, @onSaveFailure)
    

  render: ->
    (tag.div { className: 'paragraph' },
      (LockComponent {}) if @state.synchronizing
      (cc.react.editor.ContentEditableComponent {
        active:      !@state.synchronizing
        value:        @state.identity.content
        placeholder:  placeholder(@props.section, @props.position)
        onChange:     @onChange
      })
    )


# Expose
#
cc.react.editor.blocks.Paragraph = Component
