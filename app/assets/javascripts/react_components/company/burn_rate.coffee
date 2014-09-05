##= require components/Person
##= require stores/PersonStore

# Imports
# 
tag = React.DOM

PersonStore = cc.require('cc.stores.PersonStore')
PersonComponent = cc.require('cc.components.Person')

# Main Component
# 
MainComponent = React.createClass

  # Component Specifications
  # 
  render: ->
    (tag.article { className: 'editor burn-rate' },
      (tag.table {},
        (tag.thead {},
          (tag.tr {},
            (tag.th {})
            (tag.th {}, moment(@monthShiftedTime(-3)).format('MMM YY'))
            (tag.th {}, moment(@monthShiftedTime(-2)).format('MMM YY'))
            (tag.th {}, moment(@monthShiftedTime(-1)).format('MMM YY'))
            (tag.th {}, moment().format('MMM YY'))
          )
        )
        (tag.tbody {},
          @gatherPeople()
          (tag.tr {},
            (tag.td {},
              (tag.strong {}, 'Total')
            )
            (tag.td {})
            (tag.td {})
            (tag.td {})
            (tag.td {})
          )
        )
      )
    )

  # getInitialState: ->
  # getDefaultProps: ->

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  # componentDidMount: ->
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  # componentDidUpdate: (prevProps, prevState) ->
  # componentWillUnmount: ->

  # Instance Methods
  # 
  gatherPeople: ->
    people = _.chain(PersonStore.all())
      .sortBy (person) -> person.sortValue()
      .value()

    _.map people, (person) =>
      (tag.tr { key: person.to_param() },
        (tag.td {}, person.attr('full_name'))
        (tag.td {}, @showSalary(person, -3))
        (tag.td {}, @showSalary(person, -2))
        (tag.td {}, @showSalary(person, -1))
        (tag.td {}, @showSalary(person))
      )

  showSalary: (person, offset=0) ->
    if person.attr('hired_on') and 
      new Date(person.attr('hired_on')).getTime() < @monthShiftedTime(offset) and
      (!person.attr('fired_on') or new Date(person.attr('fired_on')).getTime() > @monthShiftedTime(offset))

        person.attr('salary')

  monthShiftedTime: (offset) ->
    current_date = new Date
    current_month = current_date.getMonth()

    current_date.setMonth(current_month + offset)

  # Events
  # 
  # onThingClick: ->

# Exports
# 
cc.module('react/company/burn_rate').exports = MainComponent
