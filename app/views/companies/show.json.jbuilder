# base
# 
json.company ams(@company, scope: current_user)
json.blocks ams(@company.blocks)
json.vacancies ams(@company.vacancies)
json.people ams(@company.people)
json.pictures ams(@company.pictures)
json.paragraphs ams(@company.paragraphs)
json.posts ams(@company.posts)

# invites
# 
if can?(:manage_company_invites, @company)
  json.users ams(@company.users.includes(:emails))
  json.roles ams(@company.roles)
  json.tokens ams(@company.invite_tokens)
end
