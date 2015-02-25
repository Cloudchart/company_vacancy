# Exports
#
module.exports =

  cursors:
    search: ['meta', 'search']

  Company:
    COMPANY_FETCH_DONE:   'company:fetch:done'
    COMPANY_FETCH_FAIL:   'company:fetch:fail'
    
    UPDATE:       'company:update'
    UPDATE_DONE:  'company:update:done'
    UPDATE_FAIL:  'company:update:fail'
    
    FETCH_INVITE_TOKENS:        'company:invite_tokens:fetch'
    FETCH_INVITE_TOKENS_DONE:   'company:invite_tokens:fetch:done'
    FETCH_INVITE_TOKENS_FAIL:   'company:invite_tokens:fetch:fail'
  
    FOLLOW:        'company:follow'
    FOLLOW_DONE:   'company:follow:done'
    FOLLOW_FAIL:   'company:follow:fail'
  
    UNFOLLOW:        'company:unfollow'
    UNFOLLOW_DONE:   'company:unfollow:done'
    UNFOLLOW_FAIL:   'company:unfollow:fail'

    VERIFY_SITE_URL:       'company:verify_site_url'
    VERIFY_SITE_URL_DONE:  'company:verify_site_url:done'
    VERIFY_SITE_URL_FAIL:  'company:verify_site_url:fail'
    

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


  Role:
    CREATE:       'role:create'
    CREATE_DONE:  'role:create:done'
    CREATE_FAIL:  'role:create:fail'

    UPDATE:       'role:update'
    UPDATE_DONE:  'role:update:done'
    UPDATE_FAIL:  'role:update:fail'

    DELETE:       'role:delete'
    DELETE_DONE:  'role:delete:done'
    DELETE_FAIL:  'role:delete:fail'
