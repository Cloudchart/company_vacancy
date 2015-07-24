React     = require('react')
GraphQL   = require('graphql')
Schema    = require('../../schema/schema')

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
              insights {
                id
                content
                pinboard {
                  title
                }
              }
            }
          }
        """


  componentWillMount: ->
    query = @constructor.queries.pin().replace(/\s+/g, ' ').trim()
    [_, endpoint, body] = RE.exec(query)
    query = "query get#{endpoint}($id: String!) { #{endpoint}(id: $id) #{body} }"
    GraphQL.graphql(Schema, query, null, { id: '00243f1e-ee3c-4d8b-b681-3838f974f44d' }).then (json) =>
      console.log JSON.stringify json, null, 2
      @setState
        pin: json.data.Pin


  getInitialState: ->
    pin: null


  render: ->
    return null #unless @state.pin
    <section className="cloud-card pin-card">
      <span>{ @state.pin.content }</span>
      <span> &mdash; </span>
      <a href={ @state.pin.user.url }>{ @state.pin.user.full_name }</a>
    </section>


# Exports
#
module.exports = Component
