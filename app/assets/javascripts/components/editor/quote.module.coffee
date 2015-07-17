# @cjsx React.DOM

GlobalState         = require('global_state/state')

QuoteStore          = require('stores/quote_store')

ContentEditableArea = require('components/form/contenteditable_area')
Person              = require('components/editor/person')
PersonPlaceholder   = require('components/editor/person_placeholder')

getText = (quote) ->
  (quote && quote.get("text")) || ''

getPersonId = (quote) ->
  (quote && quote.get("person_id")) || null


Quote = React.createClass

  mixins: [GlobalState.mixin]

  statics:
    isEmpty: (block_id) ->
      quote = QuoteStore.findByBlock(block_id)

      !getText(quote) && !getPersonId(quote)


  # Component specifications
  #
  propTypes:
    readOnly:    React.PropTypes.bool
    uuid:        React.PropTypes.string.isRequired

  getDefaultProps: ->
    cursor:   QuoteStore.cursor.items
    readOnly: false
  
  getInitialState: ->
    @getStateFromStores()

  onGlobalStateChange: ->
    @setState @getStateFromStores()

  getStateFromStores: ->
    quote: QuoteStore.findByBlock(@props.uuid)


  # Helpers
  #
  updateOrCreateQuote: (params) ->
    if @state.quote
      QuoteStore.update(@state.quote.get("uuid"), params)
    else
      QuoteStore.create(_.extend(block_id: @props.uuid, params))

  getSeq: (person_id) ->
    if person_id then Immutable.Seq([person_id]) else Immutable.Seq([])

  addCommas: (quote) ->
    quote = quote.trim().replace(/^(<div><br \/><\/div>)+|(<div><br \/><\/div>)+$/g, '')
    parts = quote.match(/(<div>.*?<\/div>)+?/ig)

    return quote unless parts

    parts = parts.map (part) -> part.replace(/^<div>|<\/div>$/ig, '')

    [first, ..., last] = parts

    if first[0] != "“" && last[last.length - 1] != "”"
      parts[0] = "“" + parts[0]
      parts[parts.length-1] += "”"
      "<div>" + parts.join("</div><div>") + "</div>"
    else
      quote


  # Handlers
  #
  handleTextChange: (text) ->
    return if @props.readOnly

    text = @addCommas(text)
    @updateOrCreateQuote(text: text)

  handlePersonSelect: (person_id) ->
    return if @props.readOnly

    @updateOrCreateQuote(person_id: person_id)

  handlePersonDelete: ->
    return if @props.readOnly

    @updateOrCreateQuote(person_id: null)


  # Renderers
  #
  renderPerson: ->
    if getPersonId(@state.quote)
      <Person
        company_id  = { @props.company_id }
        onDelete    = { @handlePersonDelete }
        uuid        = { getPersonId(@state.quote) }
        readOnly    = { @props.readOnly }
      />
    else if !@props.readOnly
      <PersonPlaceholder 
        company_id  = { @props.company_id }
        onSelect    = { @handlePersonSelect }
        selected    = { @getSeq(getPersonId(@state.quote)) }
      />


  render: ->
    # TODO need to get rid of excessive block classes

    <div className="quote-wrapper">
      { @renderPerson() }
      <ContentEditableArea
        onChange    = { @handleTextChange }
        placeholder = "Add a quote here. Short, twitter-style."
        readOnly    = { @props.readOnly }
        value       = { getText(@state.quote) }
      />
    </div>


# Exports
#
module.exports = Quote
