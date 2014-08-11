tag = React.DOM

Component = React.createClass

  emptyIndustry: ->
    (tag.option {
      key: 'empty'
    }, 'Industry...')


  items: ->
    roots = _.sortBy @props.industries.filter((industry) -> !industry.parent_id), 'name'

    items = roots.map (industry) =>

      children  = _.sortBy @props.industries.filter((child) -> child.parent_id == industry.uuid), 'name'

      [
        (tag.option {
          key:    industry.uuid
          value:  industry.uuid
        }, industry.name),

        children.map (child) ->
          (tag.option {
            key:    child.id
            value:  child.uuid
          }, "— #{child.name}")
      ]
    
    items.unshift(@emptyIndustry()) unless @state.value

    items
  
  
  onChange: (event) ->
    @setState
      value: event.target.value


  getDefaultProps: ->
    industries: cc.require('industries')


  getInitialState: ->
    value: @props.value
  
  
  componentDidUpdate: (prevProps, prevState) ->
    @props.onChange({ target: { value: @state.value }}) if @props.onChange instanceof Function and @state.value != prevState.value


  render: ->
    (tag.select {
      className: 'industry-select'
      value:      @state.value
      onChange:   @onChange
    }, @items())


# Exports
cc.module('react/company/industry_select').exports = Component
