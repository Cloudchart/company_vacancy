# @cjsx React.DOM


BlockComponents = 
  Paragraph:  require('components/pinnable/block/paragraph')
  Picture:    require('components/pinnable/block/picture')
  Person:     require('components/pinnable/block/people')


# Exports
#
module.exports = React.createClass

  render: ->
    component = BlockComponents[@props.cursor.get('identity_type')]
    
    if component
      component({ uuid: @props.uuid, className: @props.cursor.get('kind') || undefined })
    else
      <div>
        { @props.cursor.get('identity_type') }
      </div>
