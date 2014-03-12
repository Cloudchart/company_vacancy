if current_user.present?
  { redirect: root_path }
else
  { error: t(:user_not_found, scope: :passport) }
end.to_json
