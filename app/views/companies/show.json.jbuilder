json.company ams(@company, scope: current_user)
json.blocks ams(@company.blocks)
json.vacancies ams(@company.vacancies)
json.people ams(@company.people)
json.pictures ams(@company.pictures)
json.paragraphs ams(@company.paragraphs)
json.tags @tags

if can?(:manage_company_invites, @company)
  json.users ams(@company.users)
  json.roles ams(@company.roles)
  json.tokens ams(@company.invite_tokens)
end
