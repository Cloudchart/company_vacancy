ownerPath =
  Company: 'companies'
  Post: 'posts'

module.exports =

  createBlock: (key, attributes, done, fail) ->
    $.ajax
      url:        "/#{ownerPath[attributes.owner_type]}/#{key}/blocks"
      type:       "POST"
      dataType:   "json"
      data:
        block:    attributes
    .done done
    .fail fail
