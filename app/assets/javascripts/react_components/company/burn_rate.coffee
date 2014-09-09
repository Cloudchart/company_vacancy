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
    (tag.div { className: 'burn-rate' },
      (tag.div { className: 'container' },

        (tag.table {},
          (tag.thead {},
            (tag.tr {},
              (tag.th {})

              (tag.th {
                className: @checkCurrentMonth(@monthSubtractedMoment(3))  
              },
                (tag.a { 
                  href: ''
                  className: 'chevron-left'
                  onClick: @onChevronLeftClick 
                },
                  (tag.i { className: 'fa fa-chevron-left' })
                )
                @monthSubtractedMoment(3).format('MMM YY')
              )

              (tag.th {
                className: @checkCurrentMonth(@monthSubtractedMoment(2))
              }, 
                @monthSubtractedMoment(2).format('MMM YY')
              )

              (tag.th { 
                className: @checkCurrentMonth(@monthSubtractedMoment(1))
              }, 
                @monthSubtractedMoment(1).format('MMM YY')
              )

              (tag.th { 
                className: @checkCurrentMonth(moment(@state.selected_time))
              },
                moment(@state.selected_time).format('MMM YY')
                (tag.a { 
                  href: '#'
                  className: 'chevron-right'
                  onClick: @onChevronRightClick
                },
                  (tag.i { className: 'fa fa-chevron-right' })
                )
              )
            )
          )
          (tag.tbody {},
            @gatherPeople()
          )
          (tag.tfoot {},
            (tag.tr {},
              (tag.td {}, 'Total')
              (tag.td { className: 'total', offset: '3' })
              (tag.td { className: 'total', offset: '2' })
              (tag.td { className: 'total', offset: '1' })
              (tag.td { className: 'total', offset: 'selected' })
            )
          )
        )

      )
    )

  getInitialState: ->
    selected_time: moment()._d

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
        (tag.td { className: 'title' }, 
          (tag.div { className: 'name' }, person.attr('full_name'))
          (tag.div { className: 'occupation' }, person.attr('occupation'))
        )
        (tag.td { className: 'data month-3' }, @showSalary(person, 3))
        (tag.td { className: 'data month-2' }, @showSalary(person, 2))
        (tag.td { className: 'data month-1' }, @showSalary(person, 1))
        (tag.td { className: 'data month-selected' }, @showSalary(person))
      )

  showSalary: (person, offset=0) ->
    if person.attr('salary') and (
        (
          person.attr('hired_on') and
          moment(person.attr('hired_on')) < @monthSubtractedMoment(offset) and
          (!person.attr('fired_on') or moment(person.attr('fired_on')) > @monthSubtractedMoment(offset))
        ) or (
          !person.attr('hired_on') and
          !person.attr('fired_on')
        ) or (
          !person.attr('hired_on') and
          person.attr('fired_on') and
          moment(person.attr('fired_on')) > @monthSubtractedMoment(offset)
        )
      )

        numeral(person.attr('salary')).format('0,0')

  monthSubtractedMoment: (offset) ->
    moment(@state.selected_time).subtract(offset, 'months')

  showTotal: ->
    _.forEach document.body.querySelectorAll('td.total'), (element) =>
      element.innerHTML = @calculateTotal(element.getAttribute('offset'))

  calculateTotal: (offset) ->
    sum = 0

    _.forEach document.body.querySelectorAll("td.data.month-#{offset}"), (element) ->
      sum += numeral().unformat(element.innerHTML)

    numeral(sum).format('0,0')

  checkCurrentMonth: (given_moment) ->
    if given_moment.month() == moment().month() and
      given_moment.year() == moment().year()
        'current-month' 

  # Events
  # 
  onChevronLeftClick: (event) ->
    event.preventDefault()
    @setState({ selected_time: moment(@state.selected_time).subtract(1, 'month') })

  onChevronRightClick: (event) ->
    event.preventDefault()
    @setState({ selected_time: moment(@state.selected_time).add(1, 'month') })

# Exports
# 
cc.module('react/company/burn_rate').exports = MainComponent
