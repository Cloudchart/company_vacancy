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
        key:            section.key
        placeholder:    section.title
        title:          @props.sections_titles[section.key]
        url:            @props.url
        people_url:     @props.people_url
        vacancies_url:  @props.vacancies_url
        blocks_url:     @props.blocks_url
        owner:          @props.owner
        blocks:         @props.blocks.filter((block) -> block.section == section.key)
    
    (tag.article { className: 'editor' },
      (cc.react.editor.SidebarComponent { blocks: @props.available_block_types })
      (sectionsComponents)
    )


# Expose
#
#@cc.react.editor.Main = MainComponent
@cc.module('react/editor').exports = MainComponent
