# Expose
#
tag = React.DOM


# Main component
#
# Properties:
#   sections:         all sections to render
#   sections_titles:  object sections titles
#   blocks:           all existing blocks
#   url:              url for ajax requests
#   object:           object key for ajax requests
#
MainComponent = React.createClass


  render: ->
    sectionsComponents = @props.sections.map (section) =>
      cc.react.editor.Section
        key:          section.key
        placeholder:  section.title
        title:        @props.sections_titles[section.key]
        url:          @props.url
        owner:        @props.owner
        blocks:       @props.blocks.filter((block) -> block.section == section.key)
    
    (tag.article { className: 'editor' },
      (sectionsComponents)
    )


# Expose
#
@cc.react.editor.Main = MainComponent
