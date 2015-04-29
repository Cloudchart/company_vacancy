# @cjsx React.DOM

# Exports
#
module.exports = React.createClass

  displayName: 'WelcomeTourIntroduction'

  propTypes:
    className: React.PropTypes.string
    onNext:    React.PropTypes.func

  render: ->
    <article className={ "tour-introduction " + @props.className }>
      <header>
        <div className="logo">
          <i className="svg-icon svg-cloudchart-logo"></i>
          Cloud<b>Chart</b>
        </div>
        <h1>Learn from unicorns</h1>
        <h2>Discover the insights<br/>on how successful startups have grown</h2>
      </header>
      <p>
        Hello, <strong>{ @props.user.get('first_name') },</strong><br/> and welcome to CloudChart. Use it to grow your business: follow unicorns' timelines, collect valuable insights by successful entrepreneurs, investors, and experts.
      </p>
      <button className="cc" onClick = { @props.onNext }>
        Start Learning
      </button>
    </article>
    
    