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
    (tag.article { className: 'company' },
      (tag.div { className: 'wrapper' },
        if @state.selected_chart.people.length > 0
          (tag.header {},
            'Your expenses and revenue according to chart data'
          )
          # (tag.header {},
          #   'Your expenses and revenue according to'
          #   (tag.select {
          #     value: @state.selected_chart.uuid
          #     onChange: @onChartChange
          #   },
          #     _.map @props.charts, (chart) ->
          #       (tag.option { key: chart.uuid, value: chart.uuid }, chart.title)
          #   )
          # )
        else
          (tag.header {},
            'Please set salaries to your employees to see expenses and revenue'
          )

        (tag.div { className: 'content' },

          # TODO: write generic method
          (tag.div { className: 'burn-rate' },

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
                    ) unless @monthSubtractedMoment(3).startOf('month') <= moment(@props.established_on)

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
        ) if @state.selected_chart.people.length > 0

      )
    )

  getInitialState: ->
    selected_time: moment()._d
    selected_chart: @props.charts[0]

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

  # Helpers
  # 
  gatherPeople: ->
    console.log @state.selected_chart.people

    people = _.chain(_.uniq(@state.selected_chart.people, 'uuid'))
      .sortBy (person) -> person.full_name
      .value()

    # TODO: add timestamp key to <td>
    _.map people, (person) =>
      (tag.tr { key: person.uuid },
        (tag.td { className: 'title' }, 
          (tag.div { className: 'name' }, person.full_name)
          (tag.div { className: 'occupation' }, person.occupation)
        )
        (tag.td { className: 'data month-3' }, @showSalary(person, 3))
        (tag.td { className: 'data month-2' }, @showSalary(person, 2))
        (tag.td { className: 'data month-1' }, @showSalary(person, 1))
        (tag.td { className: 'data month-selected' }, @showSalary(person))
      )

  showSalary: (person, offset=0) ->
    if person.salary and person.salary != '0.0' and (
        (
          person.hired_on and
          moment(person.hired_on) < @monthSubtractedMoment(offset) and
          (!person.fired_on or moment(person.fired_on) > @monthSubtractedMoment(offset))
        ) or (
          !person.hired_on and
          !person.fired_on
        ) or (
          !person.hired_on and
          person.fired_on and
          moment(person.fired_on) > @monthSubtractedMoment(offset)
        )
      )

        numeral(person.salary).format('0,0')

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

  onChartChange: (event) ->
    @setState({ selected_chart: _.filter(@props.charts, { 'uuid': event.target.value })[0] })

# Exports
# 
cc.module('react/company/burn_rate').exports = MainComponent
