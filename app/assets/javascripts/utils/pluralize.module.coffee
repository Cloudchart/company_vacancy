module.exports = (count, singular, plural) ->
  if count == 1
    "#{count} #{singular}"
  else
    "#{count} #{plural}"