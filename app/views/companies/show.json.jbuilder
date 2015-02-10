tags = Tag.available_for_user(current_user)

json.company ams(@company, scope: current_user)
json.blocks ams(@company.blocks)
json.vacancies ams(@company.vacancies)
json.pictures ams(@company.pictures)
json.paragraphs ams(@company.paragraphs)
json.tags tags

json.people @company.people do |person|
  json.partial! 'person', person: person
end
