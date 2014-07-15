##= require react_components/company/header
##= require react_components/editor

#
#
tag             = cc.require('react/dom')
HeaderComponent = cc.require('react/company/header')
EditorComponent = cc.require('react/editor')


# Company Main component
#
MainComponent = React.createClass

  render: ->
    (tag.article { className: 'company' },
      (HeaderComponent @props)

      (EditorComponent {
        sections:               @props.available_sections
        sections_titles:        @props.sections
        available_block_types:  @props.available_block_types
        blocks:                 @props.blocks
        url:                    @props.url
        blocks_url:             @props.blocks_url
        people_url:             @props.people_url
        vacancies_url:          @props.vacancies_url
        owner:                  'company'
      })
    )


# Expose
#
cc.module('react/company').exports = MainComponent