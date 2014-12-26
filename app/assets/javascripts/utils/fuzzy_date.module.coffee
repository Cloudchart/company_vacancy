module.exports =
  
  format: (from, till, notSetValue) ->
    from = moment(from)
    till = moment(till)
    
    if from.isValid()
      return from.format('MMM DD, YYYY')  if from.isSame(till, 'day')
      return from.format('MMM, YYYY')     if from.isSame(till, 'month')
      return from.format('YYYY')          if from.isSame(till, 'year')
    
    notSetValue
