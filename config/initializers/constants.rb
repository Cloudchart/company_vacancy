module Cloudchart
  ROLES = [:admin, :editor, :unicorn, :trustee, :inviter].freeze

  COMPANY_INVITABLE_ROLES = [:editor, :trusted_reader, :public_reader].freeze
  COMPANY_ROLES = ([:owner] + COMPANY_INVITABLE_ROLES).freeze

  PINBOARD_INVITABLE_ROLES = [:editor, :contributor, :reader].freeze

  POPULAR_PINBOARDS = {
    followers_count: 4,
    pinboards_count: 100
  }

  RAILS_ADMIN_INCLUDED_MODELS = %w(
    Company Feature User Token Page Tag Interview Story Pinboard
    Role Pin GuestSubscription Domain Post Paragraph
  )

  BROWSERS_WHITELIST = [
    OpenStruct.new(browser: 'Android', version: '4.4'),
    OpenStruct.new(browser: 'Chrome', version: '21.0'),
    OpenStruct.new(browser: 'Safari', version: '7.1'),
    OpenStruct.new(browser: 'Firefox', version: '28.0'),
    OpenStruct.new(browser: 'Opera', version: '12.1'),
    OpenStruct.new(browser: 'Internet Explorer', version: '11.0')
  ]

  WORDS_PER_MINUTE = 200

  INSTANT_NOTIFICATIONS_TIC = 15 # minutes
  INSTANT_NOTIFICATIONS_MAX_DELAY = 60 # minutes

end
