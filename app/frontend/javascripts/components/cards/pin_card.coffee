React     = require('react')
Store     = require('../../relay/store')

RE = /^([_a-zA-Z][_a-zA-Z0-9]+)\s(\{.+\})$/

# Component
#
Component = React.createClass

  displayName: "PinCard"


  statics:
    queries:
      pin: ->
        """
          Pin {
            id
            content
            user {
              full_name
              avatar {
                url
              }
              pinboards {
                title
                pins(on: "#{new Date}") {
                  content
                  created_at
                }
              }
            }
          }
        """


  componentWillMount: ->
    @stream = Store.get(@constructor.queries.pin(), { id: '00243f1e-ee3c-4d8b-b681-3838f974f44d' })


  componentWillUnmount: ->
    @stream.end()


  getInitialState: ->
    pin: null


  render: ->
    return null
    <section className="cloud-card pin-card">
      <span>{ @state.pin.content }</span>
      <span> &mdash; </span>
      <a href={ @state.pin.user.url }>{ @state.pin.user.full_name }</a>
    </section>


# Exports
#
module.exports = Component
