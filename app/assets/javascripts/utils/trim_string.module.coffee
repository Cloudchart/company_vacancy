trimString = (string, regExp) ->
  if (match = string.match(regExp))
    string.slice(0, string.length - match[0].length)
  else
    string


module.exports = {
  trimDots: (string) -> trimString(string, /[\.|;|,]$/)
  trimBreak: (string) -> trimString(string, /<br \/>$/)
}