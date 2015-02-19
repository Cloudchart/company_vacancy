# @cjsx React.DOM


# Stores
#
PinStore    = require('stores/pin_store')
PostStore   = require('stores/post_store.cursor')


# Components
#
PinnablePostCompanyHeader = require('components/pinnable/header/post_company')


# Exports
#
module.exports = React.createClass


  displayName: 'Header'


  renderPostHeader: (pin) ->
    post = PostStore.cursor.items.get(pin.get('pinnable_id'))

    switch post.get('owner_type')

      when 'Company'
        <PinnablePostCompanyHeader uuid={ post.get('owner_id') } pin={ pin } />

      else
        throw new Error("Pinnable Header: Unkbown owner type '#{post.get('owner_type')}' for pinnable type 'Post'")



  renderPinnableHeader: ->
    pin = PinStore.cursor.items.get(@props.uuid)

    switch pin.get('pinnable_type')

      when 'Post'
        @renderPostHeader(pin)

      else
        throw new Error("Pinnable Header: Unknown pinnable type '#{pin.get('pinnable_type')}'")



  render: ->
    @renderPinnableHeader()
