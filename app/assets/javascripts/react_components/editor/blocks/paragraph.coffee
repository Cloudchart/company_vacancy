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
saveParagraph = (uuid, paragraph, content, done_callback, fail_callback) ->
  $.ajax
    url:        "/blocks/#{uuid}"
    type:       "PUT"
    dataType:   "json"
    data:       if content.length > 0 then paramsForCreateOrUpdate(paragraph, content) else paramsForDelete()
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


  getInitialState: ->
    identity:       @props.identities[0] || {}
    synchronizing:  false
  
  
  onSaveComplete: (json) ->
    @setState
      identity:       json.identities[0] || {}
      synchronizing:  false
  

  onSaveFailure: ->
    @setState { synchronizing: false }
  
  
  onChange: (event) ->
    @setState { synchronizing: true }
    saveParagraph(@props.uuid, @state.identity, event.target.value, @onSaveComplete, @onSaveFailure)
    

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
