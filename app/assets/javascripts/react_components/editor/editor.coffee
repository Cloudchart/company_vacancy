##= require cloud_blueprint/react/chart_preview
##= require ../company/profile
##= require ../company/owners

# Expose
#
tag = React.DOM

ChartPreviewComponent   = cc.require('blueprint/react/chart-preview')
CompanyProfileComponent = cc.require('react/company/profile')
CompanyOwnersComponent  = cc.require('react/company/owners')

# Main component
#
MainComponent = React.createClass

  render: ->
    sectionsComponents = @props.available_sections.map (section) =>
      cc.react.editor.Section
        key:            section.key
        placeholder:    section.title
        title:          @props.sections[section.key]
        company_url:    @props.company_url
        people_url:     @props.people_url
        vacancies_url:  @props.vacancies_url
        blocks_url:     @props.blocks_url
        owner:          @props.owner
        blocks:         @props.blocks.filter((block) -> block.section == section.key)
    
    sectionsComponents.splice(1, 0, CompanyProfileComponent({
      key: 'profile'
      company_uuid: @props.uuid
      company_url: @props.company_url
      country: @props.country
      industry_ids: @props.industry_ids
      is_listed: @props.is_listed
      short_name: @props.short_name
      default_host: @props.default_host
      site_url: @props.site_url
      verify_site_url: @props.verify_site_url
      download_verification_file_url: @props.download_verification_file_url
      is_site_url_verified: @props.is_site_url_verified
    }))

    sectionsComponents.splice(2, 0, CompanyOwnersComponent({
      key: 'owners'
      owners: @props.owners
      owner_invites: @props.owner_invites
    }))
    
    (tag.article { className: 'editor' },
      (cc.react.editor.SidebarComponent { blocks: @props.available_block_types })

      (tag.section {
        className: 'chart-preview-container'
      },
        ChartPreviewComponent
          id: @props.chart_ids[0]
          permalink: @props.chart_permalinks[0]
          company_id: @props.id
          scale: 1
      ) if @props.chart_ids.length > 0

      (sectionsComponents)
    )

# Expose
#
# @cc.react.editor.Main = MainComponent
@cc.module('react/editor').exports = MainComponent
