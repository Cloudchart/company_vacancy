# Exports
#
module.exports = -> blobURL = URL.createObjectURL(new Blob) ; URL.revokeObjectURL(blobURL) ; blobURL.split('/').pop()
