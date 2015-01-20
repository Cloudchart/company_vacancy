json.(company, :uuid, :name, :description)
json.(company, :established_on)
json.(company, :is_published, :site_url, :slug)

json.logotype_url company.logotype.url if company.logotype_stored?
