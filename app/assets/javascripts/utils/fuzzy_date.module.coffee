module.exports =
  
  format: (from, till, notSetValue) ->
    from = moment(from)
    till = moment(till)
    
    if from.isValid()
      if from.isSame(till)
        from.format('MMM DD, YYYY')
      else
        from.format('MMM, YYYY')
    else
      notSetValue