default_person_template = ->
  ""

default_vacancy_template = ->
  ""

#
#
#

class PeopleVacanciesFilter

  constructor: (container, options = {}) -> 
    @$container       = $(container) ; throw "Container not found for #{@constructor.name}" unless @$container.length

    @person_template  = options.person_template   || default_person_template()
    @vacancy_template = options.vacancy_template  || default_vacancy_template()
  

  render: ->
    self = @

    @$container.empty()
    
    people = cc.blueprint.models.Person.instances
    
    console.log _.size(people)

    _.chain(people)
      .sortBy(['first_name', 'last_name'])
      .each((person) -> self.$container.append(self.person_template.render(person)))


#
#
#

_.extend cc.blueprint.views,
  PeopleVacanciesFilter: PeopleVacanciesFilter
