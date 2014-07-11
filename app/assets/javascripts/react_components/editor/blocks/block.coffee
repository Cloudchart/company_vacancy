# Expose
#
tag = React.DOM


# Default block component
#
DefaultBlockComponent = React.createClass

  render: ->
    (tag.div { className: 'default' }, @props.identity_type)


# Block component
#
Component = React.createClass


  onDeleteButtonClick: (event) ->
    @props.onDelete({ target: { value: @props.key, url: @props.url }}) if @props.onDelete instanceof Function


  render: ->
    blockComponentClass = switch @props.identity_type
      when 'Paragraph'  then cc.react.editor.blocks.Paragraph
      when 'BlockImage' then cc.react.editor.blocks.BlockImage
      when 'Person'     then cc.react.editor.blocks.People
      when 'Vacancy'    then cc.react.editor.blocks.Vacancies
      else DefaultBlockComponent
    
    (tag.div { className: 'section-block' },
      
      (tag.i {
        className:  'fa fa-trash-o delete'
        onClick:    @onDeleteButtonClick
      }) unless @props.is_locked

      @transferPropsTo(blockComponentClass {})
    )


# Expose
#
cc.react.editor.blocks.Main = Component
