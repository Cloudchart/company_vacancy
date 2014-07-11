##= require module

search = (placeholders, key) ->
  scopes = key.split('.').reduce (memo, part) ->
    return memo unless memo[0] if memo.length > 0
    memo.unshift if memo.length > 0 then memo[0][part] else placeholders[part]
    memo
  , []
  scopes[0]


placeholder = (path, key, defaults = []) ->
  placeholders  = cc.require(path) ; defaults.unshift(key)
  value         = undefined
  
  defaults.forEach((scope) -> return if value ; value = search(placeholders, scope))

  #scopes = key.split('.').reduce (memo, part) ->
  #  return memo unless memo[0] if memo.length > 0
  #  memo.unshift if memo.length > 0 then memo[0][part] else placeholders[part]
  #  memo
  #, []
  
  #value = scopes[0]
  #scopes.forEach((scope) -> return if value ; return unless scope ; value = scope.default)
  value

cc.module('placeholder').exports = placeholder
