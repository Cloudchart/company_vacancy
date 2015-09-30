DeviceTokenSyncApi = require('sync/device_token_sync_api')

Constants = require('constants')

module.exports =

  checkRemotePermission: (permissionData) ->
    if permissionData.permission == 'default'
      # This is a new web service URL and its validity is unknown.
      window.safari.pushNotification.requestPermission(
        Constants.ZERO_PUSH_URL,
        Constants.WEBSITE_PUSH_ID,
        {},
        @checkRemotePermission
      )
    else if permissionData.permission == 'denied'
      # The user said no. Talk to your UX expert to see what you can do to entice your
      # users to subscribe to push notifications.

    else if permissionData.permission == 'granted'
      # The web service URL is a valid push provider, and the user said yes.
      # permissionData.deviceToken is now available to use.
      DeviceTokenSyncApi.create(value: permissionData.deviceToken)

  requestSafariPush: ->
    # Ensure that the user can receive Safari Push Notifications.
    if 'safari' of window and 'pushNotification' of window.safari
      permissionData = window.safari.pushNotification.permission(Constants.WEBSITE_PUSH_ID)
      @checkRemotePermission(permissionData)
    else
      # A good time to let a user know they are missing out on a feature or just bail out completely?
