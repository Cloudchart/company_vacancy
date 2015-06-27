# @cjsx React.DOM

# Exports
#
module.exports = React.createClass

  displayName: 'ProductHuntMobile'

  render: ->
    <section className="cc-container-common producthunt-mobile">
      <header>
        <h1>
          Hello Producthunter!
        </h1>
        <h2>
          We created Insights.VC to help founders solve problems they face every day.
          We have found valuable insights by founders, investors and experts, and put them together into relevant collections.
        </h2>
      </header>
      <section>
        <figure className="kitty" />
      </section>
      <footer>
        <a href={ @props.url }>Open PH collection</a>
      </footer>
    </section>
