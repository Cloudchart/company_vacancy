# @cjsx React.DOM



# Exports
#
module.exports = React.createClass

  displayName: 'Slide2'

  propTypes:
    onNext: React.PropTypes.func


  # Lifecycle methods
  #


  # Renderers
  #


  render: ->
    <article className="slide slide-6">
      <header>
        <div className="logo">
          <i className="svg-icon svg-cloudchart-logo"></i>
          Cloud<b>Chart</b>
        </div>
        <h1>Stay in the loop</h1>
        <h2>Add your email to profile: we'll keep you posted on new unicorns' timelines, useful insights, and new CloudChart features.</h2>
      </header>
      <div className="equation">
        <i className="svg-icon svg-cloudchart-logo" />
        +
        <i className="fa fa-envelope-o" />
        =
        <i className="fa fa-heart" />
      </div>
      <input className="" placeholder="Peter, your work email goes here" />
      <button className="cc">
        Sign me up!
      </button>
    </article>