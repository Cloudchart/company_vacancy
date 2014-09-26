# Exports
#
module.exports =
  Company:
    COMPANY_FETCH_DONE:   'company:fetch:done'
    COMPANY_FETCH_FAIL:   'company:fetch:fail'
    
    COMPANY_UPDATE_DONE:  'company:update:done'
    COMPANY_UPDATE_FAIL:  'company:update:fail'
    
    FETCH_INVITE_TOKENS:        'company:invite_tokens:fetch'
    FETCH_INVITE_TOKENS_DONE:   'company:invite_tokens:fetch:done'
    FETCH_INVITE_TOKENS_FAIL:   'company:invite_tokens:fetch:fail'
    
    REVOKE_ROLE:        'company:role:revoke'
    REVOKE_ROLE_DONE:   'company:role:revoke:done'
    REVOKE_ROLE_FAIL:   'company:role:revoke:fail'
  
  
  Token:
    FETCH_DONE:   'token:fetch:done'
    FETCH_FAIL:   'token:fetch:fail'
    
    CREATE:       'token:create'
    CREATE_DONE:  'token:create:done'
    CREATE_FAIL:  'token:create:fail'

    UPDATE:       'token:update'
    UPDATE_DONE:  'token:update:done'
    UPDATE_FAIL:  'token:update:fail'

    DELETE:       'token:delete'
    DELETE_DONE:  'token:delete:done'
    DELETE_FAIL:  'token:delete:fail'
  
  
  Tag:
    FETCH:        'tag:fetch'
    FETCH_DONE:   'tag:fetch:done'
    FETCH_FAIL:   'tag:fetch:fail'
    
    CREATE:       'tag:create'
    CREATE_DONE:  'tag:create:done'
    CREATE_FAIL:  'tag:create:fail'
