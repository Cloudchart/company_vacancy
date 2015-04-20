# @cjsx React.DOM


# Exports
#
module.exports = React.createClass

  displayName: 'Slide1'

  propTypes:
    onNext: React.PropTypes.func

  render: ->
    <article className="slide slide-1">
      <header>
        <div className="logo">
          <i className="svg-icon svg-cloudchart-logo"></i>
          Cloud<b>Chart</b>
        </div>
        <h1>Learn from unicorns</h1>
        <h2>Discover how successfull startups have grown</h2>
      </header>
      <p>
        Hello, <strong>{ @props.user.get('first_name') },</strong><br/> and welcome to CloudChart. Use it as your educational tool  to learn from unicorns: follow their companies' timelines, collect valuable insights by successful entrepreneurs, investors, and experts, and put them to action.
      </p>
      <button className="cc" onClick = { @props.onNext }>
        Start Learning
      </button>
    </article>
    
    