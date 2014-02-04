class VacancySetting
  include Settingable

  DISPLAY_LINK_OPTIONS = %i(nowhere company everywhere).inject({}) { |hash, val| hash.merge({ I18n.t("vacancy_setting.display_link_options.#{val}") => val }) }
  ACCESSIBLE_TO_OPTIONS = %i(only_me company company_plus_one_share everyone).inject({}) { |hash, val| hash.merge({ I18n.t("vacancy_setting.accessible_to_options.#{val}") => val }) }

  columns :display_link, :accessible_to, publish_on: :date, incentive: :integer

end
