generateUUID = -> blobURL = URL.createObjectURL(new Blob) ; URL.revokeObjectURL(blobURL) ; blobURL.split('/').pop()

generateUUID.isUUID = (possibleUUID) ->
  return false unless typeof possibleUUID is 'string'
  !!possibleUUID.match(/^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/gi)

# Exports
#
module.exports = generateUUID
