percentage_re = /^[0-9]+([\.\,][0-9]+){0,1}$/


# Main
#
validate = (value, options = {}) ->
  acceptsBlank  = options.acceptsBlank  || true
  minValue      = options.minValue      || -Infinity
  maxValue      = options.maxValue      || +Infinity
  parsedValue   = parseFloat(value)     || null
  
  valueIsValid  = (percentage_re.test(value) and parsedValue >= minValue and parsedValue <= maxValue) or (value.length == 0 and acceptsBlank)
  
  parsedValue:  parsedValue
  valueIsValid: valueIsValid


# Exports
#
module.exports = validate
