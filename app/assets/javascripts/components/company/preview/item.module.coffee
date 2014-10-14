###
  Used in:
  components/company/preview/list
###

tag = React.DOM

Logo = require('components/company/logo')

MainComponent = React.createClass

  render: ->  
    company = @props.company

    if company
      tag.article { className: "company-preview" },
        tag.a null,
          tag.header null,
            Logo {
              avatarURL: company.logotype_url
              value: company.name
            }
          tag.section { className: "middle" },
            tag.div { className: "left" },
              tag.div { className: "name" }, company.name
              tag.div { className: "description" }, company.description
            tag.div { className: "right" },
              tag.div { className: "size" },
                company.meta.people_count
                tag.i { className: "fa fa-male" }
              tag.div { className: "burn-rate" },
                "$300K"
                tag.span { className: "units" }, "month"
          tag.section { className: "bottom" },
            tag.p null, company.meta.tags.join(', ')
          
    else
      (tag.noscript null)


module.exports = MainComponent
