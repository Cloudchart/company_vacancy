# @cjsx React.DOM



# Exports
#
module.exports = React.createClass

  displayName: 'Slide1'

  propTypes:
    onNext: React.PropTypes.func


  # Lifecycle methods
  #


  # Renderers
  #


  render: ->
    <article className="slide slide1">
      <header>
        <div className="logo">
          <i className="svg-icon svg-cloudchart-logo"></i>
          Cloud<b>Chart</b>
        </div>
        <h1>Learn from Unicorns</h1>
        <h2>Discover how successfull startups have grown</h2>
      </header>
      <p>
        Hello, <strong>Tiffany,</strong> and welcome to CloudChart. Use it as your educational tool  to learn from unicorns: follow their companies' timelines, collect valuable insights by successful entrepreneurs, investors, and experts, and put them to action.
      </p>
      <button className="cc" onClick = { @props.onNext }>
        Start Learning
      </button>
    </article>
    
    