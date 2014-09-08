##= require components/Person

# Imports
# 
tag = React.DOM

PersonComponent = cc.require('cc.components.Person')

# Main Component
# 
MainComponent = React.createClass

  # Component Specifications
  # 
  render: ->
    (tag.article { key: 'burn-rate-article', className: 'editor burn-rate' },

      (tag.table {},
        (tag.thead {},
          (tag.tr {},
            (tag.th {})
            (tag.th {}, 
              (tag.a { href: '#' },
                (tag.i { className: 'fa fa-chevron-left' })
              )              
              moment(@monthShiftedTime(-3)).format('MMM YY')
            )
            (tag.th {}, moment(@monthShiftedTime(-2)).format('MMM YY'))
            (tag.th {}, moment(@monthShiftedTime(-1)).format('MMM YY'))
            (tag.th { className: 'current-month' },
              moment().format('MMM YY')
              (tag.a { href: '#' },
                (tag.i { className: 'fa fa-chevron-right' })
              )
            )
          )
        )
        (tag.tbody {},
          @gatherPeople()
          (tag.tr { className: 'total' },
            (tag.td {}, 'Total')
            (tag.td { className: 'total', offset: '-3' })
            (tag.td { className: 'total', offset: '-2' })
            (tag.td { className: 'total', offset: '-1' })
            (tag.td { className: 'total', offset: 'current' })
          )
        )
      )
    )

  # getInitialState: ->
  # getDefaultProps: ->

  # Lifecycle Methods
  # 
  # componentWillMount: ->
  componentDidMount: ->
    @showTotal()
    
  # componentWillReceiveProps: (nextProps) ->
  # shouldComponentUpdate: (nextProps, nextState) ->
  # componentWillUpdate: (nextProps, nextState) ->
  componentDidUpdate: (prevProps, prevState) ->
    @showTotal()

  # componentWillUnmount: ->

  # Instance Methods
  # 
  gatherPeople: ->
    people = _.chain(@props.people)
      .sortBy (person) -> person.sortValue()
      .value()

    _.map people, (person) =>
      (tag.tr { key: person.to_param() },
        (tag.td { className: 'name' }, PersonComponent({ key: person.to_param() }))
        (tag.td { className: 'data month--3' }, @showSalary(person, -3))
        (tag.td { className: 'data month--2' }, @showSalary(person, -2))
        (tag.td { className: 'data month--1' }, @showSalary(person, -1))
        (tag.td { className: 'data month-current' }, @showSalary(person))
      )

  showSalary: (person, offset=0) ->
    if person.attr('hired_on') and 
      new Date(person.attr('hired_on')).getTime() < @monthShiftedTime(offset) and
      (!person.attr('fired_on') or new Date(person.attr('fired_on')).getTime() > @monthShiftedTime(offset))

        parseInt(person.attr('salary'))
        # TODO: add formatting – .toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",")

  monthShiftedTime: (offset) ->
    current_date = new Date
    current_month = current_date.getMonth()

    current_date.setMonth(current_month + offset)

  showTotal: ->
    _.forEach document.body.querySelectorAll('td.total'), (element) =>
      element.innerHTML = @calculateTotal(element.getAttribute('offset'))

  calculateTotal: (offset) ->
    sum = 0

    _.forEach document.body.querySelectorAll("td.data.month-#{offset}"), (element) ->
      sum += parseFloat(element.innerHTML) unless element.innerHTML.length == 0 or isNaN(element.innerHTML)

    sum

  # Events
  # 
  # onThingClick: ->

# Exports
# 
cc.module('react/company/burn_rate').exports = MainComponent
