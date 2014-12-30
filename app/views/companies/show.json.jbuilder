json.company ams(@company, scope: current_user)
json.blocks ams(@company.blocks)
json.vacancies ams(@company.vacancies)
json.people ams(@company.people)
json.pictures ams(@company.pictures)
json.paragraphs ams(@company.paragraphs)
json.stories ams(@stories, scope: @company)
json.tags @tags
