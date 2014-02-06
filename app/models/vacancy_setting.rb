class VacancySetting
  include ActiveAttr::Model
  include JsonSerializable
  include MultiparametersConvertible

  DISPLAY_LINK_OPTIONS = %i(nowhere company everywhere).inject({}) { |hash, val| hash.merge({ I18n.t("vacancy_setting.display_link_options.#{val}") => val }) }
  ACCESSIBLE_TO_OPTIONS = %i(only_me company company_plus_one_share everyone).inject({}) { |hash, val| hash.merge({ I18n.t("vacancy_setting.accessible_to_options.#{val}") => val }) }

  attribute :publish_on, type: Date
  attribute :display_link
  attribute :accessible_to
  attribute :incentive, type: Integer

  validates :display_link, presence: true

end
