json.company ams(@company, scope: current_user)
json.users ams(@company.users)
json.roles ams(@company.roles)

json.invitable_roles Company::INVITABLE_ROLES
json.invitable_contacts @invitable_contacts
